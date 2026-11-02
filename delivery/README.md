# JUNTOS (TOGETHER)

Solo com escolha do personagem, ou cooperativo local para duas pessoas no mesmo teclado. Coletem materiais, construam a torre e subam ate o topo juntos, enfrentando inimigos e meteoros. O jogo tem duas salas: a torre principal e a sala final com o Demonio. Todos os participantes ativos precisam chegar ao topo.

## Executar
Extraia todo o ZIP e abra windows/Jogar.cmd (ou Play.cmd). Mantenha data.win e intro_story.mp4 ao lado do executavel. Windows 64 bits / DirectX 11; nao exige instalar o GameMaker.

## Menu
A/D ou Esquerda/Direita selecionam o cartao: uma silhueta = solo, duas = cooperativo. E/Enter confirma. No solo, escolha o retrato e confirme novamente; S/Baixo volta aos modos. E/Enter pula a abertura em video e as cenas introdutorias.

## Controles
| Acao | Solo, qualquer personagem / P1 (ciano) | P2 (ambar) | Controle |
|---|---|---|---|
| Mover e virar | A / D | Esquerda / Direita | Analogico esquerdo / D-pad |
| Saltar | W | Cima | A / Cruz |
| Construir | E | Enter | X / Quadrado |
| Dash carregado | Q | Shift direito | B / Circulo |
| Pausar | Esc ou P | Esc ou P | Select / Share |
| Mutar audio | M | M | - |
| Tela cheia | F11 | F11 | - |

O controle conectado comanda o P2 no coop, ou o personagem escolhido no solo. Teclado e controle funcionam juntos. Apertar Construir duas vezes em meio segundo sobre um bloco o quebra. Ao final, W ou Cima volta ao menu.

## Como jogar
- Encoste nos materiais que caem para coletar. Cada estoque e individual; cada bloco custa 1 material de quem construiu e e colocado a frente, na direcao em que o personagem olha.
- Pule em cima dos inimigos para derrota-los (slime, esqueleto, nave-meteoro, diabo, demonio). Tocar neles de lado, ser atingido por projeteis, foguinhos ou meteoros, ou cair no abismo custa uma vida (3 vidas por jogador).
- Coracoes recuperam vida e, no coop, reanimam o parceiro caido.
- Plataformas verdes sao checkpoints e atravessaveis por baixo. Meteoros destroem blocos construidos.
- Sem vidas, e sem parceiro para ajudar, aparece a tela de fim de jogo.

## Tema e sidequests
O mundo comeca em ruinas. Uma divindade aponta a missao. No final, a torre ganha vida e aparece no monitor de seis criadores. O mundo melhor nasce do que construiram juntos.

Multiplayer local, poucos comandos por jogador (mover, saltar, construir, dash) e seis avatares simbolicos que representam, da esquerda para a direita: Natan (ciano), Guilherme (ambar), Luiz (roxo), Emmanuel (coral), Vanessa (verde) e Vitally (azul). Nomes confirmados no escopo v0.3; aparencias simbolicas, nao retratos. O jogo tem musica e efeitos sonoros; nao reivindica sidequests de som por telefone ou cinco cores.

## Entrega
A apresentacao oficial exige Windows ou WebGL + LDMT preenchida. Prazo: domingo, 1 novembro 2026, 16h Lisboa. Envie o pacote com a pasta Windows e as planilhas Plan e Final, pelo canal indicado pela organizacao.

## Autoria
Codigo criado durante a jam sobre o projeto existente. Parte da arte e do video de abertura inclui imagens geradas com IA durante a jam. A narracao das cenas usa voz sintetizada (TTS) e a musica e os efeitos sao gerados por script (tools/generate_audio.py). Blocos, interface e avatares finais sao desenhos originais em GML. Comix Zone/Terraria sao referencias, sem reutilizacao de seus recursos. Detalhes em ART_AND_SOURCES.md.

## Teste
O fluxo foi exercitado por replays automaticos no Runner e por jogo manual. Suporte a controle fisico, ghosting com duas pessoas no mesmo teclado e compatibilidade em outro PC ainda nao foram verificados por humanos.
