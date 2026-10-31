# JUNTOS

Cooperativo local para duas pessoas. Coletem materiais, construam a mesma torre e alcancem o topo juntos. Ao morrer por queda ou patrulha, o personagem volta ao ultimo checkpoint e os blocos construidos pelos dois naquela secao desaparecem. Plataformas fixas e outras secoes permanecem. O estoque continua igual, sem reembolso dos blocos removidos.

## Executar
Extraia todo o ZIP e abra windows/Jogar.cmd ou windows/JUNTOS.exe. Mantenha data.win ao lado do executavel. Windows 64 bits / DirectX 11; nao exige instalar o GameMaker.

## Controles
| Acao | P1 (ciano) | P2 (ambar) |
|---|---|---|
| Mover e virar | A / D | Esquerda / Direita |
| Saltar | W | Cima |
| Construir | E | Enter |
| Confirmar inicio | W | Cima |
| Reiniciar depois do final | W ou Cima | W ou Cima |

Ambos confirmam o inicio. Encoste no material para coletar. Cada estoque e individual; cada bloco custa um material de quem construiu. E/Enter colocam na grade a frente conforme a direcao. Alvo ocupado nao gasta material. Salte pelos blocos e plataformas verdes. Estas permitem atravessar de baixo para cima e servem de recuperacao individual. Ambos precisam pousar no topo.

## Tema e sidequests
O mundo comeca em ruinas. Uma divindade aponta a missao. No final, a torre ganha vida e aparece no monitor de seis criadores. O mundo melhor nasce do que construiram juntos.

Multiplayer local, apenas JUNTOS como texto dentro do jogo e poucos comandos estao implementados. O salto tambem confirma o inicio e reinicia no final; direcao tambem escolhe o lado da construcao. Seis avatares simbolicos representam, da esquerda para a direita: Natan (ciano), Guilherme (ambar), Luiz (roxo), Emmanuel (coral), Vanessa (verde) e Vitally (azul). Nomes confirmados no escopo v0.3; aparencias simbolicas, nao retratos. Sem audio; nao reivindica sidequests de som por telefone ou cinco cores.

## Entrega
A apresentacao oficial exige Windows ou WebGL + LDMT preenchida. Prazo: domingo, 1 novembro 2026, 16h Lisboa. Envie o pacote com a pasta Windows e as planilhas Plan e Final. Nenhum upload foi feito. O canal de submissao e eventual codigo oficial da equipe nao constam das fontes acessiveis: use as indicacoes da organizacao.

## Autoria
Codigo do MVP criado nesta sessao sobre o projeto existente. Arte fornecida durante esta conversa/jam inclui imagens geradas com IA. Blocos, interface, patrulha e avatares finais sao desenhos originais em GML. Comix Zone/Terraria sao referencias, sem reutilizacao de seus recursos. Declaracao detalhada e limites dos testes em ART_AND_SOURCES.md e TEST_REPORT.md.

## Teste
O fluxo completo foi executado no Runner real com entradas deterministicas independentes para os dois jogadores, incluindo recuperacao e reinicio. Ainda recomendamos uma rodada com duas pessoas no teclado de apresentacao para avaliar conforto, ghosting e diversao.
