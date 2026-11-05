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
    "SIG": [Sigla]
  )
)

= Introdução
A busca de caminhos (ou _pathfinding_) é um dos campos mais tradicionais da Inteligência Artificial aplicada, evoluindo a partir dos algoritmos de busca clássicos em grafos (ver @grafos). Como definem #cite(<russell_norvig>, form: "prose"), os métodos clássicos de busca resolvem problemas de estados, ações e custos, visando encontrar caminhos entre um ponto de partida e um objetivo por meio da exploração do espaço de busca. Ao longo das últimas décadas, essa fundamentação deixou de ser puramente abstrata e passou a ser aplicada diretamente na computação interativa. Conforme apontam #cite(<pathfinding_game_dev>, form: "prose"), os algoritmos de busca tornaram-se componentes cruciais para o desenvolvimento de jogos modernos e simulações em tempo real.

No entanto, a transição do espaço de busca de 2D para 3D introduziu um aumento significativo na complexidade, exigindo adaptações às técnicas de busca e de representação do terreno. A escolha da representação do espaço transitável e do algoritmo de busca a ser utilizado tornou-se uma decisão crítica, impactando diretamente o desempenho e a qualidade dos caminhos encontrados.

\
#figure(
  caption: [Comparação entre representações 2D e 3D],
  supplement: "Figura",
)[
  #v(1.5em)
  #image("images/2d_vs_3d.png", width: 75%)
  #v(2em)
 Fonte: Elaborado pelo autor.
] <fig_2Dx3D> \ #v(-1.5em)

Em estudos recentes, é comumente evitada a comparação de múltiplas representações navegáveis de terrenos 3D, com foco em apenas uma abordagem na maioria das vezes. Além disso, a análise estatística do desempenho dos algoritmos de busca em diferentes representações é frequentemente negligenciada, limitando a compreensão das interações entre a estrutura do terreno e o comportamento dos algoritmos.

Esse trabalho propõe uma análise comparativa e estatística do desempenho de algoritmos clássicos de busca de caminhos em diferentes representações navegáveis de terrenos 3D. A pesquisa busca responder à seguinte questão central: Qual é a influência da *representação navegável* de um terreno 3D e das *características do terreno* no desempenho e na qualidade da busca de algoritmos clássicos de busca?

== Contribuições

Para responder à questão central, é necessário realizar uma análise detalhada das representações navegáveis de terrenos 3D (ver @representacoes_navegaveis), dos algoritmos de busca aplicados (ver @busca) e das métricas de desempenho utilizadas (ver @avaliacao). Com isso, as principais contribuições deste trabalho incluem:

+ #text()[*Comparação entre representações navegáveis.* \
As mesmas instâncias de terreno são convertidas em quatro grafos diferentes e avaliadas com os mesmos algoritmos:
  - a partir do mapa de altura: grade de altura (2.5D) e superfície voxel;
  - a partir da malha poligonal: grafo de vértices e grafo dual.]
+ #text()[*Metodologia experimental reprodutível.* \
Os terrenos são gerados proceduralmente (ver @geracao_terrenos) a partir de parâmetros controlados (escala, lacunaridade, persistência) e semente registrada, e os resultados passam por análise estatística (análise de variância, ou ANOVA, e testes post hoc).]
+ #text()[*Implementação open-source.* \
Inclui uma biblioteca de grafos leve e o motor gráfico IFCG, com visualização das malhas e dos caminhos.]

== Objetivos

O objetivo geral do estudo é analisar comparativa e estatisticamente o desempenho de algoritmos clássicos de _pathfinding_ em diferentes representações navegáveis de terrenos 3D. Mais especificamente, os objetivos incluem:

+ Implementar uma biblioteca de grafos e os algoritmos Dijkstra, A\*,  Weighted A\* e Greedy Best-First Search.
+ Desenvolver um gerador procedural de terrenos baseado em ruído de Perlin, parametrizado por escala, lacunaridade e persistência.
+ Construir quatro representações navegáveis a partir do terreno: grade de altura, superfície voxel, grafo de vértices e grafo dual da malha.
+ Desenvolver um ambiente 3D com execução concorrente para visualização das malhas e dos caminhos encontrados.
+ Automatizar a coleta de métricas e analisar estatisticamente os resultados obtidos.

= Fundamentação Teórica

A comparação proposta neste trabalho depende de três conjuntos de conceitos: a teoria de grafos, que modela o espaço de busca; os algoritmos que percorrem esse modelo; e os métodos de representação de terrenos que determinam como o grafo é construído a partir da geometria. Este capítulo apresenta cada um deles, nessa ordem, e termina com os trabalhos que compararam representações semelhantes.

== Grafos <grafos>

