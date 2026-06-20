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
  set text(font: "Libertinus Serif", size: 9pt, lang: "pt")

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
  show table: set text(size: 7.5pt)

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
  title: "Arquitetura Concorrente em C++20 para Geração Procedural e Renderização de Malhas 3D",
  short-title: "Geração e Renderização Concorrente de Malhas 3D",
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
    A geração procedural e a extração geométrica de malhas tridimensionais densas impõem desafios arquiteturais críticos, frequentemente sobrecarregando a _thread_ principal e degradando a fluidez da renderização gráfica. Este artigo apresenta uma arquitetura assíncrona baseada no padrão _Task Scheduler_, implementada em C++20, para gerenciar a geração e preparação concorrente de terrenos baseados em Ruído de Perlin. O estudo demonstra como o isolamento do contexto OpenGL e o uso de filas de prioridade multinível otimizam a aquisição de dados e mantêm a estabilidade do _framerate_ em simulações intensivas.
  ],
  ccs-concepts: (
    "Computing methodologies ~ Rendering",
    "Computing methodologies ~ Concurrent computing methodologies"
  ),
  keywords: (
    "Procedural Generation", "C++20", "Graphics Engine", "Concurrent Programming", "OpenGL"
  )
)

Numa versão sequencial convencional, gerar terrenos de forma procedural e preparar malhas 3D complexas são tarefas executadas diretamente na _thread_ principal, sobrecarregando-a quando ocorrem simultaneamente ao laço de renderização. Isso faz com que a taxa de quadros por segundo (FPS) caia drasticamente, podendo causar travamentos na aplicação.

Motores gráficos que usam a interface de programação de aplicações (API, _Application Programming Interface_) OpenGL#footnote[https://www.opengl.org/] sofrem ainda mais com esse problema. Por design, o contexto OpenGL é vinculado a uma única _thread_ por vez, exigindo que o laço de desenho e as alterações de estado dos gráficos aconteçam exclusivamente na _thread_ principal @learnopengl. Se essa mesma _thread_ tiver que parar para calcular um mapa de ruído ou gerar a geometria da malha em uma abordagem sequencial, a renderização é interrompida. Portanto, é preciso isolar o processamento pesado para garantir que a interface continue responsiva.

Para resolver isso, este artigo apresenta uma abordagem paralela baseada no padrão _Task Scheduler_ @concurrency desenvolvido com os recursos modernos do C++20. O sistema utiliza filas de prioridade multinível para organizar a criação dos mapas de altura via Ruído de Perlin e a extração das malhas em _threads_ de segundo plano (trabalhadoras), deixando a _thread_ principal livre apenas para as chamadas gráficas.

A contribuição deste trabalho é demonstrar como essa arquitetura consegue separar a renderização da preparação dos dados de forma eficiente. Além disso, mostra-se como o uso de `std::jthread` e _smart pointers_ facilita o gerenciamento de memória em sistemas paralelos, evitando erros críticos e garantindo que o motor gráfico continue rodando de forma fluida mesmo durante simulações intensas.

= Fundamentação Teórica

Este estudo se baseia em conceitos fundamentais de computação gráfica, geração procedural e técnicas de concorrência em C++. A seguir, serão discutidos os principais tópicos relacionados a esses conceitos.

== Geração Procedural de Terrenos

A criação de ambientes de teste diversificados fundamenta-se na geração procedural de mapas de altura (_heightmaps_). Para este estudo, utiliza-se o Ruído de Perlin @perlin1985image, um algoritmo de ruído gradiente que gera padrões pseudoaleatórios com transições suaves, simulando topografias naturais. A complexidade do relevo é obtida pela sobreposição de múltiplas camadas de ruído, denominadas oitavas (_octaves_).

O controle do detalhamento é exercido por dois parâmetros: a lacunaridade, que regula o aumento da frequência entre oitavas sucessivas, e a persistência, que controla a redução da amplitude. O mapa de ruído resultante é mapeado para uma grade tridimensional, onde a intensidade de cada pixel define a elevação do vértice correspondente. Essa malha serve como base geométrica para os testes de performance da arquitetura proposta.

== Renderização e Responsividade

Motores gráficos interativos são estruturados em torno de um laço de renderização (_render loop_), responsável por processar eventos de entrada, atualizar o estado do sistema e desenhar as malhas na tela de forma contínua. Para garantir movimento fluido, esse ciclo deve ser executado em intervalos regulares (preferencialmente iguais). Caso a _thread_ principal realize processamentos pesados (como a geração e triangulação de malhas 3D), o ciclo é interrompido. Isso resulta em quedas de desempenho conhecidas como engasgos (_stuttering_) ou congelamento total da renderização.

== Monitor

Conforme explica Ladeira @ladeira, o padrão Monitor é uma implementação de alto nível para controle de sincronização em programação paralela. Ele utiliza mecanismos de bloqueio (`mutexes`) para garantir exclusão mútua e variáveis de condição para coordenar a execução das threads, prevenindo condições de corrida (_race conditions_) entre as rotinas assíncronas de geração de dados e a _thread_ principal. Ao encapsular o estado compartilhado, o monitor ajuda a garantir que o processamento das malhas possa ser realizado em paralelo de forma eficiente.

== Agendamento de Tarefas (_Task Scheduler_)

