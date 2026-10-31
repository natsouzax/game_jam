# Verificacao do MVP JUNTOS

Fonte de jogo: 8a7f3bda3e9cb357684c112356832231f568e696. Base preservada: 938089d. Runtime GameMaker 2026.0.0.23, Windows x64/DirectX11. Executavel testado e o da pasta delivery/windows; o engine exportado existente tem hash identico ao Runner instalado. O arquivo data.win testado tem SHA256 9D4A8CB76E1CB95EF03449A916CB5549B8D19B3DBDAE3ED81CDE65BBDC2C85DF.

## Execucoes reais

| Verificacao | Partida normal | Queda e patrulha |
|---|---:|---:|
| Quadros de simulacao ate final/reinicio | 2061 | 4432 |
| Materiais coletados P1 / P2 | 17 / 4 | 38 / 34 |
| Blocos construidos P1 / P2 | 11 / 4 | 16 / 11 |
| Uso de blocos do parceiro P1 / P2 | 4 / 6 | 4 / 4 |
| Quadros com movimento dos dois | 173 | 266 |
| Checkpoint de topo dos dois | 5 / 5 | 5 / 5 |
| Quedas recuperadas P1 | 0 | 1 |
| Contatos com inimigo P2 | 0 | 1 |
| Blocos removidos nas mortes P1 / P2 | 0 / 0 | 10 / 2 |
| Final e reinicio verificados | Sim | Sim |

Menu de modo/personagem, tres cenas da abertura, queda, coleta, consumo de materiais, construcao pelos dois, colisao, camera vertical, uso da torre comum, chegada conjunta e final ocorreram no motor real. O teste de reinicio chama room_restart e verifica titulo ativo, estoques zerados e somente cinco plataformas iniciais. Recuperacoes verificam conservacao do estoque e remocao restrita aos blocos construidos da secao do checkpoint atual, incluindo os de ambos os jogadores. Plataformas fixas e outras secoes permanecem. Os replays de partida completa injetam acoes nos mesmos metodos dos controladores: nao concedem itens, nao teleportam ao topo e nao ignoram inimigos. A unica reposicao de posicao da partida completa e a recuperacao normal do proprio jogo.

O teste focado de secoes usa uma fixture separada: cria blocos identificados em tres secoes e inventarios conhecidos, chama a mesma recuperacao e verifica IDs. Removeu dois blocos da secao1 (dos dois construtores), manteve as secoes0/2 e as cinco plataformas, retornou ao checkpoint e conservou o estoque. Depois verificou tambem a limpeza da secao0, mantendo a secao2. Resultado: True. A fixture nao e usada como evidencia de progressao; as duas partidas completas acima sao por acoes.

A simulacao e acelerada; numero de quadros nao e tempo de conclusao de pessoas nem medida de diversao. Capturas QA sao produzidas pelo motor apos desenhar. O executavel tambem abriu sem argumentos, carregando data.win na pasta distribuida. As entradas foram automaticas; nao houve teste final com teclas fisicas nesta revisao.

## Correcoes motivadas pelos testes

1. Material nascia dentro de cobertura: geracao agora considera o teto e nasce abaixo dele.
2. Plataformas de descanso bloqueavam saltos: passaram a permitir atravessar de baixo para cima. Blocos do jogador continuam solidos.
3. Verificacao de apoio incluia o corpo inteiro: agora consulta apenas a faixa dos pes.
4. Vitoria acontecia antes do pouso: exige ambos apoiados no topo.
5. Recuperacao de queda maior que 160 px e por inimigo volta ao checkpoint e limpa apenas a secao atual. Estoque, plataformas fixas e outras secoes sao preservados; material gasto nao e devolvido.
6. Recortes de idle foram medidos por componentes de alpha e normalizados com origem nos pes.

## LDMT e requisitos

A apresentacao oficial pede build Windows ou WebGL e LDMT preenchida. Foram mantidas as copias Plan e Final, com 1.512 formulas do original e IDs fixos preservados. Os pesos sao propostas de planejamento justificadas; nao representam dificuldade empirica. O grafico e seus caches foram atualizados e os XMLs validados. A planilha nao foi testada no Excel instalado; abrir/recalcular no Excel e uma verificacao recomendada de compatibilidade, nao uma alegacao ja realizada.

As duas chamadas draw_text desenham o mesmo titulo JUNTOS (sombra e frente); nenhum outro texto e exibido. Multiplayer e chegada conjunta sao demonstrados pelos testes. Seis avatares simbolicos representam a equipe. Sem audio e sem alegacao de paleta de cinco cores.

## Limites e teste humano recomendado

Nao houve rodada com duas pessoas nem teste de ghosting, conforto, clareza narrativa ou diversao. Nao houve teste em outro PC limpo. Antes de apresentar: extrair ZIP, selecione duas silhuetas com A/D ou setas e confirme com E/Enter, cada um coleta e constroi, saltar nos blocos, deixar um parceiro para tras, tocar a patrulha, recuperar, ambos pousar no topo e reiniciar. Em teclado com ghosting, usar teclado USB que aceite as combinacoes. Sem publicacao ou envio automatico.

## Revisao visual, menu e solo

Arte simplificada aprovada por Natan: P1 grisalho/oculos/ciano, P2 bone/ambar e drone. Atlas transparente, recortes por alpha, escala comum, origem nos pes e inversao horizontal. Capturas do motor mostram ambos os personagens no inicio, selecao de retrato e tres cenas da abertura. Recursos anteriores preservados. Verificacao visual da transparência e da inversao horizontal nas capturas; nao houve avaliacao humana da fluidez.

Menu: cartao de uma/duas silhuetas; solo escolhe retrato; direcao navega, E/Enter confirma, S/Baixo volta. Replay coop entrou na selecao solo, voltou e iniciou coop pelo mesmo handler. Replays solo selecionaram cada retrato. Abertura12s com ruinas, artefato e chamado; tres cenas vistas por todos os replays. E/Enter pula apos1s; esse atalho ainda requer verificacao humana de tecla.

| Execucao solo | P1 | P2 |
|---|---:|---:|
| Quadros ate final/reinicio | 2188 | 2188 |
| Coletas do ativo | 25 | 25 |
| Blocos do ativo | 18 | 18 |
| Checkpoint do ativo | 5 | 5 |
| Personagem inativo sem coleta/construcao/recuperacao | Sim | Sim |
| Final/reinicio | Sim | Sim |

Solo usa A/D/W/E com qualquer personagem. Camera, material, colisao com inimigo, bloqueio da construcao e vitoria filtram participantes ativos. Cada replay solo encontrou a patrulha, recuperou e removeu3 blocos da secao antes de concluir. Todos os cinco relatorios correspondem ao mesmo SHA256 da build. LDMT Final3 revisa somente descricoes do menu/abertura e condicao de chegada; Plan, pesos, formulas e IDs preservados.
