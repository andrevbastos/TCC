// Apresentação do TCC — conversão do Google Slides (16:9, 720 × 405 pt).
// Posições e tamanhos convertidos de EMU para pt (1 pt = 12700 EMU).
// O conteúdo segue a monografia (../tcc/tcc.typ).

#let verde-texto = rgb("#0B0F0D")
#let verde = rgb("#1D6933")
#let cinza = rgb("#5B605D")
#let branco = rgb("#F2F5F3")
#let fonte = ("IBM Plex Sans", "Arial")

#set page(width: 720pt, height: 405pt, margin: 0pt)
#set text(font: fonte, lang: "pt", region: "br", fill: verde-texto)
#set par(leading: 0.4em, spacing: 0.4em)

// Contador de slides lógicos: slides marcados como continuação repetem o
// número do anterior. Exibido como "atual/total" no canto inferior direito.
#let contador = counter("slide")
#let numero = context place(
  top + left, dx: 667.1pt, dy: 367.2pt,
  box(width: 43.2pt, height: 31pt, align(right + horizon, text(size: 10pt,
    [#contador.display()/#contador.final().first()]))),
)

// Slide de conteúdo: faixa com o fundo de grafos (recorte vertical
// 63,84 % – 81,00 % da imagem), título, corpo e nota de rodapé opcional.
// contado: false — slide fora da numeração (sem número e fora do total).
#let slide(titulo, nota: none, continua: false, contado: true, corpo) = {
  pagebreak(weak: true)
  if contado and not continua { contador.step() }
  place(top + left, box(width: 720pt, height: 69.5pt, clip: true,
    place(top + left, dy: -0.63842 * 405pt,
      image("images/grafos.svg", width: 720pt, height: 405pt))))
  place(top + left, dx: 93.9pt, dy: 5.3pt, box(
    width: 532.1pt, height: 58.9pt,
    // Reduz a fonte quando o título não cabe em uma linha.
    align(center + horizon, context {
      let t(s) = text(size: s, weight: "bold", fill: branco, titulo)
      if measure(t(30pt)).width > 532.1pt { t(24pt) } else { t(30pt) }
    }),
  ))
  // Corpo centralizado verticalmente na área branca entre o cabeçalho e a
  // nota de rodapé (ou o fim do slide, quando não há nota).
  let fim = if nota != none { 369.3pt } else { 405pt }
  place(top + left, dx: 36pt, dy: 69.5pt,
    box(width: 648pt, height: fim - 69.5pt, inset: (y: 14pt), align(horizon, {
      set text(size: 14pt)
      set par(spacing: 10pt)
      set list(spacing: 10pt)
      set enum(spacing: 8pt)
      corpo
    })))
  if nota != none {
    place(top + left, dx: 36pt, dy: 369.3pt, box(
      width: 625pt, height: 26.7pt,
      align(left + horizon, text(size: 10pt, fill: cinza, nota)),
    ))
  }
  if contado { numero }
}

// Legenda de figura.
#let legenda(corpo) = align(center, text(size: 12pt, fill: cinza, corpo))

// Tabela com cabeçalho na cor da faixa.
#let tabela(..args) = {
  set text(size: 12pt)
  table(
    stroke: none,
    inset: (x: 8pt, y: 6pt),
    fill: (_, y) => if y == 0 { verde } else if calc.even(y) { rgb("#E6EEE8") },
    ..args,
  )
}
#let cab(corpo) = text(weight: "bold", fill: branco, corpo)

// ---------------------------------------------------------------- Slide 1 ---
// A capa não conta nem exibe número.
#let capa() = {
  pagebreak(weak: true)

  // Faixa com o fundo de grafos (recorte vertical 16,58 % – 51,27 % da imagem).
  let faixa-h = 143.3pt
  place(top + left, dx: 25.2pt, dy: 28.2pt, box(
    width: 669.6pt, height: faixa-h, radius: 23.9pt, clip: true,
    place(top + left, dy: -0.1658 * faixa-h / 0.3469,
      image("images/grafos.svg", width: 669.6pt,
        height: faixa-h / 0.3469, fit: "stretch")),
  ))

  // Título e subtítulo.
  place(top + left, dx: 50pt, dy: 28.2pt, box(
    width: 620pt, height: 143.3pt,
    align(center + horizon)[
      #text(size: 20pt, weight: "bold", fill: branco)[
        Representações e características de terrenos tridimensionais \
        e seu impacto no desempenho de algoritmos \ de busca de caminhos
      ]
      #v(10pt)
      #text(size: 16pt, fill: branco)[Uma análise comparativa e estatística]
    ],
  ))

  // Autoria e instituição.
  place(top + left, dx: 125.4pt, dy: 195.7pt, box(
    width: 469.2pt, inset: 7.2pt,
    align(center)[
      #text(size: 20pt)[André Vitor Bastos de Macêdo] \
      #text(size: 20pt)[Orientador: Prof. Dr. Paulo César Rodacki Gomes]
      #v(20pt)
      #text(size: 16pt, style: "italic")[Instituto Federal Catarinense] \
      #text(size: 16pt, style: "italic")[Campus Blumenau]
      #v(16pt)
      #text(size: 18pt)[2026]
    ],
  ))

  // Logo do IFC.
  place(top + left, dx: 516.8pt, dy: 326.7pt,
    image("images/logo-ifc.png", width: 177.2pt, height: 58.9pt))
}

