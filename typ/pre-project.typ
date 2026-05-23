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
    "A*": "A-Star",
    "API": "Application Programming Interface",
    "IFCG": "Instituto Federal Catarinense/Computação Gráfica",
    "JPS": "Jump Point Search",
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
/*
*1º Parágrafo (Contextualização e Fundamentação).*
Introduza a evolução da inteligência artificial aplicada à busca de caminhos (pathfinding). Utilize Russell e Norvig (2013) para definir algoritmos de busca clássicos e emende com Pardede et al. (2022) para contextualizar o avanço e a aplicação crítica dessas técnicas no desenvolvimento de ambientes interativos e jogos.
*/

/*
*2º Parágrafo (O Problema e a Complexidade).*
Disserte sobre o salto de complexidade ao migrar do 2D para o 3D. Apresente a "lacuna" onde algoritmos costumam ser testados em ambientes isolados. Apoie-se em Gurung (2019) para falar sobre malhas de navegação (NavMeshes) e em Smołka et al. (2019) para explicar as instabilidades e necessidades de adaptação (como as falhas matemáticas e funções de smoothing) em engines 3D reais.
*/

/*
*3º Parágrafo (A Proposta).*
Declare o objetivo central do estudo: uma análise estatística e comparativa focada em métricas quantitativas (como tempo de execução, uso de memória e overheads), desenvolvendo uma solução construída do zero.
*/

/*
*4º Parágrafo (Estado da Arte e Fronteira).*
Referencie trabalhos recentes para mostrar que seu estudo está atualizado. Cite Madushanka e Madushanka (2026) para introduzir a relevância do processamento multithread em ambientes dinâmicos, e Nobes et al. (2022) para demonstrar que a expansão do Jump Point Search (JPS) para três dimensões é um tópico de pesquisa ativo e de alto interesse.
*/

= JUSTIFICATIVA
Com este capítulo, pretende-se justificar a relevância e a necessidade do estudo proposto, destacando a importância de uma análise estatística detalhada dos algoritmos de pathfinding em malhas 3D, especialmente considerando as complexidades e desafios dos ambientes reais.

Na área de algoritmos de _pathfinding_, a maioria dos estudos se concentra em topologias 2D ou não geométricas e em cenários ideais, onde as condições são controladas e otimizadas para destacar as vantagens de cada algoritmo. No entanto, a transição para ambientes 3D introduz uma série de desafios adicionais, como a complexidade da geometria, a necessidade de lidar com obstáculos tridimensionais e a gestão de recursos computacionais. A falta de análises estatísticas detalhadas sob condições adversas limita a compreensão real do desempenho desses algoritmos em situações práticas, onde otimizações matemáticas e técnicas avançadas podem ter um impacto significativo.

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

A escolha do C++20 também se justifica pela disponibilidade de bibliotecas e frameworks que facilitam a implementação de estruturas de dados complexas, renderização gráfica e multithreading, além de permitir uma integração eficiente com APIs gráficas como OpenGL.

Enquanto a implementação da infraestrutura gráfica e dos algoritmos de pathfinding foi realizada do zero, a escolha do C++20 garantiu um ambiente de desenvolvimento robusto e flexível, permitindo a aplicação de técnicas avançadas de otimização e controle total sobre os recursos computacionais utilizados durante os testes.

==== Estruturas de Dados
A implementação de algoritmos de pathfinding em malhas 3D requer o uso de estruturas de dados eficientes para representar grafos, filas de prioridade e outras estruturas auxiliares. Para isso, foi utilizada a biblioteca padrão do C++20, a STL (Standard Template Library), que oferece uma variedade de contêineres e algoritmos otimizados para manipulação de dados. 

A escolha de estruturas de dados adequadas é crucial para garantir o desempenho dos algoritmos, especialmente em ambientes tridimensionais onde a complexidade pode aumentar significativamente. Por isso foram utilizadas estruturas como vetores, mapas de _hash_ e filas de prioridade para representar os grafos e gerenciar os nós durante a execução dos algoritmos de busca.

==== Funções _Lambda_
A introdução de funções _lambda_ em C++11 e suas melhorias contínuas nas versões subsequentes, incluindo C++20, proporcionaram uma maneira mais concisa de definir funções anônimas. No contexto deste estudo, as funções _lambda_ foram amplamente utilizadas. 

Por definição, uma função anônima é uma função "sem nome", que pode ser definida e utilizada diretamente no local onde é necessária. Essas funções são particularmente úteis para operações que exigem uma função de curto prazo, como a definição de heurísticas em algoritmos de busca ou a implementação de callbacks para eventos específicos durante a renderização ou execução dos algoritmos.

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