Grafos são estruturas matemáticas que representam relações entre objetos. Eles consistem em um conjunto de vértices (ou nós) e um conjunto de arestas (ou ligações) que conectam os vértices. Um grafo pode ser direcionado ou não direcionado, ponderado ou não ponderado, dependendo das características do problema a ser modelado. 

\
#figure(
  caption: [Exemplo de grafo simples.],
  supplement: "Figura",
)[
  #v(1.5em)
  #image("images/grafo_simples.png", width: 25%)
  #v(2em)
 Fonte: Elaborado pelo autor.
] <fig_grafo_simples> \ #v(-1.5em)

Quando trabalhamos com estruturas de dados complexas, como terrenos 3D, os grafos fornecem uma representação abstrata que facilita a aplicação de algoritmos de busca. Em aplicações como a navegação em terrenos 3D, os vértices podem representar posições do ambiente, e as arestas, a transitabilidade entre elas.

=== Definição

Segundo #cite(<rodacki_grafos>, form: "prose"), um grafo G é definido como um par ordenado (@formula_grafo), onde: $G$ é o grafo; $V$ é o conjunto de vértices; e $A$ é o conjunto de arestas. Cada aresta representa a conexão entre dois vértices, podendo ter uma direção associada e um peso.

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

Como definido em @arestas, uma aresta conecta dois vértices. Essa conexão pode ter um sentido, caso em que a aresta é direcionada, ou representar apenas uma ligação sem direção. Na criação de um grafo, é possível defini-lo como direcionado (@fig_dir\.a) ou não direcionado (@fig_dir\.b). Ou seja, a conexão entre dois vértices pode ser unidirecional ou bidirecional.

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

Grafos também podem ser ponderados (@fig_peso\.a), atribuindo valores numéricos às arestas para representar custos ou distâncias entre os vértices.

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

O custo de travessia de uma aresta pode representar diferentes aspectos, como distância física, tempo de viagem ou dificuldade de navegação. A escolha de atribuir pesos às arestas depende do contexto do problema e dos objetivos da estrutura. Alguns algoritmos de busca, como o de Dijkstra, exigem que os pesos sejam não-negativos @cormen2009introduction.

=== Caminho

Um caminho em um grafo é uma sequência de vértices conectados por arestas, representando uma rota entre dois pontos @rodacki_grafos, ilustrado na @fig_caminho. A definição formal de um caminho é uma sequência de vértices $(v_1, v_2, ..., v_n)$ tal que cada par consecutivo ${v_i, v_(i+1)}$ está conectado por uma aresta no grafo.

\
#figure(
  caption: [Exemplo de caminho em um grafo.],
  supplement: "Figura",
)[
  #image("images/caminho.png", width: 45%)
  #v(0.5em)
 Fonte: Elaborado pelo autor.
] <fig_caminho> \ #v(-1.5em)

Considerando $v_1$ o vértice inicial e $v_7$ o vértice final, a sequência de vértices $(v_1, v_2, v_3, v_4, v_5, v_6, v_7)$ representada na @fig_caminho é o caminho $v_1 arrow v_7$. Esse caminho é uma das várias rotas possíveis entre os vértices $v_1$ e $v_7$, e a escolha do caminho mais eficiente depende dos pesos das arestas e das características do grafo.

Para todo vértice $v$ em um grafo, é possível determinar se existe um caminho para outro vértice $u$ no mesmo grafo. Entretanto, a existência de um caminho não impede a existência de outros caminhos entre $v$ e $u$, podendo haver múltiplos caminhos com diferentes pesos e características. Quando comparados, os caminhos podem apresentar variações significativas em termos de custo, distância ou dificuldade de travessia. Se existe ao menos um caminho entre $v$ e $u$, e o grafo não contém ciclos de peso negativo, existe um caminho mínimo ou ótimo entre eles, que é aquele com o menor custo ou peso total.

=== Componente conexo

Dado um grafo não direcionado, um componente conexo é um subgrafo conexo e maximal, isto é, não pode ser estendido com outros vértices ou arestas do grafo original, e nele existe caminho entre quaisquer pares de vértices @rodacki_grafos. 

#figure(
  caption: [Exemplo de componentes conexos em um grafo.],
  supplement: "Figura",
)[
  // #image("", width: 75%)
  #v(0.5em)
 Fonte: Elaborado pelo autor.
] <fig_componentes_conexos> \ #v(-1.5em)

A identificação de componentes conexos é fundamental para entender a estrutura do grafo e determinar a viabilidade de encontrar caminhos entre diferentes regiões. Uma vez que um vértice pertence a um componente conexo, é possível garantir que existe um caminho para qualquer outro vértice dentro do mesmo componente.

== Busca <busca>

