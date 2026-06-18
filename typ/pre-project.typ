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
  lista_siglas: (:),
  corpo
) = {
  // 1. Configuração Básica da Página
  set page(
    paper: "a4",
    margin: (top: 3cm, left: 3cm, right: 2cm, bottom: 2cm),
    numbering: none // Numeração invisível nos pré-textuais
  )
  
  set text(font: ("Arial"), size: 12pt, lang: "pt", region: "br")

  // ==========================================
  // ELEMENTOS PRÉ-TEXTUAIS
  // ==========================================

  // --- CAPA (Obrigatório) ---
  align(center)[
    #text(weight: "bold", upper(instituicao)) \
    #text(weight: "bold", upper(curso))

    #v(2fr)
    // ABNT: O Autor deve preceder o Título
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

  // --- FOLHA DE ROSTO (Obrigatório) ---
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

  // --- LISTA DE ABREVIATURAS E SIGLAS (Opcional) ---
  if type(lista_siglas) == dictionary and lista_siglas.len() > 0 [
    #align(center)[#text(weight: "bold")[LISTA DE ABREVIATURAS E SIGLAS]]
    #v(1.5em)
    
    // Grid para manter as siglas e os significados perfeitamente alinhados
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

  // --- SUMÁRIO (Obrigatório) ---
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

  // ==========================================
  // ELEMENTOS TEXTUAIS E FORMATAÇÃO DO CORPO
  // ==========================================

  // A partir daqui, a numeração de páginas fica visível
  set page(numbering: "1", number-align: top + right)

  set par(
    justify: true, 
    first-line-indent: 1.25cm, 
    leading: 0.65em, 
    spacing: 0.8em
  )

  set heading(numbering: "1.1")
  show heading: it => {
    set text(size: 12pt, weight: "bold")
    set block(above: 1.5em, below: 1.5em) 
    
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
    context v(-par.spacing)
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
  v(1.5em)
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
  titulo: "Pathfinding em Malhas 3D",
  subtitulo: "Análise estatística e comparativa",
  autor: "André Vitor Bastos de Macêdo",
  orientador: "Prof. Paulo César Rodacki Gomes",
  instituicao: "Instituto Federal Catarinense - IFC",
  curso: "Bacharelado de Ciência da Computação",
  local: "Blumenau",
  ano: "2026",
  natureza_trabalho: "Pré-projeto de Trabalho de Conclusão de Curso apresentado ao curso de Bacharelado em Ciência da Computação do Instituto Federal Catarinense, como requisito parcial para a obtenção do grau de Bacharel.",
  
  lista_ilustracoes: true,
  lista_tabelas: true,
  lista_siglas: (
    "A*": [_A-Star_],
    "API": [_Application Programming Interface_ \ (Interface de Programação de Aplicações)],
    "CPU": [_Central Processing Unit_ (Unidade Central de Processamento)],
    "EBO": [_Element Buffer Object_],
    "GLFW": [_Graphics Library Framework_],
    "GPU": [_Graphics Processing Unit_ (Unidade de Processamento Gráfico)],
    "IFCG": "Instituto Federal Catarinense/Computação Gráfica",
    "JPS": [_Jump Point Search_],
    "MST": [_Minimum Spanning Tree_ (Árvore Geradora Mínima)],
    "OpenGL": [_Open Graphics Library_],
    "RAII": [_Resource Acquisition Is Initialization_],
    "RGB": [_Red, Green, Blue_],
    "SIGSEGV": [_Segmentation Violation_ (Violação de Segmentação)],
    "STL": [_Standard Template Library_],
    "VAO": [_Vertex Array Object_],
    "VBO": [_Vertex Buffer Object_]
  )
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
A busca de caminhos (ou _pathfinding_) é um dos campos mais tradicionais da Inteligência Artificial aplicada, evoluindo a partir dos algoritmos de busca clássicos em grafos. Como definem #cite(<russell_norvig>, form: "prose"), os métodos clássicos de busca estruturam problemas em termos de estados, ações e custos, visando encontrar caminhos entre um ponto de partida e um objetivo por meio da exploração sistemática do espaço de busca. Ao longo das últimas décadas, essa fundamentação teórica deixou de ser puramente abstrata e passou a ser aplicada diretamente na computação interativa. Conforme apontam #cite(<pathfinding_game_dev>, form: "prose"), os algoritmos de busca tornaram-se componentes cruciais para o desenvolvimento de jogos modernos e simulações em tempo real, nos quais personagens controlados por computador precisam navegar por cenários dinâmicos de forma autônoma e inteligente.

No entanto, a transição das simulações bidimensionais (2D) para os ambientes tridimensionais (3D) gerou um grande salto na complexidade computacional dos algoritmos. Há na literatura científica uma lacuna metodológica significativa, na qual a maioria dos algoritmos de busca é testada e avaliada isoladamente em cenários planos ou ideais, ignorando as restrições físicas de um ambiente real. No espaço 3D real, é preciso considerar a variação de altura, inclinação do relevo e obstáculos tridimensionais complexos. Conforme discutido por #cite(<a_star_modification>, form: "prose"), a navegação em engines 3D reais traz problemas práticos de instabilidade e inconsistências matemáticas nos cálculos de distância. Isso exige o desenvolvimento de funções de suavização (_smoothing_) e modificações nos algoritmos heurísticos tradicionais para garantir que os caminhos gerados sejam tanto realistas quanto viáveis fisicamente.

Este estudo propõe uma análise estatística e comparativa com foco no desempenho de diferentes algoritmos de busca heurística em malhas 3D acidentadas. O objetivo principal é medir métricas de eficiência computacional, como tempo de execução em microssegundos, consumo absoluto de memória RAM e overhead de processamento sob concorrência. Para garantir controle total sobre as variáveis de teste e isolar o impacto do hardware e das chamadas ao sistema operacional, o experimento adota uma infraestrutura de desenvolvimento própria. Tanto o motor de renderização (denominado IFCG) quanto as estruturas de dados de grafos e algoritmos foram implementados do zero em linguagem C++, permitindo extrair métricas de desempenho livres das interferências comuns de engines comerciais.

A otimização de algoritmos de busca em ambientes tridimensionais dinâmicos permanece na fronteira da pesquisa científica na área de computação. Trabalhos recentes, como o de #cite(<a_star_multithreaded>, form: "prose"), destacam a importância e a necessidade do processamento concorrente (_multithreading_) para calcular caminhos em tempo real sem prejudicar a responsividade visual do motor gráfico. Além disso, a adaptação de técnicas eficientes baseadas em grades uniformes para o espaço volumétrico, como a expansão tridimensional do algoritmo _Jump Point Search_ (JPS) estudada por #cite(<jps_3d>, form: "prose"), demonstra que o desenvolvimento de heurísticas espaciais avançadas é um tema ativo e de grande interesse para aplicações de grande escala.

= JUSTIFICATIVA
Com este capítulo, pretende-se justificar a relevância e a necessidade do estudo proposto, destacando a importância de uma análise estatística detalhada dos algoritmos de pathfinding em malhas 3D, especialmente considerando as complexidades e desafios dos ambientes reais.

Na área de algoritmos de _pathfinding_, busca de caminhos, a maioria dos estudos se concentra em topologias 2D ou não geométricas e em cenários ideais, onde as condições são controladas e otimizadas para destacar as vantagens de cada algoritmo. No entanto, a transição para ambientes 3D introduz uma série de desafios adicionais, como a complexidade da geometria, a necessidade de lidar com obstáculos tridimensionais e a gestão de recursos computacionais. A falta de análises estatísticas detalhadas sob condições adversas limita a compreensão real do desempenho desses algoritmos em situações práticas, onde otimizações matemáticas e técnicas avançadas podem ter um impacto significativo.

Este estudo se diferencia por adotar uma abordagem aprofundada e detalhada, focando em métricas quantitativas e condições adversas que refletem os desafios do mundo real. Ao invés de uma visão superficial e generalizada, a pesquisa se propõe a investigar o comportamento de algoritmos de busca quando expostos a concorrência computacional e arquiteturas complexas.

Além disso, a construção de uma infraestrutura gráfica e de uma biblioteca de grafos do zero não apenas proporciona um ambiente de teste personalizado, mas também garante um controle total sobre as variáveis e anomalias de hardware que podem afetar os resultados. A correta aplicação teórica e estrutural da base de grafos é fundamental para garantir a validade dos testes empíricos, conforme destacado por #cite(<rodacki_grafos>, form: "prose").

Com isso, viu-se a necessidade de um estudo que vá além dos testes em ambientes ideais, oferecendo uma análise estatística detalhada do desempenho dos algoritmos de pathfinding em malhas 3D, contribuindo para a escolha informada de técnicas de navegação em projetos futuros.

= OBJETIVOS
Neste capítulo serão apresentados os objetivos gerais e específicos do estudo, detalhando o que se pretende alcançar com a pesquisa. As metas girarão em torno da implementação de algoritmos de pathfinding, desenvolvimento de uma infraestrutura gráfica para testes, coleta e análise de dados, e apresentação dos resultados.

== Objetivos Gerais
Analisar comparativamente o desempenho dos algoritmos de pathfinding como A\*, JPS e Theta\* em ambientes tridimensionais, considerando métricas de execução, concorrência e técnicas de otimização.

== Objetivos Específicos
1. Implementar uma estrutura de dados eficiente para representação de grafos direcionados e não direcionados voltada à execução de algoritmos de pathfinding.
2. Desenvolver uma infraestrutura de renderização para visualização de malhas tridimensionais e execução integrada dos algoritmos de pathfinding.
3. Implementar e adaptar algoritmos heurísticos (A\*, JPS, Theta\* e outros) para ambientes tridimensionais.
4. Adaptar a arquitetura do sistema para execução concorrente e realização de testes de estresse utilizando multithreading.
5. Desenvolver geradores de malhas topológicas complexas para simulação de diferentes cenários de teste.
6. Coletar e analisar métricas de desempenho dos algoritmos de pathfinding, incluindo tempo de execução, uso de memória e qualidade dos caminhos gerados.
7. Elaborar análises estatísticas e visuais comparativas dos resultados obtidos nos testes realizados.

= FUNDAMENTAÇÃO TEÓRICA
Para a realização deste estudo, foi necessário adquirir conhecimentos em diversas áreas, incluindo algoritmos de busca, estruturas de dados, computação gráfica e concorrência. A seguir, são detalhados os principais tópicos que compõem a base teórica deste trabalho.

== Pilha Tecnológica
=== Linguagem de Programação
Todas as implementações e experimentos deste estudo foram realizados utilizando a linguagem de programação C++20. Escolhida por sua eficiência, controle de baixo nível e ampla adoção na indústria de jogos e simulações, a linguagem C++ oferece recursos avançados para manipulação de memória, concorrência e otimização de desempenho, essenciais para o desenvolvimento de algoritmos de pathfinding em ambientes tridimensionais.

A escolha do C++20 também se justifica pela disponibilidade de bibliotecas e _frameworks_ que facilitam a implementação de estruturas de dados complexas, renderização gráfica e multithreading, além de permitir uma integração eficiente com APIs gráficas como OpenGL.

Enquanto a implementação da infraestrutura gráfica e dos algoritmos de pathfinding foi realizada do zero, a escolha do C++20 garantiu um ambiente de desenvolvimento robusto e flexível, permitindo a aplicação de técnicas avançadas de otimização e controle total sobre os recursos computacionais utilizados durante os testes.

==== Estruturas de Dados
A implementação de algoritmos de pathfinding em malhas 3D requer o uso de estruturas de dados eficientes para representar grafos, filas de prioridade e outras estruturas auxiliares. Para isso, foi utilizada a biblioteca padrão do C++20, a STL (Standard Template Library), que oferece uma variedade de contêineres e algoritmos otimizados para manipulação de dados. 

A escolha de estruturas de dados adequadas é crucial para garantir o desempenho dos algoritmos, especialmente em ambientes tridimensionais onde a complexidade pode aumentar significativamente. Por isso foram utilizadas estruturas como vetores, mapas de _hash_ e filas de prioridade para representar os grafos e gerenciar os nós durante a execução dos algoritmos de busca.

==== Funções _Lambda_
A introdução de funções _lambda_ em C++11 e suas melhorias contínuas nas versões subsequentes, incluindo C++20, proporcionaram uma maneira mais concisa de definir funções anônimas. No contexto deste estudo, as funções _lambda_ foram amplamente utilizadas. 

Por definição, uma função anônima é uma função "sem nome", que pode ser definida e utilizada diretamente no local onde é necessária. Essas funções são particularmente úteis para operações que exigem uma função de curto prazo, como a definição de heurísticas em algoritmos de busca ou a implementação de _callbacks_ para eventos específicos durante a renderização ou execução dos algoritmos.

==== Biblioteca _jthread_
Um dos principais motivadores para o uso da versão C++20 é a introdução da biblioteca _jthread_, que simplifica significativamente a implementação de multithreading e concorrência. A _jthread_ oferece uma interface mais segura e fácil de usar para gerenciamento de _threads_, incluindo a capacidade de interromper _threads_ de forma cooperativa, o que é crucial para a realização de testes de estresse e simulações em ambientes dinâmicos.

Esta biblioteca utiliza dos principios de RAII (Resource Acquisition Is Initialization) para garantir que os recursos sejam gerenciados de forma eficiente e segura, evitando problemas comuns em multithreading, como o encerramento abrupto do programa devido a _threads_ não finalizadas ao saírem de escopo. A classe de _thread_ é gereciada de uma forma que, perante sua destruição, a _thread_ faz um _join_ automaticamente, garantindo que os recursos sejam liberados corretamente. Isso não só facilita a implementação de concorrência, mas também melhora a segurança do código.

Um _join_ é uma operação que bloqueia a execução da _thread_ chamadora até que a _thread_ alvo termine sua execução. No caso da _jthread_, o _join_ é automático, o que significa que quando um objeto de _jthread_ é destruído, ele automaticamente chama o método _join()_, garantindo que a _thread_ associada seja finalizada corretamente antes de liberar os recursos. 

Também, a introdução dos _stop tokens_ na biblioteca permite que as _threads_ sejam interrompidas de maneira cooperativa, o que é especialmente útil para simulações e testes de estresse, onde é necessário controlar o tempo de execução das _threads_ e garantir que elas possam ser finalizadas de forma segura.

=== Arquitetura de Programas
A arquitetura das bibliotecas e programas desenvolvido para este estudo foi projetada para ser modular e escalável, permitindo a fácil integração de novos algoritmos de pathfinding e a adaptação a diferentes cenários de teste. Por isso foi escolhida uma arquitetura orientada a objetos, que facilita a organização do código e a reutilização de componentes.

Essa escolha se dá pela necessidade de criar uma infraestrutura gráfica personalizada e uma estrutura de dados eficiente para representar grafos, além de implementar algoritmos de pathfinding que possam ser facilmente adaptados e otimizados para ambientes tridimensionais. A arquitetura orientada a objetos permite encapsular a complexidade dos diferentes componentes do sistema, como a renderização gráfica, a representação de grafos e a execução dos algoritmos, facilitando a manutenção e evolução do código ao longo do desenvolvimento do estudo.

Em adição, o uso de uma arquitetura orientada a objetos permite abstrações de hierarquia e polimorfismo, que serão amplamente utilizadas no implementação de ambas as principais bibliotecas, tanto a de grafos quanto a de renderização gráfica.

==== Padrões de Projeto
Padrões de projeto são soluções reutilizáveis para problemas comuns de design de _software_  @gamma1994design. No desenvolvimento deste estudo, foram aplicados diversos padrões de projeto para garantir a modularidade, flexibilidade e manutenibilidade do código.

O padrão _Composite_ @gamma1994design foi utilizado para representar a hierarquia de objetos na infraestrutura gráfica, permitindo que objetos complexos sejam tratados de forma uniforme, e na representação de grafos, onde grafos direcionados e não direcionados podem ser manipulados de maneira consistente. Neste padrão, objetos compostos (_Composite_) e objetos individuais (_Leaves_ ou folhas) são tratados de forma uniforme, com a introdução de um parente comum (_Component_) que define a interface para ambos. Com isso, é possível que _Composite_ delegue a execução de uma função comum entre eles para todos os seus filhos, sejam eles _Composite_ ou _Leaves_.

\
#figure(
  caption: [Diagrama de classes do padrão _Composite_],
  supplement: "Figura",
)[
  #image("./images/composite.png", width: 75%)
  #v(0.5em)
  Fonte: #cite(<gamma1994design>, form: "prose")
]\

Em adição, foi utilizado o padrão _Singleton_ @gamma1994design. Este padrão dita que uma classe deve ter apenas uma instância e fornecer um ponto global de acesso a essa instância. Para isso, o construtor da classe é privado e ela contém uma variável estática que armazena a única instância da classe (inicializada como nula). A classe também tem um método público estático que retorna a instância, criando-a se ainda não existir. Este padrão é útil para gerenciar recursos compartilhados, como o contexto gráfico do OpenGL, garantindo que haja um controle centralizado sobre a renderização e os recursos gráficos utilizados durante os testes.

\
#figure(
  caption: [Diagrama de classes do padrão _Singleton_],
  supplement: "Figura",
)[
  #image("./images/singleton.png", width: 75%)
  #v(0.5em)
  Fonte: #cite(<gamma1994design>, form: "prose")
]\

== Teoria dos Grafos
Uma vez que os algoritmos de pathfinding operam sobre estruturas de grafos para encontrar caminhos entre nós, o estudo da teoria dos grafos é a base fundamental deste experimento. A teoria dos grafos fornece as ferramentas e conceitos necessários para representar e manipular essas estruturas, permitindo a implementação eficiente dos algoritmos de busca.

Segundo #cite(<rodacki_grafos>, form: "prose"), um grafo é uma estrutura de dados composta por um conjunto de vértices (ou nós) e um conjunto de arestas (ou ligações) que conectam esses vértices. Os grafos podem ser direcionados, onde as arestas têm uma direção específica, ou não direcionados, onde as arestas não possuem direção. A representação de grafos pode ser feita de diversas formas, como listas de adjacência, matrizes de adjacência ou listas de arestas, cada uma com suas vantagens e desvantagens em termos de eficiência e uso de memória.

=== Definição e Propriedades dos Grafos
Um grafo é uma forma de representar conexões entre diferentes pontos. Basicamente, ele é composto por dois elementos principais: um conjunto de *vértices* (também chamados de nós), que são os pontos em si, e um conjunto de *arestas* (ou ligações), que são as linhas que conectam esses vértices. No contexto deste estudo, cada vértice pode representar uma posição ou uma célula em uma malha 3D, enquanto as arestas indicam os caminhos possíveis entre essas posições.

As arestas podem ter *pesos*, que são valores numéricos associados a elas. Esse peso pode indicar o "custo" de percorrer aquela ligação, como a distância física, o tempo gasto, ou a dificuldade de travessia (por exemplo, subir uma colina íngreme). O conceito de *adjacência* se refere a vértices que estão diretamente conectados por uma aresta, e um *caminho* é uma sequência de vértices adjacentes que leva de um ponto inicial a um destino @rodacki_grafos. Essas propriedades são fundamentais para os algoritmos de busca que visam encontrar as melhores rotas.

=== Grafos Direcionados e Não Direcionados
A natureza das arestas em um grafo define se ele é *direcionado* ou *não direcionado*. Em um grafo *não direcionado*, se existe uma aresta entre dois vértices A e B, significa que o caminho pode ser percorrido tanto de A para B quanto de B para A, com o mesmo custo (ou seja, a aresta (A, B) é idêntica à aresta (B, A)). Pense em uma estrada de mão dupla em um terreno plano.

Já em um grafo *direcionado*, a aresta tem um sentido específico. Uma aresta de A para B não implica necessariamente que existe uma aresta de B para A, ou que o custo de retorno seja o mesmo. Isso é particularmente relevante em ambientes 3D, onde o custo de subir uma rampa íngreme pode ser muito diferente (e maior) do que descer a mesma rampa, ou até mesmo haver obstáculos que permitem passagem em apenas um sentido.

=== MST (_Minimum Spanning Tree_)
Uma _Minimum Spanning Tree_ (MST), ou Árvore Geradora Mínima, é um subgrafo de um grafo original que conecta todos os vértices do grafo sem formar nenhum ciclo, e cuja soma dos pesos de todas as suas arestas é a menor possível @rodacki_grafos. Em outras palavras, é a forma mais "econômica" de conectar todos os pontos.

Para o propósito deste trabalho, algoritmos de construção de MST, como o algoritmo de Kruskal, são de grande utilidade para a *geração procedural de labirintos*. Ao aplicar esses algoritmos sobre uma grade de possíveis conexões (representando as células do labirinto como vértices e as paredes como arestas com pesos aleatórios), é possível criar labirintos "perfeitos", onde existe um único caminho entre quaisquer dois pontos. Esses labirintos servem como cenários de teste complexos e controláveis para avaliar o desempenho dos diferentes algoritmos de pathfinding em ambientes 3D.

== Algoritmos de Busca Heurística

Na área de estudo de grafos, existe uma grande concentração de pesquisas em algoritmos de busca heurística, que são técnicas que utilizam informações adicionais (heurísticas) para guiar a busca por um caminho mais eficiente no grafo. Esses algoritmos são amplamente utilizados em jogos e simulações para encontrar rotas entre pontos em um ambiente tridimensional.

=== Dijkstra
O algoritmo de Dijkstra é um dos métodos mais fundamentais para encontrar o caminho mais curto entre dois vértices em um grafo com arestas de pesos não negativos. Segundo #cite(<rodacki_grafos>, form: "prose"), o algoritmo funciona explorando sistematicamente todos os caminhos possíveis a partir de um vértice inicial, mantendo uma lista de distâncias mínimas conhecidas para cada nó. Ele utiliza uma fila de prioridade para sempre expandir o nó com a menor distância acumulada, garantindo que, ao chegar no destino, o caminho encontrado seja de fato o mais curto. Por sua natureza exaustiva, o Dijkstra é garantidamente ótimo, mas pode ser computacionalmente custoso em grafos muito grandes, pois "olha para todos os lados" antes de decidir a direção final.

=== Heurísticas
Diferente do Dijkstra, que explora o grafo de forma cega, a busca heurística utiliza informações extras para tentar "adivinhar" qual direção é mais promissora. Uma heurística é, essencialmente, uma estimativa do custo restante para chegar ao destino #cite(<astar>). 

Um exemplo clássico é a *Distância Euclidiana* (a linha reta entre dois pontos). Em um mapa 3D, se soubermos as coordenadas do ponto atual $(x_1, y_1, z_1)$ e do destino $(x_2, y_2, z_2)$, podemos calcular a distância direta entre eles. Embora essa distância ignore obstáculos como paredes ou montanhas, ela serve como um guia excelente para o algoritmo priorizar nós que estão fisicamente mais próximos do objetivo, reduzindo drasticamente o número de vértices que precisam ser analisados.

=== A\*
O algoritmo A\* (A-Star) é uma evolução do Dijkstra que incorpora o uso de heurísticas para aumentar a eficiência da busca. Ele avalia cada nó utilizando uma função de custo $f(n) = g(n) + h(n)$, onde:

- $g(n)$ é o custo real acumulado do ponto de partida até o nó atual $n$.
- $h(n)$ é o valor da heurística (a estimativa do custo de $n$ até o destino).
\
#v(-1.5em)
Ao combinar o progresso real com a estimativa futura, o A\* consegue focar a busca na direção do objetivo, evitando explorar áreas do grafo que claramente não levam ao caminho mais curto #cite(<astar>). Se a heurística utilizada for "admissível" (ou seja, nunca superestimar o custo real), o A\* garante encontrar o caminho ótimo, unindo a precisão do Dijkstra com a velocidade de uma busca direcionada.

=== Jump Point Search (JPS)
O _Jump Point Search_ (JPS) é uma otimização do algoritmo A\* específica para grades uniformes (como as malhas de navegação). Em vez de analisar cada vizinho imediato de um nó (passo a passo), o JPS "pula" grandes áreas vazias do grafo que não oferecem mudanças de direção interessantes #cite(<jps_3d>). 

Ele identifica pontos críticos chamados _Jump Points_ — locais onde a presença de um obstáculo força o algoritmo a considerar uma nova direção. Ao saltar diretamente entre esses pontos, o JPS reduz significativamente o número de operações na fila de prioridade e o uso de memória, sendo frequentemente ordens de grandeza mais rápido que o A\* tradicional em ambientes com grandes espaços abertos, mantendo a mesma garantia de encontrar o caminho mais curto.

== Computação Gráfica
Por causa da necessidade de controle total sobre a infraestrutura gráfica e a implementação dos algoritmos, optou-se por desenvolver um montor gráfica do zero, denominada IFCG#footnote[Disponível em: #link("https://github.com/andrevbastos/IFCG"). Acesso em: 22 mai. 2026.] (Instituto Federal Catarinense/Computação Gráfica). Esta decisão foi motivada pela necessidade de um ambiente de teste personalizado, que permita a coleta de dados em condições controladas e a aplicação de otimizações específicas para os algoritmos de pathfinding.

=== OpenGL API
O OpenGL é uma API de gráficos 3D amplamente utilizada para renderização de gráficos em tempo real @learnopengl. No desenvolvimento da infraestrutura gráfica para este estudo, o OpenGL foi escolhido por sua flexibilidade, desempenho e ampla adoção na indústria de jogos e simulações.  A utilização do OpenGL também facilita a implementação de técnicas avançadas de renderização e otimização, garantindo que os testes sejam realizados em um ambiente gráfico realista.

==== Malhas 
As malhas são uma representação comum de superfícies em computação gráfica, onde uma superfície é representada por um conjunto de vértices conectados por arestas e faces. No contexto deste estudo, as malhas serão utilizadas para representar os cenários de teste em que os algoritmos de pathfinding serão executados. 

Cada conjunto de vértices e arestas diferentes são armazenados em _buffers_ denominados VBO (Vertex Buffer Object) e EBO (Element Buffer Object), respectivamente, que são gerenciados pela GPU para renderização eficiente. Cada um desses _buffers_ é associado a um VAO (Vertex Array Object), que encapsula o estado necessário para renderizar a malha, incluindo as ligações dos _buffers_ e as configurações de atributos de vértice.

O conhecimento detalhado do funcionamento de cada buffer se prova essencial, quando consideramos a forma que o OpenGL lida com a renderização de malhas e troca de dados entre CPU e GPU. Uma vez que o OpenGL tem grandes problemas para lidar com múltiplas _threads_, o gerenciamento eficiente dos _buffers_ e a minimização de operações de troca de dados entre CPU e GPU são cruciais para garantir o desempenho dos algoritmos de pathfinding em ambientes tridimensionais.

==== Programação Orientada a Eventos e Funções de _Callback_
Embora o OpenGL seja estritamente uma API de renderização, sem conhecimento nativo sobre o sistema operacional, janelas ou periféricos de entrada, a infraestrutura gráfica desenvolvida (IFCG) utiliza a biblioteca GLFW para o gerenciamento da janela e a criação do contexto gráfico. Essa integração permite implementar um modelo de programação orientada a eventos, onde o fluxo de execução é guiado por interações externas, como atualizações do sistema e entradas do usuário. As funções de _callback_ fornecidas pela API do GLFW foram implementadas na camada de gerenciamento do motor para interceptar eventos de teclado e mouse, servindo como uma ponte de comunicação interativa com o sistema de renderização.

==== A Máquina de Estados e o Contexto OpenGL
Para lidar com a renderização em si, o OpenGL opera como uma vasta máquina de estados. Todas as configurações e referências de dados ficam armazenadas no que é chamado de Contexto OpenGL. Dessa forma, para renderizar uma malha, é necessário configurar o estado da máquina de acordo com as características do objeto — como a vinculação dos _buffers_ VBO e EBO — antes de emitir os comandos de desenho para a GPU. Como mudanças excessivas de estado geram alto custo de processamento (_overhead_), o gerenciamento eficiente dos _buffers_ procura minimizar as trocas de estado e agrupar comandos sempre que possível, otimizando o tráfego de dados entre a CPU e a GPU.

==== Concorrência e Isolamento de _Threads_
Essa arquitetura baseada em contexto de estado impõe restrições rígidas à implementação de concorrência. O contexto do OpenGL é estritamente atrelado à _thread_ em que foi ativado, tipicamente a _thread_ principal. Tentativas de acessar ou modificar o estado da API gráfica a partir de múltiplas _threads_ simultaneamente causam violações de acesso à memória, resultando em falhas críticas de limite de endereço, como erros SIGSEGV. Por isso, a arquitetura deste trabalho isola a renderização na _main thread_ e delega o processamento pesado de dados para as _worker threads_ do `TaskMaster`.

== Geração de Cenários de Teste
Para garantir a diversidade e complexidade dos cenários de teste, é necessário implementar algoritmos de geração procedural de terrenos. Esses algoritmos permitem criar malhas 3D complexas e variadas, simulando diferentes tipos de ambientes que os algoritmos de pathfinding podem encontrar em situações reais.

A geração procedural é uma técnica utilizada para criar conteúdo de forma automática, utilizando algoritmos que produzem resultados variados e complexos a partir de um conjunto de regras ou parâmetros. No contexto deste estudo, a geração procedural será aplicada para criar terrenos que servirão como cenários de teste para os algoritmos de pathfinding.

=== Labirintos
Temos como difinição que labirintos são estruturas complexas compostas por caminhos interconectados, onde o objetivo é encontrar uma rota do ponto de partida até um destino específico. A geração de labirintos pode ser realizada utilizando diversos algoritmos. Para este estudo, foi utilizado o algoritmo de Kruskal @rodacki_grafos, que é um método eficiente para gerar labirintos perfeitos, ou seja, labirintos sem ciclos, onde existe apenas um caminho entre quaisquer dois pontos. 

Inicialmente, para gerar labirintos com o algoritmo de Kruskal, é construído um grafo em formato de grade (Figura /*Definir depois*/Xa). Neste grafo, cada célula do labirinto é representada por um vértice, e as possíveis conexões entre as células são representadas por arestas de pesos aleatórios. 

O algoritmo de Kruskal é então aplicado para construir uma _Minimum Spanning Tree_ (MST), ou árvore geradora mínima, a partir desse grafo, selecionando as arestas de menor peso e garantindo que não sejam formados ciclos (Figura /*Definir depois*/Xb). O resultado é um labirinto perfeito, onde cada célula tem um caminho que a conecta a qualquer outra célula, criando um caminho único entre o ponto de partida e o destino (Figura /*Definir depois*/Xc).

\
#figure(
  caption: [Etapas de geração de um labirinto perfeito utilizando o algoritmo de Kruskal],
  supplement: "Figura",
)[
  #columns(3)[
    #image("./images/kruskal_grid.svg", width: 100%)
    (a) Grafo inicial em formato \ de grade.
    #colbreak()
    #image("./images/kruskal_selection.svg", width: 100%)
    (b) Seleção das arestas de \ menor peso.
    #colbreak()
    #image("./images/kruskal_mst.svg", width: 100%)
    (c) Extração da MST.
  ]
  #v(0.5em)
  #text(size: 10pt)[Fonte: Elaborado pelo autor (2026).]
] \

