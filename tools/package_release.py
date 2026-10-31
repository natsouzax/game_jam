from pathlib import Path
from zipfile import ZipFile,ZIP_DEFLATED
import hashlib,json,subprocess,xml.etree.ElementTree as E
R=Path(__file__).resolve().parent.parent
D=R/'delivery'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest().upper()
normal=json.loads((D/'tests/qa_result.json').read_text(encoding='utf-8-sig'))
recovery=json.loads((D/'tests/qa_recovery_result.json').read_text(encoding='utf-8-sig'))
section=json.loads((D/'tests/qa_section_reset_result.json').read_text(encoding='utf-8-sig'))
solos=[json.loads((D/f'tests/qa_solo{i}_result.json').read_text(encoding='utf-8-sig')) for i in (1,2)]
for index,s in enumerate(solos):
 assert s['passed'] and s['restarted'] and s['menu_ok'] and s['intro_all_scenes'] and s['inactive_untouched']
 assert s['players']==1 and s['solo_character']==index and s['data_sha256']==sha(D/'windows/data.win')
assert section['passed'] and section['data_sha256']==sha(D/'windows/data.win')
for report in [normal,recovery]:
 assert report['passed'] and report['restarted']
 assert report['data_sha256']==sha(D/'windows/data.win')
assert recovery['enemy_hits']>0 and recovery['fall_hits']>0
assert normal['section_scope_ok'] and recovery['section_scope_ok']
commit=subprocess.check_output(['git','rev-parse','HEAD'],cwd=R).decode().strip()
report=f'''# Verificacao do MVP TOGETHER

Fonte de jogo: {normal['source_commit']}. Base preservada: 938089d. Runtime GameMaker 2026.0.0.23, Windows x64/DirectX11. Executavel testado e o da pasta delivery/windows; o engine exportado existente tem hash identico ao Runner instalado. O arquivo data.win testado tem SHA256 {sha(D/'windows/data.win')}.

## Execucoes reais

| Verificacao | Partida normal | Queda e patrulha |
|---|---:|---:|
| Quadros de simulacao ate final/reinicio | {normal['frames']:.0f} | {recovery['frames']:.0f} |
| Materiais coletados P1 / P2 | {normal['p1_collected']:.0f} / {normal['p2_collected']:.0f} | {recovery['p1_collected']:.0f} / {recovery['p2_collected']:.0f} |
| Blocos construidos P1 / P2 | {normal['p1_built']:.0f} / {normal['p2_built']:.0f} | {recovery['p1_built']:.0f} / {recovery['p2_built']:.0f} |
| Uso de blocos do parceiro P1 / P2 | {normal['p1_shared_uses']:.0f} / {normal['p2_shared_uses']:.0f} | {recovery['p1_shared_uses']:.0f} / {recovery['p2_shared_uses']:.0f} |
| Quadros com movimento dos dois | {normal['simultaneous_frames']:.0f} | {recovery['simultaneous_frames']:.0f} |
| Checkpoint de topo dos dois | 5 / 5 | 5 / 5 |
| Quedas recuperadas P1 | {normal['fall_hits']:.0f} | {recovery['fall_hits']:.0f} |
| Contatos com inimigo P2 | {normal['enemy_hits']:.0f} | {recovery['enemy_hits']:.0f} |
| Blocos removidos nas mortes P1 / P2 | {normal['p1_removed_blocks']:.0f} / {normal['p2_removed_blocks']:.0f} | {recovery['p1_removed_blocks']:.0f} / {recovery['p2_removed_blocks']:.0f} |
| Final e reinicio verificados | Sim | Sim |

Entrada do titulo, introducao, queda, coleta, consumo de materiais, construcao pelos dois, colisao, camera vertical, uso da torre comum, chegada conjunta e final ocorreram no motor real. O teste de reinicio chama room_restart e verifica titulo ativo, estoques zerados e somente cinco plataformas iniciais. Recuperacoes verificam conservacao do estoque e remocao restrita aos blocos construidos da secao do checkpoint atual, incluindo os de ambos os jogadores. Plataformas fixas e outras secoes permanecem. Os replays de partida completa injetam acoes nos mesmos metodos dos controladores: nao concedem itens, nao teleportam ao topo e nao ignoram inimigos. A unica reposicao de posicao da partida completa e a recuperacao normal do proprio jogo.

O teste focado de secoes usa uma fixture separada: cria blocos identificados em tres secoes e inventarios conhecidos, chama a mesma recuperacao e verifica IDs. Removeu dois blocos da secao1 (dos dois construtores), manteve as secoes0/2 e as cinco plataformas, retornou ao checkpoint e conservou o estoque. Depois verificou tambem a limpeza da secao0, mantendo a secao2. Resultado: {section['passed']}. A fixture nao e usada como evidencia de progressao; as duas partidas completas acima sao por acoes.

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

Apenas uma chamada draw_text existe no jogo, com o titulo TOGETHER. Multiplayer e chegada conjunta sao demonstrados pelos testes. Seis avatares simbolicos representam a equipe. Sem audio e sem alegacao de paleta de cinco cores.

## Limites e teste humano recomendado

Nao houve rodada com duas pessoas nem teste de ghosting, conforto, clareza narrativa ou diversao. Nao houve teste em outro PC limpo. Antes de apresentar: extrair ZIP, ambos confirmam com W/Cima, cada um coleta e constroi, saltar nos blocos, deixar um parceiro para tras, tocar a patrulha, recuperar, ambos pousar no topo e reiniciar. Em teclado com ghosting, usar teclado USB que aceite as combinacoes. Sem publicacao ou envio automatico.
'''
report=report.replace('Entrada do titulo, introducao,','Menu de modo/personagem, tres cenas da abertura,')
report=report.replace('A API de controle da interface ficou indisponivel (native pipe), portanto nao foi feito teste final com teclas fisicas.','As entradas foram automaticas; nao houve teste final com teclas fisicas nesta revisao.')
report=report.replace('Apenas uma chamada draw_text existe no jogo, com o titulo TOGETHER.','As duas chamadas draw_text desenham o mesmo titulo TOGETHER (sombra e frente); nenhum outro texto e exibido.')
report=report.replace('ambos confirmam com W/Cima,','selecione duas silhuetas com A/D ou setas e confirme com E/Enter,')
report+=f'''
## Revisao visual, menu e solo

Arte simplificada aprovada por Natan: P1 grisalho/oculos/ciano, P2 bone/ambar e drone. Atlas transparente, recortes por alpha, escala comum, origem nos pes e inversao horizontal. Capturas do motor mostram ambos os personagens no inicio, selecao de retrato e tres cenas da abertura. Recursos anteriores preservados. Verificacao visual da transparência e da inversao horizontal nas capturas; nao houve avaliacao humana da fluidez.

Menu: cartao de uma/duas silhuetas; solo escolhe retrato; direcao navega, E/Enter confirma, S/Baixo volta. Replay coop entrou na selecao solo, voltou e iniciou coop pelo mesmo handler. Replays solo selecionaram cada retrato. Abertura12s com ruinas, artefato e chamado; tres cenas vistas por todos os replays. E/Enter pula apos1s; esse atalho ainda requer verificacao humana de tecla.

| Execucao solo | P1 | P2 |
|---|---:|---:|
| Quadros ate final/reinicio | {solos[0]['frames']:.0f} | {solos[1]['frames']:.0f} |
| Coletas do ativo | {solos[0]['p1_collected']:.0f} | {solos[1]['p2_collected']:.0f} |
| Blocos do ativo | {solos[0]['p1_built']:.0f} | {solos[1]['p2_built']:.0f} |
| Checkpoint do ativo | 5 | 5 |
| Personagem inativo sem coleta/construcao/recuperacao | Sim | Sim |
| Final/reinicio | Sim | Sim |

Solo usa A/D/W/E com qualquer personagem. Camera, material, colisao com inimigo, bloqueio da construcao e vitoria filtram participantes ativos. Cada replay solo encontrou a patrulha, recuperou e removeu3 blocos da secao antes de concluir. Todos os cinco relatorios correspondem ao mesmo SHA256 da build. LDMT Final3 revisa somente descricoes do menu/abertura e condicao de chegada; Plan, pesos, formulas e IDs preservados.
'''
(R/'docs/TEST_REPORT.md').write_text(report,encoding='utf-8')
(D/'TEST_REPORT.md').write_text(report,encoding='utf-8')
(D/'SUBMISSION.txt').write_text('''TOGETHER
Tema: A better world
Dois sobreviventes recebem um chamado para subir. Os recursos pertencem a cada jogador, mas a torre e construida em conjunto. Ao alcancar o topo, a criacao ganha vida; o final revela seis criadores jogando, levando a ideia de construir juntos para fora da tela.
Windows x64. Solo com escolha do personagem ou dois jogadores no mesmo teclado. Menu A/D ou setas, E/Enter confirma, S/Baixo volta. Solo qualquer personagem A/D/W/E. Coop P1 A/D/W/E; P2 Esquerda/Direita/Cima/Enter. Coleta automatica; todos os participantes ativos precisam chegar ao topo. Abertura visual sem palavras.
Equipe: Natan, Guilherme, Luiz, Emmanuel, Vanessa e Vitally.
Sidequests demonstradas: multiplayer local; apenas titulo como texto; seis avatares simbolicos; quatro comandos por jogador com usos reaproveitados. Sem audio.
Arte inclui imagens geradas com IA fornecidas durante a jam; elementos procedurais e codigo criados durante esta sessao. Declarar conforme exigencias da organizacao.
Entregar Windows/ e LDMT Plan + Final. Canal de upload e eventual codigo oficial de equipe devem ser informados pela organizacao. Nenhum envio foi feito.
''',encoding='utf-8')
# Preserve the exact fixed IDs and formula text, check every package part is valid XML.
source=Path(r'C:\Users\natan\OneDrive\Documentos\ChatGPT\GameJam\LDMT_Game_Jam.xlsx')
ns={'s':'http://schemas.openxmlformats.org/spreadsheetml/2006/main'}
def workbook_facts(p):
 forms={};ids={}
 with ZipFile(p) as z:
  for n in z.namelist():
   if n.endswith('.xml'):E.fromstring(z.read(n))
   if n.startswith('xl/worksheets/sheet') and n.endswith('.xml'):
    for c in E.fromstring(z.read(n)).findall('.//s:c',ns):
     f=c.find('s:f',ns)
     if f is not None:forms[(n,c.get('r'))]=f.text
     if n in ['xl/worksheets/sheet2.xml','xl/worksheets/sheet3.xml'] and c.get('r','').startswith('B'):
      v=c.find('s:v',ns);ids[(n,c.get('r'))]=v.text if v is not None else None
 return forms,ids