A busca de caminhos em um grafo é o processo de encontrar um caminho entre um vértice inicial e um vértice objetivo, idealmente o de menor custo. Diferentes algoritmos de busca podem ser aplicados, dependendo das características do grafo e dos requisitos do problema.

#figure(
  caption: [Diversos caminhos possíveis entre dois vértices em um grafo.],
  supplement: "Figura",
)[
  // #image("", width: 75%)
  #v(0.5em)
 Fonte: Elaborado pelo autor.
] <fig_caminhos> \ #v(-1.5em)

Sabendo da necessidade de encontrar caminhos mínimos, algoritmos de busca são projetados para explorar o grafo de maneiras específicas, visando otimizar a descoberta de caminhos com base em critérios como custo, distância ou heurísticas.

=== Dijkstra

// Algoritmo de busca de caminho mínimo em grafos ponderados, garantindo a descoberta do caminho mais curto entre um vértice inicial e todos os outros vértices.
O algoritmo de Dijkstra, proposto por #cite(<dijkstra1959note>, form: "prose"), é um método clássico da busca de caminhos em grafos ponderados, considerando que todos os pesos das arestas são não-negativos. Ele é capaz de encontrar, para cada vértice alcançável, um caminho mínimo a partir de um vértice inicial @rodacki_grafos. Esse processo gera uma árvore de caminhos mínimos tendo o vértice inicial como raiz.

Na implementação do algoritmo de Dijkstra, é considerado o pseudocódigo apresentado por #cite(<rodacki_grafos>, form: "prose"). Neste capítulo consideraremos um grafo $G = (V, A)$ ponderado de pesos não-negativos, onde $V$ é o conjunto de vértices e $A$ é o conjunto de arestas.

\
#figure(
  caption: [Pseudocódigo do algoritmo de Dijkstra.],
  supplement: "Figura",
)[
  #v(-0.5em)
  #pseudocode-list[
    Dijkstra$(G, W, s)$
    + para cada $v in V$ faça
      + $g_v arrow.l inf$
      + $p_v arrow.l "nil"$
    + $d_s arrow.l 0$
    + $Q arrow.l V$
    + $S arrow.l nothing$
    + enquanto $Q != nothing$ faça
      + $u arrow.l "pop"(Q)$
      + $S arrow.l S union {u}$
      + para cada $"vértice" v in "adj"(u)$ faça
        + se $v in Q$ e $[g_v > d_u + W_(u, v)]$ então
          + $g_v arrow.l (d_u + W_(u,v))$
          + $p_v arrow.l u$
  ]
  #v(0.5em)
  Fonte: #cite(<rodacki_grafos>, form: "prose").
] <fig_dijkstra> \ #v(-1.5em)

Na @fig_dijkstra, o algoritmo de Dijkstra inicializa a distância $g_v$ de todos os vértices a partir do vértice inicial $s$ como infinitos, exceto para o vértice inicial, que tem distância zero para ele mesmo. Em seguida são criadas duas estruturas de dados:
- $Q$: Uma fila de prioridade mínima (ou _min-PQ_, do inglês _Minimum Priority Queue_) que armazena os vértices ainda não processados ordenados pela menor distância conhecida, de modo que o vértice de menor distância seja sempre o primeiro a sair.
- $S$: Um conjunto que armazena os vértices cuja distância mínima já foi determinada. Os caminhos são reconstruídos a partir dos predecessores $p_v$.

O laço principal do algoritmo repete-se enquanto $Q$ não estiver vazia. Em cada iteração, a operação $"pop"(Q)$ retorna o vértice $u$ com menor distância estimada $d_u$ e o remove da fila. Em seguida, $u$ é incluído em $S$. Como os pesos são não-negativos, nenhum caminho que passe por vértices ainda não processados pode reduzir $d_u$, o que garante que essa distância já é a mínima.

Para cada vértice $v$ adjacente a $u$ (ver @lista_adjacencia) que ainda está em $Q$, verifica-se se passar por $u$ produz um caminho melhor do que o já conhecido. Se $g_v > d_u + W_(u,v)$, atualiza-se $g_v$ para $d_u + W_(u,v)$ e registra-se $u$ como predecessor de $v$ em $p_v$. Essa operação é chamada de relaxamento da aresta $(u, v)$.

Ao término do laço, para cada vértice alcançável a partir de $s$, $g_v$ contém a distância mínima entre $s$ e $v$. Os predecessores $p_v$ permitem reconstruir o caminho mínimo, percorrendo-os do destino até $s$.

=== Heurísticas <heuristicas>

Uma heurística é uma função $h(n)$ que estima o custo de um caminho entre um vértice $n$ e o objetivo, sem precisar percorrê-lo. Ela orienta a busca para os vértices mais promissores. Uma heurística é admissível quando nunca superestima o custo real até o objetivo @astar. Já a consistência exige que, para cada aresta, a estimativa do vértice de origem não exceda o custo da aresta somado à estimativa do vértice de destino.

