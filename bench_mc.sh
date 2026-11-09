#!/bin/bash

# Benchmark do Marching Cubes (`tcc mcbench`) nos terrenos do passo 500 da coleta de escala.
# As sementes vêm de results/scale_vertex_20261108_092340/run_*/ (colunas "Escala" = 500 e
# "Seed do Terreno"): 10 sementes únicas por execução original, 50 no total.
# Cada execução daqui mede as 10 sementes de uma execução original, com as mesmas checagens de
# acquire.sh (tomada, build Release, taskset, arrefecimento, throttling) e o turbo desligado
# como em collect_all.sh. Uso: ./bench_mc.sh

COOLDOWN=${COOLDOWN:-60}
CPU=${CPU:-2}                 # P-core (0-3 no i5-1235U), como em acquire.sh
TEMP_MAX=${TEMP_MAX:-45}
TEMP_WAIT=${TEMP_WAIT:-900}
ATTEMPTS=${ATTEMPTS:-3}
SRC=${SRC:-results/scale_vertex_20261108_092340}
SEEDS_PER_RUN=10
TOTAL_SEEDS=50
AC=/sys/class/power_supply/ADP1/online
THROTTLE=/sys/devices/system/cpu/cpu$CPU/thermal_throttle
PKG_TEMP=$(grep -l x86_pkg_temp /sys/class/thermal/thermal_zone*/type 2>/dev/null | head -1 | xargs -r dirname)/temp
NO_TURBO=/sys/devices/system/cpu/intel_pstate/no_turbo

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR"

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

throttle_snapshot() {
    echo "$(cat "$THROTTLE/core_throttle_count") $(cat "$THROTTLE/package_throttle_count")" \
         "$(($(cat "$THROTTLE/core_throttle_total_time_ms") + $(cat "$THROTTLE/package_throttle_total_time_ms")))"
}

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

