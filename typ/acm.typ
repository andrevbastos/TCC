#let acm_sigconf(
  title: "",
  short-title: none,
  authors: (),
  abstract: none,
  ccs-concepts: (),
  keywords: (),
  body
) = {
  // Configuração Base do Documento
  set document(title: if type(title) == content { title.text } else { title })
  
  // A ACM utiliza o padrão US Letter
  set page(
    paper: "us-letter",
    margin: (x: 4.5 * 12pt, top: 4.5 * 12pt, bottom: 6 * 12pt),
    // Cabeçalhos dinâmicos e alternados (Padrão ACM Sigconf)
    header: context {
      let page-num = here().page()
      if page-num == 1 { return none }
      
      if calc.even(page-num) {
        // Páginas pares: Nome dos autores intercalados
        let author-names = authors.map(a => a.name).join(", ", last: " e ")
        align(left)[#text(8pt, font: "Libertinus Serif", style: "italic")[#author-names]]
      } else {
        // Páginas ímpares: Título curto do artigo
        let display-title = if short-title != none { short-title } else { title }
        align(right)[#text(8pt, font: "Libertinus Serif", style: "italic")[#display-title]]
      }
    },
    // Numeração de páginas centralizada no rodapé
    footer: context {
      align(center)[#text(9pt, font: "Libertinus Serif")[#here().page()]]
    }
  )

  // Fonte Libertinus Serif (nativa do Typst, elimina os avisos de falta de fonte)
  set text(font: "Libertinus Serif", size: 9pt)

  // Espaçamento e recuo de parágrafos atualizados para a sintaxe do Typst 0.13+
  set par(justify: true, leading: 0.5em, first-line-indent: 1em, spacing: 0.65em)

  // Numeração e Formatação de Cabeçalhos (até o nível 3)
  set heading(numbering: "1.1.1")
  show heading: it => {
    v(0.5em)
    set text(font: "Libertinus Serif")
    let top-spacing = 1em
    let bottom-spacing = 0.5em
    let font-size = 9pt
    let font-weight = "medium"

    if it.level == 1 {
      font-size = 12pt
      top-spacing = 1.5em
      font-weight = "bold"
    } else if it.level == 2 {
      font-size = 11pt
      font-weight = "bold"
    } else if it.level == 3 {
      font-size = 10pt
      font-weight = "bold"
    }

    set block(above: top-spacing, below: bottom-spacing)
    text(size: font-size, weight: font-weight)[
      #if it.numbering != none and it.level <= 3 {
        context counter(heading).display(it.numbering)
        h(0.5em)
      }
      #if it.level == 1 { upper(it.body) } else { it.body }
    ]
  }

  // Regras de Posição de Legendas (Tabelas acima, Figuras abaixo)
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: image): set figure.caption(position: bottom)
  show figure.caption: set text(size: 8pt)

  // Elementos Iniciais: Título principal ocupando a largura total
  align(center)[
    #block(text(18pt, weight: "bold", title))
    #v(1.5em)
  ]

  // Grid de Autores: Ocupa a largura total da página antes das colunas do artigo
  if authors.len() > 0 {
    align(center)[
      #grid(
        columns: calc.min(authors.len(), 3),
        gutter: 1.5em,
        ..authors.map(author => [
          #text(11pt, weight: "regular")[#author.name]\
          #if "affiliation" in author [#text(9pt, style: "italic")[#author.affiliation]\ ]
          #if "email" in author [#text(9pt)[#author.email]]
        ])
      )
    ]
    v(2em)
  }

  // Ativação do layout em duas colunas a partir do Resumo/Abstract
  show: columns.with(2, gutter: 2 * 12pt)

  // Bloco do Resumo alinhado à esquerda na coluna inicial
  if abstract != none {
    block(width: 100%, below: 1em)[
      #text(weight: "bold", size: 9pt)[RESUMO] \
      #v(0.5em)
      #abstract
    ]
  }

  // Formatação hierárquica para CCS Concepts usando setas estruturadas
  if ccs-concepts.len() > 0 {
    block(width: 100%, below: 1em)[
      #text(weight: "bold")[CCS Concepts: ]
      #list(..ccs-concepts.map(concept => {
        let parts = concept.split("~")
        if parts.len() > 1 {
          [#text(weight: "bold")[#parts.at(0).trim()] $arrow.r$ #parts.slice(1).join(" ")]
        } else {
          concept
        }
      }))
    ]
  }

  if keywords.len() > 0 {
    block(width: 100%, below: 1.5em)[
      #text(weight: "bold")[Keywords: ]
      #keywords.join(", ")
    ]
  }

  body
}