#capa()

// ---------------------------------------------------------------- Slide 2 ---
#slide(contado: false)[Sumário][
  #place(top + left, dx: 97.8pt, dy: 40.4pt, box(width: 452.5pt, {
    set text(size: 24pt)
    set par(spacing: 18pt)
    for (n, item) in (
      ("01", [Introdução e objetivos]),
      ("02", [Fundamentação teórica]),
      ("03", [Implementação e metodologia]),
      ("04", [Resultados e discussões]),
      ("05", [Conclusão]),
    ) {
      // Número em branco sobre fundo verde, como no modelo antigo.
      par[#box(fill: verde, radius: 4pt, inset: (x: 8pt, y: 5pt),
        outset: (y: 1pt), text(weight: "bold", fill: branco, n))#h(24pt)#item]
    }
  }))
]

// ---------------------------------------------------------------- Slide 3 ---
#slide[Busca de caminhos em espaços 3D][
  - A busca de caminhos (_pathfinding_) encontra caminhos entre um ponto de
    partida e um objetivo explorando o espaço de busca #cite(<russell_norvig>).
  - É componente crucial de jogos e simulações em tempo real
    #cite(<pathfinding_game_dev>).
  - Na grade 2D, cada aresta custa 1. No terreno 3D, o custo depende da
    diferença de altura entre os vértices.
  - A escolha da representação do terreno e do algoritmo de busca afeta o
    desempenho e a qualidade dos caminhos.

  #v(16pt)
  #grid(
    columns: (1fr, 1fr),
    align: center + horizon,
    image("images/2d.svg", height: 110pt),
    image("images/3d.svg", height: 130pt),
  )
  #legenda[Comparação entre representações 2D e 3D.]
]

// ---------------------------------------------------------------- Slide 4 ---
#slide[Pergunta de pesquisa e contribuições][
  #align(center, block(width: 85%, text(size: 16pt, style: "italic")[
    "Qual é a influência da *representação navegável* de um terreno 3D e das
    *características do terreno* no desempenho e na qualidade da busca de
    algoritmos clássicos de busca?"
  ]))
  #v(18pt)
  #set text(size: 13pt)
  #set par(spacing: 10pt)
  *Contribuições:*
  + *Comparação entre representações navegáveis:* os mesmos terrenos são
    convertidos em quatro grafos e avaliados com os mesmos algoritmos:
    - do mapa de altura: grade 2.5D e grade voxelizada;
    - da malha poligonal: grafo de vértices e grafo dual.
  + *Metodologia experimental reprodutível:* terrenos gerados
    proceduralmente com parâmetros controlados e semente registrada, e
    análise estatística (ANOVA e testes _post hoc_).
  + *Implementação de código aberto:* gerador, representações, algoritmos
    instrumentados, `lwGraph<T>` e _TaskMaster_, sobre as bibliotecas Graph
    e IFCG do autor.
]

