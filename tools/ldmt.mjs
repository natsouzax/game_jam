import fs from 'node:fs/promises';
import {FileBlob,SpreadsheetFile} from '@oai/artifact-tool';
const source='C:/Users/natan/OneDrive/Documentos/ChatGPT/GameJam/LDMT_Game_Jam.xlsx';
const wb=await SpreadsheetFile.importXlsx(await FileBlob.load(source));
const edits={};
function put(sheet,cell,values){wb.worksheets.getItem(sheet).getRange(cell).values=values;edits[sheet]??={};edits[sheet][cell]=values;}
put('Overview','C6',[['JUNTOS']]);put('Overview','C7',[['Torre cooperativa']]);put('Overview','C8',[['Equipe Game Jam (codigo nao fornecido)']]);put('Overview','F6',[['MVP Plan 1']]);put('Overview','F7',[['Planning']]);put('Overview','F8',[[new Date('2026-10-31T12:00:00Z')]]);
put('Segments','C9:G38',Array.from({length:30},()=>Array(5).fill(null)));put('Segments','K9:K38',Array.from({length:30},()=>[null]));
put('Elements','C9:D28',Array.from({length:20},()=>[null,null]));put('Elements','F9:G28',Array.from({length:20},()=>[null,null]));
put('Level Map','B9:F308',Array.from({length:300},()=>Array(5).fill(null)));
put('Segments','C9:G14',[
['Chamado','Inicio','Introduction','Prontidao conjunta','Titulo e divindade visual; ambos confirmam.'],
['Oficina','1408 a 1216','Introduction','Coletar, construir, saltar','Aprender uma peca por bloco; terreno seguro.'],
['Patrulha','1216 a 1024','Challenge','Subir e evitar patrulha','Atravesse o encontro movel com recuperacao.'],
['Reconstrucao','1024 a 640','Reinforcement','Subida e recuperacao','Duas secoes repetem construcao e uso da torre comum.'],
['Topo','640 a 448','Challenge','Chegada dos dois','Objetivo so conclui quando ambos estao no topo.'],
['Mundo real','Final','Reinforcement','Revelacao e reinicio','A torre fica verde; seis avatares observam o jogo num monitor.']]);
put('Elements','C9:D13', [['Contexto',0],['Trecho de construcao',1],['Patrulha',2],['Recuperacao',-1],['Suprimento',-1]]);
put('Elements','F9:G13',[
['Uma sequencia ou marco visual','Neutro; sem demanda de execucao.'],['Um trecho de 192 px, nao cada bloco','Proposta do coordenador: demanda base de planejar e saltar.'],['Um encontro com patrulha movel','Proposta: combinar tempo e deslocamento exige mais que o trecho simples.'],['Uma plataforma de checkpoint','Proposta: limita custo da queda e conserva materiais.'],['Uma regra continua de queda de materiais','Suporte de todo trecho; nao contar gotas ilimitadas.']]);
put('Level Map','B9:F23',[
[1,1,1,'Titulo/introducao','Prontidao independente dos dois'],
[2,2,1,'y1408 a y1216','Construcao da primeira subida'],[2,4,1,'Plataforma y1216','Recuperacao individual'],[2,5,1,'Queda junto aos jogadores','Uma regra de suprimento'],
[3,2,1,'y1216 a y1024','Subida'],[3,3,1,'Patrulha y940','Encontro acima da plataforma'],[3,4,1,'Plataforma y1024','Recuperacao'],[3,5,1,'Durante trecho','Suprimento'],
[4,2,2,'y1024 a y640','Dois trechos de 192'],[4,4,2,'y832 e y640','Duas plataformas'],[4,5,1,'Durante trecho','Suprimento'],
[5,2,1,'y640 a y448','Ultima subida'],[5,4,1,'Plataforma y448','Pouso de ambos'],[5,5,1,'Durante trecho','Suprimento'],
[6,1,1,'Sequencia final','Seis avatares abstratos e reinicio']]);
await wb.recalculate();
await fs.writeFile('tools/ldmt_edits.json',JSON.stringify(edits));
await fs.mkdir('tools/tmp',{recursive:true});
await (await SpreadsheetFile.exportXlsx(wb)).save('tools/tmp/LDMT_artifact_work.xlsx');
console.log((await wb.inspect({kind:'region',sheetId:'Overview',range:'B6:L18',maxChars:2500})).ndjson);
try{const image=await wb.render({sheetName:'Overview',range:'B2:M20',scale:1,format:'png'});await fs.writeFile('tools/tmp/LDMT_artifact_preview.png',new Uint8Array(await image.arrayBuffer()));}catch(e){console.log('RENDER',e.message)}
