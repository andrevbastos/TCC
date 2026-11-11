# Revisão crítica do TCC — texto × código × referências

Documento revisado: `typ/tcc/tcc_refac.typ` (1978 linhas, arquivo único; não importa outros `.typ`).
Referências: `typ/tcc/referencias.bib` (não existe `./referencias.bib` na raiz; há outro em `typ/pre-project/`, não usado pelo documento).
Dados: `results/campanha_20261109_172346/` (80 CSVs, 25 600 linhas) e `analise/saida/`.
Código da coleta: commit `c802ee3` (registrado no manifesto, `git_sujo = 0`); desde então só mudou a posição da câmera em `src/main.cpp:474-475`.

Numeração de capítulos citada abaixo é a do PDF compilado (Resultados = capítulo 4).

## Resumo executivo

- **Os números do texto batem com os dados.** Recalculei, a partir dos CSVs brutos e com implementação própria, as 15 tabelas (médias geométricas, razões, 112 linhas de ANOVA, Tukey): só 10 células divergem, todas na última casa decimal.
- **Os problemas de fundo são de interpretação, não de aritmética.** O Dijkstra expande 100% do grafo em todas as consultas, o tamanho dos grafos de malha varia até 3× com o parâmetro de terreno e não é reportado, e cerca de metade do tempo da Greedy Best-First é inicialização de vetores.
- **A descrição dos métodos corresponde ao código** (heurística, pesos, vizinhanças, desempates, medição, script de coleta), com poucas exceções pontuais.
- **Referências:** todas as 26 chaves citadas existem no `.bib`. Duas citações da Introdução são frágeis (Kapi 2022 é 2D; a dissertação de Johansson não foi localizada), e os métodos estatísticos usados não têm referência.
- **O documento está incompleto:** seção de trabalhos relacionados vazia, 7 figuras sem imagem, sem resumo/abstract, e o desenvolvimento está dentro do capítulo de Fundamentação.
- **Compilação:** `typst 0.15.1` compila sem erros nem avisos (76 páginas).

| Severidade | Qtde |
|---|---|
| Crítica | 2 |
| Alta | 8 |
| Média | 17 |
| Baixa | 25 |

---

## (a) Texto × código

### A1 — Dijkstra expande o grafo inteiro; o texto diz que a causa "não foi investigada" · **Alta**
- **Local:** `tcc_refac.typ:1500` (4.3) e `:1590` (5.3).
- **Texto:** o número de vértices expandidos do Dijkstra nas grades "só muda com a escala" (razão 1,00); "A causa dessa constância não foi investigada".
- **Código/dados:** as consultas são sempre as duas diagonais, de canto a canto (`include/core/statistics.hpp:225-240`). Nos CSVs, `Nós Expandidos / Nós do Grafo` do Dijkstra tem mediana 1,0000 e mínimo 0,9936 nas quatro representações. Nas grades, |V| = dimensão² (250 000 em 500), constante entre níveis de lacunaridade, persistência e comprimento de onda.
- **Sugestão:** dizer explicitamente que, com destino no canto oposto, o Dijkstra é exaustivo e que "vértices expandidos" dele equivale a |V|. Isso também limita a generalidade da comparação Dijkstra × A* (é o pior caso do Dijkstra) e deve entrar nas ameaças à validade.

### A2 — Tamanho dos grafos não é reportado e se confunde com o efeito do terreno · **Alta**
- **Local:** `:934` ("quantidades distintas de vértices e arestas"), `:1330`, `:1498`, `:1578`, `:1586-1590`.
- **Texto:** atribui as variações de tempo e expansões às "características do terreno" e à representação; não apresenta |V| nem |A| em nenhuma tabela.
- **Dados** (medianas das colunas `Nós do Grafo` / `Arestas do Grafo`, dimensão 500):

  | Representação | Vértices | Arestas |
  |---|---|---|
  | Grade 2.5D | 250 000 | 997 002 |
  | Grade voxelizada | 250 000 | 499 000 |
  | Grafo de vértices | 514 876 a 1 617 084 | 1,54 M a 4,84 M |
  | Grafo dual | 1 026 670 a 3 226 796 | 1,54 M a 4,84 M |

  Na persistência, o grafo dual vai de 1,08 M (0,3) a 3,23 M vértices (0,7); na lacunaridade, de 1,14 M a 1,95 M; no comprimento de onda, de 1,81 M (200) a 1,03 M (500). A razão 2,95 do Dijkstra em vértice/dual na persistência (`:1875`) é exatamente o crescimento do grafo.
- **Sugestão:** incluir uma tabela de |V| e |A| por representação e nível; reportar também a fração do grafo expandida; separar na discussão "o terreno muda o tamanho da malha" de "o terreno muda o comportamento da busca".

