#!/usr/bin/env python3
"""Generate JUNTOS chiptune music and SFX as 16-bit mono WAVs.

The WAV files and their GameMaker sound resources are generated from this
script so the soundtrack stays reproducible and easy to tweak.
"""
import json
import math
import os
import random
import struct
import wave

SR = 22050
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SOUND_DIR = os.path.join(ROOT, "sounds")
random.seed(20261031)

AUDIO_META = {
    "mus_menu": {"volume": 0.55, "preload": True},
    "mus_game": {"volume": 0.5, "preload": True},
    "mus_intro": {"volume": 0.6, "preload": True},
    "mus_ending": {"volume": 0.55, "preload": True},
    "sfx_ui_move": {"volume": 0.5, "preload": True},
    "sfx_ui_confirm": {"volume": 0.65, "preload": True},
    "sfx_ui_back": {"volume": 0.5, "preload": True},
    "sfx_jump": {"volume": 0.7, "preload": True},
    "sfx_hit": {"volume": 0.85, "preload": True},
    "sfx_fall": {"volume": 0.7, "preload": True},
    "sfx_block": {"volume": 0.85, "preload": True},
    "sfx_collect": {"volume": 0.7, "preload": True},
    "sfx_checkpoint": {"volume": 0.8, "preload": True},
    "sfx_intro_whoosh": {"volume": 0.7, "preload": True},
    "sfx_intro_artifact": {"volume": 0.75, "preload": True},
    "sfx_victory": {"volume": 0.8, "preload": True},
}


def midi(note):
    return 440.0 * (2.0 ** ((note - 69) / 12.0))


def envelope(i, n, attack, release):
    a = 1.0 if attack <= 0 else min(1.0, (i / SR) / attack)
    r = 1.0 if release <= 0 else min(1.0, (n - 1 - i) / (release * SR))
    return a * r


def tone(freq, dur, kind="square", vol=1.0, duty=0.5, decay=0.0,
         attack=0.004, release=0.012, vibrato=0.0):
    n = max(1, int(dur * SR))
    out = [0.0] * n
    phase = 0.0
    for i in range(n):
        t = i / SR
        f = freq * (1.0 + vibrato * math.sin(2.0 * math.pi * 5.0 * t))
        phase += f / SR
        frac = phase % 1.0
        if kind == "square":
            value = 1.0 if frac < duty else -1.0
        elif kind == "tri":
            value = 4.0 * abs(frac - 0.5) - 1.0
        elif kind == "saw":
            value = 2.0 * frac - 1.0
        else:
            value = math.sin(2.0 * math.pi * phase)
        out[i] = value * vol * math.exp(-decay * t) * envelope(i, n, attack, release)
    return out


def sweep(f0, f1, dur, kind="square", vol=1.0, duty=0.5, decay=2.0,
          attack=0.003, release=0.012):
    n = max(1, int(dur * SR))
    out = [0.0] * n
    phase = 0.0
    for i in range(n):
        t = i / SR
        f = f0 + (f1 - f0) * (t / dur)
        phase += f / SR
        frac = phase % 1.0
        if kind == "square":
            value = 1.0 if frac < duty else -1.0
        elif kind == "tri":
            value = 4.0 * abs(frac - 0.5) - 1.0
        else:
            value = math.sin(2.0 * math.pi * phase)
        out[i] = value * vol * math.exp(-decay * t) * envelope(i, n, attack, release)
    return out


def noise(dur, vol=1.0, lp=0.35, decay=18.0, attack=0.002, release=0.005, high=False):
    n = max(1, int(dur * SR))
    out = [0.0] * n
    y = 0.0
    prev = 0.0
    for i in range(n):
        t = i / SR
        white = random.uniform(-1.0, 1.0)
        if high:
            y = 0.92 * (y + white - prev)
            prev = white
        else:
            y += lp * (white - y)
        out[i] = y * vol * math.exp(-decay * t) * envelope(i, n, attack, release)
    return out


def noise_swell(dur, vol=1.0):
    n = max(1, int(dur * SR))
    out = [0.0] * n
    y = 0.0
    for i in range(n):
        t = i / SR
        p = t / dur
        lp = 0.02 + 0.36 * math.sin(math.pi * min(1.0, p * 1.25)) ** 2
        y += lp * (random.uniform(-1.0, 1.0) - y)
        amp = math.sin(math.pi * p) ** 1.35
        out[i] = y * vol * amp * envelope(i, n, 0.02, 0.02)
    return out


def kick(vol=0.7, dur=0.16):
    return sweep(150.0, 42.0, dur, "sine", vol, decay=11.0, attack=0.001, release=0.004)