// ---------------------------------------------------------------- Slide 5 ---
#slide[Objetivos][
  #set par(spacing: 10pt)
  *Objetivo geral:*

  Analisar comparativa e estatisticamente o desempenho de algoritmos
  clássicos de _pathfinding_ em diferentes representações navegáveis de
  terrenos 3D.

  #v(14pt)
  *Objetivos específicos:*
  + Estender uma biblioteca de grafos com uma estrutura leve e implementar
    os algoritmos Dijkstra, A\*, Weighted A\* e Greedy Best-First Search.
  + Desenvolver um gerador procedural de terrenos por ruído de Perlin,
    parametrizado por lacunaridade, persistência e comprimento de onda, com
    resolução da grade (escala) ajustável.
  + Construir quatro representações navegáveis: grade 2.5D, grade
    voxelizada, grafo de vértices e grafo dual da malha.
  + Desenvolver um ambiente 3D com execução concorrente para visualizar as
    malhas e os caminhos.
  + Automatizar a coleta de métricas e analisar estatisticamente os
    resultados.
]

// ---------------------------------------------------------------- Slide 6 ---
#slide(
  nota: [Os estudos analisados avaliam uma única representação navegável e
    não comparam representações por análise estatística.],
)[Trabalhos relacionados][
  #tabela(
    columns: (auto, 1fr, 1fr, 1fr),
    align: left + horizon,
    cab[Critério], cab[Este trabalho], cab[#cite(<dang2025adapting>, form: "prose")],
    cab[Kapi, Sunar e Algfoor (#cite(<Kapi2022>, form: "year"))],
    [*Espaço de busca*], [Terrenos 3D gerados por ruído de Perlin],
    [Ambientes 3D em _voxels_], [Grades 2D planas],
    [*Representações*],
    [Grade 2.5D, grade voxelizada, grafo de vértices e grafo dual],
    [Grade de _voxels_], [Grade 2D],
    [*Algoritmos*], [Dijkstra, A\*, Weighted A\* e GBFS], [Dijkstra e A\*],
    [A\*, Jump Point Search e Theta\*],
    [*Métricas*],
    [Tempo de busca, vértices expandidos, pico da lista aberta e custo
      relativo],
    [Tempo de execução e consumo de memória],
    [Tempo de execução e vértices expandidos],
  )
]

// ---------------------------------------------------------------- Slide 7 ---
#slide(
  nota: [Heurística usada: distância euclidiana 3D,
    $h(n) = sqrt(Delta x^2 + Delta y^2 + Delta z^2)$.],
)[Algoritmos de busca de caminhos][
  #align(center, block(width: 88%, tabela(
    columns: (auto, auto, 1fr),
    align: (left + horizon, center + horizon, left + horizon),
    cab[Algoritmo], cab[Função de avaliação], cab[Caminho ótimo],
    [Dijkstra #cite(<dijkstra1959note>)], $f(n) = g(n)$, [Sim],
    [A\* #cite(<astar>)], $f(n) = g(n) + h(n)$,
    [Sim, com heurística consistente],
    [Weighted A\* #cite(<pohl1970heuristic>)], $f(n) = g(n) + w dot h(n)$,
    [Não garantido ($w$ = 1,5)],
    [GBFS #cite(<russell_norvig>)], $f(n) = h(n)$, [Não garantido],
  )))
  #v(16pt)
  #align(center, block(width: 88%, align(left, text(size: 12pt)[
    #grid(
      columns: (auto, 1fr),
      column-gutter: 8pt,
      row-gutter: 6pt,
      $g(n)$, [custo acumulado do vértice inicial até $n$],
      $h(n)$, [estimativa do custo de $n$ até o objetivo (heurística)],
      $w$, [peso da heurística],
    )
  ])))
]

// Imagem com legenda curta abaixo.
#let fig(caminho, cap, ..args) = align(center, stack(
  spacing: 5pt, image(caminho, ..args), text(size: 11pt, fill: cinza, cap)))

// ---------------------------------------------------------------- Slide 8 ---
#slide[Mapas de altura][
  - Matriz 2D em que cada elemento guarda a altura do terreno. Como imagem,
    a intensidade do pixel é a elevação.
  - Valores $v in [0, 1]$ são convertidos em altura pela escala $H$:
    pixel preto → altura mínima, branco → altura máxima.
  - Cada elemento $(i, j)$ vira o vértice $(x, y, z) = (i, e(i, j), j)$,
    em que $e(i, j)$ é a altura armazenada.

  #v(16pt)
  #align(center, image("images/pixel_to_vertex.png", width: 430pt))
  #legenda[Conversão de um mapa de altura em vértices tridimensionais.]
]

