# Corre??es de controles, abismo, inimigo azul e morte

- Jogador 1 (e solo): A/D movimento, W salto normal, Q segurar e soltar para salto carregado/dash, E construir.
- Jogador 2: setas esquerda/direita movimento, seta para cima salto normal, Shift direito segurar e soltar para salto carregado/dash, Enter construir.
- Salto normal: impulso imediato -11, sem carga. Dash: carga m?xima de 150 frames (2,5 s a 60 FPS), soltar para impulso horizontal; dire??o escolhida durante a carga ou a dire??o atual do personagem.
- Abismo central: x=540..826; o ch?o decorativo cont?nuo e o collider antigo de largura total foram desativados nas duas rooms. As duas margens e o vazio s?o desenhados com as mesmas coordenadas da colis?o.
- ?ltima vida perdida por qualquer jogador encerra a tentativa da equipe, inclusive em solo. O menu usa ?cones de tentar novamente e voltar ao t?tulo; A/D ou setas selecionam, E/Enter ou clique confirmam, Esc volta ao t?tulo. Tentar novamente mant?m modo e personagem selecionado.
- Inimigo azul: cinco recortes individuais, tr?s poses de flutua??o e duas de ataque. O shader remove a base branca irregular do arquivo original durante o desenho.

## Verifica??o

Compila??o Igor 2026.0.0.23 passou. O modo --qa-regression passou nos testes de colis?o das margens e abismo, salto normal imediato, carga, dash, menu de morte solo/cooperativo, rein?cio real da room mantendo solo e retorno ao t?tulo. Capturas de gameplay e menu verificadas visualmente em delivery/tests/controls_fix. N?o foi feita uma partida completa nem avalia??o humana de conforto das teclas.