Com um labirinto perfeito em mãos, é possível sobrepor múltiplos labirintos perfeitos para criar cenários mais complexos. Essa técnica de sobreposição permite aumentar a densidade de obstáculos e criar topologias mais desafiadoras para os algoritmos de pathfinding, simulando ambientes mais realistas e variados.

=== Mapas de Altura

Uma mapa de altura nada mais é do que uma representação gráfica de um terreno, onde cada pixel da imagem representa uma coordenada no espaço tridimensional e a intensidade dos valores de cor indica a elevação do terreno naquela coordenada. Diversos desenvolvedores de jogos e simulações utilizam mapas de altura para criar terrenos realistas, como montanhas, vales e planícies. Oferecendo, na internet, uma variedade de cenários para testar os algoritmos de pathfinding.

\
#figure(
  caption: [Exemplo de mapa de altura],
  supplement: "Figura",
)[
  #image("./images/heightmap.png", width: 50%)
  #v(0.5em)
  #text(size: 10pt)[Fonte: #cite(<imperial_library_solstheim>, form: "prose").]
] \

Com isso, é possível gerar malhas 3D complexas a partir de simples imagens. Essa técnica é amplamente utilizada em jogos e simulações para criar ambientes naturais, como montanhas, vales e planícies, oferecendo uma variedade de cenários para testar os algoritmos de pathfinding.