// ---------------------------------------------------------------- Slide 9 ---
#slide(
  nota: [500 × 500 px, semente 42, lacunaridade 2, persistência 0,5.
    As oitavas são exibidas normalizadas, sem o peso $a_i$.],
)[Ruído de Perlin e oitavas][
  #grid(
    columns: (1fr, 250pt),
    column-gutter: 20pt,
    [
      - Ruído gradiente com variações contínuas e suaves, adequado para
        simular relevos naturais #cite(<perlin1985image>).
      - O terreno soma $N$ oitavas, cada uma com frequência e amplitude
        próprias #cite(<patel_terrain_noise>):
      #v(4pt)
      $ f_i = f dot l^i, quad a_i = a_0 dot p^i $
      $ R(x, y) = sum_(i=0)^(N-1) a_i dot "ruído"(x dot f_i, y dot f_i) $
      #v(4pt)
      - $l$: lacunaridade; $p$: persistência.
      - Todos os testes usam seis oitavas.
    ],
    [
      #fig("images/oitavas.png", [Soma das oitavas], height: 130pt)
      #v(8pt)
      #grid(
        columns: 6,
        column-gutter: 4pt,
        ..range(1, 7).map(i => fig("images/oitavas/octave_" + str(i) + ".png",
          $i = #(i - 1)$, width: 38pt)),
      )
    ],
  )
]

// --------------------------------------------------------------- Slide 10 ---
#slide(
  nota: [500 × 500 px, semente 42, 6 oitavas; demais parâmetros fixos
    (lacunaridade 2, persistência 0,5, células de 250 px).],
)[Parâmetros de geração][
  #let coluna(nome, texto, a, ca, b, cb) = [
    #text(weight: "bold", fill: verde, nome)
    #v(4pt)
    #block(height: 70pt, text(size: 12pt, texto))
    #grid(
      columns: 2,
      column-gutter: 6pt,
      fig(a, ca, width: 96pt), fig(b, cb, width: 96pt),
    )
  ]
  #grid(
    columns: (1fr, 1fr, 1fr),
    column-gutter: 18pt,
    coluna([Lacunaridade $l$],
      [Quanto a frequência cresce entre oitavas. Valores altos concentram
        o detalhe em escalas pequenas e o relevo fica mais irregular.],
      "images/lac_baixa.png", [$l$ = 1,5], "images/lac_alta.png", [$l$ = 2,25]),
    coluna([Persistência $p$],
      [Quanto a amplitude diminui entre oitavas. Valores altos mantêm o peso
        das oitavas finas e o terreno fica mais áspero.],
      "images/pers_baixa.png", [$p$ = 0,3], "images/pers_alta.png", [$p$ = 0,7]),
    coluna([Comprimento de onda],
      [Tamanho das células da primeira oitava. Valores menores repetem o
        padrão mais próximo, e muda a escala de todo o terreno.],
      "images/freq_baixa.png", [500 px], "images/freq_alta.png", [200 px]),
  )
]

// --------------------------------------------------------- Slides 11 e 12 ---
// Representação navegável: imagem, nome e tópicos.
#let rep(img, nome, corpo) = [
  #align(center, image(img, width: 290pt, height: 160pt, fit: "contain"))
  #v(6pt)
  #text(size: 16pt, weight: "bold", fill: verde, nome)
  #v(4pt)
  #set text(size: 12pt)
  #set list(spacing: 6pt)
  #corpo
]
#let nota-rep = [Em todas as representações, o peso da aresta é a distância
  euclidiana 3D, e nenhuma conexão é removida por critério de
  transitabilidade.]

#slide(nota: nota-rep)[Representações: mapa de altura][
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 24pt,
    align: top,
    rep("images/2_5d.png", [Grade 2.5D])[
      - Cada pixel do mapa de altura é um vértice, com altura contínua.
      - Vizinhança de 8 direções.
      - Não representa cavidades nem estruturas sobrepostas.
    ],
    rep("images/voxel.png", [Grade voxelizada])[
      - Um vértice no topo de cada coluna, com altura arredondada para um
        número inteiro de _voxels_.
      - Vizinhança de 4 direções.
    ],
  )
]