Em algumas variantes, a heurística recebe um fator de ponderação $w$, e a função de avaliação passa a ser $f(n) = g(n) + w dot h(n)$, em que $g(n)$ é o custo acumulado desde o vértice inicial até $n$. Com $w = 0$, a heurística não influencia a escolha, e a busca se comporta como o Dijkstra. Valores maiores de $w$ tornam a busca mais orientada pela estimativa, o que pode reduzir o número de vértices explorados à custa da otimalidade do caminho @pohl1970heuristic.

A forma de calcular $h(n)$ depende do tipo de movimento permitido no espaço de busca. Em terrenos 3D, a estimativa mais comum é a distância euclidiana, que mede a distância em linha reta entre os vértices:

\
$ h(n) = sqrt((x_2 - x_1)^2 + (y_2 - y_1)^2 + (z_2 - z_1)^2) $ <formula_euclidiana> \

Em grades com movimentos apenas nos eixos, a distância de Manhattan soma as diferenças em cada coordenada:

\
$ h(n) = |x_2 - x_1| + |y_2 - y_1| + |z_2 - z_1| $ <formula_manhattan> \

A distância de Chebyshev toma a maior diferença entre as coordenadas. Ela corresponde ao número mínimo de passos em uma grade que permite movimentos diagonais, desde que cada passo tenha o mesmo custo:

\
$ h(n) = max(|x_2 - x_1|, |y_2 - y_1|, |z_2 - z_1|) $ <formula_chebyshev> \

A escolha da heurística depende de ela ser compatível com o custo das arestas. A euclidiana é admissível quando nenhuma aresta custa menos que a distância em linha reta entre seus extremos. A Chebyshev é admissível quando os movimentos diagonais custam o mesmo que os movimentos retos. Já a Manhattan superestima a distância real quando há movimentos diagonais, o que pode levar a caminhos não ótimos.

Como a heurística define a ordem de exploração, ela altera tanto o número de vértices visitados quanto a qualidade do caminho encontrado. Uma heurística admissível garante o caminho ótimo, enquanto uma heurística que superestima o custo pode explorar menos vértices e, ainda assim, não encontrar o menor caminho.

=== A\* <a_star>

O A\* é um algoritmo de busca que combina o custo acumulado com a estimativa do custo restante. Para cada vértice $n$, ele avalia

\
$ f(n) = g(n) + h(n) $ <formula_astar> #v(1.5em)

em que $g(n)$ é o custo do caminho desde o vértice inicial até $n$ e $h(n)$ é a heurística de $n$ até o objetivo. Como no Dijkstra, a busca usa uma fila de prioridade, mas ordena os vértices por $f(n)$, e não apenas por $g(n)$. Se a heurística for admissível, o caminho retornado tem o menor custo possível @astar.

\
#figure(
  caption: [Pseudocódigo do algoritmo A\*.],
  supplement: "Figura",
)[
  #v(-0.5em)
  #pseudocode-list[
    A\*$(G, w, s, t, h)$
    + para cada $v in V$ faça
      + $g_v arrow.l inf$
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
        + *se $v in.not S$ e $[g_v > g_u + W_(u,v)]$ então*
          + $g_v arrow.l (g_u + W_(u,v))$
          + $p_v arrow.l u$
          + *se $v in.not Q$ então $Q arrow.l Q union {v}$*
  ]
  #v(0.5em)
  Fonte: Elaborado pelo autor, com base em #cite(<rodacki_grafos>, form: "prose") e #cite(<astar>, form: "prose").
] <fig_astar> \ #v(-1.5em)

Na @fig_astar, as diferenças em relação ao Dijkstra estão em negrito. A inicialização das distâncias é igual à do Dijkstra, mas a fila $Q$ começa apenas com o vértice inicial $s$, pois a busca só precisa explorar a fronteira a partir dele.

A principal diferença está na escolha do vértice a ser expandido. Enquanto o Dijkstra remove de $Q$ o vértice de menor distância, o A\* remove o vértice de menor $f(u)$. Quando $h(n) = 0$ para todo $n$, as duas escolhas coincidem, e o Dijkstra passa a ser um caso particular do A\*.

Outra diferença é o critério de parada. O algoritmo termina quando o vértice removido é o objetivo $t$, e não quando $Q$ esvazia. Essa parada antecipada pode reduzir o número de vértices explorados. Vértices já finalizados em $S$ não são mais atualizados, e um vértice entra em $Q$ na primeira vez que é alcançado.

=== Weighted A\* <weighted_a_star>

O Weighted A\* é uma variante do A\* em que a heurística é multiplicada por um fator de ponderação $w$. A função de avaliação passa a ser:

\
$ f(n) = g(n) + w dot h(n) $ <formula_weighted_astar> \

Com $w = 1$, a busca coincide com o A\*. Com $w = 0$, a heurística deixa de influenciar a escolha e o algoritmo se comporta como o Dijkstra. Para $w > 1$, a estimativa passa a pesar mais na escolha, o que tende a reduzir o número de vértices explorados. Em contrapartida, o caminho encontrado pode não ser o de menor custo @pohl1970heuristic.

\
#figure(
  caption: [Pseudocódigo do algoritmo Weighted A\*.],
  supplement: "Figura",
)[
  #v(-0.5em)
  #pseudocode-list[
    Weighted A\*$(G, W, s, t, h)$
    + para cada $v in V$ faça
      + $g_v arrow.l inf$
      + $p_v arrow.l "nil"$
    + $g_s arrow.l 0$
    + *$Q arrow.l {s}$*
    + $S arrow.l nothing$
    + enquanto $Q != nothing$ faça
      + \# vértice de menor $f(u) = g_u + *w* dot h(u)$
      + $u arrow.l "pop"(Q)$ 
      + *se $u = t$ então retorna o caminho até $t$ por $p$*
      + $S arrow.l S union {u}$
      + para cada $"vértice" v in "adj"(u)$ faça
        + *se $v in.not S$ e $[g_v > g_u + W_(u,v)]$ então*
          + $g_v arrow.l (g_u + W_(u,v))$
          + $p_v arrow.l u$
          + *se $v in.not Q$ então $Q arrow.l Q union {v}$*
  ]
  #v(0.5em)
  Fonte: Elaborado pelo autor, com base em #cite(<rodacki_grafos>, form: "prose") e #cite(<astar>, form: "prose").
] <fig_weighted_astar> \ #v(-1.5em)

Na @fig_weighted_astar, as diferenças em relação ao Dijkstra estão em negrito, e são as mesmas do A\*, acrescidas do fator $w$ na seleção do vértice. Como a estrutura do pseudocódigo é a do A\*, a única mudança de comportamento vem da função de avaliação, e por isso o restante da explicação do A\* se aplica aqui.

O valor de $w$ define o equilíbrio entre velocidade e otimalidade. Valores próximos de 1 mantêm a garantia do A\* quando a heurística é admissível. Valores maiores fazem a busca se aproximar do comportamento de uma busca gulosa, que é o caso tratado a seguir.

=== Greedy Best-First Search <gbfs>

A Greedy Best-First Search ordena os vértices apenas pela heurística, sem considerar o custo acumulado até eles. Assim, a função de avaliação é:

\
$ f(n) = h(n) $ <formula_gbfs> \

Essa escolha torna a busca rápida, porque ela tende a seguir diretamente na direção do objetivo. Em contrapartida, como o custo acumulado é ignorado, o caminho encontrado pode ser longo e não é garantidamente o de menor custo. A Greedy Best-First Search corresponde ao caso em que o peso da heurística tende ao infinito no Weighted A\*.

\
#figure(
  caption: [Pseudocódigo da Greedy Best-First Search.],
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
  Fonte: Elaborado pelo autor, com base em #cite(<rodacki_grafos>, form: "prose") e #cite(<astar>, form: "prose").
] <fig_gbfs> \ #v(-1.5em)

Na @fig_gbfs, as diferenças em relação ao Dijkstra estão em negrito. Não há $g_v$ nem relaxação: a fila é ordenada apenas por $h(u)$, e cada vértice é inserido uma única vez, na primeira vez em que é descoberto. Por isso, a inicialização não precisa das distâncias, e a condição de atualização depende apenas de o vértice já ter sido visitado ou estar na fila.

== Geração Procedural de Terrenos <geracao_terrenos>

A geração procedural consiste em criar conteúdo automaticamente, a partir de algoritmos e de um conjunto de regras ou parâmetros. Em terrenos 3D, essa abordagem produz paisagens complexas e variadas sem modelagem manual. Como o resultado depende apenas dos parâmetros e de uma semente inicial, a mesma configuração pode ser reproduzida com exatidão.

=== Mapas de altura <heightmap>

Um mapa de altura é uma matriz bidimensional em que cada elemento armazena a altura do terreno naquele ponto. Quando essa matriz é exibida como imagem em escala de cinza, a intensidade de cada pixel corresponde à elevação. Em geral, os valores são normalizados no intervalo $[0, 1]$ e multiplicados por um fator de escala $H$, que define a altura máxima do terreno.

Para obter a geometria tridimensional, cada elemento $(i, j)$ da matriz é associado a um vértice cujas coordenadas são

$ (x, y, z) = (i, h(i, j), j) $ <formula_vertice>

