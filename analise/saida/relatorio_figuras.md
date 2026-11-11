# Conferência das figuras

Ponto plotado = média geométrica da célula teste × nível × algoritmo × representação (exp da média dos ln por terreno, n = 50); barras = IC de 95% na escala ln, exp(m ± t(0,975; 49)·s/√50).

## (a) Pontos × `saida/dados_por_terreno_ln.csv`

- Pontos conferidos: 640 (n = 50 terrenos em cada); tolerância relativa 1e-12.
- Divergências: 0

## (b) Pontos × `resumo_resultados.md`

O resumo não contém a média geométrica de cada célula por nível. A conferência usa as duas agregações que ele contém, recalculadas a partir dos pontos plotados (exp da média dos ln dos pontos), com tolerância de meia unidade da última casa exibida:

- Algoritmo × representação (4 níveis agregados): 160 valores conferidos (640 pontos envolvidos).
- Nível (algoritmos × representações agregados): 48 valores conferidos.
- Divergências: 0

## Pontos por figura

| Figura | Pontos |
|---|---|
| fig_frequency_custo_relativo.png | 32 |
| fig_frequency_expandidos.png | 64 |
| fig_frequency_tempo.png | 64 |
| fig_lac_custo_relativo.png | 32 |
| fig_lac_expandidos.png | 64 |
| fig_lac_tempo.png | 64 |
| fig_pers_custo_relativo.png | 32 |
| fig_pers_expandidos.png | 64 |
| fig_pers_tempo.png | 64 |
| fig_scale_custo_relativo.png | 32 |
| fig_scale_expandidos.png | 64 |
| fig_scale_tempo.png | 64 |

Resultado: sem divergências.