#slide(nota: nota-rep, continua: true)[Representações: malha poligonal][
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 24pt,
    align: top,
    rep("images/vertex.png", [Grafo de vértices])[
      - Cada vértice da malha é um vértice navegável.
      - As arestas são as arestas dos triângulos da malha.
    ],
    rep("images/dual.png", [Grafo dual])[
      - Cada triângulo é um vértice, posicionado no baricentro.
      - Triângulos que compartilham uma aresta são ligados.
      - Base das malhas de navegação #cite(<snook_navmesh>).
    ],
  )
]

// --------------------------------------------------------------- Slide 13 ---
#slide[Pipeline experimental][
  #align(center, image("images/pipeline_hor.svg", width: 100%))
  #v(16pt)
  #grid(
    columns: (1fr, 130pt),
    column-gutter: 20pt,
    align: horizon,
    [
      - O mapa de altura é gerado a partir de uma semente registrada.
      - Para os grafos de vértices e dual, o mapa vira um volume de _voxels_,
        e a malha é extraída por Marching Cubes #cite(<lorensen_cline_marching_cubes>).
      - As consultas são associadas ao vértice mais próximo do grafo, e os
        quatro algoritmos são executados sobre o mesmo grafo.
      - As métricas são registradas e analisadas estatisticamente.
    ],
    fig("images/heightmap_to_mesh.png", [Malha extraída], width: 130pt),
  )
]

// --------------------------------------------------------------- Slide 14 ---
#slide[Variáveis][
  #align(center, block(width: 96%, tabela(
    columns: (auto, auto, 1fr),
    align: left + horizon,
    cab[Tipo], cab[Variável], cab[Descrição],
    [Independente], [Representação navegável],
    [Grade 2.5D, grade voxelizada, grafo de vértices e grafo dual],
    [Independente], [Algoritmo de busca],
    [Dijkstra, A\*, Weighted A\* ($w$ = 1,5) e GBFS],
    [Independente], [Parâmetro de geração],
    [Escala, lacunaridade, persistência e comprimento de onda (testados
      separadamente)],
    [Desempenho], [Tempo de busca],
    [Tempo da busca, sem a construção do grafo],
    [Desempenho], [Vértices expandidos], [Esforço da busca],
    [Desempenho], [Pico da lista aberta],
    [Maior número de elementos simultâneos na lista aberta],
    [Qualidade], [Custo relativo],
    [Custo do caminho ÷ custo do Dijkstra no mesmo par de consulta],
  )))
]

// --------------------------------------------------------------- Slide 15 ---
#slide(
  nota: [Intel Core i5-1235U, Arch Linux em pendrive, GCC 16.2.1 em modo
    Release, busca fixada em um núcleo e turbo desligado.],
  continua: true,
)[Níveis e procedimento][
  #align(center, block(width: 96%, tabela(
    columns: (auto, 1fr, 1fr),
    align: left + horizon,
    cab[Teste], cab[Níveis], cab[Parâmetros fixos],
    [Escala], [500, 600, 700, 800 \ #text(size: 10pt)[(altura = dimensão,
      onda = metade)]], [$l$ = 2, $p$ = 0,5],
    [Lacunaridade], [1,5; 1,75; 2; 2,25], [dimensão 500, onda 250, $p$ = 0,5],
    [Persistência], [0,3; 0,433; 0,567; 0,7], [dimensão 500, onda 250, $l$ = 2],
    [Comp. de onda], [200, 275, 350, 500], [dimensão 500, $l$ = 2, $p$ = 0,5],
  )))
  #v(12pt)
  #set text(size: 13pt)
  - Seis oitavas em todos os testes; um parâmetro varia por vez; altura
    máxima $H$ igual à dimensão ($H$ = 500 fora da escala).
  - 50 terrenos por nível (5 execuções × 10), com sementes derivadas de uma
    semente base: todas as representações medem os mesmos terrenos.
  - Duas consultas por terreno, nas diagonais, de canto a canto.
  - Cada busca é executada uma vez sem medição antes de ser cronometrada.
]