em que $h(i, j)$ é a altura armazenada naquele ponto. Dessa forma, o plano horizontal da grade é preservado, e a altura passa a ser a coordenada $y$ (@fig_mapa_altura). 

\
#figure(
  caption: [Conversão de um mapa de altura em vértices tridimensionais.],
  supplement: "Figura",
)[
  #image("images/pixel_to_vertex.png", width: 90%)
  #v(0.5em)
 Fonte: Elaborado pelo autor.
] <fig_mapa_altura> \ #v(-1.5em)

Dessa forma, um pixel totalmente preto ($v = 0$) resultará em uma altura de 0, enquanto um pixel totalmente branco ($v = 255$) atingirá a altura máxima estipulada ($H$), permitindo um controle preciso sobre a amplitude do relevo gerado.

Por fim, são criadas faces conectando cada vértice com seus vizinhos diretos, formando uma malha de triângulos que representa a superfície do terreno. Essa malha pode então ser utilizada como cenário de teste para os algoritmos de _pathfinding_, permitindo avaliar seu desempenho em ambientes tridimensionais complexos.

\
#figure(
  caption: [Exemplo de malha gerada a partir de um mapa de altura],
  supplement: "Figura",
)[
  #image("./images/heightmap_to_mesh.png", width: 63%)
  #v(0.5em)
  #text(size: 10pt)[Fonte: Elaborado pelo autor.]
] <fig_heightmap_mesh> \ #v(-1.5em)

A criação de mapas de altura pode ser feita a partir de imagens reais, como fotografias aéreas ou imagens de satélite, ou gerada proceduralmente por algoritmos de ruído, como o ruído de Perlin (@perlin).



=== Ruído de Perlin <perlin>

O ruído de Perlin é um algoritmo de geração de ruído gradiente, proposto por #cite(<perlin1985image>, form: "prose"), que produz variações contínuas e suaves. Diferentemente de um ruído puramente aleatório, cada valor depende de uma grade regular de vetores de gradiente, o que faz o resultado variar gradualmente. Por isso, o ruído de Perlin é adequado para simular relevos naturais.

O valor do ruído em um ponto é obtido a partir da célula da grade que o contém. Cada canto $c$ dessa célula possui um vetor de gradiente unitário $arrow(g)_c$, com direção aleatória. Para cada canto, calcula-se o vetor de distância $arrow(d)_c$ entre o ponto e o canto, e o produto escalar entre os dois vetores:

\
$ s_c = arrow(d)_c dot arrow(g)_c = d_(c,x) g_(c,x) + d_(c,y) g_(c,y) $ <formula_produto_escalar> \

Esses valores $s_c$ são as contribuições de cada canto. O tamanho da célula determina o nível de detalhe: células maiores produzem um ruído mais suave, e células menores produzem um ruído mais detalhado.

\
#figure(
  caption: [Ruído de Perlin com células de diferentes tamanhos.],
  supplement: "Figura",
)[
  #columns(3)[
    #image("images/wave_pequena.png", width: 100%)
    #align(center)[(a) Ruído gerado com \ células pequenas.]
    #colbreak()
    #image("images/wave_mediana.png", width: 100%)
    #align(center)[(b) Ruído gerado com \ células medianas.]
    #colbreak()
    #image("images/wave_grande.png", width: 100%)
    #align(center)[(c) Ruído gerado com \ células grandes.]
  ]
  #v(0.5em)
  #text(size: 10pt)[Fonte: Elaborado pelo autor.]
] <fig_perlin_celulas> \ #v(-1.5em)

==== Função de suavização <sec_interpolacao>

As contribuições dos cantos são combinadas por interpolação, dentro da própria célula. A interpolação linear simples produz transições com mudança abrupta de inclinação nas bordas da célula, o que se torna visível no terreno. Para evitar isso, o peso de interpolação $w$ é substituído por uma função de suavização $S(w)$. A proposta original de Perlin utiliza uma curva cúbica, e versões posteriores empregam a curva quíntica:

\
$ S(w) = 6w^5 - 15w^4 + 10w^3 $ <formula_suavizacao> #v(1.5em)

Com essa função, a interpolação entre dois valores $a_0$ e $a_1$ é dada por:

\
$ f(a_0, a_1, w) = a_0 + (a_1 - a_0) dot S(w) $ <formula_interpolacao> \

==== Oitavas <oitavas>

Uma única oitava do ruído tem um nível de detalhe fixo. Para obter relevos com variações em diferentes escalas, somam-se várias oitavas, cada uma com frequência e amplitude próprias. Para a oitava $i$, com $i = 0, 1, ..., N-1$, tem-se

\
$ f_i = f dot l^i, quad a_i = a_0 dot p^i $ <formula_frequencia_amplitude> #v(1.5em)