// Utilitários para replicar as linhas horizontais do padrão booktabs
#let toprule = table.hline(stroke: 1pt)
#let midrule = table.hline(stroke: 0.5pt)
#let bottomrule = table.hline(stroke: 1pt)

// INSTANCIAÇÃO DO MODELO COM O CONTEÚDO DO ARTIGO
#show: acm_sigconf.with(
  title: "Paralelismo para aquisição de dados estatísticos em C++20: Um estudo de caso com algoritmos de pathfinding em malhas 3D",
  short-title: "Algoritmos de Pathfinding",
  authors: (
    (
      name: "André Vitor Bastos de Macêdo",
      affiliation: [Instituto Federal de Educação, Ciência e Tecnologia Catarinense \ Campus Blumenau],
      email: "andre.macedo@estudantes.ifc.edu.br"
    ),
    (
      name: "Ricardo de la Rocha Ladeira",
      affiliation: [Instituto Federal de Educação, Ciência e Tecnologia Catarinense \ Campus Blumenau],
      email: "ricardo.ladeira@ifc.edu.br"
    )
  ),
  abstract: [
    Este documento apresenta um estudo quantitativo sobre a performance de algoritmos de busca (A\*, Jump Point Search e Theta\*) em ambientes tridimensionais. O foco está na otimização de uso de cache da CPU e na arquitetura do motor gráfico subjacente, avaliando taxas de quadros e consumo de memória durante simulações intensivas.
  ],
  ccs-concepts: (
    "Computing methodologies ~ Rendering",
    "Theory of computation ~ Shortest paths"
  ),
  keywords: (
    "Pathfinding", "A*", "C++20", "Graphics Engine", "Concorrent Programming"
  )
)


= Introdução

Ao avaliar algoritmos de _pathfinding_ (busca de caminhos) em malhas 3D densas, o processamento sequencial pode se tornar um gargalo significativo. Algoritmos como A\*, _Jump Point Search_ (JPS) e Theta\* são amplamente utilizados para encontrar o caminho mais curto entre dois pontos em um grafo, mas quando aplicados a malhas 3D complexas, o tempo de execução pode aumentar exponencialmente. Isso ocorre porque esses algoritmos precisam explorar um grande número de nós e arestas, o que pode levar a tempos de processamento inaceitáveis, especialmente em aplicações em tempo real, como jogos ou simulações.

Quando há um motor de renderização em execução, a _main thread_ (_thread_ principal) pode ficar sobrecarregada, resultando em travamentos ou quedas de desempenho. A extração dos caminhos e a construção de estruturas de dados para esses algoritmos podem consumir muitos recursos, o que torna essencial isolar a _main thread_ para garantir um desempenho adequado.

A API OpenGL, que será utilizada para renderizar as malhas 3D, é sensível a bloqueios na _main thread_. Se a _main thread_ estiver ocupada processando os algoritmos de busca, a renderização pode ser interrompida. Portanto, é crucial encontrar uma solução arquitetural que permita a execução concorrente dessas tarefas sem comprometer a responsividade da aplicação.

Este artigo é um estudo para implementar um _Task Scheduler_ @concorrency, uma solução arquitetural projetada para gerenciar o fluxo de tarefas concorrentes em C++20. Neste modelo, será implementada uma classe responsável por tarefas requisitadas pela _main thread_, garantindo que ela permaneça responsiva enquanto as tarefas de extração e construção de dados são processadas em paralelo. 

A contribuição deste trabalho inclui a implementação do _Task Scheduler_, a análise de sua eficácia em comparação com abordagens sequenciais e a demonstração de como as ferramentas modernas do C++ simplificam o gerenciamento de recursos e a segurança de memória.

= Fundamentação Teórica

Este estudo se baseia em conceitos fundamentais de algoritmos de busca em grafos, renderização gráfica e técnicas de concorrência em C++. A seguir, serão discutidos os principais tópicos relacionados a esses conceitos.

== Algoritmos de Busca em Grafos

Conforme #cite(<rodacki_grafos>, form:"prose"), um grafo é uma abstração matemática que representa relações entre objetos. Por definição, um grafo $G = (V, E)$ consiste em um conjunto de vértices, os objetos, $V$ e um conjunto de arestas $E$ que conectam pares de vértices com seus respectivos custos. Grafos podem ser representados de diversas formas, como listas de adjacências ou matrizes de adjacências, cada uma com suas vantagens e desvantagens em termos de eficiência de acesso e uso de memória. Este estudo se concentrará em grafos representados por listas de adjacência, onde uma estrutura de dados linear é usada para armazenar os vértices e suas conexões.

