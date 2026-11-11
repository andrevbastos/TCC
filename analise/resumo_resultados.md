# Resumo dos resultados

Gerado por `analise.py`. Só números; sem interpretação. Valores em escala original são médias geométricas (exp da média dos ln por terreno). Testes F com correção de Greenhouse-Geisser nos efeitos dentro do terreno; α = 0,05. Tabelas completas em `saida/`.

Notação dos efeitos: **N** = nível (entre terrenos), **Alg** = algoritmo, **Rep** = representação. Razão = razão das médias geométricas (grupo 1 / grupo 2).


## Escala


### Tempo de busca

Médias geométricas marginais:

- Nível: 500 = 46,148 ms; 600 = 69,704 ms; 700 = 93,062 ms; 800 = 129,702 ms
- Algoritmo: Dijkstra = 386,041 ms; A* = 414,103 ms; Weighted A* = 104,264 ms; Greedy Best-First = 2,329 ms
- Representação: Grade 2.5D = 33,005 ms; Grade voxelizada = 43,557 ms; Grafo de vértices = 110,368 ms; Grafo dual = 244,702 ms

Média geométrica por algoritmo × representação (todos os níveis):

| Algoritmo | Grade 2.5D | Grade voxelizada | Grafo de vértices | Grafo dual |
|---|---|---|---|---|
| Dijkstra | 215,978 ms | 135,401 ms | 679,745 ms | 1117,268 ms |
| A* | 223,825 ms | 170,670 ms | 656,890 ms | 1171,856 ms |
| Weighted A* | 22,644 ms | 128,231 ms | 95,775 ms | 424,955 ms |
| Greedy Best-First | 1,084 ms | 1,215 ms | 3,470 ms | 6,444 ms |

ANOVA split-plot:

| Efeito | F | gl (GG) | ε GG | p (GG) | η² parcial |
|---|---|---|---|---|---|
| N | 595,01 | 3; 196 | — | < 0,001 | 0,901 |
| Alg | 35531,32 | 1,20; 234,3 | 0,399 | < 0,001 | 0,995 |
| N × Alg | 5,85 | 3,59; 234,3 | 0,399 | < 0,001 | 0,082 |
| Rep | 22039,06 | 1,84; 360,6 | 0,613 | < 0,001 | 0,991 |
| N × Rep | 4,96 | 5,52; 360,6 | 0,613 | < 0,001 | 0,071 |
| Alg × Rep | 1802,37 | 1,97; 385,7 | 0,219 | < 0,001 | 0,902 |
| N × Alg × Rep | 2,83 | 5,90; 385,7 | 0,219 | 0,011 | 0,042 |

Shapiro-Wilk dos resíduos: entre terrenos (n = 200): W = 0,988, p = 0,095; dentro do terreno (n = 3200): W = 0,876, p < 0,001

Tukey dentro do terreno, representações por algoritmo — razão (p):

| Algoritmo | Grade 2.5D / Grade voxelizada | Grade 2.5D / Grafo de vértices | Grade 2.5D / Grafo dual | Grade voxelizada / Grafo de vértices | Grade voxelizada / Grafo dual | Grafo de vértices / Grafo dual |
|---|---|---|---|---|---|---|
| Dijkstra | 1,595 (< 0,001) | 0,318 (< 0,001) | 0,193 (< 0,001) | 0,199 (< 0,001) | 0,121 (< 0,001) | 0,608 (< 0,001) |
| A* | 1,311 (< 0,001) | 0,341 (< 0,001) | 0,191 (< 0,001) | 0,260 (< 0,001) | 0,146 (< 0,001) | 0,561 (< 0,001) |
| Weighted A* | 0,177 (< 0,001) | 0,236 (< 0,001) | 0,053 (< 0,001) | 1,339 (< 0,001) | 0,302 (< 0,001) | 0,225 (< 0,001) |
| Greedy Best-First | 0,892 (< 0,001) | 0,312 (< 0,001) | 0,168 (< 0,001) | 0,350 (< 0,001) | 0,188 (< 0,001) | 0,538 (< 0,001) |

Tukey dentro do terreno, algoritmos por representação — razão (p):

| Representação | Dijkstra / A* | Dijkstra / Weighted A* | Dijkstra / Greedy Best-First | A* / Weighted A* | A* / Greedy Best-First | Weighted A* / Greedy Best-First |
|---|---|---|---|---|---|---|
| Grade 2.5D | 0,965 (0,088) | 9,538 (< 0,001) | 199,218 (< 0,001) | 9,885 (< 0,001) | 206,456 (< 0,001) | 20,886 (< 0,001) |
| Grade voxelizada | 0,793 (< 0,001) | 1,056 (0,002) | 111,466 (< 0,001) | 1,331 (< 0,001) | 140,501 (< 0,001) | 105,563 (< 0,001) |
| Grafo de vértices | 1,035 (0,111) | 7,097 (< 0,001) | 195,915 (< 0,001) | 6,859 (< 0,001) | 189,328 (< 0,001) | 27,604 (< 0,001) |
| Grafo dual | 0,953 (0,009) | 2,629 (< 0,001) | 173,373 (< 0,001) | 2,758 (< 0,001) | 181,843 (< 0,001) | 65,943 (< 0,001) |

Tukey entre níveis (grupos independentes, n = 50 por nível): para cada algoritmo × representação, razão e p do par extremo 800 / 500 e número de pares significativos entre os 6 possíveis:

| Algoritmo | Grade 2.5D | Grade voxelizada | Grafo de vértices | Grafo dual |
|---|---|---|---|---|
| Dijkstra | 2,805 (< 0,001); 6/6 | 2,641 (< 0,001); 6/6 | 2,785 (< 0,001); 6/6 | 2,799 (< 0,001); 6/6 |
| A* | 2,928 (< 0,001); 6/6 | 2,690 (< 0,001); 6/6 | 2,875 (< 0,001); 6/6 | 2,790 (< 0,001); 6/6 |
| Weighted A* | 3,952 (< 0,001); 5/6 | 2,746 (< 0,001); 6/6 | 3,675 (< 0,001); 5/6 | 3,211 (< 0,001); 5/6 |
| Greedy Best-First | 2,383 (< 0,001); 6/6 | 2,257 (< 0,001); 6/6 | 2,393 (< 0,001); 6/6 | 2,520 (< 0,001); 6/6 |

### Vértices expandidos

Médias geométricas marginais:

- Nível: 500 = 69781; 600 = 100618; 700 = 129516; 800 = 174030
- Algoritmo: Dijkstra = 860130; A* = 660544; Weighted A* = 154972; Greedy Best-First = 1797
- Representação: Grade 2.5D = 40678; Grade voxelizada = 86526; Grafo de vértices = 128806; Grafo dual = 349077

Média geométrica por algoritmo × representação (todos os níveis):

| Algoritmo | Grade 2.5D | Grade voxelizada | Grafo de vértices | Grafo dual |
|---|---|---|---|---|
| Dijkstra | 409867 | 409874 | 1277671 | 2550023 |
| A* | 267624 | 396571 | 871772 | 2057585 |
| Weighted A* | 30106 | 235856 | 121399 | 669106 |
| Greedy Best-First | 829 | 1462 | 2036 | 4229 |

ANOVA split-plot:

| Efeito | F | gl (GG) | ε GG | p (GG) | η² parcial |
|---|---|---|---|---|---|
| N | 314,92 | 3; 196 | — | < 0,001 | 0,828 |
| Alg | 42398,75 | 1,74; 340,2 | 0,579 | < 0,001 | 0,995 |
| N × Alg | 13,00 | 5,21; 340,2 | 0,579 | < 0,001 | 0,166 |
| Rep | 19442,74 | 1,77; 347,0 | 0,590 | < 0,001 | 0,990 |
| N × Rep | 2,31 | 5,31; 347,0 | 0,590 | 0,040 | 0,034 |
| Alg × Rep | 1728,46 | 2,33; 456,5 | 0,259 | < 0,001 | 0,898 |
| N × Alg × Rep | 2,90 | 6,99; 456,5 | 0,259 | 0,006 | 0,042 |

Shapiro-Wilk dos resíduos: entre terrenos (n = 200): W = 0,969, p < 0,001; dentro do terreno (n = 3200): W = 0,940, p < 0,001

Tukey dentro do terreno, representações por algoritmo — razão (p):

| Algoritmo | Grade 2.5D / Grade voxelizada | Grade 2.5D / Grafo de vértices | Grade 2.5D / Grafo dual | Grade voxelizada / Grafo de vértices | Grade voxelizada / Grafo dual | Grafo de vértices / Grafo dual |
|---|---|---|---|---|---|---|
| Dijkstra | 1,000 (1,000) | 0,321 (< 0,001) | 0,161 (< 0,001) | 0,321 (< 0,001) | 0,161 (< 0,001) | 0,501 (< 0,001) |
| A* | 0,675 (< 0,001) | 0,307 (< 0,001) | 0,130 (< 0,001) | 0,455 (< 0,001) | 0,193 (< 0,001) | 0,424 (< 0,001) |
| Weighted A* | 0,128 (< 0,001) | 0,248 (< 0,001) | 0,045 (< 0,001) | 1,943 (< 0,001) | 0,352 (< 0,001) | 0,181 (< 0,001) |
| Greedy Best-First | 0,567 (< 0,001) | 0,407 (< 0,001) | 0,196 (< 0,001) | 0,718 (< 0,001) | 0,346 (< 0,001) | 0,481 (< 0,001) |

Tukey dentro do terreno, algoritmos por representação — razão (p):

| Representação | Dijkstra / A* | Dijkstra / Weighted A* | Dijkstra / Greedy Best-First | A* / Weighted A* | A* / Greedy Best-First | Weighted A* / Greedy Best-First |
|---|---|---|---|---|---|---|
| Grade 2.5D | 1,532 (< 0,001) | 13,614 (< 0,001) | 494,348 (< 0,001) | 8,889 (< 0,001) | 322,787 (< 0,001) | 36,312 (< 0,001) |
| Grade voxelizada | 1,034 (0,117) | 1,738 (< 0,001) | 280,345 (< 0,001) | 1,681 (< 0,001) | 271,246 (< 0,001) | 161,320 (< 0,001) |
| Grafo de vértices | 1,466 (< 0,001) | 10,525 (< 0,001) | 627,646 (< 0,001) | 7,181 (< 0,001) | 428,251 (< 0,001) | 59,636 (< 0,001) |
| Grafo dual | 1,239 (< 0,001) | 3,811 (< 0,001) | 602,914 (< 0,001) | 3,075 (< 0,001) | 486,484 (< 0,001) | 158,200 (< 0,001) |

