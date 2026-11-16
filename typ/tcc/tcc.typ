// ==========================================
// CONFIGURAÇÃO DO TEMPLATE DE PRÉ-PROJETO (ABNT NBR 15287)
// ==========================================

#import "@preview/lovelace:0.3.1": *

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
    
    #text(weight: "bold", size: 14pt, upper(titulo))#if subtitulo != "" [#text(weight: "bold", size: 14pt)[: #subtitulo]]
        
    #v(3fr)
    #text(weight: "bold", local) \
    #text(weight: "bold", ano)
  ]
  pagebreak()
  counter(page).update(1)

  align(center)[
    #text(upper(autor))
    #v(1fr)
    
    #text(weight: "bold", upper(titulo))#if subtitulo != "" [#text(weight: "bold")[: #subtitulo]]
    #v(3em)
    
    #align(right)[
      #pad(left: 8cm)[
        #set text(size: 10pt)
        #set par(leading: 0.65em, justify: true)
        #natureza_trabalho
        \ \
        *Orientador:* #orientador
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
      #text(weight: "bold", upper(titulo))#if subtitulo != "" [#text(weight: "bold")[: #subtitulo]]
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
    ] else [
      Aprovado em: #box(width: 1.2cm, repeat[\_])/#box(width: 1.2cm, repeat[\_])/#box(width: 2cm, repeat[\_]) \
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
    #set par(first-line-indent: 0pt, leading: 1em, justify: true)
    #resumo
    
    #v(2em)
    #text(weight: "bold")[Palavras-chave:] #palavras_chave.join(". ").
    #pagebreak()
  ]

  if abstract != [] [
    #align(center)[#text(weight: "bold")[ABSTRACT]]
    #v(1.5em)
    #set par(first-line-indent: 0pt, leading: 1em, justify: true)
    #abstract
    
    #v(2em)
    #text(weight: "bold")[Keywords:] #keywords.join(". ").
    #pagebreak()
  ]

  // Listas de ilustrações e de tabelas: "Figura 1 – Título ..... página" (NBR 14724).
  show outline.entry: it => {
    if it.element.func() == figure {
      link(it.element.location(), it.indented([#it.prefix() –], [#it.body() #box(width: 1fr, it.fill) #it.page()]))
    } else { it }
  }

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
    leading: 1em, 
    spacing: 1em
  )

  set heading(numbering: "1.1")
  // Alíneas "a)" e subalíneas com travessão (NBR 6024).
  set enum(numbering: "a)")
  set list(marker: [–])
  set math.equation(numbering: "(1)")
  show heading: it => {
    set text(size: 12pt, weight: "bold")
    set block(above: 1.5em, below: 1.5em) 
    
    if it.level == 1 {
      pagebreak(weak: true)
      // Títulos sem indicativo numérico (referências, apêndices) são centralizados (NBR 14724).
      if it.numbering == none { align(center, upper(it)) } else { upper(it) }
    } else if it.level == 2 {
      it
    } else if it.level == 3 {
      set text(weight: "regular")
      it
    } else {
      set text(weight: "regular", style: "italic")
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

// Tabela no padrão ABNT/IBGE: aberta nas laterais, sem linhas internas, com traços
// apenas no topo, abaixo do cabeçalho (primeira linha) e no fim. Aceita os mesmos
// argumentos de `table` e deve ser usada dentro de um `figure`, que cuida do título.
#let tabela-abnt(..args) = table(
  stroke: none,
  ..args.named(),
  table.hline(y: 0, stroke: 0.8pt),
  table.hline(y: 1, stroke: 0.5pt),
  ..args.pos(),
  table.hline(stroke: 0.8pt),
)

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
  titulo: "Representações e características de terrenos tridimensionais e seu impacto no desempenho de algoritmos de busca de caminhos",
  subtitulo: "Uma análise comparativa e estatística",
  autor: "André Vitor Bastos de Macêdo",
  orientador: "Prof. Dr. Paulo César Rodacki Gomes",
  instituicao: "Instituto Federal Catarinense - IFC",
  curso: "Bacharelado em Ciência da Computação",
  local: "Blumenau",
  ano: "2026",
  natureza_trabalho: "Trabalho de Conclusão de Curso apresentado ao curso de Bacharelado em Ciência da Computação do Instituto Federal Catarinense – Campus Blumenau, como requisito parcial para a obtenção do grau de Bacharel em Ciência da Computação.",

  resumo: [
    A busca de caminhos em terrenos tridimensionais depende tanto do algoritmo de busca quanto da representação navegável construída a partir da geometria do terreno, mas essas escolhas costumam ser avaliadas isoladamente. Este trabalho analisa, de forma comparativa e estatística, a influência da representação navegável e das características do terreno no desempenho e na qualidade da busca de quatro algoritmos clássicos: Dijkstra, A\*, Weighted A\* e Greedy Best-First Search. Os terrenos são gerados proceduralmente por ruído de Perlin e convertidos em quatro representações: grade 2.5D, grade voxelizada, grafo de vértices e grafo dual da malha. Em quatro testes, variam-se a escala, isto é, a resolução da grade sobre a qual o terreno é amostrado, e a lacunaridade, a persistência e o comprimento de onda do ruído, com 50 terrenos por nível, e registram-se o tempo de busca, o número de vértices expandidos, o pico da lista aberta e o custo relativo do caminho. Os dados são analisados por análise de variância em modelo _split-plot_, com testes de Tukey. O algoritmo Greedy Best-First Search é o mais rápido em todos os testes, mas produz caminhos entre 18% e 28% mais caros que os do algoritmo de Dijkstra. O algoritmo A\* expande menos vértices que o algoritmo de Dijkstra sem reduzir o tempo de busca, e o algoritmo Weighted A\* obtém caminhos cerca de 3% mais caros, com o maior pico da lista aberta. A grade 2.5D é a representação mais rápida em média entre os algoritmos, mas a ordem entre as representações muda conforme o algoritmo. Entre as características do terreno, a persistência tem o maior efeito, quadruplicando o tempo de busca entre os níveis extremos. Conclui-se que nenhuma combinação é a melhor em todos os critérios e que representação e algoritmo devem ser escolhidos em conjunto, conforme a prioridade da aplicação.
  ],
  palavras_chave: ("Busca de caminhos", "Representações navegáveis", "Terrenos tridimensionais", "Ruído de Perlin", "Análise de variância"),
  abstract: [
    Pathfinding on three-dimensional terrain depends on both the search algorithm and the navigable representation built from the terrain geometry, but these choices are usually evaluated in isolation. This work presents a comparative and statistical analysis of how the navigable representation and the terrain characteristics affect the performance and the path quality of four classical algorithms: Dijkstra, A\*, Weighted A\* and Greedy Best-First Search. Terrains are procedurally generated with Perlin noise and converted into four representations: a 2.5D grid, a voxelized grid, a vertex graph and the dual graph of the mesh. In four tests, the scale, that is, the resolution of the grid on which the terrain is sampled, and the lacunarity, persistence and wavelength of the noise are varied, with 50 terrains per level, and the search time, the number of expanded vertices, the peak size of the open list and the relative path cost are recorded. The data are analyzed by a split-plot analysis of variance, followed by Tukey tests. The Greedy Best-First Search algorithm is the fastest in every test, but its paths cost between 18% and 28% more than those of Dijkstra's algorithm. The A\* algorithm expands fewer vertices than Dijkstra's algorithm without reducing the search time, and the Weighted A\* algorithm finds paths about 3% more expensive, with the largest open list peak. The 2.5D grid is the fastest representation on average across the algorithms, but the ranking of the representations changes with the algorithm. Among the terrain characteristics, persistence has the largest effect, quadrupling the search time between the extreme levels. No combination is best on every criterion, and the representation and the algorithm should be chosen together, according to the priority of the application.
  ],
  keywords: ("Pathfinding", "Navigable representations", "Three-dimensional terrain", "Perlin noise", "Analysis of variance"),
  
  banca: (
    (nome: "Prof. Dr. Paulo César Rodacki Gomes", filiacao: [Orientador \ Instituto Federal Catarinense – Campus Blumenau]),
    (nome: "Prof. Me. Ricardo de la Rocha Ladeira", filiacao: [Instituto Federal Catarinense – Campus Blumenau]),
    (nome: "Prof. Me. Matheus Luan Krueger", filiacao: [Instituto Federal Catarinense – Campus Blumenau]),
  ),

  lista_ilustracoes: true,
  lista_tabelas: true,
  lista_siglas: (
    "ANOVA": [Análise de variância],
    "API": [_Application Programming Interface_ (interface de programação de aplicações)],
    "CLI": [_Command-Line Interface_ (interface de linha de comando)],
    "CSV": [_Comma-Separated Values_ (valores separados por vírgula)],
    "EBO": [_Element Buffer Object_ (objeto de _buffer_ de índices)],
    "FPS": [_Frames Per Second_ (quadros por segundo)],
    "GBFS": [Greedy Best-First Search],
    "GLSL": [_OpenGL Shading Language_ (linguagem de sombreamento do OpenGL)],
    "GPU": [_Graphics Processing Unit_ (unidade de processamento gráfico)],
    "HSD": [_Honestly Significant Difference_ (diferença honestamente significativa)],
    "IFC": [Instituto Federal Catarinense],
    "MQ": [Quadrado médio],
    "VAO": [_Vertex Array Object_ (objeto de arranjo de vértices)],
    "VBO": [_Vertex Buffer Object_ (objeto de _buffer_ de vértices)],
    "WA*": [Weighted A\*],
  )
)

= Introdução
A busca de caminhos (ou _pathfinding_) é um dos campos mais tradicionais da Inteligência Artificial aplicada, que evoluiu a partir dos algoritmos de busca clássicos em grafos (ver @grafos). Como definem Russell e Norvig (#cite(<russell_norvig>, form: "year")), os métodos clássicos de busca resolvem problemas de estados, ações e custos, visando encontrar caminhos entre um ponto de partida e um objetivo por meio da exploração do espaço de busca. Ao longo das últimas décadas, essa fundamentação deixou de ser puramente abstrata e passou a ser aplicada diretamente na computação interativa. Conforme apontam #cite(<pathfinding_game_dev>, form: "prose"), os algoritmos de busca tornaram-se componentes cruciais para o desenvolvimento de jogos modernos e simulações em tempo real.

No entanto, a transição do espaço de busca de 2D para 3D introduziu um aumento considerável na complexidade, exigindo adaptações às técnicas de busca e de representação do terreno. A escolha da representação do espaço transitável e do algoritmo de busca a ser utilizado tornou-se uma decisão crítica, impactando diretamente o desempenho e a qualidade dos caminhos encontrados.

A transição do espaço de busca de 2D para 3D é ilustrada na @fig_2Dx3D, que compara a representação bidimensional de um terreno com sua contraparte tridimensional. A representação 2D é mais simples e a atribuição de pesos para a travessia entre vértices é direta, enquanto a representação 3D exige uma modelagem mais complexa, considerando a geometria do terreno e as restrições de movimentação. Essa complexidade adicional influencia diretamente o desempenho dos algoritmos de busca. Em destaque, um mesmo caminho: na grade 2D, cada aresta tem custo 1, enquanto no terreno 3D o custo depende da diferença de altura entre os vértices.

\
#figure(
  caption: [Comparação entre representações 2D e 3D.],
  supplement: "Figura",
)[
  #v(-2em)
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 2em,
    row-gutter: 0em,
    align: center + horizon,
    [
      #image("images/2d.svg", width: 75%)
    ],
    [
      #image("images/3d.svg", width: 100%)
    ]
  )
  #v(-1.5em)
 Fonte: Elaborado pelo autor.
] <fig_2Dx3D> \ #v(-1.5em)

Nos estudos analisados neste trabalho, a avaliação se concentra em uma única representação navegável @dang2025adapting @Kapi2022. Por isso, nenhum deles compara representações por meio de análise estatística, o que limita a compreensão das interações entre a estrutura do terreno e o comportamento dos algoritmos.

Este trabalho propõe uma análise comparativa e estatística do desempenho de algoritmos clássicos de busca de caminhos em diferentes representações navegáveis de terrenos 3D. A pesquisa busca responder à seguinte questão central: qual é a influência da *representação navegável* de um terreno 3D e das *características do terreno* no desempenho e na qualidade da busca de algoritmos clássicos de busca?

== Contribuições

Para responder à questão central, é necessário realizar uma análise detalhada das representações navegáveis de terrenos 3D (ver @representacoes_navegaveis), dos algoritmos de busca aplicados (ver @busca) e das métricas de desempenho utilizadas (ver @avaliacao). Com isso, as principais contribuições deste trabalho incluem:

+ #text()[*comparação entre representações navegáveis:* as mesmas instâncias de terreno são convertidas em quatro grafos diferentes e avaliadas com os mesmos algoritmos, sendo:
  - a partir do mapa de altura, a grade de altura (2.5D) e a grade voxelizada;
  - a partir da malha poligonal, o grafo de vértices e o grafo dual;]
+ #text()[*metodologia experimental reprodutível:* os terrenos são gerados proceduralmente (ver @geracao_terrenos) a partir de parâmetros controlados (lacunaridade, persistência e comprimento de onda do ruído, além da escala, que define a resolução da grade) e semente registrada, e os resultados passam por análise estatística (análise de variância, ou ANOVA, e testes _post hoc_);]
+ #text()[*implementação de código aberto:* foram desenvolvidos neste trabalho o gerador de terrenos, as quatro representações navegáveis, os algoritmos de busca instrumentados, os _scripts_ de coleta e de análise, a estrutura de grafo leve `lwGraph<T>` e o gerenciador de tarefas concorrente _TaskMaster_. Eles foram construídos sobre duas bibliotecas anteriores do autor: a biblioteca de grafos Graph @graph_lib e o motor gráfico IFCG @ifcg_lib, usado na visualização das malhas e dos caminhos.]

== Objetivos

O objetivo geral do estudo é analisar comparativa e estatisticamente o desempenho de algoritmos clássicos de _pathfinding_ em diferentes representações navegáveis de terrenos 3D. Os objetivos específicos são:

+ estender uma biblioteca de grafos com uma estrutura leve, voltada à busca em grafos grandes, e implementar os algoritmos Dijkstra, A\*, Weighted A\* e Greedy Best-First Search;
+ desenvolver um gerador procedural de terrenos baseado em ruído de Perlin, parametrizado por lacunaridade, persistência e comprimento de onda, com resolução da grade (escala) ajustável;
+ construir quatro representações navegáveis a partir do terreno: grade de altura, grade voxelizada, grafo de vértices e grafo dual da malha;
+ desenvolver um ambiente 3D com execução concorrente para visualização das malhas e dos caminhos encontrados;
+ automatizar a coleta de métricas e analisar estatisticamente os resultados obtidos.

= Fundamentação teórica

A comparação proposta neste trabalho depende de três conjuntos de conceitos: a teoria de grafos, que modela o espaço de busca; os algoritmos que percorrem esse modelo; e os métodos de representação de terrenos que determinam como o grafo é construído a partir da geometria. Este capítulo apresenta cada um deles, nessa ordem, e termina com os trabalhos que compararam representações semelhantes.

== Grafos <grafos>

Grafos são estruturas matemáticas que representam relações entre objetos. Eles consistem em um conjunto de vértices (ou nós) e um conjunto de arestas (ou ligações) que conectam os vértices (@fig_grafo_simples). Um grafo pode ser direcionado ou não direcionado, ponderado ou não ponderado, dependendo das características do problema a ser modelado. 

\
#figure(
  caption: [Exemplo de grafo.],
  supplement: "Figura",
)[
  #v(1.5em)
  #image("images/grafo_simples.png", width: 25%)
  #v(2em)
 Fonte: Elaborado pelo autor.
] <fig_grafo_simples> \ #v(-1.5em)

Para modelar ambientes complexos, como terrenos 3D, os grafos fornecem uma representação abstrata que facilita a aplicação de algoritmos de busca. Em aplicações como a navegação em terrenos 3D, os vértices podem representar posições do ambiente, e as arestas, a transitabilidade entre elas.

=== Definição

Com base em #cite(<rodacki_grafos>, form: "prose"), um grafo G é definido como um par ordenado (@formula_grafo), em que $G$ é o grafo; $V$ é o conjunto de vértices; e $A$ é o conjunto de arestas. A notação foi adaptada dessa obra, que denota o conjunto de arestas por $E$. Cada aresta representa a conexão entre dois vértices, podendo ter uma direção associada e um peso.

\
$ G = (V, A) $ <formula_grafo> \

Cada conjunto de vértices e arestas pode ser representado de diferentes maneiras, dependendo da aplicação e das operações que serão realizadas sobre o grafo. As representações mais comuns incluem listas de adjacência (@lista_adjacencia) e matrizes de adjacência (@matriz_adjacencia) @rodacki_grafos. 

Dado que um grafo é uma estrutura de dados baseada em conjuntos, naturalmente existem subgrafos. Um subgrafo é formado por um subconjunto de vértices e por um subconjunto de arestas cujas extremidades pertencem a esse subconjunto de vértices, podendo ser utilizado para analisar partes específicas da estrutura ou para simplificar a resolução de problemas complexos @rodacki_grafos.

==== Vértices

Vértices são as unidades básicas de um grafo, também chamadas de nós. Cada vértice funciona como um elemento unitário que pode carregar qualquer tipo de valor ou informação. Dependendo da aplicação, um vértice pode representar um espaço na memória, um local, uma ideia ou um estado, como a configuração de um sistema em um dado momento. A definição de grafo não restringe o significado dos vértices, que depende apenas do problema modelado.

==== Arestas <arestas>

Arestas são as conexões que ligam pares de vértices de um grafo. Cada aresta representa uma relação entre dois vértices, e seu significado depende da aplicação. Uma aresta pode representar uma passagem física entre dois locais, uma passagem lógica entre dois estados ou uma mudança de estado, como a transição de um sistema de uma configuração para outra.

==== Lista de adjacência <lista_adjacencia>

Lista de adjacência é uma forma de representar um grafo em que cada vértice armazena a lista dos vértices diretamente conectados a ele por uma aresta. Para um grafo com $n$ vértices e $m$ arestas, essa estrutura ocupa espaço proporcional a $n + m$, o que a torna eficiente para grafos com poucas arestas @cormen2009introduction.

==== Matriz de adjacência <matriz_adjacencia>

Matriz de adjacência é uma forma de representar um grafo por meio de uma tabela quadrada de dimensão $n times n$, em que cada linha e cada coluna correspondem a um vértice. Cada posição da matriz indica se existe uma aresta entre o par de vértices correspondente, e pode também armazenar o peso dessa aresta. Em um grafo não direcionado, a matriz é simétrica, pois a conexão vale nos dois sentidos.

Essa estrutura ocupa espaço proporcional a $n^2$, o que a torna pouco eficiente para grafos com poucas arestas. Em compensação, ao contrário da lista de adjacência (@lista_adjacencia), ela permite verificar em tempo constante se dois vértices estão conectados @rodacki_grafos.

=== Direcionamento

Como definido na @arestas, uma aresta conecta dois vértices. Essa conexão pode ter um sentido, caso em que a aresta é direcionada, ou representar apenas uma ligação sem direção. Na criação de um grafo, é possível defini-lo como direcionado (@fig_dir\(a\)) ou não direcionado (@fig_dir\(b\)). Ou seja, a conexão entre dois vértices pode ser unidirecional ou bidirecional.

\
#figure(
  caption: [Exemplo de grafo direcionado e não direcionado.],
  supplement: "Figura",
)[
  #v(1.5em)
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 2em,
    row-gutter: 0em,
    [
      #image("images/direcionado.png", width: 50%)
      #v(1.5em)
      #align(center)[(a) Grafo direcionado]
    ],
    [
      #image("images/nao_direcionado.png", width: 50%)
      #v(1.5em)
      #align(center)[(b) Grafo não direcionado]
    ]
  )
  #v(.5em)
 Fonte: Elaborado pelo autor.
] <fig_dir> \ #v(-1.5em)

A escolha entre grafos direcionados e não direcionados depende do problema a ser modelado. Em muitos casos, como em mapas de ruas ou redes de transporte, as conexões são bidirecionais, enquanto em outros, como fluxos de dados ou hierarquias, as conexões podem ser unidirecionais.

=== Pesos

Grafos também podem ser ponderados (@fig_peso\(a\)), atribuindo valores numéricos às arestas para representar custos ou distâncias entre os vértices.

\
#figure(
  caption: [Exemplo de grafo ponderado e não ponderado.],
  supplement: "Figura",
)[
  #v(1.5em)
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 2em,
    row-gutter: 0em,
    align: center + horizon,
    [
      #image("images/ponderado.png", width: 50%)
      #v(1.5em)
      #align(center)[(a) Grafo ponderado]
    ],
    [
      #image("images/nao_ponderado.png", width: 50%)
      #v(1.5em)
      #align(center)[(b) Grafo não ponderado]
    ]
  )
  #v(0.5em)
 Fonte: Elaborado pelo autor.
] <fig_peso> \ #v(-1.5em)

Ponderar a travessia entre vértices permite representar de forma mais precisa as características do ambiente, como a dificuldade de atravessar determinados terrenos ou a distância entre pontos. Como visto na @fig_peso, a atribuição de pesos às arestas pode influenciar diretamente a escolha do caminho mais eficiente ou mais curto.

O custo de travessia de uma aresta pode representar diferentes aspectos, como distância física, tempo de viagem ou dificuldade de navegação. A escolha de atribuir pesos às arestas depende do contexto do problema e dos objetivos da estrutura. Alguns algoritmos de busca, como o de Dijkstra, exigem que os pesos sejam não negativos @cormen2009introduction.

=== Caminho

Um caminho em um grafo é uma sequência de vértices conectados por arestas, representando uma rota entre dois pontos @rodacki_grafos, ilustrado na @fig_caminho. A definição formal de um caminho é uma sequência de vértices $(v_1, v_2, ..., v_n)$ tal que cada par consecutivo ${v_i, v_(i+1)}$ está conectado por uma aresta no grafo.

\
#figure(
  caption: [Exemplo de caminho em um grafo.],
  supplement: "Figura",
)[
  #image("images/caminho.png", width: 50%)
  #v(0.5em)
 Fonte: Elaborado pelo autor.
] <fig_caminho> \ #v(-1.5em)

Considerando $v_1$ o vértice inicial e $v_7$ o vértice final, a sequência de vértices $(v_1, v_2, v_3, v_4, v_5, v_6, v_7)$ representada na @fig_caminho é o caminho $v_1 arrow v_7$. Esse caminho é uma das várias rotas possíveis entre os vértices $v_1$ e $v_7$, e a escolha do caminho mais eficiente depende dos pesos das arestas e das características do grafo.

