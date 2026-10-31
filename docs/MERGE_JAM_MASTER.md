# Integra??o jam/mvp-complete e master

A base de gameplay conserva salas, salto carregado, vida, cura, combate por salto,
inimigo voador e game over da master. A apresenta??o, imagens do atlas, narra??o
em ingl?s, cutscene e controles de ?udio v?m da jam. O idle respira tamb?m durante
o gameplay. A c?mera considera a m?dia dos jogadores ativos e vivos.

O contrato de obj_enemy agora inicializa kind, draw_height e os par?metros de
movimento no Create. O Step usa os tipos visuais da jam e mant?m dano e combate
da master. Isso corrige a leitura de kind n?o inicializado no Draw.

Verifica??o: compila??o Igor passou; uma execu??o automatizada entrou no gameplay
e chegou ao game over sem reproduzir o erro. O roteiro antigo de QA pressup?e a
torre curta e n?o valida a subida das salas maiores da master. N?o h? aprova??o
de uma partida completa nem teste manual da cena final nesta integra??o.
