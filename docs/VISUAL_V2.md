# Revisao visual, menu e modo solo

Direcao aprovada por Natan em 31/10/2026: personagens simplificados do estudo visual (P1 grisalho/oculos/ciano, P2 bone/ambar), inimigo vermelho com um olho. O estudo e direcao de arte, nao uma folha com celulas uniformes.

Escopo desta revisao: menu visual com selecao solo/cooperativo e personagem no solo; abertura sem palavras em tres momentos (ruinas, artefato, chamado divino); integrar a arte aprovada e conservar fisica/construcao/recuperacao. Nenhuma habilidade exclusiva nova.

Escolhas de implementacao do coordenador: A/D ou setas navegam; E/Enter confirma; S/Baixo volta. Solo usa A/D, W e E com qualquer personagem. Cooperativo preserva P1 A/D/W/E e P2 setas/Enter. Somente participantes ativos recebem recursos, colidem com inimigos e contam para camera/vitoria. Abertura dura 12 segundos, E/Enter permite avancar apos o primeiro segundo. Reinicio volta ao menu.

Responsavel: coordenador/integrador, sem executores adicionais. Orca 1.4.245 acessivel, caller=null; nao assumir outro coordenador nem contratar quota nao verificada. Sem push, merge em master, publicacao ou cobranca por consumo.

Arte: geracao/edicao pelo imagegen integrado a partir do estudo aprovado, copiada para o projeto. Nenhuma arte antiga removida. Atlas unico com recortes explicitamente medidos por alpha; render com origem nos pes, escala sem filtro e inversao horizontal. Metadados e funcoes de apresentacao em scr_presentation, logica fisica continua em scr_mvp.

Aceitacao: compilar; conferir menu e tres momentos da abertura no motor; concluir/reiniciar partidas coop e solo com os dois personagens selecionaveis; verificar coleta/construcao apenas do ativo; repetir morte por secao; conferir poses e espelhamento em capturas. Testes automaticos nao equivalem a rodada humana no teclado.
