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

#let contador_topicos = counter("topico_obj")

#let topico(titulo, texto) = {
  contador_topicos.step()
  
  context contador_topicos.display("1.")
  [ *#titulo:* #texto]
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
  
  lista_ilustracoes: true,
  lista_tabelas: true,
)

/* Nada dissa vai para a versão final, é apenas um rascunho para organizar as ideias e estruturar o pré-projeto.
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
*/ 

= INTRODUÇÃO
/*
Introduza a evolução da inteligência artificial aplicada à busca de caminhos (pathfinding). Utilize Russell e Norvig (2013) para definir algoritmos de busca clássicos e emende com Pardede et al. (2022) para contextualizar o avanço e a aplicação crítica dessas técnicas no desenvolvimento de ambientes interativos e jogos.
*/
*1º Parágrafo (Contextualização e Fundamentação).*

/*
Disserte sobre o salto de complexidade ao migrar do 2D para o 3D. Apresente a "lacuna" onde algoritmos costumam ser testados em ambientes isolados. Apoie-se em Gurung (2019) para falar sobre malhas de navegação (NavMeshes) e em Smołka et al. (2019) para explicar as instabilidades e necessidades de adaptação (como as falhas matemáticas e funções de smoothing) em engines 3D reais.
*/
*2º Parágrafo (O Problema e a Complexidade).*

/*
Declare o objetivo central do estudo: uma análise estatística e comparativa focada em métricas quantitativas (como tempo de execução, uso de memória e overheads), desenvolvendo uma solução construída do zero.
*/
*3º Parágrafo (A Proposta).*

/*
Referencie trabalhos recentes para mostrar que seu estudo está atualizado. Cite Madushanka e Madushanka (2026) para introduzir a relevância do processamento multithread em ambientes dinâmicos, e Nobes et al. (2022) para demonstrar que a expansão do Jump Point Search (JPS) para três dimensões é um tópico de pesquisa ativo e de alto interesse.
*/
*4º Parágrafo (Estado da Arte e Fronteira).*

= JUSTIFICATIVA
Com este capítulo, pretende-se justificar a relevância e a necessidade do estudo proposto, destacando a importância de uma análise estatística detalhada dos algoritmos de pathfinding em malhas 3D, especialmente considerando as complexidades e desafios dos ambientes reais.

Na área de algoritmos de pathfinding, a maioria dos estudos se concentra em topologias 2D ou não geométricas e em cenários ideais, onde as condições são controladas e otimizadas para destacar as vantagens de cada algoritmo. No entanto, a transição para ambientes 3D introduz uma série de desafios adicionais, como a complexidade da geometria, a necessidade de lidar com obstáculos tridimensionais e a gestão de recursos computacionais. A falta de análises estatísticas detalhadas sob condições adversas limita a compreensão real do desempenho desses algoritmos em situações práticas, onde otimizações matemáticas e técnicas avançadas podem ter um impacto significativo.

Este estudo se diferencia por adotar uma abordagem aprofundada e detalhada, focando em métricas quantitativas e condições adversas que refletem os desafios do mundo real. Ao invés de uma visão superficial e generalizada, a pesquisa se propõe a investigar o comportamento de algoritmos de busca quando expostos a concorrência computacional e arquiteturas complexas.

Também, a construção de uma infraestrutura gráfica e de uma biblioteca de grafos do zero não apenas proporciona um ambiente de teste personalizado, mas também garante um controle total sobre as variáveis e anomalias de hardware que podem afetar os resultados. A correta aplicação teórica e estrutural da base de grafos é fundamental para garantir a validade dos testes empíricos, conforme destacado por #cite(<rodacki_grafos>, form: "prose") e #cite(<cormen_algoritmos>, form: "prose").

Com isso, viu-se a necessidade de um estudo que vá além dos testes em ambientes ideais, oferecendo uma análise estatística robusta e detalhada do desempenho dos algoritmos de pathfinding em malhas 3D, contribuindo para a escolha informada de técnicas de navegação em projetos futuros.

= OBJETIVOS
Neste capítulo serão apresentados os objetivos gerais e específicos do estudo, detalhando o que se pretende alcançar com a pesquisa. As metas girarão em torno da implementação de algoritmos de pathfinding, desenvolvimento de uma infraestrutura gráfica para testes, coleta e análise de dados, e apresentação dos resultados.

