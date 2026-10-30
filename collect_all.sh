#!/bin/bash

# Coleta geral: roda acquire.sh para todas as combinações de teste e representação.
# Para na primeira falha de acquire.sh (fora da tomada ou erro de compilação).
# RUNS, REPS, STEPS, COOLDOWN, CPU e BASE_SEED são repassados a acquire.sh.

# Encontra a pasta do script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR"

# Impede suspensão durante a coleta, inclusive ao fechar a tampa
if [[ -z "$COLLECT_INHIBITED" ]]; then
    export COLLECT_INHIBITED=1
    exec systemd-inhibit --what=idle:sleep:handle-lid-switch --who=tcc --why="Coleta do TCC" "$0" "$@"
fi

TESTS=(scale lac pers)
GRAPHS=(2_5d voxel vertex dual)
TOTAL=$((${#TESTS[@]} * ${#GRAPHS[@]}))
DONE=0
START=$(date +%s)

for test in "${TESTS[@]}"; do
    for graph in "${GRAPHS[@]}"; do
        DONE=$((DONE + 1))
        echo -e "\n\e[1;35m[Coleta $DONE/$TOTAL]\e[0m $test/$graph ($(date +%H:%M:%S))"

        if ! ./acquire.sh "$test" "$graph"; then
            echo -e "\e[1;31m[Coleta $DONE/$TOTAL]\e[0m $test/$graph falhou, abortando." >&2
            exit 1
        fi
    done
done

ELAPSED=$(($(date +%s) - START))
echo -e "\n\e[1;32m[Coleta]\e[0m Fim: $TOTAL combinações em $((ELAPSED / 3600))h$(((ELAPSED % 3600) / 60))min."

# Execuções com exit_code diferente de 0 não interrompem a coleta; lista aqui
FAILED=$(awk -F, 'FNR > 1 && $5 != 0 { print FILENAME ": execução " $1 " (exit " $5 ")" }' \
    $(find results -name manifest.csv -newermt "@$START"))
if [[ -n "$FAILED" ]]; then
    echo -e "\e[1;31m[Coleta]\e[0m Execuções com falha:\n$FAILED"
    exit 1
fi
