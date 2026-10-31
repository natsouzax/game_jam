# Verificacao do MVP JUNTOS

Fonte de jogo: 9cde5a3ef17403ba5d4f9a678dc935df9208752f. Base preservada: 938089d. Runtime GameMaker 2026.0.0.23, Windows x64/DirectX11. Executavel testado e o da pasta delivery/windows; o engine exportado existente tem hash identico ao Runner instalado. O arquivo data.win testado tem SHA256 AD570E045E7F3BAE4A101FA625A8418C5633AED845049F05B1F9F40140971FAA.

## Execucoes reais

| Verificacao | Partida normal | Queda e patrulha |
|---|---:|---:|
| Quadros de simulacao ate final/reinicio | 1307 | 1689 |
| Materiais coletados P1 / P2 | 17 / 4 | 13 / 6 |
| Blocos construidos P1 / P2 | 11 / 4 | 9 / 6 |
| Uso de blocos do parceiro P1 / P2 | 4 / 6 | 5 / 5 |
| Quadros com movimento dos dois | 173 | 364 |
| Checkpoint de topo dos dois | 5 / 5 | 5 / 5 |
| Quedas recuperadas P1 | 0 | 6 |
| Contatos com inimigo P2 | 0 | 1 |
| Final e reinicio verificados | Sim | Sim |

Entrada do titulo, introducao, queda, coleta, consumo de materiais, construcao pelos dois, colisao, camera vertical, uso da torre comum, chegada conjunta e final ocorreram no motor real. O teste de reinicio chama room_restart e verifica titulo ativo, estoques zerados e somente cinco plataformas iniciais. Recuperacoes verificam conservacao de materiais e blocos. O modo QA injeta acoes nos mesmos metodos dos controladores: nao concede itens, nao teleporta ao topo e nao ignora inimigos. A unica reposicao de posicao e a recuperacao normal do proprio jogo.

A simulacao e acelerada; numero de quadros nao e tempo de conclusao de pessoas nem medida de diversao. Capturas QA sao produzidas pelo motor apos desenhar. O executavel tambem abriu sem argumentos, carregando data.win na pasta distribuida. A API de controle da interface ficou indisponivel (native pipe), portanto nao foi feito teste final com teclas fisicas.

## Correcoes motivadas pelos testes

1. Material nascia dentro de cobertura: geracao agora considera o teto e nasce abaixo dele.
2. Plataformas de descanso bloqueavam saltos: passaram a permitir atravessar de baixo para cima. Blocos do jogador continuam solidos.
3. Verificacao de apoio incluia o corpo inteiro: agora consulta apenas a faixa dos pes.
4. Vitoria acontecia antes do pouso: exige ambos apoiados no topo.
5. Recuperacao de queda maior que 160 px preserva estoque e torre; inimigo tambem usa esse mecanismo.
6. Recortes de idle foram medidos por componentes de alpha e normalizados com origem nos pes.

## LDMT e requisitos

A apresentacao oficial pede build Windows ou WebGL e LDMT preenchida. Foram mantidas as copias Plan e Final, com 1.512 formulas do original e IDs fixos preservados. Os pesos sao propostas de planejamento justificadas; nao representam dificuldade empirica. O grafico e seus caches foram atualizados e os XMLs validados. A planilha nao foi testada no Excel instalado; abrir/recalcular no Excel e uma verificacao recomendada de compatibilidade, nao uma alegacao ja realizada.

Apenas uma chamada draw_text existe no jogo, com o titulo JUNTOS. Multiplayer e chegada conjunta sao demonstrados pelos testes. Seis avatares simbolicos representam a equipe. Sem audio e sem alegacao de paleta de cinco cores.

## Limites e teste humano recomendado

Nao houve rodada com duas pessoas nem teste de ghosting, conforto, clareza narrativa ou diversao. Nao houve teste em outro PC limpo. Antes de apresentar: extrair ZIP, ambos confirmam com W/Cima, cada um coleta e constroi, saltar nos blocos, deixar um parceiro para tras, tocar a patrulha, recuperar, ambos pousar no topo e reiniciar. Em teclado com ghosting, usar teclado USB que aceite as combinacoes. Sem publicacao ou envio automatico.
