#!/usr/bin/env python3
# SPDX-License-Identifier: CC-BY-SA-4.0
"""Gera a arte e os sons originais do SALPH OS (determinístico, só stdlib).

    python3 tools/gen-assets.py art     logo + wallpapers (SVG, versionados)
    python3 tools/gen-assets.py sounds  tema de sons (WAV, gerados no build)
    python3 tools/gen-assets.py png     logo em PNG p/ instalador e boot (gerado no build)
    python3 tools/gen-assets.py all
"""
import math
import random
import struct
import sys
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
INC = ROOT / "config" / "includes.chroot"

# ---------------------------------------------------------------- logo
LOGO_SYMBOL = """\
  <defs>
    <linearGradient id="salph-g" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#5ec8f2"/>
      <stop offset="1" stop-color="#3b4bb0"/>
    </linearGradient>
  </defs>
  <circle cx="128" cy="128" r="120" fill="url(#salph-g)"/>
  <path d="M60 150 C92 128 118 170 150 150 S 196 118 200 128"
        fill="none" stroke="#ffffff" stroke-opacity="0.45" stroke-width="12" stroke-linecap="round"/>
  <path d="M174 84 C150 62 94 64 94 100 C94 134 162 122 162 158 C162 194 104 196 80 172"
        fill="none" stroke="#ffffff" stroke-width="22" stroke-linecap="round"/>
"""

def logo_svg():
    return ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">\n'
            f"{LOGO_SYMBOL}</svg>\n")

def logo_text_svg():
    return ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 256" width="380" height="128">\n'
            f"{LOGO_SYMBOL}"
            '  <text x="290" y="160" font-family="Inter, Cantarell, sans-serif" font-size="96"\n'
            '        font-weight="700" letter-spacing="4" fill="#3b4bb0">SALPH<tspan font-weight="400" fill="#5e6b8a"> OS</tspan></text>\n'
            "</svg>\n")

# ---------------------------------------------------------- wallpapers
W, H = 3840, 2160
DUNES = [
    "M0 1300 C600 1150 1200 1260 1900 1180 S3200 1040 3840 1200 V2160 H0 Z",
    "M0 1500 C700 1370 1400 1610 2100 1450 S3300 1340 3840 1500 V2160 H0 Z",
    "M0 1780 C900 1590 1700 1900 2600 1720 S3500 1690 3840 1780 V2160 H0 Z",
    "M0 2000 C1000 1840 2000 2110 3000 1950 S3700 1940 3840 2010 V2160 H0 Z",
]
THEMES = {
    "day": {
        "sky": ["#7fbde8", "#bcdcf0", "#f6d7b8"],
        "orb": ("#fff3d6", 2620, 900, 210, 0.95),
        "dunes": [("#efc3a4", "#e2a98a"), ("#e2a383", "#cf8a6c"),
                  ("#cc8566", "#b56c55"), ("#a95f4d", "#8e4c41")],
        "ridge": "#ffffff", "stars": 0,
    },
    "night": {
        "sky": ["#070b24", "#1b2156", "#3a3a7c"],
        "orb": ("#e9ecff", 2900, 620, 120, 0.9),
        "dunes": [("#3f4385", "#33376f"), ("#30346a", "#272a59"),
                  ("#232650", "#1b1d42"), ("#17193a", "#10112b")],
        "ridge": "#9aa6ff", "stars": 140,
    },
}

def wallpaper_svg(name):
    t = THEMES[name]
    rnd = random.Random(f"salph-{name}")
    out = [f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}" '
           'preserveAspectRatio="xMidYMid slice">',
           "  <defs>",
           '    <linearGradient id="sky" x1="0" y1="0" x2="0" y2="1">']
    for i, c in enumerate(t["sky"]):
        out.append(f'      <stop offset="{i / (len(t["sky"]) - 1):.2f}" stop-color="{c}"/>')
    out.append("    </linearGradient>")
    oc, ox, oy, orad, oop = t["orb"]
    out += ['    <radialGradient id="glow">',
            f'      <stop offset="0" stop-color="{oc}" stop-opacity="{oop}"/>',
            f'      <stop offset="0.35" stop-color="{oc}" stop-opacity="0.35"/>',
            f'      <stop offset="1" stop-color="{oc}" stop-opacity="0"/>',
            "    </radialGradient>"]
    for i, (a, b) in enumerate(t["dunes"]):
        out += [f'    <linearGradient id="d{i}" x1="0" y1="0" x2="0.3" y2="1">',
                f'      <stop offset="0" stop-color="{a}"/>',
                f'      <stop offset="1" stop-color="{b}"/>',
                "    </linearGradient>"]
    out += ["  </defs>", f'  <rect width="{W}" height="{H}" fill="url(#sky)"/>']
    for _ in range(t["stars"]):
        x, y = rnd.uniform(0, W), rnd.uniform(0, 1250)
        r, op = rnd.uniform(1.2, 3.6), rnd.uniform(0.35, 0.95)
        out.append(f'  <circle cx="{x:.0f}" cy="{y:.0f}" r="{r:.1f}" fill="#ffffff" fill-opacity="{op:.2f}"/>')
    out += [f'  <circle cx="{ox}" cy="{oy}" r="{orad * 4}" fill="url(#glow)"/>',
            f'  <circle cx="{ox}" cy="{oy}" r="{orad}" fill="{oc}" fill-opacity="{oop}"/>']
    for i, d in enumerate(DUNES):
        out.append(f'  <path d="{d}" fill="url(#d{i})"/>')
        ridge = d.split(" V")[0]
        out.append(f'  <path d="{ridge}" fill="none" stroke="{t["ridge"]}" '
                   f'stroke-opacity="{0.10 + 0.04 * i:.2f}" stroke-width="6"/>')
    out.append("</svg>")
    return "\n".join(out) + "\n"

