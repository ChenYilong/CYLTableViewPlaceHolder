#!/usr/bin/env python3
"""Makes a stitched screenshot sheet that follows instructions.md, "Header and footer on stitched screenshots".

    python3 scripts/screenshot_sheet.py sheet.json

sheet.json (paths relative to the repository root):

    {
      "out": "docs/assets/<platform>-<os>-<device>-<what>-<commit>-<yyyymmdd>-sheet.png",
      "header": {
        "platform": "HarmonyOS 6.0.1 (API 21), x86_64 emulator",
        "ide": "DevEco Studio 6.0.1.251",
        "host": "Windows 11 23H2",
        "libraries": "CYLTabBarController ad3dca0e",
        "branch_commit": "feat/android-refresh-port-followup b8a4aaf",
        "date": "2026-11-18",
        "purpose": "Animation detail page on CYLAnimatedItemView"
      },
      "panels": [{"image": "docs/assets/<original>.jpeg", "caption": "launch, centered", "crop": [x1, y1, x2, y2]}],
      "footer": ["PASS: ...", "Measured: ...", "Originals: ..."]
    }

The sheet is a portrait PNG in the owner's order (2026-11-18, second update): one column with several rows first; two
columns with several rows only when one column would be taller than one phone screen (19.5:9, height above 2.17 times
the width); white
background, the same margin around every panel; a header band, a caption band above each panel and a footer band, all
outside the panels (nothing is drawn on a screenshot); bold English text in one high-contrast color. Panels are cropped,
never scaled. The sheet records its header, captions, footer and originals as PNG text ("cyl-screenshot-sheet"), which
scripts/check_screenshots.py reads.
"""
import json
import os
import re
import sys

from PIL import Image, ImageDraw, ImageFont, PngImagePlugin

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HEADER_KEYS = ["platform", "ide", "host", "libraries", "branch_commit", "date", "purpose"]
COLOR = (208, 2, 27)
MARGIN = 24
GAP = 12
# A common phone screen, 19.5:9: one column taller than this times its width becomes two columns.
PHONE_RATIO = 19.5 / 9
FONTS = [
    "C:/Windows/Fonts/arialbd.ttf",
    "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
    "/Library/Fonts/Arial Bold.ttf",
    "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
    "/usr/share/fonts/dejavu/DejaVuSans-Bold.ttf",
]


def font(size):
    for path in FONTS:
        if os.path.exists(path):
            return ImageFont.truetype(path, size)
    raise SystemExit("error: no bold TrueType font found (" + ", ".join(FONTS) + ")")


def split_long(draw, word, face, width):
    """A word wider than the band (a long file name) is cut into pieces that fit."""
    pieces, piece = [], ""
    for ch in word:
        if piece and draw.textlength(piece + ch, font=face) > width:
            pieces.append(piece)
            piece = ch
        else:
            piece += ch
    return pieces + ([piece] if piece else [])


def wrap(draw, text, face, width):
    lines, line = [], ""
    words = []
    for word in text.split(" "):
        words.extend(split_long(draw, word, face, width) if draw.textlength(word, font=face) > width else [word])
    for word in words:
        candidate = (line + " " + word).strip()
        if line and draw.textlength(candidate, font=face) > width:
            lines.append(line)
            line = word
        else:
            line = candidate
    if line:
        lines.append(line)
    return lines


def band(lines, face, width):
    """Height of a text band of wrapped lines."""
    probe = ImageDraw.Draw(Image.new("RGB", (1, 1)))
    rows = [r for text in lines for r in wrap(probe, text, face, width)]
    step = int(face.size * 1.3)
    return rows, len(rows) * step


def layout(panels, columns):
    cell_w = max(p.width for p in panels)
    rows = [panels[i:i + columns] for i in range(0, len(panels), columns)]
    width = MARGIN * 2 + columns * cell_w + (columns - 1) * MARGIN
    return cell_w, rows, width


