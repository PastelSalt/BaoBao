#!/usr/bin/env python3
"""Synthesises BaoBao's original music and sound effects.

Everything here is generated from this script, so the audio is original work
with no third-party licence attached. Output is deterministic.

Needs numpy and ffmpeg. Run from the repository root:  python3 tool/make_audio.py
"""
import subprocess
import tempfile
import wave
from pathlib import Path

import numpy as np

SR = 44100
OUT = Path(__file__).resolve().parent.parent / "assets/audio"


def hz(midi: float) -> float:
    return 440.0 * 2 ** ((midi - 69) / 12)


def tone(freq, seconds, *, attack=0.01, decay=1.5, harmonics=((1, 1.0),), vibrato=0.0):
    """A note with an exponential decay, built from sine partials."""
    t = np.arange(int(SR * seconds)) / SR
    phase = 2 * np.pi * freq * t
    if vibrato:
        phase += vibrato * np.sin(2 * np.pi * 5 * t)
    wave_ = sum(amp * np.sin(k * phase) for k, amp in harmonics)
    env = np.minimum(t / attack, 1.0) * np.exp(-t / decay)
    return wave_ * env


def pad(freq, seconds, *, attack=1.2, release=1.5):
    """A soft sustained note: two slightly detuned sines with a slow swell."""
    t = np.arange(int(SR * seconds)) / SR
    body = np.sin(2 * np.pi * freq * t) + np.sin(2 * np.pi * freq * 1.004 * t)
    body += 0.3 * np.sin(2 * np.pi * freq * 2 * t)
    env = np.minimum(t / attack, 1.0) * np.minimum((seconds - t) / release, 1.0)
    return body * np.clip(env, 0, 1)


def place(track, sound, at_seconds, gain=1.0, pan=0.0):
    """Mixes a mono sound into the stereo track at a time and pan position."""
    start = int(at_seconds * SR)
    if start >= track.shape[0]:
        return
    sound = sound[: track.shape[0] - start]
    left, right = np.cos((pan + 1) * np.pi / 4), np.sin((pan + 1) * np.pi / 4)
    track[start : start + len(sound), 0] += sound * gain * left
    track[start : start + len(sound), 1] += sound * gain * right


def reverb(track, *, mix=0.25):
    """A small room made from a few feedback delays."""
    wet = np.zeros_like(track)
    for delay_ms, feedback in ((113, 0.45), (167, 0.4), (229, 0.35), (311, 0.3)):
        d = int(SR * delay_ms / 1000)
        echo = np.zeros_like(track)
        echo[d:] = track[:-d]
        for _ in range(4):
            wet += echo * feedback
            shifted = np.zeros_like(echo)
            shifted[d:] = echo[:-d]
            echo = shifted * feedback
    return track * (1 - mix) + wet * mix


def finish(track, *, fade=2.0):
    """Fades the ends so the loop point is gentle, then normalises."""
    n = int(SR * fade)
    ramp = np.linspace(0, 1, n)[:, None]
    track[:n] *= ramp
    track[-n:] *= ramp[::-1]
    return track / np.max(np.abs(track)) * 0.82


def save(track, target: Path, bitrate="96k"):
    target.parent.mkdir(parents=True, exist_ok=True)
    pcm = (np.clip(track, -1, 1) * 32767).astype(np.int16)
    with tempfile.NamedTemporaryFile(suffix=".wav") as tmp:
        with wave.open(tmp.name, "wb") as w:
            w.setnchannels(pcm.shape[1])
            w.setsampwidth(2)
            w.setframerate(SR)
            w.writeframes(pcm.tobytes())
        subprocess.run(
            ["ffmpeg", "-loglevel", "error", "-y", "-i", tmp.name, "-c:a", "aac", "-b:a", bitrate,
             "-movflags", "+faststart", str(target)],
            check=True)


MUSIC_BOX = ((1, 1.0), (2, 0.35), (3, 0.12), (4.2, 0.05))
PLUCK = ((1, 1.0), (2, 0.5), (3, 0.25), (4, 0.1))