e o valor final do ruído é a soma das oitavas:

\
$ V(x, y) = sum_(i=0)^(N-1) a_i dot "ruído"(x dot f_i, y dot f_i) $ <formula_oitavas> \

Os parâmetros $f$, $a_0$, $l$, $p$ e $N$ controlam o resultado final de maneiras distintas, descritas a seguir.

A frequência inicial $f$ define a escala do ruído na primeira oitava. Quando $f$ aumenta, o padrão se repete com mais proximidade, e uma mesma área apresenta mais elevações e depressões. Como todas as oitavas são multiplicadas pela mesma proporção de $f$, a escala de todo o terreno muda, e não apenas um detalhe.

A amplitude inicial $a_0$ define o alcance vertical da primeira oitava. Como $a_i = a_0 dot p^i$, aumentar $a_0$ multiplica a contribuição de todas as oitavas pelo mesmo fator. Assim, $a_0$ altera a altura total do relevo sem mudar a proporção entre detalhes grandes e pequenos.

A lacunaridade $l$ determina quanto a frequência cresce de uma oitava para a seguinte. Valores altos fazem as oitavas finais ter frequências muito maiores que as iniciais, de modo que o detalhe se concentra em escalas pequenas e o relevo fica mais irregular. Valores próximos de 1 fazem todas as oitavas ter frequência semelhante, e o resultado se aproxima de um único ruído escalado. A @fig_lacunaridade compara ruídos com lacunaridade baixa e alta, mantendo os demais parâmetros.

\
#figure(
  caption: [Variação da lacunaridade: ruídos com lacunaridade baixa e alta.],
  supplement: "Figura",
)[
  #columns(2)[
    #image("images/lac_baixa.png", width: 100%)
    #align(center)[(a) Ruído de baixa lacunaridade.]
    #colbreak()
    #image("images/lac_alta.png", width: 100%)
    #align(center)[(b) Ruído de alta lacunaridade.]
  ]
  #v(0.5em)
  #text(size: 10pt)[Fonte: Elaborado pelo autor.]
] <fig_lacunaridade> \ #v(-1.5em)

A persistência $p$ determina quanto a amplitude diminui de uma oitava para a seguinte. Valores baixos fazem os detalhes finos ter pouca influência, e o relevo fica dominado pelas formas amplas. Valores altos mantêm as oitavas finas com peso comparável ao das oitavas grandes, e o terreno fica mais áspero. A @fig_persistencia mostra essa diferença, mantendo os demais parâmetros.

\
#figure(
  caption: [Variação da persistência: ruídos com persistência baixa e alta.],
  supplement: "Figura",
)[
  #columns(2)[
    #image("images/pers_baixa.png", width: 100%)
    #align(center)[(a) Ruído de baixa amplitude/persistência.]
    #colbreak()
    #image("images/pers_alta.png", width: 100%)
    #align(center)[(b) Ruído de alta amplitude/persistência.]
  ]
  #v(0.5em)
  #text(size: 10pt)[Fonte: Elaborado pelo autor.]
] <fig_persistencia> \ #v(-1.5em)

O número de oitavas $N$ define quantas camadas são somadas. Com poucas oitavas, o ruído contém apenas as escalas mais grosseiras. Cada oitava adicional acrescenta detalhes menores, cujo peso é reduzido por $p^i$. Por isso, com persistência baixa, oitavas adicionais quase não alteram o resultado, e com persistência alta, cada uma contribui de forma perceptível (@fig_oitavas).

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
] <fig_oitavas> \ #v(-1.5em)

Valores comumente usados são próximos de 2 para a lacunaridade e de 0,5 para a persistência, de modo que cada oitava tem o dobro da frequência e metade da amplitude da anterior. Essa combinação é descrita por #cite(<patel_terrain_noise>, form: "prose"), e produz terrenos com grandes elevações e pequenas variações ao mesmo tempo.

== Representações Geométricas de Terrenos

Formas de representar a geometria (visual) de terrenos em um ambiente 3D, utilizando diferentes técnicas e abstrações.

=== Voxels

Representação volumétrica de terrenos, onde o espaço é dividido em pequenas unidades cúbicas (voxels), permitindo a modelagem de formas complexas e detalhadas.

=== Marching Cubes/Transvoxel

Algoritmos de reconstrução de superfícies a partir de dados volumétricos, como voxels, permitindo a criação de malhas poligonais suaves e contínuas.

figura: exemplo de reconstrução de superfícies com Marching Cubes e Transvoxel

== Representações Navegáveis de Terrenos <representacoes_navegaveis>

Formas de representar a navegação em terrenos, permitindo a movimentação e interação com o ambiente.

=== Grade 2.5D

