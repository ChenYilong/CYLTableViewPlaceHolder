#!/usr/bin/env python3
"""Checks that a placeholder's icon and title share one vertical center line on HarmonyOS (docs/HarmonyOS.md, E16).

    python3 scripts/harmonyos-center-check.py                    # the screen now on the device (hdc)
    python3 scripts/harmonyos-center-check.py --layout dump.json # a saved `uitest dumpLayout` file
    python3 scripts/harmonyos-center-check.py --target 127.0.0.1:5555 --tolerance 1

It reads a uitest dumpLayout and checks two kinds of nodes by their inspector id:

- "<name>-icon" and "<name>-title" (CYLPlaceholderView: the icon Stack and the title Text, see `cylPartId`): the two
  centers' x must be equal within the tolerance;
- "<name>-item" (a CYLAnimatedItemView given `itemId`, such as the animation detail page): inside it, the icon (the
  widest Image, Canvas or XComponent) and every Text must be centered on the item's icon.

A title moved on purpose (`defaultTitlePositionAdjustment.x`) fails the check; leave such screens out. Exit status 0
when every pair is centered, 1 when one is not, 2 when the screen has no such node.
"""
import argparse
import json
import os
import re
import subprocess
import sys
import tempfile

DEFAULT_HDC = "C:/Program Files/Huawei/DevEco Studio/sdk/default/openharmony/toolchains/hdc.exe"
DEVICE_PATH = "/data/local/tmp/cyl-center-check.json"
ICON_TYPES = {"Image", "Canvas", "XComponent"}


def bounds(node):
    m = re.fullmatch(r"\[(-?\d+),(-?\d+)\]\[(-?\d+),(-?\d+)\]", node.get("attributes", {}).get("bounds", ""))
    return tuple(int(v) for v in m.groups()) if m else None


def center_x(b):
    return (b[0] + b[2]) / 2


def walk(node):
    yield node
    for child in node.get("children", []):
        yield from walk(child)


def dump(hdc, target):
    base = [hdc] + (["-t", target] if target else [])
    subprocess.run(base + ["shell", "uitest", "dumpLayout", "-p", DEVICE_PATH], check=True, capture_output=True)
    local = os.path.join(tempfile.mkdtemp(prefix="cyl-center-"), "layout.json")
    subprocess.run(base + ["file", "recv", DEVICE_PATH, local], check=True, capture_output=True)
    return local


def check(tree, tolerance):
    """Returns (rows, failures): one row per checked pair."""
    by_id = {}
    for node in walk(tree):
        node_id = node.get("attributes", {}).get("id", "")
        b = bounds(node)
        if node_id and b and b[2] > b[0]:
            by_id.setdefault(node_id, []).append((node, b))
    rows, failures = [], 0
    for node_id, icons in sorted(by_id.items()):
        if node_id.endswith("-icon"):
            name = node_id[:-len("-icon")]
            # Several placeholders with the same identifier: pair them in screen order.
            for (_, icon), (_, title) in zip(icons, by_id.get(name + "-title", [])):
                dx = center_x(title) - center_x(icon)
                ok = abs(dx) <= tolerance
                failures += not ok
                rows.append((ok, name, "icon x %.1f, title x %.1f, dx %+.1f" % (center_x(icon), center_x(title), dx)))
        elif node_id.endswith("-item"):
            for item, _ in icons:
                parts = [(n.get("attributes", {}).get("type"), bounds(n)) for n in walk(item)]
                icon_parts = [b for t, b in parts if t in ICON_TYPES and b and b[2] > b[0]]
                texts = [b for t, b in parts if t == "Text" and b and b[2] > b[0]]
                if not icon_parts or not texts:
                    continue
                icon = max(icon_parts, key=lambda b: b[2] - b[0])
                for text in texts:
                    dx = center_x(text) - center_x(icon)
                    ok = abs(dx) <= tolerance
                    failures += not ok
                    rows.append((ok, node_id, "icon x %.1f, text x %.1f, dx %+.1f" % (center_x(icon), center_x(text), dx)))
    return rows, failures


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--layout", help="a saved uitest dumpLayout JSON file instead of the device")
    parser.add_argument("--target", help="hdc target (default: the only device)")
    parser.add_argument("--hdc", default=os.environ.get("HDC", DEFAULT_HDC), help="hdc executable (or $HDC)")
    parser.add_argument("--tolerance", type=float, default=1.0, help="largest center difference in px (default 1)")
    args = parser.parse_args()
    path = args.layout or dump(args.hdc, args.target)
    tree = json.load(open(path, encoding="utf-8"))
    rows, failures = check(tree, args.tolerance)
    for ok, name, text in rows:
        print("%s %s: %s" % ("PASS" if ok else "FAIL", name, text))
    if not rows:
        print("no '<name>-icon' / '<name>-title' or '<name>-item' node on this screen (%s)" % path)
        return 2
    print("%d checked, %d off center (tolerance %.1f px)" % (len(rows), failures, args.tolerance))
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