# 1. Sementes: únicas por run_*, na ordem em que aparecem no CSV
RUN_DIRS=("$SRC"/run_*)
declare -a RUN_SEEDS
ALL_SEEDS=()
for d in "${RUN_DIRS[@]}"; do
    csv=$(ls "$d"/scale_*.csv 2>/dev/null | head -1)
    if [[ -z "$csv" ]]; then
        echo -e "\e[1;31m[Sementes]\e[0m $d sem CSV de escala, abortando." >&2
        exit 1
    fi
    seeds=$(awk -F, '
        NR == 1 { for (i = 1; i <= NF; i++) { if ($i == "Escala") e = i; if ($i == "Seed do Terreno") s = i } next }
        e && s && $e + 0 == 500 && !seen[$s]++ { print $s }' "$csv" | tr '\n' ' ')
    count=$(wc -w <<< "$seeds")
    if ((count != SEEDS_PER_RUN)); then
        echo -e "\e[1;31m[Sementes]\e[0m $csv tem $count sementes únicas com Escala = 500 (esperado $SEEDS_PER_RUN), abortando." >&2
        exit 1
    fi
    RUN_SEEDS+=("$seeds")
    ALL_SEEDS+=($seeds)
done
UNIQUE=$(printf '%s\n' "${ALL_SEEDS[@]}" | sort -u | wc -l)
if ((UNIQUE != TOTAL_SEEDS)); then
    echo -e "\e[1;31m[Sementes]\e[0m $UNIQUE sementes únicas em ${#RUN_DIRS[@]} execuções (esperado $TOTAL_SEEDS), abortando." >&2
    exit 1
fi

# 2. Turbo desligado, como na coleta (collect_all.sh), restaurado ao sair
if [[ ! -e "$NO_TURBO" ]]; then
    echo -e "\e[1;31m[Turbo]\e[0m $NO_TURBO não existe (intel_pstate inativo?), abortando." >&2
    exit 1
fi
TURBO_ORIG=$(cat "$NO_TURBO")
if [[ "$TURBO_ORIG" != "1" ]]; then
    echo -e "\e[1;34m[Turbo]\e[0m Desligando o turbo (requer sudo)..."
    if ! echo 1 | sudo tee "$NO_TURBO" > /dev/null; then
        echo -e "\e[1;31m[Turbo]\e[0m Não foi possível desligar o turbo, abortando." >&2
        exit 1
    fi
fi
restore_turbo() {
    [[ "$TURBO_ORIG" == "1" ]] && return
    if echo "$TURBO_ORIG" | sudo -n tee "$NO_TURBO" > /dev/null 2>&1; then
        echo -e "\e[1;34m[Turbo]\e[0m Turbo restaurado."
    else
        echo -e "\e[1;33m[Turbo]\e[0m Restaure manualmente: echo $TURBO_ORIG | sudo tee $NO_TURBO" >&2
    fi
}
trap restore_turbo EXIT
trap 'exit 130' INT TERM

# 3. Build Release
echo -e "\e[1;34m[Build]\e[0m Compilando o tcc..."
mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
if ! cmake --build . --target tcc; then
    echo -e "\e[1;31m[Build] Erro na compilação do tcc!\e[0m"
    exit 1
fi

# 4. Saída
OUT="$DIR/results/mc_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUT"
MANIFEST="$OUT/manifest.csv"
echo "run,run_origem,inicio,duracao_s,exit_code,tentativa,mantida,throttle_core,throttle_pkg,throttle_ms,temp_inicio_c,temp_fim_c,no_turbo,ac_inicio,ac_fim" > "$MANIFEST"
RUNS=${#RUN_SEEDS[@]}

echo -e "\e[1;32m[MC]\e[0m $RUNS execuções × $SEEDS_PER_RUN sementes, ${COOLDOWN}s de pausa + ≤ ${TEMP_MAX}°C, CPU $CPU"
echo -e "\e[1;32m[MC]\e[0m Saída em $OUT"

for ((i = 1; i <= RUNS; i++)); do
    RUN_DIR="$OUT/run_$(printf '%02d' "$i")"
    ORIGIN=$(basename "${RUN_DIRS[i - 1]}")
    read -ra SEEDS <<< "${RUN_SEEDS[i - 1]}"

    for ((a = 1; a <= ATTEMPTS; a++)); do
        if ((i == 1 && a == 1)); then cool_down 0; else cool_down "$COOLDOWN"; fi

        mkdir -p "$RUN_DIR"
        check_ac "antes da execução $i"
        AC0=$(cat "$AC")
        TEMP_START=$(temp_c)
        read -r C0 P0 MS0 <<< "$(throttle_snapshot)"
        START=$(date +%s)

        echo -e "\n\e[1;34m[Execução $i/$RUNS]\e[0m $ORIGIN, tentativa $a/$ATTEMPTS, ${TEMP_START}°C ($(date +%H:%M:%S))"
        taskset -c "$CPU" ./tcc mcbench "${SEEDS[@]}" --out "$RUN_DIR/mc.csv" \
            > >(tee "$RUN_DIR/stdout.log") 2> >(tee "$RUN_DIR/stderr.log" >&2)
        CODE=$?
        wait

        END=$(date +%s)
        read -r C1 P1 MS1 <<< "$(throttle_snapshot)"
        DC=$((C1 - C0)); DP=$((P1 - P0)); DMS=$((MS1 - MS0))
        AC1=$(cat "$AC" 2>/dev/null)

        THROTTLED=$((DC > 0 || DP > 0))
        KEEP=1
        if ((THROTTLED && a < ATTEMPTS)); then
            KEEP=0
        fi
        echo "$i,$ORIGIN,$(date -d "@$START" +%FT%T),$((END - START)),$CODE,$a,$KEEP,$DC,$DP,$DMS,$TEMP_START,$(temp_c),$(cat "$NO_TURBO"),$AC0,$AC1" >> "$MANIFEST"
        check_ac "durante a execução $i, resultados dela inválidos"

        if ((KEEP == 0)); then
            mv "$RUN_DIR" "$OUT/descartada_run_$(printf '%02d' "$i")_t$a"
            echo -e "\e[1;31m[Térmica]\e[0m throttling na execução $i (núcleo $DC, pacote $DP eventos, ${DMS} ms), refazendo"
            continue
        fi
        if ((THROTTLED)); then
            echo -e "\e[1;31m[Térmica]\e[0m execução $i mantida COM throttling após $ATTEMPTS tentativas (núcleo $DC, pacote $DP, ${DMS} ms)"
        fi
        if ((CODE != 0)); then
            echo -e "\e[1;31m[Execução $i/$RUNS]\e[0m falhou (exit $CODE), abortando" >&2
            exit 1
        fi
        echo -e "\e[1;32m[Execução $i/$RUNS]\e[0m concluída em $((END - START))s"
        break
    done
done

# 5. mc.csv: concatena as execuções mantidas (cabeçalho uma vez)
head -1 "$OUT/run_01/mc.csv" > "$OUT/mc.csv"
for f in "$OUT"/run_*/mc.csv; do tail -n +2 "$f" >> "$OUT/mc.csv"; done

echo -e "\n\e[1;32m[MC]\e[0m Fim. $(($(wc -l < "$OUT/mc.csv") - 1)) medições em $OUT/mc.csv, manifesto em $MANIFEST"
