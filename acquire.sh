#!/bin/bash

# Aquisição de métricas: várias execuções separadas de `tcc stats`, com pausa
# para arrefecimento entre elas. Uso: ./acquire.sh <scale|lac|pers> <2_5d|voxel|vertex|dual>

RUNS=${RUNS:-5}
REPS=${REPS:-10}
STEPS=${STEPS:-4}
COOLDOWN=${COOLDOWN:-60}
BASE_SEED=${BASE_SEED:-20261030}  # fixa: as representações medem os mesmos terrenos em cada execução
CPU=${CPU:-2}  # P-core (0-3 no i5-1235U): evita migração para E-cores durante as medições
TEMP_MAX=${TEMP_MAX:-45}      # °C do pacote para iniciar uma execução (espera após o COOLDOWN)
TEMP_WAIT=${TEMP_WAIT:-900}   # espera máxima pela temperatura, em segundos
ATTEMPTS=${ATTEMPTS:-3}       # tentativas por execução quando há thermal throttling
AC=/sys/class/power_supply/ADP1/online
THROTTLE=/sys/devices/system/cpu/cpu$CPU/thermal_throttle
PKG_TEMP=$(grep -l x86_pkg_temp /sys/class/thermal/thermal_zone*/type 2>/dev/null | head -1 | xargs -r dirname)/temp

TEST=$1
GRAPH=$2

case "$TEST" in scale|lac|pers) ;; *) echo "Uso: $0 <scale|lac|pers> <2_5d|voxel|vertex|dual>"; exit 1 ;; esac
case "$GRAPH" in 2_5d|voxel|vertex|dual) ;; *) echo "Uso: $0 <scale|lac|pers> <2_5d|voxel|vertex|dual>"; exit 1 ;; esac

# Aborta se o notebook não estiver na tomada (frequência da CPU muda na bateria)
check_ac() {
    if [[ "$(cat "$AC" 2>/dev/null)" != "1" ]]; then
        echo -e "\e[1;31m[Energia] Notebook fora da tomada ($1), abortando!\e[0m" >&2
        exit 1
    fi
}

check_ac "início"

if [[ ! -r "$THROTTLE/core_throttle_count" || ! -r "$PKG_TEMP" ]]; then
    echo -e "\e[1;31m[Térmica] Contadores de throttling ou sensor x86_pkg_temp indisponíveis, abortando!\e[0m" >&2
    exit 1
fi

temp_c() { echo $(($(cat "$PKG_TEMP") / 1000)); }

# Contadores de thermal throttling do núcleo usado e do pacote (eventos e tempo total em ms)
throttle_snapshot() {
    echo "$(cat "$THROTTLE/core_throttle_count") $(cat "$THROTTLE/package_throttle_count")" \
         "$(($(cat "$THROTTLE/core_throttle_total_time_ms") + $(cat "$THROTTLE/package_throttle_total_time_ms")))"
}

# Pausa fixa de COOLDOWN segundos e depois espera o pacote chegar a TEMP_MAX
cool_down() {
    for ((t = $1; t > 0; t--)); do
        printf '\r\e[1;33m[Arrefecimento]\e[0m %3ds (%d°C) ' "$t" "$(temp_c)"
        sleep 1
    done
    local waited=0
    while (($(temp_c) > TEMP_MAX)); do
        if ((waited >= TEMP_WAIT)); then
            printf '\r\e[K\e[1;31m[Térmica]\e[0m %d°C após %ds de espera, seguindo mesmo assim\n' "$(temp_c)" "$waited"
            return
        fi
        printf '\r\e[1;33m[Arrefecimento]\e[0m aguardando %d°C ≤ %d°C (%ds) ' "$(temp_c)" "$TEMP_MAX" "$waited"
        sleep 5
        waited=$((waited + 5))
    done
    printf '\r\e[K'
}

# Encontra a pasta do script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR"

# 1. Compila o executável de aquisição
echo -e "\e[1;34m[Build]\e[0m Compilando o tcc..."
mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
if ! cmake --build . --target tcc; then
    echo -e "\e[1;31m[Build] Erro na compilação do tcc!\e[0m"
    exit 1
