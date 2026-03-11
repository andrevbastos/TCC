// ==========================================
// CONFIGURAÇÃO DO TEMPLATE TCC ABNT
// ==========================================

#let tcc_abnt(
  titulo: "",
  subtitulo: "",
  autor: "",
  orientador: "",
  instituicao: "",
  curso: "",
  local: "",
  ano: "",
  natureza_trabalho: "",
  // Novos Elementos Pré-Textuais
  data_aprovacao: "",
  banca: (),
  dedicatoria: [],
  agradecimentos: [],
  epigrafe: [],
  lista_ilustracoes: false,
  lista_tabelas: false,
  // Resumo e Abstract
  resumo: [],
  abstract: [],
  palavras_chave: (),
  keywords: (),
  corpo
) = {
  // 1. Configuração Básica da Página (Sem numeração nos elementos pré-textuais)
  set page(
    paper: "a4",
    margin: (top: 3cm, left: 3cm, right: 2cm, bottom: 2cm),
    numbering: none // Numeração invisível (mas o Typst continua contando em background)
  )
  
  set text(font: ("Times New Roman"), size: 12pt, lang: "pt", region: "br")

  // ==========================================
  // ELEMENTOS PRÉ-TEXTUAIS
  // ==========================================

  // --- CAPA ---
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

  // --- FOLHA DE ROSTO ---
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
      ]
    ]
    
    #v(1fr)
    #local \
    #ano
  ]
  pagebreak()

  // --- FOLHA DE APROVAÇÃO (Comissão Examinadora) ---
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

  // --- DEDICATÓRIA ---
  if dedicatoria != [] [
    #align(right + bottom)[
      #pad(left: 50%)[
        #set text(style: "italic")
        #dedicatoria
      ]
    ]
    #pagebreak()
  ]

  // --- AGRADECIMENTOS ---
  if agradecimentos != [] [
    #align(center)[#text(weight: "bold")[AGRADECIMENTOS]]
    #v(1.5em)
    #set par(first-line-indent: 1.25cm, leading: 0.5em, justify: true)
    #agradecimentos
    #pagebreak()
  ]

  // --- EPÍGRAFE ---
  if epigrafe != [] [
    #align(right + bottom)[
      #pad(left: 50%)[
        #set text(style: "italic")
        #epigrafe
      ]
    ]
    #pagebreak()
  ]

  // --- RESUMO ---
  if resumo != [] [
    #align(center)[#text(weight: "bold")[RESUMO]]
    #v(1.5em)
    #set par(first-line-indent: 0pt, leading: 0.3em, justify: true)
    #resumo
    
    #v(2em)
    #text(weight: "bold")[Palavras-chave:] #palavras_chave.join(". ").
    #pagebreak()
  ]

  // --- ABSTRACT ---
  if abstract != [] [
    #align(center)[#text(weight: "bold")[ABSTRACT]]
    #v(1.5em)
    #set par(first-line-indent: 0pt, leading: 0.3em, justify: true)
    #abstract
    
    #v(2em)
    #text(weight: "bold")[Keywords:] #keywords.join(". ").
    #pagebreak()
  ]

  // --- SUMÁRIO ---
  align(center)[#text(weight: "bold")[SUMÁRIO]]
  v(1.5em)
  
  show outline.entry.where(level: 1): it => {
    v(1em, weak: true)
    strong(it)
  }
  
  outline(title: none, depth: 3, indent: 0.5em)
  pagebreak()

  // --- LISTA DE ILUSTRAÇÕES (FIGURAS) ---
  if lista_ilustracoes [
    #align(center)[#text(weight: "bold")[LISTA DE ILUSTRAÇÕES]]
    #v(1.5em)
    #outline(title: none, target: figure.where(kind: image))
    #pagebreak()
  ]

  // --- LISTA DE TABELAS ---
  if lista_tabelas [
    #align(center)[#text(weight: "bold")[LISTA DE TABELAS]]
    #v(1.5em)
    #outline(title: none, target: figure.where(kind: table))
    #pagebreak()
  ]

  // ==========================================
  // ELEMENTOS TEXTUAIS E FORMATAÇÃO DO CORPO
  // ==========================================

  // A partir daqui, a numeração de páginas fica visível (o Typst já contou as anteriores)
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
      pagebreak(weak: true)
      upper(it)
    } else if it.level == 2 {
      it
    } else {
      set text(weight: "regular")
      it
    }
    par(text(size: 0pt, ""))
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
// EXEMPLO DE USO DO TEMPLATE DE TCC
// ==========================================