Tukey entre níveis (grupos independentes, n = 50 por nível): para cada algoritmo × representação, razão e p do par extremo 800 / 500 e número de pares significativos entre os 6 possíveis:

| Algoritmo | Grade 2.5D | Grade voxelizada | Grafo de vértices | Grafo dual |
|---|---|---|---|---|
| Dijkstra | 2,560 (< 0,001); 6/6 | 2,560 (< 0,001); 6/6 | 2,575 (< 0,001); 6/6 | 2,578 (< 0,001); 6/6 |
| A* | 2,640 (< 0,001); 6/6 | 2,569 (< 0,001); 6/6 | 2,665 (< 0,001); 6/6 | 2,617 (< 0,001); 6/6 |
| Weighted A* | 3,701 (< 0,001); 5/6 | 2,625 (< 0,001); 6/6 | 3,450 (< 0,001); 5/6 | 3,065 (< 0,001); 5/6 |
| Greedy Best-First | 1,758 (< 0,001); 6/6 | 1,743 (< 0,001); 6/6 | 1,803 (< 0,001); 5/6 | 1,920 (< 0,001); 5/6 |

### Pico da lista aberta

Médias geométricas marginais:

- Nível: 500 = 2783; 600 = 3354; 700 = 3925; 800 = 4541
- Algoritmo: Dijkstra = 2048; A* = 4180; Weighted A* = 6743; Greedy Best-First = 2882
- Representação: Grade 2.5D = 3912; Grade voxelizada = 2074; Grafo de vértices = 5182; Grafo dual = 3958

Média geométrica por algoritmo × representação (todos os níveis):

| Algoritmo | Grade 2.5D | Grade voxelizada | Grafo de vértices | Grafo dual |
|---|---|---|---|---|
| Dijkstra | 2409 | 1101 | 2873 | 2311 |
| A* | 5747 | 1961 | 6437 | 4209 |
| Weighted A* | 6424 | 4099 | 9895 | 7935 |
| Greedy Best-First | 2633 | 2092 | 3940 | 3178 |

ANOVA split-plot:

| Efeito | F | gl (GG) | ε GG | p (GG) | η² parcial |
|---|---|---|---|---|---|
| N | 2650,32 | 3; 196 | — | < 0,001 | 0,976 |
| Alg | 18998,76 | 1,83; 357,7 | 0,608 | < 0,001 | 0,990 |
| N × Alg | 2,55 | 5,48; 357,7 | 0,608 | 0,024 | 0,038 |
| Rep | 25116,99 | 2,57; 503,6 | 0,856 | < 0,001 | 0,992 |
| N × Rep | 1,70 | 7,71; 503,6 | 0,856 | 0,098 | 0,025 |
| Alg × Rep | 1061,61 | 3,51; 687,2 | 0,390 | < 0,001 | 0,844 |
| N × Alg × Rep | 1,88 | 10,52; 687,2 | 0,390 | 0,042 | 0,028 |

Shapiro-Wilk dos resíduos: entre terrenos (n = 200): W = 0,988, p = 0,089; dentro do terreno (n = 3200): W = 0,952, p < 0,001

Tukey dentro do terreno, representações por algoritmo — razão (p):

| Algoritmo | Grade 2.5D / Grade voxelizada | Grade 2.5D / Grafo de vértices | Grade 2.5D / Grafo dual | Grade voxelizada / Grafo de vértices | Grade voxelizada / Grafo dual | Grafo de vértices / Grafo dual |
|---|---|---|---|---|---|---|
| Dijkstra | 2,189 (< 0,001) | 0,839 (< 0,001) | 1,043 (< 0,001) | 0,383 (< 0,001) | 0,476 (< 0,001) | 1,243 (< 0,001) |
| A* | 2,931 (< 0,001) | 0,893 (< 0,001) | 1,365 (< 0,001) | 0,305 (< 0,001) | 0,466 (< 0,001) | 1,529 (< 0,001) |
| Weighted A* | 1,567 (< 0,001) | 0,649 (< 0,001) | 0,810 (< 0,001) | 0,414 (< 0,001) | 0,517 (< 0,001) | 1,247 (< 0,001) |
| Greedy Best-First | 1,258 (< 0,001) | 0,668 (< 0,001) | 0,828 (< 0,001) | 0,531 (< 0,001) | 0,658 (< 0,001) | 1,240 (< 0,001) |

Tukey dentro do terreno, algoritmos por representação — razão (p):

| Representação | Dijkstra / A* | Dijkstra / Weighted A* | Dijkstra / Greedy Best-First | A* / Weighted A* | A* / Greedy Best-First | Weighted A* / Greedy Best-First |
|---|---|---|---|---|---|---|
| Grade 2.5D | 0,419 (< 0,001) | 0,375 (< 0,001) | 0,915 (< 0,001) | 0,894 (< 0,001) | 2,183 (< 0,001) | 2,440 (< 0,001) |
| Grade voxelizada | 0,561 (< 0,001) | 0,268 (< 0,001) | 0,526 (< 0,001) | 0,478 (< 0,001) | 0,937 (< 0,001) | 1,959 (< 0,001) |
| Grafo de vértices | 0,446 (< 0,001) | 0,290 (< 0,001) | 0,729 (< 0,001) | 0,651 (< 0,001) | 1,634 (< 0,001) | 2,511 (< 0,001) |
| Grafo dual | 0,549 (< 0,001) | 0,291 (< 0,001) | 0,727 (< 0,001) | 0,530 (< 0,001) | 1,324 (< 0,001) | 2,496 (< 0,001) |

Tukey entre níveis (grupos independentes, n = 50 por nível): para cada algoritmo × representação, razão e p do par extremo 800 / 500 e número de pares significativos entre os 6 possíveis:

| Algoritmo | Grade 2.5D | Grade voxelizada | Grafo de vértices | Grafo dual |
|---|---|---|---|---|
| Dijkstra | 1,609 (< 0,001); 6/6 | 1,592 (< 0,001); 6/6 | 1,584 (< 0,001); 6/6 | 1,588 (< 0,001); 6/6 |
| A* | 1,638 (< 0,001); 6/6 | 1,640 (< 0,001); 6/6 | 1,561 (< 0,001); 6/6 | 1,582 (< 0,001); 6/6 |
| Weighted A* | 1,807 (< 0,001); 6/6 | 1,655 (< 0,001); 6/6 | 1,702 (< 0,001); 6/6 | 1,597 (< 0,001); 6/6 |
| Greedy Best-First | 1,607 (< 0,001); 6/6 | 1,641 (< 0,001); 6/6 | 1,654 (< 0,001); 6/6 | 1,660 (< 0,001); 6/6 |

### Custo relativo

Apenas Weighted A* e Greedy Best-First.

Médias geométricas marginais:

- Nível: 500 = 1,1245; 600 = 1,1296; 700 = 1,1278; 800 = 1,1316
- Algoritmo: Weighted A* = 1,0372; Greedy Best-First = 1,2275
- Representação: Grade 2.5D = 1,1229; Grade voxelizada = 1,1161; Grafo de vértices = 1,1569; Grafo dual = 1,1179

Média geométrica por algoritmo × representação (todos os níveis):

| Algoritmo | Grade 2.5D | Grade voxelizada | Grafo de vértices | Grafo dual |
|---|---|---|---|---|
| Weighted A* | 1,0571 | 1,0072 | 1,0566 | 1,0287 |
| Greedy Best-First | 1,1928 | 1,2368 | 1,2668 | 1,2149 |

ANOVA split-plot:

| Efeito | F | gl (GG) | ε GG | p (GG) | η² parcial |
|---|---|---|---|---|---|
| N | 2,53 | 3; 196 | — | 0,059 | 0,037 |
| Alg | 11037,79 | 1,00; 196,0 | 1,000 | < 0,001 | 0,983 |
| N × Alg | 2,92 | 3,00; 196,0 | 1,000 | 0,035 | 0,043 |
| Rep | 282,35 | 2,63; 515,6 | 0,877 | < 0,001 | 0,590 |
| N × Rep | 1,13 | 7,89; 515,6 | 0,877 | 0,340 | 0,017 |
| Alg × Rep | 323,65 | 2,58; 504,8 | 0,859 | < 0,001 | 0,623 |
| N × Alg × Rep | 1,19 | 7,73; 504,8 | 0,859 | 0,302 | 0,018 |

Shapiro-Wilk dos resíduos: entre terrenos (n = 200): W = 0,967, p < 0,001; dentro do terreno (n = 1600): W = 0,969, p < 0,001

Tukey dentro do terreno, representações por algoritmo — razão (p):

| Algoritmo | Grade 2.5D / Grade voxelizada | Grade 2.5D / Grafo de vértices | Grade 2.5D / Grafo dual | Grade voxelizada / Grafo de vértices | Grade voxelizada / Grafo dual | Grafo de vértices / Grafo dual |
|---|---|---|---|---|---|---|
| Weighted A* | 1,050 (< 0,001) | 1,000 (0,995) | 1,028 (< 0,001) | 0,953 (< 0,001) | 0,979 (< 0,001) | 1,027 (< 0,001) |
| Greedy Best-First | 0,964 (< 0,001) | 0,942 (< 0,001) | 0,982 (< 0,001) | 0,976 (< 0,001) | 1,018 (< 0,001) | 1,043 (< 0,001) |

Tukey dentro do terreno, algoritmos por representação — razão (p):

| Representação | Weighted A* / Greedy Best-First |
|---|---|
| Grade 2.5D | 0,886 (< 0,001) |
| Grade voxelizada | 0,814 (< 0,001) |
| Grafo de vértices | 0,834 (< 0,001) |
| Grafo dual | 0,847 (< 0,001) |

Tukey entre níveis (grupos independentes, n = 50 por nível): para cada algoritmo × representação, razão e p do par extremo 800 / 500 e número de pares significativos entre os 6 possíveis:

| Algoritmo | Grade 2.5D | Grade voxelizada | Grafo de vértices | Grafo dual |
|---|---|---|---|---|
| Weighted A* | 1,003 (0,314); 2/6 | 1,002 (0,009); 3/6 | 0,998 (0,882); 0/6 | 1,000 (0,998); 0/6 |
| Greedy Best-First | 1,008 (0,714); 0/6 | 1,008 (0,552); 0/6 | 1,010 (0,399); 0/6 | 1,021 (0,006); 1/6 |

## Lacunaridade


### Tempo de busca

Médias geométricas marginais:

- Nível: 1,5 = 29,620 ms; 1,75 = 35,834 ms; 2 = 46,160 ms; 2,25 = 65,912 ms
- Algoritmo: Dijkstra = 212,682 ms; A* = 220,671 ms; Weighted A* = 48,529 ms; Greedy Best-First = 1,418 ms
- Representação: Grade 2.5D = 18,037 ms; Grade voxelizada = 25,512 ms; Grafo de vértices = 57,368 ms; Grafo dual = 122,329 ms

Média geométrica por algoritmo × representação (todos os níveis):

| Algoritmo | Grade 2.5D | Grade voxelizada | Grafo de vértices | Grafo dual |
|---|---|---|---|---|
| Dijkstra | 121,529 ms | 78,846 ms | 360,645 ms | 592,083 ms |
| A* | 120,364 ms | 97,038 ms | 336,537 ms | 603,266 ms |
| Weighted A* | 10,596 ms | 69,340 ms | 44,290 ms | 170,436 ms |
| Greedy Best-First | 0,683 ms | 0,799 ms | 2,015 ms | 3,678 ms |

ANOVA split-plot:

| Efeito | F | gl (GG) | ε GG | p (GG) | η² parcial |
|---|---|---|---|---|---|
| N | 378,02 | 3; 196 | — | < 0,001 | 0,853 |
| Alg | 33976,09 | 1,20; 235,4 | 0,400 | < 0,001 | 0,994 |
| N × Alg | 115,81 | 3,60; 235,4 | 0,400 | < 0,001 | 0,639 |
| Rep | 17449,55 | 2,25; 440,0 | 0,748 | < 0,001 | 0,989 |
| N × Rep | 150,85 | 6,74; 440,0 | 0,748 | < 0,001 | 0,698 |
| Alg × Rep | 1730,39 | 2,53; 495,1 | 0,281 | < 0,001 | 0,898 |
| N × Alg × Rep | 49,17 | 7,58; 495,1 | 0,281 | < 0,001 | 0,429 |

Shapiro-Wilk dos resíduos: entre terrenos (n = 200): W = 0,996, p = 0,899; dentro do terreno (n = 3200): W = 0,880, p < 0,001

Tukey dentro do terreno, representações por algoritmo — razão (p):

| Algoritmo | Grade 2.5D / Grade voxelizada | Grade 2.5D / Grafo de vértices | Grade 2.5D / Grafo dual | Grade voxelizada / Grafo de vértices | Grade voxelizada / Grafo dual | Grafo de vértices / Grafo dual |
|---|---|---|---|---|---|---|
| Dijkstra | 1,541 (< 0,001) | 0,337 (< 0,001) | 0,205 (< 0,001) | 0,219 (< 0,001) | 0,133 (< 0,001) | 0,609 (< 0,001) |
| A* | 1,240 (< 0,001) | 0,358 (< 0,001) | 0,200 (< 0,001) | 0,288 (< 0,001) | 0,161 (< 0,001) | 0,558 (< 0,001) |
| Weighted A* | 0,153 (< 0,001) | 0,239 (< 0,001) | 0,062 (< 0,001) | 1,566 (< 0,001) | 0,407 (< 0,001) | 0,260 (< 0,001) |
| Greedy Best-First | 0,855 (< 0,001) | 0,339 (< 0,001) | 0,186 (< 0,001) | 0,396 (< 0,001) | 0,217 (< 0,001) | 0,548 (< 0,001) |

Tukey dentro do terreno, algoritmos por representação — razão (p):

| Representação | Dijkstra / A* | Dijkstra / Weighted A* | Dijkstra / Greedy Best-First | A* / Weighted A* | A* / Greedy Best-First | Weighted A* / Greedy Best-First |
|---|---|---|---|---|---|---|
| Grade 2.5D | 1,010 (0,930) | 11,469 (< 0,001) | 177,967 (< 0,001) | 11,359 (< 0,001) | 176,261 (< 0,001) | 15,517 (< 0,001) |
| Grade voxelizada | 0,813 (< 0,001) | 1,137 (< 0,001) | 98,742 (< 0,001) | 1,399 (< 0,001) | 121,524 (< 0,001) | 86,837 (< 0,001) |
| Grafo de vértices | 1,072 (< 0,001) | 8,143 (< 0,001) | 178,984 (< 0,001) | 7,598 (< 0,001) | 167,020 (< 0,001) | 21,981 (< 0,001) |
| Grafo dual | 0,981 (0,642) | 3,474 (< 0,001) | 160,960 (< 0,001) | 3,540 (< 0,001) | 164,000 (< 0,001) | 46,334 (< 0,001) |

Tukey entre níveis (grupos independentes, n = 50 por nível): para cada algoritmo × representação, razão e p do par extremo 2,25 / 1,5 e número de pares significativos entre os 6 possíveis:

| Algoritmo | Grade 2.5D | Grade voxelizada | Grafo de vértices | Grafo dual |
|---|---|---|---|---|
| Dijkstra | 1,225 (< 0,001); 6/6 | 1,195 (< 0,001); 6/6 | 1,954 (< 0,001); 6/6 | 1,863 (< 0,001); 6/6 |
| A* | 1,479 (< 0,001); 6/6 | 1,290 (< 0,001); 6/6 | 2,415 (< 0,001); 6/6 | 2,220 (< 0,001); 6/6 |
| Weighted A* | 10,729 (< 0,001); 6/6 | 1,799 (< 0,001); 6/6 | 7,561 (< 0,001); 6/6 | 7,691 (< 0,001); 6/6 |
| Greedy Best-First | 1,218 (< 0,001); 5/6 | 1,133 (< 0,001); 4/6 | 2,021 (< 0,001); 6/6 | 2,117 (< 0,001); 6/6 |

### Vértices expandidos

Médias geométricas marginais:

- Nível: 1,5 = 47145; 1,75 = 56213; 2 = 70756; 2,25 = 99115
- Algoritmo: Dijkstra = 507375; A* = 373948; Weighted A* = 75438; Greedy Best-First = 1299
- Representação: Grade 2.5D = 23887; Grade voxelizada = 54257; Grafo de vértices = 73738; Grafo dual = 194481

Média geométrica por algoritmo × representação (todos os níveis):

| Algoritmo | Grade 2.5D | Grade voxelizada | Grafo de vértices | Grafo dual |
|---|---|---|---|---|
| Dijkstra | 249994 | 249999 | 729122 | 1454284 |
| A* | 150236 | 241156 | 477749 | 1129725 |
| Weighted A* | 14463 | 131856 | 58901 | 288329 |
| Greedy Best-First | 599 | 1090 | 1441 | 3020 |

ANOVA split-plot:

| Efeito | F | gl (GG) | ε GG | p (GG) | η² parcial |
|---|---|---|---|---|---|
| N | 246,01 | 3; 196 | — | < 0,001 | 0,790 |
| Alg | 39976,26 | 1,62; 317,1 | 0,539 | < 0,001 | 0,995 |
| N × Alg | 98,47 | 4,85; 317,1 | 0,539 | < 0,001 | 0,601 |
| Rep | 16510,66 | 2,12; 415,7 | 0,707 | < 0,001 | 0,988 |
| N × Rep | 149,46 | 6,36; 415,7 | 0,707 | < 0,001 | 0,696 |
| Alg × Rep | 1592,49 | 2,82; 553,1 | 0,314 | < 0,001 | 0,890 |
| N × Alg × Rep | 40,39 | 8,47; 553,1 | 0,314 | < 0,001 | 0,382 |

Shapiro-Wilk dos resíduos: entre terrenos (n = 200): W = 0,994, p = 0,574; dentro do terreno (n = 3200): W = 0,911, p < 0,001

Tukey dentro do terreno, representações por algoritmo — razão (p):

| Algoritmo | Grade 2.5D / Grade voxelizada | Grade 2.5D / Grafo de vértices | Grade 2.5D / Grafo dual | Grade voxelizada / Grafo de vértices | Grade voxelizada / Grafo dual | Grafo de vértices / Grafo dual |
|---|---|---|---|---|---|---|
| Dijkstra | 1,000 (1,000) | 0,343 (< 0,001) | 0,172 (< 0,001) | 0,343 (< 0,001) | 0,172 (< 0,001) | 0,501 (< 0,001) |
| A* | 0,623 (< 0,001) | 0,314 (< 0,001) | 0,133 (< 0,001) | 0,505 (< 0,001) | 0,213 (< 0,001) | 0,423 (< 0,001) |
| Weighted A* | 0,110 (< 0,001) | 0,246 (< 0,001) | 0,050 (< 0,001) | 2,239 (< 0,001) | 0,457 (< 0,001) | 0,204 (< 0,001) |
| Greedy Best-First | 0,550 (< 0,001) | 0,416 (< 0,001) | 0,198 (< 0,001) | 0,757 (< 0,001) | 0,361 (< 0,001) | 0,477 (< 0,001) |

Tukey dentro do terreno, algoritmos por representação — razão (p):

| Representação | Dijkstra / A* | Dijkstra / Weighted A* | Dijkstra / Greedy Best-First | A* / Weighted A* | A* / Greedy Best-First | Weighted A* / Greedy Best-First |
|---|---|---|---|---|---|---|
| Grade 2.5D | 1,664 (< 0,001) | 17,285 (< 0,001) | 417,110 (< 0,001) | 10,388 (< 0,001) | 250,667 (< 0,001) | 24,131 (< 0,001) |
| Grade voxelizada | 1,037 (0,104) | 1,896 (< 0,001) | 229,323 (< 0,001) | 1,829 (< 0,001) | 221,212 (< 0,001) | 120,951 (< 0,001) |
| Grafo de vértices | 1,526 (< 0,001) | 12,379 (< 0,001) | 506,006 (< 0,001) | 8,111 (< 0,001) | 331,555 (< 0,001) | 40,877 (< 0,001) |
| Grafo dual | 1,287 (< 0,001) | 5,044 (< 0,001) | 481,557 (< 0,001) | 3,918 (< 0,001) | 374,086 (< 0,001) | 95,474 (< 0,001) |