def snare(vol=0.4, dur=0.13):
    body = noise(dur, vol, lp=0.55, decay=19.0)
    ring = tone(185.0, dur, "sine", vol * 0.35, decay=22.0)
    return [a + b for a, b in zip(body, ring)]


def hat(vol=0.12, dur=0.05):
    return noise(dur, vol, decay=55.0, high=True, attack=0.001)


class Mix:
    def __init__(self, dur):
        self.n = max(1, int(dur * SR))
        self.buf = [0.0] * self.n

    def add(self, start, sig, gain=1.0):
        i0 = int(start * SR)
        n = min(len(sig), self.n - i0)
        if n <= 0:
            return
        buf = self.buf
        for i in range(n):
            buf[i0 + i] += sig[i] * gain

    def finish(self, peak=0.82):
        y = 0.0
        prev = 0.0
        out = [0.0] * self.n
        for i, x in enumerate(self.buf):
            y = 0.998 * (y + x - prev)
            prev = x
            out[i] = math.tanh(y * 1.05)
        top = max((abs(v) for v in out), default=0.0)
        if top > 0:
            scale = peak / top
            out = [v * scale for v in out]
        self.buf = out

    def write(self, path):
        with wave.open(path, "wb") as wav:
            wav.setnchannels(1)
            wav.setsampwidth(2)
            wav.setframerate(SR)
            frames = bytearray()
            for value in self.buf:
                clamped = max(-1.0, min(1.0, value))
                frames += struct.pack("<h", int(clamped * 32767))
            wav.writeframes(bytes(frames))

    def loop_edges(self, fade_in=0.008, fade_out=0.03):
        """Silence the loop seam so GameMaker restarts the track without a click."""
        n_in = min(self.n, int(fade_in * SR))
        n_out = min(self.n, int(fade_out * SR))
        for i in range(n_in):
            self.buf[i] *= i / n_in
        for i in range(n_out):
            self.buf[self.n - 1 - i] *= i / n_out


def note(mix, beat, start_beat, beats, midi_note, **kwargs):
    sig = tone(midi(midi_note), beats * beat, **kwargs)
    mix.add(start_beat * beat, sig)


MENU_MELODY = [
    [(0, 1, 69), (1, 0.5, 72), (1.5, 0.5, 76), (2, 1, 74), (3, 1, 72)],
    [(0, 1.5, 69), (1.5, 0.5, 67), (2, 1, 65), (3, 1, 64)],
    [(0, 0.5, 72), (0.5, 0.5, 74), (1, 1, 76), (2, 1, 79), (3, 1, 76)],
    [(0, 1.5, 74), (1.5, 0.5, 71), (2, 2, 67)],
    [(0, 1, 76), (1, 0.5, 74), (1.5, 0.5, 72), (2, 1.5, 69), (3.5, 0.5, 72)],
    [(0, 1, 77), (1, 0.5, 76), (1.5, 0.5, 72), (2, 1, 69), (3, 1, 67)],
    [(0, 0.5, 72), (0.5, 0.5, 76), (1, 1, 79), (2, 1, 76), (3, 1, 72)],
    [(0, 1, 74), (1, 1, 71), (2, 2, 67)],
]

GAME_MELODY = [
    [(0, 0.5, 69), (0.5, 0.5, 72), (1, 0.5, 76), (1.5, 0.5, 72), (2, 0.5, 74), (2.5, 0.5, 76), (3, 1, 79)],
    [(0, 0.5, 72), (0.5, 0.5, 69), (1, 0.5, 65), (1.5, 0.5, 69), (2, 1, 72), (3, 1, 74)],
    [(0, 0.5, 76), (0.5, 0.5, 79), (1, 1, 84), (2, 0.5, 79), (2.5, 0.5, 76), (3, 1, 72)],
    [(0, 0.5, 74), (0.5, 0.5, 71), (1, 0.5, 67), (1.5, 0.5, 71), (2, 2, 74)],
    [(0, 1, 81), (1, 0.5, 79), (1.5, 0.5, 76), (2, 1, 72), (3, 1, 69)],
    [(0, 1, 77), (1, 0.5, 76), (1.5, 0.5, 72), (2, 1, 69), (3, 1, 65)],
    [(0, 0.5, 72), (0.5, 0.5, 76), (1, 0.5, 79), (1.5, 0.5, 84), (2, 1, 79), (3, 1, 76)],
    [(0, 1, 74), (1, 1, 71), (2, 1, 67), (3, 1, 74)],
]


