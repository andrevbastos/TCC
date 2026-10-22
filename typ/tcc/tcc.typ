// ==========================================
// CONFIGURAÇÃO DO TEMPLATE DE PRÉ-PROJETO (ABNT NBR 15287)
// ==========================================

#let pre_projeto_abnt(
  titulo: "",
  subtitulo: "",
  autor: "",
  orientador: "",
  coorientador: "",
  instituicao: "",
  curso: "",
  local: "",
  ano: "",
  natureza_trabalho: "",
  banca: (),
  data_aprovacao: "",
  dedicatoria: [],
  agradecimentos: [],
  epigrafe: [],
  resumo: [],
  palavras_chave: [],
  abstract: [],
  keywords: [],
  lista_ilustracoes: false,
  lista_tabelas: false,
  lista_siglas: (:),
  lista_simbolos: (:),
  corpo
) = {
  set page(
    paper: "a4",
    margin: (top: 3cm, left: 3cm, right: 2cm, bottom: 2cm),
    numbering: none
  )
  
  set text(font: ("Arial"), size: 12pt, lang: "pt", region: "br")

  align(center)[
    #text(weight: "bold", upper(instituicao)) \
    #text(weight: "bold", upper(curso))

    #v(2fr)
    #text(weight: "bold", upper(autor)) 
    #v(2fr)
    
    #text(weight: "bold", size: 14pt, upper(titulo))
    #if subtitulo != "" [
      #text(weight: "bold", size: 14pt)[: #subtitulo]
    ]
        
    #v(3fr)
    #text(weight: "bold", local) \
    #text(weight: "bold", ano)
  ]
  pagebreak()
  counter(page).update(1)

  align(center)[
    #text(upper(autor))
    #v(1fr)
    
    #text(weight: "bold", upper(titulo))
    #if subtitulo != "" [
      #text(weight: "bold")[: #subtitulo]
    ]
    #v(3em)
    
    #align(right)[
      #pad(left: 8cm)[
        #set text(size: 10pt)
        #set par(leading: 0.65em, justify: true)
        #natureza_trabalho
        \ \
        *Orientador(a):* #orientador
        #if coorientador != "" [
          \ *Coorientador(a):* #coorientador
        ]
      ]
    ]
    
    #v(1fr)
    #local \
    #ano
  ]
  pagebreak()

  if banca != () [
    #align(center)[
      #text(upper(autor)) \
      #v(2em)
      #text(weight: "bold", upper(titulo))
      #if subtitulo != "" [
        #text(weight: "bold")[: #subtitulo]
      ]
      #v(2em)
    ]
    #align(right)[
      #pad(left: 8cm)[
        #set text(size: 10pt)
        #set par(leading: 0.3em, justify: true)
        #natureza_trabalho
      ]
    ]
    #v(2em)
    #if data_aprovacao != "" [
      Aprovado em: #data_aprovacao \
    ]
    #v(1.5em)
    #align(center)[*BANCA EXAMINADORA*]
    #v(1.5em)
    
    #for membro in banca [
      #align(center)[
        #v(2.5em)
        #line(length: 60%, stroke: 0.5pt) \
        #text(weight: "bold")[#membro.nome] \
        #set text(size: 10pt)
        #membro.filiacao
      ]
    ]
    #pagebreak()
  ]

  if dedicatoria != [] [
    #align(right + bottom)[
      #pad(left: 50%)[
        #set text(style: "italic")
        #dedicatoria
      ]
    ]
    #pagebreak()
  ]

  if agradecimentos != [] [
    #align(center)[#text(weight: "bold")[AGRADECIMENTOS]]
    #v(1.5em)
    #set par(first-line-indent: 1.25cm, leading: 0.5em, justify: true)
    #agradecimentos
    #pagebreak()
  ]

  if epigrafe != [] [
    #align(right + bottom)[
      #pad(left: 50%)[
        #set text(style: "italic")
        #epigrafe
      ]
    ]
    #pagebreak()
  ]

  if resumo != [] [
    #align(center)[#text(weight: "bold")[RESUMO]]
    #v(1.5em)
    #set par(first-line-indent: 0pt, leading: 0.3em, justify: true)
    #resumo
    
    #v(2em)
    #text(weight: "bold")[Palavras-chave:] #palavras_chave.join(". ").
    #pagebreak()
  ]

  if abstract != [] [
    #align(center)[#text(weight: "bold")[ABSTRACT]]
    #v(1.5em)
    #set par(first-line-indent: 0pt, leading: 0.3em, justify: true)
    #abstract
    
    #v(2em)
    #text(weight: "bold")[Keywords:] #keywords.join(". ").
    #pagebreak()
  ]

  if lista_ilustracoes [
    #align(center)[#text(weight: "bold")[LISTA DE ILUSTRAÇÕES]]
    #v(1.5em)
    #outline(title: none, target: figure.where(kind: image))
    #pagebreak()
  ]

  if lista_tabelas [
    #align(center)[#text(weight: "bold")[LISTA DE TABELAS]]
    #v(1.5em)
    #outline(title: none, target: figure.where(kind: table))
    #pagebreak()
  ]

  if type(lista_siglas) == dictionary and lista_siglas.len() > 0 [
    #align(center)[#text(weight: "bold")[LISTA DE ABREVIATURAS E SIGLAS]]
    #v(1.5em)
    
    #grid(
      columns: (auto, 1fr),
      column-gutter: 2em,
      row-gutter: 1em,
      ..for (sigla, significado) in lista_siglas {
        (strong(sigla), significado)
      }
    )
    #pagebreak()
  ]


  if type(lista_simbolos) == dictionary and lista_simbolos.len() > 0 [
    #align(center)[#text(weight: "bold")[LISTA DE SÍMBOLOS]]
    #v(1.5em)
    
    #grid(
      columns: (auto, 1fr),
      column-gutter: 2em,
      row-gutter: 1em,
      ..for (simbolo, significado) in lista_simbolos {
        (strong(simbolo), significado)
      }
    )
    #pagebreak()
  ]

  align(center)[#text(weight: "bold")[SUMÁRIO]]
  v(1.5em)
  
  show outline.entry: it => {
    if it.level == 1 {
      v(1em, weak: true)
      strong(upper(it))
    } else if it.level == 2 {
      strong(it)
    } else {
      it
    }
  }
  
  outline(title: none, depth: 3, indent: 0.5em)
  pagebreak()

  set page(numbering: "1", number-align: top + right)

  set par(
    justify: true, 
    first-line-indent: 1.25cm, 
    leading: 0.65em, 
    spacing: 0.8em
  )

  set heading(numbering: "1.1")
  set math.equation(numbering: "(1)")
  show heading: it => {
    set text(size: 12pt, weight: "bold")
    set block(above: 1.5em, below: 1.5em) 
    
    if it.level == 1 {
      pagebreak(weak: true)
      upper(it)
    } else if it.level == 2 {
      it
    } else {
      set text(weight: "regular")
      it
    }
    par(text(size: 0pt, ""))
    context v(-par.spacing)
  }

  show figure: it => block(breakable: false, width: 100%)[
    #set align(center)
    #set text(size: 10pt)
    #set par(leading: 0.3em)
    
    #if it.has("caption") [
      #strong[#it.supplement #it.counter.display(it.numbering) -- #it.caption.body]
      #v(0.5em)
    ]
    #it.body
    #v(1em)
  ]

  show bibliography: set text(size: 12pt)
  show bibliography: set par(leading: 0.3em, first-line-indent: 0pt, justify: false)
  show bibliography: set block(spacing: 1.5em)
  show bibliography: set align(left)

  corpo
}

#let citacao_longa(texto) = {
  pad(left: 4cm, right: 0cm)[
    #set text(size: 10pt)
    #set par(first-line-indent: 0pt, leading: 0.3em)
    #texto
  ]
  v(1.5em)
}

#let contador_topicos = counter("topico_obj")

#let topico(titulo, texto) = {
  contador_topicos.step()
  
  context contador_topicos.display("1.")
  [ *#titulo:* #texto]
}

#show: pre_projeto_abnt.with(
  titulo: "Algoritmos de busca de caminho em representações navegáveis tridimensionais",
  subtitulo: "Uma análise estatística e comparativa",
  autor: "André Vitor Bastos de Macêdo",
  orientador: "Prof. Paulo César Rodacki Gomes",
  instituicao: "Instituto Federal Catarinense - IFC",
  curso: "Bacharelado de Ciência da Computação",
  local: "Blumenau",
  ano: "2026",
  natureza_trabalho: "Trabalho de Conclusão de Curso apresentado ao curso de Bacharelado em Ciência da Computação do Instituto Federal Catarinense.",
  
  lista_ilustracoes: true,
  lista_tabelas: true,
  // TODO(tcc): acrescentar conforme o texto for escrito: GBFS (Greedy Best-First Search), WA* (Weighted A*),
  // BFS (Breadth-First Search, se citar o componente conexo), CSV, HSD (Tukey). Revisar no fim se todas aparecem no texto.
  lista_siglas: (
    "A*": [_A-Star_],
    "ANOVA": [_Analysis of Variance_ \ (Análise de Variância)],
    "API": [_Application Programming Interface_ \ (Interface de Programação de Aplicações)],
    "CPU": [_Central Processing Unit_ (Unidade Central de Processamento)],
    "GCC": [_GNU Compiler Collection_],
    "GLFW": [_Graphics Library Framework_],
    "GLM": [_OpenGL Mathematics_],
    "GLSL": [_OpenGL Shading Language_],
    "GPU": [_Graphics Processing Unit_ \ (Unidade de Processamento Gráfico)],
    "IFCG": [Instituto Federal Catarinense/Computação Gráfica],
    "OpenGL": [_Open Graphics Library_],
    "RAII": [_Resource Acquisition Is Initialization_ \ (Aquisição de Recursos é Inicialização)],
    "RAM": [_Random Access Memory_ \ (Memória de Acesso Aleatório)],
    "STL": [_Standard Template Library_ \ (Biblioteca Padrão de Modelos)],
    "TCC": [Trabalho de Conclusão de Curso]
  )
)