Um _Task Scheduler_ é um componente de software responsável por gerenciar a execução de tarefas concorrentes. Ele mantém uma fila de tarefas pendentes e um conjunto de threads (_thread pool_) que processam essas tarefas em paralelo @ladeira. O _Task Scheduler_ é projetado para otimizar o uso dos recursos do sistema, garantindo que as tarefas pesadas de geração de terrenos sejam delegadas para threads trabalhadoras (_worker threads_), mantendo a _thread_ principal sempre responsiva para a renderização gráfica.

=== Filas multinível

Filas multinível são estruturas de dados que organizam tarefas em diferentes níveis de prioridade. No contexto do _Task Scheduler_, as tarefas são classificadas em categorias como `High`, `Medium` e `Low`, permitindo que as threads trabalhadoras processem primeiro as tarefas mais críticas antes de lidar com tarefas de menor impacto. Essa abordagem garante que o sistema responda rapidamente às demandas mais urgentes, atrasando as tarefas menos críticas para serem processadas quando os recursos estiverem disponíveis.

== Concorrência e Segurança de Memória em C++20

A concorrência moderna no C++20 se baseia no uso de `std::jthread`, esta classe adota o princípio RAII (Resource Acquisition Is Initialization) fazendo a junção (`join()`) implicitamente em seu destrutor. A coordenação e o encerramento conjunto entre threads são efetuados por `std::stop_token`, que permite verificar requisições de parada de forma assíncrona. Para coordenação entre threads, variáveis de condição como `std::condition_variable_any` permite a espera passiva por eventos, liberando o _lock_ enquanto a thread está bloqueada, evitando espera ocupada.

Sobre segurança de memória em sistemas concorrentes, a prevenção de condições de corrida e falhas de segmentação (`SIGSEGV`) na manipulação de dados compartilhados exige o banimento de ponteiros brutos. Em seu lugar, utilizam-se referências e ponteiros inteligentes (`std::unique_ptr` e `std::shared_ptr`), que garantem o controle da vida útil dos recursos compartilhados de forma automática.

= Metodologia

Para avaliar o impacto do processamento paralelo na geração das malhas, desenvolveu-se uma arquitetura baseada no padrão _Task Scheduler_. A metodologia adotada divide-se na implementação estrutural do escalonador, na instrumentação para coleta de dados de desempenho e na definição de cenários de teste isolados.

== Ambiente de Teste e Ferramentas

O hardware utilizado para os testes consiste em um processador de 12ª geração Intel Core i5-1235U (12 _threads_, com frequência máxima de 4.40 GHz) e 16 GB de memória RAM. A aceleração gráfica foi provida por uma unidade de processamento gráfico (GPU, _Graphics Processing Unit_) integrada Intel Iris Xe Graphics.

O sistema operacional utilizado foi Arch Linux (Kernel 6.15.9). Todo o código-fonte foi desenvolvido obedecendo estritamente ao padrão C++20 e compilado utilizando a coleção de compiladores GNU (GCC). Para avaliar a máxima performance dos algoritmos, o binário final foi gerado utilizando a flag de otimização de tempo de execução `-O3` (`Release`), juntamente com diretrizes rigorosas de compilação (`-Wall`, `-Wextra`, `-Wpedantic` e `-Werror`).

A renderização e o controle do _loop_ de eventos foram construídos utilizando a API nativa do OpenGL versão 4.6 em conjunto com a biblioteca de gerenciamento de janelas GLFW versão 3.4. As operações matemáticas em matrizes e vetores tridimensionais foram realizadas através da biblioteca GLM (_OpenGL Mathematics_) versão 1.0.3. O gerenciamento de dependências e a orquestração do _build_ foram realizados por meio da ferramenta CMake.

== Cenários de Teste

Para garantir a aquisição de dados que reflitam o comportamento real dos algoritmos, os experimentos foram estruturados em quatro modos de execução distintos, cruzando o isolamento do processamento com a concorrência:

- *Bench Sequential (BS):* Geração e extração linear em ambiente isolado (sem motor gráfico), servindo como _baseline_ de performance pura.
- *Bench Parallel (BP):* Geração e extração utilizando o `TaskMaster` para processamento paralelo, medindo o escalonamento da unidade central de processamento (CPU, _Central Processing Unit_) sem interferência da GPU.
- *Engine Sequential (ES):* Integração com o motor gráfico onde a geração ocorre na _thread_ principal, bloqueando o laço de renderização e permitindo medir a degradação do FPS.
- *Engine Parallel (EP):* Geração assíncrona em _threads_ de _background_ com upload de dados para o motor conforme a disponibilidade, validando a fluidez da aplicação.

Os testes foram realizados com variações de dois parâmetros de geração do relevo: a *Escala* (densidade da malha de 100x100 até 1000x1000 vértices) e o *Número de Oitavas* (complexidade geométrica de 1 a 10 camadas de ruído). Para cada nível de variação, foram coletadas 100 amostras. A escolha do tamanho amostral visa atender com folga aos pressupostos do Teorema do Limite Central, garantindo a aproximação normal da distribuição das médias e assegurando o poder estatístico necessário para a aplicação dos testes paramétricos de Análise de Variância (ANOVA) e de Tukey @montgomery2017design.

== Instrumentação e Coleta de Dados

Para coletar e organizar os resultados de desempenho, foi desenvolvido um _wrapper_ que estrutura os dados de forma hierárquica. O objetivo principal deste componente é facilitar a exportação e análise das métricas coletadas, mantendo o código de teste organizado e os resultados fáceis de interpretar.