def compose_menu():
    bpm = 96.0
    beat = 60.0 / bpm
    bars = 8
    mix = Mix(bars * 4 * beat)
    chords = [[57, 60, 64], [53, 57, 60], [48, 52, 55], [55, 59, 62]]
    roots = [45, 41, 48, 43]
    for bar in range(bars):
        t0 = bar * 4.0
        chord = chords[bar % 4]
        root = roots[bar % 4]
        note(mix, beat, t0, 2, root, kind="tri", vol=0.42, decay=0.35, release=0.05)
        note(mix, beat, t0 + 2, 2, root + 7, kind="tri", vol=0.34, decay=0.35, release=0.05)
        for eighth in range(8):
            idx = [0, 1, 2, 1, 0, 2, 1, 2][eighth]
            note(mix, beat, t0 + eighth * 0.5, 0.44, chord[idx] + 12,
                 kind="square", vol=0.085, duty=0.125, decay=2.4, release=0.02)
        for off, length, pitch in MENU_MELODY[bar]:
            note(mix, beat, t0 + off, length, pitch,
                 kind="square", vol=0.19, duty=0.25, decay=0.7, release=0.04)
        mix.add(t0 * beat, kick(0.4))
        mix.add((t0 + 2) * beat, kick(0.32))
        mix.add((t0 + 1) * beat, snare(0.17))
        mix.add((t0 + 3) * beat, snare(0.17))
        for eighth in range(8):
            mix.add((t0 + eighth * 0.5) * beat, hat(0.05 if eighth % 2 else 0.075))
    mix.finish(0.8)
    return mix


def compose_game():
    bpm = 138.0
    beat = 60.0 / bpm
    bars = 8
    mix = Mix(bars * 4 * beat)
    chords = [[57, 60, 64], [53, 57, 60], [48, 52, 55], [55, 59, 62]]
    roots = [45, 41, 48, 43]
    for bar in range(bars):
        t0 = bar * 4.0
        chord = chords[bar % 4]
        root = roots[bar % 4]
        for eighth in range(8):
            pitch = root + (12 if eighth % 2 else 0)
            note(mix, beat, t0 + eighth * 0.5, 0.42, pitch,
                 kind="tri", vol=0.3, decay=3.0, release=0.015)
        for sixteenth in range(16):
            idx = [0, 1, 2, 1, 0, 1, 2, 1,
                   0, 2, 1, 2, 0, 1, 2, 1][sixteenth]
            note(mix, beat, t0 + sixteenth * 0.25, 0.2, chord[idx] + 12,
                 kind="square", vol=0.045, duty=0.125, decay=5.0, release=0.012)
        for off, length, pitch in GAME_MELODY[bar]:
            note(mix, beat, t0 + off, length, pitch,
                 kind="square", vol=0.2, duty=0.25, decay=0.55, release=0.03)
        for hit in (0, 1.5, 2, 2.5):
            mix.add((t0 + hit) * beat, kick(0.48))
        for hit in (1, 3):
            mix.add((t0 + hit) * beat, snare(0.3))
        for eighth in range(8):
            mix.add((t0 + eighth * 0.5) * beat, hat(0.07 if eighth % 2 else 0.11))
    mix.finish(0.84)
    return mix


def compose_intro():
    bpm = 60.0
    beat = 60.0 / bpm
    bars = 3
    mix = Mix(bars * 4 * beat)
    chords = [[57, 60, 64], [53, 57, 60], [55, 59, 62]]
    roots = [45, 41, 43]
    bells = [
        [(0.0, 2.0, 69), (2.5, 1.4, 76)],
        [(0.25, 1.5, 77), (2.0, 1.8, 72)],
        [(0.0, 2.0, 79), (2.5, 1.5, 74)],
    ]
    for bar in range(bars):
        t0 = bar * 4.0
        for pitch in chords[bar]:
            note(mix, beat, t0, 3.84, pitch, kind="tri", vol=0.15,
                 decay=0.0, attack=0.55, release=0.65)
            note(mix, beat, t0, 3.84, pitch + 12, kind="sine", vol=0.045,
                 decay=0.0, attack=0.8, release=0.7)
        note(mix, beat, t0, 3.84, roots[bar], kind="sine", vol=0.17,
             decay=0.0, attack=0.7, release=0.7)
        for off, length, pitch in bells[bar]:
            note(mix, beat, t0 + off, length, pitch,
                 kind="sine", vol=0.15, decay=1.0, attack=0.01, release=0.25)
            note(mix, beat, t0 + off, length, pitch,
                 kind="square", vol=0.022, duty=0.125, decay=2.5, release=0.2)
    mix.finish(0.72)
    return mix