Por sua vez, malhas no OpenGL são compostas, de forma simplificada, por conjuntos de vértices (pontos coordenados) e índices (ligações entre os pontos) que definem sua geometria @learnopengl. As similaridades entre a representação de malhas e grafos permitem que algoritmos de busca em grafos sejam aplicados para encontrar caminhos em ambientes 3D, onde os vértices do grafo correspondem aos pontos na malha e as arestas representam as conexões entre esses pontos.

Algoritmos de busca em grafos, como A\*, JPS e Theta\*, são amplamente utilizados para encontrar o caminho mais curto entre dois pontos em um grafo. Esses algoritmos precisam expandir e avaliar milhares de vértices e arestas, o que pode levar a tempos de processamento inaceitáveis, especialmente em aplicações em tempo real. A complexidade de tempo desses algoritmos, frequentemente em torno de $cal(O)(E + V log V)$ dependendo da implementação da fila de prioridade, resulta em um custo de processamento intenso em malhas densas.

== Renderização e Responsividade

Este estudo fará uso da OpenGL API @learnopengl para a renderização das malhas 3D. O loop de renderização típico envolve a atualização do estado da aplicação, o processamento de eventos e a renderização dos gráficos. A OpenGL é sensível a bloqueios na _main thread_, o que significa que se a _main thread_ estiver ocupada processando os algoritmos de busca, a renderização pode ser interrompida, resultando em travamentos ou quedas de desempenho.

Para a implementação do motor gráfico será utilizada a biblioteca GLFW, que fornece uma interface de criação de janelas, contextos OpenGL e gerenciamento de eventos de entrada. O loop de eventos do GLFW é projetado para trabalhar como uma máquina de estado, onde a _main thread_ é responsável por processar eventos e renderizar gráficos. Se a _main thread_ estiver bloqueada por tarefas de processamento intensivo, como a execução de algoritmos de busca em grafos, o loop de eventos e de desenho ficará bloqueado, o que compromete a responsividade geral do sistema.

Se a _main thread_ assumir o custo computacional da extração de caminhos do tópico anterior, o loop de eventos e de desenho ficará bloqueado. Isso derruba o framerate (FPS) da aplicação, gera engasgos (stuttering) e compromete a responsividade geral do sistema.

Com isso, é essencial encontrar uma solução arquitetural que permita a execução concorrente dessas tarefas sem comprometer a responsividade da aplicação. A implementação de um _Task Scheduler_ @concorrency em C++20 é uma abordagem promissora para gerenciar o fluxo de tarefas concorrentes, permitindo que a _main thread_ permaneça responsiva enquanto as tarefas de extração e construção de dados são processadas em paralelo.

== Monitor

Conforme explica #cite(<ladeira_sincronizacao>, form: "prose"), o padrão Monitor é uma implementação de alto nível para controle de sincronização em programação paralela. Ele é um tipo abstrato de dados projetado para gerenciar o acesso a recursos compartilhados, garantindo que apenas uma thread possa acessar um recurso crítico por vez, evitando condições de corrida e garantindo a integridade dos dados.

Um monitor é comumente associado a programação orientada a objetos, onde o monitor encapsula tanto os dados quanto os métodos que operam sobre esses dados. Ele utiliza mecanismos de bloqueio (_mutexes_) para garantir exclusão mútua e condições de espera (_condition variables_) para coordenar a execução das threads. O monitor é uma construção arquitetural que garante exclusão mútua por design, o que o torna uma escolha ideal para gerenciar o acesso concorrente a recursos compartilhados, como os dados da malha/grafo neste estudo.

A adoção do padrão Monitor visa prevenir condições de corrida (_race conditions_) entre as rotinas assíncronas de busca e a _main thread_. Ao encapsular o estado compartilhado e fornecer métodos seguros para as threads acessarem esses dados, o monitor ajuda a garantir que as operações de busca em grafos possam ser realizadas em paralelo eficientemente.

== Agendamento de Tarefas (_Task Scheduler_)

Um _Task Scheduler_ é um componente de software responsável por gerenciar a execução de tarefas concorrentes. Ele mantém uma fila de tarefas pendentes e um conjunto de threads (_thread pool_) que processam essas tarefas em paralelo @ladeira_threads @concorrency. O _Task Scheduler_ é projetado para otimizar o uso dos recursos do sistema, garantindo que as tarefas sejam executadas de forma eficiente e que a _main thread_ permaneça responsiva.