def song(*, seed, bpm, root, scale, chords, bars, melody_density, lead=MUSIC_BOX,
         lead_decay=1.2, bass=True, rain=False, swing=0.0):
    """Builds a looping piece: pads on a chord progression, a wandering
    pentatonic melody, and an optional bass and rain bed."""
    rng = np.random.default_rng(seed)
    beat = 60 / bpm
    bar = beat * 4
    track = np.zeros((int(SR * bar * bars) + SR * 3, 2))
    notes = [root + 12 * octave + step for octave in (0, 1) for step in scale]

    position = len(notes) // 2
    for b in range(bars):
        chord = chords[b % len(chords)]
        for i, interval in enumerate(chord):
            place(track, pad(hz(root - 12 + interval), bar + 1.0), b * bar, gain=0.16,
                  pan=(-0.5, 0.0, 0.5)[i % 3])
        if bass:
            for half in (0, 2):
                place(track, tone(hz(root - 24 + chord[0]), beat * 1.8, decay=0.9,
                                  harmonics=((1, 1.0), (2, 0.2))), b * bar + half * beat, gain=0.30)
        for eighth in range(8):
            strong = eighth % 2 == 0
            if rng.random() > (melody_density if strong else melody_density * 0.55):
                continue
            # A random walk keeps the melody singable; pentatonic keeps it consonant.
            position = int(np.clip(position + rng.choice([-2, -1, -1, 0, 1, 1, 2]), 0, len(notes) - 1))
            when = b * bar + eighth * beat / 2 + (swing * beat / 2 if not strong else 0)
            place(track, tone(hz(notes[position] + 12), 2.5, decay=lead_decay, harmonics=lead),
                  when, gain=0.34 if strong else 0.24, pan=float(rng.uniform(-0.4, 0.4)))

    if rain:
        noise = rng.normal(size=track.shape[0])
        # Crude low-pass: a moving average softens the hiss into rain.
        kernel = np.ones(24) / 24
        soft = np.convolve(noise, kernel, mode="same")
        track[:, 0] += soft * 0.10
        track[:, 1] += np.roll(soft, 977) * 0.10

    return finish(reverb(track)[: int(SR * bar * bars)])


MAJOR_PENT = (0, 2, 4, 7, 9)
MINOR_PENT = (0, 3, 5, 7, 10)


def main() -> None:
    music = {
        # Home tracks (catalogue items).
        "bamboo_morning": dict(seed=11, bpm=72, root=60, scale=MAJOR_PENT, bars=20, melody_density=0.55,
                               chords=[(0, 4, 7), (9, 12, 16), (5, 9, 12), (7, 11, 14)]),
        "paper_lanterns": dict(seed=23, bpm=84, root=65, scale=MAJOR_PENT, bars=24, melody_density=0.7,
                               chords=[(0, 4, 7), (5, 9, 12), (9, 12, 16), (7, 11, 14)], swing=0.25),
        "quiet_rain": dict(seed=37, bpm=60, root=57, scale=MINOR_PENT, bars=16, melody_density=0.4,
                           chords=[(0, 3, 7), (8, 12, 15), (3, 7, 10), (10, 14, 17)],
                           lead_decay=1.8, rain=True),
        # Screen tracks.
        "shop": dict(seed=41, bpm=104, root=67, scale=MAJOR_PENT, bars=28, melody_density=0.8,
                     chords=[(0, 4, 7), (5, 9, 12), (0, 4, 7), (7, 11, 14)], lead=PLUCK,
                     lead_decay=0.5, swing=0.3),
        "claw_machine": dict(seed=53, bpm=120, root=62, scale=MAJOR_PENT, bars=32, melody_density=0.85,
                             chords=[(0, 4, 7), (7, 11, 14), (9, 12, 16), (5, 9, 12)], lead=PLUCK,
                             lead_decay=0.35),
    }
    for name, settings in music.items():
        save(song(**settings), OUT / "music" / f"{name}.m4a")

    # Effects.
    click = np.zeros((int(SR * 0.12), 2))
    place(click, tone(hz(84), 0.1, attack=0.002, decay=0.025, harmonics=((1, 1.0), (2.7, 0.3))), 0)
    save(click / np.max(np.abs(click)) * 0.6, OUT / "sfx/click.m4a", "64k")

    win = np.zeros((int(SR * 1.6), 2))
    for i, note in enumerate((72, 76, 79, 84)):
        place(win, tone(hz(note), 1.2, decay=0.45, harmonics=MUSIC_BOX), i * 0.11, pan=(i - 1.5) / 3)
    save(reverb(win) / np.max(np.abs(win)) * 0.7, OUT / "sfx/win.m4a", "64k")

    miss = np.zeros((int(SR * 1.0), 2))
    for i, note in enumerate((67, 64)):
        place(miss, tone(hz(note), 0.8, decay=0.3, harmonics=((1, 1.0), (2, 0.2))), i * 0.18)
    save(reverb(miss) / np.max(np.abs(miss)) * 0.55, OUT / "sfx/miss.m4a", "64k")

    print("audio written to", OUT)


if __name__ == "__main__":
    main()