= INTRODUÇÃO
A busca de caminhos (ou _pathfinding_) é um dos campos mais tradicionais da Inteligência Artificial aplicada, evoluindo a partir dos algoritmos de busca clássicos em grafos. Como definem #cite(<russell_norvig>, form: "prose"), os métodos clássicos de busca resolvem problemas de estados, ações e custos, visando encontrar caminhos entre um ponto de partida e um objetivo por meio da exploração do espaço de busca. Ao longo das últimas décadas, essa fundamentação deixou de ser puramente abstrata e passou a ser aplicada diretamente na computação interativa. Conforme apontam #cite(<pathfinding_game_dev>, form: "prose"), os algoritmos de busca tornaram-se componentes cruciais para o desenvolvimento de jogos modernos e simulações em tempo real.

// TODO(tcc): pathfinding em duas etapas: gerar o grafo do espaço e buscar nele (algfoor_pathfinding_survey).
// Slide 3: na grade 2D o custo entre vizinhos é constante; no terreno 3D depende da altura, e transformar o terreno em grafo vira uma decisão.

// TODO(tcc): pergunta de pesquisa (slide 4): "Como a representação navegável de um terreno 3D e as
// características do terreno influenciam o tempo de execução e a qualidade dos caminhos encontrados por algoritmos clássicos de busca?". Fechar com "não propõe novo algoritmo; foco na avaliação comparativa".

// TODO(tcc): contribuições (slide 4): (1) mesmo terreno em 4 representações (grade 2.5D, superfície voxel,
// grafo de vértices, grafo dual) com os mesmos algoritmos; (2) metodologia reprodutível (seed registrada,
// escala/lacunaridade/persistência, ANOVA + Tukey); (3) implementação aberta (biblioteca de grafos + IFCG).
// Concorrência NÃO é foco: as medições são sequenciais e fora do laço de renderização.

= JUSTIFICATIVA
// TODO(tcc): lacuna: trabalhos avaliam algoritmos em UMA representação (voxels em johansson2024adapting,
// grades 2D em Kapi2022); engines (Unity/Unreal) geram a própria navmesh, e a representação não é variável
// controlável (tabela do slide 6). Representações são famílias estabelecidas (algfoor_pathfinding_survey).
// Infraestrutura própria justificada pelo controle da construção do grafo, não por "anomalias de hardware".

= OBJETIVOS
// TODO(tcc): 1 frase de abertura do capítulo.

== Objetivos Gerais
// TODO(tcc): slide 5: "Analisar comparativa e estatisticamente o desempenho de algoritmos clássicos de busca
// de caminhos em diferentes representações navegáveis de terrenos 3D."

== Objetivos Específicos
// TODO(tcc): slide 5, 5 itens: (1) biblioteca de grafos + Dijkstra, A*, GBFS, WA*; (2) gerador procedural
// Perlin parametrizado por escala, lacunaridade e persistência; (3) 4 representações navegáveis; (4) ambiente 3D
// com execução concorrente para visualização das malhas e caminhos; (5) coleta automatizada + análise estatística.

= FUNDAMENTAÇÃO TEÓRICA
A fundamentação teórica deste trabalho engloba conceitos fundamentais nas áreas de algoritmos de busca, estruturas de dados, computação gráfica e concorrência, cujas definições conceituais são detalhadas a seguir.

== Pilha Tecnológica
// TODO(tcc): não responde à pergunta de pesquisa. Resumir em 1 parágrafo (C++20, STL, GLFW/GLM) e mover
// para o capítulo de Desenvolvimento; lambdas/jthread só se forem usados para explicar o visualizador.

Para um ambiente de desenvolvimento robusto e eficiente, a escolha da pilha tecnológica é crucial. A seguir, são detalhados os principais componentes que compõem a base tecnológica deste estudo.

A linguagem de programação C++20 caracteriza-se por sua eficiência, controle de baixo nível e ampla adoção na indústria de jogos e simulações, oferecendo recursos avançados para manipulação de memória, concorrência e otimização de desempenho. A adoção do C++20 destaca-se pela disponibilidade de bibliotecas e _frameworks_ que facilitam a implementação de estruturas de dados complexas, renderização gráfica e execução concorrente, além de permitir integração eficiente com APIs gráficas como OpenGL.

=== Estruturas de Dados
A representação de grafos, filas de prioridade e outras estruturas auxiliares necessárias para algoritmos de busca e motores gráficos é viabilizada pela biblioteca padrão do C++, a STL (_Standard Template Library_), que oferece uma variedade de contêineres e algoritmos otimizados para manipulação de dados. 

Estruturas como vetores, tabelas de dispersão (_hash maps_) e filas de prioridade desempenham papel crucial na representação de grafos e no gerenciamento de nós durante a execução dos algoritmos de busca.

=== Funções _Lambda_
A introdução de funções _lambda_ em C++11 e suas melhorias contínuas nas versões subsequentes, incluindo C++20, proporcionou uma maneira mais concisa de definir funções anônimas.

Por definição, uma função anônima é uma função "sem nome", que pode ser definida e utilizada diretamente no local onde é necessária. Essas funções são particularmente úteis para operações que exigem uma função de curto prazo, como a definição de heurísticas em algoritmos de busca ou a implementação de funções de retorno (_callbacks_) para eventos específicos durante a renderização ou execução dos algoritmos.

=== Biblioteca `jthread`
A introdução da biblioteca `jthread` no padrão C++20 simplifica a implementação de _multithreading_ e concorrência. A classe `jthread` oferece uma interface mais segura e fácil de usar para gerenciamento de _threads_, incluindo a capacidade de interromper _threads_ de forma cooperativa.

Esta biblioteca utiliza os princípios de RAII (_Resource Acquisition Is Initialization_) para garantir que os recursos sejam gerenciados de forma eficiente e segura, evitando problemas comuns em _multithreading_. A classe `jthread` é gerenciada de uma forma que, no momento de sua destruição, realiza uma junção (`join`) automaticamente, garantindo que os recursos sejam liberados corretamente. Isso não só facilita a implementação de concorrência, mas também melhora a segurança do código. Uma junção (`join`) é uma operação que bloqueia a execução da _thread_ chamadora até que a _thread_ alvo termine sua execução.

A introdução dos tokens de parada (`stop_token`) na biblioteca permite que as _threads_ sejam interrompidas de maneira cooperativa, o que se mostra relevante em cenários de simulação nos quais é necessário controlar o tempo de execução e garantir que as linhas de processamento sejam finalizadas de forma segura.

=== Bibliotecas Auxiliares
A visualização gráfica e os cálculos espaciais são viabilizados por bibliotecas consagradas na literatura. A biblioteca GLFW @learnopengl, por exemplo, é empregada para gerenciar a criação de janelas, o contexto de renderização do OpenGL e o tratamento de eventos de dispositivos de entrada (teclado e mouse). 

Para as operações matemáticas de geometria analítica e álgebra linear, emprega-se a biblioteca GLM (OpenGL Mathematics), que implementa estruturas otimizadas de vetores e matrizes compatíveis com as especificações de sombreamento do OpenGL (GLSL).

== Teoria dos Grafos
Uma vez que os algoritmos de _pathfinding_ operam sobre estruturas de grafos para encontrar caminhos entre nós, a teoria dos grafos fornece o arcabouço matemático e conceitual necessário para modelar caminhos e conexões espaciais, servindo como base conceitual para o funcionamento dos algoritmos de busca.

Segundo #cite(<rodacki_grafos>, form: "prose"), um grafo é uma estrutura de dados composta por um conjunto de vértices (ou nós) e um conjunto de arestas (ou ligações) que conectam esses vértices. Os grafos podem ser direcionados, onde as arestas têm uma direção específica, ou não direcionados, onde as arestas não possuem direção. A representação de grafos pode ser feita de diversas formas, como listas de adjacência, matrizes de adjacência ou listas de arestas, cada uma com suas vantagens e desvantagens em termos de eficiência e uso de memória.

=== Definição e Propriedades dos Grafos
Um grafo é uma forma de representar conexões entre diferentes pontos. Basicamente, ele é composto por dois elementos principais: $G = (V, A)$, onde $V$ é o conjunto de vértices (valores unitários) e $A$ é o conjunto de arestas (ligações ponderadas entre vértices). Em malhas tridimensionais, os vértices podem representar coordenadas espaciais ou células de navegação, enquanto as arestas denotam as transições viáveis entre essas posições. Grafos podem ser representados de diversas formas, como listas de adjacência, matrizes de adjacência ou listas de arestas, cada uma com suas vantagens e desvantagens em termos de eficiência e uso de memória.

As arestas podem ter pesos, que são valores numéricos associados a elas. Esse peso pode indicar o "custo" de percorrer aquela ligação, como a distância física, o tempo gasto, ou a dificuldade de travessia. O conceito de adjacência se refere a vértices que estão diretamente conectados por uma aresta, e um caminho é uma sequência de vértices adjacentes que leva de um ponto inicial a um destino @rodacki_grafos.

