# TODO — Imagens do TCC

- [ ] `fig_componentes_conexos` (l. 532): grafo não direcionado com 2–3 componentes conexos destacados
- [x] Oitavas individuais (perto de l. 921): cada oitava do ruído separada (1ª a 6ª) + a soma final
- [x] `fig_pipeline` (l. 1088): semente → mapa de altura → voxels → malha → grafo → associar os pares de consulta → busca → métricas/ANOVA
- [x] `fig_mesh_composite` (l. 1121): diagrama de classes `MeshBase` / `Mesh` / `MeshTree` (Composite)
- [x] `fig_cena_visualizador` (l. 1159): captura de tela do visualizador renderizando uma cena

## Refazer as figuras das representações (`2_5d`, `voxel`, `vertex`, `dual`)

Por que estão fracas hoje (`src/main.cpp`, função `test`):
- Grafo em cinza-escuro `{0.26, 0.26, 0.30}` com alfa 0,25, sobre um terreno que a iluminação deixa cinza-escuro.
- Linha de 1 px: `test` não chama `glLineWidth`; só `testHeuristics` chama (l. 611–616).
- Vértices não aparecem; só as arestas. Entre `vertex` e `dual`, a diferença é justamente onde ficam os vértices.
- O recorte tem ~480 px de uma janela de 1200×800. É pouco para um slide.

### Mudanças no `test` (opções novas propostas)

- [x] `--line-width <px>` (padrão 1): `glLineWidth`, limitado pelo `GL_ALIASED_LINE_WIDTH_RANGE`, como em `testHeuristics`
- [x] `--point-size <px>` (padrão 0 = desligado): desenha os vértices do grafo como `GL_POINTS` com `glPointSize`
      (o shader não escreve `gl_PointSize`, então `glPointSize` basta)
- [x] `--nav-color r,g,b,a` (padrão o atual): cor das arestas
- [x] `--point-color r,g,b,a`: cor dos vértices
- [x] `--terrain-color r,g,b,a` (padrão `0.82,0.79,0.72,1`): cor da malha
- [x] `--window LxA` (padrão `1200x800`): tamanho da janela, para a captura sair em resolução maior
- [x] `--no-paths`: começa com os caminhos ocultos (hoje é preciso apertar `X`)
- [ ] (opcional) `--wave <px>`: o `save` tem, o `test` não; hoje o relevo só é ajustável por `--freq`

### Sugestão de valores

- Terreno claro e neutro, grafo escuro e saturado, vértices em cor de contraste. Assim a figura funciona impressa em P&B e no projetor.
  - terreno: `0.85,0.85,0.85,1`
  - arestas: `0.10,0.30,0.75,1` (azul, alfa 1)
  - vértices: `0.85,0.25,0.10,1` (laranja-avermelhado)
- Espessura: arestas 3 px e vértices 7–8 px numa janela de 1920×1080. Se aumentar a janela, aumente as espessuras na mesma proporção.
- Os 4 com a mesma semente, o mesmo terreno e a mesma câmera (teclas `I`/`O`). Terreno pequeno, para as células ficarem distinguíveis.

```fish
# mesma base para as 4; trocar só a representação e o nome do arquivo
for g in 2_5d voxel vertex dual
    ./tcc test $g --width 8 --height 8 --intensity 8 --octaves 6 --freq 4 --seed 42 --line-width 3 --point-size 8  --terrain-color 0.85,0.85,0.85,1 --nav-color 0.10,0.30,0.75,1 --point-color 0.85,0.25,0.10,1 --no-paths
end
```
(`width`/`height`/`intensity`/`freq` são ponto de partida: ajustar até o relevo ter um degrau visível e as células não ficarem miúdas)

- [x] Implementar as opções acima no `test` (exceto `--wave`)
- [x] Gerar `2_5d.png`, `voxel.png`, `vertex.png`, `dual.png` com a mesma semente e a mesma câmera
- [x] Atualizar as legendas de `fig_grade_25d`, `fig_grade_voxelizada`, `fig_grafo_vertices` e `fig_grafo_dual` com os parâmetros (`Nota:`, como nas de ruído)
- [ ] Decidir sobre `fig_representacoes_terreno` (l. 1230): remover ou montar a partir das 4 imagens novas, se couber em outro lugar
