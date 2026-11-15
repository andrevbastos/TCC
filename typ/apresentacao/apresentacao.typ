// Apresentação do TCC — conversão do Google Slides (16:9, 720 × 405 pt).
// Posições e tamanhos convertidos de EMU para pt (1 pt = 12700 EMU).

#let verde-texto = rgb("#0B0F0D")
#let branco = rgb("#F2F5F3")
#let fonte = ("IBM Plex Sans", "Arial")

#set page(width: 720pt, height: 405pt, margin: 0pt)
#set text(font: fonte, lang: "pt", region: "br", fill: verde-texto)
#set par(leading: 0.4em, spacing: 0.4em)

// Número do slide no canto inferior direito.
#let numero = context place(
  top + left, dx: 667.1pt, dy: 367.2pt,
  box(width: 43.2pt, height: 31pt, align(right + horizon,
    text(size: 10pt, counter(page).display()))),
)

// ---------------------------------------------------------------- Slide 1 ---
#{
  // Faixa com o fundo de grafos (recorte vertical 16,58 % – 51,27 % da imagem).
  let faixa-h = 143.3pt
  place(top + left, dx: 25.2pt, dy: 28.2pt, box(
    width: 669.6pt, height: faixa-h, radius: 23.9pt, clip: true,
    place(top + left, dy: -0.1658 * faixa-h / 0.3469,
      image("assets/grafos.png", width: 669.6pt,
        height: faixa-h / 0.3469, fit: "stretch")),
  ))

  // Título.
  place(top + left, dx: 92.1pt, dy: 54.9pt, box(
    width: 535.7pt, height: 58.9pt,
    align(center + horizon, text(size: 24pt, weight: "bold", fill: branco)[
      Algoritmos de busca de caminho em \
      representações navegáveis tridimensionais
    ]),
  ))

  // Subtítulo.
  place(top + left, dx: 120.4pt, dy: 113.7pt, box(
    width: 479.1pt, height: 33.5pt,
    align(center + horizon, text(size: 18pt, fill: branco)[
      Uma análise comparativa e estatística
    ]),
  ))

  // Autoria e instituição.
  place(top + left, dx: 125.4pt, dy: 195.7pt, box(
    width: 469.2pt, inset: 7.2pt,
    align(center)[
      #text(size: 20pt)[André Vitor Bastos de Macêdo] \
      #text(size: 20pt)[Orientador: Prof. Paulo César Rodacki Gomes]
      #v(20pt)
      #text(size: 16pt, style: "italic")[Instituto Federal Catarinense] \
      #text(size: 16pt, style: "italic")[Campus Blumenau]
      #v(16pt)
      #text(size: 18pt)[2026]
    ],
  ))

  // Logo do IFC.
  place(top + left, dx: 516.8pt, dy: 326.7pt,
    image("assets/logo-ifc.png", width: 177.2pt, height: 58.9pt))

  numero
}