O padrão _Composite_ @gamma1994design foi utilizado para representar a hierarquia de objetos na infraestrutura gráfica, permitindo que objetos complexos sejam tratados de forma uniforme, e na representação de grafos, onde grafos direcionados e não direcionados podem ser manipulados de maneira consistente. Neste padrão, objetos compostos (como grafos ou cenas gráficas) e objetos individuais (como nós ou entidades gráficas) são tratados de forma uniforme, com a introdução de um parente comum que define a interface para ambos. Isso facilita a manipulação de estruturas complexas e a implementação de algoritmos de pathfinding que podem operar em diferentes tipos de grafos ou cenários gráficos.

Na estrutura gráfica, também, foi utilizado o padrão _Singleton_ @gamma1994design. Este padrão garante que uma classe tenha apenas uma instância e fornece um ponto global de acesso a essa instância, garantindo um controle centralizado de recursos.

== Teoria dos Grafos
Uma vez que os algoritmos de pathfinding operam sobre estruturas de grafos para encontrar caminhos entre nós, o estudo da teoria dos grafos é a base fundamental deste experimento. A teoria dos grafos fornece as ferramentas e conceitos necessários para representar e manipular essas estruturas, permitindo a implementação eficiente dos algoritmos de busca.

Segundo #cite(<rodacki_grafos>, form: "prose"), um grafo é uma estrutura de dados composta por um conjunto de vértices (ou nós) e um conjunto de arestas (ou ligações) que conectam esses vértices. Os grafos podem ser direcionados, onde as arestas têm uma direção específica, ou não direcionados, onde as arestas não possuem direção. A representação de grafos pode ser feita de diversas formas, como listas de adjacência, matrizes de adjacência ou listas de arestas, cada uma com suas vantagens e desvantagens em termos de eficiência e uso de memória.

=== Definição e Propriedades dos Grafos
=== Grafos Direcionados e Não Direcionados
=== MST (_Minimum Spanning Tree_)

== Computação Gráfica
Por causa da necessidade de controle total sobre a infraestrutura gráfica e a implementação dos algoritmos, optou-se por desenvolver uma engine gráfica do zero, denominada IFCG#footnote[Disponível em: #link("https://github.com/andrevbastos/IFCG"). Acesso em: 22 mai. 2026.] (Instituto Federal Catarinense/Computação Gráfica). Esta decisão foi motivada pela necessidade de um ambiente de teste personalizado, que permita a coleta de dados em condições controladas e a aplicação de otimizações específicas para os algoritmos de pathfinding.

=== OpenGL API
O OpenGL é uma API de gráficos 3D amplamente utilizada para renderização de gráficos em tempo real @learnopengl. No desenvolvimento da infraestrutura gráfica para este estudo, o OpenGL foi escolhido por sua flexibilidade, desempenho e ampla adoção na indústria de jogos e simulações.  A utilização do OpenGL também facilita a implementação de técnicas avançadas de renderização e otimização, garantindo que os testes sejam realizados em um ambiente gráfico realista.

==== Malhas 
As malhas são uma representação comum de superfícies em computação gráfica, onde uma superfície é representada por um conjunto de vértices conectados por arestas e faces. No contexto deste estudo, as malhas serão utilizadas para representar os cenários de teste em que os algoritmos de pathfinding serão executados. 

Cada conjunto de vértices e arestas diferentes são armazenados em _buffers_ denominados VBO (Vertex Buffer Object) e EBO (Element Buffer Object), respectivamente, que são gerenciados pela GPU para renderização eficiente. Cada um desses _buffers_ é associado a um VAO (Vertex Array Object), que encapsula o estado necessário para renderizar a malha, incluindo as ligações dos _buffers_ e as configurações de atributos de vértice.

O conhecimento detalhado do funcionamento de cada buffer se prova essencial, quando consideramos a forma que o OpenGL lida com a renderização de malhas e troca de dados entre CPU e GPU. Uma vez que o OpenGL tem grandes problemas para lidar com múltiplas _threads_, o gerenciamento eficiente dos _buffers_ e a minimização de operações de troca de dados entre CPU e GPU são cruciais para garantir o desempenho dos algoritmos de pathfinding em ambientes tridimensionais.

==== Programação Orientada a Eventos e Funções de _Callback_
Embora o OpenGL seja estritamente uma API de renderização, sem conhecimento nativo sobre o sistema operacional, janelas ou periféricos de entrada, a infraestrutura gráfica desenvolvida (IFCG) utiliza a biblioteca GLFW para o gerenciamento da janela e a criação do contexto gráfico. Essa integração permite implementar um modelo de programação orientada a eventos, onde o fluxo de execução é guiado por interações externas, como atualizações do sistema e entradas do usuário.