A estrutura utilizada para o armazenamento em memória é `std::map<std::string, std::map<std::string, std::vector<double>>>`. Nela, o primeiro nível associa a configuração de geração (como "Escala" ou "Número de oitavas") a um conjunto de métricas. O segundo nível vincula cada métrica (como "Tempo de Extração" ou "FPS Médio") a um vetor que armazena os valores obtidos em cada repetição do experimento. Os resultados contidos na estrutura foram exportados em arquivos formatados em CSV para posterior análise estatística e plotagem de gráficos.

Embora o uso de `std::map` envolva mais alocações dinâmicas do que um vetor contíguo, essa escolha não interfere na precisão dos resultados. Isso ocorre porque o registro dos dados no módulo de instrumentação é feito apenas após a finalização da medição de dados de cada cenário de teste. Assim, a abordagem prioriza a facilidade em adicionar novas métricas sem comprometer o desempenho medido nos benchmarks.

=== Métricas de Desempenho e Speedup

Para avaliar o impacto da concorrência, foram selecionadas métricas de eficiência temporal e de uso de recursos de hardware:

- *Tempo de Extração:* Mede o intervalo total gasto para converter o mapa de ruído em uma malha de triângulos, sendo uma métrica crítica para a fluidez do sistema.
- *Eficiência do Cache:* Mede a taxa de falhas de acesso ao cache (_cache misses_) através da ferramenta `perf stat` do Linux, permitindo avaliar a localidade de referência dos acessos à memória durante a geração de ruído e extração de malhas.
- *Responsividade (FPS):* A taxa de quadros por segundo da aplicação é monitorada para verificar se a geração assíncrona de malha isola a renderização gráfica de travamentos.
\
#v(-1em)
Para quantificar o ganho de desempenho obtido com a paralelização das tarefas, calculou-se o _speedup_ global ($S$), definido pela razão entre o tempo de execução sequencial ($T_text("s")$) e o tempo de execução paralelo ($T_text("p")$): $S = T_text("s") / T_text("p")$.

Além dessas métricas, o sistema permite registrar parâmetros de configuração do ruído, facilitando a correlação entre a complexidade da malha e o custo de renderização. As possíveis variações de configuração incluem:

- *Escala:* Refere-se à densidade da malha, que influencia o número de vértices gerados e o tempo de transferência para a GPU.
- *Número de oitavas:* Determina a quantidade de camadas de ruído sobrepostas, afetando a complexidade do terreno e, consequentemente, o desempenho da geração de mapas. 

== Pipeline de Processamento Sequencial

Para garantir a validade estatística dos resultados, o pipeline sequencial (modos BS e ES) atua como o modelo de referência. Neste fluxo, todas as etapas de geração de ruído e triangulação ocorrem de forma linear na thread principal.

O fluxo de processamento segue uma ordem rígida: para cada configuração de teste, o sistema gera o mapa de ruído e realiza a extração dos vértices antes de prosseguir para a próxima amostra ou quadro de renderização. As baterias de testes foram organizadas em 8 níveis incrementais de complexidade (passos), variando a escala de 100x100 a 800x800 ou o número de oitavas de 1 a 10.

Embora funcional para volumes menores de dados, esta abordagem sequencial revela limitações críticas conforme a complexidade aumenta. No modo ES, o custo acumulado da geração de relevo na mesma thread de renderização causa quedas bruscas de FPS e travamentos visíveis, o que motiva e justifica a transição para a arquitetura concorrente (modos BP e EP).

== Arquitetura da Solução Concorrente

Com o objetivo de isolar a thread principal e permitir que as tarefas de extração e construção de dados sejam processadas em paralelo, foi implementada uma arquitetura baseada no padrão _Task Scheduler_. Esta arquitetura é projetada para gerenciar o fluxo de tarefas concorrentes, garantindo que a _thread_ principal permaneça responsiva enquanto as tarefas de extração e construção de dados são processadas em paralelo.

Para isso, foi criada uma classe `TaskMaster` que encapsula a lógica de gerenciamento de tarefas e threads. O `TaskMaster` é responsável por manter uma fila de tarefas pendentes, gerenciar um pool de threads trabalhadoras e coordenar a execução das tarefas de forma eficiente.

=== Estrutura do `TaskMaster`

Esse componente é projetado para ser o núcleo do sistema de agendamento de tarefas, gerenciando a execução concorrente das tarefas de extração e construção de dados. Ele mantém uma fila de tarefas pendentes e um conjunto de threads trabalhadoras que processam essas tarefas em paralelo.

\
#figure(
  caption: [Diagrama de classes da arquitetura do TaskMaster],
)[
  #image("./images/task_master.png", width: 100%)
]\

A implementação do `TaskMaster` utiliza um conjunto de três filas de prioridade, representadas pelo `enum class Priority` com os níveis `High` (0), `Medium` (1) e `Low` (2). Essas filas são armazenadas em um `std::array` de `std::queue`, permitindo o acesso direto de cada nível de importância. No contexto desta pesquisa, as tarefas de prioridade `High` compreendem a geração de mapas de altura (ruído), as tarefas `Medium` envolvem a extração geométrica e triangulação da malha 3D correspondente e as tarefas `Low` referem-se à gravação de logs e exportação dos dados estatísticos.

No construtor da classe, o número de threads trabalhadoras é determinado dinamicamente através de `std::thread::hardware_concurrency()`. Para evitar a saturação completa dos núcleos do processador e garantir que a _thread_ principal (responsável pela renderização e interface) permaneça responsiva, o sistema reserva um núcleo, instanciando $N-1$ threads trabalhadoras. Estas threads são implementadas como objetos `std::jthread`, aproveitando o comportamento RAII para garantir que sejam finalizadas corretamente na destruição do escalonador.