É possível encontrar diversos mapas de altura gratuitos na internet, que podem ser utilizados para gerar malhas 3D realistas e complexas. Esses mapas de altura podem ser processados para extrair a geometria do terreno, criando uma malha que pode ser utilizada como cenário de teste para os algoritmos de pathfinding.

Para poder criar uma malha a partir dessas imagens, primeiro é necessário processar a imagem do mapa de altura para extrair as coordenadas dos vértices e suas respectivas alturas. Considerando $i$ e $j$ como os índices dos pixeis da imagem, $h$ como o valor de intensidade da cor do pixel e $(x, y, z)$ como as coordenadas 3D de cada vértice da malha, é possível atribuir as coordenadas de cada vértice da malha com $(x, y, z) = (i, h, j)$. 

\
#figure(
  caption: [Conversão de um mapa de altura para uma malha 3D],
  supplement: "Figura",
)[
  #image("./images/pixel_to_vertex.svg", width: 90%)
  #v(0.5em)
  #text(size: 10pt)[Fonte: Elaborado pelo autor.]
] \

É importante ressaltar que os valores de cor ($r, g, b$) de uma imagem em escala de cinza variam igualmente de 0 a 255. Para evitar que as variações de altura no cenário 3D sejam desproporcionais às distâncias horizontais, o valor do pixel precisa ser normalizado e escalonado. Considerando $v$ como o valor $r$, $g$ ou $b$ do pixel e $H$ como a altura máxima desejada para o terreno, a elevação $h$ de cada vértice é calculada pela fórmula:

