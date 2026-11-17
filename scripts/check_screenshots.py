#!/usr/bin/env python3
"""Checks that every screenshot in docs/assets follows instructions.md, "Screenshots of local builds and CI/CD" and
"Header and footer on stitched screenshots" (enforced since 2026-11-18, 9cdf294).

    python3 scripts/check_screenshots.py            # fail on a screenshot that breaks the rule
    python3 scripts/check_screenshots.py --legacy   # list the images the rule does not cover (screenshot-legacy.txt)

An image that is not in docs/assets/screenshot-legacy.txt (the images committed before the rule; never add to it) must be
  - a sheet made by scripts/screenshot_sheet.py, or by another tool with a sidecar <sheet>.sheet.json holding the same
    record: a PNG whose "cyl-screenshot-sheet" text (or sidecar) has every header field
    (platform, IDE, host, libraries, branch and commit, YYYY-MM-DD date, purpose), a caption per panel, a footer, and
    originals that exist in docs/assets; or
  - an original capture used by such a sheet, named <platform>-...-<commit>-<yyyymmdd>.<png|jpg|jpeg> with the platform
    one of ios, android, harmonyos, wechat-miniprogram, flutter, react-native.
"""
import json
import os
import re
import sys

try:
    from PIL import Image
except ImportError:  # Pillow is not part of the system Python on macOS or Ubuntu.
    raise SystemExit("error: this script needs Pillow: python3 -m pip install pillow (or a venv; CI installs it)")

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS = os.path.join(ROOT, "docs", "assets")
LEGACY = os.path.join(ASSETS, "screenshot-legacy.txt")
IMAGE = re.compile(r"\.(png|jpe?g)$", re.I)
ORIGINAL = re.compile(r"^(ios|android|harmonyos|wechat-miniprogram|flutter|react-native)-[a-z0-9._-]+-[0-9a-f]{7,40}-\d{8}"
                      r"\.(png|jpe?g)$")
HEADER_KEYS = ["platform", "ide", "host", "libraries", "branch_commit", "date", "purpose"]


def images():
    return sorted(f for f in os.listdir(ASSETS) if IMAGE.search(f) and os.path.isfile(os.path.join(ASSETS, f)))


def legacy():
    if not os.path.exists(LEGACY):
        return set()
    return {line.strip() for line in open(LEGACY, encoding="utf-8") if line.strip() and not line.startswith("#")}


def sheet_meta(name):
    """The sheet's record: its PNG text (scripts/screenshot_sheet.py) or a sidecar <name>.sheet.json (another tool)."""
    sidecar = os.path.join(ASSETS, os.path.splitext(name)[0] + ".sheet.json")
    if os.path.exists(sidecar):
        return json.load(open(sidecar, encoding="utf-8"))
    if not name.lower().endswith(".png"):
        return None
    with Image.open(os.path.join(ASSETS, name)) as im:
        text = im.info.get("cyl-screenshot-sheet")
    return json.loads(text) if text else None


def main():
    old = legacy()
    files = images()
    if "--legacy" in sys.argv:
        print("\n".join(sorted(old)))
        return 0
    errors = []
    sheets = {}
    for name in files:
        if name in old:
            continue
        meta = sheet_meta(name)
        if meta is not None:
            sheets[name] = meta
    used = set()
    for name, meta in sheets.items():
        header = meta.get("header", {})
        missing = [k for k in HEADER_KEYS if not str(header.get(k, "")).strip()]
        if missing:
            errors.append("%s: header lacks %s" % (name, ", ".join(missing)))
        if not re.fullmatch(r"\d{4}-\d{2}-\d{2}", str(header.get("date", ""))):
            errors.append("%s: header date is not YYYY-MM-DD" % name)
        if not meta.get("footer"):
            errors.append("%s: no footer" % name)
        captions = meta.get("captions", [])
        originals = meta.get("originals", [])
        if not originals or not captions or not all(str(c).strip() for c in captions):
            errors.append("%s: every panel needs a caption" % name)
        for original in originals:
            base = os.path.basename(original)
            used.add(base)
            if not os.path.exists(os.path.join(ROOT, original)):
                errors.append("%s: original %s is missing" % (name, original))
    for name in files:
        if name in old or name in sheets:
            continue
        if name not in used:
            errors.append("%s: neither a sheet made by scripts/screenshot_sheet.py nor an original one uses" % name)
        elif not ORIGINAL.match(name):
            errors.append("%s: an original is named <platform>-...-<commit>-<yyyymmdd>.<png|jpg|jpeg>" % name)
    for error in errors:
        print("error: " + error)
    print("%d screenshot(s) checked, %d sheet(s), %d legacy" % (len(files) - len(old & set(files)), len(sheets),
                                                                 len(old & set(files))))
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