Cada thread trabalhadora executa um loop contínuo que aguarda por novas tarefas utilizando uma `std::condition_variable_any`. A lógica de seleção de tarefas prioriza sempre as filas de maior importância: o trabalhador verifica sequencialmente as filas `High`, `Medium` e `Low`, extraindo a primeira tarefa disponível na fila de maior prioridade encontrada. Isso garante que tarefas críticas, como a geração da malha visível, sejam processadas antes de tarefas de menor impacto, como a exportação de dados estatísticos. 

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

O uso de metaprogramação na passagem da função lambda permite que o `TaskMaster` possa lidar com uma variedade de tarefas sem exigir que todas as funções de tarefa sejam projetadas para aceitar um `std::stop_token`.

Encapsulando a tarefa, é mais fácil manter a fila de prioridade sem abstrações desnecessárias. Então, o método `addTask` verifica se a função fornecida é invocável com um `std::stop_token`. Se for, a função é usada diretamente. Caso contrário, ela é encapsulada em uma função lambda que ignora o `std::stop_token`, permitindo que tarefas simples sejam adicionadas sem a necessidade de lidar com tokens de parada.

Com a função encapsulada, o método `addTask` adquire um lock para garantir acesso exclusivo às filas de tarefas e adiciona a tarefa à fila correspondente à sua prioridade. Após a adição, a variável de condição é notificada para acordar uma thread trabalhadora que esteja aguardando por novas tarefas, garantindo que a tarefa seja processada o mais rápido possível.

A sincronização entre as threads trabalhadoras e a thread principal é garantida por um `std::mutex`, protegendo o acesso às filas de tarefas e à variável de condição. O uso de `std::condition_variable_any` permite que as threads trabalhadoras sejam notificadas imediatamente quando uma nova tarefa é adicionada, evitando a necessidade de polling e garantindo uma resposta rápida às mudanças na fila de tarefas.

Por fim, o ciclo de vida do escalonador é encerrado de forma cooperativa através do seu destrutor (Listagem 3). O uso combinado de `notify_all` para acordar threads bloqueadas e `request_stop` do `std::jthread` garante um encerramento limpo e livre de _deadlocks_.

=== Paralelização da Aquisição de Dados

A preparação da geometria e a extração de métricas de desempenho foram fortemente beneficiadas pela arquitetura do `TaskMaster` e pelo uso de _multithreading_ direto. O processo compreende a geração procedural do terreno (mapa de ruído), a extração da malha tridimensional correspondente e o upload dos dados para a GPU.

No modo EP (Engine Parallel), utiliza-se uma thread de _background_ dedicada que produz continuamente novos dados de malha e os insere em uma fila segura (`std::queue` protegida por `std::mutex`). O laço principal da engine consome as malhas prontas da fila de forma assíncrona. Isso permite que a renderização ocorra de forma fluida enquanto novos setores do terreno são processados em paralelo, eliminando o bloqueio da _thread_ principal.

Para o modo BP (Bench Parallel), o `TaskMaster` distribui as repetições do experimento entre múltiplos núcleos, utilizando mecanismos de sincronização (`std::mutex` e `std::condition_variable`) para orquestrar o fim de cada passo de teste. Dessa forma, a _thread_ principal aguarda a conclusão de todos os trabalhadores antes de consolidar as estatísticas através da classe `Statistics`.

== Controle de Recursos do Sistema Operacional

Para garantir um ambiente isolado e obter um sistema quiescente, livre de ruído experimental @jain1991art, o sistema operacional foi configurado para reduzir a influência de processos em segundo plano. Um script de inicialização foi criado para desativar serviços desnecessários e ajustar a política de escalonamento da CPU e configurar o sistema para operar em modo _performance_. 

Além disso, todos os testes de benchmark (BS e BP) foram conduzidos no ambiente TTY (sem interface gráfica), garantindo que a GPU não fosse utilizada para renderização de janelas ou efeitos visuais do sistema operacional durante os testes. Essa abordagem assegura que os resultados obtidos reflitam com precisão o desempenho da arquitetura concorrente implementada, conforme preconizado pelas boas práticas de medição de sistemas computacionais @lilja2000measuring.

Após os ajustes no sistema, os testes são executados 5 vezes alternativamente, ou seja um após o outro, com 10 segundos de espera entre cada execução para garantir que o sistema esteja estabilizado e que os resultados sejam consistentes.


= Resultados e Discussão

O desempenho dos algoritmos foi avaliado com base nas métricas de tempo de extração, eficiência do cache e responsividade (FPS). Os resultados obtidos demonstram uma melhoria significativa na maior parte dos cenários avaliados quando a arquitetura concorrente é utilizada, sobretudo em termos de vazão global (throughput) e estabilidade do FPS.

== Tratamento de dados

Mesmo rodando o algoritmo de forma isolada em linha de comando, interrupções temporárias do sistema operacional, oscilações na frequência da CPU (thermal throttling) ou pequenos atrasos de alocação de memória podem gerar picos isolados de latência (outliers) @mytkowicz2009producing.
Para tratar esses pontos de dados discrepantes de forma matematicamente rigorosa (como recomendado para relatórios acadêmicos), implementamos o método da Amplitude Interquartílica (IQR) @bussab2017estatistica:
- *Detecção*: Para cada configuração de teste (mesma escala/oitava e mesmo modo), calculou-se a amplitude interquartílica. Valores de tempo fora do intervalo das amostras foram classificados como outliers.
- *Imputação de valores*: Os outliers detectados foram substituídos pela *mediana* do seu respectivo grupo. Isso preserva o tamanho amostral original ($N = 100$) e a tendência central, mas estabiliza o desvio padrão e o erro residual, garantindo que o modelo da ANOVA atenda ao pressuposto de homogeneidade de variância.

