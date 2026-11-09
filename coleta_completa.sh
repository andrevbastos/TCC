#!/bin/bash

# Campanha completa de coleta: RUNS execuções; em cada execução, os blocos de teste
# (teste × representação) rodam em ordem aleatória reproduzível, sorteada com a semente
# BASE_SEED + execução. Cada bloco é um processo `tcc stats` separado, com as mesmas
# salvaguardas de acquire.sh (CPU fixa, arrefecimento, temperatura, throttling, energia AC)
# e de collect_all.sh (turbo desligado, sem suspensão).
#
# Checkpoint: cada bloco concluído com exit 0 é anotado em checkpoint.csv. Para retomar uma
# campanha interrompida, passe o diretório dela; os parâmetros vêm do params.env salvo nele.
#
# Uso: ./coleta_completa.sh                    # nova campanha em results/campanha_<data>
#      ./coleta_completa.sh <dir_da_campanha>   # retoma
# LEVELS="0 3" restringe os passos (piloto); vazio roda todos.
# RESULTS_ROOT muda a pasta-mãe da campanha (padrão: results/).

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR"

# Impede suspensão durante a coleta, inclusive ao fechar a tampa
if [[ -z "$COLLECT_INHIBITED" ]]; then
    export COLLECT_INHIBITED=1
    exec systemd-inhibit --what=idle:sleep:handle-lid-switch --who=tcc --why="Coleta completa do TCC" "$0" "$@"
fi

RESUME_DIR=$1

if [[ -n "$RESUME_DIR" ]]; then
    OUT=$(cd "$RESUME_DIR" 2>/dev/null && pwd)
    if [[ -z "$OUT" || ! -f "$OUT/params.env" ]]; then
        echo -e "\e[1;31m[Retomada]\e[0m $RESUME_DIR não é uma campanha (falta params.env)." >&2
        exit 1
    fi
    # Os parâmetros da campanha original prevalecem sobre o ambiente atual
    source "$OUT/params.env"
else
    RUNS=${RUNS:-5}
    REPS=${REPS:-10}
    STEPS=${STEPS:-4}
    COOLDOWN=${COOLDOWN:-60}
    BASE_SEED=${BASE_SEED:-20261030}  # fixa: as representações medem os mesmos terrenos em cada execução
    CPU=${CPU:-2}                     # P-core (0-3 no i5-1235U)
    TEMP_MAX=${TEMP_MAX:-45}          # °C do pacote para iniciar um bloco
    TEMP_WAIT=${TEMP_WAIT:-900}       # espera máxima pela temperatura, em segundos
    ATTEMPTS=${ATTEMPTS:-3}           # tentativas por bloco quando há thermal throttling
    LEVELS=${LEVELS:-}                # índices de passo; vazio = todos
fi

TESTS=(scale lac pers frequency)
GRAPHS=(2_5d voxel vertex dual)

AC=/sys/class/power_supply/ADP1/online
THROTTLE=/sys/devices/system/cpu/cpu$CPU/thermal_throttle
PKG_TEMP=$(grep -l x86_pkg_temp /sys/class/thermal/thermal_zone*/type 2>/dev/null | head -1 | xargs -r dirname)/temp
NO_TURBO=/sys/devices/system/cpu/intel_pstate/no_turbo

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

# Desliga o turbo durante a coleta e restaura ao sair
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

