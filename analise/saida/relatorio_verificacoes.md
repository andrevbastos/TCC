# Relatório de verificações

Dados: `campanha_20261109_172346`

Versões: Python 3.14.0, numpy 2.5.4, pandas 3.1.1, scipy 1.18.1, matplotlib 3.11.2, statsmodels 0.15.0 (só na validação)


## Arquivos e blocos

- **[OK]** Número de CSVs de resultado: 80 (esperado 80)
- **[OK]** Blocos teste × grafo com 5 execuções: 16 blocos, 16 com 5 execuções
- **[OK]** Número de linhas: 25600 (esperado 25600)
- **[INFO]** Nome da 2ª coluna (nível) por teste: scale: Escala; lac: Lacunaridade; pers: Persistência; frequency: Comprimento de Onda

## Terrenos

- **[OK]** 50 terrenos por nível em cada teste × grafo: mín 50, máx 50 terrenos; 4 níveis por bloco
- **[OK]** 10 terrenos por nível em cada execução: mín 10, máx 10
- **[OK]** Mesmos terrenos (nível, seed) nas quatro representações de cada teste
- **[OK]** Cada seed pertence a um único nível dentro do teste
- **[OK]** Cada terreno tem 4 algoritmos × 2 pares, sem duplicatas
- **[OK]** Métricas sem ausentes e estritamente positivas (ln definido): 0 ausentes, 0 valores ≤ 0

## Coluna de tempo

- **[OK]** Buscas com medição única ≥ 5 ms: k = 1 e 'tempo_busca' = 'Tempo de Execução': 19462 linhas
- **[OK]** Buscas com medição única < 5 ms: 'tempo_busca' = mediana de k repetições: 6138 linhas; k entre 1 e 9; 1 delas com k = 1 (a única repetição já passou de 5 ms), das quais 1 diferem de 'Tempo de Execução'
- **[INFO]** Coluna usada como tempo de busca: 'tempo_busca' (exclui a construção do grafo; inclui a inicialização dos vetores de estado, registrada à parte em 'tempo_inicializacao')

## Custo relativo de Dijkstra e A*

- **[OK]** Custo relativo do Dijkstra = 1 em todas as linhas: 6400 linhas
- **[OK]** Custo relativo do A* = 1 em todas as linhas: 6400/6400 exatamente iguais; máx |rel − 1| = 0.000e+00
- **[OK]** Nenhum algoritmo com custo menor que o do Dijkstra: 0 linhas

## manifest.csv, sementes e commit

- **[OK]** Linhas do manifest: 80 linhas, 80 mantidas (tentativas > 1: 0)
- **[OK]** exit_code = 0 em todos os blocos mantidos: valores: [0]
- **[OK]** throttle = 0 em todos os blocos mantidos: throttle_core máx 0, throttle_pkg máx 0, throttle_ms máx 0
- **[OK]** Manifest cobre 16 blocos × 5 execuções
- **[INFO]** Commit registrado no manifest: c802ee3748efd78ae3d958bcd4fd6b1730fe6777; git_sujo = [0]
- **[OK]** Semente de cada execução = BASE_SEED + execução: BASE_SEED (params.env) = 20261030; sementes por execução: 1: 20261031, 2: 20261032, 3: 20261033, 4: 20261034, 5: 20261035
- **[OK]** 'Seed base' do stdout.log = semente da execução no manifest: execução 1: [20261031]; execução 2: [20261032]; execução 3: [20261033]; execução 4: [20261034]; execução 5: [20261035]

## Validação da ANOVA split-plot (dados simulados)

- **[OK]** SS de todos os termos = OLS do statsmodels (SS tipo I com termos de terreno): máx. erro relativo 1.70e-14
- **[OK]** Graus de liberdade de todos os termos conferem com o OLS
- **[OK]** ε de Greenhouse-Geisser estimado ≈ ε teórico (n = 2000 por nível): B: 0.785 vs 0.785; C: 0.906 vs 0.905; B×C: 0.627 vs 0.616
- **[OK]** ε ≈ 1 com covariância esférica: B: 1.000, C: 0.999, B×C: 0.999
- **[OK]** Médias marginais simuladas recuperadas (efeitos de A, B e C conhecidos): máx. desvio 0.025 (escala ln)
- **[OK]** Erro tipo I sob H0 com GG ≤ α (+3 EP) em 2000 simulações, n = 50 por nível: GG: A 0.059, B 0.049, C 0.043, B×C 0.056, A×B 0.053, A×C 0.052, A×B×C 0.049 | sem correção: A 0.059, B 0.058, C 0.050, B×C 0.084, A×B 0.070, A×C 0.062, A×B×C 0.091
- **[OK]** Poder simulado = poder teórico do F não central (2000 simulações, ±3 EP): A 0.640 vs 0.645, B 0.762 vs 0.758, C 0.760 vs 0.758, B×C 0.684 vs 0.681
- **[OK]** Tukey entre níveis = scipy.stats.tukey_hsd: máx |Δp| = 0.0e+00