sf,si=workbook_facts(source)
for p in [D/'documents/LDMT_JUNTOS_Plan.xlsx',D/'documents/LDMT_JUNTOS_Final.xlsx']:
 f,i=workbook_facts(p);assert f==sf and i==si
validation=json.loads((D/'documents/LDMT_VALIDATION.json').read_text())
validation.update({'formula_count':len(sf),'fixed_ids_preserved':True,'all_xml_parse':True})
(D/'documents/LDMT_VALIDATION.json').write_text(json.dumps(validation,indent=2))
import shutil
shutil.copyfile(R/'docs/ART_AND_SOURCES.md',D/'ART_AND_SOURCES.md')
shutil.copyfile(D/'README.md',D/'windows/README.md')
payload=[]
for p in (D/'windows').iterdir():
 if p.is_file() and p.name not in ['JUNTOS.exe','Jogar.cmd']:payload.append((p,'windows/'+p.name))
for n in ['LDMT_JUNTOS_Plan.xlsx','LDMT_JUNTOS_Final.xlsx','LDMT_VALIDATION.json']:payload.append((D/'documents'/n,'documents/'+n))
for n in ['README.md','TEST_REPORT.md','ART_AND_SOURCES.md','SUBMISSION.txt']:payload.append((D/n,n))
for name,label in [('qa_menu.png','menu.png'),('qa_character.png','selection.png'),('qa_intro_0.png','intro_ruins.png'),('qa_intro_1.png','intro_artifact.png'),('qa_intro_2.png','intro_mission.png'),('qa_coop_start.png','coop.png'),('qa_gameplay.png','gameplay.png'),('qa_solo2_start.png','solo.png'),('qa_final.png','final.png')]:
 p=D/'tests'/name
 if p.exists():payload.append((p,'screenshots/'+label))
for name in ['qa_result.json','qa_recovery_result.json','qa_section_reset_result.json','qa_solo1_result.json','qa_solo2_result.json']:payload.append((D/'tests'/name,'tests/'+name))
manifest={'game_commit':normal['source_commit'],'branch':'jam/mvp-complete','runtime':'2026.0.0.23','normal_passed':normal['passed'],'recovery_passed':recovery['passed'],'section_reset_passed':section['passed'],'solo1_passed':solos[0]['passed'],'solo2_passed':solos[1]['passed'],'files':{n:sha(p) for p,n in payload}}
(D/'MANIFEST.json').write_text(json.dumps(manifest,indent=2))
payload.append((D/'MANIFEST.json','MANIFEST.json'))
out=D/'TOGETHER_Release.zip'
with ZipFile(out,'w',ZIP_DEFLATED) as z:
 for p,n in payload:z.write(p,n)
with ZipFile(out) as z:
 assert z.testzip() is None
 for n,h in manifest['files'].items():assert hashlib.sha256(z.read(n)).hexdigest().upper()==h
print('Verified release',out, out.stat().st_size,'bytes; formulas and IDs preserved:',len(sf))
