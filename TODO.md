= Implementação
[x] Algoritmos: Dijkstra, A*, Greedy Best-First, Weighted A*
    search.hpp integrado ao stats e ao viewer
[x] Representação: Grid, Voxel, Vertex Graph, Dual Graph
[x] Voxel Graph está fragmentado, precisa ser refeito
    Não precisa refazer: é a superfície caminhável do mesmo volume do marching cubes.
    Mantida vizinhança-4 (adjacência por face).
[x] Grid 3D deveria ser Grid 2.5D
[x] Terreno escala, lacunaridade, persistência, seeds diferentes.
    stats <scale|lac|pers> com seeds determinísticas (--seed)
[x] Coletar nós espandidos
[x] Corrigir lacunaridade e persistência.
    Ex: em "amp /= 2;" 1/2 é a persistência e não o amp
    Corrigido no ruído 2D (usado no experimento). O ruído 3D ainda usa amp /= 2 e freq *= 2,
    mas não entra no pipeline experimental.
[x] Start/end equivalentes: pares (rand, 0) → (rand, D-1), snap no maior componente conexo
[x] Critério de transitabilidade comum: inclinação máxima 1 (45°) em todas as representações
[x] Altura = largura = profundidade; teste de escala estica o terreno (heightScale / wave = 2)
[x] Comprimento geométrico: caminho projetado em (x, z) sobre o heightmap
[x] Memória do grafo: memória estrutural pela capacidade alocada
[x] Viewer usa o mesmo par/snap do experimento (1 par por terreno, seed do terreno)

= Coleta
[ ] Rodada completa: 10 execuções de 10 (fora deste repositório)
[ ] Análise: juntar os CSVs (representação vem do nome do arquivo), ANOVA + Tukey, gráficos

= Escrita
[ ] Reescrever pergunta central + objetivo geral/específicos em torno das representações navegáveis.
[ ] Atualizar as variáveis experimentais, adicionando representação navegável.
[ ] Como diferentes representações do espaço navegável afetam o desempenho, o consumo de memória e a qualidade das soluções produzidas por algoritmos de busca em terrenos procedurais?
[ ] Perlin e Marching Cubes
        ↓
    Grade regular 2.5D
    Grade voxelizada
    Grafo de vértices
    Grafo dual de polígonos
        ↓
    Dijkstra
    A*
    Greedy Best-First
    Weighted A*
[ ] Voxel Graph → Representação voxelizada do espaço navegável
[ ] Analisar o impacto de diferentes representações navegáveis no desempenho e na qualidade de solução de algoritmos de busca aplicados a terrenos tridimensionais.
[ ] Reescrever “extração de grafos” para explicar as quatro transformações.
[ ] Tirar NavMeshes e OctoTree
[ ] Malhas 3D → "representações navegáveis de terrenos tridimensionais" ou "navegação em terrenos tridimensionais"
[ ] frequência = lacunaridade inicial
[ ] amplitude = persistência inicial
[ ] Reduzir protagonismo da concorrência
[ ] Definir exatamente o custo das arestas em cada representação
    Definido no código: distância euclidiana 3D entre os nós (heurística euclidiana admissível).
[ ] Definir start/end equivalentes entre representações
    Definido no código: pares nas margens opostas, snap no maior componente conexo.
[ ] Definir critério de transitabilidade comum
    Definido no código: |dy| / distância horizontal ≤ 1 (45°).
[ ] Limitações / decisões a documentar:
    - Tempo de execução inclui inicialização de vetores O(|V|) (pesa no GBFS)
    - Snap pode realocar o ponto em até ~9 unidades em terreno íngreme
    - Weighted A* com peso fixo 1.5
    - Voxel com vizinhança-4 infla o comprimento do caminho (~19% vs 2.5D)
    - Memória do grafo = estrutura pronta (capacity), sem temporários da construção
    - Vertex: custo pode ficar abaixo do comprimento geométrico (vértices do MC fora da superfície)

= Foco
[ ] Análise do impacto de representações navegáveis no desempenho de algoritmos de busca em terrenos tridimensionais procedurais.

[x] Representações:
    - Grid 2.5D
    - Voxel
    - Vertex Graph
    - Dual Graph

[x] Algoritmos:
    - Dijkstra
    - A*
    - Greedy Best-First
    - Weighted A*

[x] Terrenos:
    - Escala
    - Frequência base
    - Amplitude base
    - Seeds

[x] Métricas da busca:
    - Nós gerados
    - Tempo
    - Nós expandidos
    - Custo Caminho
    - Comprimento geométrico

[x] Métricas da representação:
    - |V|
    - |E|
    - Memória
    - Tempo de construção