// --------------------------------------------------------------- Slide 16 ---
#slide(
  nota: [Custo relativo analisado só para WA\* e GBFS: o do Dijkstra é 1 por
    definição, e o do A\* também, pois a heurística é consistente.],
)[Protocolo estatístico][
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 24pt,
    align: top,
    [
      #text(weight: "bold", fill: verde)[Modelo]
      #v(4pt)
      - Unidade experimental: o terreno.
      - Métricas em escala logarítmica (média dos logs das duas consultas).
      - ANOVA em modelo _split-plot_:
        - entre terrenos: nível do parâmetro;
        - dentro do terreno: algoritmo e representação.
      - Correção de Greenhouse-Geisser; $alpha$ = 0,05.
    ],
    [
      #text(weight: "bold", fill: verde)[Após a ANOVA]
      #v(4pt)
      - Teste de Tukey dentro do terreno (representações por algoritmo e
        algoritmos por representação) e entre níveis.
      - Efeitos reportados por $eta^2_p$ e pela razão entre os níveis
        extremos.
      - Normalidade dos resíduos verificada por Shapiro-Wilk.
    ],
  )
]

// --------------------------------------------------------------- Slide 17 ---
#slide(
  nota: [Grafo de vértices; mapa de altura de 256 × 256 px, semente 42,
    4 oitavas.],
)[Visualizador IFCG][
  #grid(
    columns: (300pt, 1fr),
    column-gutter: 24pt,
    align: horizon,
    image("images/cena.png", width: 300pt),
    [
      - Motor gráfico próprio, usado para visualizar as malhas e os
        caminhos encontrados.
      - Ruído, geometria e grafo são gerados em _threads_ trabalhadoras; a
        criação das malhas e o envio à GPU ficam na _thread_ principal.
      - Não participa da coleta das métricas de busca.
      #v(10pt)
      #set text(size: 13pt)
      #let ponto(c, t) = [#text(fill: c)[●] #t]
      #ponto(rgb("#D62728"))[Dijkstra] \
      #ponto(rgb("#1F5FD6"))[A\*] \
      #ponto(rgb("#2CA02C"))[Greedy Best-First Search] \
      #ponto(rgb("#8E44AD"))[Weighted A\*]
    ],
  )
]

// --------------------------------------------------------------- Slide 18 ---
#slide(
  nota: [Médias geométricas dos terrenos, em ms. Detalhes da ANOVA e do
    Tukey nos apêndices da monografia.],
)[Tempo de busca][
  #align(center, block(width: 92%, tabela(
    columns: (auto, 1fr, 1fr, 1fr, 1fr),
    align: (left, right, right, right, right),
    cab[Fator], cab[Escala], cab[Lacunaridade], cab[Persistência],
    cab[Comp. de onda],
    [Dijkstra], [386,0], [212,7], [243,1], [203,9],
    [A\*], [414,1], [220,7], [255,6], [212,8],
    [Weighted A\*], [104,3], [48,5], [68,5], [33,7],
    [GBFS], [2,3], [1,4], [1,7], [1,3],
    table.hline(stroke: 1pt + verde),
    [Grade 2.5D], [33,0], [18,0], [21,5], [15,6],
    [Grade voxelizada], [43,6], [25,5], [27,0], [24,7],
    [Grafo de vértices], [110,4], [57,4], [76,2], [47,9],
    [Grafo dual], [244,7], [122,3], [160,9], [106,0],
  )))
  #v(10pt)
  #set text(size: 13pt)
  - A mesma ordem nos quatro testes: GBFS < WA\* < Dijkstra < A\* e
    grade 2.5D < grade voxelizada < grafo de vértices < grafo dual.
]