\
$ h = (v / 255) * H $ \

Dessa forma, um pixel totalmente preto ($v = 0$) resultará em uma altura de 0, enquanto um pixel totalmente branco ($v = 255$) atingirá a altura máxima estipulada ($H$), permitindo um controle preciso sobre a amplitude do relevo gerado.

Por fim, são criadas faces conectando cada vértice com seus vizinhos diretos, formando uma malha de triângulos que representa a superfície do terreno. Essa malha pode então ser utilizada como cenário de teste para os algoritmos de pathfinding, permitindo avaliar seu desempenho em ambientes tridimensionais complexos.

\
#figure(
  caption: [Exemplo de malha gerada a partir de um mapa de altura],
  supplement: "Figura",
)[
  #image("./images/heightmap_to_mesh.png", width: 100%)
  #v(0.5em)
  #text(size: 10pt)[Fonte: Elaborado pelo autor.]
] \

=== Geração de Ruídos
Utilizar mapas de altura foi uma grande vantagem para a geração de cenários realistas, mas é ineficiente procurar imagens pré-existentes para cada cenário de teste que se deseja criar. Para isso, é indispensável a implementação de algoritmos de geração de ruídos.

Um ruído é uma função matemática que gera valores pseudoaleatórios, mas de forma controlada, para criar padrões que se assemelham a fenômenos naturais. Existem diversos tipos de ruídos, como o ruído Perlin, o ruído Simplex e o ruído de valor, cada um com suas características e aplicações específicas. Porém, para essa pesquisa, o foco será no ruído Perlin, devido à sua capacidade de gerar padrões suaves e naturais, ideal para simular terrenos realistas.

O ruído de Perlin é um algoritmo de geração de ruído gradiente procedural que é amplamente utilizado para criar texturas e terrenos realistas em gráficos 3D. Ele foi desenvolvido por #cite(<perlin1985image>, form: "prose") e é conhecido por produzir padrões de ruído suaves e naturais (Figura /*Definir depois*/Xa), o que o torna ideal para simular superfícies como montanhas, nuvens e oceanos. Com isso em mente, podemos utilizar desse algoritmo para gerar nossos próprios mapas de altura, sem precisar recorrer a imagens pré-existentes. Isso nos dá controle total sobre a geração dos cenários de teste, permitindo criar uma variedade de terrenos com diferentes características e desafios para os algoritmos de pathfinding.

Para conseguir um ruído suave e natural, o algoritmo gera diversas camadas de texturas diferentes (Figura /*Definir depois*/Xb) e as sobrepõe, essas camadas são chamadas de _octaves_ (oitavas). Ao sobrepor múltiplas _octaves_, é usada uma função de interpolação, que será detalhada na Seção 4.4.3.1, para suavizar a transição entre os valores gerados por cada camada, criando um resultado final que se assemelha a padrões naturais. A combinação de múltiplas _octaves_ permite criar terrenos com detalhes variados, desde grandes elevações até pequenas variações de altura.

\
#figure(
  caption: [Exemplo de ruído de Perlin e um de seus _octaves_],
  supplement: "Figura",
)[
  #columns(2)[
    #image("./images/perlin_noise.png", width: 100%)
    #align(center)[(a) Ruído de Perlin completo.]
    #colbreak()
    #image("./images/octave.png", width: 100%)
    #align(center)[(b) Uma _octave_ do ruído de Perlin.]
  ]
  #v(0.5em)
  #text(size: 10pt)[Fonte: Elaborado pelo autor.]
] \

Para gerar uma _octave_ do ruído de Perlin, primeiro é necessário criar uma grade de tamanho unitário com vetores de gradiente unitários em cada ponto de interceçao da grade, onde cada vetor aponta em uma direção aleatória. O tamanho de cada célula da grade determina o nível de detalhe do ruído, onde células maiores produzem um ruído mais suave, enquanto células menores geram um ruído mais detalhado. 

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
] \

Para cada ponto no espaço (ou _pixel_), o algoritmo calcula os vetores de distância entre ele e cada ponto de interceção de sua respectiva célula da grade. Em seguida, é calculado o produto escalar entre os vetores de distância $arrow(a) = (a_x, a_y)$ e os vetores de gradiente correspondentes $arrow(b) = (b_x, b_y)$, pela fórmula:

\
$ arrow(a) dot arrow(b) = (a_x * b_x) + (a_y * b_y) $ \

O resultado do produto escalar é um valor numérico que representa a contribuição do vetor de gradiente para o _pixel_ em questão. Por fim, é aplicada uma função de interpolação (Seção 4.4.3.1), onde cada valor escalar é suavizado para criar uma transição entre o _pixel_ de forma ponderada, ou seja quanto mais próximo o _pixel_ estiver do ponto de interseção, maior será a contribuição do vetor de gradiente para o valor final do ruído.

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
] \

Com uma _octave_ do ruído de Perlin gerada, é possível sobrepor múltiplas octaves para criar um ruído mais complexo e detalhado. Porém, para evitar que as octaves sejam idênticas, é necessário aplicar valores que alterem sua geração. Para isso são introduzidos valores de frequência (Lacunaridade) e amplitude (Persistência), onde a frequência determina o número de detalhes presentes na _octave_, e a amplitude controla a intensidade desses detalhes. 

Conforme #cite(<patel_terrain_noise>, form:"prose") explica, a combinação de múltiplas octaves com diferentes frequências e amplitudes permite criar terrenos com uma variedade de características, desde grandes elevações até pequenas variações de altura, simulando ambientes naturais de forma realista.

\
#figure(
  caption: [Ruídos de Perlin com diferentes frequências e amplitudes],
  supplement: "Figura",
)[
  #columns(3)[
    #image("./images/perlin_high_freq.png", width: 100%)
    #align(center)[(a) Ruído gerado com alta \ lacunaridade (Frequência 4 e Amplitude 1).]
    #colbreak()
    #image("./images/perlin_high_amp.png", width: 100%)
    #align(center)[(b) Ruído gerado com alta \ persistência (Frequência 1 \ e Amplitude 4).]
    #colbreak()
    #image("./images/perlin_high_freq_amp.png", width: 100%)
    #align(center)[(c) Ruído gerado com alta \ lacunaridade e persistência \ (Frequência 4 e Amplitude 4).]
  ]
  #v(0.5em)
  #text(size: 10pt)[Fonte: Elaborado pelo autor.]
] \

Assim, em cada ponto do espaço $(x, y)$, o valor base do ruído acumulado $V(x, y)$ é definido pela soma ponderada das _octaves_:

\
$ V(x, y) = sum_(i=0)^(N-1) (a_i dot "perlin"((x dot f_i)/lambda, (y dot f_i)/lambda)) $ \

Onde $N$ é o número de _octaves_, $lambda$ é o tamanho da célula, $f_i = F dot 2^i$ representa o aumento exponencial da frequência e $a_i = A dot 0.5^i$ representa o decaimento exponencial da amplitude. 

Após o acúmulo, o valor final $V_"f" (x,y)$ do terreno é limitado para um intervalo de $[-1, 1]$ e pode ser remapeado para um intervalo de $[0, H]$, onde $H$ é a altura máxima desejada para o terreno, utilizando a fórmula:
$ V_"f" (x,y) = ((V(x, y) + 1) / 2) dot H $ \

Finalmente, o valor $V_"f" (x,y)$ é utilizado para definir a elevação de cada vértice da malha como $h$. Isso permite gerar terrenos como feito anteriormente a partir de mapas de altura, mas com controle total sobre a geração dos cenários de teste, criando uma variedade de terrenos sem depender de imagens de terceiros.

\
#figure(
  caption: [Exemplo de malha gerada a partir de um ruído de Perlin],
  supplement: "Figura",
)[
  #image("./images/mesh_from_perlin.png", width: 100%)
  #v(0.5em)
  #text(size: 10pt)[Fonte: Elaborado pelo autor.]
] \

==== Função de Interpolação
A função de interpolação é um componente crucial no algoritmo de geração de ruído de Perlin, pois é responsável por suavizar a transição entre os valores gerados por cada camada de ruído, criando um resultado final que se assemelha a padrões naturais. 

A função de interpolação utilizada no ruído de Perlin é conhecida como função de suavização. #cite(<zipped_perlin_noise>, form:"prose") ressalta que a interpolação linear simples não é adequada de forma isolada para gerar padrões naturais, pois deixa transições abruptas entre os valores de ruído, resultando em um terreno com bordas visíveis entre as células da grade.

Para solucionar esse problema e garantir uma transição orgânica, emprega-se uma curva de atenuação (ou função _fade_). No algoritmo original de Perlin, essa suavização é alcançada através de uma função polinomial cúbica, conhecida como _Smoothstep_, definida matematicamente por:

\
$ S(w) = 3w^2 - 2w^3 $ \

#figure(
  caption: [Função de Suavização no Ruído de Perlin],
  supplement: "Figura",
)[
  #image("./images/smoothstep_graph.png", width: 100%)
  #v(0.5em)
  #text(size: 10pt)[Fonte: Elaborado pelo autor.]
] \


Essa curva mapeia o peso $w$ (a posição relativa da coordenada, variando de $0$ a $1$) para um valor suavizado. A principal vantagem matemática do uso dessa função é que a sua primeira derivada é igual a zero em ambas as extremidades ($w = 0$ e $w = 1$). Isso garante que a transição de influência entre os gradientes de duas células vizinhas seja perfeitamente contínua, ocultando os limites da grade original.

Após obter o peso suavizado $S(w)$, o algoritmo realiza a interpolação linear padrão entre os valores de contribuição escalar $a_0$ e $a_1$ calculados:

\
$ f(a_0, a_1, w) = a_0 + (a_1 - a_0) dot S(w) $ \

== Concorrência e Paralelismo
A evolução do hardware moderno, com o aumento do número de núcleos de processamento, tornou o paralelismo uma ferramenta essencial para manter a responsividade em aplicações gráficas e intensivas em dados.

=== _Multithreading_ com C++20
A linguagem C++20 introduziu várias melhorias para a programação concorrente, incluindo a classe `std::jthread`, que é uma extensão da classe `std::thread` com suporte integrado para cancelamento de threads. O uso de `std::jthread` permite que as threads sejam encerradas de forma limpa e segura, aproveitando o padrão RAII (_Resource Acquisition Is Initialization_) para garantir que as threads sejam automaticamente unidas (_joined_) em chamadas de destruição. 

Em seu construtor, as `std::jthread` recebem uma função lambda que encapsula a lógica de execução da thread trabalhadora. Funções lambda são funções anônimas que podem capturar variáveis do escopo onde foram definidas, facilitando a passagem de dados. Ao ser instanciada, a `std::jthread` inicia a execução da lambda em uma nova linha de processamento paralela.

=== Tokens de Parada
O `std::stop_token` é um mecanismo que permite sinalizar a uma thread que ela deve parar sua execução de forma cooperativa. Isso é especialmente útil para evitar bloqueios e garantir encerramentos limpos. No seu loop interno, a função lambda pode verificar periodicamente o estado do `std::stop_token` para determinar se deve continuar executando ou encerrar a thread. Uma vantagem da `std::jthread` é a injeção automática desse token caso a função lambda possua um parâmetro correspondente, eliminando a necessidade de instanciá-lo explicitamente.

=== Variáveis Condicionais
O `std::condition_variable_any` é uma ferramenta de sincronização que permite que as threads esperem por condições específicas, facilitando a coordenação entre threads trabalhadoras e a _main thread_. Quando as threads trabalhadoras são criadas, elas entram em estado de espera usando a variável condicional, aguardando que a _main thread_ adicione uma tarefa à fila. O uso desta ferramenta é crucial para garantir que as tarefas sejam processadas em ordem e sem o uso excessivo de CPU por meio de _polling_.

=== Monitores
Conforme explica #cite(<ladeira_sincronizacao>, form: "prose"), o padrão Monitor é uma implementação de alto nível para controle de sincronização. Ele encapsula tanto os dados quanto os métodos que operam sobre esses dados, utilizando mecanismos de bloqueio (_mutexes_) para garantir exclusão mútua e variáveis de condição para coordenar a execução das threads. A adoção do padrão Monitor visa prevenir condições de corrida (_race conditions_) entre as rotinas assíncronas de processamento e a _main thread_, garantindo a integridade dos recursos compartilhados como os dados da malha e do grafo.

=== _Task Scheduler_
O _Task Scheduler_ (Agendador de Tarefas) da aplicação centraliza o gerenciamento de todas as rotinas concorrentes que não envolvem renderização. O seu papel principal é evitar o travamento da thread principal (onde roda a interface e o contexto OpenGL) através da delegação de processamento intensivo para um pool de threads trabalhadoras que operam em paralelo #cite(label("williams2019c++"), form:"normal"). No contexto deste projeto, as tarefas delegadas incluem a modelagem de ruído de Perlin, a leitura e decodificação de mapas de altura, a triangulação física de malhas 3D e a posterior extração do grafo lógico necessário para o cálculo das rotas.

=== Fila Multinível
Como as tarefas executadas pelo agendador possuem tempos de processamento e níveis de importância diferentes para o usuário, o sistema utiliza filas multinível ordenadas por prioridade.
- As tarefas de alta prioridade (`Priority::High`) são reservadas para etapas cruciais que desbloqueiam as fases seguintes do pipeline, como a definição dos parâmetros criação e a geração dos ruídos.
- As tarefas de média prioridade (`Priority::Medium`) compreendem o processamento estrutural mais longo, que envolve a triangulação geométrica e a extração do grafo.
- As tarefas de baixa prioridade (`Priority::Low`) englobam processos de escrita em disco (I/O) utilizando a biblioteca `stb_image_write`, como o salvamento de imagens png dos mapas gerados. Por dependerem da latência física do sistema de armazenamento, essas operações rodam apenas quando não há tarefas computacionais prioritárias na fila, minimizando a contenção por barramento e memória.

