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
  lista_ilustracoes: false,
  lista_tabelas: false,
  corpo
) = {
  // 1. Configuração Básica da Página
  set page(
    paper: "a4",
    margin: (top: 3cm, left: 3cm, right: 2cm, bottom: 2cm),
    numbering: none // Numeração invisível nos pré-textuais
  )
  
  set text(font: ("Times New Roman"), size: 12pt, lang: "pt", region: "br")

  // ==========================================
  // ELEMENTOS PRÉ-TEXTUAIS
  // ==========================================

  // --- CAPA (Obrigatório) ---
  align(center)[
    #text(weight: "bold", upper(instituicao)) \
    #text(weight: "bold", upper(curso))

    #v(2fr)
    
    #text(weight: "bold", size: 14pt, upper(titulo))
    #if subtitulo != "" [
      #text(weight: "bold", size: 14pt)[: #subtitulo]
    ]
        
    #v(1fr)
    #text(weight: "bold", upper(autor))
    #v(1fr)

    #text(weight: "bold", local) \
    #text(weight: "bold", ano)
  ]
  pagebreak()

  // --- FOLHA DE ROSTO (Obrigatório) ---
  align(center)[
    #text(upper(autor))
    #v(1fr)
    
    #text(weight: "bold", upper(titulo))
    #if subtitulo != "" [
      #text(weight: "bold")[: #subtitulo]
    ]
    #v(3em)
    
    // Recuo de 8cm para a nota de natureza do trabalho
    #align(right)[
      #pad(left: 8cm)[
        #set text(size: 10pt)
        #set par(leading: 0.3em, justify: true)
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

  // --- LISTA DE ILUSTRAÇÕES (Opcional) ---
  if lista_ilustracoes [
    #align(center)[#text(weight: "bold")[LISTA DE ILUSTRAÇÕES]]
    #v(1.5em)
    #outline(title: none, target: figure.where(kind: image))
    #pagebreak()
  ]

  // --- LISTA DE TABELAS (Opcional) ---
  if lista_tabelas [
    #align(center)[#text(weight: "bold")[LISTA DE TABELAS]]
    #v(1.5em)
    #outline(title: none, target: figure.where(kind: table))
    #pagebreak()
  ]

  // --- SUMÁRIO (Obrigatório) ---
  align(center)[#text(weight: "bold")[SUMÁRIO]]
  v(1.5em)
  
  show outline.entry.where(level: 1): it => {
    v(1em, weak: true)
    strong(it)
  }
  
  outline(title: none, depth: 3, indent: 0.5em)
  pagebreak()

  // ==========================================
  // ELEMENTOS TEXTUAIS E FORMATAÇÃO DO CORPO
  // ==========================================

  // A partir daqui, a numeração de páginas fica visível
  set page(numbering: "1", number-align: top + right)

  set par(
    justify: true, 
    first-line-indent: 1.25cm, 
    leading: 0.5em, 
    spacing: 0.5em
  )

  set heading(numbering: "1.1")
  show heading: it => {
    set text(size: 12pt, weight: "bold")
    set block(above: 1.5em, below: 1em) 
    
    if it.level == 1 {
      // Capítulos principais quebram página
      pagebreak(weak: true)
      upper(it)
    } else if it.level == 2 {
      it
    } else {
      // Subseções de nível 3 em diante sem negrito
      set text(weight: "regular")
      it
    }
    par(text(size: 0pt, ""))
  }

  // Formatação de Figuras e Tabelas
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

  // Formatação das Referências
  show bibliography: set text(size: 12pt)
  show bibliography: set par(leading: 0.3em, first-line-indent: 0pt, justify: false)
  show bibliography: set block(spacing: 1.5em)
  show bibliography: set align(left)

  corpo
}

// ==========================================
// FUNÇÕES AUXILIARES
// ==========================================

#let citacao_longa(texto) = {
  pad(left: 4cm, right: 0cm)[
    #set text(size: 10pt)
    #set par(first-line-indent: 0pt, leading: 0.3em)
    #texto
  ]
  v(1em)
}


// ==========================================
// APLICAÇÃO DO TEMPLATE (CONTEÚDO DO PROJETO)
// ==========================================

#show: pre_projeto_abnt.with(
  titulo: "Análise Estatística e Comparativa de Algoritmos de Pathfinding em Malhas 3D",
  autor: "André Vitor Bastos de Macêdo",
  orientador: "Prof. Paulo César Rodacki Gomes",
  instituicao: "Instituto Federal Catarinense - IFC",
  curso: "Bacharelado de Ciência da Computação",
  local: "Blumenau",
  ano: "2026",
  natureza_trabalho: "",
  
  lista_ilustracoes: false,
  lista_tabelas: false,
)

= Ideias iniciais

== Modo de pesquisa proposto
O modo de pesquisa será experimental, serão implementadas diversas malhas 3D e algoritmos de pathfinding, a partir deles serão coletadas amostras de dados e, por fim, serão realizadas análises estatísticas para comparar o desempenho dos algoritmos.

== Metas e objetivos
Para esse estudo, as metas incluem coletar dados substanciais sobre o desempenho dos algoritmos de pathfinding em malhas 3D. Visando comparar não apenas o tempo de execução, mas se aprofundar em situações reais de uso, onde haverá overheads de otimização, concorrência, etc. O objetivo é fornecer uma análise detalhada do desempenho desses algoritmos em ambientes 3D, detectando padrões e tendências.
=== Objetivos
- Implementar uma estrutura de dados eficiente para representar grafos.
- Desenvolver um ambiente de renderização de malhas 3D para simular os cenários de teste.
- Implementar os algoritmos de pathfinding (A\*, JPS, Tetha\*, etc.).
- Coletar dados de desempenho (tempo de execução, uso de memória, qualidade do caminho, etc.) para cada algoritmo em diferentes cenários.
- Analisar os dados coletados utilizando técnicas estatísticas para comparar o desempenho dos algoritmos.
- Apresentar os resultados de forma clara e compreensível, utilizando gráficos e tabelas.