#show: tcc_abnt.with(
  titulo: "Implementação de Templates Typst",
  subtitulo: "Uma abordagem baseada na ABNT",
  autor: "João da Silva",
  orientador: "Prof. Dr. Marcos António",
  instituicao: "Universidade Federal de Santa Catarina - UFSC",
  curso: "Curso de Ciência da Computação",
  local: "Florianópolis",
  ano: "2024",
  natureza_trabalho: "Trabalho de Conclusão de Curso apresentado ao Departamento de Computação como requisito parcial para obtenção do grau de Bacharel em Ciência da Computação.",
  
  // NOVOS ELEMENTOS PREENCHIDOS:
  data_aprovacao: "15 de Dezembro de 2024",
  banca: (
    (nome: "Prof. Dr. Marcos António", filiacao: "Orientador - Universidade Federal de Santa Catarina"),
    (nome: "Profa. Dra. Ana Carolina", filiacao: "Avaliadora - Universidade de São Paulo"),
    (nome: "Prof. Me. Carlos Eduardo", filiacao: "Avaliador - Universidade Federal do Paraná")
  ),
  dedicatoria: [
    Dedico este trabalho aos meus pais, que sempre me apoiaram e incentivaram durante toda a minha jornada acadêmica.
  ],
  agradecimentos: [
    Agradeço primeiramente ao meu orientador pela paciência e pelas valiosas correções.
    
    Aos meus colegas de turma pelas noites em claro estudando e desenvolvendo projetos.
    
    À universidade por fornecer a infraestrutura necessária para a realização desta pesquisa.
  ],
  epigrafe: [
    "A simplicidade é o último grau de sofisticação." \
    — Leonardo da Vinci
  ],
  lista_ilustracoes: true,
  lista_tabelas: true,
  
  resumo: [
    Este trabalho descreve o processo de criação de um modelo de documento em Typst para a escrita de Trabalhos de Conclusão de Curso. As normas da ABNT ditam regras estritas sobre a formatação dos elementos pré-textuais, textuais e pós-textuais. O template automatiza a criação da Capa, Folha de Rosto e o controle da numeração de páginas, além das regras tipográficas do corpo do texto.
  ],
  palavras_chave: ("Typst", "ABNT", "Monografia", "TCC"),
  abstract: [
    This work describes the process of creating a Typst document template for writing undergraduate thesis. ABNT standards dictate strict rules regarding the formatting of pre-textual, textual, and post-textual elements. The template automates the creation of the Cover, Title Page, and page numbering control, as well as the typographic rules of the text body.
  ],
  keywords: ("Typst", "ABNT", "Thesis", "TCC")
)


= INTRODUÇÃO

Este é o primeiro capítulo do trabalho. Se olhar para o canto superior direito, verá que a numeração da página está correta (ex: página 12), levando em conta as 11 páginas de capa, listas e sumário que ficaram para trás ocultas!

= ANTECEDENTES

Respondendo à sua dúvida: os "Antecedentes" nada mais são do que uma seção normal do seu texto. Basta você criar o capítulo e escrever. 

A ABNT não exige formatações diferentes para capítulos de referencial teórico, história ou antecedentes.

= METODOLOGIA

Neste capítulo metodológico, detalhamos como a formatação foi implementada.

#figure(
  caption: [Diagrama do fluxo de compilação],
  supplement: "Figura",
)[
  #rect(width: 80%, height: 4cm, fill: luma(230), stroke: 1pt)[
    #align(center + horizon)[*IMAGEM DA METODOLOGIA*]
  ]
  #v(0.5em)
  #text(size: 10pt)[Fonte: Elaborado pelo autor (2024).]
]

= RESULTADOS E DISCUSSÃO

Assim como os antecedentes, os resultados são apenas mais um capítulo no fluxo normal do documento. Aqui você pode inserir tabelas que irão automaticamente para a Lista de Tabelas que ativamos lá em cima.

#figure(
  caption: [Comparativo de tempos de compilação],
  supplement: "Tabela",
)[
  #table(
    columns: (auto, auto, auto),
    stroke: none,
    table.hline(y: 0, stroke: 1pt),
    table.hline(y: 1, stroke: 0.5pt),
    [*Ferramenta*], [*Complexidade*], [*Tempo Médio*],
    [LaTeX], [Alta], [3.2 s],
    [Typst], [Baixa], [0.1 s],
    table.hline(y: 3, stroke: 1pt)
  )
  #v(0.5em)
  #text(size: 10pt)[Fonte: Dados da pesquisa (2024).]
]

= CONCLUSÃO

A conclusão finaliza os elementos textuais.

// =======================================================
// ELEMENTOS PÓS-TEXTUAIS (REFERÊNCIAS, APÊNDICES E ANEXOS)
// =======================================================

// 1. Referências (Obrigatório)
// #pagebreak()
#bibliography("referencias.bib", style: "associacao-brasileira-de-normas-tecnicas.csl", title: "REFERÊNCIAS")

// 2. Apêndices (Opcional - Documentos gerados por você)
// Como a ABNT pede que Apêndices e Anexos sejam numerados por letras (A, B, C...) e não números (1, 2, 3), 
// nós removemos a numeração automática padrão dos títulos a partir daqui:

#set heading(numbering: none)
#pagebreak()

= APÊNDICE A -- QUESTIONÁRIO APLICADO

Aqui você coloca o conteúdo do seu apêndice. Lembre-se que o Apêndice é um documento ou texto elaborado pelo *próprio autor* do TCC para complementar a argumentação.

#pagebreak()

= ANEXO A -- MANUAL DO USUÁRIO DO SISTEMA X

Aqui entra o conteúdo do anexo. Diferente do Apêndice, o Anexo é um documento ou texto elaborado por *outra pessoa/instituição* que serve de fundamentação, comprovação ou ilustração.