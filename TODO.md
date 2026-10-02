= Implementação
[ ] Algoritmos: Dijkstra, A*, Greedy Best-First, Weighted A*
[ ] Representação: Grid, Voxel, Vertex Graph, Dual Graph
[ ] Voxel Graph está fragmentado, precisa ser refeito
[ ] Grid 3D deveria ser Grid 2.5D
[ ] Terreno escala, lacunaridade, persistência, seeds diferentes.
[ ] Coletar nós espandidos
[ ] Corrigir lacunaridade e persistência.
    Ex: em "amp /= 2;" 1/2 é a persistência e não o amp
[ ] Registrar quando não existe caminho

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
[ ] Definir start/end equivalentes entre representações
[ ] Definir critério de transitabilidade comum

= Foco
[ ] Análise do impacto de representações navegáveis no desempenho de algoritmos de busca em terrenos tridimensionais procedurais.

[ ] Representações:
    - Grid 2.5D
    - Voxel
    - Vertex Graph
    - Dual Graph

[ ] Algoritmos:
    - Dijkstra
    - A*
    - Greedy Best-First
    - Weighted A*

[ ] Terrenos:
    - Escala
    - Frequência base
    - Amplitude base
    - Seeds

[ ] Métricas da busca:
    - Tempo
    - Nós expandidos
    - Nós gerados
    - Custo
    - Comprimento geométrico
    - Taxa de sucesso

[ ] Métricas da representação:
    - |V|
    - |E|
    - Memória
    - Tempo de construção