Para todo vértice $v$ em um grafo, é possível determinar se existe um caminho para outro vértice $u$ no mesmo grafo. Entretanto, a existência de um caminho não impede a existência de outros caminhos entre $v$ e $u$, podendo haver múltiplos caminhos com diferentes pesos e características. Quando comparados, os caminhos podem apresentar variações significativas em termos de custo, distância ou dificuldade de travessia. Se existe ao menos um caminho entre $v$ e $u$, e o grafo não contém ciclos de peso negativo, existe um caminho mínimo ou ótimo entre eles, que é aquele com o menor custo ou peso total @cormen2009introduction.

=== Componente conexo <componente_conexo>

Dado um grafo não direcionado, um componente conexo é um subgrafo conexo e maximal, isto é, não pode ser estendido com outros vértices ou arestas do grafo original, e nele existe caminho entre quaisquer pares de vértices @rodacki_grafos. A @fig_componentes_conexos ilustra um grafo com mais de um componente conexo, cada um com uma cor diferente.

#figure(
  caption: [Exemplo de componentes conexos em um grafo.],
  supplement: "Figura",
)[
  #image("images/componentes_conexos.png", width: 75%)
  #v(0.5em)
 Fonte: Elaborado pelo autor.
] <fig_componentes_conexos> \ #v(-1.5em)

A identificação de componentes conexos é fundamental para entender a estrutura do grafo e determinar a viabilidade de encontrar caminhos entre diferentes regiões. Uma vez que um vértice pertence a um componente conexo, é possível garantir que existe um caminho para qualquer outro vértice dentro do mesmo componente.

== Busca <busca>

A busca de caminhos em um grafo é o processo de encontrar um caminho entre um vértice inicial e um vértice objetivo, idealmente o de menor custo. Diferentes algoritmos de busca podem ser aplicados, dependendo das características do grafo e dos requisitos do problema.

\
#figure(
  caption: [Diversos caminhos possíveis entre dois vértices em um grafo.],
  supplement: "Figura",
)[
  #image("images/caminhos.png", width: 50%)
  #v(0.5em)
 Fonte: Elaborado pelo autor.
] <fig_caminhos> \ #v(-1.5em)

Como mostra a @fig_caminhos, há múltiplos caminhos possíveis entre dois vértices em um grafo (um em azul e outro em vermelho). A busca de caminhos envolve explorar essas possibilidades para identificar o caminho mais eficiente ou adequado, considerando critérios como custo, distância ou heurísticas específicas.

Como é preciso encontrar caminhos mínimos, os algoritmos de busca são projetados para explorar o grafo de maneiras específicas, visando otimizar a descoberta de caminhos com base em critérios como custo, distância ou heurísticas.

=== Dijkstra

O algoritmo de Dijkstra, proposto por #cite(<dijkstra1959note>, form: "prose"), é um método clássico da busca de caminhos em grafos ponderados, considerando que todos os pesos das arestas são não negativos. Ele é capaz de encontrar, para cada vértice alcançável, um caminho mínimo a partir de um vértice inicial @rodacki_grafos. Esse processo gera uma árvore de caminhos mínimos tendo o vértice inicial como raiz.

Na implementação do algoritmo de Dijkstra, é considerado o pseudocódigo apresentado por #cite(<rodacki_grafos>, form: "prose"). Neste capítulo, considera-se um grafo $G = (V, A)$ ponderado de pesos não negativos, em que $V$ é o conjunto de vértices, $A$ é o conjunto de arestas e $c_(u,v)$ é o peso da aresta $(u, v)$.

\
#figure(
  caption: [Pseudocódigo do algoritmo de Dijkstra.],
  supplement: "Figura",
)[
  #v(-0.5em)
  #pseudocode-list[
    Dijkstra$(G, c, s)$
    + para cada $v in V$ faça
      + $g_v arrow.l infinity$
      + $p_v arrow.l "nil"$
    + $g_s arrow.l 0$
    + $Q arrow.l V$
    + $S arrow.l nothing$
    + enquanto $Q != nothing$ faça
      + $u arrow.l "pop"(Q)$
      + $S arrow.l S union {u}$
      + para cada $"vértice" v in "adj"(u)$ faça
        + se $v in Q$ e $[g_v > g_u + c_(u,v)]$ então
          + $g_v arrow.l (g_u + c_(u,v))$
          + $p_v arrow.l u$
  ]
  #v(0.5em)
  Fonte: Adaptado de #cite(<rodacki_grafos>, form: "prose").
] <fig_dijkstra> \ #v(-1.5em)

Na @fig_dijkstra, o algoritmo de Dijkstra inicializa a distância $g_v$ de todos os vértices a partir do vértice inicial $s$ como infinita, exceto para o vértice inicial, que tem distância zero para si mesmo. Em seguida são criadas duas estruturas de dados:
+ $Q$: uma fila de prioridade mínima (ou _min-PQ_, do inglês _Minimum Priority Queue_) que armazena os vértices ainda não processados ordenados pela menor distância conhecida, de modo que o vértice de menor distância seja sempre o primeiro a sair;
+ $S$: um conjunto que armazena os vértices cuja distância mínima já foi determinada.

#text()[] \ #v(-1.5em)

O laço principal do algoritmo repete-se enquanto $Q$ não estiver vazia. Em cada iteração, a operação $"pop"(Q)$ retorna o vértice $u$ com menor distância estimada $g_u$ e o remove da fila. Em seguida, $u$ é incluído em $S$. Como os pesos são não negativos, nenhum caminho que passe por vértices ainda não processados pode reduzir $g_u$, o que garante que essa distância já é a mínima.

Para cada vértice $v$ adjacente a $u$ (ver @lista_adjacencia) que ainda está em $Q$, verifica-se se passar por $u$ produz um caminho melhor do que o já conhecido. Se $g_v > g_u + c_(u,v)$, atualiza-se $g_v$ para $g_u + c_(u,v)$ e registra-se $u$ como predecessor de $v$ em $p_v$. Essa operação é chamada de relaxamento da aresta $(u, v)$.

Ao término do laço, para cada vértice alcançável a partir de $s$, $g_v$ contém a distância mínima entre $s$ e $v$. Os predecessores $p_v$ permitem reconstruir o caminho mínimo, percorrendo-os do destino até $s$.

Quando apenas o caminho entre dois vértices interessa, o algoritmo pode ser adaptado para uma busca ponto a ponto, com um vértice objetivo $t$, como na @fig_dijkstra_pp.

\
#figure(
  caption: [Pseudocódigo do algoritmo de Dijkstra ponto a ponto.],
  supplement: "Figura",
)[
  #v(-0.5em)
  #pseudocode-list[
    Dijkstra$(G, c, s, t)$
    + para cada $v in V$ faça
      + $g_v arrow.l infinity$
      + $p_v arrow.l "nil"$
    + $g_s arrow.l 0$
    + *$Q arrow.l {s}$*
    + $S arrow.l nothing$
    + enquanto $Q != nothing$ faça
      + $u arrow.l "pop"(Q)$
      + *se $u = t$ então retorna o caminho até $t$ por $p$*
      + $S arrow.l S union {u}$
      + para cada $"vértice" v in "adj"(u)$ faça
        + *se $v in.not S$ e $[g_v > g_u + c_(u,v)]$ então*
          + $g_v arrow.l (g_u + c_(u,v))$
          + $p_v arrow.l u$
          + *se $v in.not Q$ então $Q arrow.l Q union {v}$*
  ]
  #v(0.5em)
  Fonte: Elaborado pelo autor, com base em #cite(<rodacki_grafos>, form: "prose").
] <fig_dijkstra_pp> \ #v(-1.5em)

Na @fig_dijkstra_pp, as diferenças em relação à @fig_dijkstra estão em negrito. A fila $Q$ começa apenas com $s$, e cada vértice entra nela na primeira vez em que é alcançado. Por isso, a condição de relaxamento verifica se $v$ ainda não foi finalizado, em vez de verificar se ele está em $Q$. A busca termina quando $t$ é retirado da fila, já que, nesse momento, $g_t$ é mínimo, e os vértices mais distantes que $t$ não chegam a ser processados. O caminho encontrado até $t$ é o mesmo da versão clássica.

=== Heurísticas <heuristicas>

Uma heurística é uma função $h(n)$ que estima o custo de um caminho entre um vértice $n$ e o objetivo, sem precisar percorrê-lo. Ela orienta a busca para os vértices mais promissores. Uma heurística é admissível quando nunca superestima o custo real até o objetivo @astar. Já a consistência exige que, para cada aresta, a estimativa do vértice de origem não exceda o custo da aresta somado à estimativa do vértice de destino @russell_norvig.

Em algumas variantes, a heurística recebe um fator de ponderação $w$, e a função de avaliação passa a ser $f(n) = g(n) + w dot h(n)$, em que $g(n)$ é o custo acumulado desde o vértice inicial até $n$. Com $w = 0$, a heurística não influencia a escolha, e a busca se comporta como o algoritmo de Dijkstra. Valores maiores de $w$ tornam a busca mais orientada pela estimativa, o que pode reduzir o número de vértices explorados à custa da otimalidade do caminho @pohl1970heuristic.

A forma de calcular $h(n)$ depende do tipo de movimento permitido no espaço de busca. Em terrenos 3D, a estimativa mais comum é a distância euclidiana, que mede a distância em linha reta entre o vértice $n = (x_1, y_1, z_1)$ e o objetivo $t = (x_2, y_2, z_2)$:

\
$ h(n) = sqrt((x_2 - x_1)^2 + (y_2 - y_1)^2 + (z_2 - z_1)^2) $ <formula_euclidiana> \

Em grades com movimentos apenas nos eixos, a distância de Manhattan soma as diferenças em cada coordenada:

\
$ h(n) = |x_2 - x_1| + |y_2 - y_1| + |z_2 - z_1| $ <formula_manhattan> \

A distância de Chebyshev toma a maior diferença entre as coordenadas. Ela corresponde ao número mínimo de passos em uma grade que permite movimentos diagonais, desde que cada passo tenha o mesmo custo:

\
$ h(n) = max(|x_2 - x_1|, |y_2 - y_1|, |z_2 - z_1|) $ <formula_chebyshev> \

A escolha da heurística depende de ela ser compatível com o custo das arestas. A distância euclidiana é admissível quando nenhuma aresta custa menos que a distância em linha reta entre seus extremos. A distância de Chebyshev é admissível quando os movimentos diagonais custam o mesmo que os movimentos retos. Já a distância de Manhattan superestima a distância real quando há movimentos diagonais, o que pode levar a caminhos não ótimos. Na mesma condição em que é admissível, a distância euclidiana também é consistente, pela desigualdade triangular.

Como a heurística define a ordem de exploração, ela altera tanto o número de vértices visitados quanto a qualidade do caminho encontrado. Uma heurística admissível garante o caminho ótimo quando vértices já finalizados podem ser reabertos @astar. Quando não podem, como no pseudocódigo da @fig_astar, a garantia exige que a heurística seja consistente @russell_norvig. Já uma heurística que superestima o custo pode explorar menos vértices e, ainda assim, não encontrar o menor caminho.

=== A\* <a_star>

O A\* é um algoritmo de busca que combina o custo acumulado com a estimativa do custo restante. Para cada vértice $n$, ele avalia

\
$ f(n) = g(n) + h(n) $ <formula_astar> #v(1.5em)

em que $g(n)$ é o custo do caminho desde o vértice inicial até $n$ e $h(n)$ é a heurística de $n$ até o objetivo. Como no algoritmo de Dijkstra, a busca usa uma fila de prioridade, mas ordena os vértices por $f(n)$, e não apenas por $g(n)$. Se a heurística for consistente, o caminho retornado tem o menor custo possível, mesmo sem reabrir vértices já finalizados @russell_norvig.

\
#figure(
  caption: [Pseudocódigo do algoritmo A\*.],
  supplement: "Figura",
)[
  #v(-0.5em)
  #pseudocode-list[
    A\*$(G, c, s, t, h)$
    + para cada $v in V$ faça
      + $g_v arrow.l infinity$
      + $p_v arrow.l "nil"$
    + $g_s arrow.l 0$
    + *$Q arrow.l {s}$*
    + $S arrow.l nothing$
    + enquanto $Q != nothing$ faça
      + \# vértice de menor $f(u) = g_u + h(u)$
      + $u arrow.l "pop"(Q)$
      + *se $u = t$ então retorna o caminho até $t$ por $p$*
      + $S arrow.l S union {u}$
      + para cada $"vértice" v in "adj"(u)$ faça
        + *se $v in.not S$ e $[g_v > g_u + c_(u,v)]$ então*
          + $g_v arrow.l (g_u + c_(u,v))$
          + $p_v arrow.l u$
          + *se $v in.not Q$ então $Q arrow.l Q union {v}$*
  ]
  #v(0.5em)
  Fonte: Elaborado pelo autor, com base em #cite(<rodacki_grafos>, form: "prose") e Hart, Nilsson e Raphael (#cite(<astar>, form: "year")).
] <fig_astar> \ #v(-1.5em)

Na @fig_astar, as diferenças em relação ao algoritmo de Dijkstra estão em negrito. A inicialização das distâncias é igual à do algoritmo de Dijkstra, mas a fila $Q$ começa apenas com o vértice inicial $s$, pois a busca só precisa explorar a fronteira a partir dele.

A principal diferença está na escolha do vértice a ser expandido. Enquanto o algoritmo de Dijkstra remove de $Q$ o vértice de menor distância, o algoritmo A\* remove o vértice de menor $f(u)$. Quando $h(n) = 0$ para todo $n$, as duas escolhas coincidem, e o algoritmo de Dijkstra passa a ser um caso particular do algoritmo A\*.

Outra diferença é o critério de parada. O algoritmo termina quando o vértice removido é o objetivo $t$, e não quando $Q$ esvazia. Essa parada antecipada pode reduzir o número de vértices explorados. Vértices já finalizados em $S$ não são mais atualizados, e um vértice entra em $Q$ na primeira vez que é alcançado.

=== Weighted A\* <weighted_a_star>

O algoritmo Weighted A\* é uma variante do algoritmo A\* em que a heurística é multiplicada por um fator de ponderação $w$. A função de avaliação passa a ser:

\
$ f(n) = g(n) + w dot h(n) $ <formula_weighted_astar> \

Com $w = 1$, a busca coincide com a do algoritmo A\*. Com $w = 0$, a heurística deixa de influenciar a escolha e o algoritmo se comporta como o de Dijkstra. Para $w > 1$, a estimativa passa a pesar mais na escolha, o que tende a reduzir o número de vértices explorados. Em contrapartida, o caminho encontrado pode não ser o de menor custo @pohl1970heuristic.

\
#figure(
  caption: [Pseudocódigo do algoritmo Weighted A\*.],
  supplement: "Figura",
)[
  #v(-0.5em)
  #pseudocode-list[
    Weighted A\*$(G, c, s, t, h, w)$
    + para cada $v in V$ faça
      + $g_v arrow.l infinity$
      + $p_v arrow.l "nil"$
    + $g_s arrow.l 0$
    + *$Q arrow.l {s}$*
    + $S arrow.l nothing$
    + enquanto $Q != nothing$ faça
      + \# vértice de menor $f(u) = g_u + bold(w) dot h(u)$
      + $u arrow.l "pop"(Q)$ 
      + *se $u = t$ então retorna o caminho até $t$ por $p$*
      + $S arrow.l S union {u}$
      + para cada $"vértice" v in "adj"(u)$ faça
        + *se $v in.not S$ e $[g_v > g_u + c_(u,v)]$ então*
          + $g_v arrow.l (g_u + c_(u,v))$
          + $p_v arrow.l u$
          + *se $v in.not Q$ então $Q arrow.l Q union {v}$*
  ]
  #v(0.5em)
  Fonte: Elaborado pelo autor, com base em #cite(<rodacki_grafos>, form: "prose") e Hart, Nilsson e Raphael (#cite(<astar>, form: "year")).
] <fig_weighted_astar> \ #v(-1.5em)

Na @fig_weighted_astar, as diferenças em relação ao algoritmo de Dijkstra estão em negrito, e são as mesmas do algoritmo A\*, acrescidas do fator $w$ na seleção do vértice. Como a estrutura do pseudocódigo é a mesma, a única mudança de comportamento vem da função de avaliação, e por isso o restante da explicação do algoritmo A\* se aplica aqui.

O valor de $w$ define o equilíbrio entre velocidade e otimalidade. Quando a heurística é admissível, o custo do caminho encontrado não excede $w$ vezes o custo ótimo $C^*$ @pohl1970heuristic. Valores próximos de 1, portanto, limitam a perda de qualidade, mas não garantem o caminho ótimo. Valores maiores fazem a busca se aproximar do comportamento de uma busca gulosa, que é o caso tratado a seguir.

=== Greedy Best-First Search <gbfs>

O algoritmo Greedy Best-First Search ordena os vértices apenas pela heurística, sem considerar o custo acumulado até eles @russell_norvig. Assim, a função de avaliação é:

\
$ f(n) = h(n) $ <formula_gbfs> \

Essa escolha torna a busca rápida, porque ela tende a seguir diretamente na direção do objetivo. Em contrapartida, como o custo acumulado é ignorado, o caminho encontrado pode ser longo e não é garantidamente o de menor custo. Esse algoritmo corresponde ao caso em que o peso da heurística tende ao infinito no algoritmo Weighted A\*.

\
#figure(
  caption: [Pseudocódigo do algoritmo Greedy Best-First Search.],
  supplement: "Figura",
)[
  #v(-0.5em)
  #pseudocode-list[
    Greedy Best-First Search$(G, s, t, h)$
    + para cada $v in V$ faça
      + *$p_v arrow.l "nil"$*
    + *$Q arrow.l {s}$*
    + $S arrow.l nothing$
    + enquanto $Q != nothing$ faça
      + \# vértice de menor $h(u)$
      + $u arrow.l "pop"(Q)$ 
      + *se $u = t$ então retorna o caminho até $t$ por $p$*
      + $S arrow.l S union {u}$
      + para cada $"vértice" v in "adj"(u)$ faça
        + *se $v in.not S$ e $v in.not Q$ então*
          + *$p_v arrow.l u$*
          + *$Q arrow.l Q union {v}$*
  ]
  #v(0.5em)
  Fonte: Elaborado pelo autor, com base em #cite(<rodacki_grafos>, form: "prose") e Hart, Nilsson e Raphael (#cite(<astar>, form: "year")).
] <fig_gbfs> \ #v(-1.5em)

Na @fig_gbfs, as diferenças em relação ao algoritmo de Dijkstra estão em negrito. Não há $g_v$ nem relaxação: a fila é ordenada apenas por $h(u)$, e cada vértice é inserido uma única vez, na primeira vez em que é descoberto. Por isso, a inicialização não precisa das distâncias, e a condição de atualização depende apenas de o vértice já ter sido visitado ou estar na fila.

== Geração procedural de terrenos <geracao_terrenos>

A geração procedural consiste em criar conteúdo automaticamente, a partir de algoritmos e de um conjunto de regras ou parâmetros. Em terrenos 3D, essa abordagem produz paisagens complexas e variadas sem modelagem manual. Como o resultado depende apenas dos parâmetros e de uma semente inicial, a mesma configuração pode ser reproduzida com exatidão.

=== Mapas de altura <heightmap>

Um mapa de altura é uma matriz bidimensional em que cada elemento armazena a altura do terreno naquele ponto. Quando essa matriz é exibida como imagem em escala de cinza, a intensidade de cada pixel corresponde à elevação. Em geral, os valores são normalizados no intervalo $[0, 1]$ e convertidos em altura por um fator de escala $H$, que define a altura máxima do terreno.

Para obter a geometria tridimensional, cada elemento $(i, j)$ da matriz é associado a um vértice cujas coordenadas são

$ (x, y, z) = (i, e(i, j), j) $ <formula_vertice>

em que $e(i, j)$ é a altura armazenada naquele ponto. Dessa forma, o plano horizontal da grade é preservado, e a altura passa a ser a coordenada $y$ (@fig_mapa_altura). 

\
#figure(
  caption: [Conversão de um mapa de altura em vértices tridimensionais.],
  supplement: "Figura",
)[
  #image("images/pixel_to_vertex.png", width: 100%)
  #v(0.5em)
 Fonte: Elaborado pelo autor.
] <fig_mapa_altura> \ #v(-1.5em)

Assim, um pixel totalmente preto ($v = 0$) resultará na altura mínima, enquanto um pixel totalmente branco ($v = 1$) atingirá a altura máxima estipulada ($H$), permitindo um controle preciso sobre a amplitude do relevo gerado.

Por fim, são criadas faces conectando cada vértice com seus vizinhos diretos, formando uma malha de triângulos que representa a superfície do terreno. Essa malha pode então ser utilizada como cenário de teste para os algoritmos de _pathfinding_, permitindo avaliar seu desempenho em ambientes tridimensionais complexos. Neste trabalho, porém, a malha usada pelos grafos de vértices e dual não é obtida dessa forma, e sim pela extração de superfície de um volume de _voxels_ (ver @voxels).

\
#figure(
  caption: [Malha extraída por Marching Cubes a partir de um mapa de altura.],
  supplement: "Figura",
)[
  #image("./images/heightmap_to_mesh.png", width: 100%)
  #v(0.5em)
  #text(size: 10pt)[Fonte: Elaborado pelo autor.]
  \ #text(size: 10pt)[Nota: mapa de altura de 64 × 64 px, altura máxima $H = 64$, semente 1751774298, 6 oitavas, lacunaridade 2, persistência 0,5, amplitude 2, células de 250 px na primeira oitava.]
] <fig_heightmap_mesh> \ #v(-1.5em)

A criação de mapas de altura pode ser feita a partir de imagens reais, como fotografias aéreas ou imagens de satélite, ou gerada proceduralmente por algoritmos de ruído, como o ruído de Perlin (@perlin). 

=== Ruído de Perlin <perlin>

O ruído de Perlin é um algoritmo de geração de ruído gradiente, proposto por #cite(<perlin1985image>, form: "prose"), que produz variações contínuas e suaves. Diferentemente de um ruído puramente aleatório, cada valor depende de uma grade regular de vetores de gradiente, o que faz o resultado variar gradualmente. Por isso, o ruído de Perlin é adequado para simular relevos naturais.

O valor do ruído em um ponto é obtido a partir da célula da grade que o contém. Cada canto $c$ dessa célula possui um vetor de gradiente unitário $arrow(g)_c$, com direção aleatória. Para cada canto, calcula-se o vetor de distância $arrow(d)_c$ entre o ponto e o canto, e o produto escalar entre os dois vetores:

\
$ s_c = arrow(d)_c dot arrow(g)_c = d_(c,x) g_(c,x) + d_(c,y) g_(c,y) $ <formula_produto_escalar> \

Esses valores $s_c$ são as contribuições de cada canto. O tamanho da célula determina o nível de detalhe: células maiores produzem um ruído mais suave, e células menores produzem um ruído mais detalhado (@fig_perlin_celulas).