\
#figure(
  caption: [Diagrama de Thread Pool e filas multinível],
  supplement: "Figura",
)[
  #image("./images/thread_pool.svg", width: 75%)
  #v(0.5em)
  #text(size: 10pt)[Fonte: Elaborado pelo autor.]
] \

=== Segurança de Memória e Compartilhamento de Estado
A execução simultânea de algoritmos de busca e rotinas de geração procedural em múltiplas threads operárias traz riscos críticos de corrupção de memória. Se uma thread trabalhadora tentar ler ou varrer os nós de um grafo (composto por objetos `Vertex3D` e vetores de adjacência) no exato instante em que a thread principal deleta, substitui ou recria o cenário tridimensional, ocorre um erro de ponteiro solto (dangling pointer) que causa o encerramento do programa por falha de segmentação (erro `SIGSEGV`).

Para evitar a ocorrência de condições de corrida (race conditions) e vazamento de recursos sem introduzir cópias pesadas de dados na memória RAM, a infraestrutura abandona o uso de ponteiros brutos na comunicação entre threads. Em vez disso, o grafo lógico é compartilhado por meio de ponteiros inteligentes do tipo `std::shared_ptr<common::lwGraph<Vertex3D>>`. Quando uma tarefa de busca de caminhos é inserida no `TaskMaster`, ela recebe uma cópia do `std::shared_ptr`, o que incrementa o contador de referências do recurso. Dessa maneira, mesmo que a thread principal delete a representação visual da malha ou inicie uma nova simulação, o bloco de memória do grafo em execução permanece válido até que a thread operária termine seu processamento e libere o ponteiro, garantindo total isolamento e segurança. As referências constantes (como `const Vertex3D&`) são reservadas apenas para acessos de leitura locais dentro de escopos bem controlados onde a validade temporal do objeto é garantida por design.

= TRABALHOS RELACIONADOS

Este capítulo apresenta uma análise comparativa detalhada entre a proposta deste trabalho  e os principais estudos correlatos da literatura recente que realizam análises estatísticas e _benchmarks_ de algoritmos de _pathfinding_.

== Johansson (2024)
No trabalho intitulado _Adapting Pathfinding Algorithms for 3D Environments: Performance Analysis and Real-World Applications_, #cite(<johansson2024adapting>, form: "prose") realiza uma avaliação de desempenho em termos de tempo de execução e consumo de memória dos algoritmos Dijkstra e A\* (utilizando as heurísticas Euclidiana e Manhattan) adaptados para ambientes tridimensionais.

Contudo, o estudo apresenta limitações de escopo, focando quase que exclusivamente em ambientes estruturados por *Voxels* (grades de blocos uniformes e cúbicos), e a execução dos testes ocorre de forma puramente sequencial e padrão. O diferencial crítico utilizando deste estudo frente a este trabalho reside em dois pontos principais:

1. *Topologia Geométrica:* Enquanto o estudo citado limita-se à rigidez ortogonal dos voxels, o gerador procedural deste estudo utiliza Ruído de Perlin e processamento de mapas de altura para extrair malhas contínuas e acidentadas. Isso eleva a complexidade do cálculo heurístico ao exigir navegação sobre relevos realistas, rampas e curvas suaves.
2. *Diversidade Algorítmica:* Estende-se a análise para algoritmos focados em otimização de espaço aberto e relaxação de linha de visão (_Any-Angle Pathfinding_), incorporando o *Theta\** e o *Jump Point Search (JPS)*, indo muito além do escopo básico de Dijkstra e A\*.

== Grid Maps Benchmark (2023)
O artigo _A Comparison of Pathfinding Algorithm for Code Optimization on Grid Maps_, publicado na IJACSA #cite(<ijacsa2023comparison>), realiza uma comparação estatística direta (tempo de CPU em microssegundos e contagem de nós expandidos) entre a trindade clássica de busca: A\*, JPS e Theta\*.

A principal limitação deste estudo é que os experimentos são restritos a matrizes bidimensionais planas (_2D Grid Maps_). Além disso, a execução dos algoritmos ocorre de forma síncrona e linear, avaliando buscas isoladas em cenários estáticos. Em contrapartida, os diferenciais deste estudo são:

1. *A Terceira Dimensão Físico-Espacial:* Exige a readequação volumétrica tridimensional real das heurísticas (como a distância diagonal/Chebyshev adaptada e a distância Euclidiana 3D), lidando com a complexidade geométrica do eixo Z.
2. *Arquitetura Concorrente sob Estresse:* O _benchmark_ pulveriza a execução simultânea das buscas espaciais em múltiplas _threads_ operárias através da biblioteca `jthread` e de filas multinível orientadas a eventos.
3. *Rigor e Segurança de Memória:* Para suportar esse ambiente de alto estresse concorrente sem mascarar os tempos de CPU com travamentos ou condições de corrida, a infraestrutura implementada utiliza ponteiros inteligentes (`shared_ptr` e `unique_ptr`), garantindo métricas puras de hardware.

== Matriz de Diferenciação Técnica
A tabela a seguir consolida as lacunas da literatura e destaca as contribuições metodológicas do motor IFCG.

#figure(
  caption: [Matriz de diferenciação entre a proposta e trabalhos relacionados],
  supplement: "Tabela",
)[
  #table(
    columns: (1fr, 1.4fr, 1fr, 1fr),
    stroke: none,
    align: (left, left, left, left),
    table.hline(y: 0, stroke: 1pt),
    table.hline(y: 1, stroke: 0.5pt),
    [*Critério*], [*Proposta (IFCG)*], [*Johansson (2024)*], [*Benchmark (2023)*],
    [Dimensão Espacial], [Malhas 3D volumétricas], [Voxels (blocos 3D)], [Grades 2D planas],
    [Geometria], [Contínua e procedural (Perlin)], [Cubos fixos \ (discretos)], [Matrizes planas],
    [Algoritmos], [Dijkstra, A\* (e modificações), JPS, Theta\*, LazyTheta\*], [A\* e Dijkstra], [A\*, JPS, Theta\*],
    [Arquitetura], [Multi-threaded (`jthread`)], [Sequencial/Padrão], [Sequencial/Padrão],
    [Ambiente / Carga], [Renderização 3D em tempo real sob concorrência], [Execução sequencial isolada], [Execução sequencial isolada],
    table.hline(stroke: 1pt)
  )
  #v(0.5em)
  #text(size: 10pt)[Fonte: Elaborado pelo autor (2026).]
]

= METODOLOGIA
Esta seção detalha a metodologia adotada para a realização da pesquisa, explicando como os algoritmos de pathfinding e a infraestrutura gráfica serão implementados e testados. Este projeto foi conduzido como uma pesquisa experimental de caráter quantitativo, sendo que a implementação da infraestrutura gráfica e dos algoritmos de pathfinding ocorreu em paralelo à coleta e análise de dados. A abordagem experimental permitirá a avaliação do desempenho dos algoritmos em condições controladas, enquanto a construção do motor do zero garantirá um ambiente de teste personalizado e otimizado para as necessidades específicas deste estudo.

== Arquitetura do Motor Gráfico (IFCG)

O motor gráfico desenvolvido para este estudo, denominado IFCG (Instituto Federal Catarinense/Computação Gráfica), foi projetado para ser uma plataforma de redenrização flexível para a implementação e avaliação dos algoritmos de pathfinding. A arquitetura do IFCG foi cuidadosamente planejada para garantir que os testes sejam realizados em um ambiente gráfico realista, mas simples, permitindo a coleta de dados precisos sobre o desempenho dos algoritmos em cenários tridimensionais complexos.

Ele é composto por diversos módulos, cada um responsável por uma parte específica do processo de renderização e gerenciamento de recursos gráficos. A seguir, serão detalhados os principais componentes da arquitetura do motor gráfico e como eles se relacionam para criar um ambiente de teste eficiente para os algoritmos de pathfinding.

=== Aplicação de conceitos

Para lidar com a complexidade inerente à renderização gráfica e ao gerenciamento de recursos, a arquitetura do IFCG foi projetada utilizando princípios de design de software e padrões de projeto. A aplicação desses conceitos é fundamental para garantir que o código seja uma simplificação das chamadas do OpenGL, mantendo a flexibilidade e a capacidade de extensão necessárias para futuras implementações e otimizações.

Como o coração do motor foi desenvolvida uma classe `Engine`, que é responsável por gerenciar o ciclo de renderização, as chamadas ao OpenGL e a interação com a janela. Essa classe encapsula toda a lógica do ciclo de renderização e fornece uma interface simples para a criação de cenários de teste, permitindo que os algoritmos de pathfinding sejam avaliados em diferentes condições e configurações.

O padrão _Singleton_ foi aplicado na criação de instâncias do `Engine`, garantindo um controle centralizado sobre os recursos gráficos e a renderização. Isso evita conflitos e mantém a consistência do ambiente de renderização, permitindo que diferentes partes do sistema acessem o motor gráfico de forma segura e coordenada.

Seguindo os conceitos de #cite(<learnopengl>, form: "prose"), foi desenvolvido uma classe `Mesh`, que representa uma malha 3D e encapsula os dados necessários para renderizá-la, como vértices, normais, coordenadas de textura e índices. Essa classe também gerencia os _buffers_ VBO, EBO e VAO, garantindo que a malha seja renderizada de forma eficiente e correta.

A classe `Shader` @learnopengl foi implementada para gerenciar os programas de sombreamento (shaders) utilizados na renderização das malhas. Ela encapsula a criação, compilação e vinculação dos shaders. Essa classe permite a leitura de arquivos de extensão `glsl`, que contêm o código dos shaders, e fornece métodos para definir uniformes e atributos de vértice, facilitando a personalização da aparência das malhas renderizadas.

