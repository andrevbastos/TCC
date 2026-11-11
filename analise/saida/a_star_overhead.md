# A* × Dijkstra: razões e parcela da inicialização

Gerado por `analise.py`. Só números, sem interpretação.

- Razões: média geométrica entre os 200 terrenos de cada teste (4 níveis × 50), da razão A*/Dijkstra no mesmo terreno; cada terreno usa a média dos ln das duas consultas.
- Parcela da inicialização: `tempo_inicializacao / tempo_busca`, linha a linha dos CSVs brutos. "MG" = média geométrica entre terrenos (média dos ln das duas consultas por terreno); também a mediana, o mínimo e o máximo das linhas.
- Medição: `tempo_inicializacao` é medido uma vez por terreno e representação, à parte das buscas (`measureSearchStateInit`, em `include/core/statistics.hpp`); o mesmo valor aparece nas linhas de todos os algoritmos do terreno. A última coluna conta as linhas com razão > 1.

| Teste | Representação | Tempo A*/Dij | Expandidos A*/Dij | Init/busca Dij (MG; mediana; mín–máx) | Init/busca A* (MG; mediana; mín–máx) | Linhas > 1 (Dij; A*) |
|---|---|---|---|---|---|---|
| Escala | Grade 2.5D | 1,036 | 0,653 | 0,0029; 0,0028; 0,0025–0,0139 | 0,0028; 0,0027; 0,0019–0,0169 | 0; 0 |
| Escala | Grade voxelizada | 1,260 | 0,968 | 0,0046; 0,0046; 0,0040–0,0051 | 0,0036; 0,0036; 0,0033–0,0044 | 0; 0 |
| Escala | Grafo de vértices | 0,966 | 0,682 | 0,0030; 0,0030; 0,0027–0,0037 | 0,0031; 0,0031; 0,0021–0,0046 | 0; 0 |
| Escala | Grafo dual | 1,049 | 0,807 | 0,0037; 0,0037; 0,0033–0,0075 | 0,0035; 0,0035; 0,0028–0,0092 | 0; 0 |
| Lacunaridade | Grade 2.5D | 0,990 | 0,601 | 0,0029; 0,0028; 0,0023–0,0157 | 0,0029; 0,0027; 0,0019–0,0283 | 0; 0 |
| Lacunaridade | Grade voxelizada | 1,231 | 0,965 | 0,0045; 0,0045; 0,0040–0,0053 | 0,0037; 0,0037; 0,0031–0,0048 | 0; 0 |
| Lacunaridade | Grafo de vértices | 0,933 | 0,655 | 0,0033; 0,0033; 0,0027–0,0038 | 0,0035; 0,0035; 0,0022–0,0070 | 0; 0 |
| Lacunaridade | Grafo dual | 1,019 | 0,777 | 0,0039; 0,0039; 0,0033–0,0043 | 0,0038; 0,0038; 0,0027–0,0071 | 0; 0 |
| Persistência | Grade 2.5D | 1,010 | 0,646 | 0,0028; 0,0027; 0,0022–0,0157 | 0,0028; 0,0026; 0,0018–0,0227 | 0; 0 |
| Persistência | Grade voxelizada | 1,218 | 0,971 | 0,0043; 0,0044; 0,0036–0,0054 | 0,0036; 0,0036; 0,0029–0,0051 | 0; 0 |
| Persistência | Grafo de vértices | 0,958 | 0,679 | 0,0031; 0,0030; 0,0026–0,0039 | 0,0032; 0,0032; 0,0021–0,0062 | 0; 0 |
| Persistência | Grafo dual | 1,036 | 0,794 | 0,0037; 0,0038; 0,0030–0,0044 | 0,0036; 0,0036; 0,0026–0,0058 | 0; 0 |
| Comprimento de onda | Grade 2.5D | 0,990 | 0,581 | 0,0029; 0,0028; 0,0023–0,0133 | 0,0029; 0,0028; 0,0019–0,0160 | 0; 0 |
| Comprimento de onda | Grade voxelizada | 1,228 | 0,971 | 0,0046; 0,0046; 0,0041–0,0053 | 0,0037; 0,0037; 0,0031–0,0047 | 0; 0 |
| Comprimento de onda | Grafo de vértices | 0,952 | 0,659 | 0,0032; 0,0032; 0,0026–0,0040 | 0,0034; 0,0034; 0,0022–0,0056 | 0; 0 |
| Comprimento de onda | Grafo dual | 1,024 | 0,774 | 0,0039; 0,0039; 0,0033–0,0045 | 0,0038; 0,0038; 0,0029–0,0056 | 0; 0 |