\
#figure(
  caption: [Ruído de Perlin com células de diferentes tamanhos.],
  supplement: "Figura",
)[
  #columns(3)[
    #image("images/wave_pequena.png", width: 100%)
    #align(center)[(a) Células de 50 px.]
    #colbreak()
    #image("images/wave_mediana.png", width: 100%)
    #align(center)[(b) Células de 125 px.]
    #colbreak()
    #image("images/wave_grande.png", width: 100%)
    #align(center)[(c) Células de 250 px.]
  ]
  #v(0.5em)
  #text(size: 10pt)[Fonte: Elaborado pelo autor.]
  \ #text(size: 10pt)[Nota: 500 × 500 px, uma oitava, semente 42.]
] <fig_perlin_celulas> \ #v(-1.5em)

==== Função de suavização <sec_interpolacao>

As contribuições dos cantos são combinadas por interpolação, dentro da própria célula. A interpolação linear simples produz transições com mudança abrupta de inclinação nas bordas da célula, o que se torna visível no terreno. Para evitar isso, o peso de interpolação $t$ é substituído por uma função de suavização $phi(t)$. A proposta original de Perlin utiliza uma curva cúbica, e versões posteriores empregam a curva quíntica:

\
$ phi(t) = 6t^5 - 15t^4 + 10t^3 $ <formula_suavizacao> #v(1.5em)

Com essa função, a interpolação entre dois valores $q_0$ e $q_1$ é dada por:

\
$ "interp"(q_0, q_1, t) = q_0 + (q_1 - q_0) dot phi(t) $ <formula_interpolacao> \

==== Oitavas <oitavas>

Uma única oitava do ruído tem um nível de detalhe fixo. Para obter relevos com variações em diferentes escalas, somam-se várias oitavas, cada uma com frequência e amplitude próprias @patel_terrain_noise. Para a oitava $i$, com $i = 0, 1, ..., N-1$, tem-se

\
$ f_i = f dot l^i, quad a_i = a_0 dot p^i $ <formula_frequencia_amplitude> #v(1.5em)

e o valor final do ruído é a soma das oitavas:

\
$ R(x, y) = sum_(i=0)^(N-1) a_i dot "ruído"(x dot f_i, y dot f_i) $ <formula_oitavas> \

Os parâmetros $f$, $a_0$, $l$, $p$ e $N$ controlam o resultado final de maneiras distintas, descritas a seguir. A @fig_oitavas_individuais mostra as seis oitavas de um mesmo ruído e o resultado da soma. As oitavas (b) a (g) são exibidas normalizadas, sem o peso $a_i$, que é aplicado apenas na soma.


#figure(
  caption: [Oitavas de um ruído de Perlin e a soma resultante.],
  supplement: "Figura",
)[
  #image("images/oitavas.png", width: 50%)
  #align(center)[(a) Soma das oitavas.]
  #v(0.8em)
  #grid(
    columns: 3,
    column-gutter: 0.5em,
    row-gutter: 0.8em,
    [#image("images/oitavas/octave_1.png", width: 50%) #align(center)[(b) $i = 0$, $a_i = 1$]],
    [#image("images/oitavas/octave_2.png", width: 50%) #align(center)[(c) $i = 1$, $a_i = "0,5"$]],
    [#image("images/oitavas/octave_3.png", width: 50%) #align(center)[(d) $i = 2$, $a_i = "0,25"$]],
    [#image("images/oitavas/octave_4.png", width: 50%) #align(center)[(e) $i = 3$, $a_i = "0,125"$]],
    [#image("images/oitavas/octave_5.png", width: 50%) #align(center)[(f) $i = 4$, $a_i = "0,0625"$]],
    [#image("images/oitavas/octave_6.png", width: 50%) #align(center)[(g) $i = 5$, $a_i = "0,03125"$]],
  )
  #v(0.5em)
  #text(size: 10pt)[Fonte: Elaborado pelo autor.]
  \ #text(size: 10pt)[Nota: 500 × 500 px, semente 42, lacunaridade 2, persistência 0,5, células de 250 px na primeira oitava.]
] <fig_oitavas_individuais> \ #v(-1.5em)

A frequência inicial $f$ define a escala do ruído na primeira oitava. Quando $f$ aumenta, o padrão se repete em intervalos menores, e uma mesma área apresenta mais elevações e depressões. Como a frequência de todas as oitavas é proporcional a $f$, a escala de todo o terreno muda, e não apenas um detalhe. A @fig_frequencia compara ruídos com frequência baixa e alta, mantendo os demais parâmetros.

\
#figure(
  caption: [Variação da frequência: ruídos com frequência baixa e alta.],
  supplement: "Figura",
)[
  #columns(2)[
    #image("images/freq_baixa.png", width: 100%)
    #align(center)[(a) Células de 500 px.]
    #colbreak()
    #image("images/freq_alta.png", width: 100%)
    #align(center)[(b) Células de 200 px.]
  ]
  #v(0.5em)
  #text(size: 10pt)[Fonte: Elaborado pelo autor.]
  \ #text(size: 10pt)[Nota: 500 × 500 px, semente 42, 6 oitavas, lacunaridade 2, persistência 0,5.]
] <fig_frequencia> \ #v(-1.5em)

A amplitude inicial $a_0$ define o alcance vertical da primeira oitava. Como $a_i = a_0 dot p^i$, aumentar $a_0$ multiplica a contribuição de todas as oitavas pelo mesmo fator. Na soma da @formula_oitavas, $a_0$ altera, portanto, a altura total do relevo sem mudar a proporção entre detalhes grandes e pequenos. Quando a soma é normalizada pelas amplitudes, esse fator se cancela, e o alcance vertical passa a depender de um fator aplicado depois da normalização.

A lacunaridade $l$ determina quanto a frequência cresce de uma oitava para a seguinte. Valores altos fazem as oitavas finais ter frequências muito maiores que as iniciais, de modo que o detalhe se concentra em escalas pequenas e o relevo fica mais irregular. Valores próximos de 1 fazem todas as oitavas ter frequência semelhante, e o resultado se aproxima de um único ruído escalado. A @fig_lacunaridade compara ruídos com lacunaridade baixa e alta, mantendo os demais parâmetros.

\
#figure(
  caption: [Variação da lacunaridade: ruídos com lacunaridade baixa e alta.],
  supplement: "Figura",
)[
  #columns(2)[
    #image("images/lac_baixa.png", width: 100%)
    #align(center)[(a) Lacunaridade 1,5.]
    #colbreak()
    #image("images/lac_alta.png", width: 100%)
    #align(center)[(b) Lacunaridade 2,25.]
  ]
  #v(0.5em)
  #text(size: 10pt)[Fonte: Elaborado pelo autor.]
  \ #text(size: 10pt)[Nota: 500 × 500 px, semente 42, 6 oitavas, persistência 0,5, células de 250 px na primeira oitava.]
] <fig_lacunaridade> \ #v(-1.5em)

A persistência $p$ determina quanto a amplitude diminui de uma oitava para a seguinte. Valores baixos fazem os detalhes finos ter pouca influência, e o relevo fica dominado pelas formas amplas. Valores altos mantêm as oitavas finas com peso comparável ao das oitavas grandes, e o terreno fica mais áspero. A @fig_persistencia mostra essa diferença, mantendo os demais parâmetros.

\
#figure(
  caption: [Variação da persistência: ruídos com persistência baixa e alta.],
  supplement: "Figura",
)[
  #columns(2)[
    #image("images/pers_baixa.png", width: 100%)
    #align(center)[(a) Persistência 0,3.]
    #colbreak()
    #image("images/pers_alta.png", width: 100%)
    #align(center)[(b) Persistência 0,7.]
  ]
  #v(0.5em)
  #text(size: 10pt)[Fonte: Elaborado pelo autor.]
  \ #text(size: 10pt)[Nota: 500 × 500 px, semente 42, 6 oitavas, lacunaridade 2, células de 250 px na primeira oitava.]
] <fig_persistencia> \ #v(-1.5em)

O número de oitavas $N$ define quantas camadas são somadas. Com poucas oitavas, o ruído contém apenas as escalas mais grosseiras. Cada oitava adicional acrescenta detalhes menores, cujo peso é reduzido por $p^i$ (@fig_oitavas). Por isso, com persistência baixa, oitavas adicionais quase não alteram o resultado, e com persistência alta, cada uma contribui de forma perceptível.

\
#figure(
  caption: [Variação do número de oitavas: ruídos com 1 e 6 oitavas.],
  supplement: "Figura",
)[
  #columns(2)[
    #image("images/1_oitava.png", width: 100%)
    #align(center)[(a) Ruído com 1 oitava.]
    #colbreak()
    #image("images/6_oitavas.png", width: 100%)
    #align(center)[(b) Ruído com 6 oitavas.]
  ]
  #v(0.5em)
  #text(size: 10pt)[Fonte: Elaborado pelo autor.]
  \ #text(size: 10pt)[Nota: 500 × 500 px, semente 42, lacunaridade 2, persistência 0,5, células de 250 px na primeira oitava.]
] <fig_oitavas> \ #v(-1.5em)

Valores comumente usados são próximos de 2 para a lacunaridade e de 0,5 para a persistência, de modo que cada oitava tem o dobro da frequência e metade da amplitude da anterior. Essa combinação é descrita por #cite(<patel_terrain_noise>, form: "prose") e produz terrenos com grandes elevações e pequenas variações ao mesmo tempo.

== Representações geométricas de terrenos <representacoes_geometricas>

Esta seção descreve formas de representar a geometria visual de terrenos em um ambiente 3D. Cada técnica define como o volume ou a superfície do terreno é armazenado, e essa escolha determina quais formas podem ser descritas.

=== Voxels <voxels>

O _voxel_ é a unidade cúbica que divide o espaço tridimensional em uma grade regular, de modo análogo ao pixel em imagens bidimensionais. Em uma representação volumétrica de terreno, cada _voxel_ pode indicar se a posição correspondente está preenchida por material ou vazia. Essa abordagem descreve cavidades e estruturas sobrepostas, que um mapa de altura não armazena, já que ele guarda apenas uma altura para cada posição horizontal. Neste trabalho, porém, o volume é obtido a partir do próprio mapa de altura: cada coluna é preenchida até a sua altura, arredondada para um número inteiro de _voxels_. Por isso, o volume não contém cavidades nem estruturas sobrepostas, e essa capacidade da representação volumétrica não é explorada.

=== Marching Cubes

A extração de uma superfície a partir de um campo volumétrico pode ser feita pelo algoritmo de Marching Cubes, proposto por Lorensen e Cline (#cite(<lorensen_cline_marching_cubes>, form: "year")). Para cada célula do volume, o algoritmo compara os valores dos oito cantos com um limiar, classifica cada canto como acima ou abaixo dele e gera os triângulos correspondentes à configuração resultante. Como essa classificação produz 256 configurações possíveis, o algoritmo usa tabelas de casos para determinar os triângulos de cada uma.

O Transvoxel, apresentado por #cite(<lengyel_transvoxel>, form: "prose"), estende essa abordagem a terrenos baseados em _voxels_ em tempo real. Ele acrescenta tabelas de casos para células de transição entre níveis de detalhe distintos, o que evita rachaduras na superfície nas fronteiras entre blocos de resoluções diferentes. Neste trabalho, o volume é extraído em uma única resolução, e por isso são usadas apenas as tabelas de células regulares do Transvoxel, que correspondem aos casos do Marching Cubes. As células de transição não são utilizadas.

Como exemplo, a malha da @fig_heightmap_mesh foi extraída com o Marching Cubes a partir de um volume construído como descrito na @voxels.

== Representações navegáveis de terrenos <representacoes_navegaveis>

A busca de caminhos depende de uma estrutura que represente as regiões por onde um agente pode se deslocar. Essa estrutura é uma representação navegável, em geral um grafo $G = (V, A)$ (ver @grafos), obtido a partir da geometria do terreno. Seus vértices correspondem a posições ou regiões transitáveis, e suas arestas indicam a passagem entre elas. Diferentes representações partem do mesmo terreno, mas produzem grafos com quantidades distintas de vértices e arestas. Conforme Algfoor, Sunar e Kolivand (#cite(<algfoor_pathfinding_survey>, form: "year")), o _pathfinding_ pode ser dividido em duas etapas: a geração do grafo e o algoritmo de busca.

=== Grade 2.5D

A grade 2.5D é uma matriz bidimensional de alturas, em que cada célula corresponde a uma posição do plano horizontal e armazena um único valor de altura. Como grafo, ela corresponde ao mapa de altura (ver @heightmap): cada célula é um vértice, ligado às células vizinhas @sturtevant_grid_benchmarks. Neste trabalho, todas as ligações entre vizinhos são mantidas, e a diferença de altura entre as células afeta apenas o peso das arestas. Por armazenar uma altura por posição, a grade descreve a superfície do terreno, mas não representa cavidades nem estruturas sobrepostas. A @fig_grade_25d mostra essa representação sobre um terreno gerado por ruído de Perlin.

\
#figure(
  caption: [Exemplo de grade 2.5D.],
  supplement: "Figura",
)[
  #v(1.5em)
  #image("images/2_5d.png", width: 15cm)
  #v(.5em)
 Fonte: Elaborado pelo autor. \
 Nota: mapa de altura de 20 × 20 px, altura máxima $H = 14$, semente 42, 2 oitavas, lacunaridade 2, persistência 0,5, células de 16,7 px na primeira oitava.
] <fig_grade_25d> \ #v(-1.5em)

=== Grade voxelizada

A grade voxelizada é uma grade 2.5D em que a altura de cada coluna é arredondada para um número inteiro de _voxels_ (ver @voxels). Cada coluna do mapa de altura corresponde a um vértice, posicionado no topo da coluna, e as arestas ligam apenas as colunas vizinhas nas quatro direções do plano horizontal. As diferenças em relação à grade 2.5D são a altura discretizada e a vizinhança de quatro direções. A @fig_grade_voxelizada mostra essa representação sobre o mesmo terreno da @fig_grade_25d.

\
#figure(
  caption: [Exemplo de grade voxelizada.],
  supplement: "Figura",
)[
  #v(1.5em)
  #image("images/voxel.png", width: 15cm)
  #v(.5em)
 Fonte: Elaborado pelo autor. \
 Nota: mapa de altura de 20 × 20 px, altura máxima $H = 14$, semente 42, 2 oitavas, lacunaridade 2, persistência 0,5, células de 16,7 px na primeira oitava.
] <fig_grade_voxelizada> \ #v(-1.5em)

=== Grafo de vértices

No grafo de vértices, cada vértice da malha poligonal do terreno dá origem a um vértice navegável, e cada aresta liga dois vértices que são extremidades de uma mesma aresta da malha. A estrutura reaproveita a topologia da malha, sem criar vértices novos. A @fig_grafo_vertices mostra essa representação sobre o mesmo terreno da @fig_grade_25d.

\
#figure(
  caption: [Exemplo de grafo de vértices.],
  supplement: "Figura",
)[
  #v(1.5em)
  #image("images/vertex.png", width: 15cm)
  #v(.5em)
 Fonte: Elaborado pelo autor. \
 Nota: mapa de altura de 20 × 20 px, altura máxima $H = 14$, semente 42, 2 oitavas, lacunaridade 2, persistência 0,5, células de 16,7 px na primeira oitava.
] <fig_grafo_vertices> \ #v(-1.5em)

=== Grafo dual

No grafo dual, cada polígono da malha corresponde a um vértice, que representa uma região navegável, e dois vértices são ligados por uma aresta quando os polígonos correspondentes compartilham uma aresta da malha. O número de vértices do grafo é, portanto, o número de polígonos da malha, e não o número de seus vértices. Essa construção é a base das malhas de navegação (_navmesh_), nas quais os polígonos são regiões caminháveis e a adjacência entre eles forma o grafo, conforme #cite(<snook_navmesh>, form: "prose") e #cite(<navigation_mesh>, form: "prose"). A mesma ideia de adjacência entre triângulos é empregada na busca em triangulações, como em Demyen e Buro (#cite(<demyen_buro_triangulation>, form: "year")). A @fig_grafo_dual mostra essa representação sobre o mesmo terreno da @fig_grade_25d.

\
#figure(
  caption: [Exemplo de grafo dual.],
  supplement: "Figura",
)[
  #v(1.5em)
  #image("images/dual.png", width: 15cm)
  #v(.5em)
 Fonte: Elaborado pelo autor. \
 Nota: mapa de altura de 20 × 20 px, altura máxima $H = 14$, semente 42, 2 oitavas, lacunaridade 2, persistência 0,5, células de 16,7 px na primeira oitava.
] <fig_grafo_dual> \ #v(-1.5em)

== Avaliação de desempenho e estatísticas <avaliacao>

Esta seção apresenta as ferramentas estatísticas usadas para comparar medições de desempenho obtidas em condições diferentes. Medições como o tempo de execução variam de uma execução para outra, de modo que a diferença observada entre as médias de dois grupos pode resultar dessa variação, e não de uma diferença real entre os métodos comparados. Testes de hipótese permitem avaliar se a diferença observada é compatível com essa variação aleatória. Ferramentas desse tipo são usuais na análise de desempenho de sistemas, como discute #cite(<jain1991art>, form: "prose").

=== ANOVA <anova>

A ANOVA compara as médias de uma variável resposta entre dois ou mais grupos definidos por um fator. Sua hipótese nula afirma que todas as médias populacionais são iguais, e a hipótese alternativa afirma que ao menos uma delas difere das demais. A estatística do teste é a razão entre o quadrado médio (MQ) entre os grupos e o quadrado médio dentro dos grupos:

\
$ F = "MQ"_"entre" / "MQ"_"dentro" $ <formula_anova> \

Valores grandes de $F$ indicam que a variação entre os grupos é grande em relação à variação interna, o que leva à rejeição da hipótese nula ao nível de significância adotado. A validade do teste depende de três pressupostos: independência das observações, normalidade dos resíduos e homocedasticidade, isto é, variâncias iguais entre os grupos @jurandir @devore2006probabilidade. A violação desses pressupostos pode alterar o nível de significância real do teste.

=== ANOVA em modelo _split-plot_ <split_plot>

Quando o experimento combina fatores aplicados a unidades experimentais diferentes e fatores medidos repetidamente sobre a mesma unidade, a ANOVA é organizada em um modelo de parcelas subdivididas (_split-plot_). Os efeitos dos fatores entre unidades são testados contra a variação entre as unidades. Os efeitos dos fatores dentro da unidade são testados contra a sua interação com a unidade, já que as medidas de uma mesma unidade não são independentes @montgomery2013design.

Os testes dentro da unidade pressupõem esfericidade, isto é, variâncias iguais para as diferenças entre todos os pares de níveis do fator. Quando essa condição não vale, o teste $F$ rejeita a hipótese nula com frequência maior que o nível de significância adotado. A correção de #cite(<greenhouse1959methods>, form: "prose") multiplica os graus de liberdade do numerador e do denominador por um fator $epsilon$, estimado a partir dos dados, com $1/(k - 1) <= epsilon <= 1$, em que $k$ é o número de níveis do fator. Com $epsilon = 1$, não há correção.

=== Normalidade e transformação logarítmica <normalidade>

O pressuposto de normalidade dos resíduos pode ser verificado pelo teste de #cite(<shapiro1965analysis>, form: "prose"), cuja hipótese nula é a de que a amostra provém de uma distribuição normal. A estatística $W$ varia entre 0 e 1 e se aproxima de 1 quanto mais a amostra se aproxima dessa distribuição.

Quando a variância de uma variável cresce com a sua média, como ocorre com tempos e contagens, a transformação logarítmica da variável resposta tende a estabilizar a variância e a aproximar os resíduos da normalidade @montgomery2013design. Na escala logarítmica, diferenças entre médias correspondem a razões entre médias geométricas na escala original.

=== Tamanho de efeito <eta_parcial>

O valor de $p$ indica se um efeito é distinguível da variação aleatória, mas não a sua magnitude. Para isso, usa-se o eta-quadrado parcial ($eta_p^2$), que mede a fração da variação atribuível a um efeito, desconsiderada a variação explicada pelos demais efeitos @cohen1973eta:

\
$ eta_p^2 = "SQ"_"efeito" / ("SQ"_"efeito" + "SQ"_"erro") $ <formula_eta_parcial> #v(1.5em)

em que $"SQ"_"efeito"$ é a soma de quadrados do efeito e $"SQ"_"erro"$ é a soma de quadrados do termo de erro contra o qual o efeito é testado. O valor varia entre 0 e 1.

=== Teste _post hoc_ de Tukey <tukey>

Quando a ANOVA rejeita a hipótese nula, ela indica que ao menos um par de médias difere, mas não identifica quais pares são. Testes _post hoc_ realizam essas comparações após a ANOVA. O teste de Tukey, ou diferença honestamente significativa (HSD, do inglês _honestly significant difference_), compara todos os pares de médias. Ele controla a taxa de erro da família de comparações, de modo que o número de pares comparados não aumente indevidamente a chance de declarar uma diferença falsa @jurandir @devore2006probabilidade.

Para grupos com $n$ observações cada, a menor diferença significativa entre duas médias é dada por:

\
$ "HSD" = q_(alpha, k, nu) sqrt("MQ"_"dentro" / n) $ <formula_tukey> #v(1.5em)

em que $q$ é a estatística da amplitude studentizada, $k$ é o número de grupos, $nu$ são os graus de liberdade do quadrado médio dentro dos grupos e $alpha$ é o nível de significância. Dois grupos são considerados diferentes quando a diferença absoluta entre suas médias excede o HSD.

== Trabalhos relacionados

Esta seção apresenta dois estudos que avaliam o desempenho de algoritmos de _pathfinding_ e indica em que este trabalho difere de cada um.

=== Dang (2025)

#cite(<dang2025adapting>, form: "prose") avalia os algoritmos Dijkstra e A\*, adaptados a ambientes tridimensionais. As métricas são o tempo de execução e o consumo de memória. O ambiente de teste é estruturado em _voxels_ (ver @voxels), de modo que o espaço de busca é uma grade de blocos cúbicos uniformes.

Este trabalho difere em dois pontos. O primeiro é a representação: o mesmo terreno, gerado por ruído de Perlin, é convertido em quatro grafos, e a grade voxelizada é apenas um deles (ver @representacoes_navegaveis). O segundo é o conjunto de algoritmos, que inclui os algoritmos Weighted A\* e Greedy Best-First Search, além dos algoritmos de Dijkstra e A\*.

=== Kapi, Sunar e Algfoor (2022)

