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
    "SIG": [Sigla]
  )
)

= Introdução
A busca de caminhos (ou _pathfinding_) é um dos campos mais tradicionais da Inteligência Artificial aplicada, evoluindo a partir dos algoritmos de busca clássicos em grafos. Como definem #cite(<russell_norvig>, form: "prose"), os métodos clássicos de busca resolvem problemas de estados, ações e custos, visando encontrar caminhos entre um ponto de partida e um objetivo por meio da exploração do espaço de busca. Ao longo das últimas décadas, essa fundamentação deixou de ser puramente abstrata e passou a ser aplicada diretamente na computação interativa. Conforme apontam #cite(<pathfinding_game_dev>, form: "prose"), os algoritmos de busca tornaram-se componentes cruciais para o desenvolvimento de jogos modernos e simulações em tempo real.

No entanto, a transição do espaço de busca de 2D para 3D introduziu um aumento significativo na complexidade, exigindo adaptações às técnicas de busca e de representação do terreno. A escolha da representação do espaço transitável e do algoritmo de busca a ser utilizado tornou-se uma decisão crítica, impactando diretamente o desempenho e a qualidade dos caminhos encontrados.

\
#figure(
  caption: [Comparação entre representações 2D e 3D],
  supplement: "Figura",
)[
  // #image("", width: 75%)
  #v(0.5em)
 Fonte: Elaborado pelo autor.
] <fig_2Dx3D> \ #v(-1.5em)

Em estudos recentes, é comumente evitada a comparação de múltiplas representações navegáveis de terrenos 3D, com foco em apenas uma abornagem na maiora das vezes. Além disso, a análise estatística do desempenho dos algoritmos de busca em diferentes representações é frequentemente negligenciada, limitando a compreensão das interações entre a estrutura do terreno e o comportamento dos algoritmos.

Esse trabalho propõe uma análise comparativa e estatística do desempenho de algoritmos clássicos de busca de caminhos em diferentes representações navegáveis de terrenos 3D. A pesquisa busca responder à seguinte questão central: Qual é a influência da *representação navegável* de um terreno 3D e das *características do terreno* no desempenho e na qualidade da busca de algoritmos clássicos de busca?

== Contribuições

Para responder à questão central, é necessário realizar uma análise detalhada das representações navegáveis de terrenos 3D, dos algoritmos de busca aplicados e das métricas de desempenho utilizadas. Com isso, as principais contribuições deste trabalho incluem:

+ #text()[*Comparação entre representações navegáveis.* \
As mesmas instâncias de terreno são convertidas em quatro grafos diferentes e avaliadas com os mesmos algoritmos:
  - a partir do mapa de altura: grade de altura (2.5D) e superfície voxel;
  - a partir da malha poligonal: grafo de vértices e grafo dual.]
+ #text()[*Metodologia experimental reprodutível.* \
Os terrenos são gerados proceduralmente a partir de parâmetros controlados (escala, lacunaridade, persistência) e semente registrada, e os resultados passam por análise estatística (ANOVA e testes post hoc).]
+ #text()[*Implementação open-source.* \
Inclui uma biblioteca de grafos leve e o motor gráfico IFCG, com visualização das malhas e dos caminhos.]

== Objetivos

O objetivo geral do estudo é analisar comparativa e estatisticamente o desempenho de algoritmos clássicos de _pathfinding_ em diferentes representações navegáveis de terrenos 3D. Mais especificamente, os objetivos incluem:

+ Implementar uma biblioteca de grafos e os algoritmos Dijkstra, A\*,  Weighted A\* e Greedy Best-First.
+ Desenvolver um gerador procedural de terrenos baseado em ruído de Perlin, parametrizado por escala, lacunaridade e persistência.
+ Construir quatro representações navegáveis a partir do terreno: grade de altura, superfície voxel, grafo de vértices e grafo dual da malha.
+ Desenvolver um ambiente 3D com execução concorrente para visualização das malhas e dos caminhos encontrados.
+ Automatizar a coleta de métricas e analisar estatisticamente os resultados obtidos.

= Fundamentação Teórica

Este capítulo apresenta os conceitos fundamentais que embasam o trabalho, incluindo grafos, algoritmos de busca, geração procedural de terrenos, representações geométricas e navegáveis de terrenos, avaliação de desempenho e trabalhos relacionados.