BG_PROPS = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE wallpapers SYSTEM "gnome-wp-list.dtd">
<wallpapers>
  <wallpaper deleted="false">
    <name>SALPH Dunas</name>
    <filename>/usr/share/backgrounds/salph/salph-dunes-day.svg</filename>
    <filename-dark>/usr/share/backgrounds/salph/salph-dunes-night.svg</filename-dark>
    <options>zoom</options>
    <shade_type>solid</shade_type>
    <pcolor>#3a6ea5</pcolor>
    <scolor>#1b2156</scolor>
  </wallpaper>
</wallpapers>
"""

def write(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8", newline="\n")
    print(path.relative_to(ROOT))

def art():
    write(INC / "usr/share/pixmaps/salph-os-logo.svg", logo_svg())
    write(INC / "usr/share/pixmaps/salph-os-logo-text.svg", logo_text_svg())
    write(INC / "usr/share/icons/hicolor/scalable/apps/salph-os.svg", logo_svg())
    for name in THEMES:
        write(INC / f"usr/share/backgrounds/salph/salph-dunes-{name}.svg", wallpaper_svg(name))
    write(INC / "usr/share/gnome-background-properties/salph.xml", BG_PROPS)

# --------------------------------------------------------------- sounds
RATE = 44100

def tone(freq, dur, decay=7.0, start=0.0):
    """Sino suave: fundamental + harmônicos, ataque curto e decaimento exponencial."""
    return (start, freq, dur, decay)

SOUNDS = {
    # nome do evento (freedesktop sound naming spec): notas
    "bell":                [tone(880, 0.35), tone(1320, 0.30, start=0.0)],
    "message-new-instant": [tone(660, 0.30), tone(990, 0.45, start=0.11)],
    "complete":            [tone(523.25, 0.4), tone(659.25, 0.4, start=0.09), tone(783.99, 0.6, start=0.18)],
    "device-added":        [tone(587.33, 0.25), tone(880, 0.35, start=0.08)],
    "device-removed":      [tone(880, 0.25), tone(587.33, 0.35, start=0.08)],
    "dialog-warning":      [tone(440, 0.25, 9), tone(440, 0.35, 9, start=0.16)],
    "dialog-error":        [tone(392, 0.3, 8), tone(311.13, 0.45, 8, start=0.14)],
    "power-plug":          [tone(523.25, 0.3), tone(1046.5, 0.4, start=0.07)],
    "power-unplug":        [tone(1046.5, 0.3), tone(523.25, 0.4, start=0.07)],
}

def render(notes):
    total = max(s + d for s, _, d, _ in notes) + 0.05
    n = int(total * RATE)
    buf = [0.0] * n
    for start, freq, dur, decay in notes:
        s0 = int(start * RATE)
        for i in range(int(dur * RATE)):
            t = i / RATE
            env = min(1.0, t / 0.004) * math.exp(-decay * t)
            v = (math.sin(2 * math.pi * freq * t)
                 + 0.30 * math.sin(2 * math.pi * 2 * freq * t)
                 + 0.08 * math.sin(2 * math.pi * 3.01 * freq * t))
            if s0 + i < n:
                buf[s0 + i] += env * v
    peak = max(abs(x) for x in buf) or 1.0
    gain = 0.5 / peak  # -6 dBFS
    # fade-out final de 20 ms para não estalar
    fade = int(0.02 * RATE)
    for i in range(fade):
        buf[n - 1 - i] *= i / fade
    return [int(max(-1.0, min(1.0, x * gain)) * 32767) for x in buf]

INDEX_THEME = """[Sound Theme]
Name=SALPH
Comment=Sons originais do SALPH OS / SALPH OS original sounds
Inherits=freedesktop
Directories=stereo