Kapi, Sunar e Algfoor (#cite(<Kapi2022>, form: "year")) comparam algoritmos de busca em mapas de grade, entre eles A\*, Jump Point Search e Theta\* @nash2007thetastar, pelo tempo de execução e pelo número de vértices expandidos. Os experimentos são restritos a grades bidimensionais planas.

Em relação a esse estudo, este trabalho considera a terceira dimensão: a altura do terreno entra no peso das arestas e na heurística, que é a distância euclidiana tridimensional. Em contrapartida, Jump Point Search e Theta\* não são avaliados aqui.

=== Comparação com os trabalhos relacionados

A @tab_matriz_diferenca resume as diferenças entre este trabalho e os dois estudos.

\
#figure(
  caption: [Diferenças entre este trabalho e os trabalhos relacionados.],
  supplement: "Tabela",
)[
  #tabela-abnt(
    columns: (auto, 1fr, 1fr, 1fr),
    align: left,
    [*Critério*], [*Este trabalho*], [*Dang (2025)*], [*Kapi, Sunar e Algfoor (2022)*],
    [Espaço de busca], [Terrenos 3D gerados por ruído de Perlin], [Ambientes 3D em _voxels_], [Grades 2D planas],
    [Representações], [Grade 2.5D, grade voxelizada, grafo de vértices e grafo dual], [Grade de _voxels_], [Grade 2D],
    [Algoritmos], [Dijkstra, A\*, Weighted A\* e Greedy Best-First Search], [Dijkstra e A\*], [A\*, Jump Point Search e Theta\*],
    [Métricas], [Tempo de busca, vértices expandidos, pico da lista aberta e custo relativo], [Tempo de execução e consumo de memória], [Tempo de execução e vértices expandidos],
  )
  #v(.5em)
  Fonte: Elaborado pelo autor.
] <tab_matriz_diferenca>

= Implementação <implementacao>

Este capítulo descreve o software desenvolvido para os experimentos. Inicialmente, apresenta-se o _pipeline_ que liga a geração do terreno à coleta das métricas. Em seguida, descrevem-se o motor gráfico IFCG e seu visualizador, a estrutura de grafo `lwGraph`, os algoritmos de busca, o gerador de terrenos, as fábricas das representações navegáveis e a instrumentação usada na coleta.

== Pipeline

Cada execução do experimento segue a mesma sequência de etapas. A partir de uma semente, gera-se um mapa de altura por ruído de Perlin (ver @perlin). Quando o modelo de representação exige geometria, o mapa é convertido em um volume de _voxels_, com cada coluna preenchida até a sua altura arredondada, e esse volume é convertido em uma malha triangular por extração de superfície. Em seguida, o modelo constrói o grafo navegável, os pares de consulta são associados aos vértices mais próximos do grafo, e os algoritmos de busca são executados sobre ele. As métricas de cada execução são registradas e, ao final, analisadas estatisticamente (ver @avaliacao). A @fig_pipeline resume essas etapas.

\
#figure(
  caption: [Etapas do _pipeline_ experimental.],
  supplement: "Figura",
)[
  #v(1.5em)
  #image("images/pipeline_ver.svg", width: 50%)
  #v(.5em)
 Fonte: Elaborado pelo autor.
] <fig_pipeline> \ #v(-1.5em)

== IFCG e visualizador concorrente <ifcg>

O IFCG é uma biblioteca de motor gráfico escrita em C++ sobre OpenGL, desenvolvida pelo autor e inicialmente vinculada à disciplina de Computação Gráfica do Instituto Federal Catarinense (IFC) Campus Blumenau @ifcg_lib. Neste trabalho, ela é a camada de visualização: exibe o terreno gerado, a malha de navegação e os caminhos encontrados pelos algoritmos de busca, permitindo a inspeção visual dos resultados.

=== Arquitetura e _Singleton_

O núcleo da biblioteca é a classe `Engine`, que reúne a janela, o contexto, o renderizador, o tratamento de entrada e o gerenciador de tarefas. A aplicação mantém uma única janela e um único contexto, e por isso a classe segue o padrão _Singleton_ @gamma1994design: o construtor é privado, e a instância é criada por `Engine::init` e destruída por `Engine::terminate`.

=== Janela e contexto

A classe `Window` encapsula a criação da janela pela biblioteca GLFW e expõe suas dimensões e o identificador da janela. A classe `Context` inicializa a GLFW, carrega as funções do OpenGL com a biblioteca GLAD, processa os eventos da janela e informa o tempo decorrido desde a inicialização.

=== Renderização e laço principal

A classe `Renderer` mantém a fila de malhas desenhadas a cada quadro, além do _shader_ ativo, da câmera e dos planos de recorte, cujos valores padrão são campo de visão de 90 graus e planos próximo e distante em 0,1 e 100 unidades. O laço principal é executado por `Engine::loop`, que recebe um `LoopConfig` com funções de _callback_ fornecidas pela aplicação. 

Em cada iteração, as tarefas pendentes destinadas à _thread_ principal são executadas antes da leitura de entrada e novamente antes do corpo do laço. Em seguida, ocorrem a atualização da câmera, a renderização da fila e a troca de _buffers_. Quando há limite de quadros por segundo, a _thread_ aguarda o tempo restante do quadro.

=== Malhas e composição

`MeshBase` define a interface comum das malhas, com a matriz de modelo e as transformações de translação, escala, rotação e reflexão. `Mesh` armazena uma malha indexada, gerencia os _buffers_ de vértices e de índices e a desenha por meio de `glDrawElements`. `MeshTree` implementa o padrão _Composite_ @gamma1994design: seus filhos são malhas simples ou compostas, e o desenho é repassado a cada filho com a matriz de modelo acumulada do nó pai. Dessa forma, uma malha simples e uma composta são tratadas pela mesma interface. A @fig_mesh_composite mostra a relação entre essas classes.

\
#figure(
  caption: [Diagrama de classes do padrão _Composite_ nas malhas do IFCG.],
  supplement: "Figura",
)[
  #v(1.5em)
  #image("images/composite_mesh.svg", width: 100%)
  #v(.5em)
 Fonte: Elaborado pelo autor, com base em #cite(<gamma1994design>, form: "prose").
] <fig_mesh_composite> \ #v(-1.5em)

=== _Shaders_ e _buffers_

`Shader` compila e vincula os programas de sombreamento escritos em GLSL (do inglês _OpenGL Shading Language_). As classes `VBO` (do inglês _vertex buffer object_), `VAO` (do inglês _vertex array object_) e `EBO` (do inglês _element buffer object_) encapsulam, respectivamente, os _buffers_ de vértices, a descrição dos atributos de vértice e os _buffers_ de índices. Essa organização segue o _pipeline_ de renderização descrito em #cite(<learnopengl>, form: "prose").

=== Câmera e entrada

`Camera` atualiza as matrizes de visão e de projeção a partir do campo de visão e dos planos de recorte, e recebe a movimentação pela janela da GLFW. `Keys` associa funções de _callback_ a teclas e ações definidas pela aplicação.

=== Concorrência e _TaskMaster_

O contexto do OpenGL está associado à _thread_ que o ativa, normalmente a principal, e as chamadas à interface de programação de aplicações (API, do inglês _application programming interface_) devem partir dela. O IFCG separa, portanto, o trabalho computacional, que pode ser executado em paralelo, da atualização da unidade de processamento gráfico (GPU, do inglês _graphics processing unit_), que permanece na _thread_ principal.

O _TaskMaster_ (@fig_taskmaster) implementa esse trabalho paralelo como um _pool_ de _threads_. O número de _threads_ trabalhadoras é uma a menos que o de unidades de processamento disponíveis, mantendo-se pelo menos uma. As tarefas entram em três filas, de prioridade alta, média e baixa, e cada trabalhadora retira a próxima tarefa da fila de maior prioridade que não esteja vazia @ladeira. A sincronização usa um `mutex` e uma variável de condição, e as _threads_ são `std::jthread`, que recebem um `std::stop_token` para encerramento cooperativo #cite(label("williams2019c++")).

\
#figure(
  caption: [Diagrama de classes do _TaskMaster_.],
  supplement: "Figura",
)[
  #v(1.5em)
  #image("images/taskmaster.svg", width: 75%)
  #v(.5em)
 Fonte: Elaborado pelo autor.
] <fig_taskmaster> \ #v(-1.5em)

`Engine` oferece três operações sobre o _TaskMaster_. `runAsync` envia uma tarefa ao _pool_. `runOnMainThread` enfileira uma função para execução na _thread_ principal, na próxima iteração do laço. `runAsyncThenMain` combina as duas: a tarefa é calculada em uma trabalhadora, e o resultado é entregue a uma função que roda na _thread_ principal. No visualizador, a geração do ruído e da geometria do terreno e a construção do grafo de navegação ocorrem nas trabalhadoras, enquanto a criação das malhas e o envio à GPU ficam na _thread_ principal. A @fig_cena_visualizador mostra uma cena renderizada pelo visualizador, com a malha de um terreno gerado por ruído de Perlin e os caminhos encontrados pelos quatro algoritmos entre o mesmo par de vértices: Dijkstra em vermelho, A\* em azul, Greedy Best-First Search em verde e Weighted A\* em roxo. A avaliação do _TaskMaster_ nesse tipo de uso está resumida no #link(<apendice_taskmaster>)[Apêndice D].

\
#figure(
  caption: [Cena renderizada pelo visualizador.],
  supplement: "Figura",
)[
  #v(1.5em)
  #image("images/cena.png", width: 100%)
  #v(.5em)
 Fonte: Elaborado pelo autor. \
 Nota: grafo de vértices; mapa de altura de 256 × 256 px, semente 42, 4 oitavas.
] <fig_cena_visualizador> \ #v(-1.5em)

== lwGraph\<T\> <lwgraph>

O grafo usado nos experimentos é representado pela classe `lwGraph<T>`, uma estrutura genérica em que cada vértice armazena um dado do tipo `T`. A biblioteca Graph @graph_lib foi desenvolvida pelo autor na disciplina de Estruturas de Dados 2. Neste trabalho, ela recebeu a estrutura leve, que define a versão base `common::lwGraph<T>` e a especialização `undirected::lwGraph<T>`, usada nos experimentos, que trata as arestas como não direcionadas.

Os vértices são armazenados em um vetor contíguo (`std::vector<T>`), e a lista de adjacência é um vetor de vetores de arestas (`std::vector<std::vector<lwEdge>>`). Cada `lwEdge` guarda apenas o índice do vértice de destino e o peso, sem objetos individuais para nós ou arestas. Essa disposição mantém os dados em blocos contíguos, o que favorece a localidade de memória quando a busca percorre os vizinhos de um vértice. A lista de adjacência (ver @lista_adjacencia) foi preferida à matriz de adjacência (ver @matriz_adjacencia) porque os grafos dos experimentos são esparsos: nas grades, cada vértice tem no máximo oito vizinhos, enquanto uma matriz para 250 mil vértices teria $"6,25" times 10^10$ posições.

Na especialização não direcionada, `addEdge` insere a aresta nas listas dos dois vértices, de modo que ela vale nos dois sentidos, como descrito na @grafos. Depois de construído, o grafo não é modificado pelos algoritmos de busca, que o recebem por referência constante. Por isso, uma mesma instância pode ser lida por mais de uma _thread_, sem sincronização adicional.

Para o cálculo de memória, a função `graphMemoryBytes` soma o tamanho do objeto do grafo, os dados dos vértices, os vetores de adjacência e a capacidade alocada para as arestas. Usa-se a capacidade, e não o tamanho, porque ela inclui a folga reservada pelo crescimento dos vetores, que também ocupa memória.

== search.hpp <search>

Os algoritmos de busca estão no arquivo `search.hpp`, no _namespace_ `search`. Cada um deles é uma função genérica sobre `common::lwGraph<T>`, que recebe o vértice inicial, o vértice objetivo e, quando necessária, uma heurística. Todos retornam uma estrutura `SearchResult`, com o caminho encontrado, o custo acumulado e os contadores de execução. 

Os quatro algoritmos têm implementações separadas, e o algoritmo de Dijkstra não é tratado como o algoritmo A\* com heurística nula. Todos seguem a mesma estrutura de busca ponto a ponto: a lista aberta começa apenas com o vértice inicial, e a busca termina quando o vértice objetivo é retirado dela. No algoritmo de Dijkstra, isso difere do pseudocódigo da @fig_dijkstra, que insere todos os vértices em $Q$ e só termina quando a fila esvazia. Como os vértices são retirados em ordem de custo, o caminho até o objetivo é o mesmo nas duas formas.

=== Algoritmos

O algoritmo de Dijkstra ordena a lista aberta pelo custo acumulado `g`. O algoritmo A\* ordena pela soma `f = g + h`, usando como heurística a distância euclidiana tridimensional entre o vértice e o objetivo, a mesma usada pelos algoritmos Weighted A\* e Greedy Best-First Search (GBFS). A escolha decorre do peso das arestas, que em todas as representações é a distância euclidiana tridimensional entre os extremos. Com esse peso, nenhum caminho é mais curto que a linha reta, e a heurística euclidiana é consistente (ver @heuristicas), o que garante o caminho ótimo do algoritmo A\*. A distância de Manhattan superestimaria o custo dos passos diagonais, e a de Chebyshev, embora admissível, nunca é maior que a distância euclidiana e estima o custo restante com menos precisão. O algoritmo Weighted A\* usa `f = g + w·h`, com o fator `w` igual a 1,5 nos experimentos. O algoritmo GBFS ordena somente pela heurística. 

Como o algoritmo GBFS depende apenas de $h$, ele evidencia o efeito da escolha da heurística (ver @heuristicas). A @fig_heuristicas mostra os caminhos encontrados pelo algoritmo GBFS em um mesmo terreno e entre o mesmo par de vértices, com a distância euclidiana em vermelho, a de Manhattan em azul e a de Chebyshev em verde. A consulta liga dois cantos opostos do terreno. Com a distância de Chebyshev, como a diferença horizontal até o objetivo é a maior das três, apenas os passos diagonais reduzem $h$, e a busca segue a diagonal da grade sem ser influenciada pelo relevo. A distância euclidiana e a de Manhattan incluem a diferença de altura no cálculo, de modo que o relevo altera a ordem de exploração e o caminho se afasta da diagonal, com desvio maior para a distância de Manhattan. Fora do trecho central, o caminho obtido com a distância euclidiana coincide com o obtido com a de Chebyshev e fica encoberto por ele.

\
#figure(
  caption: [Caminhos do algoritmo Greedy Best-First Search com diferentes heurísticas.],
  supplement: "Figura",
)[
  #v(1.5em)
  #image("images/heuristicas.png", width: 75%)
  #v(.5em)
 Fonte: Elaborado pelo autor. \
 Nota: grade 2.5D; mapa de altura de 128 × 128 px, altura máxima $H = 128$, semente 42, 6 oitavas.
] <fig_heuristicas> \ #v(-1.5em)

No algoritmo GBFS, como o custo acumulado não influencia a ordem, cada vértice entra na lista aberta uma única vez, na primeira vez em que é descoberto. Diferentemente do pseudocódigo da @fig_gbfs, a implementação mantém o custo acumulado de cada vértice: um custo menor encontrado depois, enquanto o vértice ainda está na lista aberta, atualiza o pai do vértice e o custo registrado, sem reinseri-lo. Por isso, o caminho retornado pode ter custo menor que o da formulação clássica do algoritmo.

A lista aberta é uma fila de prioridade sem operação de redução de chave. Nos demais algoritmos, quando um vértice que já está na lista recebe um custo menor, ele é inserido novamente com a nova prioridade, e as entradas antigas são descartadas quando retiradas da fila, se o vértice já tiver sido expandido. Nos algoritmos A\* e Weighted A\*, os empates de prioridade são desfeitos pelo menor valor da heurística e, em seguida, pelo menor índice do vértice. No algoritmo de Dijkstra, que não usa heurística, e no algoritmo GBFS, cuja prioridade já é a própria heurística, o desempate é feito apenas pelo índice.

=== Aquisição de dados

Os contadores são incrementados dentro dos próprios algoritmos. `expanded` registra os vértices retirados da lista aberta e processados, `generated` registra as inserções na lista aberta, incluindo as reinserções de um mesmo vértice, e `peakOpen` registra o maior tamanho que a lista atinge durante a busca, contando também as entradas antigas ainda não descartadas. Por fazerem parte da execução, esses valores são os mesmos em toda repetição com o mesmo grafo e os mesmos vértices.

O tempo de execução é medido com `std::chrono::steady_clock` ao redor da chamada do algoritmo, sem incluir a construção do grafo nem a geração do terreno. Quando uma busca leva menos de 5 ms, a resolução do relógio e a variação entre chamadas pesam sobre a medição. Nesse caso, a busca é repetida até que o tempo somado ultrapasse 5 ms, com no máximo 100 000 repetições, e registra-se a mediana dos tempos e o número de repetições @lilja2000measuring. Buscas mais longas são medidas uma única vez. Separadamente, mede-se o tempo de inicialização dos vetores de estado da busca para o número de vértices do grafo, já que essa inicialização faz parte de cada chamada. Em seguida, calcula-se o comprimento geométrico do caminho sobre a superfície. Cada segmento é amostrado em subpassos de no máximo 0,25 unidade horizontal, com a altura obtida por interpolação bilinear do mapa de altura. Esse valor independe dos pesos definidos no grafo, ao contrário do custo acumulado.

Os pontos de início e de fim de cada par de consulta são associados ao vértice mais próximo do grafo por busca linear, e a distância de ajuste é emitida no registro de diagnóstico da execução.

== Gerador de terrenos <gerador>

O gerador produz o mapa de altura de cada terreno a partir de um conjunto de parâmetros e de uma semente. Sua implementação está no _namespace_ `perlin2D`, e os parâmetros ficam reunidos na estrutura `NoiseConfig`: largura e altura do mapa, comprimento de onda base (`wave`), frequência inicial (`freq`), lacunaridade (`lac`), amplitude (`amp`), persistência (`pers`), expoente (`exp`), semente (`seed`) e número de oitavas (`octaves`).

Os gradientes de cada ponto da grade são vetores unitários cuja direção é obtida por uma função de embaralhamento (_hash_) sobre as coordenadas inteiras e a semente. Assim, o mesmo par de coordenadas e semente sempre produz o mesmo gradiente, sem que seja necessário armazenar uma tabela de gradientes @zipped_perlin_noise. Os valores entre os cantos de cada célula são combinados pela função quíntica de suavização (ver @sec_interpolacao).

Para cada oitava $i$, o gerador sorteia um deslocamento de 0 a 1000 em cada eixo, a partir de um gerador de números aleatórios inicializado com a semente, e usa a semente derivada $"semente" + 1013 i$ para os gradientes. A frequência de cada oitava cresce pela lacunaridade, e a amplitude decresce pela persistência, como descrito na @oitavas.

A soma das oitavas é dividida pela raiz quadrada da soma dos quadrados das amplitudes. Essa normalização impede que a persistência, isoladamente, altere a amplitude do relevo. Pelo mesmo motivo, a amplitude inicial $a_0$ da @formula_frequencia_amplitude não altera o resultado, e o alcance vertical é controlado pelo fator `amp`, aplicado depois da normalização, e pela altura $H$. Em seguida, o valor é multiplicado pelo fator `amp`, limitado ao intervalo $[-1, 1]$, reescalado para $[0, 1]$ e elevado ao expoente `exp`. Cada valor $v$ desse mapa é convertido em uma altura $y = 1 + v (H - 1)$, em que $H$ é a escala vertical do terreno.

A função `generateOctaveMaps` produz um mapa por oitava, normalizado isoladamente, e `saveNoiseAsPNG` grava qualquer mapa em escala de cinza.

== GraphModel e GraphFactory <graphmodel>

Cada representação navegável é descrita por uma estrutura `GraphModel`, com três campos: o nome usado na linha de comando e nos arquivos de saída (`name`), a indicação de exigência de geometria (`requiresGeometry`) e a fábrica do grafo (`create`). A fábrica é uma `std::function` que recebe um `GraphBuildInput` e devolve um `NavigationGraph`, alias de `undirected::lwGraph<Vertex3D>`. O `GraphBuildInput` reúne referências ao mapa de altura e à malha extraída, além da largura, da escala vertical e da profundidade do terreno.

O campo `requiresGeometry` indica se a fábrica consome a malha. O laço experimental usa essa indicação para decidir se extrai a geometria antes de construir o grafo. Os quatro modelos registrados são:

+ `2_5d` com `createGrid2_5D`, que lê apenas o mapa de altura;
+ `voxel` com `createVoxelGraph`, que lê apenas o mapa de altura;
+ `vertex` com `createVertexToVertex`, que parte da malha;
+ `dual` com `createPolygonToPolygon`, que também parte da malha.

#text()[] \ #v(-1.5em)

A `createGrid2_5D` cria um vértice por pixel do mapa de altura, posicionado na altura $y = 1 + v (H - 1)$. Cada célula se liga aos vizinhos a leste, ao sul, a sudeste e a sudoeste, de modo que a vizinhança é de oito direções. O peso de cada aresta é a distância euclidiana tridimensional entre os vértices.

A `createVoxelGraph` constrói a grade voxelizada. Ela cria um vértice por pixel do mapa de altura, isto é, por coluna, com a altura arredondada para um número inteiro de _voxels_, sem construir o volume. Cada vértice se liga apenas aos vizinhos a leste e ao sul, ou seja, a vizinhança é de quatro direções sobre a superfície. O peso também é a distância euclidiana tridimensional, o que faz a diferença de altura entre colunas contribuir para o custo.

Os grafos de vértices e dual partem da malha extraída por Marching Cubes (@fig_pipeline). Como o volume é preenchido até a altura arredondada de cada coluna (ver @voxels), as três representações que não são a grade 2.5D usam alturas discretizadas.

A `createVertexToVertex` cria um vértice para cada vértice da malha. Para cada triângulo, conecta seus três vértices por arestas, e uma aresta repetida entre triângulos vizinhos é inserida uma única vez. 

A `createPolygonToPolygon` cria um vértice para cada triângulo, posicionado no seu baricentro. Duas faces que compartilham uma aresta da malha são ligadas por uma aresta cujo peso é a distância entre os baricentros. Essa fábrica supõe que vértices compartilhados entre triângulos tenham exatamente as mesmas coordenadas na malha.

Nenhuma fábrica aplica critério de transitabilidade. Todas as conexões geradas são mantidas, e a diferença de altura entre os vértices afeta apenas o peso das arestas. Por isso, os vértices de início e de destino das consultas ficam no mesmo componente conexo (ver @componente_conexo), e nenhuma busca da coleta terminou sem caminho, já que esse caso interrompe a execução com erro (ver @procedimento_testes).

== Instrumentação <instrumentacao>

A instrumentação reúne os mecanismos que registram as medições durante os testes: o procedimento que gera os terrenos e executa as buscas, a classe que acumula e exporta os resultados, o _script_ que repete as execuções em condições controladas e a interface de linha de comando que dá acesso a esses recursos.

=== Procedimento dos testes <procedimento_testes>

As quatro variáveis são avaliadas por funções próprias, `testScale`, `testLacunarity`, `testPersistence` e `testFrequency`, que implementam o procedimento descrito na @procedimento_metricas. Cada passo corresponde a um nível, e cada terreno recebe uma semente sorteada a partir da semente base da execução. Os resultados de um terreno só são registrados depois que todos os pares de consulta e algoritmos foram executados.

