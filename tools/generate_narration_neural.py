"""Render the cutscene narration with a neural voice (edge-tts) and register the lines as GameMaker sounds.

Reads the lines from scr_cut_lines() in scripts/scr_presentation/scr_presentation.gml so the text lives in one place.
Needs: pip install edge-tts mutagen. Sends the narration text to Microsoft's online TTS service.
Usage: python tools/generate_narration_neural.py [voice] [rate]
"""
import asyncio
import re
import sys
from pathlib import Path

import edge_tts
from mutagen.mp3 import MP3

root = Path(__file__).resolve().parent.parent
gml = root / 'scripts' / 'scr_presentation' / 'scr_presentation.gml'
voice = sys.argv[1] if len(sys.argv) > 1 else 'en-US-ChristopherNeural'
rate = sys.argv[2] if len(sys.argv) > 2 else '-8%'

source = gml.read_text(encoding='utf-8')
pattern = re.compile(r'\[(\d+),(\d+),(narr_\d\d),"([^"]+)"\]')
lines = pattern.findall(source)
assert lines, 'no narration lines found in scr_cut_lines'

yy_template = (root / 'sounds' / 'narr_01' / 'narr_01.yy').read_text(encoding='utf-8')
durations = {}


async def render(name, text):
    folder = root / 'sounds' / name
    mp3 = folder / (name + '.mp3')
    await edge_tts.Communicate(text, voice, rate=rate).save(str(mp3))
    old = folder / (name + '.wav')
    if old.exists():
        old.unlink()
    return MP3(str(mp3)).info.length


async def main():
    for start, frames, name, text in lines:
        durations[name] = await render(name, text)
        print(name, round(durations[name], 2), 's', text)


asyncio.run(main())

for start, frames, name, text in lines:
    yy_path = root / 'sounds' / name / (name + '.yy')
    yy = yy_template.replace('narr_01', name)
    yy = re.sub(r'"duration":[0-9.]+', '"duration":%.6f' % durations[name], yy)
    yy = yy.replace('"soundFile":"%s.wav"' % name, '"soundFile":"%s.mp3"' % name).replace('"sampleRate":22050', '"sampleRate":24000')
    yy_path.write_text(yy, encoding='utf-8', newline='\n')

# Keep the voice length (frames) in the GML table in sync with the rendered audio.
def sync(m):
    name = m.group(3)
    return '[%s,%d,%s,"%s"]' % (m.group(1), int(durations[name] * 60) + 1, name, m.group(4))

gml.write_text(pattern.sub(sync, source), encoding='utf-8', newline='\n')
print('voice', voice, 'rate', rate)