fi

# 2. Diretório da aquisição (o CSV tem nome fixo, então cada execução ganha sua pasta)
OUT="$DIR/results/${TEST}_${GRAPH}_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUT"
MANIFEST="$OUT/manifest.csv"
# exit_code fica na 5ª coluna (lida pelo collect_all.sh); mantida=0 marca tentativas descartadas
echo "run,seed,inicio,duracao_s,exit_code,tentativa,mantida,throttle_core,throttle_pkg,throttle_ms,temp_inicio_c,temp_fim_c" > "$MANIFEST"

echo -e "\e[1;32m[Aquisição]\e[0m $TEST/$GRAPH: $RUNS execuções × $REPS reps × $STEPS steps, ${COOLDOWN}s de pausa + ≤ ${TEMP_MAX}°C, CPU $CPU"
echo -e "\e[1;32m[Aquisição]\e[0m Saída em $OUT"

# 3. Execuções (a partir de build/, como o viewer)
for ((i = 1; i <= RUNS; i++)); do
    RUN_DIR="$OUT/run_$(printf '%02d' "$i")"
    SEED=$((BASE_SEED + i))

    # Refaz a execução se houver thermal throttling, até ATTEMPTS tentativas
    for ((a = 1; a <= ATTEMPTS; a++)); do
        # Arrefecimento antes de toda execução (inclusive a 1ª, depois da compilação)
        if ((i == 1 && a == 1)); then cool_down 0; else cool_down "$COOLDOWN"; fi

        mkdir -p "$RUN_DIR"
        check_ac "antes da execução $i"
        TEMP_START=$(temp_c)
        read -r C0 P0 MS0 <<< "$(throttle_snapshot)"
        START=$(date +%s)

        echo -e "\n\e[1;34m[Execução $i/$RUNS]\e[0m seed=$SEED, tentativa $a/$ATTEMPTS, ${TEMP_START}°C ($(date +%H:%M:%S))"
        taskset -c "$CPU" ./tcc stats "$TEST" "$GRAPH" "$REPS" "$STEPS" --seed "$SEED" --save "$RUN_DIR" \
            > >(tee "$RUN_DIR/stdout.log") 2> >(tee "$RUN_DIR/stderr.log" >&2)
        CODE=$?
        wait

        END=$(date +%s)
        read -r C1 P1 MS1 <<< "$(throttle_snapshot)"
        DC=$((C1 - C0)); DP=$((P1 - P0)); DMS=$((MS1 - MS0))
        check_ac "durante a execução $i, resultados dela inválidos"

        THROTTLED=$((DC > 0 || DP > 0))
        KEEP=1
        if ((THROTTLED && a < ATTEMPTS)); then
            KEEP=0
        fi
        echo "$i,$SEED,$(date -d "@$START" +%FT%T),$((END - START)),$CODE,$a,$KEEP,$DC,$DP,$DMS,$TEMP_START,$(temp_c)" >> "$MANIFEST"

        if ((KEEP == 0)); then
            # Guarda a tentativa fora do padrão run_*/ para não entrar na análise
            mv "$RUN_DIR" "$OUT/descartada_run_$(printf '%02d' "$i")_t$a"
            echo -e "\e[1;31m[Térmica]\e[0m throttling na execução $i (núcleo $DC, pacote $DP eventos, ${DMS} ms), refazendo"
            continue
        fi

        if ((THROTTLED)); then
            echo -e "\e[1;31m[Térmica]\e[0m execução $i mantida COM throttling após $ATTEMPTS tentativas (núcleo $DC, pacote $DP, ${DMS} ms)"
        fi
        if ((CODE != 0)); then
            echo -e "\e[1;31m[Execução $i/$RUNS]\e[0m falhou (exit $CODE), seguindo para a próxima"
        else
            echo -e "\e[1;32m[Execução $i/$RUNS]\e[0m concluída em $((END - START))s"
        fi
        break
    done
done

echo -e "\n\e[1;32m[Aquisição]\e[0m Fim. Manifesto em $MANIFEST"