Este estudo implementará um _Task Scheduler_ que permitirá que a _main thread_ delegue tarefas de extração e construção de dados para threads trabalhadoras (_worker threads_) em paralelo, garantindo que a renderização do OpenGL não seja bloqueada. O _Task Scheduler_ será responsável por gerenciar a fila de tarefas, atribuir tarefas às threads disponíveis e garantir que as tarefas sejam concluídas com êxito.

Para que a _main thread_ possa delegar tarefas para o _Task Scheduler_, será implementada uma estrutura de dados que armazenará as tarefas pendentes, juntamente com mecanismos de sincronização para garantir que as threads trabalhadoras possam acessar essas tarefas de forma segura. O _Task Scheduler_ também precisará lidar com a coordenação entre as threads, garantindo que as tarefas sejam processadas em ordem e que os resultados sejam retornados à _main thread_ de maneira eficiente.

=== Filas multinível

Em tempos, certas tarefas podem ser mais importantes do que outras, exigindo uma abordagem de agendamento que leve em consideração a prioridade das tarefas. Para isso, o _Task Scheduler_ implementará filas multinível, onde as tarefas serão categorizadas em diferentes níveis de prioridade. As tarefas de alta prioridade serão aquelas que outras tarefas dependem, enquanto as tarefas de média prioridade incluirão a construção da estrutura de dados e os algoritmos de busca. As tarefas de baixa prioridade serão aquelas relacionadas à exportação dos dados ou outras operações que não impactam diretamente a execução dos algoritmos de busca.

== Concorrência Moderna com C++20

=== Gerenciamento de Threads

A linguagem C++20 introduziu várias melhorias para a programação concorrente, incluindo a classe `std::jthread`, que é uma extensão da classe `std::thread` com suporte integrado para cancelamento de threads. O uso de `std::jthread` permite que as threads sejam encerradas de forma limpa e segura, evitando problemas comuns como deadlocks e condições de corrida. 

Essa classe utiliza de métodos RAII (_Resource Aquisition is Initialization_), que é uma técnica de gerenciamento de recursos que garante que os recursos sejam adquiridos e liberados de forma segura, mesmo em casos de exceção. Com `std::jthread`, as threads são automaticamente unidas (_joined_) em chamadas de destruição. A união de threads é o processo onde a _thread_ principal espera que a thread trabalhadora termine sua execução antes de continuar, garantindo que os recursos sejam liberados adequadamente. 

Ou seja, quando um objeto `std::jthread` é destruído, ele automaticamente chama `join()` na thread associada, garantindo que a thread seja concluída antes de liberar os recursos. Isso garante que as threads sejam encerradas de forma segura, evitando problemas como threads zumbis ou recursos não liberados.

Em seu construtor, as `std::jthread` recebem uma função lambda que encapsula a lógica de execução da thread trabalhadora. Funções lambda são funções anônimas que podem capturar variáveis do escopo onde foram definidas, o que facilita a passagem de dados para as threads trabalhadoras. Quando uma `std::jthread` é instanciada, ela inicia a execução da função lambda em uma nova thread. 

=== Tokens de Parada

O `std::stop_token` é um mecanismo que permite sinalizar a uma thread que ela deve parar sua execução. Isso é especialmente útil para garantir que as threads possam ser encerradas de forma cooperativa, evitando bloqueios. Quando uma `std::jthread` é instanciada sabemos que ela recebe uma função lambda, porém caso essa função lambda tenha um _loop_ interno e precise ser interrompida antes de sua conclusão, o `std::stop_token` pode ser utilizado para sinalizar a thread para que ela pare sua execução de forma segura. 

No seu loop, a função lambda pode verificar periodicamente o estado do `std::stop_token` para determinar se deve continuar executando ou encerrar a thread. Isso permite que as threads sejam encerradas de forma cooperativa, evitando bloqueios e garantindo que os recursos sejam liberados adequadamente.

Naturalmente, a função deve estar projetada para receber um `std::stop_token` como argumento para que o loop interno possa verificar o seu estado. Outra vantagem do uso de `std::jthread` é que ele integra uma injeção automática de um `std::stop_token` para a função lambda caso não seja passado explicitamente e ele detecte que a função lambda tem um parâmetro do tipo `std::stop_token`. Ou seja, não é necessário instanciar e passar explicitamente um `std::stop_token` para a função lambda, pois ele é automaticamente injetado pela `std::jthread`. 

=== Variáveis Condicionais