=== Componentes do Motor Gráfico

Para organizar a arquitetura do motor gráfico, foram definidos diversos módulos, cada um responsável por uma parte específica do processo de renderização e gerenciamento de recursos gráficos. A seguir, serão detalhados os principais componentes da arquitetura do motor gráfico e como eles se relacionam para criar um ambiente de teste eficiente para os algoritmos de pathfinding.

+ Window: Essa classe é um _wrapper_ para a biblioteca GLFW, responsável por criar e gerenciar a janela de renderização. Ela encapsula a criação do contexto OpenGL, o gerenciamento de eventos de entrada (como teclado e mouse) e a configuração das propriedades da janela, como tamanho, título e modo de exibição.

+ Renderer: Essa classe é responsável por gerenciar o ciclo de renderização, incluindo a configuração do estado do OpenGL, a vinculação dos _buffers_ e a emissão dos comandos de desenho. Ela também gerencia a ordem de renderização das malhas, garantindo que os objetos sejam desenhados na ordem correta e com as propriedades visuais desejadas.

+ Input: Essa classe é responsável por gerenciar a entrada do usuário, processando eventos de teclado e mouse. Ela fornece métodos para adicionar funções de _callback_ personalizadas, permitindo que a aplicação reaja a eventos de entrada de forma flexível e eficiente.

=== Estrutura de Renderização e Gerenciamento de Recursos

O padrão _Composite_ @gamma1994design foi utilizado para representar a hierarquia de objetos na infraestrutura gráfica, onde uma malha complexa pode ser composta por várias sub-malhas, e cada sub-malha pode ser tratada da mesma forma. Toda base de malha (_MeshBase_) contém sua própria matriz de modelo, que é responsável por armazenar as transformações de posição, rotação e escala da malha. Então as classes de malha (_Mesh_) e malha composta (_MeshTree_) herdam dessa base, permitindo que sejam tratadas de forma uniforme, independentemente de serem malhas simples ou compostas.

\
#figure(
  caption: [Diagrama de classe do Composite],
  supplement: "Figura",
)[
  #image("./images/mesh_composite.png", width: 100%)
  #v(0.5em)
  #text(size: 10pt)[Fonte: Elaborado pelo autor.]
] \

Com essa arquitetura, o motor de renderização pode desenhar tanto malhas simples quanto compostas utilizando a mesma interface. Assim, permitindo criar cenários complexos com complexidade reduzida e mantendo a flexibilidade para adicionar novos tipos de malhas ou componentes gráficos no futuro.

Isso permite que o `Renderer` é capaz de percorrer a hierarquia de malhas e renderizar cada uma delas de forma eficiente, aplicando as transformações apropriadas e garantindo que a cena seja exibida corretamente na janela de renderização. 

Uma fila de malhas é mantida pelo `Renderer`, permitindo que as malhas sejam adicionadas e removidas dinamicamente durante a execução do programa. Essa fila é processada a cada ciclo de renderização, garantindo que todas as malhas sejam desenhadas na ordem correta e com as propriedades visuais desejadas.

Para gerenciar a renderização foi desenvolvido um sistema de loop de renderização ajustado a partir de configurações pré-definidas. Isso é, foi desenvolvido um _struct_ `LoopConfig` que contém parâmetros como taxa de atualização desejada, limites de tempo de renderização e opções de funções _lambda_ para serem executadas em momentos diferentes do ciclo de renderização. O `Renderer` utiliza essas configurações para controlar fluxo do motor flexívelmente.

== Implementação da Estrutura de Grafos
=== Representação de Grafos Direcionados e Não Direcionados
=== Algoritmos de Pathfinding
=== Otimizações e Estruturas de Dados Auxiliares

== Geração e Processamento dos Cenários
A capacidade de testar os algoritmos em uma grande variedade de mapas exige a adoção de um fluxo bem definido para a construção procedural dos terrenos, sua conversão para malhas de renderização e, mais importante, a extração de dados matemáticos para a navegação.

=== Geração de Malhas 3D Complexas
Os cenários utilizados no estudo são gerados por duas abordagens complementares: a importação de mapas de altura pré-renderizados (imagens em escala de cinza, carregadas utilizando a biblioteca `stb_image`) e a geração puramente procedural baseada em Ruído de Perlin. 

A geração procedural opera instanciando um mapa bidimensional $(x, y)$ onde o algoritmo de ruído calcula uma elevação base. Esse valor é multiplicado por um fator global de intensidade, produzindo a coordenada tridimensional final do vértice $(x, y, z)$. Todas essas posições são agrupadas sequencialmente em _buffers_ de memória para compor a malha tridimensional (`Mesh`) que o motor IFCG utilizará para a renderização visual do ambiente.

=== Processamento de Malhas e Extração de Grafos
Para que um algoritmo de busca possa atravessar esse cenário, é necessário derivar uma representação lógica a partir dos vértices físicos. Esse processo de "extração de grafo" varre cada ponto do cenário em formato de grade e tenta conectá-lo aos seus vizinhos (adjacência horizontal, vertical e diagonal).

O diferencial nesta etapa é a limitação por inclinação. A conexão entre dois vértices (a aresta) só é considerada válida se a diferença absoluta de altura entre eles ($|z_2 - z_1|$) for menor ou igual a um limite de transposição (`heightLimit`). Esse parâmetro simula a capacidade física de uma entidade escalar um obstáculo, tornando encostas muito íngremes e penhascos intransponíveis. Uma vez validada a conexão, o custo dessa aresta é assinalado como a distância Eucltidiana 3D real enre os dois pontos, refletindo o peso natural da elevação.

=== Configuração de Cenários de Teste e Parâmetros
O desenho experimental prevê que os testes sejam automatizados em sequências de estresse parametrizado, definindo três eixos de configuração centrais:
- *Escala:* Varia progressivamente o tamanho (largura e profundidade) da malha e, por consequência, o número absoluto de nós a serem expandidos pelos algoritmos.
- *Lacunaridade:* Altera a frequência do Ruído de Perlin. Uma frequência mais alta cria terrenos mais esburacados, com "ruídos" intensos e obstáculos constantes, o que eleva a dificuldade heurística e bloqueia linhas de visão diretas (desafiando algoritmos como o Theta\* e o JPS).
- *Persistência:* Manipula a amplitude das funções de ruído, modificando a "suavidade" do terreno. Variações bruscas na persistência intensificam as elevações, forçando interrupções constantes pela trava física do `heightLimit`.

Tais parâmetros são injetados diretamente na configuração de geração procedural a cada iteração de teste, assegurando amostragem abrangente para análises estatísticas.

== Implementação do Sistema Concorrente

=== Adaptação para Ambientes de Renderização
Para viabilizar a execução de simulações interativas sem prejuízo à taxa de quadros e à fluidez visual, o sistema de concorrência foi adaptado para contornar as limitações de acesso do OpenGL. O motor gráfico IFCG opera sob estrição de contexto gráfico de _thread_ única, no qual o contexto de renderização é vinculado a uma única _thread_ ativa (_thread_ principal). Qualquer tentativa de invocar funções do OpenGL ou manipular estruturas de dados de GPU (tais como _VAOs_ e _VBOs_) a partir de _threads_ secundárias resulta em comportamento indefinido ou no encerramento abrupto do programa por violações de acesso à memória (erros `SIGSEGV`).

A adaptação implementada realiza um desacoplamento completo entre o fluxo de renderização e quaisquer tarefas secundárias. A geração de ruído, o processamento de mapas de altura e a extração do grafo adjacência são executados de maneira puramente assíncrona. Essas tarefas não possuem dependências ou chamadas diretas ao OpenGL. Uma vez que o processamento do terreno e a extração do grafo são concluídos, os dados são sincronizados com a _thread_ principal. Esta se encarrega de efetuar as chamadas de alocação e atualização de _buffers_ na GPU dentro do ciclo síncrono de renderização, garantindo a integridade do contexto OpenGL e mantendo estável a taxa de quadros por segundo da visualização tridimensional.

=== Implementação de Multithreading e Testes de Estresse
A orquestração das tarefas em segundo plano é gerenciada pela classe `TaskMaster`, desenvolvida como um escalonador de tarefas concorrente baseado em filas de prioridade multinível (`High`, `Medium` e `Low`) e um _thread pool_ dinâmico. O construtor do `TaskMaster` consulta a capacidade física do processador por meio de `std::thread::hardware_concurrency()`, instanciando $N-1$ _threads_ operárias (onde $N$ é o total de núcleos lógicos disponíveis) para resguardar a capacidade de processamento da _thread_ principal e evitar travamentos na interface gráfica do usuário. As _threads_ trabalhadoras são implementadas como objetos `std::jthread` (introduzidos no padrão C++20), que utilizam o comportamento RAII para garantir que sejam finalizadas corretamente na destruição do escalonador.

\
#figure(
  caption: [Diagrama de classes da arquitetura do TaskMaster],
  supplement: "Figura",
)[
  #image("./images/task_master.png", width: 100%)
]\

O método `addTask` é o ponto de entrada para a submissão de tarefas concorrentes. Utilizando modelos de programação (_templates_) e metaprogramação em tempo de compilação (`if constexpr`), juntamente com o traço de tipo `std::is_invocable_v`, o método diferencia funções que aceitam um `std::stop_token` daquelas que não requerem controle de cancelamento, envolvendo estas últimas em um adaptador (_wrapper_). Isso confere flexibilidade ao sistema, permitindo que tarefas de longa duração verifiquem periodicamente se uma interrupção foi solicitada, enquanto tarefas curtas e simples podem ser executadas sem essa complexidade adicional.