Representação de terrenos em uma grade bidimensional com informações de altura. Baseada únicamente na altura do terreno.

figura: exemplo de grade 2.5D

=== Superfície Voxel

Representação de terrenos utilizando voxels, permitindo a modelagem de superfícies complexas e detalhadas, com informações de altura e volume.

figura: exemplo de superficie voxel

=== Grafo de Vértices

Representação de terrenos onde os vértices da malha do terreno representam pontos navegáveis.

figura: exemplo de grafo de vértices

=== Grafo Dual

Representação de terrenos onde os polígonos da malha do terreno representam regiões navegáveis, e as arestas conectam polígonos adjacentes.

figura: exemplo de grafo dual

== Avaliação de desempenho e estatísticas <avaliacao>

ANOVA e post-hoc de Tukey.

== Trabalhos relacionados
=== Johansson
=== Kapi 
=== Matriz de diferença
figura: matrix de diferença

= Desenvolvimento

Neste capítulo, são apresentados os detalhes do desenvolvimento do trabalho, incluindo a arquitetura do sistema, a implementação dos algoritmos de busca, a geração de terrenos e a instrumentação para coleta de dados e testes.

== Pipeline

Ruido -> Heightmap -> Representação Navegável -> Algoritmo de Busca -> Coleta de métricas -> Análise estatística

figura: pipeline do desenvolvimento

== IFCG e visualizador concorrente

Motor gráfico para visualização de terrenos e caminhos encontrados pelos algoritmos de busca, permitindo a inspeção visual dos resultados.

figura: cena renderizada e diagrama taskmaster

== lwGraph\<T\>

Estrutura de dados genérica para representar grafos, utilizada na implementação dos algoritmos de busca e na representação navegável dos terrenos.

== search.hpp

Algoritmos de busca implementados em C++, incluindo Dijkstra, A\*, WA\* e GBFS, com suporte a aquisição de dados e coleta de métricas.

== Gerador de terrenos

Ferramenta para geração de terrenos 3D, permitindo a criação de modelos realistas com diferentes características e propriedades.

figura: exemplo de diferentes representações navegaveis do mesmo terreno

== GraphModel, GraphFactory, isTranversable

Classes para modelar, fabricar e verificar a traversabilidade de grafos.

== Instrumentação

Ferramentas e técnicas para coleta de dados e testes, incluindo aquisição de métricas e análise estatística.

=== Statistics

Classe para coletar e exportar métricas.

=== acquire.sh

Script para aquisição de métricas, executando os algoritmos de busca em diferentes representações navegáveis de terrenos e coletando os resultados.

=== CLI

Interface de linha de comando para executar os testes, coletas ou exportações de dados.

= Metodologia

Neste capítulo, são descritos os métodos e procedimentos utilizados para conduzir a pesquisa, incluindo o ambiente experimental, as variáveis analisadas, os níveis de teste, o procedimento de coleta de dados e as métricas utilizadas para avaliação dos resultados.

== Tipo de pesquisa

Definição do tipo de pesquisa realizada, incluindo a abordagem experimental, comparativa e estatística adotada para avaliar o desempenho dos algoritmos de busca em diferentes representações navegáveis de terrenos 3D.

== Ambiente

Configuração do ambiente experimental, incluindo hardware, software, bibliotecas e ferramentas utilizadas para a implementação dos algoritmos de busca, geração de terrenos e coleta de métricas.

== Variáveis

Variáveis independentes e dependentes analisadas na pesquisa, incluindo as representações navegáveis de terrenos, os algoritmos de busca e as métricas de desempenho coletadas.

figura: tabela de variáveis independentes e dependentes

== Níveis

Definição dos níveis de teste para cada variável, incluindo diferentes representações navegáveis de terrenos, algoritmos de busca e configurações de parâmetros utilizados nos experimentos.

figura: tabela de níveis de teste para cada variável

== Procedimento e métricas

Descrição do procedimento de coleta de dados e das métricas utilizadas para avaliar o desempenho dos algoritmos de busca.

== Protocolo estatístico

Descrição do protocolo estatístico utilizado para análise dos dados coletados, incluindo testes de hipótese, intervalos de confiança e modelos de regressão.

== Ameaças

Identificação e análise das ameaças à validade interna e externa do estudo, incluindo possíveis fontes de viés, limitações do método e impacto sobre os resultados obtidos.

= Resultados e Discussão

= Conclusão

#pagebreak()

#text(white, size: 1pt)[#heading(numbering: none)[REFERÊNCIAS]]
#v(-1.5em)
#align(center)[
  #text(weight: "bold", size: 12pt)[REFERÊNCIAS]
  #v(1.5em)
]

#bibliography("referencias.bib", style: "associacao-brasileira-de-normas-tecnicas.csl", title: none)