### A3 — Tempo da Greedy Best-First é dominado pela inicialização dos vetores · **Alta**
- **Local:** `:1312` (ameaças), `:1326`, `:1574`, `:1594`, `:1602`, tabela `:1867-1882`.
- **Texto:** a parcela da inicialização "é medida separadamente [...], o que permite estimar a sua parcela", mas a parcela nunca é apresentada.
- **Código/dados:** cada busca aloca `gScore`, `cameFrom` e `closed` com |V| posições (`include/core/search.hpp:169-171`); `measureSearchStateInit` mede isso à parte (`include/core/terrain_metrics.hpp:167-179`). `tempo_inicializacao / tempo_busca`, mediana por linha:

  | Algoritmo | 2.5D | Voxel | Vértices | Dual |
  |---|---|---|---|---|
  | Dijkstra | 0,3% | 0,5% | 0,3% | 0,4% |
  | A\* | 0,3% | 0,4% | 0,3% | 0,4% |
  | Weighted A\* | 3,4% | 0,5% | 2,7% | 1,0% |
  | Greedy Best-First | 52% | 46% | 61% | 67% |

  É uma estimativa: a inicialização é medida uma vez por grafo, isolada, e em algumas linhas supera o próprio tempo de busca (máx. 2,77). `analise/analise.py:939-987` só calcula essa parcela para Dijkstra e A\*.
- **Consequência:** as razões de tempo da GBFS na escala (2,26 a 2,52) refletem em boa parte o crescimento de |V| (2,56), e a ordem das representações para a GBFS segue o tamanho do grafo.
- **Sugestão:** reportar a parcela para os quatro algoritmos e qualificar as afirmações sobre o tempo da GBFS.

### A4 — Custo relativo da GBFS vem de uma variante modificada, sem ressalva nos resultados · **Média**
- **Local:** `:739-758` (pseudocódigo clássico), `:1143` (explica a diferença), `:1332`, `:1574`, `:1602`.
- **Texto:** em 2.11.1 explica que a implementação atualiza pai e custo quando acha um g menor e que "o caminho retornado pode ter custo menor que o da GBFS clássica". Resultados e Conclusão afirmam "18% a 28% mais longos" sem a ressalva.
- **Código:** `include/core/search.hpp:201-209`.
- **Sugestão:** repetir a ressalva onde o número é usado, ou medir também a variante clássica.

### A5 — Marching Cubes: campo binário e vértices no ponto médio não são descritos · **Média**
- **Local:** `:926-930`, `:1195`.
- **Texto:** descreve o algoritmo genérico (comparar os oito cantos com um limiar).
- **Código:** o campo é ocupação binária (`include/core/util.hpp:335-337`) e cada vértice fica no ponto médio da aresta da célula, sem interpolação (`util.hpp:386`; `operator%` em `build/_deps/ifcg-src/include/ifcg/common/vertex.hpp:105-113`). A malha resultante tem degraus e paredes verticais (comentário em `terrain_metrics.hpp:121-123`), o que determina pesos e número de triângulos dos grafos de vértices e dual.
- **Sugestão:** acrescentar uma frase sobre o campo binário, o ponto médio e a forma da malha.

### A6 — "Escala" tratada como parâmetro do gerador e, depois, negada · **Média**
- **Local:** `:357`, `:366` × `:1211`.
- **Texto:** Contribuições e Objetivos dizem que o gerador é "parametrizado por escala, lacunaridade, persistência e comprimento de onda"; 2.14.1 diz "A escala, portanto, não é um parâmetro do ruído".
- **Código:** `NoiseConfig` não tem escala (`include/core/noise_gen.hpp:20-30`); o teste varia dimensão, `wave = dimensão/2` e altura (`statistics.hpp:245-261`, `:297-300`).
- **Sugestão:** uniformizar (por exemplo, "resolução" ou "dimensão") nos objetivos.

### A7 — Dependências próprias sem versão fixada · **Média**
- **Local:** `:356` ("Metodologia experimental reprodutível"), `:1259`.
- **Texto:** IFCG e graph_project são "repositórios públicos do autor", sem versão.
- **Código:** `cmake/Dependencies.cmake:15-25` usa `GIT_TAG main` para os dois; o manifesto só registra o commit do `tcc` (`coleta_completa.sh:153`). No build local constam `ifcg 6dc69ea` e `graph 98cdadf`, mas nada garante que foram os da campanha.
- **Sugestão:** fixar e citar os commits (os algoritmos de busca dependem de `common::lwGraph`).

### A8 — Versões do Python "listadas na seção de Ambiente" não estão lá · **Média**
- **Local:** `:1308` × `:1255-1261`.
- **Dados:** `analise/saida/relatorio_verificacoes.md:5` e `analise/requirements.txt`: Python 3.14.0, numpy 2.5.4, pandas 3.1.1, scipy 1.18.1, matplotlib 3.11.2, statsmodels 0.15.0.
- **Sugestão:** incluir na seção 3.2.