=== Grafos Direcionados e Não Direcionados
A natureza das arestas em um grafo define se ele é direcionado ou não direcionado. Em um grafo não direcionado, se existe uma aresta entre dois vértices A e B, significa que o caminho pode ser percorrido tanto de A para B quanto de B para A, com o mesmo custo (ou seja, a aresta (A, B) é idêntica à aresta (B, A)). Pense em uma estrada de mão dupla em um terreno plano.

// TODO(tcc): o trabalho usa SÓ grafos não direcionados com custo simétrico (distância euclidiana 3D; o limite
// de 45° vale nos dois sentidos). Trocar o parágrafo de "rampa assimétrica" (removido) por 1 frase justificando
// essa escolha (rodacki_grafos).

=== Componentes Conexos
// TODO(tcc): definir componente conexo (rodacki_grafos, conferir se cobre). É necessário porque o critério de
// 45° fragmenta o grafo: terrenos em que início e fim ficam em componentes diferentes são descartados
// (statistics.hpp) e o visualizador faz snap no maior componente (largestComponentMask, util.hpp).

== Algoritmos de Busca
// TODO(tcc): apresentar a busca best-first genérica (open list por prioridade f(n), closed list, expansão,
// reconstrução pelo pai) da qual os 4 algoritmos são instâncias; ver a tabela do slide 7 (f(n) e garantia
// de cada um). russell_norvig, astar.


=== Dijkstra
O algoritmo de Dijkstra é um dos métodos mais fundamentais para encontrar o caminho mais curto entre dois vértices em um grafo com arestas de pesos não negativos. Segundo #cite(<rodacki_grafos>, form: "prose"), o algoritmo funciona explorando sistematicamente todos os caminhos possíveis a partir de um vértice inicial, mantendo uma lista de distâncias mínimas conhecidas para cada nó. Ele utiliza uma fila de prioridade para sempre expandir o nó com a menor distância acumulada, garantindo que, ao chegar no destino, o caminho encontrado seja de fato o mais curto. Por sua natureza exaustiva, o Dijkstra é garantidamente ótimo, mas pode ser computacionalmente custoso em grafos muito grandes, pois "olha para todos os lados" antes de decidir a direção final.

== Algoritmos de Busca Heurística

Na área de estudo de grafos, existe uma grande concentração de pesquisas em algoritmos de busca heurística, que são técnicas que utilizam informações adicionais (heurísticas) para guiar a busca por um caminho mais eficiente no grafo. Esses algoritmos são amplamente utilizados em jogos e simulações para encontrar rotas entre pontos em um ambiente tridimensional.

=== Heurísticas
// TODO(tcc): acrescentar heurística consistente (russell_norvig). Como o peso da aresta é a distância
// euclidiana 3D, a heurística euclidiana 3D é consistente (desigualdade triangular), o que permite ao A*
// fechar nós sem reabri-los (search.hpp). Citar dijkstra1959note também na seção do Dijkstra.

Diferente do Dijkstra, que explora o grafo de forma cega, a busca heurística utiliza informações extras para tentar "adivinhar" qual direção é mais promissora. Uma heurística é, essencialmente, uma estimativa do custo restante para chegar ao destino #cite(<astar>). 

Um exemplo clássico é a Distância Euclidiana (a linha reta entre dois pontos). Em um mapa 3D, se soubermos as coordenadas do ponto atual $(x_1, y_1, z_1)$ e do destino $(x_2, y_2, z_2)$, podemos calcular a distância direta entre eles com a fórmula: 

\
$ d = sqrt((x_2 - x_1)^2 + (y_2 - y_1)^2 + (z_2 - z_1)^2) $\

Embora essa distância ignore obstáculos como paredes ou montanhas, ela serve como um guia excelente para o algoritmo priorizar nós que estão fisicamente mais próximos do objetivo, reduzindo drasticamente o número de vértices que precisam ser analisados.

=== A\*
O algoritmo A\* (A-Star) é uma evolução do Dijkstra que incorpora o uso de heurísticas para aumentar a eficiência da busca. Ele avalia cada nó utilizando uma função de custo: 

\
$ f(n) = g(n) + h(n) $
#v(1.5em)
Onde:
- $g(n)$ é o custo real acumulado do ponto de partida até o nó atual $n$.
- $h(n)$ é o valor da heurística (a estimativa do custo de $n$ até o destino).
\
#v(0em)
Ao combinar o progresso real com a estimativa futura, o A\* consegue focar a busca na direção do objetivo, evitando explorar áreas do grafo que claramente não levam ao caminho mais curto #cite(<astar>). Se a heurística utilizada for "admissível" (ou seja, nunca superestimar o custo real), o A\* garante encontrar o caminho ótimo, unindo a precisão do Dijkstra com a velocidade de uma busca direcionada.

=== Weighted A\*
// TODO(tcc): f(n) = g(n) + w·h(n), w > 1 (pohl1970heuristic): menos expansões em troca de custo
// ≤ w·ótimo. Neste trabalho, w = 1,5 (main.cpp). Que a implementação não reabre nós fechados vai no
// Desenvolvimento, como decisão de implementação.

=== Greedy Best-First Search
// TODO(tcc): f(n) = h(n), sem garantia de otimalidade nem de custo (russell_norvig). Contraponto do Dijkstra
// no extremo oposto da tabela do slide 7.

== OpenGL API
// TODO(tcc): fora do foco da pergunta. Manter só o mínimo para justificar o visualizador (malha =
// vértices + índices; learnopengl) ou mover para o Desenvolvimento. VBO/EBO/VAO/máquina de estados: cortar.

O OpenGL#footnote[https://www.opengl.org/] é uma interface de programação de aplicações (API) de gráficos 3D amplamente utilizada para renderização de gráficos em tempo real @learnopengl. Consagrada na indústria para a renderização de gráficos 2D e 3D acelerados por hardware, suas especificações oferecem baixo nível de abstração, permitindo controle direto sobre a GPU, gerenciamento de buffers e programação de shaders.

=== Malhas
As malhas poligonais (ou _meshes_) constituem uma representação geométrica de superfícies em computação gráfica, nas quais a topologia do terreno é descrita por um conjunto de vértices, arestas e faces. Em simulações de navegação, essas malhas definem a superfície transitável sobre a qual as rotas são calculadas.

Cada conjunto de vértices e arestas diferentes são armazenados em _buffers_ denominados VBO (Vertex Buffer Object) e EBO (Element Buffer Object), respectivamente, que são gerenciados pela GPU para renderização eficiente. Cada um desses _buffers_ é associado a um VAO (Vertex Array Object), que encapsula o estado necessário para renderizar a malha, incluindo as ligações dos _buffers_ e as configurações de atributos de vértice.

O gerenciamento eficiente de tais estruturas de dados reduz a necessidade de transferências de dados entre CPU e GPU, mitigando gargalos de barramento. Como o contexto clássico do OpenGL possui restrições inerentes à concorrência multi-thread, a minimização dessas operações é crítica para manter taxas de quadros elevadas.

=== Programação Orientada a Eventos e Funções de Retorno (_Callback_)
Embora o OpenGL seja estritamente focado em tarefas de desenho e renderização, bibliotecas auxiliares como a GLFW realizam a integração com o sistema de janelas do sistema operacional e o processamento de periféricos. Essa abordagem viabiliza um modelo de programação orientada a eventos, no qual _callbacks_ tratam as ações de dispositivos de entrada.

=== A Máquina de Estados e o Contexto OpenGL
Para lidar com a renderização em si, o OpenGL opera como uma vasta máquina de estados. Todas as configurações e referências de dados ficam armazenadas no que é chamado de Contexto OpenGL. Dessa forma, para renderizar uma malha, é necessário configurar o estado da máquina de acordo com as características do objeto — como a vinculação dos _buffers_ VBO e EBO — antes de emitir os comandos de desenho para a GPU. 

Como mudanças excessivas de estado geram alto custo de processamento (_overhead_), o gerenciamento eficiente dos _buffers_ procura minimizar as trocas de estado e agrupar comandos sempre que possível, otimizando o tráfego de dados entre a CPU e a GPU.

// TODO(tcc): subseção "Concorrência e Isolamento de Threads" removida: a concorrência só existe no
// visualizador e é descrita no Desenvolvimento (contexto OpenGL preso à main thread).

== Geração de Cenários de Teste
A geração procedural de terrenos engloba algoritmos para criação automatizada de malhas tridimensionais complexas e variadas, permitindo a geração de cenários sob condições e restrições parametrizadas. A geração procedural é uma técnica utilizada para criar conteúdo de forma automática, utilizando algoritmos que produzem resultados variados e complexos a partir de um conjunto de regras ou parâmetros.

=== Mapas de Altura
// TODO(tcc): heightmap como CONCEITO (matriz N×N de alturas em [0,1], entrada de todas as representações).
// Removidos: a ênfase em imagens baixadas da internet e a figura de Solstheim; o trabalho só usa terreno
// procedural. Se quiser um exemplo visual, usar um heightmap gerado com `tcc save`.

Um mapa de altura nada mais é do que uma representação gráfica de um terreno, onde cada pixel da imagem representa uma coordenada no espaço tridimensional e a intensidade dos valores de cor indica a elevação do terreno naquela coordenada.

Considerando $i$ e $j$ como os índices dos pixels da imagem, $h$ como o valor de intensidade da cor do pixel e $(x, y, z)$ como as coordenadas 3D de cada vértice da malha, é possível atribuir as coordenadas de cada vértice da malha com $(x, y, z) = (i, h, j)$. 

\
#figure(
  caption: [Conversão de um mapa de altura para uma malha 3D],
  supplement: "Figura",
)[
  #image("./images/pixel_to_vertex.svg", width: 90%)
  #v(0.5em)
  #text(size: 10pt)[Fonte: Elaborado pelo autor.]
] <fig_pixel_to_vertex> \