== Sinopse
A ideia principal é desenvolver um estudo comparativo estatístico entre algoritmos de pathfinding em malhas 3D. Focando em algoritmos como A\*, JPS, Tetha\*, entre outros. Para parâmetro de comparação serão empregadas métricas quantitativas como tempo de execução, uso de memória, qualidade/tamanho do caminho encontrado, overheads de otimização e assim vai. Serão testados em cenários diversos, desde ambientes simples até complexos (com diferentes densidades de obstáculos e topologias), e circunstâncias diferentes, como ambientes dinâmicos, concorrências, etc. 

== Antecedentes
O estudo de algoritmos de busca vem evoluindo significativamente, porém há uma lacuna na literatura. Muitos algoritmos são vistos em suas respectivas bolhas, em ambientes perfeitos para que sejão eficientes, raramente considerando as complexidades dos ambientes reais. Esta proposta visa trazer uma análise estatística detalhada do desempenho de algoritmos de pathfinding em malhas 3D. Trazendo um comparativo entre grandes algoritmos como A\*, JPS, Tetha\*, entre outros, em cenários diversos e circunstâncias diferentes. Optando por uma visão aprofundada individual entre cada um e suas particularidades, ao invés de uma visão superficial e generalizada.

== Contribuições
São esperadas contribuições significativas quanto à compreensão e poder de escolha de algoritmos de pathfinding em malhas 3D. Como a distinção entre os pontos fortes e fracos de cada algoritmo e em quais cenários eles se destacam ou apresentam dificuldades. Além disso, a implementação de uma estrutura de dados eficiente para representar grafos e um ambiente de renderização de malhas 3D pode ser útil para outros pesquisadores e desenvolvedores que trabalham com algoritmos de pathfinding.
Espero sair desde estudo com uma bagagem sólida e aprofundada sobre grafos e renderização 3D.

== Metodologia
O estudo será conduzido em partes, tanto à renderização de malhas 3D e implementação de algoritmos de grafos, quanto à coleta e análise de dados. O estudo empregará duas bibliotecas desenvolvidas por mim, uma para renderização de malhas 3D e outra para implementação de algoritmos de grafos. O desenvolvimento das bibliotecas será feito paralelamente aos estudos, conforme a coleta de dados ou a implementação de novos algoritmos requerir ajustes ou otimizações. A coleta de dados será feita por meio de testes controlados, onde cada algoritmo será executado em um conjunto de cenários pré-definidos, e as métricas serão registradas. A análise dos dados será feita utilizando técnicas estatísticas para comparar o desempenho dos algoritmos, e a apresentação dos resultados incluirá gráficos e tabelas para facilitar a compreensão.

= INTRODUÇÃO

= PROBLEMA DE PESQUISA

= HIPÓTESE(S)

= JUSTIFICATIVA

= OBJETIVOS

== Objetivo Geral

== Objetivos Específicos

= REVISÃO TEÓRICA

= METODOLOGIA

= CRONOGRAMA

#figure(
  caption: [Cronograma de execução das atividades],
  supplement: "Tabela",
)[
  #table(
    columns: (auto, 1fr),
    stroke: none,
    align: (left, center),
    table.hline(y: 0, stroke: 1pt),
    table.hline(y: 1, stroke: 0.5pt),
    [*ETAPAS*], [*PERÍODOS*],
    [Revisão de Bibliografia], [Jan/2026 a Fev/2026],
    [Heurísticas e Buscas Avançadas], [Fev/2026 a Mar/2026],
    [Pathfinding e NavMesh], [Mar/2026 a Abr/2026],
    [Casos de teste e Métricas], [Abr/2026],
    [Arquitetura e Preparação do Ambiente em C++], [Fev/2026 a Mai/2026],
    [Redação do Pré-Projeto], [Mai/2026],
    [Revisão do Pré-Projeto], [Jun/2026],
    [Defesa do Pré-Projeto], [Jun/2026],
    [Desenvolvimento de Malhas e Grafos], [Jul/2026 a Ago/2026],
    [Implementação dos Algoritmos], [Jul/2026 a Ago/2026],
    [Otimização], [Ago/2026],
    [Concorrência], [Ago/2026],
    [Recolha de Dados], [Set/2026 a Out/2026],
    [Comparação de Dados], [Set/2026 a Out/2026],
    [Análise Visual], [Set/2026 a Out/2026],
    [Tratamento de Dados], [Nov/2026],
    [Redação Final], [Nov/2026],
    [Revisão], [Dez/2026],
    [Defesa], [Dez/2026],
    table.hline(y: 20, stroke: 1pt)
  )
  #v(0.5em)
  #text(size: 10pt)[Fonte: Elaborado pelo autor (2026).]
]

@rodacki_grafos \
@cormen_algoritmos \
@russel_ia \
@a_star_multithreaded \
@navigation_mesh \
@a_star_modification \
@jps_3d \
@pathfinding_game_dev \
@breaking_sorting_barrier

// =======================================================
// ELEMENTOS PÓS-TEXTUAIS
// =======================================================

// 1. Referências
#bibliography("referencias.bib", style: "associacao-brasileira-de-normas-tecnicas.csl", title: "REFERÊNCIAS")