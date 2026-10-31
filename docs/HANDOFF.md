# Continuacao para Natan e Guilherme

Base preservada: master em 938089d (ESTAGIO 3). Trabalho novo na branch jam/mvp-complete. Nao houve push ou merge em master.

Abra/reabra gameJam.yyp para que o editor carregue os novos objetos e scripts; evite salvar um editor antigo com buffers de antes da troca de branch. O projeto continua inteiramente GameMaker.

- obj_game: inicio/introducao/jogo/final, suprimento, plataformas, camera, teste e reinicio.
- scr_mvp: estado por jogador, movimento/coleta/construcao e desenho compartilhados; entradas de P1/P2 continuam em seus Steps.
- obj_world_solid: pai dos objetos fisicos. obj_ground/obj_build_block: chao, blocos e plataformas (flag is_checkpoint).
- scr_world_collision: retangulos contra instancias, pouso e tratamento de plataformas atravessaveis por baixo.
- obj_enemy: uma patrulha e recuperacao. Sem combate e sem habilidades exclusivas no MVP.

Room1 tem 1366x1536; viewport1366x768; chao y1408; descansos y1216,1024,832,640 e448. O topo exige ambos pousados. Inventarios separados; um material/bloco; E/Enter colocam a frente. Materiais sao gerados pelo controlador, nao mais pelo P1.

Para build: powershell -ExecutionPolicy Bypass -File tools/build_windows.ps1
Para teste completo da build: tools/run_qa.ps1 ; para queda/inimigo: tools/run_qa.ps1 -Recovery
O teste entra por flags de linha de comando; Jogar.cmd nao usa essas flags. O QA injeta somente acoes (mover/saltar/construir); nao teleporta para o topo, nao concede materiais e nao ignora inimigos. Recuperacao usa o mesmo metodo do jogo.

Propriedade de arquivos: um integrador edita .yyp e Room1. Mudancas em controles/render compartilhado pertencem a scr_mvp; arte entra separada e substituivel, conforme ART_AND_SOURCES. Nao executar scripts de authoring de planilha sem revisar caminhos. tools/node_modules e os binarios exportados sao ignorados pelo Git; arte e logica continuam no repositorio.

Pendencias externas: enviar no canal da organizacao; confirmar eventual ID oficial de equipe; rodada humana de conforto/ghosting. Sem bloqueio tecnico observado no fluxo automatizado.

Codigo do MVP: 9cde5a3. Pacote final: delivery/JUNTOS_Entrega.zip. Relatorios e hashes em delivery/tests e MANIFEST.json.

Regra atual de morte: checkpoint_level identifica o trecho ate o proximo checkpoint. Cada bloco tem section_id pela altura (trechos de192px). scr_player_recover apaga os blocos construidos de ambos nessa secao, preserva is_checkpoint e demais secoes, e conserva o estoque sem reembolso. Teste focado: tools/run_qa.ps1 -SectionReset.

Mudanca de morte e limpeza por secao: commit d2ce2bf. Os replays e a fixture de secoes foram executados na build com essa regra.