// --------------------------------------------------------------- Slide 19 ---
#slide(
  nota: [Tabela: teste de escala, médias geométricas. Faixas do texto: os
    quatro testes. Hipótese não isolada experimentalmente.],
)[Esforço de busca e tempo][
  #align(center, block(width: 85%, tabela(
    columns: (auto, 1fr, 1fr, 1fr),
    align: (left, right, right, right),
    cab[Algoritmo], cab[Tempo (ms)], cab[Vértices expandidos],
    cab[Pico da lista aberta],
    [Dijkstra], [386,0], [860 130], [2 048],
    [A\*], [414,1], [660 544], [4 180],
    [Weighted A\*], [104,3], [154 972], [6 743],
    [GBFS], [2,3], [1 797], [2 882],
  )))
  #v(10pt)
  #set text(size: 13pt)
  - O A\* expande de 23% a 27% menos vértices que o Dijkstra, mas não é
    mais rápido: na grade 2.5D (35% a 42% menos expansões) não diferem; na
    voxelizada (cerca de 3%, não significativo) o A\* leva 1,22 a 1,26 vez
    o tempo do Dijkstra.
  - O pico da lista aberta do A\* é cerca do dobro do Dijkstra: hipótese de
    maior custo por vértice (fila de prioridade e cálculo da heurística).
  - A ordem das representações depende do algoritmo ($eta^2_p$ entre 0,89 e
    0,93): Dijkstra é mais lento na grade 2.5D que na voxelizada, e a WA\*, o
    contrário.
]

// --------------------------------------------------------------- Slide 20 ---
#slide(
  nota: [O custo relativo usa o Dijkstra de cada representação como
    referência e não é diretamente comparável entre representações.],
)[Custo relativo][
  #grid(
    columns: (1fr, 250pt),
    column-gutter: 20pt,
    tabela(
      columns: (auto, 1fr, 1fr, 1fr, 1fr),
      align: (left, right, right, right, right),
      cab[Fator], cab[Esc.], cab[Lac.], cab[Pers.], cab[Onda],
      [WA\*], [1,037], [1,034], [1,030], [1,036],
      [GBFS], [1,228], [1,204], [1,281], [1,179],
      table.hline(stroke: 1pt + verde),
      [Grade 2.5D], [1,123], [1,099], [1,142], [1,087],
      [Grade voxel.], [1,116], [1,105], [1,137], [1,095],
      [Grafo de vért.], [1,157], [1,145], [1,173], [1,133],
      [Grafo dual], [1,118], [1,115], [1,142], [1,107],
    ),
    [
      #set text(size: 13pt)
      - O algoritmo é o fator de maior efeito ($eta^2_p$ entre 0,978 e
        0,989).
      - A WA\* fica em torno de 1,03 vez o custo do Dijkstra.
      - A GBFS fica entre 1,18 e 1,28 vez.
      - O grafo de vértices tem o maior custo relativo médio em todos os
        testes.
    ],
  )
]

// --------------------------------------------------------------- Slide 21 ---
#slide(
  nota: [Tempo em ms, média geral de algoritmos e representações; todos os
    efeitos de nível no tempo com p < 0,001.],
)[Efeito das características do terreno][
  #align(center, block(width: 96%, tabela(
    columns: (auto, 1fr, 1fr, 1fr, auto, auto),
    align: (left, right, right, right, right, right),
    cab[Teste], cab[Nível 1], cab[Nível 4], cab[Razão 4/1],
    cab[$eta^2_p$], cab[Custo rel. 4/1],
    [Escala], [46,1 (500)], [129,7 (800)], [2,81], [0,901],
    [1,006 (p = 0,059)],
    [Lacunaridade], [29,6 (1,5)], [65,9 (2,25)], [2,23], [0,853], [1,088],
    [Persistência], [27,5 (0,3)], [112,5 (0,7)], [4,09], [0,951], [1,185],
    [Comp. de onda], [58,6 (200)], [24,1 (500)], [0,41], [0,885], [0,921],
  )))
  #v(10pt)
  #set text(size: 13pt)
  - A escala aumenta o esforço sem alterar significativamente a qualidade
    relativa do caminho.
  - Lacunaridade e persistência, que aumentam o detalhe do relevo, elevam
    tempo, expansões e custo; um comprimento de onda maior os reduz.
  - A persistência tem o maior efeito: o tempo quadruplica entre os níveis
    extremos.
]