### A9 — Afirmação de localidade de memória do `lwGraph` · **Média**
- **Local:** `:1116`.
- **Texto:** a disposição "mantém os dados em blocos contíguos, o que favorece a localidade de memória".
- **Código:** só os vértices são contíguos; a adjacência é `std::vector<std::vector<lwEdge>>` (`build/_deps/graph_project-src/include/graph/common/lw_graph.hpp:54`), isto é, uma alocação separada por vértice. Nenhuma medição sustenta o ganho.
- **Sugestão:** restringir a afirmação ao que a estrutura faz, ou marcar como expectativa não medida.

### A10 — Tukey dentro do terreno com erro agrupado sob forte violação de esfericidade · **Média**
- **Local:** `:1306`; tabela `:1835-1850`.
- **Texto e código coincidem:** erro da interação algoritmo × representação × terreno (`analise/analise.py:657-670`).
- **Problema metodológico:** o ε de Greenhouse-Geisser chega a 0,22 (`analise/saida/anova_split_plot.csv`, coluna `epsilon_GG`); o texto corrige o F por isso, mas o Tukey usa um único quadrado médio agrupado, que pressupõe esfericidade. Os p de comparações limítrofes (por exemplo 0,088; 0,072; 0,014) ficam pouco confiáveis.
- **Sugestão:** usar erro por par (diferenças pareadas com correção de multiplicidade) ou registrar a limitação nas ameaças.

### A11 — Consistência da heurística vale a menos de arredondamento · **Baixa**
- **Local:** `:1306`.
- **Código:** pesos calculados em `float` (`util.hpp:423-426`, `:486-489`, `:540-543`, `:571-576`) e heurística em `double` (`statistics.hpp:286-291`).
- **Dados:** custo do A\* igual ao do Dijkstra em 6400/6400 linhas (`relatorio_verificacoes.md`), então não há efeito observado.
- **Sugestão:** citar essa verificação empírica no texto.

### A12 — GLAD é carregada por `Window`, não por `Context` · **Baixa**
- **Local:** `:1051`.
- **Código:** `gladLoadGLLoader` em `build/_deps/ifcg-src/src/ifcg/components/window.cpp:46`; `Context` só chama `glfwInit`, `glfwPollEvents`, `glfwGetTime` e `glfwTerminate` (`context.cpp:5-26`).

### A13 — Limite de quadros e modo de laço · **Baixa**
- **Local:** `:1057`.
- **Texto:** "a thread aguarda o tempo restante do quadro".
- **Código:** `startTime` é lido depois da renderização, imediatamente antes de `endTime` (`ifcg.cpp:157-170`), então a espera é sempre o quadro inteiro. `LoopConfig.mode` (`main.cpp:551-553` usa `Concurrent`) nunca é lido, e `Engine::loopP` (`ifcg.cpp:175`) não tem chamadores.

### A14 — Mediana das repetições exclui a primeira medição · **Baixa**
- **Local:** `:1151`.
- **Código:** a medição inicial (< 5 ms) só decide se há repetição; a mediana é das repetições seguintes (`statistics.hpp:388-415`, `terrain_metrics.hpp:200-221`). Observado: k entre 1 e 9; 88% das linhas da GBFS e 8% da Weighted A\* têm k > 1.

### A15 — Subcomando `heuristics` é temporário e sem figura correspondente · **Baixa**
- **Local:** `:1245`.
- **Código:** marcado como "TEMPORÁRIO: imagens do documento" (`src/main.cpp:98`, `:141`, `:558-559`); `typ/tcc/images/heuristicas.png` existe e não é usada.

### A16 — Lista de dependências · **Baixa**
- **Local:** `:1259`.
- **Código:** `nlohmann/json` é declarada (`cmake/Dependencies.cmake:8-12`), mas não é incluída por `src/` nem `include/core/`. Não são listadas GLFW e GLAD (usadas pelo IFCG), `stb_image` (`include/stb_image*.h`) nem as tabelas do Transvoxel (`include/transvoxel/transvoxel.hpp`, © Eric Lengyel).

### A17 — Detalhes de vocabulário técnico · **Baixa**
- `:1114` "especialização `undirected::lwGraph<T>`": é classe derivada (`undirected/lw_graph.hpp:7`), não especialização de template; a base é abstrata (`lw_graph.hpp:39`).
- `:1086` "mantendo-se pelo menos uma": se `hardware_concurrency()` retornar 0, não há trabalhadoras (`task.hpp:27-28`).
- `:1229` máximos locais e declividade só no interior do mapa (`terrain_metrics.hpp:80-81`).

---

## (b) Números e resultados divergentes

