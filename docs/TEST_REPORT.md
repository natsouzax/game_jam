# Verificacao do MVP JUNTOS

Fonte de jogo: d2ce2bf9b77581650432906abadbaaa6a2ba18cd. Base preservada: 938089d. Runtime GameMaker 2026.0.0.23, Windows x64/DirectX11. Executavel testado e o da pasta delivery/windows; o engine exportado existente tem hash identico ao Runner instalado. O arquivo data.win testado tem SHA256 3F533A950BB32EA32024AF7B27C8A8A1D4685D44BF6FD086AED2FC52BC10E9F5.

## Execucoes reais

| Verificacao | Partida normal | Queda e patrulha |
|---|---:|---:|
| Quadros de simulacao ate final/reinicio | 1307 | 3678 |
| Materiais coletados P1 / P2 | 17 / 4 | 38 / 34 |
| Blocos construidos P1 / P2 | 11 / 4 | 16 / 11 |
| Uso de blocos do parceiro P1 / P2 | 4 / 6 | 4 / 4 |
| Quadros com movimento dos dois | 173 | 266 |
| Checkpoint de topo dos dois | 5 / 5 | 5 / 5 |
| Quedas recuperadas P1 | 0 | 1 |
| Contatos com inimigo P2 | 0 | 1 |
| Blocos removidos nas mortes P1 / P2 | 0 / 0 | 10 / 2 |
| Final e reinicio verificados | Sim | Sim |

Entrada do titulo, introducao, queda, coleta, consumo de materiais, construcao pelos dois, colisao, camera vertical, uso da torre comum, chegada conjunta e final ocorreram no motor real. O teste de reinicio chama room_restart e verifica titulo ativo, estoques zerados e somente cinco plataformas iniciais. Recuperacoes verificam conservacao do estoque e remocao restrita aos blocos construidos da secao do checkpoint atual, incluindo os de ambos os jogadores. Plataformas fixas e outras secoes permanecem. Os replays de partida completa injetam acoes nos mesmos metodos dos controladores: nao concedem itens, nao teleportam ao topo e nao ignoram inimigos. A unica reposicao de posicao da partida completa e a recuperacao normal do proprio jogo.

O teste focado de secoes usa uma fixture separada: cria blocos identificados em tres secoes e inventarios conhecidos, chama a mesma recuperacao e verifica IDs. Removeu dois blocos da secao1 (dos dois construtores), manteve as secoes0/2 e as cinco plataformas, retornou ao checkpoint e conservou o estoque. Depois verificou tambem a limpeza da secao0, mantendo a secao2. Resultado: True. A fixture nao e usada como evidencia de progressao; as duas partidas completas acima sao por acoes.

A simulacao e acelerada; numero de quadros nao e tempo de conclusao de pessoas nem medida de diversao. Capturas QA sao produzidas pelo motor apos desenhar. O executavel tambem abriu sem argumentos, carregando data.win na pasta distribuida. A API de controle da interface ficou indisponivel (native pipe), portanto nao foi feito teste final com teclas fisicas.

## Correcoes motivadas pelos testes

1. Material nascia dentro de cobertura: geracao agora considera o teto e nasce abaixo dele.
2. Plataformas de descanso bloqueavam saltos: passaram a permitir atravessar de baixo para cima. Blocos do jogador continuam solidos.
3. Verificacao de apoio incluia o corpo inteiro: agora consulta apenas a faixa dos pes.
4. Vitoria acontecia antes do pouso: exige ambos apoiados no topo.
5. Recuperacao de queda maior que 160 px e por inimigo volta ao checkpoint e limpa apenas a secao atual. Estoque, plataformas fixas e outras secoes sao preservados; material gasto nao e devolvido.
6. Recortes de idle foram medidos por componentes de alpha e normalizados com origem nos pes.

## LDMT e requisitos

A apresentacao oficial pede build Windows ou WebGL e LDMT preenchida. Foram mantidas as copias Plan e Final, com 1.512 formulas do original e IDs fixos preservados. Os pesos sao propostas de planejamento justificadas; nao representam dificuldade empirica. O grafico e seus caches foram atualizados e os XMLs validados. A planilha nao foi testada no Excel instalado; abrir/recalcular no Excel e uma verificacao recomendada de compatibilidade, nao uma alegacao ja realizada.

Apenas uma chamada draw_text existe no jogo, com o titulo JUNTOS. Multiplayer e chegada conjunta sao demonstrados pelos testes. Seis avatares simbolicos representam a equipe. Sem audio e sem alegacao de paleta de cinco cores.

## Limites e teste humano recomendado

Nao houve rodada com duas pessoas nem teste de ghosting, conforto, clareza narrativa ou diversao. Nao houve teste em outro PC limpo. Antes de apresentar: extrair ZIP, ambos confirmam com W/Cima, cada um coleta e constroi, saltar nos blocos, deixar um parceiro para tras, tocar a patrulha, recuperar, ambos pousar no topo e reiniciar. Em teclado com ghosting, usar teclado USB que aceite as combinacoes. Sem publicacao ou envio automatico.