== Grafos

Estrutura de dados composta por vértices e arestas, utilizada para modelar relações entre elementos.

figura: exemplo de grafo com vértices e arestas 

=== Definição

Conjunto de vértices e arestas que conectam pares de vértices, representando relações entre elementos. Pode ser direcionado ou não direcionado, ponderado ou não ponderado.

fórmula: G = (V, E), onde G é o grafo, V é o conjunto de vértices e E é o conjunto de arestas.

=== Pesos

Atribuição de valores numéricos às arestas, representando custos ou distâncias entre vértices. Pode ser constante ou variável, dependendo da aplicação.

figura: exemplo de grafo com e sem pesos

=== Caminho

Sequência de vértices conectados por arestas, representando uma rota entre dois pontos no grafo.

figura: exemplo de caminho em um grafo

=== Componente conexo

Subgrafo em que todos os vértices estão conectados entre si, permitindo a existência de caminhos entre quaisquer pares de vértices.

figura: exemplo de componentes conexos em um grafo

== Busca

Processo de encontrar um caminho entre dois vértices em um grafo, utilizando diferentes estratégias e algoritmos.

figura: diversos caminhos possíveis entre dois vértices em um grafo

=== Dijkstra

Algoritmo de busca de caminho mínimo em grafos ponderados, garantindo a descoberta do caminho mais curto entre um vértice inicial e todos os outros vértices.

=== Heurísticas

Funções que estimam o custo de um caminho entre dois vértices, ajudando a direcionar a busca para áreas mais promissoras.

fórmula: heuristica euclidiana = sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2), onde (x1, y1, z1) e (x2, y2, z2) são as coordenadas dos vértices.

=== A\*

Algoritmo de busca baseado no Dijkstra que utiliza heurísticas para encontrar o caminho mais curto entre dois vértices, combinando a precisão do seu pai com o uso de heurísticas.

fórmula: f(n) = g(n) + h(n), onde f(n) é o custo total estimado, g(n) é o custo do caminho até o vértice n e h(n) é a heurística estimada do vértice n até o objetivo.

=== Weighted A\*

Algoritmo de busca que combina a abordagem do A\* com um fator de ponderação, permitindo encontrar caminhos mais rápidos, mas possivelmente subótimos.

fórmula: f(n) = g(n) + w \* h(n), onde w é o fator de ponderação que ajusta a influência da heurística na busca.

=== Greedy Best-First Search

Algoritmo de busca que utiliza apenas heurísticas para guiar a busca, priorizando a exploração de vértices mais promissores, mas sem garantir a descoberta do caminho mais curto.

fórmula: f(n) = h(n), onde f(n) é o custo total estimado e h(n) é a heurística estimada do vértice n até o objetivo.

== Geração Procedural de Terrenos

Para gerar terrenos 3D de forma eficiente e realista, técnicas de geração procedural são empregadas, permitindo a criação de paisagens complexas e reprodutíveis a partir de algoritmos matemáticos.

=== Heightmap

Representação de terrenos 3D utilizando uma imagem em escala de cinza, onde a intensidade de cada pixel corresponde à altura do terreno naquele ponto.

figura: heightmap de elder scrolls, malha 3D gerada a partir do heightmap

=== Perlin

Algoritmo de geração de ruído contínuo, utilizado para criar padrões naturais e realistas em terrenos, texturas e outros elementos gráficos.

figura: ruidos de cada parâmetro, heightmap + malha final

== Representações Geométricas de Terrenos

Formas de representar a geometria (visual) de terrenos em um ambiente 3D, utilizando diferentes técnicas e abstrações.

=== Voxels

Representação volumétrica de terrenos, onde o espaço é dividido em pequenas unidades cúbicas (voxels), permitindo a modelagem de formas complexas e detalhadas.

=== Marching Cubes/Transvoxel

Algoritmos de reconstrução de superfícies a partir de dados volumétricos, como voxels, permitindo a criação de malhas poligonais suaves e contínuas.

figura: exemplo de reconstrução de superfícies com Marching Cubes e Transvoxel

== Representações Navegáveis de Terrenos

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

== Avaliação de desempenho e estatísticas

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