Conferência feita com script próprio (não reutiliza `analise.py`): `/tmp/claude-1000/-home-andre-projects-tcc/77cbde49-8d63-4ac4-8121-1d4819af87fb/scratchpad/verifica.py`.

### B1 — Argumento "A\* expande menos e não é mais rápido" apoia-se num caso em que ele não expande menos · **Alta**
- **Local:** `:1326`, `:1572`.
- **Texto:** "O A\* expande entre 23% e 27% menos vértices [...] mas essa economia não aparece no tempo: [...] na grade voxelizada o Dijkstra é mais rápido".
- **Dados:** 23% a 27% é a média geométrica marginal entre representações (confere com `:1366-1367`). Por representação (`analise/saida/a_star_overhead.md`; `:1836-1848`):

  | | 2.5D | Voxel | Vértices | Dual |
  |---|---|---|---|---|
  | Expandidos A\*/Dijkstra | 0,58–0,65 | 0,97 (p ≥ 0,10) | 0,66–0,68 | 0,77–0,81 |
  | Tempo A\*/Dijkstra | 0,99–1,04 | 1,22–1,26 | 0,93–0,97 | 1,02–1,05 |

  Na voxelizada o A\* praticamente não poda (3%, não significativo), então ser mais lento ali é o esperado. O contraste real está na 2.5D (35% a 42% menos expansões, mesmo tempo). No grafo de vértices o A\* é mais rápido, com p < 0,05 em três testes (`:1839`, `:1843`, `:1847`).
- **Sugestão:** reescrever o argumento por representação; "o A\* não oferece ganho de tempo" (`:1594`, `:1602`) não vale para o grafo de vértices.

### B2 — "A exceção é a Weighted A\*" está incompleta · **Média**
- **Local:** `:1522`.
- **Dados** (Tukey entre níveis, pico da lista aberta): o A\* na grade 2.5D também vai no sentido contrário — 0,85 na lacunaridade (p < 0,001) e 1,21 no comprimento de onda, onde o pico geral cai; na persistência fica em 0,97 (não significativo). A Weighted A\* na voxelizada sobe 1,91 no comprimento de onda e cai 0,62 na persistência. A própria tabela `:1872-1881` mostra isso.
- **Sugestão:** listar os casos ou trocar "a exceção" por "as exceções".

### B3 — Custo relativo × escala: interação significativa omitida · **Baixa**
- **Local:** `:1544`, `:1586`.
- **Texto:** "não varia significativamente com a escala (p = 0,059)".
- **Dados:** a interação nível × algoritmo é significativa (F = 2,92; p = 0,035; `:1665`); no Tukey, GBFS no dual sobe 1,021 (p = 0,006) e Weighted A\* na voxelizada 1,002 (p = 0,009). Efeito pequeno, mas o texto generaliza.

### B4 — Dez células com diferença na última casa · **Baixa**
Aparentam ser arredondamento duplo (de 3 casas para 2). Valor recalculado entre parênteses.

| Linha | Célula | Texto | Recalculado |
|---|---|---|---|
| `:1417` | Custo, grafo de vértices, comp. de onda | 1,133 | 1,134 (1,1335) |
| `:1536` | Pico, comp. de onda, razão 4/1 | 0,76 | 0,75 |
| `:1559` | Custo, persistência, nível 2 | 1,099 | 1,098 (1,0985) |
| `:1868` | Escala, A\*, expandidos (máx.) | 2,67 | 2,66 (2,6645) |
| `:1869` | Escala, WA\*, expandidos (mín.) | 2,62 | 2,63 (2,6251) |
| `:1874` | Lacunaridade, GBFS, expandidos (mín.) | 1,20 | 1,19 (1,1949) |
| `:1877` | Persistência, WA\*, pico (mín.) | 0,61 | 0,62 (0,6153) |
| `:1880` | Comp. de onda, A\*, tempo (máx.) | 0,80 | 0,79 (0,7945) |
| `:1881` | Comp. de onda, WA\*, tempo (mín.) | 0,07 | 0,06 (0,0646; o texto em `:1432` diz 0,065) |
| `:1882` | Comp. de onda, GBFS, pico (máx.) | 0,94 | 0,95 (0,9450) |