// TODO(tcc): fórmula de altura removida (h = v/255·H, de imagem 8 bits). O código usa o ruído já em [0,1]:
// y = 1 + v·(H − 1), com H = heightScale (util.hpp: createGrid2_5D, terrainHeightAt). No experimento,
// H = N (escala) ou H = 500 (lac/pers), mantendo altura/onda = 2 (slide 12).

// TODO(tcc): removido o parágrafo "faces ligando vizinhos diretos": a malha usada no trabalho vem do
// Marching Cubes sobre o volume de voxels (ver Representações Geométricas), não da triangulação direta do
// heightmap. Avaliar se a figura abaixo ainda serve ou se troca por uma malha do MC (viewer, `tcc test`).

\
#figure(
  caption: [Exemplo de malha gerada a partir de um mapa de altura],
  supplement: "Figura",
)[
  #image("./images/heightmap_to_mesh.png", width: 100%)
  #v(0.5em)
  #text(size: 10pt)[Fonte: Elaborado pelo autor.]
] <fig_heightmap_mesh> \

=== Geração de Ruídos
// TODO(tcc): a motivação deixa de ser "substituir imagens externas" e passa a ser controlar os fatores
// do experimento (escala, lacunaridade, persistência) com seed registrada.

Um ruído é uma função matemática que gera valores pseudoaleatórios, mas de forma controlada, para criar padrões que se assemelham a fenômenos naturais. Existem diversos tipos de ruídos, como o ruído Perlin, o ruído Simplex e o ruído de valor, cada um com suas características e aplicações específicas. Entre as alternativas conhecidas, o ruído de Perlin destaca-se pela sua capacidade de gerar variações contínuas e suaves, mimetizando relevos naturais.

O ruído de Perlin é um algoritmo de geração de ruído gradiente procedural que é amplamente utilizado para criar texturas e terrenos realistas em gráficos 3D. Ele foi desenvolvido por #cite(<perlin1985image>, form: "prose") e é conhecido por produzir padrões de ruído suaves e naturais (Figura @fig_perlin (a)), o que o torna ideal para simular superfícies como montanhas, nuvens e oceanos. Essa característica permite a geração autônoma de mapas de altura parametrizados, eliminando a dependência de fontes externas e viabilizando o controle total sobre as variáveis de inclinação e rugosidade espacial.

Para conseguir um ruído suave e natural, o algoritmo gera diversas camadas de texturas diferentes e as sobrepõe (@fig_perlin) , essas camadas são chamadas de oitavas (_octaves_).
// TODO(tcc): removida a frase dizendo que a interpolação suaviza a transição ENTRE oitavas. Ela atua DENTRO
// de cada oitava, entre os cantos da célula da grade (@sec_interpolacao); as oitavas são apenas somadas.
A combinação de múltiplas oitavas permite criar terrenos com detalhes variados, desde grandes elevações até pequenas variações de altura.

\
#figure(
  caption: [Exemplo de ruído de Perlin e uma de suas oitavas (_octaves_)],
  supplement: "Figura",
)[
  #columns(2)[
    #image("./images/perlin_noise.png", width: 50%) <fig_perlin.a>
    #align(center)[(a) Ruído de Perlin completo.]
    #colbreak()
    #image("./images/octave.png", width: 50%) <fig_perlin.b>
    #align(center)[(b) Uma oitava do ruído de Perlin.]
  ]
  #v(0.5em)
  #text(size: 10pt)[Fonte: Elaborado pelo autor.]
] <fig_perlin> \

Para gerar uma _octave_ do ruído de Perlin, primeiro é necessário criar uma grade de tamanho unitário com vetores de gradiente unitários em cada ponto de interseção da grade, onde cada vetor aponta em uma direção aleatória. O tamanho de cada célula da grade determina o nível de detalhe do ruído, onde células maiores produzem um ruído mais suave, enquanto células menores geram um ruído mais detalhado. 

\
#figure(
  caption: [Ruídos de Perlin com diferentes tamanhos de células],
  supplement: "Figura",
)[
  #columns(3)[
    #image("./images/small_grid.png", width: 100%)
    #align(center)[(a) Ruído gerado com células pequenas.]
    #colbreak()
    #image("./images/medium_grid.png", width: 100%)
    #align(center)[(b) Ruído gerado com células medianas.]
    #colbreak()
    #image("./images/big_grid.png", width: 100%)
    #align(center)[(c) Ruído gerado com células grandes.]
  ]
  #v(0.5em)
  #text(size: 10pt)[Fonte: Elaborado pelo autor.]
] <fig_perlin_grid> \

Para cada ponto no espaço (ou _pixel_), o algoritmo calcula os vetores de distância entre ele e cada ponto de interseção de sua respectiva célula da grade. Em seguida, é calculado o produto escalar entre os vetores de distância $arrow(a) = (a_x, a_y)$ e os vetores de gradiente correspondentes $arrow(b) = (b_x, b_y)$, pela fórmula:

\
$ arrow(a) dot arrow(b) = (a_x * b_x) + (a_y * b_y) $ \

O resultado do produto escalar é um valor numérico que representa a contribuição do vetor de gradiente para o _pixel_ em questão. Por fim, é aplicada uma função de interpolação (@sec_interpolacao), onde cada valor escalar é suavizado para criar uma transição entre o _pixel_ de forma ponderada, ou seja quanto mais próximo o _pixel_ estiver do ponto de interseção, maior será a contribuição do vetor de gradiente para o valor final do ruído.

\
#figure(
  caption: [Cálculo do produto escalar em uma célula do ruído de Perlin],
  supplement: "Figura",
)[
  #columns(2)[
    #image("./images/perlin_vectors.svg", width: 75%)
    #align(center)[(a) Vetores de gradiente e distância.]
    #colbreak()
    #image("./images/perlin_dot.svg", width: 75%)
    #align(center)[(b) Valores escalares (produto escalar).]
  ]
  #v(0.5em)
  #text(size: 10pt)[Fonte: Elaborado pelo autor.]
] <fig_perlin_dot> \

Com uma oitava (_octave_) do ruído de Perlin gerada, é possível sobrepor múltiplas oitavas para criar um ruído mais complexo e detalhado.
// TODO(tcc): removida a frase "frequência (lacunaridade) e amplitude (persistência)", que confundia os conceitos.
// Lacunaridade = fator que MULTIPLICA a frequência a cada oitava; persistência = fator que MULTIPLICA a
// amplitude a cada oitava (slide 8). Frequência e amplitude base são os valores da 1ª oitava (freq = amp = 1).
// No código também entram offset aleatório e seed por oitava (generateNoiseMap, noise_gen.hpp), para que
// as oitavas não sejam correlacionadas.

Conforme #cite(<patel_terrain_noise>, form:"prose") explica, a combinação de múltiplas oitavas com diferentes frequências e amplitudes permite criar terrenos com uma variedade de características, desde grandes elevações até pequenas variações de altura, simulando ambientes naturais de forma realista.

// TODO(tcc): figura antiga ("Frequência 4 e Amplitude 4") removida. Usar a do slide 9: l = 1,5 vs 2,5 e
// p = 0,3 vs 0,7, mesma seed, gerada com `tcc save`. Opcional: oitavas separadas com `--save-octaves`.

// TODO(tcc): fórmulas antigas removidas (f_i = F·2^i, a_i = A·0,5^i, só clamp). Escrever conforme
// generateNoiseMap (noise_gen.hpp):
//   V = Σ_{i<N} pers^i · perlin(x·freq·lac^i / wave + ox_i, y·freq·lac^i / wave + oy_i; seed_i)
//   V ← V / sqrt(Σ (pers^i)^2) · amp  → clamp [−1, 1] → (V + 1)/2 → V^exp → y = 1 + V·(H − 1)
// No experimento: N = 6, freq = amp = exp = 1. A normalização por √Σa² (RMS) é DECISÃO PRÓPRIA (sem fonte no
// bib): com Σa, o desvio do relevo caía ~32% de p = 0,3 a 0,7, misturando persistência com amplitude.
// patel_terrain_noise para oitavas/redistribuição (exp).
// Lacunaridade limitada a 2,25: a última oitava (lac^5 / 250) fica ≤ 0,25 ciclo/unidade, abaixo de Nyquist
// (decisão de projeto, sem fonte no bib).

\
#figure(
  caption: [Exemplo de malha gerada a partir de um ruído de Perlin],
  supplement: "Figura",
)[
  #image("./images/mesh_from_perlin.png", width: 75%)
  #v(0.5em)
  #text(size: 10pt)[Fonte: Elaborado pelo autor.]
] \

==== Função de Interpolação <sec_interpolacao>
// TODO(tcc): removida a frase de abertura que dizia que a interpolação suaviza a transição entre CAMADAS
// (oitavas). Ela suaviza dentro da célula, entre as contribuições dos cantos.

A função de interpolação utilizada no ruído de Perlin é conhecida como função de suavização. #cite(<zipped_perlin_noise>, form:"prose") ressalta que a interpolação linear simples não é adequada de forma isolada para gerar padrões naturais, pois deixa transições abruptas entre os valores de ruído, resultando em um terreno com bordas visíveis entre as células da grade.

Para solucionar esse problema e garantir uma transição orgânica, emprega-se uma curva de atenuação (ou função _fade_).