Na escala, a dimensão do terreno cresce a cada passo, e a altura e o comprimento de onda acompanham a dimensão, de modo que apenas a resolução muda entre os passos. A escala, portanto, não é um parâmetro do ruído, e sim a resolução da grade sobre a qual o mesmo relevo é amostrado. Na lacunaridade e na persistência, a dimensão e o comprimento de onda são fixos, e o parâmetro testado cresce linearmente do primeiro ao último passo. No comprimento de onda, a dimensão é fixa, e o comprimento de onda base assume uma lista fixa de valores. Como a frequência do ruído é o inverso do comprimento de onda, esse teste avalia a frequência do relevo.

Se o grafo resultante não tiver vértices, o terreno é refeito com outra semente. Se algum algoritmo não encontrar caminho entre os pares, a execução é interrompida com erro, pois isso indicaria falha na construção do grafo.

=== Statistics <statistics>

A classe `Statistics` acumula em memória os registros de cada execução, protegidos por um _mutex_, o que permite registrar resultados a partir de mais de uma _thread_. Cada registro, do tipo `Results`, reúne:

+ identificação: algoritmo, valor da variável testada, semente do terreno e índice do par de consulta;
+ grafo: tempo de construção, número de vértices e de arestas, memória estrutural e, nos grafos de vértices e dual, tempo de extração da malha;
+ busca: custo do caminho, tempo de execução, tempo de busca com repetições e número de repetições, número de vértices do caminho e comprimento geométrico;
+ contadores: vértices expandidos, vértices gerados, pico da lista aberta e chamadas da heurística;
+ terreno: número de máximos locais, fração de células elevadas, desvio padrão da altura e declividade média;
+ consulta: distância em linha reta entre início e destino, razão entre a heurística no início e o custo ótimo, subida acumulada e declividade máxima do caminho;
+ inicialização: tempo de inicialização dos vetores de estado da busca.

#text()[] \ #v(-1.5em)

As métricas de terreno e de consulta são calculadas depois das buscas, fora dos intervalos cronometrados. A fração de células elevadas conta as células com altura de pelo menos um desvio padrão acima da média, e os máximos locais são contados entre essas células, com vizinhança de oito direções.

A exportação grava um arquivo CSV, com cabeçalho e uma linha por registro. Os campos opcionais ficam vazios quando não se aplicam ao registro. O nome da coluna da variável testada é informado pelo próprio teste: Escala, Lacunaridade, Persistência ou Comprimento de Onda. Cada linha também traz o estado da máquina no início e no fim da execução, com a frequência do núcleo usado e a carga média do sistema, e o pico de memória do processo, que são os mesmos para todos os registros de um arquivo.

=== coleta_completa.sh <acquire>

O _script_ `coleta_completa.sh` conduz a campanha de coleta. Ele compila o executável em modo _Release_ e realiza cinco execuções. Em cada execução, roda um bloco para cada combinação de variável testada e representação, isto é, 16 blocos, cada um como um processo `tcc stats` separado, com dez terrenos por passo e quatro passos. A semente de cada execução é a semente base somada ao índice da execução.

A ordem dos blocos dentro de cada execução é embaralhada pelo algoritmo de Fisher-Yates, com um gerador de números pseudoaleatórios inicializado com a semente da execução. Assim, a ordem é reproduzível e muda entre as execuções, o que evita que uma mesma representação seja sempre medida no mesmo momento da campanha, quando o estado térmico da máquina pode ser diferente.

Entre blocos consecutivos de uma mesma sessão, o _script_ faz uma pausa de 60 segundos. Antes de cada bloco, espera até que a temperatura do pacote do processador fique em até 45 °C, por no máximo 15 minutos. Se esse limite for atingido, o bloco é iniciado mesmo assim. Antes e depois de cada bloco, o _script_ verifica se o notebook está ligado à tomada, porque a frequência do processador muda na bateria. Se não estiver, a coleta é abortada. Os contadores de _throttling_ térmico do núcleo e do pacote são lidos antes e depois de cada bloco. Se houver _throttling_, o bloco é descartado e refeito, em até três tentativas, e na última tentativa o resultado é mantido e sinalizado.

Os arquivos de saída e os registros da saída padrão e de erro de cada bloco ficam em uma pasta própria. Um manifesto registra, para cada tentativa, o horário de início, a duração, o código de saída, os eventos de _throttling_, as temperaturas inicial e final, a posição do bloco na ordem, o _commit_ do código, a existência de alterações não registradas no repositório e as opções de compilação. Cada bloco concluído é anotado em um arquivo de controle, o que permite retomar uma campanha interrompida sem repetir os blocos já concluídos. Durante a coleta, a suspensão do sistema é impedida com `systemd-inhibit`.

=== Interface de linha de comando (CLI) <cli>

A interface de linha de comando (CLI, do inglês _command-line interface_) é construída com a biblioteca CLI11 e reúne cinco subcomandos. O subcomando `test` executa uma geração visual com os parâmetros informados, e `heuristics` executa a mesma visualização comparando heurísticas no algoritmo Greedy Best-First Search. O subcomando `save` grava o mapa de ruído em um arquivo PNG, com a opção de salvar cada oitava separadamente. O subcomando `stats` executa a aquisição de uma variável em uma representação e recebe o número de terrenos por passo (`repetitions`), o número de passos, a semente base, o diretório de saída e, opcionalmente, os índices dos passos a executar. O subcomando `mcbench` mede o tempo de extração do Marching Cubes para uma lista de sementes. A CLI11 valida os parâmetros e rejeita opções desconhecidas e valores fora dos intervalos permitidos.

= Metodologia

Este capítulo descreve o método adotado para responder à questão central deste trabalho. Inicialmente, caracteriza-se o tipo de pesquisa. Em seguida, apresentam-se o ambiente experimental, as variáveis e os níveis de teste, o procedimento de coleta e as métricas, o protocolo estatístico utilizado na análise e as ameaças à validade dos resultados.

== Tipo de pesquisa

Este trabalho caracteriza-se como uma pesquisa experimental de natureza quantitativa, com abordagem comparativa e análise estatística. Os experimentos são conduzidos em terrenos gerados proceduralmente, nos quais cada fator de geração é variado isoladamente, mantendo-se os demais fixos @jain1991art. Os algoritmos de busca e as representações navegáveis são comparados sobre os mesmos terrenos, e as diferenças entre eles são avaliadas por meio de testes estatísticos sobre as medições coletadas.

== Ambiente <ambiente>

Os experimentos foram executados em um notebook com processador Intel Core i5-1235U, de arquitetura híbrida, com 12 processadores lógicos e 15 GiB de memória. A coleta foi feita em um sistema isolado, iniciado a partir de um pendrive bootável com Arch Linux, kernel 7.2.14-arch1-1. O código foi compilado com o compilador GCC 16.2.1 e com o CMake 4.4.5, em modo _Release_ e padrão C++20.

As dependências são as seguintes: a biblioteca CLI11, na versão 2.7.2, incluída no repositório; a nlohmann/json, na versão 3.11.3, obtida por URL; as bibliotecas glm 1.0.3 e Mesa 26.2.6, instaladas no sistema; e as bibliotecas IFCG @ifcg_lib e Graph @graph_lib, repositórios públicos do autor. 

O código deste trabalho está em repositório público, sob a licença MIT#footnote[Disponível em: #link("https://github.com/andrevbastos/TCC")]. A versão avaliada corresponde à _tag_ `v1.0-tcc`, que fixa as bibliotecas IFCG e Graph nos _commits_ usados na coleta. Os dados foram coletados com o _commit_ `c802ee3`, registrado no manifesto da campanha, do qual a _tag_ difere apenas por opções de aparência do visualizador. Os arquivos CSV brutos estão anexados à _release_ dessa _tag_.

Durante a coleta, o governador de frequência era `powersave`, com o _driver_ `intel_pstate`, e a busca foi fixada no núcleo 2 com `taskset`. O turbo do processador permaneceu desligado em todas as coletas, para reduzir a ocorrência de _throttling_ térmico.

== Variáveis

As variáveis independentes são a representação navegável, o algoritmo de busca e os parâmetros de geração do terreno. A escala, que define a resolução da grade (ver @procedimento_testes), e os parâmetros de lacunaridade, persistência e comprimento de onda do ruído são testados um de cada vez, com os demais mantidos nos valores fixos de cada teste, indicados na @niveis. As métricas de desempenho são o tempo de busca, o número de vértices expandidos e o pico da lista aberta. A métrica de qualidade do caminho é o custo relativo, definido como o custo do caminho dividido pelo custo obtido pelo algoritmo de Dijkstra no mesmo terreno, representação e par de consulta. A @tab_variaveis resume essas variáveis.

\
#figure(
  caption: [Variáveis independentes e dependentes do experimento.],
  supplement: "Tabela",
)[
  #tabela-abnt(
    columns: (auto, auto, 1fr),
    align: left,
    [*Tipo*], [*Variável*], [*Descrição*],
    [Independente], [Representação navegável], [Grade 2.5D, grade voxelizada, grafo de vértices e grafo dual da malha],
    [Independente], [Algoritmo de busca], [Dijkstra, A\*, Weighted A\* (peso 1,5) e Greedy Best-First Search],
    [Independente], [Parâmetro de geração], [Escala (resolução da grade), lacunaridade, persistência e comprimento de onda \ (testados separadamente, com altura máxima $H$ igual à dimensão do terreno)],
    [Dependente (desempenho)], [Tempo de busca], [Tempo da busca, excluída a construção do grafo, com mediana de repetições nas buscas abaixo de 5 ms],
    [Dependente (desempenho)], [Vértices expandidos], [Esforço da busca, medido em vértices expandidos],
    [Dependente (desempenho)], [Pico da lista aberta], [Maior número de elementos simultâneos na lista aberta],
    [Dependente (qualidade)], [Custo relativo], [Custo do caminho dividido pelo custo do Dijkstra no mesmo par de consulta],
  )
] <tab_variaveis>

== Níveis <niveis>

Na escala, a dimensão do terreno assume os valores 500, 600, 700 e 800, com altura igual à dimensão e comprimento de onda igual à metade dela, lacunaridade 2 e persistência 0,5. Na lacunaridade, o valor varia de 1,5 a 2,25 em quatro níveis equidistantes, com dimensão 500, comprimento de onda 250 e persistência 0,5. Na persistência, o valor varia de 0,3 a 0,7 nos mesmos moldes, com lacunaridade 2. No comprimento de onda, o valor base assume 200, 275, 350 e 500, com dimensão 500, lacunaridade 2 e persistência 0,5. Todos os testes usam seis oitavas. Em todos eles, a altura máxima $H$ é igual à dimensão do terreno, de modo que $H = 500$ nos testes de lacunaridade, persistência e comprimento de onda. Com essa altura, a declividade média dos terrenos varia de 0,84, no comprimento de onda 500, a 4,20, na persistência 0,7, e permanece entre 1,64 e 1,66 na escala, em que apenas a resolução muda (#link(<apendice_tamanho>)[Apêndice E]).

== Procedimento e métricas <procedimento_metricas>

O procedimento de coleta é executado separadamente para cada teste (escala, lacunaridade, persistência e comprimento de onda) e para cada representação navegável. Em cada teste, o parâmetro avaliado assume quatro níveis, e para cada nível são avaliados 50 terrenos, distribuídos em cinco execuções independentes, com dez terrenos em cada uma. Cada bloco, formado por um teste e uma representação, roda em um processo separado em cada execução. A semente de cada execução é derivada de uma semente base fixa, de modo que todas as representações medem os mesmos terrenos.

Para cada terreno, o mapa de altura é gerado por ruído de Perlin e convertido no grafo da representação avaliada. Em seguida, são definidas as duas diagonais do terreno como consultas de canto a canto. Os pontos de início e de destino são associados ao vértice mais próximo do grafo, e cada algoritmo é executado sobre cada consulta. Grafos vazios e consultas sem caminho são tratados como descrito na @procedimento_testes.

As métricas registradas são: o tempo de busca (ver @search); o número de vértices expandidos; o pico da lista aberta; e o custo relativo, calculado como o custo do caminho dividido pelo custo do algoritmo de Dijkstra na mesma consulta. Antes de cada cronometragem, a mesma busca é executada uma vez sem medição, para que a memória e o _cache_ estejam aquecidos. As pausas entre blocos, o controle de temperatura, a reexecução de blocos com _throttling_ térmico e o embaralhamento da ordem dos blocos são descritos na @acquire.

A extração da malha pelo algoritmo de Marching Cubes é medida em cada terreno dos grafos de vértices e dual, separadamente do tempo de construção do grafo. Como esses dois grafos usam a mesma malha, esse custo se soma ao tempo de construção de ambos.

== Protocolo estatístico

A unidade experimental é o terreno. Para cada terreno, calcula-se a média dos logaritmos naturais das medidas das duas consultas, e todas as métricas são analisadas nessa escala logarítmica, já que tempos, contagens e custos tendem a variar de forma multiplicativa.

Os dados são analisados por uma ANOVA em modelo de _split-plot_, conforme @anova. O nível do parâmetro é um fator entre terrenos, pois cada nível tem seus próprios terrenos. O algoritmo e a representação são fatores dentro do terreno, medidos sobre o mesmo terreno. Cada efeito dentro do terreno é testado contra sua interação com o terreno, e os graus de liberdade são corrigidos pelo método de Greenhouse-Geisser em todos os efeitos dentro do terreno, sem teste prévio de esfericidade. O nível de significância é α = 0,05.

O teste _post hoc_ de Tukey, descrito na @tukey, é aplicado depois da ANOVA de duas formas. Dentro do terreno, comparam-se as representações para cada algoritmo e os algoritmos para cada representação, com o erro da interação. Entre níveis, comparam-se os níveis para cada par de algoritmo e representação, tratados como grupos independentes. O custo relativo é analisado apenas para os algoritmos Weighted A\* e Greedy Best-First Search. Para o algoritmo de Dijkstra, ele é igual a 1 por definição. Para o algoritmo A\*, também é igual a 1, pois o peso de cada aresta é a distância euclidiana entre seus extremos, o que torna a heurística consistente (ver @heuristicas).

A normalidade dos resíduos é verificada pelo teste de Shapiro-Wilk, separadamente dentro do terreno e entre terrenos. Como esse teste rejeita desvios pequenos quando o número de observações é grande, a estatística W é lida junto com o valor de p. As análises são feitas em Python, com as versões listadas na @ambiente.

== Ameaças <ameacas>

Quanto à validade interna, o tempo de busca inclui a inicialização dos vetores de estado da busca, que cresce com o número de vértices e pesa mais, proporcionalmente, em buscas com poucas expansões. Esse tempo de inicialização é medido separadamente para cada grafo, o que permite estimar a sua parcela no tempo de busca. Para o algoritmo de Dijkstra e o algoritmo A\*, essa parcela fica entre 0,28% e 0,46% do tempo de busca (@tab_astar_dij).

Quanto à validade de construção, o peso do algoritmo Weighted A\* foi fixado em 1,5, de modo que os resultados se referem a esse valor. O custo relativo é comparável dentro de cada representação, pois usa o mesmo grafo como referência, mas não é diretamente comparável entre representações.

As diferenças entre as representações também misturam a estrutura do grafo e a geometria. Com $H = 500$ em uma grade de 500 × 500, o relevo é íngreme, e a malha extraída pelo Marching Cubes forma paredes verticais entre colunas vizinhas. Por isso, o grafo de vértices tem entre 2,1 e 6,5 vértices por coluna do mapa de altura, e o grafo dual, entre 4,1 e 12,9 (#link(<apendice_tamanho>)[Apêndice E]). Além disso, a superfície extraída passa entre o último _voxel_ preenchido e o primeiro vazio de cada coluna, de modo que os vértices e os baricentros da malha não ocupam as coordenadas dos vértices das grades. Entre as duas grades, a comparação mistura a altura discretizada e a vizinhança, de quatro direções na grade voxelizada e de oito na grade 2.5D.

Quanto à validade estatística, os resíduos não seguem distribuição normal pelo teste de Shapiro-Wilk, sobretudo dentro do terreno. A transformação logarítmica e o desenho balanceado, com o mesmo número de terrenos por nível, tendem a reduzir o efeito dessa violação sobre a ANOVA @montgomery2013design, mas os valores de p devem ser lidos com cautela.

Quanto à validade externa, os terrenos são gerados apenas por ruído de Perlin, em um único computador e sem obstáculos dinâmicos. Os resultados se referem a esse tipo de terreno e a esse ambiente. As consultas ligam apenas cantos opostos do terreno. Para o algoritmo de Dijkstra, isso equivale a percorrer o grafo inteiro, já que o destino está entre os últimos vértices retirados da lista aberta, e consultas mais curtas ou com extremos aleatórios podem se comportar de outro modo.

= Resultados <resultados>

Este capítulo apresenta as quatro métricas (tempo de busca, vértices expandidos, pico da lista aberta e custo relativo) nos quatro testes de geração. Os valores são médias geométricas, e os efeitos são apresentados pelo eta-quadrado parcial ($eta_p^2$, ver @eta_parcial) e pela razão entre os níveis extremos. A ANOVA em modelo _split-plot_, com correção de Greenhouse-Geisser e α = 0,05, e os testes de Tukey estão nos apêndices (Apêndices #link(<apendice_anova>)[A] e #link(<apendice_tukey>)[B]). Dentro do terreno, o teste de Shapiro-Wilk rejeita a normalidade dos resíduos em todas as métricas (p < 0,001), o que é tratado na @ameacas. Os efeitos de algoritmo e de representação, comuns aos quatro testes, são apresentados uma única vez na @res_comuns.

== Efeitos comuns aos testes <res_comuns>

Nos quatro testes, o tempo de busca segue a mesma ordem entre os algoritmos: o algoritmo Greedy Best-First Search é o mais rápido, seguido dos algoritmos Weighted A\*, Dijkstra e A\* (@tab_comum_tempo). A redução de vértices expandidos pelo algoritmo A\* em relação ao algoritmo de Dijkstra depende da representação (@tab_astar_dij). Ela é de 35% a 42% na grade 2.5D, de 32% a 35% no grafo de vértices e de 19% a 23% no grafo dual. Na grade voxelizada, é de apenas cerca de 3%, e a diferença não é significativa (p entre 0,10 e 0,23). Essa economia não aparece no tempo. Na grade 2.5D, os dois algoritmos não diferem em nenhum teste (razão de tempo entre o algoritmo A\* e o de Dijkstra entre 0,99 e 1,04), e na grade voxelizada o algoritmo A\* gasta entre 1,22 e 1,26 vez o tempo do algoritmo de Dijkstra (@tab_astar_dij).

O pico da lista aberta inverte essa relação. O algoritmo de Dijkstra tem o menor pico entre os algoritmos em todos os testes, e o algoritmo Weighted A\* tem o maior (@tab_comum_pico). Entre as representações, o grafo de vértices tem o maior pico e a grade voxelizada o menor, e o grafo dual, que expande mais vértices, fica abaixo do grafo de vértices.

As representações seguem a mesma ordem de tempo nos quatro testes, da mais rápida à mais lenta: grade 2.5D, grade voxelizada, grafo de vértices e grafo dual. A interação entre algoritmo e representação, com $eta_p^2$ entre 0,89 e 0,93 no tempo, altera essa ordem para alguns algoritmos. No teste de escala, o algoritmo de Dijkstra leva 135,4 ms na grade voxelizada e 216,0 ms na grade 2.5D, enquanto o algoritmo Weighted A\* leva 128,2 ms na voxelizada e 22,6 ms na grade 2.5D (médias dos quatro níveis).

O algoritmo é o fator de maior efeito sobre o custo relativo, com $eta_p^2$ entre 0,978 e 0,989. O algoritmo Weighted A\* fica em torno de 1,03 vez o custo do algoritmo de Dijkstra, e o algoritmo Greedy Best-First Search, entre 1,18 e 1,28 vez. O grafo de vértices tem o maior custo relativo médio entre as representações em todos os testes (@tab_comum_custo).

O tamanho dos grafos também difere entre as representações (@tab_tamanho_grafos). Nas grades, o número de vértices é igual ao número de colunas do mapa de altura e não muda com o relevo, enquanto nos grafos de vértices e dual ele cresce com o relevo. O grafo dual tem cerca do dobro dos vértices do grafo de vértices e praticamente o mesmo número de arestas, e a grade 2.5D tem cerca de quatro arestas por vértice, o dobro da grade voxelizada. A construção dos grafos, que não entra no tempo de busca, leva entre 0,03 e 0,09 s nas grades, entre 0,11 e 0,52 s no grafo de vértices e entre 2,51 e 10,72 s no grafo dual. A extração da malha pelo Marching Cubes, comum aos dois últimos, acrescenta entre 0,79 e 4,18 s (@tab_construcao).

\
#figure(
  caption: [Tempo de busca (ms) por algoritmo e representação em cada teste.],
  supplement: "Tabela",
)[
  #tabela-abnt(
    columns: (auto, 1fr, 1fr, 1fr, 1fr),
    align: (left, right, right, right, right),
    [*Fator*], [*Escala*], [*Lacunaridade*], [*Persistência*], [*Comp. de onda*],
    [Dijkstra], [386,0], [212,7], [243,1], [203,9],
    [A\*], [414,1], [220,7], [255,6], [212,8],
    [WA\*], [104,3], [48,5], [68,5], [33,7],
    [GBFS], [2,3], [1,4], [1,7], [1,3],
    table.hline(stroke: 0.5pt),
    [Grade 2.5D], [33,0], [18,0], [21,5], [15,6],
    [Grade voxelizada], [43,6], [25,5], [27,0], [24,7],
    [Grafo de vértices], [110,4], [57,4], [76,2], [47,9],
    [Grafo dual], [244,7], [122,3], [160,9], [106,0],
  )
  #v(.5em)
  Fonte: Elaborado pelo autor.
] <tab_comum_tempo>

\
#figure(
  caption: [Vértices expandidos por algoritmo e representação em cada teste.],
  supplement: "Tabela",
)[
  #tabela-abnt(
    columns: (auto, 1fr, 1fr, 1fr, 1fr),
    align: (left, right, right, right, right),
    [*Fator*], [*Escala*], [*Lacunaridade*], [*Persistência*], [*Comp. de onda*],
    [Dijkstra], [860 130], [507 375], [553 502], [490 377],
    [A\*], [660 544], [373 948], [421 981], [359 044],
    [WA\*], [154 972], [75 438], [103 208], [51 794],
    [GBFS], [1 797], [1 299], [1 629], [1 214],
    table.hline(stroke: 0.5pt),
    [Grade 2.5D], [40 678], [23 887], [28 148], [20 463],
    [Grade voxelizada], [86 526], [54 257], [57 075], [52 689],
    [Grafo de vértices], [128 806], [73 738], [97 346], [61 488],
    [Grafo dual], [349 077], [194 481], [251 068], [166 960],
  )
  #v(.5em)
  Fonte: Elaborado pelo autor.
] <tab_comum_exp>

