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
    
    #v(1fr)
    #text(weight: "bold", upper(autor))
    #v(1fr)
    
    #text(weight: "bold", size: 14pt, upper(titulo))
    #if subtitulo != "" [
      #text(weight: "bold", size: 14pt)[: #subtitulo]
    ]
    
    #v(2fr)
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
  titulo: "Análise Visual e Comparativa de Algoritmos de Pathfinding de Malhas3D em Tempo Real",
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

= INTRODUÇÃO 

== Tema e Problema de Pesquisa

== Justificativa

= OBJETIVOS

== Objetivo Geral

== Objetivos Específicos

= FUNDAMENTAÇÃO TEÓRICA

= METODOLOGIA

= CRONOGRAMA

#figure(
  caption: [Cronograma de execução das atividades],
  supplement: "Tabela",
)[
  #table(
    columns: (auto, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    stroke: none,
    align: (left, center, center, center, center, center, center),
    table.hline(y: 0, stroke: 1pt),
    table.hline(y: 1, stroke: 0.5pt),
    [*Atividade*], [*Jan*], [*Fev*], [*Mar*], [*Abr*], [*Mai*], [*Jun*],
    [Revisão Bibliográfica e Fundamentação], 
    [], [X], [X], [], [], [],
    [Infraestrutura e Geração de Malhas], 
    [], [], [X], [], [], [],
    [Implementação dos Algoritmos], 
    [], [], [X], [X], [], [],
    [Coleta de Métricas e Casos de Teste], 
    [], [], [], [X], [X], [],
    [Otimização, Concorrência e Análise Visual], 
    [], [], [], [X], [X], [],
    [Redação Final], 
    [], [], [], [], [X], [X],
    [Defesa], 
    [], [], [], [], [], [X],
    table.hline(y: 8, stroke: 1pt)
  )
  #v(0.5em)
  #text(size: 10pt)[Fonte: Elaborado pelo autor (2026).]
]

// =======================================================
// ELEMENTOS PÓS-TEXTUAIS
// =======================================================

// 1. Referências
#bibliography("referencias.bib", style: "associacao-brasileira-de-normas-tecnicas.csl", title: "REFERÊNCIAS")