def compose_ending():
    bpm = 90.0
    beat = 60.0 / bpm
    bars = 8
    mix = Mix(bars * 4 * beat)
    chords = [[48, 52, 55], [43, 47, 50], [45, 48, 52], [41, 45, 48]]
    roots = [36, 43, 45, 41]
    melody = [
        [(0, 2, 76), (2, 2, 79)],
        [(0, 2, 74), (2, 2, 71)],
        [(0, 2, 72), (2, 2, 76)],
        [(0, 3, 69)],
        [(0, 2, 79), (2, 2, 76)],
        [(0, 2, 74), (2, 2, 67)],
        [(0, 1.5, 76), (1.5, 1.5, 72), (3, 1, 69)],
        [(0, 3, 72)],
    ]
    for bar in range(bars):
        t0 = bar * 4.0
        for pitch in chords[bar % 4]:
            note(mix, beat, t0, 3.8, pitch, kind="tri", vol=0.14,
                 decay=0.0, attack=0.25, release=0.4)
            note(mix, beat, t0, 3.8, pitch + 12, kind="sine", vol=0.04,
                 decay=0.0, attack=0.4, release=0.45)
        note(mix, beat, t0, 3.8, roots[bar % 4], kind="tri", vol=0.22,
             decay=0.0, attack=0.2, release=0.4)
        for eighth in range(8):
            idx = [0, 1, 2, 1, 0, 2, 1, 2][eighth]
            note(mix, beat, t0 + eighth * 0.5, 0.44, chords[bar % 4][idx] + 12,
                 kind="square", vol=0.05, duty=0.125, decay=3.0, release=0.05)
        for off, length, pitch in melody[bar]:
            note(mix, beat, t0 + off, length, pitch, kind="sine", vol=0.18,
                 decay=0.35, attack=0.01, release=0.3)
            note(mix, beat, t0 + off, length, pitch, kind="square", vol=0.03,
                 duty=0.25, decay=0.8, release=0.25)
    mix.finish(0.74)
    return mix


def make_jump():
    mix = Mix(0.18)
    mix.add(0.0, sweep(300, 780, 0.14, "square", 0.55, 0.25, decay=4.0))
    mix.add(0.0, sweep(600, 1240, 0.09, "sine", 0.16, decay=5.0))
    mix.finish(0.85)
    return mix


def make_hit():
    mix = Mix(0.34)
    mix.add(0.0, noise(0.2, 0.55, lp=0.5, decay=14.0))
    mix.add(0.0, sweep(230, 68, 0.3, "square", 0.42, 0.5, decay=5.5))
    mix.add(0.0, tone(92, 0.22, "sine", 0.35, decay=9.0))
    mix.finish(0.86)
    return mix


def make_fall():
    mix = Mix(0.52)
    mix.add(0.0, sweep(520, 108, 0.46, "square", 0.34, 0.125, decay=2.6))
    mix.add(0.02, noise(0.3, 0.12, lp=0.22, decay=7.0))
    mix.finish(0.8)
    return mix


def make_block():
    mix = Mix(0.2)
    mix.add(0.0, sweep(150, 58, 0.15, "sine", 0.6, decay=10.0))
    mix.add(0.0, noise(0.05, 0.32, lp=0.7, decay=40.0))
    mix.add(0.0, tone(215, 0.09, "square", 0.2, duty=0.25, decay=26.0))
    mix.finish(0.86)
    return mix


def make_collect():
    mix = Mix(0.22)
    mix.add(0.0, tone(midi(84), 0.07, "square", 0.3, duty=0.25, decay=18.0))
    mix.add(0.05, tone(midi(88), 0.1, "square", 0.3, duty=0.25, decay=16.0))
    mix.add(0.05, tone(midi(88), 0.1, "sine", 0.2, decay=14.0))
    mix.finish(0.8)
    return mix


def make_checkpoint():
    mix = Mix(0.62)
    for index, pitch in enumerate((72, 76, 79, 84)):
        start = index * 0.085
        mix.add(start, tone(midi(pitch), 0.22, "sine", 0.22, decay=4.0))
        mix.add(start, tone(midi(pitch), 0.22, "square", 0.06, duty=0.25, decay=6.0))
    mix.finish(0.82)
    return mix


def make_ui_move():
    mix = Mix(0.07)
    mix.add(0.0, sweep(880, 1040, 0.045, "square", 0.28, 0.5, decay=9.0))
    mix.finish(0.7)
    return mix