### Conferido sem divergência
- Tabelas `tab_comum_*` (`:1343-1418`) e `tab_nivel_*` (`:1443-1560`), exceto as três células acima.
- Apêndice A (`:1638-1813`): 112 linhas de F, graus de liberdade com Greenhouse-Geisser, p e η²p.
- Apêndice B (`:1835-1882`), exceto as sete células acima; sobrescritos corretos.
- Números em prosa: 2,81; 3,95; 2,26–3,68; 2,23; 1,80; 7,56–10,73; 1,20–2,42; 4,09; 39,93; 34,49; 2,44; 0,41; 0,065; p ≥ 0,529; 0,64; 2,35; 1,34–1,63; 0,97–0,99; "480 vezes" (478,5); 135,4 / 216,0 / 128,2 / 22,6 ms; faixas de η²p; "pico do A\* ≈ 2× o do Dijkstra" (2,01 a 2,12).
- Shapiro-Wilk: dentro do terreno p < 0,001 em todas as métricas; entre terrenos rejeita em 7 de 16.
- Desenho: 50 terrenos por nível, 5 execuções × 10, mesmas sementes nas quatro representações, 80 blocos sem *throttling* e sem novas tentativas, temperatura inicial ≤ 43 °C.
- Consistência interna: escala 500 e lacunaridade 2,0 têm a mesma configuração com sementes diferentes e dão valores quase iguais (46,1 × 46,2 ms; 69 781 × 70 756 expansões; pico 2 783 × 2 780; custo 1,125 × 1,125).
- As 12 figuras de resultado em `typ/tcc/images/` são idênticas, byte a byte, às de `analise/saida/figuras/`.

---

## (c) Referências

Todas as 26 chaves citadas no `.typ` existem no `.bib`. Verificação de conteúdo: só o que está marcado como "verificado na web"; o restante é **não verificado** (sem acesso aos PDFs).

### C1 — Kapi (2022) citado como estudo de terrenos 3D · **Alta**
- **Local:** `:344`.
- **Texto:** "é comumente evitada a comparação de múltiplas representações navegáveis de terrenos 3D, com foco em apenas uma abordagem [...] @johansson2024adapting @Kapi2022".
- **Fonte:** o artigo compara algoritmos em mapas de grade 2D (verificado na web: resumo do IJACSA; também o comentário do próprio `.bib`, `referencias.bib:18-21`).
- **Sugestão:** reformular a frase ou trocar a fonte por um trabalho de fato 3D.

### C2 — Johansson (2024): entrada incompleta e não localizada · **Alta**
- **Local:** `:344`, `:1021`; `referencias.bib:10-16`.
- **Problema:** autor "Johansson, E. and others", sem URL nem identificador do repositório. Uma busca pelo título exato não encontrou a dissertação na Linnaeus University. **Não verificado**: pode existir no DiVA e não estar indexada.
- **Sugestão:** confirmar no DiVA, completar autor, tipo, URL e data de acesso. É uma das duas únicas fontes de trabalhos relacionados.

### C3 — Jain (1991) citado como apoio a "um fator por vez" · **Média**
- **Local:** `:1253`.
- **Fonte:** nos slides do próprio autor para o capítulo 16, o desenho "simple design" (um fator por vez) é descrito como estatisticamente ineficiente, sujeito a conclusões erradas quando há interação, e não recomendado (verificado na web, nos slides; **não verificado** no texto do livro).
- **Agravante:** o próprio TCC encontra interações grandes.
- **Sugestão:** citar Jain pela definição e reconhecer a limitação, ou justificar a escolha.

### C4 — Métodos estatísticos usados sem fundamentação nem referência · **Média**
- **Local:** `:1000-1018` × `:1304-1308`, `:1322`.
- **Problema:** a seção 2.6 só cobre ANOVA de um fator e Tukey com grupos independentes, ambos apoiados em notas de aula (`jurandir`). Modelo split-plot, Greenhouse-Geisser, η² parcial, Shapiro-Wilk e média geométrica aparecem na Metodologia sem definição nem citação; "conforme @anova" (`:1304`) aponta para uma seção que não os descreve. Fisher-Yates e Park-Miller (`:1237`, `coleta_completa.sh:124-142`) também não têm referência.
- **Sugestão:** ampliar 2.6 e citar fontes primárias ou um livro-texto de planejamento de experimentos.

### C5 — Williams (2019) para `std::jthread` e `std::stop_token` · **Média**
- **Local:** `:1086`.
- **Problema:** são recursos do C++20; a 2ª edição do livro cobre até C++17. **Não verificado** no PDF.
- **Sugestão:** conferir; se não constar, citar a norma ou a documentação de referência.

### C6 — Curva cúbica × quíntica do Perlin sem fonte · **Baixa**
- **Local:** `:832`. A afirmação sobre "versões posteriores" não tem citação; a única fonte de Perlin no `.bib` é a de 1985. **Não verificado.**

### C7 — Sturtevant (2012) para definir a grade 2.5D · **Baixa**
- **Local:** `:938`. Pelo título e pelo comentário do `.bib` (`:244-246`), o artigo trata de benchmarks em grades 2D. **Não verificado** no PDF.

### C8 — Formulação `f = g + w·h` atribuída a Pohl (1970) · **Baixa**
- **Local:** `:616`, `:688`, `:1574`. **Não verificado**: conferir se a forma do artigo é essa ou uma equivalente.