def header_text(header):
    missing = [k for k in HEADER_KEYS if not str(header.get(k, "")).strip()]
    if missing:
        raise SystemExit("error: header lacks " + ", ".join(missing))
    if not re.fullmatch(r"\d{4}-\d{2}-\d{2}", header["date"]):
        raise SystemExit("error: header date must be YYYY-MM-DD")
    facts = ", ".join(str(header[k]).strip() for k in HEADER_KEYS[:-1])
    return facts + ", " + str(header["purpose"]).strip().rstrip(".") + "."


def make(spec_path):
    spec = json.load(open(spec_path, encoding="utf-8"))
    head = header_text(spec["header"])
    footer = [str(line) for line in spec.get("footer", []) if str(line).strip()]
    if not footer:
        raise SystemExit("error: the footer is empty (verdict, measured values, how, originals)")
    panels, captions, originals = [], [], []
    for p in spec["panels"]:
        if not str(p.get("caption", "")).strip():
            raise SystemExit("error: every panel needs a caption: " + p["image"])
        image = Image.open(os.path.join(ROOT, p["image"])).convert("RGB")
        if p.get("crop"):
            image = image.crop(tuple(p["crop"]))
        panels.append(image)
        captions.append(p["caption"])
        originals.append(p["image"].replace("\\", "/"))
    # One column first; two columns only when one column would be taller than a 19.5:9 phone screen.
    columns = 1
    cell_w, rows, width = layout(panels, columns)
    one_column_height = sum(p.height + MARGIN for p in panels) + MARGIN
    if len(panels) >= 2 and one_column_height > PHONE_RATIO * width:
        columns = 2
        cell_w, rows, width = layout(panels, columns)
    size = max(20, width // 42)
    face, small = font(size), font(max(18, int(size * 0.85)))
    text_w = width - 2 * MARGIN
    head_rows, head_h = band([head], face, text_w)
    foot_rows, foot_h = band(footer, small, text_w)
    cap_bands = []
    for r_index, row in enumerate(rows):
        cap_h = max(band([captions[r_index * columns + i]], small, cell_w)[1] for i in range(len(row)))
        cap_bands.append(cap_h)
    height = MARGIN + head_h + GAP * 2
    for row, cap_h in zip(rows, cap_bands):
        height += cap_h + GAP + max(p.height for p in row) + MARGIN
    height += GAP + foot_h + MARGIN
    sheet = Image.new("RGB", (width, height), "white")
    draw = ImageDraw.Draw(sheet)
    y = MARGIN
    for line in head_rows:
        draw.text((MARGIN, y), line, fill=COLOR, font=face)
        y += int(face.size * 1.3)
    y += GAP * 2
    for r_index, (row, cap_h) in enumerate(zip(rows, cap_bands)):
        row_h = max(p.height for p in row)
        for i, panel in enumerate(row):
            x = MARGIN + i * (cell_w + MARGIN)
            cy = y
            for line in wrap(draw, captions[r_index * columns + i], small, cell_w):
                draw.text((x, cy), line, fill=COLOR, font=small)
                cy += int(small.size * 1.3)
            sheet.paste(panel, (x + (cell_w - panel.width) // 2, y + cap_h + GAP))
        y += cap_h + GAP + row_h + MARGIN
    y += GAP
    for line in foot_rows:
        draw.text((MARGIN, y), line, fill=COLOR, font=small)
        y += int(small.size * 1.3)
    meta = PngImagePlugin.PngInfo()
    meta.add_text("cyl-screenshot-sheet", json.dumps({
        "header": spec["header"], "captions": captions, "footer": footer, "originals": originals,
    }, ensure_ascii=False))
    out = os.path.join(ROOT, spec["out"])
    if not out.lower().endswith(".png"):
        raise SystemExit("error: a sheet is a PNG (lossless)")
    sheet.save(out, pnginfo=meta)
    print("wrote %s (%d x %d, %d column(s))" % (spec["out"], width, height, columns))


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit(__doc__)
    make(sys.argv[1])