O `std::condition_variable_any` é uma ferramenta de sincronização que permite que as threads esperem por condições específicas, facilitando a coordenação entre as threads trabalhadoras e a _main thread_. Ele é utilizado para implementar a lógica de espera e notificação entre as threads. Por exemplo, quando as _threads_ trabalhadoras são criadas, todas são colocadas em espera usando `std::condition_variable_any`, aguardando que a _main thread_ adicione uma tarefa na fila. Isso sinaliza a `std::condition_variable_any` para que acorde uma das threads trabalhadoras para processar a tarefa. 

As threads trabalhadoras, por sua vez, também podem notificar a _main thread_ quando uma tarefa é concluída, permitindo que ela atualize o estado do sistema ou inicie novas tarefas conforme necessário. O uso de `std::condition_variable_any` é crucial para garantir que as threads possam coordenar suas ações de forma eficiente, evitando bloqueios e garantindo que as tarefas sejam processadas em ordem.

== Segurança de Memória e Compartilhamento de Estado

O uso de ponteiros brutos do C++ em um ambiente de programação concorrente pode levar a problemas de segurança de memória gravíssimos, como condições de corrida e falhas de segmentação (SIGSEGV). Uma vez que as threads trabalhadoras operam sobre os dados compartilhados, é crucial garantir que esses dados permaneçam válidos durante toda a execução das tarefas. 

Para isso, a implementação do _TaskMaster_ banirá o uso de ponteiros brutos e adotará exclusivamente referências e smart pointers (como `std::shared_ptr` ou `std::unique_ptr`) para gerenciar o acesso aos dados compartilhados.

Referências são uma forma segura de acessar um objeto em memória sem a necessidade de lidar com a alocação e desalocação manual de memória, o que reduz significativamente o risco de erros de memória. Diferente de cópias, as referências não criam uma nova instância do objeto, mas sim apontam para o mesmo objeto em memória. Em contradição à ponteiros brutos, as referências não podem ser nulas, o que elimina a possibilidade de acessar um ponteiro nulo e causar uma falha de segmentação.

Smart pointers, por outro lado, são objetos que gerenciam automaticamente a vida útil de um recurso, como um objeto alocado dinamicamente. Um `std::shared_ptr` permite que múltiplos objetos compartilhem a propriedade de um recurso, garantindo que ele seja destruído apenas quando a última referência for liberada. Enquanto um `std::unique_ptr` garante que apenas um objeto tenha a propriedade de um recurso. 

Ao utilizar referências e smart pointers, o _TaskMaster_ garante que o grafo compartilhado entre as threads trabalhadoras permaneça válido durante toda a execução das tarefas e as malhas 3D sejam processadas de forma segura, evitando erros de memória e garantindo a integridade dos dados.

= Metodologia

Para avaliar o impacto do processamento paralelo na execução de algoritmos de _pathfinding_ em malhas 3D, desenvolveu-se uma arquitetura baseada no padrão _Task Scheduler_. A metodologia adotada divide-se na implementação estrutural do escalonador, na instrumentação para coleta de dados de desempenho e na definição de cenários de teste isolados.

== Ambiente de Teste

O hardware utilizado para os testes consiste em um processador de 12ª geração Intel Core i5-1235U (12 _threads_, com frequência máxima de 4.40 GHz) e 16 GB de memória RAM. A aceleração gráfica foi provida por uma GPU integrada Intel Iris Xe Graphics.

O sistema operacional utilizado foi Arch Linux (Kernel 6.15.9). Todo o código-fonte foi desenvolvido obedecendo estritamente ao padrão C++20 e compilado utilizando a coleção de compiladores GNU (GCC). Para avaliar a máxima performance dos algoritmos, o binário final foi gerado utilizando a flag de otimização de tempo de execução `-O3` (`Release`), juntamente com diretrizes rigorosas de compilação (`-Wall`, `-Wextra`, `-Wpedantic` e `-Werror`).

A renderização e o controle do _loop_ de eventos foram construídos utilizando a API nativa do OpenGL versão 4.6 em conjunto com a biblioteca de gerenciamento de janelas GLFW versão 3.4. As operações matemáticas em matrizes e vetores tridimensionais foram realizadas através da biblioteca GLM (_OpenGL Mathematics_) versão 1.0.3. O gerenciamento de dependências e a orquestração do _build_ foram realizados por meio da ferramenta CMake.

== Instrumentação e Coleta de Dados

