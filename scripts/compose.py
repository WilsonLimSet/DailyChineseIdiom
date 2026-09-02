# -*- coding: utf-8 -*-
"""Compose an App Store shot in ChengYu's existing style.
   usage: compose.py <screenshot.png> <out.png> "Line one" "Line two"
   Geometry measured off the live shot 3: bg #1F1F1F, headline x=100 from y=120,
   device frame x 182..1112, y 835..2673."""
import sys
from PIL import Image, ImageDraw, ImageFont, ImageFilter

W, H, BG = 1320, 2868, (31, 31, 31)
FONT, IDX, TARGET_W = "/System/Library/Fonts/Supplemental/HelveticaNeue.ttc", 3, 1140
FX0, FY0, FX1, FY1 = 182, 835, 1112, 2673
PAD = 22

def compose(shot_path, out_path, lines):
    size = 100
    for _ in range(40):
        f = ImageFont.truetype(FONT, size, index=IDX)
        w = max(ImageDraw.Draw(Image.new("RGB", (10, 10))).textlength(l, font=f) for l in lines)
        if abs(w - TARGET_W) < 8:
            break
        size = int(size * TARGET_W / max(w, 1))
    f = ImageFont.truetype(FONT, size, index=IDX)

    canvas = Image.new("RGB", (W, H), BG)
    d = ImageDraw.Draw(canvas)
    y = 120
    for ln in lines:
        d.text((100, y), ln, font=f, fill=(255, 255, 255))
        y = d.textbbox((100, y), ln, font=f)[3] + 10

    shot = Image.open(shot_path).convert("RGB")
    iw, ih = FX1 - FX0 - 2 * PAD, FY1 - FY0 - 2 * PAD
    sw, sh = shot.size
    sc = ih / sh
    nw = int(sw * sc)
    sr = shot.resize((nw, ih), Image.LANCZOS)
    fx1 = FX1
    if nw > iw:
        o = (nw - iw) // 2
        sr = sr.crop((o, 0, o + iw, ih))
    else:
        iw = nw
        fx1 = FX0 + iw + 2 * PAD

    shadow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle([FX0 + 6, FY0 + 16, fx1 + 6, FY1 + 16], radius=86,
                                             fill=(0, 0, 0, 170))
    canvas = Image.alpha_composite(canvas.convert("RGBA"),
                                   shadow.filter(ImageFilter.GaussianBlur(30))).convert("RGB")

    frame = Image.new("RGB", (fx1 - FX0, FY1 - FY0), (250, 250, 252))
    fmask = Image.new("L", frame.size, 0)
    ImageDraw.Draw(fmask).rounded_rectangle([0, 0, frame.size[0] - 1, frame.size[1] - 1],
                                            radius=86, fill=255)
    inner = Image.new("RGB", (iw, ih), (0, 0, 0))
    inner.paste(sr, (0, 0))
    imask = Image.new("L", (iw, ih), 0)
    ImageDraw.Draw(imask).rounded_rectangle([0, 0, iw - 1, ih - 1], radius=68, fill=255)
    frame.paste(inner, (PAD, PAD), imask)
    canvas.paste(frame, (FX0, FY0), fmask)
    canvas.save(out_path)
    return canvas

if __name__ == "__main__":
    c = compose(sys.argv[1], sys.argv[2], sys.argv[3:])
    print("composed", sys.argv[2], c.size)