Cada thread operária executa um loop contínuo que aguarda por novas tarefas utilizando uma `std::condition_variable_any`. A lógica de seleção de tarefas prioriza sempre as filas de maior importância: o trabalhador verifica sequencialmente as filas 0 (`High`), 1 (`Medium`) e 2 (`Low`), extraindo a primeira tarefa disponível na fila de maior prioridade encontrada. Mesmo que um lock tenha sido adquirido por meio de `std::unique_lock<std::mutex>`, a função `wait` da variável condicional libera o lock enquanto a thread está bloqueada, permitindo que a _main thread_ adicione novas tarefas concorrentes sem contenção desnecessária. Quando a thread operária é acordada, o lock é automaticamente re-adquirido para a extração segura da tarefa.

Para monitoramento e testes de estresse do _thread pool_, o `TaskMaster` incorpora a função de escrita `drawWorkers()`. Protegida por um semáforo de exclusão mútua (`printMtx`), ela atualiza e imprime no console o estado de cada _thread_ trabalhadora (usando os caracteres `H`, `M`, `L` e `-` para representar atividades de alta, média, baixa prioridade ou ociosidade, respectivamente), oferecendo _feedback_ visual instantâneo e contínuo durante a execução em lote das simulações.

=== Controle de Recursos do Sistema Operacional
Para garantir que a execução paralela não comprometa a estabilidade do sistema ou a fluidez da interface gráfica, a arquitetura adota estratégias rigorosas de controle de recursos em nível de software e hardware. Ao limitar o pool de trabalhadores ao total de núcleos físicos menos um ($N-1$), reduz-se o custo de trocas de contexto (_context switching_) e a disputa por cache L3 entre as _threads_ operárias e o motor de renderização. Além disso, o suporte ao cancelamento cooperativo via `std::stop_token` permite interromper de forma imediata tarefas obsoletas, evitando o desperdício de ciclos de CPU em processamentos desnecessários.

Adicionalmente, a fim de obter medições estatísticas limpas durante as baterias de testes estatísticos, a aplicação realiza o controle de afinidade de CPU por meio de chamadas de baixo nível do sistema operacional (utilizando `pthread_setaffinity_np` envelopado na função `pinThreadToCore`). Enquanto as tarefas de geração do mapa de ruído e construção do grafo ocorrem concorrentemente sob o gerenciamento do `TaskMaster` em múltiplos núcleos, a _main thread_ sincroniza a conclusão do lote de processamento e vincula sua execução estritamente a um núcleo de processador isolado (como o núcleo 2) para executar os algoritmos de busca (A\*, Dijkstra e JPS). Esse isolamento de afinidade evita flutuações e ruído causados pelo agendador do sistema operacional, blindando os benchmarks estatísticos contra perturbações dinâmicas de concorrência.


== Desenho Experimental e Coleta de Dados
A coleta de dados foi projetada para avaliar o impacto computacional dos algoritmos em terrenos de complexidade variável. 

=== Ambiente de Teste
A avaliação empírica do sistema foi executada em um computador pessoal com processador Intel Core i5-1235U de 12ª geração. Esse processador possui uma arquitetura híbrida contendo 10 núcleos físicos (2 núcleos de alta performance e 8 núcleos de alta eficiência) que totalizam 12 threads lógicas de execução, operando com frequência de clock máxima de 4,40 GHz e 12 MB de memória cache. O sistema possui 16 GB de memória RAM DDR4 operando a 3200 MHz em canal duplo (dual-channel). A renderização das malhas 3D e a rasterização do motor gráfico foram processadas por uma GPU integrada Intel Iris Xe Graphics rodando a uma frequência dinâmica máxima de 1,20 GHz.

Em termos de software, os benchmarks foram realizados sob o sistema operacional Arch Linux rodando o Kernel estável 6.15.9. Para reduzir perturbações externas nos testes de performance, o agendador de energia do processador foi configurado manualmente para o modo de desempenho máximo (`performance`), mantendo os clocks elevados e estáveis. O código-fonte foi desenvolvido no padrão C++20 (`-std=c++20`) e compilado com o GNU Compiler Collection (GCC) versão 14.1. 

Para extrair o máximo desempenho do hardware nos testes comparativos, o binário final foi construído utilizando a flag de otimização agressiva de velocidade de execução `-O3` no perfil de lançamento (`Release`), além de parâmetros estritos de compilação que garantem a segurança do código (`-Wall`, `-Wextra`, `-Wpedantic`, `-Werror`). A renderização gráfica foi programada sobre a especificação do OpenGL versão 4.6 (Core Profile), usando a biblioteca GLFW 3.4 para o controle de janelas e contexto gráfico, e a biblioteca GLM 1.0.3 para o processamento algébrico de matrizes e vetores tridimensionais.

=== Configuração dos Testes e Métricas Coletadas
Para analisar o desempenho, foram selecionadas métricas que avaliam tanto a eficiência computacional quanto a qualidade da solução e a estabilidade do sistema:

- *Tempo de Execução:* Mede o intervalo gasto na geração de mapas, construção de grafos e busca de caminhos.
- *Responsividade (FPS):* A taxa de quadros por segundo é monitorada para validar a eficácia do isolamento da _main thread_.
- *Consumo de Memória:* Avalia o impacto das estruturas de dados (malhas e grafos) no uso de RAM.
- *Eficiência do Cache:* Analisa a taxa de acertos e falhas na CPU, fornecendo _insights_ sobre a localidade de referência dos algoritmos.
- *Métricas de Busca:* Incluem o número de nós expandidos e o custo total do caminho para validar a otimalidade.

Com essas métricas, será possível realizar uma análise abrangente do desempenho dos algoritmos de pathfinding em diferentes cenários, identificando as condições sob as quais cada algoritmo se destaca ou apresenta limitações. Como resultado, espera-se fornecer recomendações práticas para a escolha de algoritmos em aplicações de navegação tridimensional em tempo real para diferentes circunstâncias.

=== Execução dos Testes e Registro dos Resultados

O experimento utiliza uma bateria de testes organizada em três eixos principais de variação: escala, lacunaridade e persistência. A aquisição dos dados estatísticos é realizada de forma paralelizada para otimizar o tempo total de experimentação e garantir que o motor gráfico permaneça responsivo.

O fluxo de execução é gerenciado pelo `TaskMaster`, que agrupa as tarefas de cada repetição do experimento:
1. *Geração do Mapa (Alta Prioridade):* O mapa de ruído de Perlin é gerado na fila `Priority::High`.
2. *Construção do Grafo e Malha (Média Prioridade):* A extração da estrutura de dados para busca ocorre na fila `Priority::Medium`.
3. *Exportação de Dados (Baixa Prioridade):* O salvamento das representações visuais (PNG) é feito na fila `Priority::Low` por ser uma operação de I/O lenta.\

A _main thread_ utiliza um mecanismo de sincronização baseado em `std::condition_variable` para aguardar a conclusão de um lote completo de processamento (passo do experimento). Somente após todos os grafos estarem prontos e alocados, a _thread_ principal executa os algoritmos de busca (A\*, Dijkstra, etc.) e registra os dados estatísticos, garantindo que a medição de performance não sofra ruído devido à contenção de recursos do processamento paralelo.

Para garantir um ambiente de teste com o mínimo de interferências externas, certas configurações do sistema são ajustadas. Um shell script é utilizado para configurar a afinidade de CPU do processo, limitando-o a um subconjunto específico de núcleos para evitar interferências de outros processos do sistema operacional. Além disso, o sistema é configurado para minimizar a interferência de serviços em segundo plano, garantindo que os dados coletados reflitam o desempenho real dos algoritmos sob as condições controladas do experimento. 

= RESULTADOS



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
    [Arquitetura Base (IFCG) e Estrutura de Grafos], [Fev/2026 a Abr/2026],
    [Heurísticas e Implementação Base (A\*, Dijkstra, JPS, Theta\*)], [Mar/2026 a Mai/2026],
    [Geração de Cenários de Teste e Malhas 3D], [Abr/2026 a Mai/2026],
    [Multithreading e Testes de Estresse], [Mai/2026 a Jun/2026],
    [Coleta de Dados Iniciais e Análise Estatística Simples], [Mai/2026 a Jun/2026],
    [Redação e Revisão do Pré-Projeto], [Abr/2026 a Jun/2026],
    [Defesa do Pré-Projeto], [Jun/2026],
    [Implementação de NavMeshes e Otimização 3D], [Jul/2026 a Ago/2026],
    [Otimização de Concorrência e Testes de Estresse], [Ago/2026],
    [Implementações Específicas (D\* Lite, Busca Bidirecional, Lazy Theta\*)], [Ago/2026 a Set/2026],
    [Coleta Automatizada de Métricas e Dados], [Set/2026 a Out/2026],
    [Análise Estatística e Visual dos Resultados], [Out/2026 a Nov/2026],
    [Redação da Monografia Final], [Out/2026 a Nov/2026],
    [Revisão e Entrega Final], [Nov/2026],
    [Defesa do TCC], [Dez/2026],
    table.hline(y: 17, stroke: 1pt)
  )
  #v(0.5em)
  #text(size: 10pt)[Fonte: Elaborado pelo autor (2026).]
]

// =======================================================
// ELEMENTOS PÓS-TEXTUAIS
// =======================================================

#pagebreak()

// 1. Referências
#align(center)[
  #text(weight: "bold", size: 12pt)[REFERÊNCIAS]
  #v(1.5em)
]

#bibliography("referencias.bib", style: "associacao-brasileira-de-normas-tecnicas.csl", title: none)