Para coletar e organizar os resultados de desempenho, foi desenvolvido um _wrapper_ que estrutura os dados de forma hierárquica. O objetivo principal deste componente é facilitar a exportação e análise das métricas coletadas, mantendo o código de teste organizado e os resultados fáceis de interpretar.

A estrutura utilizada para o armazenamento em memória é `std::map<std::string, std::map<std::string, std::vector<double>>>`. Nela, o primeiro nível associa o nome do algoritmo (como `A*` ou `JPS`) a um conjunto de métricas. O segundo nível vincula cada métrica (como "Tempo de Execução" ou "Custo do Caminho") a um vetor que armazena os valores obtidos em cada repetição do experimento.

Embora o uso de `std::map` envolva mais alocações dinâmicas do que um vetor contíguo, essa escolha não interfere na precisão dos resultados. Isso ocorre porque o registro dos dados no módulo de instrumentação é feito apenas após a finalização da medição de dados de cada algoritmo. Assim, a abordagem prioriza a facilidade em adicionar novas métricas sem comprometer o desempenho medido nos benchmarks.

=== Dados de Desempenho Coletados

Para analisar o impacto dos algoritmos, foram selecionadas métricas que avaliam tanto a eficiência computacional quanto a qualidade da solução encontrada:

- *Tempo de Execução:* Mede o intervalo total gasto pelo algoritmo para encontrar o caminho, sendo uma métrica crítica para aplicações em tempo real.
- *Número de Nós Expandidos:* Indica o esforço computacional e a eficiência da busca. Um menor número de expansões geralmente aponta para um algoritmo mais otimizado ou com uma heurística mais precisa.
- *Custo do Caminho:* Representa a soma dos pesos das arestas que compõem o trajeto. Esta métrica permite verificar a otimalidade do algoritmo em encontrar o caminho mais curto.
- *Responsividade (FPS):* A taxa de quadros por segundo da aplicação é monitorada para observar como o processamento da busca afeta a thread principal e validar a eficácia da solução concorrente.
- *Consumo de Memória:* Mede a quantidade de memória RAM utilizada durante a execução dos algoritmos, sendo uma métrica importante para avaliar a eficiência do uso de recursos.
- *Eficiência do Cache:* Avalia a taxa de acertos e falhas no cache da CPU, fornecendo insights sobre a localidade de referência dos algoritmos e seu impacto no desempenho.

Além dessas métricas, o sistema permite registrar parâmetros de configuração do mapa (como intensidade e limite de altura), facilitando a correlação entre a complexidade do terreno e o desempenho dos algoritmos. As possíveis variações de configuração incluem:

- *Escala:* Refere-se à dimensão do mapa, que pode influenciar o tempo de execução e o número de nós expandidos.
- *Lacunaridade:* Indica a densidade de obstáculos no mapa. Mapas com alta frequência possuem mais obstáculos, o que pode impactar significativamente o desempenho dos algoritmos de busca.
- *Persistência:* Refere-se à variação de altura entre os pontos do mapa. Mapas com alta persistência apresentam mudanças abruptas de altura, o que pode aumentar a complexidade da busca e afetar o desempenho dos algoritmos.

== Pipeline de Processamento Sequencial

Para garantir a validade estatística dos resultados, o experimento foi desenhado para coletar uma base sólida de amostras em diferentes cenários de complexidade. O pipeline sequencial atua como o modelo de referência (_baseline_), onde todas as etapas de preparação e execução ocorrem de forma linear na thread principal.

O fluxo de processamento segue uma ordem rígida: para cada configuração de teste, o sistema gera o mapa de ruído, constrói a estrutura de dados do grafo e, por fim, executa os diferentes algoritmos de busca. Esse ciclo é repetido para cada amostra, garantindo que o ambiente de execução seja idêntico para todos os algoritmos comparados.

As baterias de testes foram organizadas em três eixos principais, onde cada um varia um parâmetro específico do ruído (escala, lacunaridade ou persistência) enquanto mantém os demais constantes. Cada eixo é composto por cinco níveis incrementais de complexidade, com 30 repetições para cada nível. No total, o pipeline gera 450 amostras por algoritmo, permitindo uma análise detalhada de como o desempenho escala conforme o terreno se torna mais denso ou irregular.

Embora funcional para volumes menores de dados, esta abordagem sequencial revela limitações conforme a complexidade do mapa aumenta. O custo acumulado da geração de mapas e construção de grafos na mesma thread que executa as buscas torna o tempo total de experimentação elevado, o que motiva a transição para uma arquitetura concorrente.

== Arquitetura da Solução Concorrente