Tukey entre níveis (grupos independentes, n = 50 por nível): para cada algoritmo × representação, razão e p do par extremo 2,25 / 1,5 e número de pares significativos entre os 6 possíveis:

| Algoritmo | Grade 2.5D | Grade voxelizada | Grafo de vértices | Grafo dual |
|---|---|---|---|---|
| Dijkstra | 1,000 (0,529); 0/6 | 1,000 (0,632); 0/6 | 1,715 (< 0,001); 6/6 | 1,716 (< 0,001); 6/6 |
| A* | 1,587 (< 0,001); 6/6 | 1,034 (< 0,001); 4/6 | 2,216 (< 0,001); 6/6 | 2,123 (< 0,001); 6/6 |
| Weighted A* | 9,982 (< 0,001); 6/6 | 1,771 (< 0,001); 6/6 | 6,821 (< 0,001); 6/6 | 6,793 (< 0,001); 6/6 |
| Greedy Best-First | 1,444 (< 0,001); 5/6 | 1,195 (< 0,001); 4/6 | 2,204 (< 0,001); 6/6 | 2,057 (< 0,001); 6/6 |

### Pico da lista aberta

Médias geométricas marginais:

- Nível: 1,5 = 2361; 1,75 = 2509; 2 = 2780; 2,25 = 3193
- Algoritmo: Dijkstra = 1523; A* = 3190; Weighted A* = 4951; Greedy Best-First = 2186
- Representação: Grade 2.5D = 2934; Grade voxelizada = 1600; Grafo de vértices = 3806; Grafo dual = 2943

Média geométrica por algoritmo × representação (todos os níveis):

| Algoritmo | Grade 2.5D | Grade voxelizada | Grafo de vértices | Grafo dual |
|---|---|---|---|---|
| Dijkstra | 1802 | 809 | 2136 | 1727 |
| A* | 4656 | 1471 | 4797 | 3154 |
| Weighted A* | 4320 | 3503 | 6948 | 5711 |
| Greedy Best-First | 2044 | 1572 | 2947 | 2410 |

ANOVA split-plot:

| Efeito | F | gl (GG) | ε GG | p (GG) | η² parcial |
|---|---|---|---|---|---|
| N | 1021,63 | 3; 196 | — | < 0,001 | 0,940 |
| Alg | 18327,68 | 1,97; 385,3 | 0,655 | < 0,001 | 0,989 |
| N × Alg | 38,32 | 5,90; 385,3 | 0,655 | < 0,001 | 0,370 |
| Rep | 16950,97 | 2,57; 504,4 | 0,858 | < 0,001 | 0,989 |
| N × Rep | 172,42 | 7,72; 504,4 | 0,858 | < 0,001 | 0,725 |
| Alg × Rep | 1086,84 | 3,35; 656,9 | 0,372 | < 0,001 | 0,847 |
| N × Alg × Rep | 149,75 | 10,05; 656,9 | 0,372 | < 0,001 | 0,696 |

Shapiro-Wilk dos resíduos: entre terrenos (n = 200): W = 0,986, p = 0,049; dentro do terreno (n = 3200): W = 0,935, p < 0,001

Tukey dentro do terreno, representações por algoritmo — razão (p):

| Algoritmo | Grade 2.5D / Grade voxelizada | Grade 2.5D / Grafo de vértices | Grade 2.5D / Grafo dual | Grade voxelizada / Grafo de vértices | Grade voxelizada / Grafo dual | Grafo de vértices / Grafo dual |
|---|---|---|---|---|---|---|
| Dijkstra | 2,226 (< 0,001) | 0,843 (< 0,001) | 1,043 (< 0,001) | 0,379 (< 0,001) | 0,469 (< 0,001) | 1,237 (< 0,001) |
| A* | 3,166 (< 0,001) | 0,971 (0,002) | 1,476 (< 0,001) | 0,307 (< 0,001) | 0,466 (< 0,001) | 1,521 (< 0,001) |
| Weighted A* | 1,233 (< 0,001) | 0,622 (< 0,001) | 0,756 (< 0,001) | 0,504 (< 0,001) | 0,613 (< 0,001) | 1,217 (< 0,001) |
| Greedy Best-First | 1,300 (< 0,001) | 0,694 (< 0,001) | 0,848 (< 0,001) | 0,533 (< 0,001) | 0,653 (< 0,001) | 1,223 (< 0,001) |

Tukey dentro do terreno, algoritmos por representação — razão (p):

| Representação | Dijkstra / A* | Dijkstra / Weighted A* | Dijkstra / Greedy Best-First | A* / Weighted A* | A* / Greedy Best-First | Weighted A* / Greedy Best-First |
|---|---|---|---|---|---|---|
| Grade 2.5D | 0,387 (< 0,001) | 0,417 (< 0,001) | 0,881 (< 0,001) | 1,078 (< 0,001) | 2,278 (< 0,001) | 2,114 (< 0,001) |
| Grade voxelizada | 0,550 (< 0,001) | 0,231 (< 0,001) | 0,515 (< 0,001) | 0,420 (< 0,001) | 0,935 (< 0,001) | 2,228 (< 0,001) |
| Grafo de vértices | 0,445 (< 0,001) | 0,307 (< 0,001) | 0,725 (< 0,001) | 0,690 (< 0,001) | 1,628 (< 0,001) | 2,357 (< 0,001) |
| Grafo dual | 0,548 (< 0,001) | 0,302 (< 0,001) | 0,717 (< 0,001) | 0,552 (< 0,001) | 1,309 (< 0,001) | 2,370 (< 0,001) |

Tukey entre níveis (grupos independentes, n = 50 por nível): para cada algoritmo × representação, razão e p do par extremo 2,25 / 1,5 e número de pares significativos entre os 6 possíveis:

| Algoritmo | Grade 2.5D | Grade voxelizada | Grafo de vértices | Grafo dual |
|---|---|---|---|---|
| Dijkstra | 1,345 (< 0,001); 6/6 | 1,488 (< 0,001); 6/6 | 1,531 (< 0,001); 6/6 | 1,505 (< 0,001); 6/6 |
| A* | 0,850 (< 0,001); 5/6 | 1,257 (< 0,001); 6/6 | 1,438 (< 0,001); 6/6 | 1,452 (< 0,001); 6/6 |
| Weighted A* | 2,350 (< 0,001); 6/6 | 0,636 (< 0,001); 6/6 | 2,021 (< 0,001); 6/6 | 1,630 (< 0,001); 6/6 |
| Greedy Best-First | 1,068 (< 0,001); 5/6 | 1,143 (< 0,001); 6/6 | 1,438 (< 0,001); 6/6 | 1,412 (< 0,001); 6/6 |

### Custo relativo

Apenas Weighted A* e Greedy Best-First.

Médias geométricas marginais:

- Nível: 1,5 = 1,0752; 1,75 = 1,0960; 2 = 1,1251; 2,25 = 1,1698
- Algoritmo: Weighted A* = 1,0343; Greedy Best-First = 1,2041
- Representação: Grade 2.5D = 1,0995; Grade voxelizada = 1,1055; Grafo de vértices = 1,1448; Grafo dual = 1,1147

Média geométrica por algoritmo × representação (todos os níveis):

| Algoritmo | Grade 2.5D | Grade voxelizada | Grafo de vértices | Grafo dual |
|---|---|---|---|---|
| Weighted A* | 1,0443 | 1,0084 | 1,0534 | 1,0314 |
| Greedy Best-First | 1,1576 | 1,2119 | 1,2441 | 1,2046 |

ANOVA split-plot:

| Efeito | F | gl (GG) | ε GG | p (GG) | η² parcial |
|---|---|---|---|---|---|
| N | 405,34 | 3; 196 | — | < 0,001 | 0,861 |
| Alg | 8528,73 | 1,00; 196,0 | 1,000 | < 0,001 | 0,978 |
| N × Alg | 582,53 | 3,00; 196,0 | 1,000 | < 0,001 | 0,899 |
| Rep | 347,17 | 2,64; 518,2 | 0,881 | < 0,001 | 0,639 |
| N × Rep | 64,25 | 7,93; 518,2 | 0,881 | < 0,001 | 0,496 |
| Alg × Rep | 366,38 | 2,71; 531,2 | 0,903 | < 0,001 | 0,651 |
| N × Alg × Rep | 27,35 | 8,13; 531,2 | 0,903 | < 0,001 | 0,295 |

Shapiro-Wilk dos resíduos: entre terrenos (n = 200): W = 0,977, p = 0,002; dentro do terreno (n = 1600): W = 0,988, p < 0,001

Tukey dentro do terreno, representações por algoritmo — razão (p):

| Algoritmo | Grade 2.5D / Grade voxelizada | Grade 2.5D / Grafo de vértices | Grade 2.5D / Grafo dual | Grade voxelizada / Grafo de vértices | Grade voxelizada / Grafo dual | Grafo de vértices / Grafo dual |
|---|---|---|---|---|---|---|
| Weighted A* | 1,036 (< 0,001) | 0,991 (< 0,001) | 1,012 (< 0,001) | 0,957 (< 0,001) | 0,978 (< 0,001) | 1,021 (< 0,001) |
| Greedy Best-First | 0,955 (< 0,001) | 0,930 (< 0,001) | 0,961 (< 0,001) | 0,974 (< 0,001) | 1,006 (0,005) | 1,033 (< 0,001) |

Tukey dentro do terreno, algoritmos por representação — razão (p):

| Representação | Weighted A* / Greedy Best-First |
|---|---|
| Grade 2.5D | 0,902 (< 0,001) |
| Grade voxelizada | 0,832 (< 0,001) |
| Grafo de vértices | 0,847 (< 0,001) |
| Grafo dual | 0,856 (< 0,001) |

Tukey entre níveis (grupos independentes, n = 50 por nível): para cada algoritmo × representação, razão e p do par extremo 2,25 / 1,5 e número de pares significativos entre os 6 possíveis:

| Algoritmo | Grade 2.5D | Grade voxelizada | Grafo de vértices | Grafo dual |
|---|---|---|---|---|
| Weighted A* | 1,009 (< 0,001); 5/6 | 0,993 (< 0,001); 5/6 | 0,994 (0,042); 5/6 | 0,976 (< 0,001); 6/6 |
| Greedy Best-First | 1,288 (< 0,001); 6/6 | 1,165 (< 0,001); 6/6 | 1,188 (< 0,001); 6/6 | 1,132 (< 0,001); 6/6 |