\
#figure(
  caption: [Razões entre o A\* e o Dijkstra por representação.],
  supplement: "Tabela",
)[
  #set par(justify: false)
  #tabela-abnt(
    columns: (auto, 1fr, 1fr, 1fr, 1fr),
    align: (left, right, right, right, right),
    [*Representação*], [*Expandidos A\*/Dij.*], [*p (Tukey)*], [*Tempo A\*/Dij.*], [*Inicialização (%)*],
    [Grade 2.5D], [0,58–0,65], [< 0,001], [0,99–1,04], [0,28–0,29],
    [Grade voxelizada], [0,96–0,97], [0,10–0,23], [1,22–1,26], [0,36–0,46],
    [Grafo de vértices], [0,66–0,68], [< 0,001], [0,93–0,97], [0,30–0,35],
    [Grafo dual], [0,77–0,81], [< 0,001], [1,02–1,05], [0,35–0,39],
  )
  #v(.5em)
  Fonte: Elaborado pelo autor. \
  #text(size: 10pt)[Nota: faixas entre os quatro testes. Razões: médias geométricas entre terrenos da razão no mesmo terreno. p: comparação de Tukey dentro do terreno entre A\* e Dijkstra em vértices expandidos. Inicialização: tempo de inicialização dos vetores de estado dividido pelo tempo de busca, média geométrica, Dijkstra e A\*.]
] <tab_astar_dij>

\
#figure(
  caption: [Pico da lista aberta por algoritmo e representação em cada teste.],
  supplement: "Tabela",
)[
  #tabela-abnt(
    columns: (auto, 1fr, 1fr, 1fr, 1fr),
    align: (left, right, right, right, right),
    [*Fator*], [*Escala*], [*Lacunaridade*], [*Persistência*], [*Comp. de onda*],
    [Dijkstra], [2 048], [1 523], [1 741], [1 463],
    [A\*], [4 180], [3 190], [3 500], [3 094],
    [WA\*], [6 743], [4 951], [5 401], [4 754],
    [GBFS], [2 882], [2 186], [2 335], [2 134],
    table.hline(stroke: 0.5pt),
    [Grade 2.5D], [3 912], [2 934], [3 166], [2 829],
    [Grade voxelizada], [2 074], [1 600], [1 668], [1 607],
    [Grafo de vértices], [5 182], [3 806], [4 356], [3 583],
    [Grafo dual], [3 958], [2 943], [3 340], [2 818],
  )
  #v(.5em)
  Fonte: Elaborado pelo autor.
] <tab_comum_pico>

\
#figure(
  caption: [Custo relativo por algoritmo e representação em cada teste (somente Weighted A\* e Greedy Best-First Search).],
  supplement: "Tabela",
)[
  #tabela-abnt(
    columns: (auto, 1fr, 1fr, 1fr, 1fr),
    align: (left, right, right, right, right),
    [*Fator*], [*Escala*], [*Lacunaridade*], [*Persistência*], [*Comp. de onda*],
    [WA\*], [1,037], [1,034], [1,030], [1,036],
    [GBFS], [1,228], [1,204], [1,281], [1,179],
    table.hline(stroke: 0.5pt),
    [Grade 2.5D], [1,123], [1,099], [1,142], [1,087],
    [Grade voxelizada], [1,116], [1,105], [1,137], [1,095],
    [Grafo de vértices], [1,157], [1,145], [1,173], [1,133],
    [Grafo dual], [1,118], [1,115], [1,142], [1,107],
  )
  #v(.5em)
  Fonte: Elaborado pelo autor.
] <tab_comum_custo>

\
#figure(
  caption: [Tamanho dos grafos por representação em cada teste.],
  supplement: "Tabela",
)[
  #set par(justify: false)
  #tabela-abnt(
    columns: (auto, auto, 1fr, 1fr, 1fr, 1fr),
    align: (left, right, right, right, right, right),
    [*Representação*], [*|A|/|V|*], [*Escala*], [*Lacunaridade*], [*Persistência*], [*Comp. de onda*],
    [Grade 2.5D], [3,99], [250–640], [250], [250], [250],
    [Grade voxelizada], [2,00], [250–640], [250], [250], [250],
    [Grafo de vértices], [2,99–3,00], [776–1 998], [571–979], [549–1 617], [516–908],
    [Grafo dual], [1,50], [1 547–3 989], [1 139–1 953], [1 094–3 226], [1 030–1 812],
  )
  #v(.5em)
  Fonte: Elaborado pelo autor. \
  #text(size: 10pt)[Nota: colunas dos testes com o número de vértices |V|, em milhares, do menor ao maior nível (média dos 50 terrenos de cada nível). Valores por nível no #link(<apendice_tamanho>)[Apêndice E].]
] <tab_tamanho_grafos>

\
#figure(
  caption: [Tempo de construção dos grafos e de extração da malha (s) em cada teste.],
  supplement: "Tabela",
)[
  #set par(justify: false)
  #tabela-abnt(
    columns: (auto, 1fr, 1fr, 1fr, 1fr),
    align: (left, right, right, right, right),
    [*Etapa*], [*Escala*], [*Lacunaridade*], [*Persistência*], [*Comp. de onda*],
    [Grade 2.5D], [0,03–0,08], [0,03], [0,03], [0,03],
    [Grade voxelizada], [0,03–0,09], [0,03], [0,03], [0,03],
    [Grafo de vértices], [0,21–0,52], [0,12–0,28], [0,12–0,44], [0,11–0,25],
    [Grafo dual], [4,09–10,72], [2,82–5,12], [2,71–8,85], [2,51–4,88],
    [Extração da malha (Marching Cubes)], [1,13–4,18], [0,86–1,06], [0,84–1,53], [0,79–1,06],
  )
  #v(.5em)
  Fonte: Elaborado pelo autor. \
  #text(size: 10pt)[Nota: médias geométricas por nível, do menor ao maior entre os níveis. A construção não inclui a extração da malha, que é a mesma para o grafo de vértices e o grafo dual e se soma à construção de ambos.]
] <tab_construcao>

== Tempo de busca <res_tempo>

Na escala, o tempo de busca quase triplica entre os níveis 500 e 800 (razão 2,81; $eta_p^2$ = 0,901; @tab_nivel_tempo). O efeito é quase uniforme entre algoritmos e representações, com interações pequenas ($eta_p^2$ de 0,082 e 0,071). O maior desvio está no algoritmo Weighted A\* na grade 2.5D, cuja razão é 3,95, enquanto os demais casos ficam entre 2,26 e 3,68 (@fig_res_escala_tempo).

Com a lacunaridade, o tempo de busca mais que dobra entre 1,5 e 2,25 (razão 2,23; $eta_p^2$ = 0,853). Aqui o efeito não é uniforme, e as interações com o algoritmo ($eta_p^2$ = 0,639) e com a representação ($eta_p^2$ = 0,698) são grandes. O algoritmo Weighted A\* é o mais sensível: fora da grade voxelizada (razão 1,80), seu tempo cresce entre 7,56 e 10,73 vezes entre os níveis extremos, com o maior efeito na grade 2.5D, enquanto os algoritmos de Dijkstra e A\* ficam entre 1,20 e 2,42 (@fig_res_lac_tempo).

Com a persistência, o tempo de busca quadruplica de 0,3 para 0,7 (razão 4,09; $eta_p^2$ = 0,951; @tab_nivel_tempo). O efeito não é uniforme, com interação entre nível e representação de $eta_p^2$ = 0,915 e entre nível e algoritmo de $eta_p^2$ = 0,793. O algoritmo Weighted A\* volta a ser o mais sensível: seu tempo cresce 39,93 vezes na grade 2.5D e 34,49 vezes no grafo de vértices entre os mesmos níveis, mas apenas 2,44 vezes na grade voxelizada (@fig_res_pers_tempo).

No comprimento de onda, o tempo de busca cai para 0,41 do valor inicial entre 200 e 500 ($eta_p^2$ = 0,885; @tab_nivel_tempo). As interações também são grandes, com $eta_p^2$ de 0,730 para o algoritmo e 0,759 para a representação. O tempo do algoritmo Weighted A\* na grade 2.5D cai para 0,065 do valor inicial, a maior queda entre todas as combinações (@fig_res_comp_tempo).

\
#figure(
  caption: [Tempo de busca (ms) por nível em cada teste.],
  supplement: "Tabela",
)[
  #tabela-abnt(
    columns: (auto, 1fr, 1fr, 1fr, 1fr, auto, auto, auto),
    align: (left, right, right, right, right, right, right, right),
    [*Teste*], [*Nível 1*], [*Nível 2*], [*Nível 3*], [*Nível 4*], [*Razão 4/1*], [*p*], [*$eta_p^2$*],
    [Escala], [46,1 \ #text(size: 9pt)[(500)]], [69,7 \ #text(size: 9pt)[(600)]], [93,1 \ #text(size: 9pt)[(700)]], [129,7 \ #text(size: 9pt)[(800)]], [2,81], [< 0,001], [0,901],
    [Lacunaridade], [29,6 \ #text(size: 9pt)[(1,5)]], [35,8 \ #text(size: 9pt)[(1,75)]], [46,2 \ #text(size: 9pt)[(2)]], [65,9 \ #text(size: 9pt)[(2,25)]], [2,23], [< 0,001], [0,853],
    [Persistência], [27,5 \ #text(size: 9pt)[(0,3)]], [37,2 \ #text(size: 9pt)[(0,433)]], [61,8 \ #text(size: 9pt)[(0,567)]], [112,5 \ #text(size: 9pt)[(0,7)]], [4,09], [< 0,001], [0,951],
    [Comprimento de onda], [58,6 \ #text(size: 9pt)[(200)]], [42,3 \ #text(size: 9pt)[(275)]], [32,8 \ #text(size: 9pt)[(350)]], [24,1 \ #text(size: 9pt)[(500)]], [0,41], [< 0,001], [0,885],
  )
  #v(.5em)
  Fonte: Elaborado pelo autor.
] <tab_nivel_tempo>

\
#figure(
  caption: [Tempo de busca em função da escala, \ por algoritmo e representação.],
  supplement: "Figura",
)[
  #v(1.5em)
  #image("images/scale_tempo.png", width: 100%)
  #v(.5em)
 Fonte: Elaborado pelo autor.
] <fig_res_escala_tempo> \ #v(-1.5em)

\
#figure(
  caption: [Tempo de busca em função da lacunaridade, \ por algoritmo e representação.],
  supplement: "Figura",
)[
  #v(1.5em)
  #image("images/lac_tempo.png", width: 100%)
  #v(.5em)
 Fonte: Elaborado pelo autor.
] <fig_res_lac_tempo> \ #v(-1.5em)

\
#figure(
  caption: [Tempo de busca em função da persistência, \ por algoritmo e representação.],
  supplement: "Figura",
)[
  #v(1.5em)
  #image("images/pers_tempo.png", width: 100%)
  #v(.5em)
 Fonte: Elaborado pelo autor.
] <fig_res_pers_tempo> \ #v(-1.5em)

\
#figure(
  caption: [Tempo de busca em função do comprimento de onda base, \ por algoritmo e representação.],
  supplement: "Figura",
)[
  #v(1.5em)
  #image("images/frequency_tempo.png", width: 100%)
  #v(.5em)
 Fonte: Elaborado pelo autor.
] <fig_res_comp_tempo> \ #v(-1.5em)

== Vértices expandidos <res_expandidos>

Os vértices expandidos seguem a mesma direção do tempo nos quatro testes. Na escala, na lacunaridade e na persistência, o número de expansões sobe com o nível, e no comprimento de onda cai, com $eta_p^2$ entre 0,79 e 0,93 (@tab_nivel_exp). A razão entre os níveis extremos varia de 0,44 a 3,80 entre os testes. As figuras por teste estão no #link(<apendice_figuras>)[Apêndice C] (Figuras #ref(<fig_apx_scale_expandidos>, supplement: none), #ref(<fig_apx_lac_expandidos>, supplement: none), #ref(<fig_apx_pers_expandidos>, supplement: none) e #ref(<fig_apx_frequency_expandidos>, supplement: none)).

A exceção é o algoritmo de Dijkstra nas grades 2.5D e voxelizada, cujo número de vértices expandidos só muda com a escala. Na lacunaridade, na persistência e no comprimento de onda, a razão entre os níveis extremos é de 1,00 nas duas grades. A diferença entre os níveis extremos não é significativa na lacunaridade (Tukey, p = 0,529 na grade 2.5D e p = 0,632 na grade voxelizada, indicada pelo sobrescrito da @tab_tukey_niveis) e, nos outros dois testes, é significativa, mas sem relevância prática.