== Comparação de benchmark

Para os testes de benchmark, os modos BS e BP foram comparados para avaliar o impacto do processamento paralelo na geração das malhas. Os dados foram analisados utilizando ANOVA de dois fatores com nível de significância $alpha = 0,05$, considerando a Escala e o Número de Oitavas como fatores independentes @montgomery2017design. A análise relevou diferenças estatisticamente significativas entre os modos de execução, com o modo BP apresentando tempos de extração consistentemente menores em todas as configurações testadas.
A análise estatística foi conduzida utilizando ANOVA de dois fatores, com nível de significância $alpha = 0,05$. O teste de Tukey foi aplicado para identificar diferenças significativas entre os grupos @montgomery2017design.

+ *Tempo de Geração vs. Escala (Tamanho da Malha):*
  Para malhas pequenas de $100 times 100$ vértices, o modo Sequencial obteve média de 25,41 ms contra 55,32 ms do modo Paralelo. Em malhas maiores de $1000 times 1000$ vértices, o tempo sequencial elevou-se para 2.295,97 ms, enquanto o paralelo registrou 4.859,25 ms. O speedup individual médio é medido em aproximadamente 0,46x e 0,47x, evidenciando que o processamento paralelo de uma única tarefa é cerca de duas vezes mais lento que o sequencial.

+ *Tempo de Geração vs. Oitavas (Complexidade do Ruído):*
  Com 1 oitava de ruído, a média do modo Sequencial foi de 131,01 ms contra 295,96 ms do modo Paralelo (speedup de 0,44x). Com a complexidade máxima de 10 oitavas, as médias foram de 605,42 ms e 1.192,29 ms, respectivamente, resultando em um speedup de 0,51x.
\

#figure(
  table(
    columns: (1fr, 1.7fr, 1.7fr, 1fr),
    align: (center, right, right, right),
    stroke: 0.5pt + luma(150),
    fill: (x, y) => if y == 0 { rgb("#eef2f7") } else { none },
    [*Escala*], [*Seq. Médio (ms)*], [*Par. Médio (ms)*], [*Speedup*],
    [100x100], [25,41 ± 0,05], [55,32 ± 2,11], [0,46x],
    [200x200], [98,52 ± 0,16], [216,95 ± 8,85], [0,45x],
    [300x300], [218,54 ± 0,18], [477,07 ± 20,19], [0,46x],
    [400x400], [380,11 ± 0,28], [808,81 ± 32,80], [0,47x],
    [500x500], [585,75 ± 0,33], [1241,59 ± 51,58], [0,47x],
    [600x600], [842,92 ± 0,41], [1792,47 ± 75,83], [0,47x],
    [700x700], [1132,59 ± 0,69], [2396,33 ± 100,96], [0,47x],
    [800x800], [1483,53 ± 0,87], [3182,91 ± 137,72], [0,47x],
    [900x900], [1871,30 ± 1,08], [3967,01 ± 168,51], [0,47x],
    [1000x1000], [2295,97 ± 0,78], [4859,25 ± 207,72], [0,47x],
  ),
  caption: [Benchmark do tempo de geração de malha em função da escala.],
) <tab:escala_pure>

#figure(
  table(
    columns: (1fr, 1.7fr, 1.7fr, 1fr),
    align: (center, right, right, right),
    stroke: 0.5pt + luma(150),
    fill: (x, y) => if y == 0 { rgb("#eef2f7") } else { none },
    [*Oitavas*], [*Seq. Médio (ms)*], [*Par. Médio (ms)*], [*Speedup*],
    [1], [131,01 ± 0,28], [295,96 ± 10,75], [0,44x],
    [2], [176,00 ± 0,12], [387,60 ± 12,80], [0,45x],
    [3], [222,53 ± 0,11], [496,05 ± 19,30], [0,45x],
    [4], [270,30 ± 0,17], [586,36 ± 21,92], [0,46x],
    [5], [320,57 ± 0,23], [688,34 ± 27,81], [0,47x],
    [6], [374,70 ± 0,27], [808,35 ± 35,60], [0,46x],
    [7], [433,60 ± 0,32], [895,33 ± 40,17], [0,48x],
    [8], [491,28 ± 0,34], [995,85 ± 48,09], [0,49x],
    [9], [548,77 ± 0,33], [1089,94 ± 52,81], [0,50x],
    [10], [605,42 ± 0,39], [1192,29 ± 57,34], [0,51x],
  ),
  caption: [Benchmark do tempo de geração de malha em função das oitavas de ruído.],
) <tab:oitavas_pure>
\

A aparente contradição da versão paralela ser mais lenta para processar uma única malha (latência da tarefa) é explicada ao analisar o tempo total necessário para processar o lote completo de testes (vazão ou _throughput_). Enquanto o lote completo de testes (composto por um total de 400 malhas tridimensionais, sendo 200 no teste de escala e 200 no de oitavas) no modo Sequencial levou 250,32 segundos para ser concluído, o modo Paralelo finalizou todo o trabalho em apenas 46,69 segundos — representando um *speedup* global de 5,35x.