## Persistência


### Tempo de busca

Médias geométricas marginais:

- Nível: 0,3 = 27,508 ms; 0,433 = 37,155 ms; 0,567 = 61,784 ms; 0,7 = 112,499 ms
- Algoritmo: Dijkstra = 243,123 ms; A* = 255,559 ms; Weighted A* = 68,523 ms; Greedy Best-First = 1,669 ms
- Representação: Grade 2.5D = 21,460 ms; Grade voxelizada = 27,000 ms; Grafo de vértices = 76,221 ms; Grafo dual = 160,853 ms

Média geométrica por algoritmo × representação (todos os níveis):

| Algoritmo | Grade 2.5D | Grade voxelizada | Grafo de vértices | Grafo dual |
|---|---|---|---|---|
| Dijkstra | 128,887 ms | 82,536 ms | 444,501 ms | 738,885 ms |
| A* | 130,201 ms | 100,569 ms | 425,753 ms | 765,122 ms |
| Weighted A* | 16,848 ms | 75,726 ms | 68,742 ms | 251,378 ms |
| Greedy Best-First | 0,750 ms | 0,846 ms | 2,594 ms | 4,711 ms |

ANOVA split-plot:

| Efeito | F | gl (GG) | ε GG | p (GG) | η² parcial |
|---|---|---|---|---|---|
| N | 1277,93 | 3; 196 | — | < 0,001 | 0,951 |
| Alg | 32733,41 | 1,30; 254,3 | 0,433 | < 0,001 | 0,994 |
| N × Alg | 250,80 | 3,89; 254,3 | 0,433 | < 0,001 | 0,793 |
| Rep | 26240,93 | 2,04; 399,2 | 0,679 | < 0,001 | 0,993 |
| N × Rep | 705,70 | 6,11; 399,2 | 0,679 | < 0,001 | 0,915 |
| Alg × Rep | 1576,88 | 2,47; 483,7 | 0,274 | < 0,001 | 0,889 |
| N × Alg × Rep | 151,67 | 7,40; 483,7 | 0,274 | < 0,001 | 0,699 |

Shapiro-Wilk dos resíduos: entre terrenos (n = 200): W = 0,989, p = 0,109; dentro do terreno (n = 3200): W = 0,864, p < 0,001

Tukey dentro do terreno, representações por algoritmo — razão (p):

| Algoritmo | Grade 2.5D / Grade voxelizada | Grade 2.5D / Grafo de vértices | Grade 2.5D / Grafo dual | Grade voxelizada / Grafo de vértices | Grade voxelizada / Grafo dual | Grafo de vértices / Grafo dual |
|---|---|---|---|---|---|---|
| Dijkstra | 1,562 (< 0,001) | 0,290 (< 0,001) | 0,174 (< 0,001) | 0,186 (< 0,001) | 0,112 (< 0,001) | 0,602 (< 0,001) |
| A* | 1,295 (< 0,001) | 0,306 (< 0,001) | 0,170 (< 0,001) | 0,236 (< 0,001) | 0,131 (< 0,001) | 0,556 (< 0,001) |
| Weighted A* | 0,222 (< 0,001) | 0,245 (< 0,001) | 0,067 (< 0,001) | 1,102 (< 0,001) | 0,301 (< 0,001) | 0,273 (< 0,001) |
| Greedy Best-First | 0,887 (< 0,001) | 0,289 (< 0,001) | 0,159 (< 0,001) | 0,326 (< 0,001) | 0,179 (< 0,001) | 0,551 (< 0,001) |

Tukey dentro do terreno, algoritmos por representação — razão (p):

| Representação | Dijkstra / A* | Dijkstra / Weighted A* | Dijkstra / Greedy Best-First | A* / Weighted A* | A* / Greedy Best-First | Weighted A* / Greedy Best-First |
|---|---|---|---|---|---|---|
| Grade 2.5D | 0,990 (0,894) | 7,650 (< 0,001) | 171,828 (< 0,001) | 7,728 (< 0,001) | 173,580 (< 0,001) | 22,462 (< 0,001) |
| Grade voxelizada | 0,821 (< 0,001) | 1,090 (< 0,001) | 97,615 (< 0,001) | 1,328 (< 0,001) | 118,943 (< 0,001) | 89,562 (< 0,001) |
| Grafo de vértices | 1,044 (0,014) | 6,466 (< 0,001) | 171,329 (< 0,001) | 6,193 (< 0,001) | 164,103 (< 0,001) | 26,496 (< 0,001) |
| Grafo dual | 0,966 (0,072) | 2,939 (< 0,001) | 156,853 (< 0,001) | 3,044 (< 0,001) | 162,422 (< 0,001) | 53,363 (< 0,001) |

Tukey entre níveis (grupos independentes, n = 50 por nível): para cada algoritmo × representação, razão e p do par extremo 0,7 / 0,3 e número de pares significativos entre os 6 possíveis:

| Algoritmo | Grade 2.5D | Grade voxelizada | Grafo de vértices | Grafo dual |
|---|---|---|---|---|
| Dijkstra | 1,432 (< 0,001); 6/6 | 1,360 (< 0,001); 6/6 | 3,737 (< 0,001); 6/6 | 3,728 (< 0,001); 6/6 |
| A* | 1,926 (< 0,001); 6/6 | 1,437 (< 0,001); 6/6 | 4,945 (< 0,001); 6/6 | 4,492 (< 0,001); 6/6 |
| Weighted A* | 39,928 (< 0,001); 6/6 | 2,442 (< 0,001); 6/6 | 34,491 (< 0,001); 6/6 | 23,389 (< 0,001); 6/6 |
| Greedy Best-First | 1,602 (< 0,001); 5/6 | 1,362 (< 0,001); 5/6 | 4,774 (< 0,001); 6/6 | 4,482 (< 0,001); 6/6 |

### Vértices expandidos

Médias geométricas marginais:

- Nível: 0,3 = 43945; 0,433 = 57721; 0,567 = 92691; 0,7 = 167002
- Algoritmo: Dijkstra = 553502; A* = 421981; Weighted A* = 103208; Greedy Best-First = 1629
- Representação: Grade 2.5D = 28148; Grade voxelizada = 57075; Grafo de vértices = 97346; Grafo dual = 251068

Média geométrica por algoritmo × representação (todos os níveis):

| Algoritmo | Grade 2.5D | Grade voxelizada | Grafo de vértices | Grafo dual |
|---|---|---|---|---|
| Dijkstra | 249993 | 249996 | 867682 | 1730838 |
| A* | 161405 | 242825 | 588783 | 1374055 |
| Weighted A* | 21826 | 144798 | 88272 | 406727 |
| Greedy Best-First | 713 | 1207 | 1991 | 4108 |

ANOVA split-plot:

| Efeito | F | gl (GG) | ε GG | p (GG) | η² parcial |
|---|---|---|---|---|---|
| N | 855,22 | 3; 196 | — | < 0,001 | 0,929 |
| Alg | 33595,96 | 1,79; 350,6 | 0,596 | < 0,001 | 0,994 |
| N × Alg | 200,83 | 5,37; 350,6 | 0,596 | < 0,001 | 0,755 |
| Rep | 22922,07 | 1,92; 377,0 | 0,641 | < 0,001 | 0,992 |
| N × Rep | 650,07 | 5,77; 377,0 | 0,641 | < 0,001 | 0,909 |
| Alg × Rep | 1487,09 | 2,78; 545,7 | 0,309 | < 0,001 | 0,884 |
| N × Alg × Rep | 128,36 | 8,35; 545,7 | 0,309 | < 0,001 | 0,663 |

Shapiro-Wilk dos resíduos: entre terrenos (n = 200): W = 0,989, p = 0,108; dentro do terreno (n = 3200): W = 0,901, p < 0,001

Tukey dentro do terreno, representações por algoritmo — razão (p):

| Algoritmo | Grade 2.5D / Grade voxelizada | Grade 2.5D / Grafo de vértices | Grade 2.5D / Grafo dual | Grade voxelizada / Grafo de vértices | Grade voxelizada / Grafo dual | Grafo de vértices / Grafo dual |
|---|---|---|---|---|---|---|
| Dijkstra | 1,000 (1,000) | 0,288 (< 0,001) | 0,144 (< 0,001) | 0,288 (< 0,001) | 0,144 (< 0,001) | 0,501 (< 0,001) |
| A* | 0,665 (< 0,001) | 0,274 (< 0,001) | 0,117 (< 0,001) | 0,412 (< 0,001) | 0,177 (< 0,001) | 0,429 (< 0,001) |
| Weighted A* | 0,151 (< 0,001) | 0,247 (< 0,001) | 0,054 (< 0,001) | 1,640 (< 0,001) | 0,356 (< 0,001) | 0,217 (< 0,001) |
| Greedy Best-First | 0,590 (< 0,001) | 0,358 (< 0,001) | 0,174 (< 0,001) | 0,606 (< 0,001) | 0,294 (< 0,001) | 0,485 (< 0,001) |

Tukey dentro do terreno, algoritmos por representação — razão (p):

| Representação | Dijkstra / A* | Dijkstra / Weighted A* | Dijkstra / Greedy Best-First | A* / Weighted A* | A* / Greedy Best-First | Weighted A* / Greedy Best-First |
|---|---|---|---|---|---|---|
| Grade 2.5D | 1,549 (< 0,001) | 11,454 (< 0,001) | 350,694 (< 0,001) | 7,395 (< 0,001) | 226,421 (< 0,001) | 30,617 (< 0,001) |
| Grade voxelizada | 1,030 (0,183) | 1,727 (< 0,001) | 207,084 (< 0,001) | 1,677 (< 0,001) | 201,144 (< 0,001) | 119,943 (< 0,001) |
| Grafo de vértices | 1,474 (< 0,001) | 9,830 (< 0,001) | 435,738 (< 0,001) | 6,670 (< 0,001) | 295,678 (< 0,001) | 44,329 (< 0,001) |
| Grafo dual | 1,260 (< 0,001) | 4,256 (< 0,001) | 421,364 (< 0,001) | 3,378 (< 0,001) | 334,507 (< 0,001) | 99,016 (< 0,001) |