\
#figure(
  caption: [Vértices expandidos por nível em cada teste.],
  supplement: "Tabela",
)[
  #tabela-abnt(
    columns: (auto, 1fr, 1fr, 1fr, 1fr, auto, auto, auto),
    align: (left, right, right, right, right, right, right, right),
    [*Teste*], [*Nível 1*], [*Nível 2*], [*Nível 3*], [*Nível 4*], [*Razão 4/1*], [*p*], [*$eta_p^2$*],
    [Escala], [69 781 \ #text(size: 9pt)[(500)]], [100 618 \ #text(size: 9pt)[(600)]], [129 516 \ #text(size: 9pt)[(700)]], [174 030 \ #text(size: 9pt)[(800)]], [2,49], [< 0,001], [0,828],
    [Lacunaridade], [47 145 \ #text(size: 9pt)[(1,5)]], [56 213 \ #text(size: 9pt)[(1,75)]], [70 756 \ #text(size: 9pt)[(2)]], [99 115 \ #text(size: 9pt)[(2,25)]], [2,10], [< 0,001], [0,790],
    [Persistência], [43 945 \ #text(size: 9pt)[(0,3)]], [57 721 \ #text(size: 9pt)[(0,433)]], [92 691 \ #text(size: 9pt)[(0,567)]], [167 002 \ #text(size: 9pt)[(0,7)]], [3,80], [< 0,001], [0,929],
    [Comprimento de onda], [88 368 \ #text(size: 9pt)[(200)]], [63 768 \ #text(size: 9pt)[(275)]], [50 966 \ #text(size: 9pt)[(350)]], [38 539 \ #text(size: 9pt)[(500)]], [0,44], [< 0,001], [0,840],
  )
  #v(.5em)
  Fonte: Elaborado pelo autor.
] <tab_nivel_exp>

== Pico da lista aberta <res_pico>

O pico da lista aberta segue a direção do tempo: sobe na escala, na lacunaridade e na persistência, e cai no comprimento de onda, com $eta_p^2$ entre 0,935 e 0,983 (@tab_nivel_pico). Na escala, a interação com a representação é pequena ($eta_p^2$ = 0,025; p = 0,098), e nos outros testes é grande, entre 0,73 e 0,91. A exceção é o algoritmo Weighted A\*: na lacunaridade, o pico cai na grade voxelizada (razão 0,64) e sobe na grade 2.5D (razão 2,35; @tab_tukey_niveis).

\
#figure(
  caption: [Pico da lista aberta por nível em cada teste.],
  supplement: "Tabela",
)[
  #tabela-abnt(
    columns: (auto, 1fr, 1fr, 1fr, 1fr, auto, auto, auto),
    align: (left, right, right, right, right, right, right, right),
    [*Teste*], [*Nível 1*], [*Nível 2*], [*Nível 3*], [*Nível 4*], [*Razão 4/1*], [*p*], [*$eta_p^2$*],
    [Escala], [2 783 \ #text(size: 9pt)[(500)]], [3 354 \ #text(size: 9pt)[(600)]], [3 925 \ #text(size: 9pt)[(700)]], [4 541 \ #text(size: 9pt)[(800)]], [1,63], [< 0,001], [0,976],
    [Lacunaridade], [2 361 \ #text(size: 9pt)[(1,5)]], [2 509 \ #text(size: 9pt)[(1,75)]], [2 780 \ #text(size: 9pt)[(2)]], [3 193 \ #text(size: 9pt)[(2,25)]], [1,35], [< 0,001], [0,940],
    [Persistência], [2 305 \ #text(size: 9pt)[(0,3)]], [2 538 \ #text(size: 9pt)[(0,433)]], [3 161 \ #text(size: 9pt)[(0,567)]], [4 155 \ #text(size: 9pt)[(0,7)]], [1,80], [< 0,001], [0,983],
    [Comprimento de onda], [3 025 \ #text(size: 9pt)[(200)]], [2 688 \ #text(size: 9pt)[(275)]], [2 472 \ #text(size: 9pt)[(350)]], [2 284 \ #text(size: 9pt)[(500)]], [0,76], [< 0,001], [0,935],
  )
  #v(.5em)
  Fonte: Elaborado pelo autor.
] <tab_nivel_pico>

== Custo relativo <res_custo>

Ao contrário do tempo, o custo relativo não varia significativamente com a escala (p = 0,059; $eta_p^2$ = 0,037). Na lacunaridade e na persistência, ele sobe, e no comprimento de onda cai, com $eta_p^2$ entre 0,86 e 0,96 (@tab_nivel_custo). As figuras por teste estão no #link(<apendice_figuras>)[Apêndice C] (Figuras #ref(<fig_apx_scale_custo_relativo>, supplement: none), #ref(<fig_apx_lac_custo_relativo>, supplement: none), #ref(<fig_apx_pers_custo_relativo>, supplement: none) e #ref(<fig_apx_frequency_custo_relativo>, supplement: none)).

Essa variação vem sobretudo do algoritmo Greedy Best-First Search. Na persistência, seu custo relativo aumenta por um fator entre 1,34 e 1,63 entre os níveis extremos em todas as representações, enquanto o do algoritmo Weighted A\* diminui ligeiramente, por um fator entre 0,97 e 0,99 (@tab_tukey_niveis).

\
#figure(
  caption: [Custo relativo por nível em cada teste (somente Weighted A\* e Greedy Best-First Search).],
  supplement: "Tabela",
)[
  #tabela-abnt(
    columns: (auto, 1fr, 1fr, 1fr, 1fr, auto, auto, auto),
    align: (left, right, right, right, right, right, right, right),
    [*Teste*], [*Nível 1*], [*Nível 2*], [*Nível 3*], [*Nível 4*], [*Razão 4/1*], [*p*], [*$eta_p^2$*],
    [Escala], [1,125 \ #text(size: 9pt)[(500)]], [1,130 \ #text(size: 9pt)[(600)]], [1,128 \ #text(size: 9pt)[(700)]], [1,132 \ #text(size: 9pt)[(800)]], [1,006], [0,059], [0,037],
    [Lacunaridade], [1,075 \ #text(size: 9pt)[(1,5)]], [1,096 \ #text(size: 9pt)[(1,75)]], [1,125 \ #text(size: 9pt)[(2)]], [1,170 \ #text(size: 9pt)[(2,25)]], [1,088], [< 0,001], [0,861],
    [Persistência], [1,072 \ #text(size: 9pt)[(0,3)]], [1,099 \ #text(size: 9pt)[(0,433)]], [1,164 \ #text(size: 9pt)[(0,567)]], [1,270 \ #text(size: 9pt)[(0,7)]], [1,185], [< 0,001], [0,963],
    [Comprimento de onda], [1,156 \ #text(size: 9pt)[(200)]], [1,113 \ #text(size: 9pt)[(275)]], [1,090 \ #text(size: 9pt)[(350)]], [1,065 \ #text(size: 9pt)[(500)]], [0,921], [< 0,001], [0,906],
  )
  #v(.5em)
  Fonte: Elaborado pelo autor.
] <tab_nivel_custo>

= Discussões

Os resultados respondem em parte à questão central deste trabalho. As explicações causais propostas a seguir são hipóteses, que não foram isoladas experimentalmente.

== Esforço de busca e tempo

A expectativa de que menos expansões levem a uma busca mais rápida não se confirma para o algoritmo A\*: ele expande menos vértices que o algoritmo de Dijkstra, mas não é mais rápido que ele (@res_comuns). Uma hipótese para esse resultado está no custo por vértice. O pico da lista aberta do algoritmo A\* é cerca de duas vezes o do algoritmo de Dijkstra em todos os testes (@tab_comum_pico), o que sugere mais operações sobre a estrutura de prioridade, além do cálculo da heurística a cada vértice gerado. Os valores por representação são compatíveis com essa hipótese (@tab_astar_dij): onde a redução de expansões é grande, como na grade 2.5D, os dois algoritmos levam o mesmo tempo, e onde ela é quase nula, como na grade voxelizada, o algoritmo A\* é mais lento, o que indica um custo maior por vértice expandido. A inicialização dos vetores de estado, abaixo de 0,5% do tempo de busca, não explica essa diferença. Confirmar essa hipótese exigiria medir essas operações separadamente.

O algoritmo Greedy Best-First Search está no extremo oposto. Na escala, ele expande cerca de 1/480 dos vértices expandidos pelo algoritmo de Dijkstra e é o mais rápido em todos os testes. O ganho tem um custo, já que seus caminhos ficam entre 18% e 28% mais caros que os do algoritmo de Dijkstra (@tab_comum_custo). O algoritmo Weighted A\*, com peso 1,5, fica em um ponto intermediário, com custo entre 3% e 4% acima do de referência. A ponderação da heurística, na formulação de #cite(<pohl1970heuristic>, form: "prose"), troca a garantia de caminho ótimo por uma busca menos extensa, e os valores observados seguem essa troca. Além disso, o algoritmo Weighted A\* é mais rápido que os algoritmos de Dijkstra e A\*, mas tem o maior pico da lista aberta (@tab_comum_pico). Tempo e memória, portanto, não devem ser tratados como um único critério.

== Efeito da representação

A ordem entre as representações depende do algoritmo: entre as duas grades, a 2.5D é a mais lenta para o algoritmo de Dijkstra e a mais rápida para o algoritmo Weighted A\* (@res_comuns). A escolha da representação, portanto, só pode ser feita em conjunto com a do algoritmo. O grafo dual, a representação mais lenta, também é a que mais expande vértices, o que é coerente com a sua construção, na qual cada polígono da malha se torna um vértice, o que lhe dá cerca do dobro dos vértices do grafo de vértices (@tab_comum_exp e @tab_tamanho_grafos). Nesses dois grafos, o número de vértices cresce com o relevo, de modo que parte do efeito do terreno sobre eles decorre do tamanho do grafo, enquanto nas grades o tamanho é fixo para cada dimensão.

Uma hipótese para o algoritmo de Dijkstra ser mais lento na grade 2.5D que na grade voxelizada é o número de arestas. Com vizinhança de oito direções, a grade 2.5D tem cerca de quatro arestas por vértice, o dobro da grade voxelizada (@tab_tamanho_grafos), e o algoritmo de Dijkstra, que expande praticamente todos os vértices, examina todas elas. A comparação, porém, também envolve a altura discretizada da grade voxelizada, e os dois efeitos não foram separados (@ameacas).

O grafo de vértices tem o maior custo relativo médio entre as representações. Esse resultado deve ser lido com cautela, porque o custo relativo toma como referência o algoritmo de Dijkstra em cada representação e, por isso, não é diretamente comparável entre elas, como discutido nas ameaças à validade (@ameacas).

Além disso, o tempo de busca não inclui a construção dos grafos, cujo custo difere entre as representações (@tab_construcao). Nas grades, a construção leva menos de 0,1 s. No grafo dual, a construção e a extração da malha pelo Marching Cubes somam entre cerca de 3,3 e 14,9 s por terreno, enquanto o tempo médio de busca nessa representação fica entre 106 e 245 ms (@tab_comum_tempo). O critério de tempo de busca, portanto, favorece os grafos de vértices e dual, e uma comparação de desempenho total depende do número de buscas feitas sobre o mesmo grafo.

== Efeito das características do terreno

A escala aumenta o esforço sem alterar significativamente a qualidade relativa do caminho. O tempo de busca quase triplica entre os níveis extremos (razão 2,81), enquanto o custo relativo não varia de forma significativa (p = 0,059). Lacunaridade e persistência, que aumentam o detalhe do relevo, elevam tempo, expansões e custo. O mesmo sentido se observa quando o comprimento de onda base diminui, pois as feições do relevo ficam menores: o tempo de busca cai para 0,41 do valor inicial quando o valor sobe de 200 para 500 (@tab_nivel_tempo).

A persistência tem o maior efeito sobre o tempo, que quadruplica entre os níveis extremos (razão 4,09). O custo também responde a ela, mas de forma desigual entre os algoritmos. O custo do algoritmo Greedy Best-First Search aumenta entre 1,34 e 1,63 vez em todas as representações, enquanto o do algoritmo Weighted A\* diminui levemente (@tab_tukey_niveis). Uma hipótese é que esse algoritmo, que orienta a expansão apenas pela estimativa até o destino e ignora o custo já percorrido, siga caminhos mais caros em relevos mais irregulares. Essa hipótese não foi testada diretamente.

O algoritmo Weighted A\* também mostra que o efeito do terreno depende da representação: sob variação de persistência, seu tempo cresce muito mais na grade 2.5D que na voxelizada (@fig_res_pers_tempo). Já o algoritmo de Dijkstra é a exceção nas grades, pois seu número de vértices expandidos não responde à lacunaridade, à persistência nem ao comprimento de onda (@res_expandidos). Essa constância decorre das consultas. Como o destino é o canto oposto do terreno, ele está entre os últimos vértices retirados da lista aberta, e o algoritmo de Dijkstra expande entre 99,8% e 100% dos vértices das grades. Como o número de vértices das grades não muda com esses parâmetros, o número de vértices expandidos também não muda. Nos grafos de vértices e dual, a cobertura também fica acima de 99,4%, mas o número de vértices cresce com o relevo.

== Recomendações <recomendacoes>

A @tab_recomendacoes resume, para cada prioridade, a combinação de representação e algoritmo indicada pelos resultados. As recomendações valem nas condições testadas, com as limitações apontadas nas ameaças à validade (@ameacas), e consideram apenas o tempo de busca, o pico da lista aberta e o custo relativo.

\
#figure(
  caption: [Combinações de representação e algoritmo recomendadas por prioridade.],
  supplement: "Tabela",
)[
  #set par(justify: false)
  #tabela-abnt(
    columns: (3.5cm, 3.5cm, 1fr),
    align: (left, left, left),
    [*Prioridade*], [*Combinação*], [*Ressalvas*],
    [Menor tempo de busca], [GBFS na grade 2.5D], [Caminhos entre 18% e 28% mais caros que o de referência (@tab_comum_custo), com excesso que cresce com a persistência (@res_custo).],
    [Caminho ótimo e menor pico da lista aberta], [Dijkstra na grade voxelizada], [O caminho é ótimo no grafo voxelizado, de altura discretizada e vizinhança de quatro direções, e seu custo não é comparável ao das outras representações.],
    [Equilíbrio entre tempo e custo], [Weighted A\* na grade 2.5D], [Custo cerca de 3% acima do de referência e maior pico da lista aberta entre os algoritmos (@tab_comum_pico). Em relevo de persistência alta, o tempo cresce a ponto de superar o do Dijkstra na grade voxelizada (@fig_res_pers_tempo).],
  )
  #v(.5em)
  Fonte: Elaborado pelo autor.
] <tab_recomendacoes> \ #v(-1.5em)

Os grafos de vértices e dual não aparecem entre as recomendações, pois não lideram nenhum dos critérios avaliados. Essa conclusão se restringe aos terrenos testados, cujo volume não contém cavidades nem estruturas sobrepostas (ver @voxels), situação em que essas representações poderiam se diferenciar das grades. Além disso, o tempo de construção dos grafos e a extração da malha não entram na comparação, e uma escolha baseada no custo total deve considerá-los. Como a construção é mais cara justamente nos grafos de vértices e dual (@tab_construcao), considerá-la reforçaria a vantagem das grades.

= Conclusão

Este trabalho buscou responder qual é a influência da representação navegável de um terreno 3D e das características do terreno no desempenho e na qualidade da busca de algoritmos clássicos. Os resultados indicam que ambas as escolhas alteram o desempenho, mas que o sentido e a magnitude desse efeito dependem do algoritmo. Não há uma combinação que seja a melhor em todos os critérios: a escolha depende de a prioridade ser o tempo de busca, o esforço de expansão ou a qualidade do caminho.

Nas condições testadas, o algoritmo Greedy Best-First Search é o mais rápido em todos os testes, mas seus caminhos ficam entre 18% e 28% mais caros que os do algoritmo de Dijkstra (@tab_comum_custo). O algoritmo de Dijkstra serve de referência de qualidade, e o algoritmo A\* expande menos vértices sem reduzir o tempo de busca. O algoritmo Weighted A\* ocupa um meio-termo, com caminhos próximos aos de referência, ao custo de picos maiores da lista aberta (@tab_comum_pico).

Os objetivos propostos foram cumpridos. A biblioteca de grafos foi estendida com uma estrutura leve, os quatro algoritmos foram implementados, um gerador de terrenos por ruído de Perlin foi desenvolvido com os parâmetros testados, as quatro representações navegáveis foram construídas, e as métricas foram coletadas automaticamente e analisadas por ANOVA com testes de Tukey. O ambiente 3D com execução concorrente foi implementado como ferramenta de visualização das malhas e dos caminhos. Ele não participa da coleta das métricas de busca, e a avaliação do seu gerenciador de tarefas está resumida no #link(<apendice_taskmaster>)[Apêndice D].

Assim, este trabalho contribui com uma comparação entre representações navegáveis avaliadas sobre os mesmos terrenos, com uma metodologia experimental reproduzível e com uma implementação de código aberto do gerador, das representações e dos algoritmos instrumentados, construída sobre a biblioteca de grafos Graph e o motor IFCG (ver Seções #ref(<lwgraph>, supplement: none) e #ref(<ifcg>, supplement: none)).

Dentro das limitações apontadas nas ameaças à validade (@ameacas), trabalhos futuros podem estender a comparação a terrenos reais, a obstáculos dinâmicos e a outros pesos do algoritmo Weighted A\*, além de incluir na comparação estatística o custo de construção dos grafos, hoje apresentado apenas de forma descritiva (@tab_construcao). A escolha conjunta de representação e algoritmo, portanto, deve considerar tanto o tipo de terreno quanto a prioridade da aplicação.

#pagebreak()

#text(white, size: 1pt)[#heading(numbering: none)[DECLARAÇÃO DE USO DE INTELIGÊNCIA ARTIFICIAL]]
#v(-1.5em)
#align(center)[
  #text(weight: "bold", size: 12pt)[DECLARAÇÃO DE USO DE INTELIGÊNCIA ARTIFICIAL]
  #v(1.5em)
]

O autor declara que o assistente de inteligência artificial Claude Code foi utilizado como apoio na revisão textual e ortográfica, na redação de trechos a partir de dados e indicações fornecidos pelo autor e na formatação das tabelas deste trabalho. Também foi utilizado no desenvolvimento das funções de aquisição de dados, construídas sobre a base de software implementada pelo autor, e no tratamento estatístico dos dados. Todo o conteúdo gerado foi revisado pelo autor. A concepção do estudo, a implementação do software base, a execução dos experimentos e a análise científica são de inteira responsabilidade do autor.

#pagebreak()

#text(white, size: 1pt)[#heading(numbering: none)[REFERÊNCIAS]]
#v(-1.5em)
#align(center)[
  #text(weight: "bold", size: 12pt)[REFERÊNCIAS]
  #v(1.5em)
]

#bibliography("referencias.bib", style: "associacao-brasileira-de-normas-tecnicas.csl", title: none)

#pagebreak()

#heading(numbering: none)[Apêndice A -- Análise de variância] <apendice_anova>

Este apêndice apresenta a ANOVA em modelo _split-plot_ de cada teste: escala (@tab_anova_escala), lacunaridade (@tab_anova_lac), persistência (@tab_anova_pers) e comprimento de onda (@tab_anova_comp). Nas tabelas, N é o nível do parâmetro testado, A é o algoritmo e R é a representação navegável. Nos efeitos dentro do terreno, os graus de liberdade (gl) e o valor de p trazem a correção de Greenhouse-Geisser.

\
#figure(
  caption: [ANOVA _split-plot_ do teste de escala.],
  supplement: "Tabela",
)[
  #set text(size: 9pt)
  #set par(justify: false)
  #tabela-abnt(
    columns: (auto, auto, 1fr, 1fr, 1fr, 1fr),
    align: (left, left, right, right, right, right),
    [*Métrica*], [*Efeito*], [*F*], [*gl*], [*p*], [*$eta_p^2$*],
    table.cell(rowspan: 7)[Tempo],
    [N], [595,01], [3; 196], [< 0,001], [0,901],
    [A], [35531,32], [1,20; 234,3], [< 0,001], [0,995],
    [N × A], [5,85], [3,59; 234,3], [< 0,001], [0,082],
    [R], [22039,06], [1,84; 360,6], [< 0,001], [0,991],
    [N × R], [4,96], [5,52; 360,6], [< 0,001], [0,071],
    [A × R], [1802,37], [1,97; 385,7], [< 0,001], [0,902],
    [N × A × R], [2,83], [5,90; 385,7], [0,011], [0,042],
    table.cell(rowspan: 7)[Expandidos],
    [N], [314,92], [3; 196], [< 0,001], [0,828],
    [A], [42398,75], [1,74; 340,2], [< 0,001], [0,995],
    [N × A], [13,00], [5,21; 340,2], [< 0,001], [0,166],
    [R], [19442,74], [1,77; 347,0], [< 0,001], [0,990],
    [N × R], [2,31], [5,31; 347,0], [0,040], [0,034],
    [A × R], [1728,46], [2,33; 456,5], [< 0,001], [0,898],
    [N × A × R], [2,90], [6,99; 456,5], [0,006], [0,042],
    table.cell(rowspan: 7)[Pico da lista aberta],
    [N], [2650,32], [3; 196], [< 0,001], [0,976],
    [A], [18998,76], [1,83; 357,7], [< 0,001], [0,990],
    [N × A], [2,55], [5,48; 357,7], [0,024], [0,038],
    [R], [25116,99], [2,57; 503,6], [< 0,001], [0,992],
    [N × R], [1,70], [7,71; 503,6], [0,098], [0,025],
    [A × R], [1061,61], [3,51; 687,2], [< 0,001], [0,844],
    [N × A × R], [1,88], [10,52; 687,2], [0,042], [0,028],
    table.cell(rowspan: 7)[Custo relativo],
    [N], [2,53], [3; 196], [0,059], [0,037],
    [A], [11037,79], [1,00; 196,0], [< 0,001], [0,983],
    [N × A], [2,92], [3,00; 196,0], [0,035], [0,043],
    [R], [282,35], [2,63; 515,6], [< 0,001], [0,590],
    [N × R], [1,13], [7,89; 515,6], [0,340], [0,017],
    [A × R], [323,65], [2,58; 504,8], [< 0,001], [0,623],
    [N × A × R], [1,19], [7,73; 504,8], [0,302], [0,018],
  )
  #v(.5em)
  Fonte: Elaborado pelo autor.
] <tab_anova_escala>

\
#figure(
  caption: [ANOVA _split-plot_ do teste de lacunaridade.],
  supplement: "Tabela",
)[
  #set text(size: 9pt)
  #set par(justify: false)
  #tabela-abnt(
    columns: (auto, auto, 1fr, 1fr, 1fr, 1fr),
    align: (left, left, right, right, right, right),
    [*Métrica*], [*Efeito*], [*F*], [*gl*], [*p*], [*$eta_p^2$*],
    table.cell(rowspan: 7)[Tempo],
    [N], [378,02], [3; 196], [< 0,001], [0,853],
    [A], [33976,09], [1,20; 235,4], [< 0,001], [0,994],
    [N × A], [115,81], [3,60; 235,4], [< 0,001], [0,639],
    [R], [17449,55], [2,25; 440,0], [< 0,001], [0,989],
    [N × R], [150,85], [6,74; 440,0], [< 0,001], [0,698],
    [A × R], [1730,39], [2,53; 495,1], [< 0,001], [0,898],
    [N × A × R], [49,17], [7,58; 495,1], [< 0,001], [0,429],
    table.cell(rowspan: 7)[Expandidos],
    [N], [246,01], [3; 196], [< 0,001], [0,790],
    [A], [39976,26], [1,62; 317,1], [< 0,001], [0,995],
    [N × A], [98,47], [4,85; 317,1], [< 0,001], [0,601],
    [R], [16510,66], [2,12; 415,7], [< 0,001], [0,988],
    [N × R], [149,46], [6,36; 415,7], [< 0,001], [0,696],
    [A × R], [1592,49], [2,82; 553,1], [< 0,001], [0,890],
    [N × A × R], [40,39], [8,47; 553,1], [< 0,001], [0,382],
    table.cell(rowspan: 7)[Pico da lista aberta],
    [N], [1021,63], [3; 196], [< 0,001], [0,940],
    [A], [18327,68], [1,97; 385,3], [< 0,001], [0,989],
    [N × A], [38,32], [5,90; 385,3], [< 0,001], [0,370],
    [R], [16950,97], [2,57; 504,4], [< 0,001], [0,989],
    [N × R], [172,42], [7,72; 504,4], [< 0,001], [0,725],
    [A × R], [1086,84], [3,35; 656,9], [< 0,001], [0,847],
    [N × A × R], [149,75], [10,05; 656,9], [< 0,001], [0,696],
    table.cell(rowspan: 7)[Custo relativo],
    [N], [405,34], [3; 196], [< 0,001], [0,861],
    [A], [8528,73], [1,00; 196,0], [< 0,001], [0,978],
    [N × A], [582,53], [3,00; 196,0], [< 0,001], [0,899],
    [R], [347,17], [2,64; 518,2], [< 0,001], [0,639],
    [N × R], [64,25], [7,93; 518,2], [< 0,001], [0,496],
    [A × R], [366,38], [2,71; 531,2], [< 0,001], [0,651],
    [N × A × R], [27,35], [8,13; 531,2], [< 0,001], [0,295],
  )
  #v(.5em)
  Fonte: Elaborado pelo autor.
] <tab_anova_lac>

\
#figure(
  caption: [ANOVA _split-plot_ do teste de persistência.],
  supplement: "Tabela",
)[
  #set text(size: 9pt)
  #set par(justify: false)
  #tabela-abnt(
    columns: (auto, auto, 1fr, 1fr, 1fr, 1fr),
    align: (left, left, center, center, center, center),
    [*Métrica*], [*Efeito*], [*F*], [*gl*], [*p*], [*$eta_p^2$*],
    table.cell(rowspan: 7)[Tempo],
    [N], [1277,93], [3; 196], [< 0,001], [0,951],
    [A], [32733,41], [1,30; 254,3], [< 0,001], [0,994],
    [N × A], [250,80], [3,89; 254,3], [< 0,001], [0,793],
    [R], [26240,93], [2,04; 399,2], [< 0,001], [0,993],
    [N × R], [705,70], [6,11; 399,2], [< 0,001], [0,915],
    [A × R], [1576,88], [2,47; 483,7], [< 0,001], [0,889],
    [N × A × R], [151,67], [7,40; 483,7], [< 0,001], [0,699],
    table.cell(rowspan: 7)[Expandidos],
    [N], [855,22], [3; 196], [< 0,001], [0,929],
    [A], [33595,96], [1,79; 350,6], [< 0,001], [0,994],
    [N × A], [200,83], [5,37; 350,6], [< 0,001], [0,755],
    [R], [22922,07], [1,92; 377,0], [< 0,001], [0,992],
    [N × R], [650,07], [5,77; 377,0], [< 0,001], [0,909],
    [A × R], [1487,09], [2,78; 545,7], [< 0,001], [0,884],
    [N × A × R], [128,36], [8,35; 545,7], [< 0,001], [0,663],
    table.cell(rowspan: 7)[Pico da lista aberta],
    [N], [3813,67], [3; 196], [< 0,001], [0,983],
    [A], [15877,84], [1,88; 368,8], [< 0,001], [0,988],
    [N × A], [97,05], [5,65; 368,8], [< 0,001], [0,598],
    [R], [22882,36], [2,66; 522,1], [< 0,001], [0,992],
    [N × R], [621,89], [7,99; 522,1], [< 0,001], [0,905],
    [A × R], [1143,78], [4,05; 792,8], [< 0,001], [0,854],
    [N × A × R], [316,05], [12,14; 792,8], [< 0,001], [0,829],
    table.cell(rowspan: 7)[Custo relativo],
    [N], [1680,31], [3; 196], [< 0,001], [0,963],
    [A], [17052,56], [1,00; 196,0], [< 0,001], [0,989],
    [N × A], [2527,82], [3,00; 196,0], [< 0,001], [0,975],
    [R], [183,54], [2,55; 500,4], [< 0,001], [0,484],
    [N × R], [119,00], [7,66; 500,4], [< 0,001], [0,646],
    [A × R], [99,41], [2,48; 485,1], [< 0,001], [0,337],
    [N × A × R], [104,48], [7,43; 485,1], [< 0,001], [0,615],
  )
  #v(.5em)
  Fonte: Elaborado pelo autor.
] <tab_anova_pers>

\
#figure(
  caption: [ANOVA _split-plot_ do teste de comprimento de onda.],
  supplement: "Tabela",
)[
  #set text(size: 9pt)
  #set par(justify: false)
  #tabela-abnt(
    columns: (auto, auto, 1fr, 1fr, 1fr, 1fr),
    align: (left, left, center, center, center, center),
    [*Métrica*], [*Efeito*], [*F*], [*gl*], [*p*], [*$eta_p^2$*],
    table.cell(rowspan: 7)[Tempo],
    [N], [504,09], [3; 196], [< 0,001], [0,885],
    [A], [33657,63], [1,11; 217,7], [< 0,001], [0,994],
    [N × A], [176,43], [3,33; 217,7], [< 0,001], [0,730],
    [R], [17349,38], [2,08; 407,6], [< 0,001], [0,989],
    [N × R], [206,03], [6,24; 407,6], [< 0,001], [0,759],
    [A × R], [2494,24], [2,33; 457,6], [< 0,001], [0,927],
    [N × A × R], [61,97], [7,00; 457,6], [< 0,001], [0,487],
    table.cell(rowspan: 7)[Expandidos],
    [N], [344,06], [3; 196], [< 0,001], [0,840],
    [A], [40812,30], [1,37; 269,0], [< 0,001], [0,995],
    [N × A], [166,40], [4,12; 269,0], [< 0,001], [0,718],
    [R], [17395,19], [1,94; 380,0], [< 0,001], [0,989],
    [N × R], [178,09], [5,82; 380,0], [< 0,001], [0,732],
    [A × R], [2330,12], [2,53; 495,1], [< 0,001], [0,922],
    [N × A × R], [56,38], [7,58; 495,1], [< 0,001], [0,463],
    table.cell(rowspan: 7)[Pico da lista aberta],
    [N], [940,57], [3; 196], [< 0,001], [0,935],
    [A], [20493,12], [1,78; 348,5], [< 0,001], [0,991],
    [N × A], [31,03], [5,33; 348,5], [< 0,001], [0,322],
    [R], [18279,91], [2,32; 454,3], [< 0,001], [0,989],
    [N × R], [218,75], [6,95; 454,3], [< 0,001], [0,770],
    [A × R], [2134,16], [3,19; 625,2], [< 0,001], [0,916],
    [N × A × R], [253,19], [9,57; 625,2], [< 0,001], [0,795],
    table.cell(rowspan: 7)[Custo relativo],
    [N], [626,39], [3; 196], [< 0,001], [0,906],
    [A], [9437,10], [1,00; 196,0], [< 0,001], [0,980],
    [N × A], [778,08], [3,00; 196,0], [< 0,001], [0,923],
    [R], [407,60], [2,58; 506,4], [< 0,001], [0,675],
    [N × R], [69,48], [7,75; 506,4], [< 0,001], [0,515],
    [A × R], [449,56], [2,60; 509,7], [< 0,001], [0,696],
    [N × A × R], [22,84], [7,80; 509,7], [< 0,001], [0,259],
  )
  #v(.5em)
  Fonte: Elaborado pelo autor.
] <tab_anova_comp>


#heading(numbering: none)[Apêndice B -- Comparações de Tukey] <apendice_tukey>

Este apêndice resume as comparações do teste de Tukey. A @tab_tukey_alg traz, para cada teste e representação, a razão entre as médias geométricas dos algoritmos de Dijkstra e A\* no tempo de busca, nos vértices expandidos e no pico da lista aberta, com o valor de p entre parênteses. No custo relativo, a razão é entre os algoritmos Weighted A\* e Greedy Best-First Search. A @tab_tukey_niveis traz a razão entre o último e o primeiro nível de cada teste, por algoritmo, com o menor e o maior valor entre as quatro representações.