Com o objetivo de isolar a thread principal e permitir que as tarefas de extração e construção de dados sejam processadas em paralelo, foi implementada uma arquitetura baseada no padrão _Task Scheduler_. Esta arquitetura é projetada para gerenciar o fluxo de tarefas concorrentes, garantindo que a _main thread_ permaneça responsiva enquanto as tarefas de extração e construção de dados são processadas em paralelo.

Para isso, foi criada uma classe `TaskMaster` que encapsula a lógica de gerenciamento de tarefas e threads. O `TaskMaster` é responsável por manter uma fila de tarefas pendentes, gerenciar um pool de threads trabalhadoras e coordenar a execução das tarefas de forma eficiente.

=== Estrutura do `TaskMaster`

Esse componente é projetado para ser o núcleo do sistema de agendamento de tarefas, gerenciando a execução concorrente das tarefas de extração e construção de dados. Ele mantém uma fila de tarefas pendentes e um conjunto de threads trabalhadoras que processam essas tarefas em paralelo.

\
#figure(
  caption: [Diagrama de classes da arquitetura do TaskMaster],
  supplement: "Figura",
)[
  #image("./images/task_master.png", width: 100%)
]\

A implementação do `TaskMaster` utiliza um conjunto de três filas de prioridade, representadas pelo `enum class Priority` com os níveis `High` (0), `Medium` (1) e `Low` (2). Essas filas são armazenadas em um `std::array` de `std::queue`, permitindo um acesso eficiente e organizado por nível de importância.

No construtor da classe, o número de threads trabalhadoras é determinado dinamicamente através de `std::thread::hardware_concurrency()`. Para evitar a saturação completa dos núcleos do processador e garantir que a _main thread_ (responsável pela renderização e interface) permaneça responsiva, o sistema reserva um núcleo, instanciando $N-1$ threads trabalhadoras. Estas threads são implementadas como objetos `std::jthread`, aproveitando o comportamento RAII para garantir que sejam finalizadas corretamente na destruição do escalonador.

Cada thread trabalhadora executa um loop contínuo que aguarda por novas tarefas utilizando uma `std::condition_variable_any`. A lógica de seleção de tarefas prioriza sempre as filas de maior importância: o trabalhador verifica sequencialmente as filas `High`, `Medium` e `Low`, extraindo a primeira tarefa disponível na fila de maior prioridade encontrada. Isso garante que tarefas críticas, como a extração de malhas para o grafo, sejam processadas antes de tarefas de menor impacto, como a exportação de dados estatísticos. 

O loop de execução é projetado para ser interrompido de forma cooperativa através do uso de `std::stop_token`, permitindo que as threads sejam encerradas de forma segura quando o escalonador for destruído ou quando uma interrupção for solicitada. 

\
#align(center)[
  ```
  workers.emplace_back([this, id](std::stop_token st) {
    while (!st.stop_requested()) {
      // Lógica de espera e execução de tarefas
    }
  });
  ```
]\

Em cara iteração, a thread trabalhadora aguarda por uma notificação indicando que uma nova tarefa foi adicionada à fila. A espera é implementada utilizando `std::condition_variable_any`, que bloqueia a thread até que uma tarefa esteja disponível ou até que uma solicitação de parada seja feita.

\
#align(center)[
  ```
  // Bloco de código para uso do lock
  {
    std::unique_lock<std::mutex> lock(mtx);
    auto stopCon = [this]{
      return 
      !taskQueues[0].empty() || 
      !taskQueues[1].empty() || 
      !taskQueues[2].empty();
    };
    if (!cv.wait(lock, st, stopCon)) return;
  ```
]

Após ser notificada, a thread trabalhadora verifica as filas de tarefas em ordem de prioridade. A primeira tarefa disponível na fila de maior prioridade é extraída e executada. Se nenhuma tarefa estiver disponível, a thread retorna ao estado de espera. Mesmo que um lock tenha sido adquirido, a função `wait` do `std::condition_variable_any` é projetada para liberar o lock enquanto a thread está bloqueada, permitindo que outras threads adicionem tarefas à fila. Quando a thread é acordada, o lock é automaticamente re-adquirido e destruído com o escopo do bloco.

\
#align(center)[
  ```
    for (int q = 0; q < 3; ++q) {
      if (!taskQueues[q].empty()) {
        task = std::move(taskQueues[q].front());
        taskQueues[q].pop();
        break;
      }
    }
  // Fim do bloco de código para uso do lock
  }

  if (task) task(st);
  ```
]\