== Geral
Perante o cenário atual de desenvolvimento de jogos e ambientes interativos, onde a navegação eficiente é crucial, este estudo visa fornecer insights valiosos sobre o desempenho de algoritmos de pathfinding em malhas 3D. Através da implementação de uma infraestrutura gráfica e da coleta de dados detalhados, pretende-se comparar algoritmos como A\*, JPS e Theta\* sob condições adversas, incluindo concorrência e otimizações. O objetivo é não apenas medir o tempo de execução, mas também entender as nuances do comportamento desses algoritmos em ambientes complexos.

== Específicos
#topico("Implementar grafos", [
  Desenvolver uma estrutura de dados leve e eficiente para representar grafos, considerando as particularidades de grafos direcionados e não direcionados. A implementação deve ser baseada em teorias e práticas recomendadas, garantindo que a estrutura seja otimizada para uso em algoritmos de pathfinding.
])

#topico("Desenvolver a infraestrutura 3D", [
  Criar um ambiente para renderização de malhas 3D, com foco na separação de responsabilidades entre renderização gráfica e as demais aplicações. A infraestrutura deve ser capaz de gerenciar componentes, câmeras e buffers, garantindo que a renderização ocorra de forma fluida e sem travamentos, mesmo durante a execução dos algoritmos de pathfinding.
])

#topico("Implementar e adaptar os algoritmos heurísticos", [
  Implementar os algoritmos de pathfinding A\*, JPS e Theta\*, adaptando-os para ambientes 3D. Otimizando-os com técnicas de alto desempenho e multithreading.
])

#topico("Adaptar a arquitetura lógica para testes de estresse e multithreading", [
  Modificar a arquitetura do sistema para permitir a execução concorrente dos algoritmos de pathfinding, garantindo que os testes de estresse possam ser realizados sem interferências ou travamentos. A implementação deve ser baseada em práticas recomendadas para multithreading, garantindo a integridade dos dados e a eficiência do processamento.
])

#topico("Desenvolver geradores de malhas topológicas complexas", [
  Criar geradores de malhas que possam simular diferentes cenários de teste, incluindo labirintos e topologias densas. 
])

#topico("Coletar e tratar dados", [
  Coletar dados de desempenho dos algoritmos de pathfinding, incluindo tempo de execução, uso de memória e qualidade do caminho encontrado. O tratamento dos dados deve incluir a identificação e análise de outliers, garantindo que as conclusões sejam baseadas em dados confiáveis e representativos.
])

#topico("Apresentar análises visuais e estatísticas comparativas", [
  Desenvolver gráficos e tabelas para apresentar os resultados da análise estatística de forma clara e compreensível. As análises devem destacar as diferenças de desempenho entre os algoritmos de pathfinding, considerando as métricas coletadas e as condições dos testes.
])

= METODOLOGIA
Aqui, o foco é detalhar a metodologia de pesquisa, explicando como a infraestrutura gráfica e os algoritmos de pathfinding serão implementados e testados. Este projeto será conduzido como uma pesquisa experimental de caráter quantitativo, onde a implementação da infraestrutura gráfica e dos algoritmos de pathfinding ocorrerá em paralelo à coleta e análise de dados. A abordagem experimental permitirá a avaliação do desempenho dos algoritmos em condições controladas, enquanto a construção da engine do zero garantirá um ambiente de teste personalizado e otimizado para as necessidades específicas deste estudo.

/*
Detalhe o uso da IFCG. Discuta a arquitetura de loop lambda e a separação estrita entre a thread de renderização (OpenGL/Graphics) e a lógica de busca para evitar travamentos.
*/
== Infraestrutura Gráfica

/*
Descreva a arquitetura base. Mencione a distinção entre grafos comuns e direcionados, embasando a escolha das estruturas de dados e otimização de memória na literatura de Cormen et al. (2012) e Gomes (2022). Se aplicável, mencione como o trabalho de Duan et al. (2025) inspira o tratamento de filas de prioridade e ordenação nos grafos direcionados.
*/
== Estrutura de Grafos

/*
Explique como as malhas serão geradas para simular estresse. Disserte sobre o uso do Algoritmo de Kruskal, citando Buck (2011), para criar labirintos perfeitos e topologias densas que forcem o desvio de obstáculos e exijam cálculos exaustivos de caminho.
*/
== Geração de Cenários de Teste
Durante a fase de desenvolvimento, foram criados diversos cenários de teste para avaliar o desempenho dos algoritmos de pathfinding. É importante retificar como estes cenários foram gerados e o que eles representam em termos de desafios para os algoritmos. A seguir, serão detalhados os tipos de cenários utilizados:

=== Labirintos
Como testes iniciais, foram gerados labirintos utilizando o Algoritmo de Kruskal, que é um método eficiente para criar labirintos. Este tipo de teste é ótimo para avaliar a capacidade dos algoritmos de pathfinding em encontrar caminhos em ambientes complexos e com muitos obstáculos, forçando-os a realizar cálculos exaustivos para encontrar a rota mais eficiente.

Para criar um labirinto, segundo #cite(<buck2011kruskal>, form: "prose"), se cria um grafo em grid com valores de peso aleatórios entre os vértices e seus vizinhos (considerando os 8 vizinhos para permitir movimento diagonal). Em seguida, é aplicado o Algoritmo de Kruskal para gerar um labirinto perfeito, uma vez que ele gera uma Árvore Geradora Mínima (MST), e criar um novo grafo a partir dessa árvore. Isso garante que para qualquer par de vértices, existe exatamente um caminho entre eles, o que é ideal para testar a eficiência dos algoritmos de pathfinding.

Consequentemente, é possível retirar ou adicionar arestas para criar variações de labirintos, aumentando a complexidade e a densidade de obstáculos, o que permitirá uma análise mais robusta do desempenho dos algoritmos em diferentes cenários.

Embora os labirintos sejam um excelente teste para avaliar a capacidade de desvio de obstáculos, eles foram utilizados apenas como um ponto de partida para a geração de cenários de teste. Uma vez que a ideia desta pesquisa é comparar algoritmos de pathfindings em grafos criados a partir de malhas 3D. Gerar um grafo abstrato e independente seria redundante a esse estudo, o que levou ao descarte deste meio de geração de cenários.

=== Mapas de Altura
Um heightmap (ou mapa de altura) é uma imagem que utiliza apenas tons de cinza para representar a elevação de uma superfície. A intensidade de cada pixel indica a altura de um determinado ponto no terreno, onde tons mais claros representam áreas mais elevadas e tons mais escuros indicam áreas mais baixas. 

#figure(
  caption: [Exemplo de Heightmap],
  supplement: "Figura",
)[
  #image("/typ/images/heightmap.png", width: 50%)
  #v(0.5em)
  #text(size: 10pt)[Fonte: #cite(<imperial_library_solstheim>, form: "prose").]
] \

Determinando o valor mínimo e máximo de altura, é possível criar uma maha 3D a partir do heightmap, onde cada pixel é convertido em um vértice com coordenadas (x, y, z), sendo x e y as coordenadas do pixel e z o valor do pixel. Como trabalhamos com valores cinza, os valores RGB serão iguais, alternando apenas na intensidade entre 0 e 255. A partir disso, é possível criar uma malha 3D que representa o terreno que desejamos simular.

Com o uso dos heightmaps, é possível gerar tanto malhas 3D quanto grafos a partir de um mesmo cenário, simplificando o processo de geração de cenários. Esta versatilidade se provará útil futuramente quando falarmos de NavMeshes.

Agora, considerando que certas diferenças de altura podem ser intransponíveis para um agente navegando, foi separada a geração de malhas e grafos. Enquanto as malhas são geradas indiscriminadamente, os grafos verificam as diferenças de altura entre os vértices e, caso a diferença seja maior que um determinado limiar, a aresta entre esses vértices não é adicionada. Isso simula a realidade de que certos terrenos podem ser intransponíveis para um agente, forçando os algoritmos de pathfinding a encontrar rotas alternativas.

=== NavMeshes
NavMeshes ou malhas de navegação são uma representação eficiente do espaço navegável em um ambiente 3D. Elas consistem em polígonos que representam áreas onde um agente pode se mover.

/*
Disserte sobre a lógica dos três concorrentes. O A* com suas modificações e suavização (baseado em Smołka et al., 2019), a extensão complexa do Jump Point Search no eixo Z (apoiado em Nobes et al., 2022) e as particularidades do Theta*.
*/
== Implementação dos Algoritmos

/*
Detalhe a orquestração dos testes. Como os algoritmos rodarão concorrentemente. Aqui, ancore-se em Madushanka e Madushanka (2026) para justificar a necessidade de isolar e mensurar o impacto do paralelismo real no tempo de execução da navegação.
*/
== Multithread

/*
Defina as variáveis dependentes (tempo de processamento de CPU, picos de memória) e como você planeja projetar os caminhos resultantes visualmente (ex: plotar a visão de cima) para certificar a qualidade do trajeto além de apenas sua velocidade.
*/
== Processo de Coleta e Tratamento de Dados

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

// =======================================================
// ELEMENTOS PÓS-TEXTUAIS
// =======================================================

// 1. Referências
#bibliography("referencias.bib", style: "associacao-brasileira-de-normas-tecnicas.csl", title: "REFERÊNCIAS")