### C9 — Fontes de baixa rastreabilidade · **Baixa**
- `zipped_perlin_noise` (vídeo, `:1159`) para a função de *hash* dos gradientes (`noise_gen.hpp:32-51`).
- `ladeira` e `jurandir` ("Material didático", sem título, URL ou data): `:1007`, `:1011`, `:1086`.

### C10 — Fonte dos pseudocódigos · **Baixa**
- **Local:** `:716`, `:755`. Weighted A\* e GBFS indicam "com base em Gomes e Hart et al."; o Weighted A\* vem de Pohl e a GBFS é citada no texto a Russell e Norvig.

### C11 — Higiene do `.bib` · **Baixa**
- **Nunca citadas (9):** `a_star_modification`, `a_star_multithreaded`, `breaking_sorting_barrier`, `gtest`, `imperial_library_solstheim`, `jps_3d`, `nash2007thetastar`, `nash2013anyangle`, `russel_norvig` (duplicata de `russell_norvig`, anotada no próprio arquivo, `:135-145`).
- **Campos:** `astar` sem DOI; `Kapi2022` sem páginas; `pathfinding_game_dev` com "and others"; `navigation_mesh` como `@mastersthesis` com `type = Bachelor Thesis`, `publisher` e "Politécnica"; `urlaccessdate` (`:469`) não é campo padrão.
- **Formatação:** autores ora "Sobrenome, Nome", ora "Nome Sobrenome"; `edition` como `3` e `2nd`; `month={Jul.}`; `year = 2019` sem chaves; datas de acesso em dois formatos (`:325`, `:375`); chave `williams2019c++` exige `label(...)`.

---

## (d) Texto e Typst

### D1 — Seção "Trabalhos relacionados" vazia · **Crítica**
- **Local:** `:1020-1024`. Três subtítulos sem texto ("Johansson", "Kapi", "Matriz de diferença") e a linha solta "figura: matrix de diferença", que aparece no PDF. A abertura do capítulo (`:373`) promete essa seção.

### D2 — Sete figuras sem imagem · **Crítica**
- **Local:** `:507-514`, `:1031-1039`, `:1064-1072`, `:1089-1097`, `:1102-1110`, `:1123-1131`, `:1168-1176` (`#image` comentado). Saem no PDF e na Lista de Ilustrações só com legenda e fonte: componentes conexos, pipeline, diagrama *Composite*, *TaskMaster*, cena do visualizador, `lwGraph` e representações do mesmo terreno. Nenhuma delas é citada no texto (ver D7).

### D3 — Desenvolvimento dentro da Fundamentação Teórica · **Alta**
- **Local:** `:1026-1245`. "Pipeline", "IFCG", "lwGraph", "search.hpp", "Gerador", "GraphModel" e "Instrumentação" são títulos de nível 2 sob `= Fundamentação Teórica` (saem como 2.8 a 2.14). Falta um título de nível 1 antes de `:1026`.

### D4 — Elementos pré-textuais pendentes · **Alta**
- **Local:** `:306-324`. Sem resumo, abstract, palavras-chave e banca; lista de siglas com o marcador `"SIG": [Sigla]` (`:321-323`) e TODO (`:319`); apêndices sem texto introdutório (TODO em `:1625`, `:1822`). O cabeçalho do modelo ainda diz "PRÉ-PROJETO (ABNT NBR 15287)" (`:2`).

### D5 — Referência cruzada duplicada e texto de link · **Média**
- `:1322` "na seção @res_comuns" sai "na seção Seção 4.1".
- `:1322` os links saem como "Apêndice: ANOVA" e "Apêndice: Tukey", mas os títulos são "Apêndice A" e "Apêndice B".
- `:1322` "seção de Ameaças" e `:1308` "seção de Ambiente" sem referência cruzada.

### D6 — Referência cruzada errada · **Média**
- **Local:** `:1606`. "a biblioteca de grafos e o motor IFCG (ver @gerador e @ifcg)": `@gerador` é o gerador de terrenos; a biblioteca está em `@lwgraph`.

### D7 — Figuras e tabelas nunca citadas no texto · **Média**
- **Figuras:** `fig_grafo_simples` (`:388`), `fig_componentes_conexos` (`:514`), `fig_perlin_celulas` (`:828`), `fig_grade_25d` (`:949`), `fig_grade_voxelizada` (`:964`), `fig_grafo_vertices` (`:979`), `fig_grafo_dual` (`:994`), `fig_pipeline` (`:1039`), `fig_mesh_composite` (`:1072`), `fig_taskmaster` (`:1097`), `fig_cena_visualizador` (`:1110`), `fig_lwgraph` (`:1131`), `fig_representacoes_terreno` (`:1176`) e as oito do Apêndice C (`:1900-1977`).
- **Tabelas:** `tab_tukey_alg` (`:1854`) e as quatro `tab_anova_*` (só alcançadas pelo link genérico do apêndice). O Apêndice C não é mencionado em lugar nenhum.

