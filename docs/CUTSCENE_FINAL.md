# Cutscene final (GameMaker)

O gatilho e a chegada dos jogadores ativos ao topo. A sequencia usa 4780 quadros a 60 FPS (cerca de 80 s) e e silenciosa: so imagem, sem dialogo. E/Enter salta para o cartao final apos os primeiros 30 quadros. W/Cima reinicia a partida quando o cartao ja mostra a dica. Durante a cutscene, todo o audio e interrompido.

A ideia: a divindade ate consegue mostrar um mundo melhor, mas nao o constroi; quem precisa fazer isso sao os jogadores. O jogo acaba, os quatro jogadores se olham e percebem que quem precisa mudar sao eles. Cada um sai sozinho e faz uma coisa boa pelo mundo.

| Quadros | Tempo | Quadro-chave |
| --- | --- | --- |
| 0-780 | 0-13 s | Jogo na tela: ruinas ao por do sol; a divindade estala os dedos e mostra a cidade restaurada, mas a visao se desfaz. Ela abre as maos vazias (nao vai reconstruir nada), aponta para cada protagonista e depois para a muda. Some, e os dois afastam o entulho |
| 780-1090 | 13-18 s | A camera recua e revela que era a TV de uma sala com quatro jogadores |
| 1090-1580 | 18-26 s | A TV apaga, os quatro recuperam a cor e se olham, um a um |
| 1580-1820 | 26-30 s | Na TV apagada reaparece a silhueta da divindade apontando para fora da tela, para eles. Um brilho quente sobre cada um (a ficha cai); levantam-se e saem sozinhos |
| 1820-3900 | 30-65 s | Quatro cenas de 520 quadros, uma por pessoa, com zoom lento: varrer a praca, levar uma lanterna a um vizinho, plantar mudas no canteiro, regar as flores |
| 3900-4600 | 65-77 s | Plano aberto: a cidade vai se curando enquanto os quatro estao em pontos diferentes do terraco; a divindade aparece pequena no brilho do sol, de bracos abertos, e some |
| 4600-4780 | 77-80 s | Cartao final TOGETHER; a dica de reinicio aparece em 4780 |

A narrativa e mostrada em legendas em ingles na barra inferior (`scr_cut_caption`, 16 frases com fade, uma por trecho da tabela acima).

## Efeitos (2D, sem video externo)

Nao ha 3D real; a sensacao de profundidade vem de: fundo com parallax sobre os personagens, dolly/zoom com easing, luz aditiva (brilho, raios, feixe), particulas deterministicas (brasas, poeira, vaga-lumes), sombras no chao, vinheta e barras de cinema animadas. Os helpers estao em `scripts/scr_presentation/scr_presentation.gml` (`scr_cut_ease`, `scr_cut_glow`, `scr_cut_motes`, `scr_cut_post`).

Os protagonistas usam o atlas `spr_juntos_atlas`. Fundos e pessoas: `spr_cut_ruins`, `spr_cut_restored`, `spr_cut_room`, `spr_cut_yard`, `spr_cut_people`. Entulho, planta, divindade, vassoura, lanterna e regador sao composicoes em GML.