O método `addTask` é o ponto de entrada para a submissão de tarefas. Utilizando modelos de programação (_templates_) e metaprogramação em tempo de compilação (`if constexpr`), o método é capaz de aceitar funções que recebem ou não um `std::stop_token`. Isso confere flexibilidade ao sistema, permitindo que tarefas de longa duração verifiquem periodicamente se uma interrupção foi solicitada, enquanto tarefas curtas e simples podem ser executadas sem essa complexidade adicional. Na Figura 2, observa-se como o método `addTask` emprega metaprogramação para unificar a submissão de tarefas, além de notificar a variável de condição para despertar uma thread ociosa.

O uso de metaprogramação permite que o `TaskMaster` possa lidar com uma variedade de tarefas sem exigir que todas as funções de tarefa sejam projetadas para aceitar um `std::stop_token`.

\
#align(center)[
  ```
  template <typename Func>
  void addTask(Func&& task, Priority p) {
    // Lógica de adição de tarefas, 
    // com suporte para funções que
    // aceitam ou não um std::stop_token
  }
  ```
]\

Encapsulando a tarefa, é mais fácil manter a fila de prioridade sem abstrações desnecessárias. Então, o método `addTask` verifica se a função fornecida é invocável com um `std::stop_token`. Se for, a função é usada diretamente. Caso contrário, ela é encapsulada em uma função lambda que ignora o `std::stop_token`, permitindo que tarefas simples sejam adicionadas sem a necessidade de lidar com tokens de parada.

\
#align(center)[
  ```
  std::function<void(std::stop_token)> wrappedTask;

  if constexpr (
    std::is_invocable_v<Func, std::stop_token>
  ) {
    wrappedTask = std::forward<Func>(task);
  } else {
    wrappedTask = [t = std::forward<Func>(task)]
    (std::stop_token) mutable {
      t();
    };
  }
  ```
]\

Com a função encapsulada, o método `addTask` adquire um lock para garantir acesso exclusivo às filas de tarefas e adiciona a tarefa à fila correspondente à sua prioridade. Após a adição, a variável de condição é notificada para acordar uma thread trabalhadora que esteja aguardando por novas tarefas, garantindo que a tarefa seja processada o mais rápido possível.
  
\
#align(center)[
  ```
  {
    std::lock_guard<std::mutex> lock(mtx);
    taskQueues[static_cast<size_t>(p)]
    .push(std::move(wrappedTask));
  }

  cv.notify_one();
  ```
]\

A sincronização entre as threads trabalhadoras e a thread principal é garantida por um `std::mutex`, protegendo o acesso às filas de tarefas e à variável de condição. O uso de `std::condition_variable_any` permite que as threads trabalhadoras sejam notificadas imediatamente quando uma nova tarefa é adicionada, evitando a necessidade de polling e garantindo uma resposta rápida às mudanças na fila de tarefas.

Por fim, o ciclo de vida do escalonador é encerrado de forma cooperativa através do seu destrutor (Listagem 3). O uso combinado de `notify_all` para acordar threads bloqueadas e `request_stop` do `std::jthread` garante um encerramento limpo e livre de _deadlocks_.

\
#align(center)[
```
~TaskMaster() {
  // Notifica todas as threads para acordar 
  // e verificar o estado de parada
  cv.notify_all();
  for (auto& worker : workers) {
    worker.request_stop();
  }
}
```
]\

== Controle de Recursos do Sistema Operacional

Para garantir que a execução paralela não comprometa a estabilidade do sistema ou a fluidez da interface gráfica, o `TaskMaster` adota estratégias de controle de recursos em nível de software. A principal estratégia é a afinidade implícita de threads e a limitação do pool de trabalhadores. Ao limitar o número de threads ao total de núcleos físicos menos um, reduz-se o custo de trocas de contexto (_context switching_) e a disputa por cache L3 entre os trabalhadores e o motor de renderização.

Além disso, o uso de `std::stop_token` permite um cancelamento cooperativo de tarefas. Se a aplicação precisar ser encerrada ou se uma tarefa se tornar obsoleta (por exemplo, uma busca de caminho que foi cancelada pelo usuário), o sistema pode sinalizar a interrupção de forma segura, evitando desperdício de ciclos de CPU em processamentos que não serão mais utilizados.

= Resultados e Discussão
== Impacto na Responsividade da Main Thread
== Análise de Performance dos Algoritmos de Busca
== Uso de Memória e Eficiência do Cache

= Conclusão

// Estilo da bibliografia atualizado para o formato da ACM
#bibliography("referencias_acm.bib", title: "Referências", style: "association-for-computing-machinery") 