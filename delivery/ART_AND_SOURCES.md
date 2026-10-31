# Arte, narrativa e fontes

## Revisao visual aprovada em31/10/2026

Natan aprovou P1 grisalho/oculos/ciano, P2 bone/ambar e drone vermelho simplificados. Substituem o desenho dos personagens/patrulha em execucao; arte antiga abaixo preservada como historico. Atlas RGBA1536x1024 gerado/editado com imagegen integrado; origem, prompt e medidas em art/README.md e scr_presentation. Nao tem celulas uniformes: recortes medidos por alpha, escala comum por personagem, origem nos pes, sem filtro. Altura visual80px; colisao32x70 mantida. Poses parado/dois passos/salto; sinal da escala horizontal espelha a direcao. Contrato de futura arte manual: PNG individual32x48 com pes(16,48).

Menu por silhuetas escolhe solo/cooperativo e retrato no solo. Abertura visual12s: ruinas/artefato, revelacao divina, caminho compartilhado. E/Enter pula. Somente JUNTOS aparece como texto. O solo e opcional; a experiencia coop e chegada conjunta continuam. Narrativa original permanece fonte, sem dialogo inventado.

## Inventario anterior preservado

Fontes consultadas (somente leitura): Halloween_Game_Jam_Abertura_2026.pdf, LDMT_Game_Jam_Tutorial.pdf e LDMT_Game_Jam.xlsx em OneDrive/Documentos/ChatGPT/GameJam; Mundo Apocaliptico.pptx em Downloads; Ideia_1_Escopo_Inicial_v0.1-v0.3.md em GameJam/outputs. A v0.3 e o pedido atual substituem a proposta antiga de duas torres e final de quatro pessoas.

A equipe documentada e Natan, Guilherme, Luiz, Emmanuel, Vanessa e Vitally. A associacao dos seis avatares finais e uma representacao simbolica proposta pelo coordenador. Nao foram inventadas fotografias, nomes ou retratos. Cores, da esquerda: ciano, ambar, roxo, coral, verde, azul.

Recursos existentes mantidos: sprites de P1/P2, folha idle do P1, cena ChatGPT_Image_31_Oct_2026__02_56_25, quatro quadros da fogueira, camada decorativa inferior. A pasta outputs possui mais sprites; apenas os adequados ja importados foram usados. O P2 usa a arte de sobrevivente disponivel no projeto, nao a personagem feminina da proposta inicial. As imagens foram fornecidas/geradas durante a conversa da jam; nao foi feita verificacao independente de direitos ou de sua data de criacao. Informar geracao por IA na pagina de entrega, se solicitado pela organizacao.

Recortes medidos por alpha, nao pela suposicao de quadros iguais. P1 run: [0,30,290,430], [299,29,577,407], [596,30,887,430], [890,29,1183,430], [1186,30,1472,429], [1491,29,1756,427]. P1 idle: [219,90,522,627], [699,90,1008,627], [219,673,522,1207], [699,673,1002,1207]. P2 run e salto constam de scr_mvp.gml. Render normaliza para cerca de 86 px de altura e ancora os pes em y; a caixa de colisao e independente, 32x70. Transparencia RGBA conferida. Idle tem quatro poses/breve respiracao; movimento e salto selecionam recortes proprios. Inversao usa escala horizontal com sinal da direcao.

Blocos, patrulha, divindade simbolica, vegetacao, interface e seis avatares finais sao desenhos GML originais. Sem audio, sem recursos comerciais de Comix Zone/Terraria. Esses jogos sao referencias de direcao, nao fontes de arquivos.

## Contrato para Luiz e Emmanuel

Entregar PNG RGBA com fundo transparente, um arquivo por quadro. Personagens preferencialmente tela de 64x96, pes em (32,96), sem texto. Nomes p1_idle_00.png, p1_run_00.png, p1_jump_00.png, equivalentes p2; incluir JSON com ordem e duracao dos quadros. Margem e origem consistentes, pixel art sem filtro. Bloco 32x32 encaixavel; drone ate 48x40; cenario separado em fundo e primeiro plano. Nao substituir arquivos/GUIDs existentes manualmente durante integracao. Entregar em pasta art/incoming/<autor>; apenas integrador registra recursos no .yyp. Evitar alteracao simultanea de Room1 e gameJam.yyp.

## LDMT

As copias Plan e Final editam somente entradas e caches de resultados. 1.512 formulas e IDs do original foram preservados. Pesos sao propostas de design explicitamente justificadas, nao medidas de diversao nem valores emprestados do exemplo Black Evasion. O exportador artifact-tool reteve resultados antigos e removeu partes do pacote original; por isso os valores foram conferidos separadamente e mesclados no XML original para preservar validacoes, estilos, nomes e grafico. O grafico mantem referencias originais e caches atualizados; todos os XMLs foram lidos novamente. Excel pode recalcular ao abrir. Originais nao alterados.