// TODO(tcc): smoothstep 3w²−2w³ e o gráfico dela removidos: o código usa a QUÍNTICA
// S(w) = 6w⁵ − 15w⁴ + 10w³ (interpolate, noise_gen.hpp:63). Explicar que a 1ª e a 2ª derivadas se anulam em
// w = 0 e w = 1 (continuidade também da curvatura entre células) e refazer a figura para a quíntica.
// NÃO atribuir a quíntica a perlin1985image (que é a versão original); citar zipped_perlin_noise só se o
// tutorial usar a quíntica (conferir); caso contrário, apresentar sem citação.

Após obter o peso suavizado $S(w)$, o algoritmo realiza a interpolação linear padrão entre os valores de contribuição escalar $a_0$ e $a_1$ calculados:

\
$ f(a_0, a_1, w) = a_0 + (a_1 - a_0) dot S(w) $ \

// TODO(tcc): seção "Ruídos 3D" removida: noise3D existe no código mas não entra no pipeline experimental.

== Representações Geométricas
// TODO(tcc): 1 parágrafo ligando heightmap → volume → malha. Malha = vértices, arestas, faces (learnopengl).

=== Voxels
// TODO(tcc): voxel como célula de um volume regular; aqui o volume é BINÁRIO e derivado do heightmap: o voxel
// (x, y, z) está cheio se y < altura da coluna (x, z) (getMarchingCubeData, util.hpp). Volume N × H × N.
// lengyel_transvoxel (terrenos em voxels em tempo real); johansson2024adapting (voxels em pathfinding).

=== Marching Cubes
// TODO(tcc): extração de superfície por casos de configuração dos 8 cantos de cada célula
// (lorensen_cline_marching_cubes). O código usa as tabelas "regular cell" do Transvoxel (lengyel_transvoxel).
// Detalhes que importam para a navegação: vértice sobre a aresta da célula sem interpolação (campo binário);
// vértices compartilhados por uma chave em coordenadas dobradas (malha indexada, sem duplicatas); a malha tem
// faces de parede (degraus), que o critério de 45° descarta na construção dos grafos.

== Representações Navegáveis
// TODO(tcc): abrir com a divisão do slide 10: 2 representações a partir do heightmap e 2 a partir da malha.
// Para CADA uma: o que é o nó, vizinhança, peso, |V| e |E| esperados e uma figura (slide 10).
// Regras comuns: grafo não direcionado; peso = distância euclidiana 3D; aresta descartada se
// |Δy| / distância horizontal > 1 (45°) ou distância horizontal = 0 (isTraversable, util.hpp).
// algfoor_pathfinding_survey para situar as famílias (grades, malhas de navegação).

=== Grade Regular 2.5D
// TODO(tcc): createGrid2_5D: 1 nó por amostra do heightmap com y contínuo; vizinhança-8; |V| = N²,
// |E| ≤ ~4N². "2.5D": uma altura por (x, z), sem sobreposição. sturtevant_grid_benchmarks (grade octil).

=== Superfície Voxel
// TODO(tcc): createVoxelGraph: topo de cada coluna de voxels, y ARREDONDADO para inteiro; vizinhança-4
// (adjacência por face); |V| = N², |E| ≤ ~2N². É a superfície caminhável do mesmo volume do MC, não um grafo
// volumétrico 3D. Consequência: degraus discretos e caminhos mais longos (~19% vs 2.5D, ver Metodologia).

=== Grafo de Vértices
// TODO(tcc): createVertexToVertex: nós = vértices da malha do MC; arestas = lados dos triângulos, sem
// duplicatas. Os vértices ficam nas arestas das células, ou seja, fora da superfície do heightmap (relevante
// para o comprimento geométrico).

=== Grafo de Polígonos
// TODO(tcc): createPolygonToPolygon: grafo DUAL; nó = centroide de cada triângulo; aresta entre triângulos que
// compartilham um lado (chave pelas posições exatas dos vértices); peso = distância entre centroides.
// Relacionar com malhas de navegação: snook_navmesh, demyen_buro_triangulation, navigation_mesh.

== Análise Estatística
// TODO(tcc): completar: (1) pressupostos (normalidade dos resíduos e homogeneidade de variâncias), nomeando
// testes específicos só se jurandir/jain1991art os cobrirem; (2) fatores: algoritmo × representação × nível do
// fator de terreno; α = 0,05 (slide 13); (3) observações NÃO independentes (mesmo terreno/par para os 4
// algoritmos): bloco ou agregação por terreno (jain1991art, conferir). Escrever "Tukey" (o slide 13 diz "Tuckey").

O modelo ANOVA (_Analysis of Variance_) é uma técnica estatística utilizada para comparar as médias de diferentes grupos e determinar se existem diferenças significativas entre eles. Com base na literatura #cite(<jurandir>, form: "prose"), o ANOVA é particularmente útil quando se deseja avaliar o impacto de diferentes fatores em uma variável dependente, permitindo identificar quais fatores têm efeito significativo sobre os resultados.

Para confirmar o nível de influência de cada fator, usa-se o teste de Tukey, que é um método de comparação múltipla que permite identificar quais grupos diferem significativamente entre si. O teste de Tukey é aplicado após a realização do ANOVA para fornecer uma análise detalhada das diferenças entre os grupos.

= TRABALHOS RELACIONADOS

Este capítulo apresenta uma análise comparativa detalhada entre a proposta deste trabalho  e os principais estudos correlatos da literatura recente que realizam análises estatísticas e _benchmarks_ (avaliações de desempenho) de algoritmos de _pathfinding_.

== Johansson (2024)
No trabalho intitulado _Adapting Pathfinding Algorithms for 3D Environments: Performance Analysis and Real-World Applications_, #cite(<johansson2024adapting>, form: "prose") realiza uma avaliação de desempenho em termos de tempo de execução e consumo de memória dos algoritmos Dijkstra e A\* (utilizando as heurísticas Euclidiana e Manhattan) adaptados para ambientes tridimensionais.

// TODO(tcc): limitação + diferencial (lista removida, que falava de Theta*/JPS e malhas "contínuas"):
// Johansson avalia UMA representação (voxels). Aqui, o mesmo terreno vira 4 representações e a representação é
// fator experimental; algoritmos em comum: Dijkstra e A*, com euclidiana 3D. NÃO usar "execução sequencial"
// como limitação: as medições deste trabalho também são sequenciais.

== Kapi (2022)
O artigo _A Comparison of Pathfinding Algorithm for Code Optimization on Grid Maps_, publicado na IJACSA #cite(<Kapi2022>), realiza uma comparação estatística direta (tempo de CPU em microssegundos e contagem de nós expandidos) entre a trindade clássica de busca: A\*, JPS e Theta\*.

// TODO(tcc): limitação + diferencial (lista removida, que falava de jthread/concorrência/smart pointers):
// Kapi usa grades 2D planas e uma representação. Diferencial: terreno 3D procedural com fatores controlados
// (escala, lacunaridade, persistência), 4 representações e ANOVA. Métricas em comum: tempo e nós expandidos.
// sturtevant_grid_benchmarks pode entrar como referência de metodologia em grades.

== Matriz de Diferenciação Técnica
// TODO(tcc): refazer a tabela (a antiga listava JPS/Theta*/LazyTheta*/multi-threaded). Linhas sugeridas:
// representação(ões) | algoritmos | origem do terreno | fatores variados | métricas | análise estatística.
// Colunas: Proposta, johansson2024adapting, Kapi2022.

= PROJETO E ARQUITETURA DO SISTEMA
Este capítulo apresenta o projeto técnico desenvolvido para viabilizar a pesquisa: a concepção estrutural, a arquitetura das bibliotecas e os componentes de software utilizados na execução dos experimentos. Nesta parte, o foco não está no método científico de avaliação, mas no artefato computacional construído para que os testes possam ser realizados de forma controlada, reproduzível e mensurável.

A separação entre projeto e metodologia é importante para evitar ambiguidade conceitual. O projeto corresponde à solução de engenharia implementada — motor de renderização gráfica (IFCG), biblioteca de grafos, estruturas de dados, algoritmos e escalonador de tarefas concorrentes (`TaskMaster`). Já a metodologia, apresentada no capítulo seguinte, define como esse artefato será usado para produzir evidências científicas: quais variáveis serão controladas, quais métricas serão coletadas, quais hipóteses serão testadas e quais procedimentos estatísticos serão aplicados.

Dessa forma, a infraestrutura própria em C++20 é tratada como instrumento experimental. Sua função é garantir controle sobre as variáveis de desempenho, reduzir interferências externas e permitir que os resultados obtidos sejam atribuídos aos algoritmos e aos parâmetros dos cenários, e não a componentes opacos de terceiros.

// TODO(tcc): abrir o capítulo com o pipeline do slide 11 (Perlin → heightmap → grade 2.5D/voxel; heightmap →
// MC → grafo de vértices/dual → algoritmos → métricas). O parágrafo acima cita o TaskMaster como parte do
// projeto: ok, mas deixar claro que ele só serve ao visualizador.

== Arquitetura do Motor Gráfico (IFCG)
// TODO(tcc): seção longa demais para o foco atual. Resumir e justificar o motor próprio pela tabela do
// slide 6 (representação controlável, coleta isolada da renderização, mesmos algoritmos sobre o mesmo grafo).
// O motor serve à visualização e à validação dos caminhos (`tcc test`); as medições ficam fora do laço de
// renderização.

O motor gráfico desenvolvido para este estudo, denominado IFCG#footnote[Disponível em: #link("https://github.com/andrevbastos/ifcg")] (Instituto Federal Catarinense/Computação Gráfica), foi projetado para ser uma plataforma de renderização flexível para a implementação e avaliação dos algoritmos de _pathfinding_. A arquitetura do IFCG foi cuidadosamente planejada para garantir que os testes sejam realizados em um ambiente gráfico realista, mas simples, permitindo a coleta de dados precisos sobre o desempenho dos algoritmos em cenários tridimensionais complexos.