### D8 — Mesmo conceito com nomes diferentes · **Média**
- "O Weighted A\*" (`:683`, `:719`) × "A Weighted A\*" (`:1326` em diante).
- "grade de altura (2.5D)" (`:354`, `:367`) × "grade 2.5D".
- "comprimento de onda" × "frequência" (`:1211`, teste `frequency`) × "Comp. de onda".
- "fila de prioridade Q" × "lista aberta" (`:1137`) × "Open List" (coluna do CSV).
- "representação navegável" × "modelo de representação" (`:1028`) × "malha de navegação" para qualquer grafo (`:1043`), termo que `:983` reserva ao grafo dual.
- "reprodutível" (`:356`) × "reproduzível" (`:1606`); "open-source" (`:358`) × "código aberto" (`:1606`); "relaxamento" (`:576`) × "relaxação" (`:758`); "post hoc" (`:1009`) × "post-hoc" (`:1306`); "Esse trabalho" (`:346`) × "Este trabalho"; "Bacharelado de" (`:313`) × "Bacharelado em" (`:315`).
- **Ambíguo:** "caminhos [...] mais longos" (`:1574`, `:1602`) refere-se ao custo no grafo; o código também mede o "Comprimento Geométrico" sobre a superfície (`util.hpp:123-167`), que não é analisado. Convém dizer qual dos dois.

### D9 — Citação em forma de prosa no fim da frase · **Baixa**
- **Local:** `:1086`. Sai "...para encerramento cooperativo Williams (2019)."; deveria ser citação entre parênteses.

### D10 — Símbolos reutilizados · **Baixa**
- `h`: heurística (`:614`) e altura (`:770`); `v`: vértice e valor do pixel (`:784`, enquanto a fórmula usa `h(i, j)`).
- `w`: peso da heurística (`:616`) e peso de interpolação (`:832`); `f`: função de avaliação (`:642`) e frequência (`:847`).
- `p`: persistência, predecessor `p_v` e valor de p; `A`: conjunto de arestas (`:394`) e fator algoritmo (Apêndice A); `N`: número de oitavas (`:844`) e fator nível.

### D11 — Português e redação · **Baixa**
- `:1024` "matrix" (matriz).
- `:568` "inicializa a distância [...] como infinitos" (concordância).
- `:887`, `:889` legendas "baixa/alta amplitude/persistência" numa figura só de persistência.
- `:335` e `:790` legendas sem ponto final; as demais têm.
- `:616` e `:688` repetem a explicação de `w`; `:532` e `:534` repetem a mesma ideia.
- `:1112`, `:1133`, `:1233` títulos de seção com nomes de arquivo ou classe.
- `:1566` "Discussões" (usual: "Discussão").

### D12 — Pseudocódigos · **Baixa**
- `:675`, `:719`, `:758` dizem que as diferenças em relação ao Dijkstra estão em negrito, mas a linha que muda a ordenação é um comentário sem negrito (`:661`, `:705`, `:745`) e conta como linha numerada.
- Pseudocódigos entram como "Figura" na Lista de Ilustrações.

### Compilação
- `typst compile` (0.15.1) terminou com código 0, sem erros nem avisos; 76 páginas. Saída gravada fora do projeto.
- Pacote `@preview/lovelace:0.3.1` já estava no cache local; nada foi instalado. Fonte Arial disponível.
- Nenhum rótulo duplicado; nenhuma referência quebrada; nenhuma imagem referenciada ausente.

---

## (e) Lacunas: o que o código e os dados têm e o texto não cobre

### E1 — Execução e processo não entram no modelo estatístico · **Média**
- **Local:** `:1292`, `:1304`.
- **Código:** as quatro representações de um mesmo terreno são medidas em quatro processos distintos, em momentos diferentes da campanha (`coleta_completa.sh:192-229`); a análise trata a representação como fator dentro do terreno e ignora a execução (`analise/analise.py:317-335`). Qualquer diferença de estado da máquina entre blocos entra no efeito de representação sobre o tempo.
- **Sugestão:** registrar como ameaça à validade interna.

### E2 — Hipótese sobre o custo por vértice do A\* é parcialmente testável com os dados existentes · **Média**
- **Local:** `:1572` ("exigiria medir essas operações separadamente").
- **Dados já coletados:** `Nós Gerados` e `chamadas_heuristica`. Gerados/expandidos na 2.5D: A\* 2,08 × Dijkstra 1,59; tempo por expansão: A\* 808 ns × Dijkstra 505 ns (voxel: 420 × 324 ns).