Tukey entre níveis (grupos independentes, n = 50 por nível): para cada algoritmo × representação, razão e p do par extremo 0,7 / 0,3 e número de pares significativos entre os 6 possíveis:

| Algoritmo | Grade 2.5D | Grade voxelizada | Grafo de vértices | Grafo dual |
|---|---|---|---|---|
| Dijkstra | 1,000 (< 0,001); 4/6 | 1,000 (0,002); 3/6 | 2,948 (< 0,001); 6/6 | 2,950 (< 0,001); 6/6 |
| A* | 2,015 (< 0,001); 6/6 | 1,046 (< 0,001); 5/6 | 4,203 (< 0,001); 6/6 | 3,882 (< 0,001); 6/6 |
| Weighted A* | 36,969 (< 0,001); 6/6 | 2,394 (< 0,001); 6/6 | 28,387 (< 0,001); 6/6 | 18,520 (< 0,001); 6/6 |
| Greedy Best-First | 2,432 (< 0,001); 5/6 | 1,640 (< 0,001); 5/6 | 6,112 (< 0,001); 6/6 | 5,573 (< 0,001); 6/6 |

### Pico da lista aberta

Médias geométricas marginais:

- Nível: 0,3 = 2305; 0,433 = 2538; 0,567 = 3161; 0,7 = 4155
- Algoritmo: Dijkstra = 1741; A* = 3500; Weighted A* = 5401; Greedy Best-First = 2335
- Representação: Grade 2.5D = 3166; Grade voxelizada = 1668; Grafo de vértices = 4356; Grafo dual = 3340

Média geométrica por algoritmo × representação (todos os níveis):

| Algoritmo | Grade 2.5D | Grade voxelizada | Grafo de vértices | Grafo dual |
|---|---|---|---|---|
| Dijkstra | 2027 | 906 | 2482 | 2017 |
| A* | 4842 | 1560 | 5468 | 3635 |
| Weighted A* | 4866 | 3406 | 8134 | 6313 |
| Greedy Best-First | 2104 | 1610 | 3260 | 2690 |

ANOVA split-plot:

| Efeito | F | gl (GG) | ε GG | p (GG) | η² parcial |
|---|---|---|---|---|---|
| N | 3813,67 | 3; 196 | — | < 0,001 | 0,983 |
| Alg | 15877,84 | 1,88; 368,8 | 0,627 | < 0,001 | 0,988 |
| N × Alg | 97,05 | 5,65; 368,8 | 0,627 | < 0,001 | 0,598 |
| Rep | 22882,36 | 2,66; 522,1 | 0,888 | < 0,001 | 0,992 |
| N × Rep | 621,89 | 7,99; 522,1 | 0,888 | < 0,001 | 0,905 |
| Alg × Rep | 1143,78 | 4,05; 792,8 | 0,449 | < 0,001 | 0,854 |
| N × Alg × Rep | 316,05 | 12,14; 792,8 | 0,449 | < 0,001 | 0,829 |

Shapiro-Wilk dos resíduos: entre terrenos (n = 200): W = 0,976, p = 0,002; dentro do terreno (n = 3200): W = 0,930, p < 0,001

Tukey dentro do terreno, representações por algoritmo — razão (p):

| Algoritmo | Grade 2.5D / Grade voxelizada | Grade 2.5D / Grafo de vértices | Grade 2.5D / Grafo dual | Grade voxelizada / Grafo de vértices | Grade voxelizada / Grafo dual | Grafo de vértices / Grafo dual |
|---|---|---|---|---|---|---|
| Dijkstra | 2,238 (< 0,001) | 0,817 (< 0,001) | 1,005 (0,881) | 0,365 (< 0,001) | 0,449 (< 0,001) | 1,231 (< 0,001) |
| A* | 3,104 (< 0,001) | 0,885 (< 0,001) | 1,332 (< 0,001) | 0,285 (< 0,001) | 0,429 (< 0,001) | 1,504 (< 0,001) |
| Weighted A* | 1,429 (< 0,001) | 0,598 (< 0,001) | 0,771 (< 0,001) | 0,419 (< 0,001) | 0,540 (< 0,001) | 1,288 (< 0,001) |
| Greedy Best-First | 1,307 (< 0,001) | 0,645 (< 0,001) | 0,782 (< 0,001) | 0,494 (< 0,001) | 0,598 (< 0,001) | 1,212 (< 0,001) |

Tukey dentro do terreno, algoritmos por representação — razão (p):

| Representação | Dijkstra / A* | Dijkstra / Weighted A* | Dijkstra / Greedy Best-First | A* / Weighted A* | A* / Greedy Best-First | Weighted A* / Greedy Best-First |
|---|---|---|---|---|---|---|
| Grade 2.5D | 0,419 (< 0,001) | 0,417 (< 0,001) | 0,964 (< 0,001) | 0,995 (0,901) | 2,301 (< 0,001) | 2,313 (< 0,001) |
| Grade voxelizada | 0,581 (< 0,001) | 0,266 (< 0,001) | 0,563 (< 0,001) | 0,458 (< 0,001) | 0,969 (< 0,001) | 2,116 (< 0,001) |
| Grafo de vértices | 0,454 (< 0,001) | 0,305 (< 0,001) | 0,761 (< 0,001) | 0,672 (< 0,001) | 1,677 (< 0,001) | 2,495 (< 0,001) |
| Grafo dual | 0,555 (< 0,001) | 0,319 (< 0,001) | 0,750 (< 0,001) | 0,576 (< 0,001) | 1,351 (< 0,001) | 2,347 (< 0,001) |

Tukey entre níveis (grupos independentes, n = 50 por nível): para cada algoritmo × representação, razão e p do par extremo 0,7 / 0,3 e número de pares significativos entre os 6 possíveis:

| Algoritmo | Grade 2.5D | Grade voxelizada | Grafo de vértices | Grafo dual |
|---|---|---|---|---|
| Dijkstra | 1,916 (< 0,001); 6/6 | 2,075 (< 0,001); 6/6 | 2,523 (< 0,001); 6/6 | 2,508 (< 0,001); 6/6 |
| A* | 0,972 (0,319); 4/6 | 1,628 (< 0,001); 6/6 | 2,127 (< 0,001); 6/6 | 2,298 (< 0,001); 6/6 |
| Weighted A* | 2,715 (< 0,001); 6/6 | 0,615 (< 0,001); 5/6 | 3,227 (< 0,001); 6/6 | 2,197 (< 0,001); 6/6 |
| Greedy Best-First | 1,159 (< 0,001); 5/6 | 1,215 (< 0,001); 6/6 | 1,942 (< 0,001); 6/6 | 1,969 (< 0,001); 6/6 |

### Custo relativo

Apenas Weighted A* e Greedy Best-First.

Médias geométricas marginais:

- Nível: 0,3 = 1,0716; 0,433 = 1,0985; 0,567 = 1,1639; 0,7 = 1,2699
- Algoritmo: Weighted A* = 1,0295; Greedy Best-First = 1,2812
- Representação: Grade 2.5D = 1,1421; Grade voxelizada = 1,1373; Grafo de vértices = 1,1727; Grafo dual = 1,1422

Média geométrica por algoritmo × representação (todos os níveis):

| Algoritmo | Grade 2.5D | Grade voxelizada | Grafo de vértices | Grafo dual |
|---|---|---|---|---|
| Weighted A* | 1,0343 | 1,0073 | 1,0490 | 1,0280 |
| Greedy Best-First | 1,2611 | 1,2841 | 1,3111 | 1,2690 |

ANOVA split-plot:

| Efeito | F | gl (GG) | ε GG | p (GG) | η² parcial |
|---|---|---|---|---|---|
| N | 1680,31 | 3; 196 | — | < 0,001 | 0,963 |
| Alg | 17052,56 | 1,00; 196,0 | 1,000 | < 0,001 | 0,989 |
| N × Alg | 2527,82 | 3,00; 196,0 | 1,000 | < 0,001 | 0,975 |
| Rep | 183,54 | 2,55; 500,4 | 0,851 | < 0,001 | 0,484 |
| N × Rep | 119,00 | 7,66; 500,4 | 0,851 | < 0,001 | 0,646 |
| Alg × Rep | 99,41 | 2,48; 485,1 | 0,825 | < 0,001 | 0,337 |
| N × Alg × Rep | 104,48 | 7,43; 485,1 | 0,825 | < 0,001 | 0,615 |

Shapiro-Wilk dos resíduos: entre terrenos (n = 200): W = 0,945, p < 0,001; dentro do terreno (n = 1600): W = 0,981, p < 0,001

Tukey dentro do terreno, representações por algoritmo — razão (p):

| Algoritmo | Grade 2.5D / Grade voxelizada | Grade 2.5D / Grafo de vértices | Grade 2.5D / Grafo dual | Grade voxelizada / Grafo de vértices | Grade voxelizada / Grafo dual | Grafo de vértices / Grafo dual |
|---|---|---|---|---|---|---|
| Weighted A* | 1,027 (< 0,001) | 0,986 (< 0,001) | 1,006 (0,007) | 0,960 (< 0,001) | 0,980 (< 0,001) | 1,020 (< 0,001) |
| Greedy Best-First | 0,982 (< 0,001) | 0,962 (< 0,001) | 0,994 (0,006) | 0,979 (< 0,001) | 1,012 (< 0,001) | 1,033 (< 0,001) |

Tukey dentro do terreno, algoritmos por representação — razão (p):

| Representação | Weighted A* / Greedy Best-First |
|---|---|
| Grade 2.5D | 0,820 (< 0,001) |
| Grade voxelizada | 0,784 (< 0,001) |
| Grafo de vértices | 0,800 (< 0,001) |
| Grafo dual | 0,810 (< 0,001) |

Tukey entre níveis (grupos independentes, n = 50 por nível): para cada algoritmo × representação, razão e p do par extremo 0,7 / 0,3 e número de pares significativos entre os 6 possíveis:

| Algoritmo | Grade 2.5D | Grade voxelizada | Grafo de vértices | Grafo dual |
|---|---|---|---|---|
| Weighted A* | 0,991 (< 0,001); 5/6 | 0,990 (< 0,001); 5/6 | 0,976 (< 0,001); 5/6 | 0,968 (< 0,001); 6/6 |
| Greedy Best-First | 1,631 (< 0,001); 6/6 | 1,389 (< 0,001); 6/6 | 1,384 (< 0,001); 6/6 | 1,337 (< 0,001); 6/6 |