Ele é composto por diversos módulos, cada um responsável por uma parte específica do processo de renderização e gerenciamento de recursos gráficos. A seguir, serão detalhados os principais componentes da arquitetura do motor gráfico e como eles se relacionam para criar um ambiente de teste eficiente para os algoritmos de _pathfinding_.

=== Aplicação de Conceitos de Projeto de Software

Para lidar com a complexidade inerente à renderização gráfica e ao gerenciamento de recursos, a arquitetura do IFCG foi projetada utilizando princípios de design de software e padrões de projeto. A aplicação desses conceitos pertence ao escopo do projeto técnico: seu papel é organizar o artefato computacional, reduzir acoplamento, favorecer manutenção e tornar o ambiente experimental estável. Assim, esses conceitos não são apresentados como metodologia científica em si, mas como decisões de engenharia que dão suporte à execução metodológica dos experimentos.

Como o coração do motor foi desenvolvida uma classe `Engine`, que é responsável por gerenciar o ciclo de renderização, as chamadas ao OpenGL e a interação com a janela. Essa classe encapsula toda a lógica do ciclo de renderização e fornece uma interface simples para a criação de cenários de teste, permitindo que os algoritmos de _pathfinding_ sejam avaliados em diferentes condições e configurações.

O padrão _Singleton_ foi aplicado na criação de instâncias do `Engine`, garantindo um controle centralizado sobre os recursos gráficos e a renderização. Isso evita conflitos e mantém a consistência do ambiente de renderização, permitindo que diferentes partes do sistema acessem o motor gráfico de forma segura e coordenada.

Seguindo os conceitos de #cite(<learnopengl>, form: "prose"), foi desenvolvido uma classe `Mesh`, que representa uma malha 3D e encapsula os dados necessários para renderizá-la, como vértices, normais, coordenadas de textura e índices. Essa classe também gerencia os _buffers_ VBO, EBO e VAO, garantindo que a malha seja renderizada de forma eficiente e correta.

A classe `Shader` @learnopengl foi implementada para gerenciar os programas de sombreamento (shaders) utilizados na renderização das malhas. Ela encapsula a criação, compilação e vinculação dos shaders. Essa classe permite a leitura de arquivos de extensão `glsl`, que contêm o código dos shaders, e fornece métodos para definir uniformes e atributos de vértice, facilitando a personalização da aparência das malhas renderizadas.

=== Componentes do Motor Gráfico

Para organizar a arquitetura do motor gráfico, foram definidos diversos módulos, cada um responsável por uma parte específica do processo de renderização e gerenciamento de recursos gráficos. A seguir, serão detalhados os principais componentes da arquitetura do motor gráfico e como eles se relacionam para criar um ambiente de teste eficiente para os algoritmos de _pathfinding_.

+ Window: Essa classe atua como um adaptador (_wrapper_) para a biblioteca GLFW, responsável por criar e gerenciar a janela de renderização. Ela encapsula a criação do contexto OpenGL, o gerenciamento de eventos de entrada (como teclado e mouse) e a configuração das propriedades da janela, como tamanho, título e modo de exibição.

+ Renderer: Essa classe é responsável por gerenciar o ciclo de renderização, incluindo a configuração do estado do OpenGL, a vinculação dos _buffers_ e a emissão dos comandos de desenho. Ela também gerencia a ordem de renderização das malhas, garantindo que os objetos sejam desenhados na ordem correta e com as propriedades visuais desejadas.

+ Input: Essa classe é responsável por gerenciar a entrada do usuário, processando eventos de teclado e mouse. Ela fornece métodos para adicionar funções de retorno (_callbacks_) personalizadas, permitindo que a aplicação reaja a eventos de entrada de forma flexível e eficiente.

=== Gerenciamento de Recursos e Renderização

O padrão _Composite_ @gamma1994design foi utilizado para representar a hierarquia de objetos na infraestrutura gráfica, onde uma malha complexa pode ser composta por várias sub-malhas, e cada sub-malha pode ser tratada da mesma forma. Toda base de malha (_MeshBase_) contém sua própria matriz de modelo, que é responsável por armazenar as transformações de posição, rotação e escala da malha. Então as classes de malha (_Mesh_) e malha composta (_MeshTree_) herdam dessa base, permitindo que sejam tratadas de forma uniforme, independentemente de serem malhas simples ou compostas.

\
#figure(
  caption: [Diagrama de classe do padrão Composite aplicado à hierarquia de malhas],
  supplement: "Figura",
)[
  #image("./images/mesh_composite.png", width: 100%)
  #v(0.5em)
  #text(size: 10pt)[Fonte: Elaborado pelo autor.]
] \

Com essa arquitetura, o motor de renderização pode desenhar tanto malhas simples quanto compostas utilizando a mesma interface. Assim, permitindo criar cenários complexos com complexidade reduzida e mantendo a flexibilidade para adicionar novos tipos de malhas ou componentes gráficos no futuro.

Isso permite que o `Renderer` seja capaz de percorrer a hierarquia de malhas e renderizar cada uma delas de forma eficiente, aplicando as transformações apropriadas e garantindo que a cena seja exibida corretamente na janela de renderização. 

Uma fila de malhas é mantida pelo `Renderer`, permitindo que as malhas sejam adicionadas e removidas dinamicamente durante a execução do programa. Essa fila é processada a cada ciclo de renderização, garantindo que todas as malhas sejam desenhadas na ordem correta e com as propriedades visuais desejadas.

Para gerenciar a renderização foi desenvolvido um sistema de laço (_loop_) de renderização ajustado a partir de configurações pré-definidas. Isso é, foi desenvolvida uma `struct` `LoopConfig` que contém parâmetros como taxa de atualização desejada, limites de tempo de renderização e opções de funções `lambda` para serem executadas em momentos diferentes do ciclo de renderização. O `Renderer` utiliza essas configurações para controlar o fluxo do motor flexivelmente.

== Estrutura de Grafos

Foi implementada uma biblioteca de grafos em C++ para representar os caminhos possíveis dentro do ambiente tridimensional. O objetivo desta seção é detalhar a implementação da estrutura de grafos e seus algoritmos.

=== Representação de Grafos Direcionados e Não Direcionados
A biblioteca de grafos desenvolvida neste projeto #footnote[Disponível em: #link("https://github.com/andrevbastos/graph")] foi criada com duas estruturas de dados diferentes para permitir flexibilidade e desempenho: uma orientada a objetos clássica e outra focada em alto desempenho baseada em vetores contíguos na memória.

// TODO(tcc): o § detalhado da estrutura OOP (common::Graph/Node/Edge) foi removido: ela não é usada no
// experimento. Citar em 1 frase e focar na lwGraph.

Para resolver esse problema de lentidão, foi criada uma segunda estrutura chamada de representação leve (_lightweight_), implementada na classe _template_ `common::lwGraph<T>` e suas versões direcionada (`directed::lwGraph<T>`) e não direcionada (`undirected::lwGraph<T>`). Essa estrutura armazena os dados dos nós em um vetor contínuo na memória (`std::vector<T>`) e a lista de adjacências de forma simplificada em um vetor de vetores (`std::vector<std::vector<lwEdge>>`), onde cada aresta guarda apenas o número do nó de destino e o peso. Colocar os dados juntos de forma linear na memória melhora a localidade de cache, fazendo com que o acesso aos vizinhos de um nó seja muito mais rápido.

// TODO(tcc): ajustar o "Para resolver esse problema" acima, que dependia do § removido. Removidas: a frase sobre
// leitura concorrente no TaskMaster (o experimento não busca em paralelo; só o viewer compartilha o grafo
// via shared_ptr) e a lwGrid/JPS. Mencionar que todas as representações usam
// NavigationGraph = undirected::lwGraph<Vertex3D> (util.hpp), o que garante o mesmo grafo-base para todos.

=== Algoritmos de Pathfinding
// TODO(tcc): removidos lwAStar (Dijkstra como A* com h = 0), lwAStarMod, Theta*, JPS, smoothing e o heap
// pair<double,int>; nada disso está no pipeline. Descrever search.hpp:
// - 4 funções independentes de mesma estrutura (dijkstra, aStar, weightedAStar(w = 1,5), greedyBestFirst);
//   Dijkstra NÃO é mais A* com h = 0;
// - open list = priority_queue min-heap de tuplas (f, h, id): empate desfeito pelo menor h;
// - lazy deletion: duplicatas no heap, descartadas ao sair se o nó já está fechado; sem reabertura;
// - GBFS insere cada nó uma única vez e só atualiza o pai/g (g serve só para medir o custo real);
// - contadores expanded, generated, peakOpen e a estimativa peakBytes (searchBytes);
// - heurística euclidiana 3D comum aos três algoritmos informados (statistics.hpp/main.cpp).

=== Construção das Representações
// TODO(tcc): GraphModel/GraphFactory (main.cpp): nome, requiresGeometry (vertex/dual precisam da malha do MC)
// e a função que cria o grafo; isTraversable e MAX_SLOPE (util.hpp) como critério único. Referenciar as
// funções create* descritas na Fundamentação.

=== Gerador de Terreno e Instrumentação
// TODO(tcc): noise_gen.hpp + CLI11 (subcomandos test/save/stats; save --save-octaves gera as figuras).
// statistics.hpp: Results/Statistics; o CSV traz só as métricas da defesa e os diagnósticos ([refeito]) vão
// para o stderr. acquire.sh orquestra as execuções (detalhado na Metodologia).

