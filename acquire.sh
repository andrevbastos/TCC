#!/bin/bash

# Aquisição de métricas: várias execuções separadas de `tcc stats`, com pausa
# para arrefecimento entre elas. Uso: ./acquire.sh <scale|lac|pers> <2_5d|voxel|vertex|dual>

RUNS=${RUNS:-10}
REPS=${REPS:-10}
STEPS=${STEPS:-4}
COOLDOWN=${COOLDOWN:-60}
CPU=${CPU:-2}  # P-core (0-3 no i5-1235U): evita migração para E-cores durante as medições
AC=/sys/class/power_supply/ADP1/online

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
echo "run,seed,inicio,duracao_s,exit_code" > "$MANIFEST"

echo -e "\e[1;32m[Aquisição]\e[0m $TEST/$GRAPH: $RUNS execuções × $REPS reps × $STEPS steps, ${COOLDOWN}s de pausa, CPU $CPU"
echo -e "\e[1;32m[Aquisição]\e[0m Saída em $OUT"

# 3. Execuções (a partir de build/, como o viewer)
for ((i = 1; i <= RUNS; i++)); do
    RUN_DIR="$OUT/run_$(printf '%02d' "$i")"
    mkdir -p "$RUN_DIR"
    SEED=$(od -An -N4 -tu4 /dev/urandom | tr -d ' ')
    check_ac "antes da execução $i"
    START=$(date +%s)

    echo -e "\n\e[1;34m[Execução $i/$RUNS]\e[0m seed=$SEED ($(date +%H:%M:%S))"
    taskset -c "$CPU" ./tcc stats "$TEST" "$GRAPH" "$REPS" "$STEPS" --seed "$SEED" --save "$RUN_DIR" \
        > >(tee "$RUN_DIR/stdout.log") 2> >(tee "$RUN_DIR/stderr.log" >&2)
    CODE=$?
    wait

    END=$(date +%s)
    echo "$i,$SEED,$(date -d "@$START" +%FT%T),$((END - START)),$CODE" >> "$MANIFEST"
    check_ac "durante a execução $i, resultados dela inválidos"

    if ((CODE != 0)); then
        echo -e "\e[1;31m[Execução $i/$RUNS]\e[0m falhou (exit $CODE), seguindo para a próxima"
    else
        echo -e "\e[1;32m[Execução $i/$RUNS]\e[0m concluída em $((END - START))s"
    fi

    # 4. Arrefecimento (exceto após a última)
    if ((i < RUNS)); then
        for ((t = COOLDOWN; t > 0; t--)); do
            printf '\r\e[1;33m[Arrefecimento]\e[0m %3ds ' "$t"
            sleep 1
        done
        printf '\r\e[K'
    fi
done

echo -e "\n\e[1;32m[Aquisição]\e[0m Fim. Manifesto em $MANIFEST"