## Comprimento de onda


### Tempo de busca

Médias geométricas marginais:

- Nível: 200 = 58,575 ms; 275 = 42,313 ms; 350 = 32,849 ms; 500 = 24,065 ms
- Algoritmo: Dijkstra = 203,948 ms; A* = 212,818 ms; Weighted A* = 33,665 ms; Greedy Best-First = 1,341 ms
- Representação: Grade 2.5D = 15,631 ms; Grade voxelizada = 24,673 ms; Grafo de vértices = 47,928 ms; Grafo dual = 106,000 ms

Média geométrica por algoritmo × representação (todos os níveis):

| Algoritmo | Grade 2.5D | Grade voxelizada | Grafo de vértices | Grafo dual |
|---|---|---|---|---|
| Dijkstra | 119,604 ms | 77,852 ms | 333,373 ms | 557,351 ms |
| A* | 118,418 ms | 95,626 ms | 317,357 ms | 570,807 ms |
| Weighted A* | 6,273 ms | 63,448 ms | 27,149 ms | 118,877 ms |
| Greedy Best-First | 0,672 ms | 0,785 ms | 1,837 ms | 3,338 ms |

ANOVA split-plot:

| Efeito | F | gl (GG) | ε GG | p (GG) | η² parcial |
|---|---|---|---|---|---|
| N | 504,09 | 3; 196 | — | < 0,001 | 0,885 |
| Alg | 33657,63 | 1,11; 217,7 | 0,370 | < 0,001 | 0,994 |
| N × Alg | 176,43 | 3,33; 217,7 | 0,370 | < 0,001 | 0,730 |
| Rep | 17349,38 | 2,08; 407,6 | 0,693 | < 0,001 | 0,989 |
| N × Rep | 206,03 | 6,24; 407,6 | 0,693 | < 0,001 | 0,759 |
| Alg × Rep | 2494,24 | 2,33; 457,6 | 0,259 | < 0,001 | 0,927 |
| N × Alg × Rep | 61,97 | 7,00; 457,6 | 0,259 | < 0,001 | 0,487 |

Shapiro-Wilk dos resíduos: entre terrenos (n = 200): W = 0,995, p = 0,765; dentro do terreno (n = 3200): W = 0,870, p < 0,001

Tukey dentro do terreno, representações por algoritmo — razão (p):

| Algoritmo | Grade 2.5D / Grade voxelizada | Grade 2.5D / Grafo de vértices | Grade 2.5D / Grafo dual | Grade voxelizada / Grafo de vértices | Grade voxelizada / Grafo dual | Grafo de vértices / Grafo dual |
|---|---|---|---|---|---|---|
| Dijkstra | 1,536 (< 0,001) | 0,359 (< 0,001) | 0,215 (< 0,001) | 0,234 (< 0,001) | 0,140 (< 0,001) | 0,598 (< 0,001) |
| A* | 1,238 (< 0,001) | 0,373 (< 0,001) | 0,207 (< 0,001) | 0,301 (< 0,001) | 0,168 (< 0,001) | 0,556 (< 0,001) |
| Weighted A* | 0,099 (< 0,001) | 0,231 (< 0,001) | 0,053 (< 0,001) | 2,337 (< 0,001) | 0,534 (< 0,001) | 0,228 (< 0,001) |
| Greedy Best-First | 0,856 (< 0,001) | 0,366 (< 0,001) | 0,201 (< 0,001) | 0,427 (< 0,001) | 0,235 (< 0,001) | 0,550 (< 0,001) |

Tukey dentro do terreno, algoritmos por representação — razão (p):

| Representação | Dijkstra / A* | Dijkstra / Weighted A* | Dijkstra / Greedy Best-First | A* / Weighted A* | A* / Greedy Best-First | Weighted A* / Greedy Best-First |
|---|---|---|---|---|---|---|
| Grade 2.5D | 1,010 (0,923) | 19,068 (< 0,001) | 177,989 (< 0,001) | 18,879 (< 0,001) | 176,226 (< 0,001) | 9,335 (< 0,001) |
| Grade voxelizada | 0,814 (< 0,001) | 1,227 (< 0,001) | 99,229 (< 0,001) | 1,507 (< 0,001) | 121,883 (< 0,001) | 80,869 (< 0,001) |
| Grafo de vértices | 1,050 (0,010) | 12,279 (< 0,001) | 181,474 (< 0,001) | 11,689 (< 0,001) | 172,756 (< 0,001) | 14,779 (< 0,001) |
| Grafo dual | 0,976 (0,434) | 4,688 (< 0,001) | 166,963 (< 0,001) | 4,802 (< 0,001) | 170,994 (< 0,001) | 35,611 (< 0,001) |

Tukey entre níveis (grupos independentes, n = 50 por nível): para cada algoritmo × representação, razão e p do par extremo 500 / 200 e número de pares significativos entre os 6 possíveis:

| Algoritmo | Grade 2.5D | Grade voxelizada | Grafo de vértices | Grafo dual |
|---|---|---|---|---|
| Dijkstra | 0,819 (< 0,001); 6/6 | 0,848 (< 0,001); 6/6 | 0,475 (< 0,001); 6/6 | 0,494 (< 0,001); 6/6 |
| A* | 0,710 (< 0,001); 6/6 | 0,795 (< 0,001); 6/6 | 0,446 (< 0,001); 6/6 | 0,456 (< 0,001); 6/6 |
| Weighted A* | 0,065 (< 0,001); 6/6 | 0,484 (< 0,001); 6/6 | 0,094 (< 0,001); 6/6 | 0,076 (< 0,001); 6/6 |
| Greedy Best-First | 0,825 (< 0,001); 4/6 | 0,892 (< 0,001); 3/6 | 0,476 (< 0,001); 6/6 | 0,452 (< 0,001); 6/6 |

### Vértices expandidos

Médias geométricas marginais:

- Nível: 200 = 88368; 275 = 63768; 350 = 50966; 500 = 38539
- Algoritmo: Dijkstra = 490377; A* = 359044; Weighted A* = 51794; Greedy Best-First = 1214
- Representação: Grade 2.5D = 20463; Grade voxelizada = 52689; Grafo de vértices = 61488; Grafo dual = 166960

Média geométrica por algoritmo × representação (todos os níveis):

| Algoritmo | Grade 2.5D | Grade voxelizada | Grafo de vértices | Grafo dual |
|---|---|---|---|---|
| Dijkstra | 249996 | 249999 | 681093 | 1358443 |
| A* | 145128 | 242724 | 448756 | 1051275 |
| Weighted A* | 8348 | 119102 | 36169 | 200114 |
| Greedy Best-First | 579 | 1066 | 1293 | 2719 |

ANOVA split-plot:

| Efeito | F | gl (GG) | ε GG | p (GG) | η² parcial |
|---|---|---|---|---|---|
| N | 344,06 | 3; 196 | — | < 0,001 | 0,840 |
| Alg | 40812,30 | 1,37; 269,0 | 0,458 | < 0,001 | 0,995 |
| N × Alg | 166,40 | 4,12; 269,0 | 0,458 | < 0,001 | 0,718 |
| Rep | 17395,19 | 1,94; 380,0 | 0,646 | < 0,001 | 0,989 |
| N × Rep | 178,09 | 5,82; 380,0 | 0,646 | < 0,001 | 0,732 |
| Alg × Rep | 2330,12 | 2,53; 495,1 | 0,281 | < 0,001 | 0,922 |
| N × Alg × Rep | 56,38 | 7,58; 495,1 | 0,281 | < 0,001 | 0,463 |

Shapiro-Wilk dos resíduos: entre terrenos (n = 200): W = 0,996, p = 0,921; dentro do terreno (n = 3200): W = 0,898, p < 0,001

Tukey dentro do terreno, representações por algoritmo — razão (p):

| Algoritmo | Grade 2.5D / Grade voxelizada | Grade 2.5D / Grafo de vértices | Grade 2.5D / Grafo dual | Grade voxelizada / Grafo de vértices | Grade voxelizada / Grafo dual | Grafo de vértices / Grafo dual |
|---|---|---|---|---|---|---|
| Dijkstra | 1,000 (1,000) | 0,367 (< 0,001) | 0,184 (< 0,001) | 0,367 (< 0,001) | 0,184 (< 0,001) | 0,501 (< 0,001) |
| A* | 0,598 (< 0,001) | 0,323 (< 0,001) | 0,138 (< 0,001) | 0,541 (< 0,001) | 0,231 (< 0,001) | 0,427 (< 0,001) |
| Weighted A* | 0,070 (< 0,001) | 0,231 (< 0,001) | 0,042 (< 0,001) | 3,293 (< 0,001) | 0,595 (< 0,001) | 0,181 (< 0,001) |
| Greedy Best-First | 0,543 (< 0,001) | 0,448 (< 0,001) | 0,213 (< 0,001) | 0,825 (< 0,001) | 0,392 (< 0,001) | 0,476 (< 0,001) |

Tukey dentro do terreno, algoritmos por representação — razão (p):

| Representação | Dijkstra / A* | Dijkstra / Weighted A* | Dijkstra / Greedy Best-First | A* / Weighted A* | A* / Greedy Best-First | Weighted A* / Greedy Best-First |
|---|---|---|---|---|---|---|
| Grade 2.5D | 1,723 (< 0,001) | 29,946 (< 0,001) | 431,896 (< 0,001) | 17,384 (< 0,001) | 250,725 (< 0,001) | 14,423 (< 0,001) |
| Grade voxelizada | 1,030 (0,234) | 2,099 (< 0,001) | 234,446 (< 0,001) | 2,038 (< 0,001) | 227,623 (< 0,001) | 111,692 (< 0,001) |
| Grafo de vértices | 1,518 (< 0,001) | 18,831 (< 0,001) | 526,737 (< 0,001) | 12,407 (< 0,001) | 347,054 (< 0,001) | 27,972 (< 0,001) |
| Grafo dual | 1,292 (< 0,001) | 6,788 (< 0,001) | 499,599 (< 0,001) | 5,253 (< 0,001) | 386,631 (< 0,001) | 73,596 (< 0,001) |