# Ordem reproduzível dos blocos: Fisher–Yates com gerador de Park–Miller (minstd), em
# aritmética do bash, para não depender da implementação de rand/shuf.
shuffled_blocks() {
    local state=$(( ($1 % 2147483646) + 1 ))
    local blocks=()
    for test in "${TESTS[@]}"; do
        for graph in "${GRAPHS[@]}"; do
            blocks+=("$test/$graph")
        done
    done
    for ((j = ${#blocks[@]} - 1; j > 0; j--)); do
        state=$(( (state * 48271) % 2147483647 ))
        local r=$(( state % (j + 1) ))
        local tmp=${blocks[j]}
        blocks[j]=${blocks[r]}
        blocks[r]=$tmp
    done
    printf '%s\n' "${blocks[@]}"
}

# 1. Compila o executável de aquisição (Release)
echo -e "\e[1;34m[Build]\e[0m Compilando o tcc..."
mkdir -p build
(
    cd build
    cmake .. -DCMAKE_BUILD_TYPE=Release > /dev/null && cmake --build . --target tcc
) || { echo -e "\e[1;31m[Build] Erro na compilação do tcc!\e[0m" >&2; exit 1; }

cache_var() { grep -E "^$1:" build/CMakeCache.txt | cut -d= -f2-; }
COMMIT=$(git rev-parse HEAD)
# Alterações não commitadas no código que entra no executável ou na coleta
GIT_DIRTY=0
[[ -n "$(git status --porcelain -- include src cmake CMakeLists.txt coleta_completa.sh)" ]] && GIT_DIRTY=1
BUILD_TYPE=$(cache_var CMAKE_BUILD_TYPE)
CXX_FLAGS=$(cache_var CMAKE_CXX_FLAGS)
CXX_FLAGS_RELEASE=$(cache_var CMAKE_CXX_FLAGS_RELEASE)

# 2. Diretório da campanha, parâmetros, manifesto e checkpoint
if [[ -z "$RESUME_DIR" ]]; then
    OUT="${RESULTS_ROOT:-$DIR/results}/campanha_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$OUT"
    {
        for var in RUNS REPS STEPS COOLDOWN BASE_SEED CPU TEMP_MAX TEMP_WAIT ATTEMPTS LEVELS; do
            printf '%s=%q\n' "$var" "${!var}"
        done
    } > "$OUT/params.env"
fi

MANIFEST="$OUT/manifest.csv"
CHECKPOINT="$OUT/checkpoint.csv"
# Colunas de acquire.sh primeiro (exit_code segue na 5ª), novas no fim
[[ -f "$MANIFEST" ]] || echo "run,seed,inicio,duracao_s,exit_code,tentativa,mantida,throttle_core,throttle_pkg,throttle_ms,temp_inicio_c,temp_fim_c,teste,grafo,ordem,commit,git_sujo,build_type,cxx_flags,cxx_flags_release,warmup" > "$MANIFEST"
[[ -f "$CHECKPOINT" ]] || echo "run,teste,grafo" > "$CHECKPOINT"

LEVEL_ARGS=()
for level in $LEVELS; do
    LEVEL_ARGS+=(--level "$level")
done

TOTAL=$((RUNS * ${#TESTS[@]} * ${#GRAPHS[@]}))
DONE_BEFORE=$(($(wc -l < "$CHECKPOINT") - 1))
echo -e "\e[1;32m[Campanha]\e[0m $RUNS execuções × ${#TESTS[@]} testes × ${#GRAPHS[@]} representações, $REPS reps × $STEPS steps${LEVELS:+ (níveis: $LEVELS)}, CPU $CPU"
echo -e "\e[1;32m[Campanha]\e[0m Saída em $OUT ($DONE_BEFORE/$TOTAL blocos já concluídos)"

FIRST=1
START_ALL=$(date +%s)

# 3. Execuções
for ((i = 1; i <= RUNS; i++)); do
    SEED=$((BASE_SEED + i))
    mapfile -t ORDER < <(shuffled_blocks "$SEED")

    for ((o = 0; o < ${#ORDER[@]}; o++)); do
        TEST=${ORDER[o]%/*}
        GRAPH=${ORDER[o]#*/}

        if grep -qx "$i,$TEST,$GRAPH" "$CHECKPOINT"; then
            continue
        fi

        RUN_DIR="$OUT/${TEST}_${GRAPH}/run_$(printf '%02d' "$i")"
        # Sobra de um bloco interrompido: guarda fora do padrão run_*/ e refaz
        if [[ -d "$RUN_DIR" ]]; then
            mv "$RUN_DIR" "$OUT/${TEST}_${GRAPH}/interrompida_run_$(printf '%02d' "$i")_$(date +%s)"
        fi

        # Refaz o bloco se houver thermal throttling, até ATTEMPTS tentativas
        for ((a = 1; a <= ATTEMPTS; a++)); do
            if ((FIRST)); then cool_down 0; else cool_down "$COOLDOWN"; fi
            FIRST=0

            mkdir -p "$RUN_DIR"
            check_ac "antes de $TEST/$GRAPH, execução $i"
            TEMP_START=$(temp_c)
            read -r C0 P0 MS0 <<< "$(throttle_snapshot)"
            START=$(date +%s)

            echo -e "\n\e[1;34m[Execução $i/$RUNS, bloco $((o + 1))/${#ORDER[@]}]\e[0m $TEST/$GRAPH seed=$SEED, tentativa $a/$ATTEMPTS, ${TEMP_START}°C ($(date +%H:%M:%S))"
            (
                cd build
                taskset -c "$CPU" ./tcc stats "$TEST" "$GRAPH" "$REPS" "$STEPS" --seed "$SEED" --save "$RUN_DIR" "${LEVEL_ARGS[@]}" \
                    > >(tee "$RUN_DIR/stdout.log") 2> >(tee "$RUN_DIR/stderr.log" >&2)
                code=$?
                wait
                exit $code
            )
            CODE=$?

            END=$(date +%s)
            # O tcc informa no stdout se fez o warm-up antes de cada busca cronometrada
            WARMUP=$(grep -m1 -oP '^warmup=\K[01]' "$RUN_DIR/stdout.log" || echo 0)
            read -r C1 P1 MS1 <<< "$(throttle_snapshot)"
            DC=$((C1 - C0)); DP=$((P1 - P0)); DMS=$((MS1 - MS0))
            check_ac "durante $TEST/$GRAPH, execução $i, resultados dela inválidos"

            THROTTLED=$((DC > 0 || DP > 0))
            KEEP=1
            if ((THROTTLED && a < ATTEMPTS)); then
                KEEP=0
            fi
            echo "$i,$SEED,$(date -d "@$START" +%FT%T),$((END - START)),$CODE,$a,$KEEP,$DC,$DP,$DMS,$TEMP_START,$(temp_c),$TEST,$GRAPH,$((o + 1)),$COMMIT,$GIT_DIRTY,$BUILD_TYPE,\"$CXX_FLAGS\",\"$CXX_FLAGS_RELEASE\",$WARMUP" >> "$MANIFEST"

            if ((KEEP == 0)); then
                mv "$RUN_DIR" "$OUT/${TEST}_${GRAPH}/descartada_run_$(printf '%02d' "$i")_t$a"
                echo -e "\e[1;31m[Térmica]\e[0m throttling em $TEST/$GRAPH (núcleo $DC, pacote $DP eventos, ${DMS} ms), refazendo"
                continue
            fi

            if ((THROTTLED)); then
                echo -e "\e[1;31m[Térmica]\e[0m $TEST/$GRAPH mantido COM throttling após $ATTEMPTS tentativas (núcleo $DC, pacote $DP, ${DMS} ms)"
            fi
            if ((CODE != 0)); then
                # Sem checkpoint: o bloco é refeito numa retomada
                echo -e "\e[1;31m[Execução $i/$RUNS]\e[0m $TEST/$GRAPH falhou (exit $CODE), seguindo"
            else
                echo "$i,$TEST,$GRAPH" >> "$CHECKPOINT"
                echo -e "\e[1;32m[Execução $i/$RUNS]\e[0m $TEST/$GRAPH concluído em $((END - START))s ($(($(wc -l < "$CHECKPOINT") - 1))/$TOTAL)"
            fi
            break
        done
    done
done

ELAPSED=$(($(date +%s) - START_ALL))
echo -e "\n\e[1;32m[Campanha]\e[0m Fim desta sessão em $((ELAPSED / 3600))h$(((ELAPSED % 3600) / 60))min. Manifesto em $MANIFEST"

PENDING=$((TOTAL - ($(wc -l < "$CHECKPOINT") - 1)))
if ((PENDING > 0)); then
    echo -e "\e[1;31m[Campanha]\e[0m $PENDING blocos sem checkpoint (falharam); retome com: $0 $OUT" >&2
    exit 1
fi

THROTTLED=$(awk -F, 'NR > 1 && $7 == 1 && ($8 > 0 || $9 > 0) { print "execução " $1 " " $13 "/" $14 " (núcleo " $8 ", pacote " $9 ", " $10 " ms)" }' "$MANIFEST")
if [[ -n "$THROTTLED" ]]; then
    echo -e "\e[1;31m[Campanha]\e[0m Blocos mantidos com thermal throttling:\n$THROTTLED"
    exit 1
fi
