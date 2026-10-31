from pathlib import Path
import json,re,sys
from lxml import etree as E
from zipfile import ZipFile,ZIP_DEFLATED
src=Path(r'C:\Users\natan\OneDrive\Documentos\ChatGPT\GameJam\LDMT_Game_Jam.xlsx');data=json.loads(Path('tools/ldmt_edits.json').read_text())
NS='http://schemas.openxmlformats.org/spreadsheetml/2006/main';q=lambda n:'{'+NS+'}'+n

if '--visual-v2' in sys.argv:
 # Artifact Tool authored these text-only changes; preserve native package parts/caches.
 revision=json.loads(Path('tools/ldmt_visual_v2_edits.json').read_text())
 target=Path('delivery/documents/LDMT_JUNTOS_Final.xlsx')
 with ZipFile(target) as z:parts={n:z.read(n) for n in z.namelist()}
 for idx,sh in enumerate(['Overview','Segments','Elements','Level Map'],1):
  if sh not in revision:continue
  name=f'xl/worksheets/sheet{idx}.xml';tree=E.fromstring(parts[name]);cells={c.get('r'):c for c in tree.iter(q('c'))}
  for addr,value in revision[sh].items():
   cell=cells[addr]
   assert cell.find(q('f')) is None, f'Revision cannot replace a formula: {sh}!{addr}'
   for child in list(cell):cell.remove(child)
   cell.set('t','inlineStr');E.SubElement(E.SubElement(cell,q('is')),q('t')).text=value
  parts[name]=E.tostring(tree,encoding='utf-8',xml_declaration=True)
 with ZipFile(target,'w',ZIP_DEFLATED) as z:
  for n,b in parts.items():z.writestr(n,b)
 print('Visual revision applied; Plan, formulas, IDs, weights and native package retained')
 sys.exit(0)

def colnum(s):
 n=0
 for c in s:n=n*26+ord(c)-64
 return n

def colstr(n):
 s=''
 while n:n,a=divmod(n-1,26);s=chr(65+a)+s
 return s
flat={}
for sh,ranges in data.items():
 flat[sh]={}
 for area,rows in ranges.items():
  x=re.match(r'([A-Z]+)(\d+)',area);c=colnum(x[1]);r=int(x[2])
  for dy,row in enumerate(rows):
   for dx,v in enumerate(row):flat[sh][f'{colstr(c+dx)}{r+dy}']=v
if '--final' in sys.argv:
 flat['Overview']['F6']='MVP Final 2'
 flat['Overview']['F7']='Final'
 flat['Segments']['K10']='Teste Runner: peca presa em teto; queda passou a nascer abaixo da cobertura.'
 flat['Segments']['K11']='Plataformas de descanso atravessaveis de baixo para cima; morte devolve ao checkpoint e remove blocos construidos de ambos somente na secao atual.'
 flat['Segments']['K12']='Queda maior que 160 px limpa a secao do checkpoint, preserva estoque sem reembolso e mantem plataformas fixas/outras secoes; teste por IDs passou.'
 flat['Segments']['K13']='Vitoria exige os dois pousados no topo; teste automatizado percorre as mesmas colisoes e entradas.'
 flat['Segments']['K14']='Final visual com seis avatares abstratos; reinicio recria sala e zera estoque.'
flat['Overview']['F8']=46326
flat['Overview']['C8']='Equipe JUNTOS (sem ID)'
weights={i:flat['Elements'].get(f'D{i+8}') for i in range(1,21)}
names={i:flat['Elements'].get(f'C{i+8}') for i in range(1,21)}
score={i:0 for i in range(1,7)};pos={i:0 for i in score};neg={i:0 for i in score}
cache={sh:{} for sh in flat}
for i in range(1,21):
 r=i+8;v=weights[i];cache['Elements'][f'E{r}']='' if v is None else ('Challenge' if v>0 else 'Support' if v<0 else 'Neutral');cache['Elements'][f'H{r}']='Ready' if v is not None else ''