As funções de _callback_ fornecidas pela API do GLFW foram implementadas na camada de gerenciamento da _engine_ para interceptar eventos de teclado e mouse, servindo como uma ponte de comunicação com o sistema de renderização. Isso permite criar um ambiente de teste interativo e responsivo, onde as interações do usuário ditam de forma dinâmica as atualizações do cenário e os disparos de execução dos algoritmos de pathfinding em tempo real.

==== A Máquina de Estados e o Contexto OpenGL
Para lidar com a renderização em si, o OpenGL opera como uma vasta máquina de estados. Todas as configurações e referências de dados ficam armazenadas no que é chamado de Contexto OpenGL (fornecido e gerenciado pelo GLFW). Dessa forma, para renderizar uma malha, é necessário configurar o estado da máquina de acordo com as características do objeto — como a vinculação dos _buffers_ VBO e EBO e a definição dos atributos de vértice — antes de emitir os comandos de desenho para a GPU.

Ademais, cada alteração na máquina de estados exige comunicação direta com o _driver_ de vídeo. Como mudanças excessivas de estado geram alto custo de processamento (_overhead_), o gerenciamento eficiente dos _buffers_ procura minimizar as trocas de estado e agrupar comandos sempre que possível, otimizando o tráfego de dados entre a CPU e a GPU.

==== Concorrência e Isolamento de _Threads_
Essa arquitetura baseada em contexto de estado impõe restrições rígidas à implementação de concorrência. O contexto do OpenGL é estritamente atrelado à _thread_ em que foi ativado, tipicamente a _thread_ principal. Tentativas de acessar ou modificar o estado da API gráfica a partir de múltiplas _threads_ simultaneamente causam violações de acesso à memória, resultando em falhas críticas de limite de endereço, como erros SIGSEGV.

== Geração de Cenários de Teste
Para garantir a diversidade e complexidade dos cenários de teste, é necessário implementar algoritmos de geração procedural de terrenos. Esses algoritmos permitem criar malhas 3D complexas e variadas, simulando diferentes tipos de ambientes que os algoritmos de pathfinding podem encontrar em situações reais.

A geração procedural é uma técnica utilizada para criar conteúdo de forma automática, utilizando algoritmos que produzem resultados variados e complexos a partir de um conjunto de regras ou parâmetros. No contexto deste estudo, a geração procedural será aplicada para criar terrenos que servirão como cenários de teste para os algoritmos de pathfinding.

=== Labirintos
Temos como difinição que labirintos são estruturas complexas compostas por caminhos interconectados, onde o objetivo é encontrar uma rota do ponto de partida até um destino específico. A geração de labirintos pode ser realizada utilizando diversos algoritmos. Para este estudo, foi utilizado o algoritmo de Kruskal @rodacki_grafos, que é um método eficiente para gerar labirintos perfeitos, ou seja, labirintos sem ciclos, onde existe apenas um caminho entre quaisquer dois pontos. 

Inicialmente, para gerar labirintos com o algoritmo de Kruskal, é construído um grafo em formato de grade. Neste grafo, cada célula do labirinto é representada por um vértice, e as possíveis conexões entre as células são representadas por arestas de pesos aleatórios. 

O algoritmo de Kruskal é então aplicado para construir uma árvore geradora mínima (MST) a partir desse grafo, selecionando as arestas de menor peso e garantindo que não sejam formados ciclos. O resultado é um labirinto perfeito, onde cada célula tem um caminho que a conecta a qualquer outra célula, criando um caminho único entre o ponto de partida e o destino.

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
  #image("./images/pixel_to_vertex.png", width: 90%)
  #v(0.5em)
  #text(size: 10pt)[Fonte: Elaborado pelo autor.]
] \

É importante ressaltar que os valores de cor ($r, g, b$) de uma imagem em escala de cinza variam igualmente de 0 a 255. Para evitar que as variações de altura no cenário 3D sejam desproporcionais às distâncias horizontais, o valor do pixel precisa ser normalizado e escalonado. Considerando $v$ como o valor RGB do pixel e $H$ como a altura máxima desejada para o terreno, a elevação $h$ de cada vértice é calculada pela fórmula:

\
$ h = (v / 255) * H $ \

Dessa forma, um pixel totalmente preto ($v = 0$) resultará em uma altura de 0, enquanto um pixel totalmente branco ($v = 255$) atingirá a altura máxima estipulada ($H$), permitindo um controle preciso sobre a amplitude do relevo gerado.

Por fim, são criadas faces conectando cada vértice com seus vizinhos diretos, formando uma malha de triângulos que representa a superfície do terreno. Essa malha pode então ser utilizada como cenário de teste para os algoritmos de pathfinding, permitindo avaliar seu desempenho em ambientes tridimensionais complexos.