\
#figure(
  caption: [Razão das médias geométricas do Dijkstra (p) por representação.],
  supplement: "Tabela",
)[
  #set text(size: 9pt)
  #set par(justify: false)
  #tabela-abnt(
    columns: (auto, auto, 1fr, 1fr, 1fr, 1fr),
    align: (left, left, center, center, center, center),
    [*Teste*], [*Métrica*], [*Grade \ 2.5D*], [*Grade \ voxelizada*], [*Grafo de \ vértices*], [*Grafo \ dual*],
    table.cell(rowspan: 4)[Escala], [Tempo], [0,965 (0,088)], [0,793 (< 0,001)], [1,035 (0,111)], [0,953 (0,009)],
    [Expandidos], [1,532 (< 0,001)], [1,034 (0,117)], [1,466 (< 0,001)], [1,239 (< 0,001)],
    [Pico da lista aberta], [0,419 (< 0,001)], [0,561 (< 0,001)], [0,446 (< 0,001)], [0,549 (< 0,001)],
    [Custo (WA\* / GBFS)], [0,886 (< 0,001)], [0,814 (< 0,001)], [0,834 (< 0,001)], [0,847 (< 0,001)],
    table.cell(rowspan: 4)[Lacuna-\ ridade], [Tempo], [1,010 (0,930)], [0,813 (< 0,001)], [1,072 (< 0,001)], [0,981 (0,642)],
    [Expandidos], [1,664 (< 0,001)], [1,037 (0,104)], [1,526 (< 0,001)], [1,287 (< 0,001)],
    [Pico da lista aberta], [0,387 (< 0,001)], [0,550 (< 0,001)], [0,445 (< 0,001)], [0,548 (< 0,001)],
    [Custo (WA\* / GBFS)], [0,902 (< 0,001)], [0,832 (< 0,001)], [0,847 (< 0,001)], [0,856 (< 0,001)],
    table.cell(rowspan: 4)[Persis-\ tência], [Tempo], [0,990 (0,894)], [0,821 (< 0,001)], [1,044 (0,014)], [0,966 (0,072)],
    [Expandidos], [1,549 (< 0,001)], [1,030 (0,183)], [1,474 (< 0,001)], [1,260 (< 0,001)],
    [Pico da lista aberta], [0,419 (< 0,001)], [0,581 (< 0,001)], [0,454 (< 0,001)], [0,555 (< 0,001)],
    [Custo (WA\* / GBFS)], [0,820 (< 0,001)], [0,784 (< 0,001)], [0,800 (< 0,001)], [0,810 (< 0,001)],
    table.cell(rowspan: 4)[Comp. de \ onda], [Tempo], [1,010 (0,923)], [0,814 (< 0,001)], [1,050 (0,010)], [0,976 (0,434)],
    [Expandidos], [1,723 (< 0,001)], [1,030 (0,234)], [1,518 (< 0,001)], [1,292 (< 0,001)],
    [Pico da lista aberta], [0,376 (< 0,001)], [0,560 (< 0,001)], [0,438 (< 0,001)], [0,542 (< 0,001)],
    [Custo (WA\* / GBFS)], [0,923 (< 0,001)], [0,849 (< 0,001)], [0,869 (< 0,001)], [0,874 (< 0,001)],
  )
  #v(.5em)
  Fonte: Elaborado pelo autor.
] <tab_tukey_alg>

\
#figure(
  caption: [Razão entre o último e o primeiro nível, por teste e algoritmo: \ mínimo e máximo entre as representações.],
  supplement: "Tabela",
)[
  #set text(size: 9pt)
  #set par(justify: false)
  #tabela-abnt(
    columns: (auto, auto, 1fr, 1fr, 1fr, 1fr),
    align: (left, left, center, center, center, center),
    [*Teste*], [*Algoritmo*], [*Tempo*], [*Expandidos*], [*Pico*], [*Custo*],
    table.cell(rowspan: 4)[Escala \ (800/500)], [Dijkstra], [2,64–2,81], [2,56–2,58], [1,58–1,61], [—],
    [A\*], [2,69–2,93], [2,57–2,67], [1,56–1,64], [—],
    [WA\*], [2,75–3,95], [2,62–3,70], [1,60–1,81], [0,998–1,003#super[(3)]],
    [GBFS], [2,26–2,52], [1,74–1,92], [1,61–1,66], [1,008–1,021#super[(3)]],
    table.cell(rowspan: 4)[Lacunaridade \ (2,25/1,5)], [Dijkstra], [1,20–1,95], [1,00–1,72#super[(2)]], [1,34–1,53], [—],
    [A\*], [1,29–2,42], [1,03–2,22], [0,85–1,45], [—],
    [WA\*], [1,80–10,73], [1,77–9,98], [0,64–2,35], [0,976–1,009],
    [GBFS], [1,13–2,12], [1,20–2,20], [1,07–1,44], [1,132–1,288],
    table.cell(rowspan: 4)[Persistência \ (0,7/0,3)], [Dijkstra], [1,36–3,74], [1,00–2,95], [1,92–2,52], [—],
    [A\*], [1,44–4,95], [1,05–4,20], [0,97–2,30#super[(1)]], [—],
    [WA\*], [2,44–39,93], [2,39–36,97], [0,61–3,23], [0,968–0,991],
    [GBFS], [1,36–4,77], [1,64–6,11], [1,16–1,97], [1,337–1,631],
    table.cell(rowspan: 4)[Comp. de onda \ (500/200)], [Dijkstra], [0,47–0,85], [0,57–1,00], [0,63–0,73], [—],
    [A\*], [0,45–0,80], [0,49–1,00#super[(1)]], [0,71–1,21], [—],
    [WA\*], [0,07–0,48], [0,06–0,47], [0,43–1,91], [0,977–1,024],
    [GBFS], [0,45–0,89], [0,45–0,82], [0,71–0,94], [0,792–0,897],
  )
  #v(.5em)
  Sobrescrito entre parênteses: número de representações em que o par extremo não é significativo (p ≥ 0,05). \
  Fonte: Elaborado pelo autor.
] <tab_tukey_niveis>

#heading(numbering: none)[Apêndice C -- Figuras complementares] <apendice_figuras>

Este apêndice reúne as figuras de vértices expandidos e de custo relativo dos quatro testes, que complementam as figuras de tempo de busca da @res_tempo. Em cada figura, os pontos são médias geométricas dos terrenos, e as barras indicam o intervalo de confiança de 95%. O custo relativo é apresentado apenas para os algoritmos Weighted A\* e Greedy Best-First Search.

\
#figure(
  caption: [Vértices expandidos em função da escala, \ por algoritmo e representação.],
  supplement: "Figura",
)[
  #v(1.5em)
  #image("images/apendice/fig_scale_expandidos.png", width: 100%)
  #v(.5em)
 Fonte: Elaborado pelo autor.
] <fig_apx_scale_expandidos> \ #v(-1.5em)

\
#figure(
  caption: [Custo relativo em função da escala, \ por algoritmo e representação.],
  supplement: "Figura",
)[
  #v(1.5em)
  #image("images/apendice/fig_scale_custo_relativo.png", width: 100%)
  #v(.5em)
 Fonte: Elaborado pelo autor.
] <fig_apx_scale_custo_relativo> \ #v(-1.5em)

\
#figure(
  caption: [Vértices expandidos em função da lacunaridade, \ por algoritmo e representação.],
  supplement: "Figura",
)[
  #v(1.5em)
  #image("images/apendice/fig_lac_expandidos.png", width: 100%)
  #v(.5em)
 Fonte: Elaborado pelo autor.
] <fig_apx_lac_expandidos> \ #v(-1.5em)

\
#figure(
  caption: [Custo relativo em função da lacunaridade, \ por algoritmo e representação.],
  supplement: "Figura",
)[
  #v(1.5em)
  #image("images/apendice/fig_lac_custo_relativo.png", width: 100%)
  #v(.5em)
 Fonte: Elaborado pelo autor.
] <fig_apx_lac_custo_relativo> \ #v(-1.5em)

\
#figure(
  caption: [Vértices expandidos em função da persistência, \ por algoritmo e representação.],
  supplement: "Figura",
)[
  #v(1.5em)
  #image("images/apendice/fig_pers_expandidos.png", width: 100%)
  #v(.5em)
 Fonte: Elaborado pelo autor.
] <fig_apx_pers_expandidos> \ #v(-1.5em)

\
#figure(
  caption: [Custo relativo em função da persistência, \ por algoritmo e representação.],
  supplement: "Figura",
)[
  #v(1.5em)
  #image("images/apendice/fig_pers_custo_relativo.png", width: 100%)
  #v(.5em)
 Fonte: Elaborado pelo autor.
] <fig_apx_pers_custo_relativo> \ #v(-1.5em)

\
#figure(
  caption: [Vértices expandidos em função do comprimento de onda base, \ por algoritmo e representação.],
  supplement: "Figura",
)[
  #v(1.5em)
  #image("images/apendice/fig_frequency_expandidos.png", width: 100%)
  #v(.5em)
 Fonte: Elaborado pelo autor.
] <fig_apx_frequency_expandidos> \ #v(-1.5em)

\
#figure(
  caption: [Custo relativo em função do comprimento de onda base, \ por algoritmo e representação.],
  supplement: "Figura",
)[
  #v(1.5em)
  #image("images/apendice/fig_frequency_custo_relativo.png", width: 100%)
  #v(.5em)
 Fonte: Elaborado pelo autor.
] <fig_apx_frequency_custo_relativo> \ #v(-1.5em)

#heading(numbering: none)[Apêndice D -- Avaliação do TaskMaster] <apendice_taskmaster>

Este apêndice resume a avaliação do _TaskMaster_ (ver @ifcg), feita em um estudo complementar a este trabalho. O estudo foi desenvolvido pelo autor na disciplina de Programação de Alto Desempenho e apresentado como pôster na MEPEC 2026, em coautoria com Paulo César Rodacki Gomes, Ricardo de la Rocha Ladeira e Jurandir Domingues Junior. O código está em repositório público#footnote[Disponível em: #link("https://github.com/andrevbastos/pad")].

O experimento mede a geração de um terreno, que compreende o mapa de altura por ruído de Perlin (ver @perlin) e a construção da malha triangular correspondente. A busca de caminhos não faz parte dessa avaliação.

São comparados dois modos. No sequencial, a geração ocorre na _thread_ principal, a mesma que executa o laço de renderização. No paralelo, a _thread_ principal apenas delega a geração ao _TaskMaster_, que a executa nas _threads_ trabalhadoras. Cada modo é avaliado em dois cenários: isolado, sem o motor gráfico, e integrado ao IFCG, com a taxa de quadros limitada a 60 quadros por segundo (FPS, do inglês _frames per second_).

A dimensão do terreno varia de 100 × 100 a 1000 × 1000 vértices, em dez níveis, com seis oitavas. Cada execução gera 20 terrenos por nível, e são feitas cinco execuções por modo, o que resulta em 100 medições por nível. O ambiente difere do descrito na Metodologia: o processador é o mesmo, mas com o governador de frequência _performance_, o turbo desligado, a rede desativada e pausas de 10 segundos entre as execuções. O modo sequencial é fixado no núcleo 2, e o paralelo usa todos os núcleos. O estudo também varia o número de oitavas, com resultados no mesmo sentido, que não são reproduzidos aqui.

A @tab_taskmaster apresenta o cenário integrado ao motor gráfico. No modo sequencial, a taxa de quadros cai de 38,69 FPS, na menor dimensão, para 0,44 FPS, na maior, porque cada geração bloqueia a _thread_ principal. No modo paralelo, a taxa permanece entre 59 e 60 FPS em todas as dimensões, isto é, no limite configurado. Esse resultado indica que a _thread_ principal não é bloqueada pela geração, e não um aumento da capacidade de renderização.

\
#figure(
  caption: [Tempo de geração e taxa de quadros por dimensão do terreno, no cenário integrado ao motor gráfico.],
  supplement: "Tabela",
)[
  #tabela-abnt(
    columns: (auto, 1fr, 1fr, 1fr, 1fr),
    align: (left, center, center, center, center),
    [*Dimensão*], [*Tempo seq. (ms)*], [*FPS seq.*], [*Tempo par. (ms)*], [*FPS par.*],
    [100 × 100], [25,6], [38,69], [49,8], [59,31],
    [200 × 200], [99,0], [10,06], [179,9], [59,31],
    [300 × 300], [218,2], [4,57], [411,5], [59,31],
    [400 × 400], [380,0], [2,63], [703,3], [59,26],
    [500 × 500], [585,3], [1,71], [1071,0], [59,25],
    [600 × 600], [842,4], [1,19], [1511,0], [59,25],
    [700 × 700], [1131,7], [0,88], [2045,3], [59,25],
    [800 × 800], [1481,8], [0,67], [2658,7], [59,25],
    [900 × 900], [1871,7], [0,53], [3333,7], [59,25],
    [1000 × 1000], [2295,0], [0,44], [3897,5], [59,59],
  )
  #v(.5em)
  Fonte: Elaborado pelo autor.
] <tab_taskmaster>

No cenário isolado, a execução completa, com 400 terrenos somados os testes de dimensão e de oitavas, leva em média 250,32 s no modo sequencial e 46,69 s no paralelo, uma razão de 5,36.

Em contrapartida, o tempo de geração de cada terreno é maior no modo paralelo: entre 1,7 e 1,9 vez o do sequencial no cenário integrado (@tab_taskmaster) e entre 2,1 e 2,2 vezes no isolado. A causa dessa diferença não foi isolada. O processador combina núcleos de desempenho e de eficiência, e o modo paralelo distribui as tarefas entre todos eles, enquanto o sequencial usa um único núcleo de desempenho. Além disso, a avaliação não inclui a busca de caminhos e, portanto, não mede o efeito do _TaskMaster_ sobre os algoritmos comparados neste trabalho.


#heading(numbering: none)[Apêndice E -- Tamanho e construção dos grafos] <apendice_tamanho>

Este apêndice apresenta, para cada teste e nível, o número de vértices |V| e de arestas |A| de cada representação, a razão entre o número de vértices e o número de colunas do mapa de altura, o tempo de construção do grafo e o tempo de extração da malha pelo Marching Cubes, além da declividade média dos terrenos. Os valores de tamanho e de declividade são médias dos 50 terrenos de cada nível, e os tempos são médias geométricas. A construção não inclui a extração da malha, que é a mesma para o grafo de vértices e o grafo dual.

\
#figure(
  caption: [Tamanho dos grafos, tempo de construção e de extração da malha por nível no teste de escala.],
  supplement: "Tabela",
)[
  #set text(size: 10pt)
  #set par(justify: false)
  #tabela-abnt(
    columns: (auto, 2cm, auto, auto, auto, auto, auto, auto),
    align: (center + horizon, center + horizon, left, right, right, right, right, right),
    [*Dimensão*], [*Declividade média*], [*Representação*], [*|V|*], [*|A|*], [*|V|/coluna*], [*Construção (s)*], [*Extração MC (s)*],
    table.cell(rowspan: 4)[500], table.cell(rowspan: 4)[1,64], [Grade 2.5D], [250 000], [997 002], [1,00], [0,034], [—],
    [Grade voxelizada], [250 000], [499 000], [1,00], [0,027], [—],
    [Grafo de vértices], [775 682], [2 322 928], [3,10], [0,210], [1,13],
    [Grafo dual], [1 547 247], [2 318 812], [6,19], [4,094], [1,13],
    table.cell(rowspan: 4)[600], table.cell(rowspan: 4)[1,66], [Grade 2.5D], [360 000], [1 436 402], [1,00], [0,046], [—],
    [Grade voxelizada], [360 000], [718 800], [1,00], [0,049], [—],
    [Grafo de vértices], [1 124 321], [3 368 021], [3,12], [0,295], [1,88],
    [Grafo dual], [2 243 701], [3 363 082], [6,23], [6,002], [1,89],
    table.cell(rowspan: 4)[700], table.cell(rowspan: 4)[1,66], [Grade 2.5D], [490 000], [1 955 802], [1,00], [0,064], [—],
    [Grade voxelizada], [490 000], [978 600], [1,00], [0,066], [—],
    [Grafo de vértices], [1 531 012], [4 587 249], [3,12], [0,401], [2,90],
    [Grafo dual], [3 056 238], [4 581 464], [6,24], [8,182], [2,88],
    table.cell(rowspan: 4)[800], table.cell(rowspan: 4)[1,66], [Grade 2.5D], [640 000], [2 555 202], [1,00], [0,082], [—],
    [Grade voxelizada], [640 000], [1 278 400], [1,00], [0,091], [—],
    [Grafo de vértices], [1 997 635], [5 986 378], [3,12], [0,520], [4,18],
    [Grafo dual], [3 988 744], [5 979 853], [6,23], [10,717], [4,14],
  )
  #v(.5em)
  Fonte: Elaborado pelo autor.
] <tab_apx_tamanho_scale>

\
#figure(
  caption: [Tamanho dos grafos, tempo de construção e de extração da malha por nível no teste de lacunaridade.],
  supplement: "Tabela",
)[
  #set text(size: 10pt)
  #set par(justify: false)
  #tabela-abnt(
    columns: (auto, 2cm, auto, auto, auto, auto, auto, auto),
    align: (center + horizon, center + horizon, left + horizon, center + horizon, center + horizon, center + horizon, center + horizon, right),
    [*Lacunaridade*], [*Declividade média*], [*Representação*], [*|V|*], [*|A|*], [*|V|/coluna*], [*Construção (s)*], [*Extração MC (s)*],
    table.cell(rowspan: 4)[1,5], table.cell(rowspan: 4)[1,01], [Grade 2.5D], [250 000], [997 002], [1,00], [0,034], [—],
    [Grade voxelizada], [250 000], [499 000], [1,00], [0,027], [—],
    [Grafo de vértices], [571 060], [1 709 895], [2,28], [0,122], [0,86],
    [Grafo dual], [1 138 836], [1 706 612], [4,56], [2,821], [0,86],
    table.cell(rowspan: 4)[1,75], table.cell(rowspan: 4)[1,25], [Grade 2.5D], [250 000], [997 002], [1,00], [0,031], [—],
    [Grade voxelizada], [250 000], [499 000], [1,00], [0,025], [—],
    [Grafo de vértices], [649 499], [1 944 884], [2,60], [0,152], [0,89],
    [Grafo dual], [1 295 386], [1 941 274], [5,18], [3,247], [0,89],
    table.cell(rowspan: 4)[2], table.cell(rowspan: 4)[1,65], [Grade 2.5D], [250 000], [997 002], [1,00], [0,031], [—],
    [Grade voxelizada], [250 000], [499 000], [1,00], [0,025], [—],
    [Grafo de vértices], [779 766], [2 335 171], [3,12], [0,204], [0,95],
    [Grafo dual], [1 555 406], [2 331 046], [6,22], [3,986], [0,95],
    table.cell(rowspan: 4)[2,25], table.cell(rowspan: 4)[2,21], [Grade 2.5D], [250 000], [997 002], [1,00], [0,031], [—],
    [Grade voxelizada], [250 000], [499 000], [1,00], [0,025], [—],
    [Grafo de vértices], [978 836], [2 931 611], [3,92], [0,281], [1,06],
    [Grafo dual], [1 952 776], [2 926 716], [7,81], [5,121], [1,06],
  )
  #v(.5em)
  Fonte: Elaborado pelo autor.
] <tab_apx_tamanho_lac>

\
#figure(
  caption: [Tamanho dos grafos, tempo de construção e de extração da malha por nível no teste de persistência.],
  supplement: "Tabela",
)[
  #set text(size: 10pt)
  #set par(justify: false)
  #tabela-abnt(
    columns: (auto, 2cm, auto, auto, auto, auto, auto, auto),
    align: (center + horizon, center + horizon, left + horizon, center + horizon, center + horizon, center + horizon, center + horizon, right),
    [*Persistência*], [*Declividade média*], [*Representação*], [*|V|*], [*|A|*], [*|V|/coluna*], [*Construção (s)*], [*Extração MC (s)*],
    table.cell(rowspan: 4)[0,3], table.cell(rowspan: 4)[0,94], [Grade 2.5D], [250 000], [997 002], [1,00], [0,034], [—],
    [Grade voxelizada], [250 000], [499 000], [1,00], [0,027], [—],
    [Grafo de vértices], [548 538], [1 642 421], [2,19], [0,118], [0,84],
    [Grafo dual], [1 093 884], [1 639 230], [4,38], [2,706], [0,85],
    table.cell(rowspan: 4)[0,433], table.cell(rowspan: 4)[1,28], [Grade 2.5D], [250 000], [997 002], [1,00], [0,031], [—],
    [Grade voxelizada], [250 000], [499 000], [1,00], [0,025], [—],
    [Grafo de vértices], [660 041], [1 976 477], [2,64], [0,162], [0,89],
    [Grafo dual], [1 316 437], [1 972 835], [5,27], [3,375], [0,90],
    table.cell(rowspan: 4)[0,567], table.cell(rowspan: 4)[2,23], [Grade 2.5D], [250 000], [997 002], [1,00], [0,031], [—],
    [Grade voxelizada], [250 000], [499 000], [1,00], [0,025], [—],
    [Grafo de vértices], [969 694], [2 904 203], [3,88], [0,264], [1,06],
    [Grafo dual], [1 934 510], [2 899 327], [7,74], [5,160], [1,06],
    table.cell(rowspan: 4)[0,7], table.cell(rowspan: 4)[4,20], [Grade 2.5D], [250 000], [997 002], [1,00], [0,031], [—],
    [Grade voxelizada], [250 000], [499 000], [1,00], [0,025], [—],
    [Grafo de vértices], [1 616 617], [4 842 432], [6,47], [0,442], [1,53],
    [Grafo dual], [3 225 816], [4 835 015], [12,90], [8,853], [1,50],
  )
  #v(.5em)
  Fonte: Elaborado pelo autor.
] <tab_apx_tamanho_pers>

\
#figure(
  caption: [Tamanho dos grafos, tempo de construção e de extração da malha por nível no teste de comprimento de onda.],
  supplement: "Tabela",
)[
  #set text(size: 10pt)
  #set par(justify: false)
  #tabela-abnt(
    columns: (auto, 2cm, auto, auto, auto, auto, auto, auto),
    align: (center + horizon, center + horizon, left + horizon, center + horizon, center + horizon, center + horizon, center + horizon, right),
    [*Comp. de onda*], [*Declividade média*], [*Representação*], [*|V|*], [*|A|*], [*|V|/coluna*], [*Construção (s)*], [*Extração MC (s)*],
    table.cell(rowspan: 4)[200], table.cell(rowspan: 4)[2,04], [Grade 2.5D], [250 000], [997 002], [1,00], [0,034], [—],
    [Grade voxelizada], [250 000], [499 000], [1,00], [0,027], [—],
    [Grafo de vértices], [908 089], [2 719 631], [3,63], [0,255], [1,04],
    [Grafo dual], [1 811 543], [2 714 997], [7,25], [4,881], [1,06],
    table.cell(rowspan: 4)[275], table.cell(rowspan: 4)[1,51], [Grade 2.5D], [250 000], [997 002], [1,00], [0,031], [—],
    [Grade voxelizada], [250 000], [499 000], [1,00], [0,025], [—],
    [Grafo de vértices], [731 971], [2 191 982], [2,93], [0,189], [0,93],
    [Grafo dual], [1 460 012], [2 188 054], [5,84], [3,810], [0,94],
    table.cell(rowspan: 4)[350], table.cell(rowspan: 4)[1,18], [Grade 2.5D], [250 000], [997 002], [1,00], [0,031], [—],
    [Grade voxelizada], [250 000], [499 000], [1,00], [0,025], [—],
    [Grafo de vértices], [627 484], [1 878 918], [2,51], [0,154], [0,87],
    [Grafo dual], [1 251 435], [1 875 386], [5,01], [3,166], [0,88],
    table.cell(rowspan: 4)[500], table.cell(rowspan: 4)[0,84], [Grade 2.5D], [250 000], [997 002], [1,00], [0,031], [—],
    [Grade voxelizada], [250 000], [499 000], [1,00], [0,025], [—],
    [Grafo de vértices], [516 337], [1 545 967], [2,07], [0,114], [0,79],
    [Grafo dual], [1 029 631], [1 542 926], [4,12], [2,510], [0,79],
  )
  #v(.5em)
  Fonte: Elaborado pelo autor.
] <tab_apx_tamanho_frequency>
