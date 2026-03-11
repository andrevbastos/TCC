= Destrinchando o tema
A ideia do tema é “Análise Visual e Comparativa de Algoritmos de Pathfinding
de Malhas3D em Tempo Real”, mas o que isso significa? Sobre o que esse TCC
vai abordar?
* Grafos
* Algoritmos de pathfinding
    * Refinamento de heurísticas
* Estudo de caso com diferentes algoritmos
    * Comparação técnica
* Geração de malhas 3D com grafos
    * NavMesh
* Estudo de caso EM TEMPO REAL com diferentes algoritmos
    * Comparação técnica e visual
* Aplicação dos conceitos
Nas minhas palavras...
A ideia deste TCC é fazer um estudo empírico do uso de grafos em ambientes
3D para a busca de caminhos em tempo real. Neste projeto, pretendo falar sobre:
* o funcionamento de grafos e algoritmos de busca
* introdução a algoritmos de busca dinâmicos
* geração de grafos de navegação a partir de malhas 3D
* utilização dos algoritmos nas malhas 3D
* comparação de algoritmos
* otimização de buscas para alto desempenho
Talvez
* Concorrência
    * Múltiplas buscas concorrentes, movimentação de uma gera novos
obstáculos para as demais
* Falar sobre alto desempenho em C++
* Explicação das bibliotecas Graph e IFCG (merchant)

= Métricas
Como vamos fazer um comparativo de algoritmos, temos que definir o que
comparar.
* Pico de consumo de Memória
    * Comparação do uso antes e durante a busca
* FPS (ou ms)
* Melhor/Médio/Pior caso e O/Ω
    * Caminhos livres; Caminhos com obstáculos; Caminhos inacessíveis
    * Overhead
* Número de Nós Visitados
* Comprimento/Custo do Caminho Gerado

= Bibliografia
* Grafos, Paulo Rodacki
* Algoritmos, Thomas Cormen
* Inteligência Artificial, Stuart Russel
* Multi-threaded Recast-Based A* Pathfinding for Scalable Navigation in Dynamic Game Environments, Tiroshan Madushanka e Sakuna Madushanka
* A Comparative Study of Navigation Meshes, Wouter van Toll
* Improving Jump Point Search, Daniel Harabor e Alban Grastien
* A Review of Pathfinding in Game Development, um monte de gente