def make_ui_confirm():
    mix = Mix(0.22)
    mix.add(0.0, tone(midi(76), 0.08, "square", 0.25, duty=0.25, decay=10.0))
    mix.add(0.055, tone(midi(83), 0.13, "square", 0.28, duty=0.25, decay=8.0))
    mix.add(0.055, tone(midi(83), 0.13, "sine", 0.16, decay=7.0))
    mix.finish(0.78)
    return mix


def make_ui_back():
    mix = Mix(0.16)
    mix.add(0.0, sweep(440, 294, 0.12, "square", 0.3, 0.5, decay=5.0))
    mix.finish(0.72)
    return mix


def make_intro_whoosh():
    mix = Mix(1.25)
    mix.add(0.0, noise_swell(1.2, 0.65))
    mix.add(0.1, sweep(55, 112, 1.0, "sine", 0.22, decay=1.2, attack=0.2, release=0.2))
    mix.finish(0.75)
    return mix


def make_intro_artifact():
    mix = Mix(1.8)
    for index, pitch in enumerate((84, 88, 91, 96)):
        start = index * 0.13
        mix.add(start, tone(midi(pitch), 0.75, "sine", 0.2, decay=3.0))
        mix.add(start, tone(midi(pitch), 0.75, "square", 0.045, duty=0.125, decay=4.5))
    mix.add(0.1, noise(0.9, 0.08, high=True, decay=3.0))
    mix.add(0.5, noise(0.9, 0.05, high=True, decay=3.0))
    mix.finish(0.78)
    return mix


def make_victory():
    mix = Mix(2.7)
    phrase = [(0.0, 0.16, 72), (0.18, 0.16, 76), (0.36, 0.16, 79), (0.54, 0.5, 84)]
    for start, length, pitch in phrase:
        mix.add(start, tone(midi(pitch), length, "square", 0.24, duty=0.25, decay=2.0))
        mix.add(start, tone(midi(pitch), length, "sine", 0.18, decay=1.5))
    for start, pitch in ((0.9, 84), (0.9, 88), (0.9, 91), (0.9, 96)):
        mix.add(start, tone(midi(pitch), 1.5, "square", 0.11, duty=0.25,
                           decay=0.5, attack=0.02, release=0.35))
        mix.add(start, tone(midi(pitch), 1.5, "sine", 0.08,
                           decay=0.5, attack=0.02, release=0.35))
    for index in range(6):
        mix.add(0.9 + index * 0.09, hat(0.07))
    mix.finish(0.84)
    return mix


BUILDERS = {
    "mus_menu": compose_menu,
    "mus_game": compose_game,
    "mus_intro": compose_intro,
    "mus_ending": compose_ending,
    "sfx_jump": make_jump,
    "sfx_hit": make_hit,
    "sfx_fall": make_fall,
    "sfx_block": make_block,
    "sfx_collect": make_collect,
    "sfx_checkpoint": make_checkpoint,
    "sfx_ui_move": make_ui_move,
    "sfx_ui_confirm": make_ui_confirm,
    "sfx_ui_back": make_ui_back,
    "sfx_intro_whoosh": make_intro_whoosh,
    "sfx_intro_artifact": make_intro_artifact,
    "sfx_victory": make_victory,
}


def write_sound_resource(name, duration):
    meta = AUDIO_META[name]
    resource = {
        "$GMSound": "",
        "%Name": name,
        "audioGroupId": {
            "name": "audiogroup_default",
            "path": "audiogroups/audiogroup_default",
        },
        "bitDepth": 1,
        "bitRate": 128,
        "compression": 0,
        "conversionMode": 0,
        "duration": round(duration, 6),
        "name": name,
        "parent": {"name": "audio", "path": "folders/audio.yy"},
        "preload": meta["preload"],
        "resourceType": "GMSound",
        "resourceVersion": "2.0",
        "sampleRate": SR,
        "soundFile": name + ".wav",
        "type": 0,
        "volume": meta["volume"],
    }
    path = os.path.join(SOUND_DIR, name, name + ".yy")
    with open(path, "w", encoding="utf-8", newline="\n") as handle:
        json.dump(resource, handle, indent=2)
        handle.write("\n")


def main():
    for name in BUILDERS:
        folder = os.path.join(SOUND_DIR, name)
        os.makedirs(folder, exist_ok=True)
        mix = BUILDERS[name]()
        if name.startswith("mus_"):
            mix.loop_edges()
        wav_path = os.path.join(folder, name + ".wav")
        mix.write(wav_path)
        write_sound_resource(name, mix.n / SR)
        print(f"{name:<20} {mix.n / SR:6.2f}s  {os.path.getsize(wav_path) // 1024:5d} KB")


if __name__ == "__main__":
    main()