== Arquitetura Concorrente e Multithreading
// TODO(tcc): deixar explícito que a concorrência existe SÓ no visualizador (`tcc test`). Cadeia em main.cpp com
// Engine::runAsyncThenMain: geometria/MC (High) → grafo + snap no maior componente (Medium) → 1 tarefa por
// algoritmo (Medium) → criação das Mesh na main thread. A coleta (`tcc stats`) é sequencial, em uma thread.
// williams2019c++, ladeira. Resumir TaskMaster/drawWorkers.

Durante a execução de simulações em tempo real, o motor gráfico IFCG precisa manter a taxa de quadros por segundo (FPS) estável. Para isso, foi implementado um sistema de concorrência#footnote[Disponível em: #link("https://github.com/andrevbastos/pad")] que permite que tarefas como geração de ruído, processamento de mapas de altura e extração do grafo de adjacência sejam realizadas em _threads_ separadas, sem interferir na renderização principal.

=== Adaptação para Ambientes de Renderização
Para viabilizar a execução de simulações interativas sem prejuízo à taxa de quadros e à fluidez visual, o sistema de concorrência foi adaptado para contornar as limitações de acesso do OpenGL. O motor gráfico IFCG opera sob estrição de contexto gráfico de _thread_ única, no qual o contexto de renderização é vinculado a uma única _thread_ ativa (_thread_ principal). Qualquer tentativa de invocar funções do OpenGL ou manipular estruturas de dados de GPU (tais como _VAOs_ e _VBOs_) a partir de _threads_ secundárias resulta em comportamento indefinido ou no encerramento abrupto do programa por violações de acesso à memória (erros `SIGSEGV`).

A adaptação implementada realiza um desacoplamento completo entre o fluxo de renderização e quaisquer tarefas secundárias. A geração de ruído, o processamento de mapas de altura e a extração do grafo de adjacência são executados de maneira puramente assíncrona. Essas tarefas não possuem dependências ou chamadas diretas ao OpenGL. Uma vez que o processamento do terreno e a extração do grafo são concluídos, os dados são sincronizados com a _thread_ principal. Esta se encarrega de efetuar as chamadas de alocação e atualização de _buffers_ na GPU dentro do ciclo síncrono de renderização, garantindo a integridade do contexto OpenGL e mantendo estável a taxa de quadros por segundo da visualização tridimensional.

=== Escalonador TaskMaster e Filas Multinível
A orquestração das tarefas em segundo plano é gerenciada pela classe `TaskMaster`, desenvolvida como um escalonador de tarefas concorrente baseado em filas de prioridade multinível (`High`, `Medium` e `Low`) e um _thread pool_ dinâmico. O construtor do `TaskMaster` consulta a capacidade física do processador por meio de `std::thread::hardware_concurrency()`, instanciando $N-1$ _threads_ operárias (onde $N$ é o total de núcleos lógicos disponíveis) para resguardar a capacidade de processamento da _thread_ principal e evitar travamentos na interface gráfica do usuário. As _threads_ operárias são implementadas como objetos `std::jthread` (introduzidos no padrão C++20), que utilizam o comportamento RAII para garantir que sejam finalizadas corretamente na destruição do escalonador.

\
#figure(
  caption: [Diagrama de classes da arquitetura do TaskMaster],
  supplement: "Figura",
)[
  #image("./images/task_master.png", width: 100%)
]\

O método `addTask` é o ponto de entrada para a submissão de tarefas concorrentes. Utilizando modelos de programação (_templates_) e metaprogramação em tempo de compilação (`if constexpr`), juntamente com o traço de tipo `std::is_invocable_v`, o método diferencia funções que aceitam um `std::stop_token` daquelas que não requerem controle de cancelamento, envolvendo estas últimas em um adaptador (_wrapper_). Isso confere flexibilidade ao sistema, permitindo que tarefas de longa duração verifiquem periodicamente se uma interrupção foi solicitada, enquanto tarefas curtas e simples podem ser executadas sem essa complexidade adicional.

Cada _thread_ operária executa um laço contínuo que aguarda por novas tarefas utilizando uma `std::condition_variable_any`. A lógica de seleção de tarefas prioriza sempre as filas de maior importância: o trabalhador verifica sequencialmente as filas 0 (`High`), 1 (`Medium`) e 2 (`Low`), extraindo a primeira tarefa disponível na fila de maior prioridade encontrada. Mesmo que um _lock_ tenha sido adquirido por meio de `std::unique_lock<std::mutex>`, a função `wait` da variável condicional libera o _lock_ enquanto a _thread_ está bloqueada, permitindo que a _main thread_ adicione novas tarefas concorrentes sem contenção desnecessária. Quando a _thread_ operária é acordada, o _lock_ é automaticamente re-adquirido para a extração segura da tarefa.

Para monitoramento e testes de estresse do _thread pool_, o `TaskMaster` incorpora a função de escrita `drawWorkers()`. Protegida por um semáforo de exclusão mútua (`printMtx`), ela atualiza e imprime no console o estado de cada _thread_ trabalhadora (usando os caracteres `H`, `M`, `L` e `-` para representar atividades de alta, média, baixa prioridade ou ociosidade, respectivamente), oferecendo _feedback_ visual instantâneo e contínuo durante a execução em lote das simulações.

=== Controle de Recursos do Sistema Operacional
Para garantir que a execução paralela não comprometa a estabilidade do sistema ou a fluidez da interface gráfica, a arquitetura adota estratégias rigorosas de controle de recursos em nível de software e hardware. Ao limitar o _pool_ de trabalhadores ao total de núcleos físicos menos um ($N-1$), reduz-se o custo de trocas de contexto (_context switching_) e a disputa por cache L3 entre as _threads_ operárias e o motor de renderização. Além disso, o suporte ao cancelamento cooperativo via `std::stop_token` permite interromper de forma imediata tarefas obsoletas, evitando o desperdício de ciclos de CPU em processamentos desnecessários.

// TODO(tcc): removido o § de afinidade de CPU (pinThreadToCore/pthread_setaffinity_np, busca isolada no
// núcleo 2): não existe no código atual. Atenção: N−1 é sobre núcleos LÓGICOS (hardware_concurrency), não
// físicos como diz o § acima; corrigir.

= METODOLOGIA EXPERIMENTAL
Este capítulo detalha os procedimentos metodológicos adotados para a realização da pesquisa, explicando como os algoritmos de _pathfinding_ serão avaliados, como os dados serão coletados e como os resultados serão analisados estatisticamente. Diferentemente do capítulo de projeto, que descreve a arquitetura do sistema construído, este capítulo define o desenho científico do estudo: o tipo de pesquisa, as variáveis envolvidas, as hipóteses, os procedimentos de coleta, os controles experimentais e os métodos de análise.

O estudo caracteriza-se como uma pesquisa experimental, aplicada e de abordagem quantitativa. É experimental porque manipula deliberadamente fatores como algoritmo, escala da malha, lacunaridade e persistência do terreno para observar seus efeitos sobre métricas de desempenho. É aplicada porque busca produzir conhecimento útil para a escolha de algoritmos de navegação em ambientes tridimensionais. É quantitativa porque se baseia em medições numéricas, repetição de testes, comparação estatística entre grupos e interpretação objetiva dos resultados.
// TODO(tcc): incluir a REPRESENTAÇÃO NAVEGÁVEL entre os fatores manipulados no § acima.

== Caracterização Científica da Pesquisa
O caráter científico deste trabalho decorre da formulação de um problema investigável, da definição de hipóteses testáveis, do controle de variáveis, da repetição dos experimentos e da aplicação de técnicas estatísticas para sustentar as conclusões. A proposta não se limita à implementação de algoritmos ou à construção de um motor gráfico; tais elementos constituem o instrumento de pesquisa. A contribuição científica está na avaliação sistemática do comportamento dos algoritmos sob condições parametrizadas e reproduzíveis.

// TODO(tcc): pergunta antiga ("malhas 3D acidentadas ... carga concorrente") removida. Repetir a pergunta do
// slide 4 (representação navegável + características do terreno → tempo e qualidade dos caminhos).

== Hipóteses e Variáveis do Estudo
// TODO(tcc): reescrever H0/H1 cobrindo os 3 fatores (algoritmo, representação, nível do fator de terreno) e as
// interações, não só "entre algoritmos". Ex.: H0 = sem efeito de representação sobre a métrica X.

// TODO(tcc): variáveis independentes (lista antiga com A* modificado/JPS/Theta* removida), conforme slide 12:
// - resolução N×N: 500 a 800, passo 100 (H = N, wave = N/2);
// - lacunaridade: 1,5 / 1,75 / 2,0 / 2,25 (código; o slide 12 diz 2,5, corrigir o slide);
// - persistência: 0,3 / 0,433 / 0,567 / 0,7;
// - representação: grade 2.5D, superfície voxel, grafo de vértices, grafo dual;
// - algoritmo: Dijkstra, A*, WA*, GBFS.
// Cada fator de terreno varia isolado, com os demais fixos (N = 500, lac = 2, pers = 0,5, wave = 250, H = 500).
// Fatores, níveis e replicações: jain1991art.

// TODO(tcc): variáveis dependentes (lista antiga com FPS/cache removida), conforme slide 12 e CSV
// (statistics.hpp):
// - grafo: tempo de construção, |V|, |E|, memória;
// - busca: tempo, nós expandidos, nós gerados, pico da open list, memória estimada;
// - caminho: custo, nº de nós, comprimento geométrico.
// Variáveis de resposta da ANOVA (slide 13): tempo, nós expandidos, custo relativo.

