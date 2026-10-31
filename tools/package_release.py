from pathlib import Path
from zipfile import ZipFile,ZIP_DEFLATED
import hashlib,json,subprocess,xml.etree.ElementTree as E
R=Path(__file__).resolve().parent.parent
D=R/'delivery'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest().upper()
normal=json.loads((D/'tests/qa_result.json').read_text(encoding='utf-8-sig'))
recovery=json.loads((D/'tests/qa_recovery_result.json').read_text(encoding='utf-8-sig'))
for report in [normal,recovery]:
 assert report['passed'] and report['restarted']
 assert report['data_sha256']==sha(D/'windows/data.win')
assert recovery['enemy_hits']>0 and recovery['fall_hits']>0
commit=subprocess.check_output(['git','rev-parse','HEAD'],cwd=R).decode().strip()
report=f'''# Verificacao do MVP JUNTOS

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
'''
(R/'docs/TEST_REPORT.md').write_text(report,encoding='utf-8')
(D/'TEST_REPORT.md').write_text(report,encoding='utf-8')
(D/'SUBMISSION.txt').write_text('''JUNTOS
Tema: A better world
Dois sobreviventes recebem um chamado para subir. Os recursos pertencem a cada jogador, mas a torre e construida em conjunto. Ao alcancar o topo, a criacao ganha vida; o final revela seis criadores jogando, levando a ideia de construir juntos para fora da tela.
Windows x64. Dois jogadores no mesmo teclado. P1 A/D/W/E; P2 Esquerda/Direita/Cima/Enter. Coleta automatica. Ambos confirmam o inicio e ambos precisam chegar ao topo.
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
payload=[]
for p in (D/'windows').iterdir():
 if p.is_file():payload.append((p,'windows/'+p.name))
for n in ['LDMT_JUNTOS_Plan.xlsx','LDMT_JUNTOS_Final.xlsx','LDMT_VALIDATION.json']:payload.append((D/'documents'/n,'documents/'+n))
for n in ['README.md','TEST_REPORT.md','ART_AND_SOURCES.md','SUBMISSION.txt']:payload.append((D/n,n))
for name,label in [('qa_20.png','intro.png'),('qa_300.png','gameplay.png'),('qa_1569.png','final.png')]:
 p=D/'tests'/name
 if p.exists():payload.append((p,'screenshots/'+label))
manifest={'game_commit':normal['source_commit'],'branch':'jam/mvp-complete','runtime':'2026.0.0.23','normal_passed':normal['passed'],'recovery_passed':recovery['passed'],'files':{n:sha(p) for p,n in payload}}
(D/'MANIFEST.json').write_text(json.dumps(manifest,indent=2))
payload.append((D/'MANIFEST.json','MANIFEST.json'))
out=D/'JUNTOS_Entrega.zip'
with ZipFile(out,'w',ZIP_DEFLATED) as z:
 for p,n in payload:z.write(p,n)
with ZipFile(out) as z:
 assert z.testzip() is None
 for n,h in manifest['files'].items():assert hashlib.sha256(z.read(n)).hexdigest().upper()==h
print('Verified release',out, out.stat().st_size,'bytes; formulas and IDs preserved:',len(sf))