Essa diferença de comportamento entre a latência unitária e a vazão global deve-se ao fato do `TaskMaster` distribuir as diferentes repetições do benchmark concorrentemente entre os núcleos físicos da CPU. Embora cada thread sofra com o _overhead_ de organização e sincronização, a execução paralela de múltiplas tarefas independentes maximiza o uso do processador.

Fisicamente, a perda de desempenho individual nas execuções paralela é justificada pela disputa por recursos de memória. Os dados coletados utilizando contadores de hardware (`perf`) apontam que o modo Sequencial apresentou uma taxa de erro de cache (_cache misses_) de $30,93%$, enquanto o modo Paralelo subiu para $36,48%$. A execução simultânea de múltiplas threads de geração de malha força a CPU a realizar acessos frequentes à memória RAM física. Isso resulta em um aumento significativo de _cache misses_, o que explica a queda de desempenho individual. Enquanto o ganho global de vazão é evidenciado pela redução drástica do tempo total necessário para processar o lote completo de malhas.

=== Variabilidade

A análise de variabilidade dos tempos obtidos em cada execução revela grandes diferenças no comportamento de ambos os modos. No modo Sequencial, a dispersão dos dados é quase inexistente, com desvio padrão de apenas 3,99 ms no cenário de escala de $1000 times 1000$ vértices. Visualmente, isso se traduz em boxplots extremamente achatados, indicando alta previsibilidade. Como a execução ocorre de forma linear e ininterrupta em um único núcleo (neste caso o núcleo 2, para evitar interrupções de sistema), os tempos permanecem constantes sob as mesmas condições.

Por outro lado, o modo Paralelo exibe uma dispersão alta, com o desvio padrão atingindo 1.059,81 ms para o mesmo tamanho de malha de $1000 times 1000$. Esse comportamento se reflete em caixas amplas nos boxplots, como ilustrado em @fig:escala_boxplot_s e @fig:escala_boxplot_p. Fisicamente, essa instabilidade é causada pela concorrência com o controle do sistema operacional. O agendamento dinâmico de threads do `TaskMaster` entre diferentes núcleos da CPU introduz latências causadas por concorrência de barramento de memória, trocas de contexto (_context switching_) e atrasos na aquisição de locks da sincronização. Consequentemente, o tempo de conclusão de cada simulação individual difere de acordo com o estado da CPU e do escalonador do SO.

#figure(
    image("images/plot_escala_boxplot_sequencial.png", width: 100%),
  caption: [Dispersão do tempo de geração por escala no modo Sequencial.],
) <fig:escala_boxplot_s>

#figure(
    image("images/plot_escala_boxplot_paralelo.png", width: 100%),
  caption: [Dispersão do tempo de geração por escala no modo Paralelo.],
) <fig:escala_boxplot_p>

=== Análise Estatística

Para avaliar de forma cientificamente se as diferenças observadas entre os tempos médios de geração dos modos Sequencial e Paralelo são estatisticamente significativas, realizou-se uma análise baseada em testes de hipóteses:
- *Hipótese Nula ($H_0$):* Não há diferença significativa nas médias dos tempos de geração entre os modos Sequencial e Paralelo para uma mesma configuração de parâmetros.
- *Hipótese Alternativa ($H_1$):* Há uma diferença estatisticamente significativa entre as médias de tempo de geração dos modos.
\
#v(-1em)
Primeiramente, aplicou-se a ANOVA de duas vias para avaliar a influência isolada do modo de execução (Sequencial ou Paralelo), do valor do parâmetro (Escala ou Oitavas) e sua interação @montgomery2017design:
- *Experimento de Escala:* Revelou efeitos muitos significativos para todos os fatores. O fator modo de execução obteve $text("p-valor") < 0,001$, o fator Escala registrou $text("p-valor") < 0,001$ e a interação entre ambos alcançou $text("p-valor") < 0,001$.
- *Experimento de Oitavas:* Também demonstrou significância estatística. O fator Modo registrou $text("p-valor") < 0,001$, o fator Oitavas registrou $text("p-valor") < 0,001$, enquanto o fator de interação obteve $text("p-valor") < 0,001$.
\
#v(-1em)
A forte significância estatística da interação ($text("p-valor") < 0,001$) em ambos os experimentos aponta que a diferença de desempenho entre os modos Sequencial e Paralelo depende diretamente do nível do parâmetro avaliado. Para isolar essas diferenças específicas em cada nível, aplicou-se o teste pós-hoc de Tukey @montgomery2017design.

No experimento de Escala, constatou-se que para grids pequenos de $100 times 100$ ($text("p-valor") = 1,00$) e $200 times 200$ ($text("p-valor") = 0,79$), *a diferença entre os modos não é estatisticamente significativa*. Nesses cenários, os dois algoritmos comportam-se de forma equivalente. Porém, a partir da escala $300 times 300$ até a escala máxima de $1000 times 1000$, a hipótese nula $H_0$ foi consistentemente rejeitada ($text("p-valor") < 0,05$), provando estatísticamente o atraso provocado pelo processamento paralelo de malhas individuais.

No experimento de Oitavas, a diferença foi significativa em todas as oitavas (de 1 a 10), com a rejeição da hipótese nula ocorrendo de forma estável ($text("p-valor") < 0,001$) para todos os cenários de complexidade.

== Desempenho no motor gráfico

Com a integração do `TaskMaster` ao motor gráfico, o impacto do processamento paralelo na fluidez da renderização foi avaliado através da métrica de FPS. Os resultados indicam que, mesmo com o aumento da latência individual para a geração de cada malha, a arquitetura concorrente permite que a thread principal mantenha uma taxa de quadros estável, evitando quedas bruscas de FPS e travamentos visíveis.

