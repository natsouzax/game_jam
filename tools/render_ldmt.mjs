import fs from 'node:fs/promises';
import {FileBlob,SpreadsheetFile} from '@oai/artifact-tool';
const wb=await SpreadsheetFile.importXlsx(await FileBlob.load('delivery/documents/LDMT_JUNTOS_Final.xlsx'));
await fs.writeFile('delivery/documents/LDMT_preview.png',new Uint8Array(await (await wb.render({sheetName:'Overview',range:'B2:M20',scale:1,format:'png'})).arrayBuffer()));
await fs.writeFile('tools/tmp/LDMT_visual_notes_preview.png',new Uint8Array(await (await wb.render({sheetName:'Segments',range:'C8:L14',scale:1,format:'png'})).arrayBuffer()));