Tukey entre níveis (grupos independentes, n = 50 por nível): para cada algoritmo × representação, razão e p do par extremo 500 / 200 e número de pares significativos entre os 6 possíveis:

| Algoritmo | Grade 2.5D | Grade voxelizada | Grafo de vértices | Grafo dual |
|---|---|---|---|---|
| Dijkstra | 1,000 (< 0,001); 2/6 | 1,000 (0,003); 3/6 | 0,569 (< 0,001); 6/6 | 0,568 (< 0,001); 6/6 |
| A* | 0,644 (< 0,001); 6/6 | 1,000 (1,000); 0/6 | 0,505 (< 0,001); 6/6 | 0,494 (< 0,001); 6/6 |
| Weighted A* | 0,061 (< 0,001); 6/6 | 0,474 (< 0,001); 6/6 | 0,104 (< 0,001); 6/6 | 0,092 (< 0,001); 6/6 |
| Greedy Best-First | 0,660 (< 0,001); 4/6 | 0,819 (< 0,001); 3/6 | 0,454 (< 0,001); 6/6 | 0,489 (< 0,001); 6/6 |

### Pico da lista aberta

Médias geométricas marginais:

- Nível: 200 = 3025; 275 = 2688; 350 = 2472; 500 = 2284
- Algoritmo: Dijkstra = 1463; A* = 3094; Weighted A* = 4754; Greedy Best-First = 2134
- Representação: Grade 2.5D = 2829; Grade voxelizada = 1607; Grafo de vértices = 3583; Grafo dual = 2818

Média geométrica por algoritmo × representação (todos os níveis):

| Algoritmo | Grade 2.5D | Grade voxelizada | Grafo de vértices | Grafo dual |
|---|---|---|---|---|
| Dijkstra | 1757 | 782 | 2025 | 1644 |
| A* | 4679 | 1396 | 4627 | 3031 |
| Weighted A* | 3827 | 3876 | 6265 | 5497 |
| Greedy Best-First | 2035 | 1576 | 2807 | 2303 |

ANOVA split-plot:

| Efeito | F | gl (GG) | ε GG | p (GG) | η² parcial |
|---|---|---|---|---|---|
| N | 940,57 | 3; 196 | — | < 0,001 | 0,935 |
| Alg | 20493,12 | 1,78; 348,5 | 0,593 | < 0,001 | 0,991 |
| N × Alg | 31,03 | 5,33; 348,5 | 0,593 | < 0,001 | 0,322 |
| Rep | 18279,91 | 2,32; 454,3 | 0,773 | < 0,001 | 0,989 |
| N × Rep | 218,75 | 6,95; 454,3 | 0,773 | < 0,001 | 0,770 |
| Alg × Rep | 2134,16 | 3,19; 625,2 | 0,354 | < 0,001 | 0,916 |
| N × Alg × Rep | 253,19 | 9,57; 625,2 | 0,354 | < 0,001 | 0,795 |

Shapiro-Wilk dos resíduos: entre terrenos (n = 200): W = 0,994, p = 0,585; dentro do terreno (n = 3200): W = 0,925, p < 0,001

Tukey dentro do terreno, representações por algoritmo — razão (p):

| Algoritmo | Grade 2.5D / Grade voxelizada | Grade 2.5D / Grafo de vértices | Grade 2.5D / Grafo dual | Grade voxelizada / Grafo de vértices | Grade voxelizada / Grafo dual | Grafo de vértices / Grafo dual |
|---|---|---|---|---|---|---|
| Dijkstra | 2,247 (< 0,001) | 0,868 (< 0,001) | 1,069 (< 0,001) | 0,386 (< 0,001) | 0,476 (< 0,001) | 1,232 (< 0,001) |
| A* | 3,352 (< 0,001) | 1,011 (0,401) | 1,544 (< 0,001) | 0,302 (< 0,001) | 0,460 (< 0,001) | 1,527 (< 0,001) |
| Weighted A* | 0,987 (0,261) | 0,611 (< 0,001) | 0,696 (< 0,001) | 0,619 (< 0,001) | 0,705 (< 0,001) | 1,140 (< 0,001) |
| Greedy Best-First | 1,291 (< 0,001) | 0,725 (< 0,001) | 0,884 (< 0,001) | 0,562 (< 0,001) | 0,685 (< 0,001) | 1,219 (< 0,001) |

Tukey dentro do terreno, algoritmos por representação — razão (p):

| Representação | Dijkstra / A* | Dijkstra / Weighted A* | Dijkstra / Greedy Best-First | A* / Weighted A* | A* / Greedy Best-First | Weighted A* / Greedy Best-First |
|---|---|---|---|---|---|---|
| Grade 2.5D | 0,376 (< 0,001) | 0,459 (< 0,001) | 0,864 (< 0,001) | 1,223 (< 0,001) | 2,300 (< 0,001) | 1,881 (< 0,001) |
| Grade voxelizada | 0,560 (< 0,001) | 0,202 (< 0,001) | 0,496 (< 0,001) | 0,360 (< 0,001) | 0,886 (< 0,001) | 2,459 (< 0,001) |
| Grafo de vértices | 0,438 (< 0,001) | 0,323 (< 0,001) | 0,722 (< 0,001) | 0,739 (< 0,001) | 1,649 (< 0,001) | 2,232 (< 0,001) |
| Grafo dual | 0,542 (< 0,001) | 0,299 (< 0,001) | 0,714 (< 0,001) | 0,551 (< 0,001) | 1,316 (< 0,001) | 2,387 (< 0,001) |

Tukey entre níveis (grupos independentes, n = 50 por nível): para cada algoritmo × representação, razão e p do par extremo 500 / 200 e número de pares significativos entre os 6 possíveis:

| Algoritmo | Grade 2.5D | Grade voxelizada | Grafo de vértices | Grafo dual |
|---|---|---|---|---|
| Dijkstra | 0,734 (< 0,001); 6/6 | 0,672 (< 0,001); 6/6 | 0,631 (< 0,001); 6/6 | 0,655 (< 0,001); 6/6 |
| A* | 1,213 (< 0,001); 4/6 | 0,709 (< 0,001); 6/6 | 0,712 (< 0,001); 6/6 | 0,706 (< 0,001); 6/6 |
| Weighted A* | 0,429 (< 0,001); 6/6 | 1,911 (< 0,001); 6/6 | 0,524 (< 0,001); 6/6 | 0,660 (< 0,001); 6/6 |
| Greedy Best-First | 0,945 (< 0,001); 5/6 | 0,901 (< 0,001); 6/6 | 0,706 (< 0,001); 6/6 | 0,738 (< 0,001); 6/6 |

### Custo relativo

Apenas Weighted A* e Greedy Best-First.

Médias geométricas marginais:

- Nível: 200 = 1,1561; 275 = 1,1129; 350 = 1,0898; 500 = 1,0648
- Algoritmo: Weighted A* = 1,0360; Greedy Best-First = 1,1795
- Representação: Grade 2.5D = 1,0873; Grade voxelizada = 1,0946; Grafo de vértices = 1,1335; Grafo dual = 1,1068

Média geométrica por algoritmo × representação (todos os níveis):

| Algoritmo | Grade 2.5D | Grade voxelizada | Grafo de vértices | Grafo dual |
|---|---|---|---|---|
| Weighted A* | 1,0447 | 1,0083 | 1,0569 | 1,0347 |
| Greedy Best-First | 1,1317 | 1,1882 | 1,2157 | 1,1839 |

ANOVA split-plot:

| Efeito | F | gl (GG) | ε GG | p (GG) | η² parcial |
|---|---|---|---|---|---|
| N | 626,39 | 3; 196 | — | < 0,001 | 0,906 |
| Alg | 9437,10 | 1,00; 196,0 | 1,000 | < 0,001 | 0,980 |
| N × Alg | 778,08 | 3,00; 196,0 | 1,000 | < 0,001 | 0,923 |
| Rep | 407,60 | 2,58; 506,4 | 0,861 | < 0,001 | 0,675 |
| N × Rep | 69,48 | 7,75; 506,4 | 0,861 | < 0,001 | 0,515 |
| Alg × Rep | 449,56 | 2,60; 509,7 | 0,867 | < 0,001 | 0,696 |
| N × Alg × Rep | 22,84 | 7,80; 509,7 | 0,867 | < 0,001 | 0,259 |

Shapiro-Wilk dos resíduos: entre terrenos (n = 200): W = 0,923, p < 0,001; dentro do terreno (n = 1600): W = 0,952, p < 0,001

Tukey dentro do terreno, representações por algoritmo — razão (p):

| Algoritmo | Grade 2.5D / Grade voxelizada | Grade 2.5D / Grafo de vértices | Grade 2.5D / Grafo dual | Grade voxelizada / Grafo de vértices | Grade voxelizada / Grafo dual | Grafo de vértices / Grafo dual |
|---|---|---|---|---|---|---|
| Weighted A* | 1,036 (< 0,001) | 0,988 (< 0,001) | 1,010 (< 0,001) | 0,954 (< 0,001) | 0,974 (< 0,001) | 1,021 (< 0,001) |
| Greedy Best-First | 0,952 (< 0,001) | 0,931 (< 0,001) | 0,956 (< 0,001) | 0,977 (< 0,001) | 1,004 (0,134) | 1,027 (< 0,001) |

Tukey dentro do terreno, algoritmos por representação — razão (p):

| Representação | Weighted A* / Greedy Best-First |
|---|---|
| Grade 2.5D | 0,923 (< 0,001) |
| Grade voxelizada | 0,849 (< 0,001) |
| Grafo de vértices | 0,869 (< 0,001) |
| Grafo dual | 0,874 (< 0,001) |

Tukey entre níveis (grupos independentes, n = 50 por nível): para cada algoritmo × representação, razão e p do par extremo 500 / 200 e número de pares significativos entre os 6 possíveis:

| Algoritmo | Grade 2.5D | Grade voxelizada | Grafo de vértices | Grafo dual |
|---|---|---|---|---|
| Weighted A* | 0,977 (< 0,001); 3/6 | 1,006 (< 0,001); 3/6 | 1,011 (< 0,001); 3/6 | 1,024 (< 0,001); 6/6 |
| Greedy Best-First | 0,792 (< 0,001); 6/6 | 0,841 (< 0,001); 6/6 | 0,852 (< 0,001); 6/6 | 0,897 (< 0,001); 6/6 |
