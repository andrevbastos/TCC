= Coleta
[ ] Rodada completa: 10 execuções de 10 (fora deste repositório)
[ ] Análise: juntar os CSVs (representação vem do nome do arquivo), ANOVA + Tukey, gráficos

= Escrita (typ/tcc/tcc.typ)
Fontes da verdade: código (include/core, src/main.cpp, acquire.sh) e apresentacao.pdf.
Citar SÓ chaves de typ/tcc/referencias.bib. Sem fonte no bib → decisão de projeto/raciocínio próprio.
(verificar) = conferir se a obra sustenta o ponto antes de citar.
Ordem sugerida: 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8. Resultados ficam para depois.

== 1. Objetivos, Introdução e Justificativa
[ ] natureza_trabalho / template: "Pré-projeto" → TCC
[ ] Objetivos: geral + 5 específicos do slide 5 (sai JPS, Theta*, estresse multithread)
[ ] Introdução (slides 3–4): pathfinding = gerar grafo + buscar; 2D custo constante vs 3D onde
    construir o grafo é decisão; pergunta de pesquisa; 3 contribuições; "não propõe novo algoritmo"
    Citar: russell_norvig, pathfinding_game_dev, algfoor_pathfinding_survey (duas etapas),
    a_star_modification só para "3D exige adaptações" (verificar)
[ ] Remover da introdução: RAM/concorrência como foco, smoothing
[ ] Justificativa: trabalhos avaliam uma única representação; engines não expõem a representação
    como variável controlada (slide 6). Citar: johansson2024adapting, Kapi2022, algfoor_pathfinding_survey
[ ] Terminologia: "malhas 3D" → "representações navegáveis de terrenos tridimensionais"

== 2. Fundamentação: grafos e busca
[ ] Grafos: reduzir direcionados a uma frase (trabalho usa não direcionados, custo simétrico)
[ ] Componente conexo (usado no snap e no descarte de terrenos). rodacki_grafos (verificar)
[ ] Busca best-first genérica (open/closed, f(n)) unificando a tabela do slide 7. russell_norvig, astar
[ ] Dijkstra: dijkstra1959note, rodacki_grafos (opcional: breaking_sorting_barrier, preprint, direcionados)
[ ] Heurística admissível e consistente (russell_norvig, astar). Peso = euclidiana 3D → h euclidiana 3D
    consistente (desigualdade triangular) → A* sem reabertura é ótimo
[ ] Weighted A*: f = g + w·h, custo ≤ w·C* (pohl1970heuristic). Não reabertura = decisão de implementação
[ ] Greedy Best-First: f = h, sem garantia (russell_norvig)

== 3. Fundamentação: Perlin
[ ] Fade: trocar smoothstep 3w²−2w³ pela quíntica 6w⁵−15w⁴+10w³ (noise_gen.hpp:63), fórmula + figura.
    Justificar por derivadas (1ª e 2ª nulas em 0 e 1) SEM atribuir a perlin1985image.
    zipped_perlin_noise só se o tutorial usar a quíntica (verificar)
[ ] Soma de oitavas conforme generateNoiseMap: freq·lac^i, amp pers^i, x/wave, offset e seed por oitava,
    normalização por √Σa², clamp [−1,1], [0,1], ^exp, y = 1 + v(H−1). Citar patel_terrain_noise
[ ] Explicar normalização RMS como decisão própria: evita confundir persistência com amplitude
    (com Σa o desvio caía ~32% de pers 0,3 a 0,7)
[ ] Deixar claro: frequência base = lacunaridade inicial; amplitude base = persistência inicial
[ ] Limite de lacunaridade 2,25 por Nyquist (lac⁵/250 ≤ 0,25) como decisão de projeto (sem fonte no bib)
[ ] Figuras de lac/pers: trocar pelas do slide 9 (l = 1,5/2,5, p = 0,3/0,7, mesma seed; tcc save)
[ ] Heightmap: manter conceito, tirar ênfase em imagens externas e figura de Solstheim,
    fórmula h = v/255·H → y = 1 + v(H−1)
[ ] Remover seção "Ruídos 3D" (noise3D fora do experimento)

== 4. Fundamentação: geometria e representações navegáveis
[ ] Voxels + Marching Cubes: volume binário pelas colunas do heightmap; tabelas regular cell do
    Transvoxel; vértice na aresta (sem interpolação, campo binário); dedup por chave em coordenadas
    dobradas; paredes cortadas pelo critério de 45°. lorensen_cline_marching_cubes, lengyel_transvoxel, learnopengl
[ ] Para cada representação: nó, vizinhança, peso, |V|, |E| e figura (slide 10)
[ ] Grade 2.5D (createGrid2_5D): y contínuo, vizinhança-8, |V| = N², |E| ≤ ~4N².
    sturtevant_grid_benchmarks, algfoor_pathfinding_survey
[ ] Superfície voxel (createVoxelGraph): y arredondado, vizinhança-4 (face); é a superfície caminhável
    do volume, não grafo volumétrico. johansson2024adapting
[ ] Grafo de vértices (createVertexToVertex): arestas dos triângulos do MC, sem duplicatas
[ ] Grafo dual (createPolygonToPolygon): centroides, adjacência por aresta compartilhada.
    snook_navmesh, demyen_buro_triangulation, navigation_mesh
[ ] Regras comuns: não direcionado, peso euclidiano 3D, |Δy|/d_h ≤ 1 (45°), d_h = 0 rejeitado
[ ] Fundamentação estatística: ANOVA (algoritmo × representação × nível), pressupostos, Tukey, α = 0,05.
    jurandir, jain1991art. Nomear Shapiro-Wilk/Levene/Kruskal-Wallis só se essas fontes cobrirem