Nos testes a taxa de quadros por segundo foi limitada a 60 FPS para garantir uma experiência fluida. O modo Sequencial, ao bloquear a thread principal durante a geração da malha, resultou em quedas significativas de FPS, especialmente em configurações de alta complexidade (grids maiores e mais oitavas). Em contraste, o modo Paralelo conseguiu manter a taxa de quadros estável em 60 FPS, mesmo com o aumento da latência de geração, demonstrando a eficácia da arquitetura concorrente em isolar a thread de renderização das tarefas pesadas de processamento.

Ao analisar o comportamento do gerador de malhas integrado ao laço principal de renderização da engine, observam-se padrões de desempenho diferentes quanto à responsividade e à latência de geração:

+ *Desempenho por Escala (Tamanho da Malha):*
  Para malhas de $100 times 100$ vértices, a geração em modo Sequencial ocupa a thread principal por 25,6 ms, limitando a renderização a 39 FPS. O modo Paralelo necessita de 49,8 ms para gerar a malha, mas a engine mantém-se estável a 60 FPS. Com grids de $200 times 200$, o tempo sequencial sobe para 99,0 ms e a taxa cai para 10 FPS, gerando engasgos visíveis. O paralelo consome 179,9 ms, mas sustenta a renderização, ainda, a 60 FPS. Na escala máxima de $1000 times 1000$, o modo Sequencial bloqueia a thread de renderização por 2,29 segundos resultando em 0,44 FPS, enquanto o Paralelo consome 3,89 segundos de computação secundária mantendo a fluidez estável a 60 FPS.

+ *Desempenho por Oitavas (Complexidade do Ruído):*
  Com 1 oitava de ruído, a latência de 131,0 ms no modo Sequencial reduz o jogo a 7,61 FPS, contra 60 FPS no modo Paralelo (computação de 235,3 ms). Sob complexidade máxima de 10 oitavas, o modo Sequencial desaba para 1,65 FPS (605,4 ms de latência), enquanto o Paralelo sustenta os mesmos 60 FPS, demandando 1.042,8 ms de tempo de CPU em segundo plano.

Os dados obtidos na engine gráfica para as variações de escala e de oitavas de ruído estão consolidados na @tab:engine_escala e na @tab:engine_oitavas, respectivamente.

#figure(
  table(
    columns: (1fr, 1.5fr, 1.2fr, 1.5fr, 1.2fr),
    align: (center, right, right, right, right),
    stroke: 0.5pt + luma(150),
    fill: (x, y) => if y == 0 { rgb("#fdf8f5") } else { none },
    [*Escala*], [*Seq. Tempo (ms)*], [*Seq. FPS*], [*Par. Tempo (ms)*], [*Par. FPS*],
    [100x100], [25,6], [39], [49,8], [60],
    [200x200], [99,0], [10], [179,9], [60],
    [300x300], [218,2], [4,57], [411,5], [60],
    [400x400], [380,0], [2,63], [703,3], [60],
    [500x500], [585,3], [1,71], [1071,0], [60],
    [600x600], [842,4], [1,19], [1511,0], [60],
    [700x700], [1131,7], [0,88], [2045,3], [60],
    [800x800], [1481,8], [0,67], [2658,7], [60],
    [900x900], [1871,7], [0,53], [3333,7], [60],
    [1000x1000], [2295,0], [0,44], [3897,5], [60],
  ),
  caption: [Tempo de processamento e taxa de quadros (FPS) em função da escala na engine gráfica.],
) <tab:engine_escala>

#figure(
  table(
    columns: (1fr, 1.5fr, 1.2fr, 1.5fr, 1.2fr),
    align: (center, right, right, right, right),
    stroke: 0.5pt + luma(150),
    fill: (x, y) => if y == 0 { rgb("#fdf8f5") } else { none },
    [*Oitavas*], [*Seq. Tempo (ms)*], [*Seq. FPS*], [*Par. Tempo (ms)*], [*Par. FPS*],
    [1], [131,0], [7,61], [235,3], [60],
    [2], [176,3], [5,67], [308,5], [60],
    [3], [222,5], [4,49], [402,6], [60],
    [4], [270,4], [3,70], [511,6], [60],
    [5], [320,2], [3,12], [581,9], [60],
    [6], [374,1], [2,67], [689,4], [60],
    [7], [433,1], [2,31], [804,4], [60],
    [8], [490,7], [2,04], [907,6], [60],
    [9], [548,0], [1,82], [1010,8], [60],
    [10], [605,4], [1,65], [1042,8], [60],
  ),
  caption: [Tempo de processamento e taxa de quadros (FPS) em função das oitavas de ruído na engine gráfica.],
) <tab:engine_oitavas>

A dispersão do FPS obtido durante a simulação por escala pode ser observada na @fig:engine_escala_fps_boxplot_sequencial e na @fig:engine_escala_fps_boxplot_paralelo. Os gráficos contrastam a instabilidade e a perda acentuada de FPS do modo sequencial sob cargas altas com a estabilidade do modo paralelo no limite físico do motor gráfico.

#figure(
  image("images/plot_engine_escala_fps_boxplot_sequencial.png", width: 85%),
  caption: [Dispersão da taxa de quadros (FPS) por escala no modo Sequencial na engine gráfica.],
) <fig:engine_escala_fps_boxplot_sequencial>