// --------------------------------------------------------------- Slide 22 ---
#slide(
  nota: [Média geométrica dos terrenos; barras: intervalo de confiança de
    95%.],
)[O efeito do terreno depende da combinação][
  #grid(
    columns: (330pt, 1fr),
    column-gutter: 18pt,
    align: horizon,
    image("images/pers_tempo.png", width: 330pt),
    [
      #set text(size: 13pt)
      - Na persistência, a interação nível × representação tem
        $eta^2_p$ = 0,915.
      - O tempo da WA\* cresce 39,93 vezes na grade 2.5D e 34,49 vezes no
        grafo de vértices, mas só 2,44 vezes na voxelizada.
      - O custo relativo da GBFS aumenta por um fator entre 1,34 e 1,63; o
        da WA\* diminui levemente.
      - No Dijkstra, as expansões nas grades não respondem à lacunaridade, à
        persistência nem ao comprimento de onda.
    ],
  )
]

// --------------------------------------------------------------- Slide 23 ---
#slide(
  nota: [Os grafos de vértices e dual não lideram nenhum critério nos
    terrenos testados, sem cavidades nem estruturas sobrepostas.],
)[Recomendações][
  #set par(justify: false)
  #tabela(
    columns: (150pt, 140pt, 1fr),
    align: left + horizon,
    cab[Prioridade], cab[Combinação], cab[Ressalvas],
    [Menor tempo de busca], [GBFS na grade 2.5D],
    [Caminhos de 18% a 28% mais caros que o de referência, com excesso que
      cresce com a persistência.],
    [Caminho ótimo e menor pico da lista aberta],
    [Dijkstra na grade voxelizada],
    [Ótimo no grafo voxelizado (altura discretizada, vizinhança de 4
      direções); custo não comparável ao das outras representações.],
    [Equilíbrio entre tempo e custo], [Weighted A\* na grade 2.5D],
    [Custo cerca de 3% acima do de referência e maior pico da lista aberta.
      Com persistência alta, o tempo supera o do Dijkstra na voxelizada.],
  )
  #v(10pt)
  #text(size: 12pt, fill: cinza)[Considerando o tempo de busca, o pico da
    lista aberta e o custo relativo, sem o tempo de construção dos grafos.]
]

// --------------------------------------------------------------- Slide 24 ---
#slide[Conclusão][
  - A representação navegável e as características do terreno alteram o
    desempenho, mas o sentido e a magnitude do efeito dependem do algoritmo.
  - Não há uma combinação melhor em todos os critérios: a escolha depende da
    prioridade (tempo, esforço ou qualidade do caminho).
  - A GBFS é a mais rápida, com caminhos de 18% a 28% mais caros; o A\*
    expande menos que o Dijkstra sem reduzir o tempo; a WA\* é o meio-termo,
    com picos maiores da lista aberta.
  - Objetivos cumpridos: biblioteca de grafos estendida e quatro
    algoritmos, gerador com os parâmetros testados, quatro representações,
    coleta automatizada com ANOVA e Tukey, e visualizador 3D concorrente.
]

// --------------------------------------------------------------- Slide 25 ---
#slide[Limitações e trabalhos futuros][
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 24pt,
    align: top,
    [
      #text(weight: "bold", fill: verde)[Limitações]
      #v(4pt)
      #set text(size: 13pt)
      - Resíduos não normais: valores de p lidos com cautela.
      - Weighted A\* avaliado apenas com $w$ = 1,5.
      - Custo relativo não comparável entre representações.
      - Apenas terrenos de ruído de Perlin, um computador e sem obstáculos
        dinâmicos.
      - Consultas só de canto a canto: o Dijkstra percorre o grafo inteiro.
      - Comparação entre representações mistura estrutura e geometria.
      - Construção dos grafos e Marching Cubes fora da análise estatística
        (apenas descritivos).
    ],
    [
      #text(weight: "bold", fill: verde)[Trabalhos futuros]
      #v(4pt)
      #set text(size: 13pt)
      - Terrenos reais.
      - Obstáculos dinâmicos.
      - Outros pesos da Weighted A\*.
      - Incluir o custo de construção dos grafos na análise.
    ],
  )
]

// --------------------------------------------------------------- Slide 26 ---
// Só as obras citadas nos slides, a partir do .bib da monografia.
#slide[Referências][
  #set text(size: 10pt)
  #set par(spacing: 8pt, leading: 0.35em, justify: false)
  #bibliography(
    "./referencias.bib",
    style: "./associacao-brasileira-de-normas-tecnicas.csl",
    title: none,
    full: false,
  )
]

// --------------------------------------------------------------- Slide 27 ---
#capa()