// TODO(tcc): variáveis controladas (slide 12): 6 oitavas, altura/onda = 2, inclinação máx. 45°, 10 pares por
// terreno, heurística euclidiana 3D, WA* w = 1,5, seed registrada, build Release. Tirar "política de energia" e
// "afinidade de processador" se não forem de fato aplicadas (o acquire.sh não faz isso hoje).

== Geração e Processamento dos Cenários de Teste
// TODO(tcc): removidos: a importação de heightmaps por imagem (stb_image), o "fator global de intensidade"
// e o critério heightLimit |z2 − z1|. Descrever o fluxo por terreno, conforme statistics.hpp:
// generateNoiseMap → (vertex/dual: getMarchingCubeData) → graphModel.create, com o tempo medido SÓ nesta
// chamada; o MC fica fora → countEdges/graphMemoryBytes. Critério de aresta: isTraversable (45°).
// Remover também a menção a Theta*/JPS/"linhas de visão" ao descrever lacunaridade e persistência.

=== Procedimento por Terreno
// TODO(tcc): seeds: mt19937(seed base) → seed de cada terreno → pares (generateQueryPairs, seed ^ 0x9E3779B9).
// 10 pares por terreno com início na borda z = 0 e fim na borda z = N−1 (x sorteado); snap ao vértice mais
// próximo em todo o grafo (nearestVertex). Os 4 algoritmos rodam sobre o mesmo grafo e o mesmo par. Se algum
// não encontra caminho, o terreno inteiro é descartado e outro é sorteado ([refeito] no stderr).
// ATENÇÃO: o TODO antigo dizia "snap no maior componente", mas o stats usa todo o grafo; definir e documentar.

=== Definição das Métricas
// TODO(tcc): definições próprias (sem citação):
// - custo: soma dos pesos no próprio grafo; NÃO é comparável entre representações;
// - custo relativo: custo ÷ custo do Dijkstra, na mesma representação e no mesmo par (slide 13);
// - comprimento geométrico: caminho projetado em (x, z) sobre a superfície de referência do heightmap
//   (interpolação bilinear, subpassos ≤ 0,25; surfacePathLength); comparável entre representações;
// - memória do grafo: estrutura pronta via capacity (graphMemoryBytes);
// - memória da busca: estimativa analítica de gScore + cameFrom + closed + pico da open list (searchBytes);
// - tempo da busca: steady_clock só em volta da chamada do algoritmo.

== Desenho Experimental e Coleta de Dados
A coleta de dados foi projetada para avaliar o impacto computacional dos algoritmos em terrenos de complexidade variável. Os testes serão conduzidos em um ambiente controlado#footnote[Disponível em: #link("https://github.com/andrevbastos/tcc")], com o objetivo de minimizar interferências externas e garantir a confiabilidade dos resultados. A seguir, são detalhados o ambiente de teste, a configuração dos testes e as métricas coletadas.

=== Ambiente de Teste
O processo de coleta será conduzido em um computador pessoal com processador Intel Core i5-1235U de 12ª geração. Esse processador possui uma arquitetura híbrida contendo 10 núcleos físicos (2 núcleos de alta performance e 8 núcleos de alta eficiência), totalizando 12 _threads_ lógicas de execução, frequência de clock máxima de 4,40 GHz e 12 MB de memória cache. O sistema possui 16 GB de memória RAM DDR4 operando a 3200 MHz em canal duplo (_dual-channel_). A renderização das malhas 3D e a rasterização do motor gráfico serão processadas por uma GPU integrada Intel Iris Xe Graphics, com frequência dinâmica máxima de 1,20 GHz.

// TODO(tcc): conferir as versões reais na máquina da coleta (kernel, GCC, GLFW, GLM) e registrá-las. O governor
// `performance` só deve ser citado se for de fato configurado antes da coleta (o acquire.sh não faz isso).
// Mencionar a CPU híbrida (P/E-cores) como ameaça, já que não há afinidade fixada.

Em termos de software, os _benchmarks_ serão realizados sob o sistema operacional Arch Linux, utilizando o _Kernel_ estável 6.15.9. Para reduzir perturbações externas nos testes de desempenho, o agendador de energia do processador será configurado manualmente para o modo de desempenho máximo (`performance`), mantendo os _clocks_ elevados e estáveis. O código-fonte será desenvolvido no padrão C++20 e compilado com o GNU Compiler Collection (GCC) versão 14.1.

A renderização gráfica será programada sobre a especificação do OpenGL versão 4.6 (_Core Profile_), usando a biblioteca GLFW 3.4 para o controle de janelas e contexto gráfico, e a biblioteca GLM 1.0.3 para o processamento algébrico de matrizes e vetores tridimensionais.

=== Configuração dos Testes e Métricas Coletadas
// TODO(tcc): lista antiga (FPS, cache, tempo de geração de mapas) removida; as métricas estão definidas em
// "Definição das Métricas". Aqui, só a configuração da rodada: STEPS = 4 níveis por fator, RUNS = 10 execuções
// × REPS = 10 terrenos = 100 terrenos por nível (o slide 12 diz 10; alinhar), 10 pares por terreno,
// 4 algoritmos, 4 representações.

=== Procedimentos Estatísticos
Após a coleta, os dados serão organizados em uma base tabular contendo, para cada execução, os valores das variáveis independentes, a semente de geração do cenário, o algoritmo executado e as métricas resultantes. Cada configuração experimental deverá ser repetida múltiplas vezes, permitindo estimar variabilidade, reduzir efeitos aleatórios e calcular medidas descritivas como média, mediana, desvio-padrão e intervalo de confiança.

A comparação entre algoritmos será realizada por meio de ANOVA quando os pressupostos de normalidade e homogeneidade de variâncias forem atendidos. Quando forem identificadas diferenças significativas entre grupos, será aplicado o teste de Tukey para comparação múltipla, permitindo indicar quais algoritmos diferem entre si.
// TODO(tcc): frase sobre Kruskal-Wallis removida (sem fonte no bib); recolocar só se jurandir ou jain1991art a
// cobrirem. Ampliar: a comparação é entre algoritmos E representações E níveis (com interações), não só entre
// algoritmos; as observações do mesmo terreno/par não são independentes (bloco ou agregação por terreno).

Além da significância estatística, serão observados o tamanho do efeito e a relevância prática dos resultados. Dessa forma, evita-se concluir apenas que uma diferença é estatisticamente detectável; busca-se verificar se essa diferença é suficientemente relevante para orientar decisões de projeto em aplicações reais de navegação 3D.

=== Execução dos Testes e Registro dos Resultados
// TODO(tcc): removidos a aquisição paralela via TaskMaster (prioridades High/Medium/Low, PNG em Low,
// condition_variable por lote) e o script de afinidade; nada disso existe. Descrever o acquire.sh:
// build Release; RUNS execuções de `tcc stats <teste> <grafo> REPS STEPS --seed <aleatória>`, cada uma em um
// processo separado e com pasta própria; 60 s de arrefecimento entre execuções; manifest.csv (run, seed,
// início, duração, exit code) + stdout/stderr por execução. Busca sequencial em uma thread, sem renderização.
// lilja2000measuring (repetições, controle de interferências).

== Critérios de Validade e Reprodutibilidade
// TODO(tcc): o § abaixo cita "isolamento de threads" e "fixação de parâmetros do SO": manter só o que for
// realmente feito. Acrescentar as ameaças à validade (lilja2000measuring, jain1991art):
// - descarte de terrenos = viés de seleção (pior em vertex/dual, onde paredes criam ilhas); reportar nº de [refeito];
// - snap pode deslocar o ponto em até ~9 unidades em terreno íngreme;
// - tempo de busca inclui a inicialização O(|V|) dos vetores (pesa no GBFS);
// - WA* com peso fixo 1,5;
// - vizinhança-4 do voxel infla o comprimento (~19% vs 2.5D);
// - memória do grafo sem os temporários da construção; memória da busca estimada, não medida;
// - vertex: custo pode ficar abaixo do comprimento geométrico (vértices do MC fora da superfície);
// - CPU híbrida (i5-1235U) sem afinidade fixada.
A validade interna do experimento será buscada por meio do controle de hardware, da fixação de parâmetros do sistema operacional, do isolamento de _threads_ e da padronização das condições de execução. A validade externa será discutida a partir das limitações do ambiente de teste, reconhecendo que os resultados podem variar em outras arquiteturas de CPU, GPU, memória e sistemas operacionais.

Para favorecer a reprodutibilidade, serão registrados os parâmetros de cada cenário, as sementes pseudoaleatórias usadas na geração procedural, as versões das bibliotecas, as flags de compilação e os arquivos de saída brutos. Sempre que possível, os dados coletados serão preservados em formato aberto, permitindo reanálise posterior. Assim, o estudo reforça seu caráter científico ao tornar explícito não apenas o funcionamento do sistema, mas também as condições sob as quais as evidências foram produzidas.

= Resultados e Discussão
// TODO(tcc): fora do escopo agora; depende da rodada completa de coleta (TODO.md → Coleta).

= Conclusão e trabalhos futuros
// TODO(tcc): fora do escopo agora. Trabalhos futuros candidatos: algoritmos any-angle e JPS
// (nash2007thetastar, nash2013anyangle, jps_3d), WA* com outros pesos e custos assimétricos (grafo direcionado).

// =======================================================
// ELEMENTOS PÓS-TEXTUAIS
// =======================================================

#pagebreak()

#text(white, size: 1pt)[#heading(numbering: none)[REFERÊNCIAS]]
#v(-1.5em)
// 1. Referências
#align(center)[
  #text(weight: "bold", size: 12pt)[REFERÊNCIAS]
  #v(1.5em)
]

#bibliography("referencias.bib", style: "associacao-brasileira-de-normas-tecnicas.csl", title: none)