[stereo]
OutputProfile=stereo
"""

def sounds():
    d = INC / "usr/share/sounds/salph"
    write(d / "index.theme", INDEX_THEME)
    (d / "stereo").mkdir(parents=True, exist_ok=True)
    for name, notes in SOUNDS.items():
        samples = render(notes)
        p = d / "stereo" / f"{name}.wav"
        with wave.open(str(p), "wb") as w:
            w.setnchannels(2)
            w.setsampwidth(2)
            w.setframerate(RATE)
            w.writeframes(b"".join(struct.pack("<hh", s, s) for s in samples))
        print(p.relative_to(ROOT))

# ------------------------------------------------------------ PNG logo
# Rasterizador mínimo do mesmo desenho do logo SVG (sem dependências), usado
# onde SVG não é garantido: branding do Calamares e tela de boot (Plymouth).

def _cubic(p0, p1, p2, p3, steps=160):
    for i in range(steps + 1):
        t = i / steps
        u = 1 - t
        yield (u**3 * p0[0] + 3 * u * u * t * p1[0] + 3 * u * t * t * p2[0] + t**3 * p3[0],
               u**3 * p0[1] + 3 * u * u * t * p1[1] + 3 * u * t * t * p2[1] + t**3 * p3[1])

# Mesmas curvas de LOGO_SYMBOL (coordenadas 0..256)
S_STROKE = [((174, 84), (150, 62), (94, 64), (94, 100)),
            ((94, 100), (94, 134), (162, 122), (162, 158)),
            ((162, 158), (162, 194), (104, 196), (80, 172))]
WAVE_STROKE = [((60, 150), (92, 128), (118, 170), (150, 150)),
               ((150, 150), (182, 130), (196, 118), (200, 128))]

def _stamp(mask, n, points, radius):
    r2 = radius * radius
    ri = int(radius) + 1
    for cx, cy in points:
        for y in range(max(0, int(cy) - ri), min(n, int(cy) + ri + 1)):
            dy = y + 0.5 - cy
            row = y * n
            for x in range(max(0, int(cx) - ri), min(n, int(cx) + ri + 1)):
                dx = x + 0.5 - cx
                if dx * dx + dy * dy <= r2:
                    mask[row + x] = 1

def logo_png(size, ss=3):
    n = size * ss
    k = n / 256.0
    circle, s_mask, w_mask = bytearray(n * n), bytearray(n * n), bytearray(n * n)
    c, r2 = 128 * k, (120 * k) ** 2
    for y in range(n):
        dy = y + 0.5 - c
        for x in range(n):
            dx = x + 0.5 - c
            if dx * dx + dy * dy <= r2:
                circle[y * n + x] = 1
    for seg in S_STROKE:
        _stamp(s_mask, n, [(px * k, py * k) for px, py in _cubic(*seg)], 11 * k)
    for seg in WAVE_STROKE:
        _stamp(w_mask, n, [(px * k, py * k) for px, py in _cubic(*seg)], 6 * k)
    c0, c1 = (0x5e, 0xc8, 0xf2), (0x3b, 0x4b, 0xb0)
    rows = []
    for Y in range(size):
        row = bytearray([0])  # filtro PNG "None"
        for X in range(size):
            acc = [0.0, 0.0, 0.0, 0.0]
            for sy in range(ss):
                y = Y * ss + sy
                for sx in range(ss):
                    x = X * ss + sx
                    i = y * n + x
                    if not circle[i]:
                        continue
                    t = (x + y) / (2.0 * n)  # gradiente diagonal
                    col = [c0[j] + (c1[j] - c0[j]) * t for j in range(3)]
                    if w_mask[i]:
                        col = [v + (255 - v) * 0.45 for v in col]
                    if s_mask[i]:
                        col = [255.0, 255.0, 255.0]
                    for j in range(3):
                        acc[j] += col[j]
                    acc[3] += 1
            a = acc[3]
            if a:
                row += bytes([int(acc[0] / a), int(acc[1] / a), int(acc[2] / a), int(255 * a / (ss * ss))])
            else:
                row += b"\0\0\0\0"
        rows.append(bytes(row))
    return _png_bytes(size, size, b"".join(rows))

def _png_bytes(w, h, raw):
    import zlib
    def chunk(tag, data):
        c = struct.pack(">I", len(data)) + tag + data
        return c + struct.pack(">I", zlib.crc32(tag + data) & 0xffffffff)
    return (b"\x89PNG\r\n\x1a\n"
            + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0))
            + chunk(b"IDAT", zlib.compress(raw, 9))
            + chunk(b"IEND", b""))

PNG_TARGETS = {
    "etc/calamares/branding/salph/logo.png": 256,
    "etc/calamares/branding/salph/welcome.png": 320,
    "usr/share/plymouth/themes/salph/watermark.png": 160,
}

def pngs():
    for rel, size in PNG_TARGETS.items():
        p = INC / rel
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_bytes(logo_png(size))
        print(p.relative_to(ROOT))

if __name__ == "__main__":
    what = sys.argv[1] if len(sys.argv) > 1 else "all"
    if what in ("art", "all"):
        art()
    if what in ("sounds", "all"):
        sounds()
    if what in ("png", "all"):
        pngs()
    if what not in ("art", "sounds", "png", "all"):
        print(__doc__)
        sys.exit(2)