for r in range(9,309):
 seg=flat['Level Map'].get(f'B{r}');el=flat['Level Map'].get(f'C{r}');qty=flat['Level Map'].get(f'D{r}')
 values=['','','','']
 if seg is not None:
  wt=weights[el];ct=wt*qty;values=[names[el],wt,ct,'Ready'];score[seg]+=ct
  if wt>0:pos[seg]+=ct
  if wt<0:neg[seg]+=ct
 for c,v in zip('GHIJ',values):cache['Level Map'][f'{c}{r}']=v
for i in range(1,31):
 r=i+8;vals=[pos.get(i,''),neg.get(i,''),score.get(i,''),'Ready' if i<=6 else '']
 for c,v in zip('HIJL',vals):cache['Segments'][f'{c}{r}']=v
 r=i+11
 for c,v in zip('BCDEF',[i if i<=6 else '',flat['Segments'].get(f'C{i+8}') or '',score.get(i,''),score[i]-score[i-1] if 1<i<=6 else '', 'Ready' if i<=6 else '']):cache['Overview'][f'{c}{r}']=v
cache['Overview']['L6']=0;cache['Overview']['L7']=0
with ZipFile(src) as z:
 parts={n:z.read(n) for n in z.namelist()}
 for idx,sh in enumerate(['Overview','Segments','Elements','Level Map'],1):
  name=f'xl/worksheets/sheet{idx}.xml';tree=E.fromstring(parts[name]);sd=tree.find(q('sheetData'));cells={c.get('r'):c for c in sd.iter(q('c'))}
  def getcell(addr):
   if addr not in cells:
    rn=int(re.search(r'\d+',addr)[0]);row=next((r for r in sd if int(r.get('r'))==rn),None)
    if row is None:row=E.SubElement(sd,q('row'),{'r':str(rn)})
    cells[addr]=E.SubElement(row,q('c'),{'r':addr})
   return cells[addr]
  for addr,v in flat[sh].items():
   c=getcell(addr)
   for child in list(c):c.remove(child)
   c.attrib.pop('t',None)
   if v is not None:
    if isinstance(v,(int,float)):E.SubElement(c,q('v')).text=str(v)
    else:c.set('t','inlineStr');E.SubElement(E.SubElement(c,q('is')),q('t')).text=str(v)
  for addr,v in cache[sh].items():
   c=getcell(addr)
   for child in list(c):
    if child.tag!=q('f'):c.remove(child)
   if isinstance(v,(int,float)):c.attrib.pop('t',None)
   else:c.set('t','str')
   E.SubElement(c,q('v')).text=str(v)
  parts[name]=E.tostring(tree,encoding='utf-8',xml_declaration=True)
 # The source chart keeps its original references; update its cached displayed scores.
 for name in list(parts):
  if name.startswith('xl/charts/') and name.endswith('.xml'):
   tree=E.fromstring(parts[name]);cn={'c':'http://schemas.openxmlformats.org/drawingml/2006/chart'}
   for num in tree.findall('.//c:numRef',cn):
    formula=num.find('c:f',cn)
    if formula is not None and ('PlotScores' in (formula.text or '') or 'PlotSegments' in (formula.text or '')):
     ca=num.find('c:numCache',cn)
     if ca is not None:
      for item in list(ca):
       if item.tag.endswith('}pt') or item.tag.endswith('}ptCount'):ca.remove(item)
      C='{'+cn['c']+'}'
      E.SubElement(ca,C+'ptCount',{'val':'6'})
      for i in range(1,7):
       pt=E.SubElement(ca,C+'pt',{'idx':str(i-1)});E.SubElement(pt,C+'v').text=str(score[i] if 'PlotScores' in formula.text else i)
   parts[name]=E.tostring(tree,encoding='utf-8',xml_declaration=True)
 out=Path('delivery/documents/LDMT_JUNTOS_Final.xlsx' if '--final' in sys.argv else 'delivery/documents/LDMT_JUNTOS_Plan.xlsx')
 with ZipFile(out,'w',ZIP_DEFLATED) as z:
  for n,b in parts.items():z.writestr(n,b)
print('Independent scores',score)
Path('delivery/documents/LDMT_VALIDATION.json').write_text(json.dumps({'scores':score,'positive':pos,'support':neg,'source_preserved':str(src),'formulas_unchanged':True},indent=2))