[ ] Corrigir "Tuckey" no slide 13

== 5. Trabalhos relacionados
[ ] Diferencial = representação como fator + terreno parametrizado + estatística
    (sai Theta*/JPS/jthread/segurança de memória)
[ ] Refazer matriz: representação(ões), algoritmos, geração do terreno, análise estatística
    johansson2024adapting, Kapi2022, sturtevant_grid_benchmarks

== 6. Desenvolvimento
[ ] Pipeline (slide 11)
[ ] IFCG: resumir (Singleton/Composite/Window...), basear na tabela "Por que um motor próprio?" (slide 6);
    gamma1994design só se os padrões continuarem citados
[ ] Pilha tecnológica (lambdas, jthread, stop_token) → 1 parágrafo
[ ] OpenGL: só o mínimo para o visualizador (learnopengl)
[ ] Biblioteca: lwGraph<T> (vetores contíguos), NavigationGraph. Remover common::Graph OOP como foco,
    lwGrid, lwAStar, lwAStarMod, lwThetaStar, JPS, smoothing
[ ] search.hpp: implementações separadas de mesma estrutura (Dijkstra não é mais A* com h = 0),
    lazy deletion, desempate (f, h, id), contadores expanded/generated/peakOpen,
    GBFS insere uma vez e atualiza só o pai
[ ] Concorrência só no viewer: runAsyncThenMain (geometria High → grafo + snap Medium →
    caminhos Medium → upload na main). Remover pinThreadToCore e lote de stats por prioridade.
    williams2019c++, ladeira
[ ] Gerador de terreno: tcc save, --save-octaves
[ ] GraphModel / GraphFactory / requiresGeometry / isTraversable
[ ] Instrumentação: Results/Statistics, CSV só com métricas da defesa (diagnósticos no stderr),
    CLI (test/save/stats)

== 7. Metodologia
[ ] Variáveis: tabela do slide 12 + peso do WA* (1,5) nas controladas. jain1991art
    (sai A* modificado, JPS, Theta*, FPS, cache)
[ ] Níveis: escala 500/600/700/800; lac 1,5/1,75/2,0/2,25; pers 0,3/0,433/0,567/0,7;
    fixos 6 oitavas, H/wave = 2 (H = N e wave = N/2 na escala; H = 500 e wave = 250 em lac/pers)
[ ] Extração do grafo: trocar heightLimit pelo critério de inclinação 45°
[ ] Remover importação de heightmaps por imagem (só terreno procedural)
[ ] Procedimento por terreno: mt19937(baseSeed) → seed do terreno → pares (^0x9E3779B9);
    10 pares z = 0 → z = N−1; snap ao vértice mais próximo; terreno refeito se algum algoritmo falha
[ ] Métricas (definição própria): custo no próprio grafo; custo relativo = custo / Dijkstra;
    comprimento geométrico (surfacePathLength: bilinear, passo 0,25; comparável entre representações);
    memória do grafo (capacity); memória da busca (estimativa analítica); tempo só da busca;
    tempo de construção exclui o MC; nós expandidos, gerados, pico da open list
[ ] Execução: descrever acquire.sh (Release, processo por execução, seed registrada, cooldown 60 s,
    manifest.csv, logs). lilja2000measuring
[ ] Ambiente: revisar versões (kernel, GCC); remover afinidade/governor se não implementados
[ ] Estatística: observações não independentes (mesmo terreno/par nos 4 algoritmos) → terreno/par
    como bloco ou agregar por terreno. jain1991art (verificar)
[ ] Ameaças à validade (lilja2000measuring, jain1991art):
    - Descarte de terrenos = viés de seleção (pior em vertex/dual); contar "[refeito]" no stderr
    - Snap pode realocar o ponto em até ~9 unidades em terreno íngreme
    - Tempo inclui inicialização de vetores O(|V|) (pesa no GBFS)
    - Weighted A* com peso fixo 1,5
    - Voxel com vizinhança-4 infla o comprimento (~19% vs 2.5D)
    - Memória do grafo = estrutura pronta (capacity), sem temporários da construção; memória da busca estimada
    - Vertex: custo pode ficar abaixo do comprimento geométrico (vértices do MC fora da superfície)
    - CPU híbrida (i5-1235U) sem afinidade fixada

== 8. Limpeza
[ ] Siglas: remover EBO, VAO, VBO, SIGSEGV, IJACSA, JPS, MST, RGB, FPS etc.; adicionar GBFS, WA*, BFS, CSV, HSD
[ ] Bib: unificar russel_norvig → russell_norvig
[ ] Bib: remover se sem citação: gtest, imperial_library_solstheim, a_star_multithreaded, breaking_sorting_barrier
[ ] JPS/Theta* só em trabalhos futuros (jps_3d, nash2007thetastar, nash2013anyangle)
[ ] Verificação: typst compile sem erros; grep JPS|Theta|heightLimit|pinThread|lwAStar|3w^2 vazio
    (exceto trabalhos futuros); toda citação existe no bib; fórmulas conferidas contra o código

= Decidir
[ ] Lacunaridade: slide diz 1,5–2,5, código 1,5–2,25 → corrigir slide
[ ] Repetições: slide diz 10 terrenos/nível, acquire.sh faz 10 × 10 = 100 → alinhar slide
[ ] Afinidade de CPU / governor: implementar no acquire.sh ou tirar do texto
[ ] Snap: TODO antigo dizia "maior componente conexo", mas stats faz snap em todo o grafo
    (statistics.hpp:262); só o viewer usa largestComponentMask → definir o pretendido