#figure(
  image("images/plot_engine_escala_fps_boxplot_paralelo.png", width: 85%),
  caption: [Dispersão da taxa de quadros (FPS) por escala no modo Paralelo na engine gráfica.],
) <fig:engine_escala_fps_boxplot_paralelo>
\

Cabe notar uma particularidade de visualização na @fig:engine_escala_fps_boxplot_paralelo: embora os limites dos diagramas de caixa (_whiskers_) e do corpo da caixa aparentem cobrir uma grande área da escala vertical, isso é um artefato visual decorrente do ajuste automático de escala do eixo vertical no _software_ de plotagem. Como a variação real do FPS no modo paralelo é quase nula (na ordem de $10^(-1)$ a $10^(-2)$ FPS), o eixo vertical foi ampliado em um intervalo microscópico.

Essa variação quase inexistente de FPS para a maioria das escalas ocorre porque a transferência de malhas pequenas para a GPU consome tempo desprezível da thread principal. Contudo, na escala máxima de $1000 times 1000$ vértices, a malha possui cerca de um milhão de vértices. O envio desse grande volume de dados de vértices é  processado obrigatoriamente pela thread principal de renderização. O _upload_ desse buffer de dados no momento em que a malha fica pronta consome alguns milissegundos do tempo limite do quadro, explicando o desvio padrão de $0,56$ FPS e as oscilações entre $57,8$ e $60,8$ FPS. 

=== O Paradoxo da Responsividade

Embora o modo paralelo resulte em uma maior latência absoluta para concluir uma única tarefa (como visto anteriormente), a delegação desse processamento a threads secundárias pelo `TaskMaster` impede o bloqueio do laço de renderização principal. Assim, para aplicações gráficas interativas em tempo real, a estabilidade e a responsividade mostram-se mais importantes que o tempo bruto de execução do algoritmo de forma isolada.

=== Métricas de Cache na Engine

Os contadores físicos de CPU coletados via `perf` durante a execução junto ao motor gráfico corroboram as conclusões do benchmark isolado a respeito da disputa por recursos de memória. No modo Sequencial, a taxa de _cache misses_ registrou 32,77%. Sob a execução do modo Paralelo, essa taxa subiu para 41,54%. Essa diferença reforça a explicação de que o processamento paralelo de múltiplas tarefas simultâneas aumenta significativamente a pressão sobre o subsistema de memória, resultando em um aumento substancial de _cache misses_. No entanto, mesmo com essa penalidade de desempenho individual, a arquitetura concorrente do `TaskMaster` permite que a aplicação mantenha uma experiência fluida e responsiva, além de alavancar o desempenho de gerações em massa.

=== Análise Estatística

Para consolidar as conclusões observadas no motor gráfico, aplicou-se a Análise de Variância (ANOVA) de duas vias sobre a taxa de quadros e o tempo de geração. A análise confirmou que o modo de execução possui efeito altamente significativo no tempo de processamento ($text("p-valor") < 0,001$). O fator modo de execução (Sequencial ou Paralelo) também apresentou impacto estatístico massivo especificamente sobre a taxa de quadros $text("p-valor") < 0,001$). 

Por fim, o teste pós-hoc de Tukey corroborou que a melhoria de FPS obtida pela arquitetura concorrente é estatisticamente significativa em todas as escalas e oitavas avaliadas com $text("p-valor") < 0,001$, validando cientificamente a eficácia da solução paralela.

= Conclusão

Este trabalho apresentou uma arquitetura concorrente assíncrona baseada no padrão _Task Scheduler_ e implementada em C++20 para solucionar o gargalo de processamento na geração procedural de terrenos e extração de malhas tridimensionais integradas a motores gráficos. O objetivo principal foi garantir a estabilidade do FPS delegando tarefas intensivas a threads trabalhadoras secundárias.

Os resultados experimentais evidenciam que, embora a latência unitária tenha aumentado no modo paralelo devido à disputa de memória, o ganho de vazão alcançou um _speedup_ de 5,35x em lote. No motor gráfico, a arquitetura proposta sustentou a estabilidade em 60 FPS, enquanto o modo sequencial reduziu a renderização a 0,44 FPS sob alta complexidade. A eficácia da paralelização foi corroborada estatisticamente por ANOVA e teste de Tukey ($text("p-valor") < 0,001$).

Do ponto de vista de engenharia de software, o uso dos recursos modernos do C++20 (como `std::jthread`, `std::stop_token` e ponteiros inteligentes) simplificou o gerenciamento do ciclo de vida das threads e garantiu a segurança de memória contra condições de corrida e vazamentos, reduzindo a complexidade do código.

Como trabalhos futuros, sugere-se a investigação de técnicas de transferência de dados mais eficientes para a GPU para mitigar o _overhead_ observado no envio de buffers muito grandes da _thread_ principal, utilizando instanceamento (_Instancing_). Adicionalmente, planeja-se estender essa arquitetura assíncrona para a paralelização de outros subsistemas do motor gráfico, como algoritmos de busca de caminho (_pathfinding_).

#heading(numbering: none)[Agradecimentos]

Os autores agradecem ao assistente de inteligência artificial Antigravity (desenvolvido pelo Google DeepMind) pelo auxílio na revisão textual e ortográfica, estruturação conceitual das ideias e na formatação das tabelas deste artigo. Ressalta-se que toda a concepção do estudo, implementação do software, execução dos experimentos e análise científica contidas neste trabalho são de inteira responsabilidade dos autores.

#bibliography("referencias_acm.bib", title: "Referências", style: "association-for-computing-machinery") 