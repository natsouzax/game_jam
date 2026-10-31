# Arte simplificada v2

`reference/juntos_style_approved.png`: estudo aprovado por Natan. `reference/juntos_atlas_v2.png`: edicao para uso no jogo. Gerados com a ferramenta imagegen integrada nesta conversa; sem API externa configurada. Arte anterior mantida nos recursos originais.

Prompt de edicao: preparar o estudo aprovado como atlas transparente, preservando P1 grisalho/oculos/ciano e P2 bone/ambar, quatro poses por personagem (parado, dois passos, salto), drone vermelho na terceira linha; retirar fundo/halos/sombras suaves, manter contornos pixelados e paleta curta; sem palavras. O PNG possui alpha, mas a geracao nao garante uma grade regular nem pixels de tamanho perfeitamente uniforme.

Fonte 1536x1024, RGBA; importada sem alterar pixels em spr_juntos_atlas. Recortes medidos por alpha>128 em scr_presentation/scr_actor_pose. O jogo seleciona os quadros por indice e desenha somente seu retangulo. Pose usa escala comum por personagem, ancora nos pes e sinal horizontal da direcao; filtro de textura desligado. Altura em jogo80px; corpo fisico continua32x70.

Para arte substituta feita a mao: preferir PNG RGBA individual de32x48 por quadro, pes em(16,48), nomes p1_idle_00, p1_walk_00/01, p1_jump_00 e equivalentes p2. Mesma origem, sem halo. Entregar em art/incoming/<autor>; integrador adapta os metadados/registra recursos. A direcao32x48 e o contrato de substituicao proposto; o atlas gerado nao e uma exportacao exata nessa resolucao.