### E3 — Métricas coletadas e não analisadas · **Baixa**
- `Comprimento Geométrico`, `Nós Gerados`, `Nós no Caminho`, métricas de terreno e de consulta, tempo de construção e de extração da malha (`statistics.hpp:22-58`). O texto admite a ausência da construção (`:1582`). Ordem de grandeza em dimensão 500: construção do dual 3,6 s, do grafo de vértices 0,18 s, das grades 0,03 s; extração da malha 0,9 s.

### E4 — Weighted A\* não reabre vértices fechados · **Baixa**
- **Código:** `search.hpp:251`, `:263`. O texto diz que "o restante da explicação do A\* se aplica" (`:719`), sem comentar a garantia de custo com heurística inflada.

### E5 — Sementes e ordem de execução · **Baixa**
- Os quatro testes usam a mesma sequência de sementes (200 de 200 em comum entre escala e lacunaridade), porque todos partem de `BASE_SEED + execução` (`coleta_completa.sh:193`, `statistics.hpp:283`).
- Os algoritmos rodam sempre na mesma ordem em cada consulta (`src/main.cpp:24-40`), sem sorteio.
- Os vértices de início e fim mudam por representação (ajuste máximo: 1,35 no dual, 1,00 no de vértices, 0,50 na voxelizada, 0 na 2.5D).

### E6 — Frequência do processador registrada e não relatada · **Baixa**
- `freq_cpu_inicio_khz` vale ~1,0 GHz em 69 dos 80 blocos e ~1,3 GHz em 11; `freq_cpu_fim_khz` vale ~1,3 GHz nos 80. O texto cita o governador `powersave` (`:1261`) sem discutir essa rampa.

### E7 — Artefatos do repositório sem menção · **Baixa**
- Campanhas-piloto (`piloto/`), resultados do `mcbench` (`results/mc_20261109_102653/`), `acquire.sh`, `run.sh`, `controls.py`, `src/terrain_viewer.cpp` e o gerador `noise3D` (`noise_gen.hpp:183-334`, não usado na coleta).

### E8 — Detalhes do gerador · **Baixa**
- O corte em [−1, 1] (`noise_gen.hpp:120-121`) é citado (`:1163`), mas não se informa se ele chega a atuar; pelas amplitudes, pode ocorrer em casos raros com persistência alta.

---

## O que foi verificado

- Leitura integral de `tcc_refac.typ`, `search.hpp`, `noise_gen.hpp`, `util.hpp`, `statistics.hpp`, `terrain_metrics.hpp`, `mc_bench.hpp`, `main.cpp`, `coleta_completa.sh`, `analise.py`, `referencias.bib`, e das partes do IFCG e da biblioteca de grafos descritas no texto (em `build/_deps/`).
- Recalculo independente, dos CSVs brutos, de todas as tabelas e dos números em prosa do capítulo 4 e dos apêndices A e B.
- Parâmetros e níveis (`:1288`) contra `statistics.hpp:245-264`, `:297`, `:504`, `:718`, `:942`; peso 1,5 (`main.cpp:37`); seis oitavas; limiar de 5 ms e 100 000 repetições; pausa de 60 s, 45 °C, 15 min, três tentativas, núcleo 2, semente base 20261030.
- Versões: GCC 16.2.1, CMake 4.4.5, C++20, Release `-O3 -DNDEBUG` (`build/CMakeCache.txt`, manifesto); CLI11 2.7.2 (`include/CLI11/CLI11.hpp:74`); json 3.11.3; glm 1.0.3 e Mesa 26.2.6 (pacotes instalados hoje); i5-1235U, 12 processadores lógicos, 15 GiB, governador `powersave` e `intel_pstate` (máquina atual).
- Chaves de citação, rótulos, referências cruzadas, arquivos de imagem e compilação.

## O que não foi possível verificar

- **Conteúdo das fontes:** sem acesso aos PDFs. Só C1 (resumo do artigo) e C3 (slides do autor) foram conferidos na web; C2 foi buscado e não localizado. Todo o resto das atribuições está **não verificado**, incluindo Gomes (2022), Hart et al., Pohl, Perlin, Lorensen e Cline, Lengyel, Algfoor et al., Snook, Demyen e Buro, Gurung, Lilja, Patel e as notas de aula.
- **Ambiente da coleta:** sistema iniciado por pendrive, kernel, governador e versões de glm/Mesa no momento da coleta não ficam registrados no manifesto; conferi apenas o estado atual da máquina.
- **Versões do IFCG e da biblioteca de grafos usadas na campanha** (ver A7).
- **Figuras:** conferi que os arquivos são os gerados pela análise, não o conteúdo visual de cada imagem nem a fidelidade das figuras conceituais.
- **Conformidade ABNT** do modelo (margens, espaçamentos, estilo de citação) não foi auditada.
- A análise `analise.py` não foi reexecutada; comparei suas saídas com o meu recálculo.