\
#figure(
  caption: [Exemplo de malha gerada a partir de um mapa de altura],
  supplement: "Figura",
)[
  #image("./images/heightmap_to_mesh.png", width: 50%)
  #v(0.5em)
  #text(size: 10pt)[Fonte: Elaborado pelo autor.]
] \

=== Geração de Ruídos
Utilizar mapas de altura foi uma grande vantagem para a geração de cenários realistas, mas é ineficiente procurar imagens pré-existentes para cada cenário de teste que se deseja criar. Para isso, é indispensável a implementação de algoritmos de geração de ruídos.

Um ruído é uma função matemática que gera valores pseudoaleatórios, mas de forma controlada, para criar padrões que se assemelham a fenômenos naturais. Existem diversos tipos de ruídos, como o ruído Perlin, o ruído Simplex e o ruído de valor, cada um com suas características e aplicações específicas. Porém, para essa pesquisa, o foco será no ruído Perlin, devido à sua capacidade de gerar padrões suaves e naturais, ideal para simular terrenos realistas.

O ruído Perlin é um algoritmo de geração de ruído procedural que é amplamente utilizado para criar texturas e terrenos realistas em gráficos 3D. Ele foi desenvolvido por #cite(<perlin1985image>, form: "prose") e é conhecido por produzir padrões de ruído suave e natural, o que o torna ideal para simular superfícies como montanhas, nuvens e oceanos. Com isso em mente, podemos utilizar desse algoritmo para gerar nossos próprios heightmaps, sem precisar recorrer a imagens pré-existentes. Isso nos dá controle total sobre a geração dos cenários de teste, permitindo criar uma variedade de terrenos com diferentes características e desafios para os algoritmos de pathfinding.

== Algoritmos de Busca Heurística
=== Dijkstra
=== Heurísticas
=== A\*
=== Jump Point Search (JPS)
=== Theta\*

== Concorrência e Paralelismo
=== _Multithreading_
=== Monitores
=== Fila Multinível e _Thread Pool_

= METODOLOGIA
Esta seção detalha a metodologia adotada para a realização da pesquisa, explicando como os algoritmos de pathfinding e a infraestrutura gráfica serão implementados e testados. Este projeto foi conduzido como uma pesquisa experimental de caráter quantitativo, sendo que a implementação da infraestrutura gráfica e dos algoritmos de pathfinding ocorreu em paralelo à coleta e análise de dados. A abordagem experimental permitirá a avaliação do desempenho dos algoritmos em condições controladas, enquanto a construção da engine do zero garantirá um ambiente de teste personalizado e otimizado para as necessidades específicas deste estudo.

== Arquitetura do Motor Gráfico (IFCG)
=== Aplicação de conceitos
=== Estrutura de Renderização e Gerenciamento de Recursos
A implementação do IFCG foi estruturada utilizando os princípios da programação orientada a objetos, para facilitar a organização do código, a reutilização de componentes e a manutenção do sistema. Além disso, foram aplicados diversos padrões de projeto para garantir a modularidade, flexibilidade e escalabilidade do código.

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

O padrão _Singleton_ foi aplicado na criação de instâncias do motor gráfico principal, garantindo um controle centralizado sobre os recursos gráficos e a renderização. Isso evita conflitos e mantém a consistência do ambiente de renderização, permitindo que diferentes partes do sistema acessem o motor gráfico de forma segura e coordenada.

=== Motor de Renderização e seus Componentes

== Implementação da Estrutura de Grafos
=== Representação de Grafos Direcionados e Não Direcionados
=== Implementação de Algoritmos de Busca em Grafos
=== Otimizações e Estruturas de Dados Auxiliares

== Geração e Processamento dos Cenários
=== Geração de Malhas 3D Complexas
=== Processamento de Malhas e Extração de Grafos
=== Configuração de Cenários de Teste e Parâmetros

== Implementação dos Algoritmos e Sistema Concorrente
=== Implementação de Algoritmos de Pathfinding
=== Adaptação para Ambientes 3D
=== Implementação de Multithreading e Testes de Estresse
Para viabilizar a arquitetura da IFCG sem comprometer o desempenho, o ciclo principal de renderização e todas as chamadas ao OpenGL foram isolados na _thread_ principal. Simultaneamente, a execução pesada dos algoritmos de pathfinding ocorre em _threads_ operárias concorrentes (utilizando _jthread_). Os resultados desses cálculos são repassados à _thread_ gráfica através de mecanismos seguros de sincronização de memória, permitindo que a geometria seja atualizada e renderizada sem corromper o contexto global da GPU.

== Desenho Experimental e Coleta de Dados
=== Configuração dos Testes e Métricas Coletadas
=== Execução dos Testes e Registro dos Resultados
=== Análise Estatística e Visual dos Resultados

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