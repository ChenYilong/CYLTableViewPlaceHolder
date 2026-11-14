#!/usr/bin/env python3
"""Regenerate the generated blocks of the bilingual documents, or check that they are current.

    python3 scripts/update-docs-navigation.py           rewrite README.md and docs/*.md
    python3 scripts/update-docs-navigation.py --check   exit 1 if any generated block is out of date

A document opts in by carrying the markers below. Never edit the text between them by hand.

  <!-- docs-navigation:start -->  ...  <!-- docs-navigation:end -->
      The "导航 / CONTENTS" table: one row per `## 中文 / English` heading, linking the same heading from both columns.
  <!-- docs-binding:start -->  ...  <!-- docs-binding:end -->
      Written from `<!-- bound-classes: ClassA, ClassB -->` (or `none`): each class with the path of its header.

See "Bilingual documentation" in instructions.md.
"""
import os
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
NAV = ("<!-- docs-navigation:start -->", "<!-- docs-navigation:end -->")
BIND = ("<!-- docs-binding:start -->", "<!-- docs-binding:end -->")
HEADER_ROOTS = [ROOT / "CYLTableViewPlaceHolder"]


def slug(heading: str) -> str:
    """GitHub's heading anchor: lowercase, drop punctuation, spaces to hyphens ('/' leaves '--')."""
    text = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", heading)
    text = text.replace("`", "").strip().lower()
    text = re.sub(r"[^\w\s-]", "", text, flags=re.UNICODE)
    return re.sub(r"\s", "-", text)


def split_bilingual(heading: str):
    cn, _, en = heading.partition(" / ")
    return cn.strip(), (en.strip() or cn.strip())


def headings(text: str):
    fence = False
    for line in text.split("\n"):
        if line.strip().startswith("```"):
            fence = not fence
        elif not fence:
            m = re.match(r"^## (.+?)\s*$", line)
            if m:
                yield m.group(1)


def navigation_rows(text: str):
    rows = ["| 中文 | English |", "| --- | --- |"]
    for heading in headings(text):
        cn, en = split_bilingual(heading)
        if cn.startswith("导航"):
            continue
        anchor = slug(heading)
        rows.append(f"| [{cn}](#{anchor}) | [{en}](#{anchor}) |")
    return "\n".join(rows)


def header_path(name: str):
    for base in HEADER_ROOTS:
        for candidate in sorted(base.rglob(f"{name}.h")):
            return candidate.relative_to(ROOT).as_posix()
    return None


def binding_rows(text: str):
    m = re.search(r"<!--\s*bound-classes:\s*(.*?)\s*-->", text)
    if not m or m.group(1).strip().lower() == "none":
        return "| 类 / Class | 头文件 / Header |\n| --- | --- |\n| 无 / none | — |"
    rows = ["| 类 / Class | 头文件 / Header |", "| --- | --- |"]
    for name in [n.strip() for n in m.group(1).split(",") if n.strip()]:
        path = header_path(name)
        if path is None:
            raise SystemExit(f"error: bound class {name} has no header under CYLTableViewPlaceHolder/")
        rows.append(f"| `{name}` | [`{path}`]({relative_link(path)}) |")
    return "\n".join(rows)


CURRENT_DOC = ROOT


def relative_link(path: str):
    return Path(os.path.relpath(ROOT / path, CURRENT_DOC)).as_posix()


def replace_block(text: str, markers, body: str):
    start, end = markers
    if start not in text:
        return text
    pattern = re.compile(re.escape(start) + r".*?" + re.escape(end), re.S)
    return pattern.sub(lambda _: f"{start}\n\n{body}\n\n{end}", text, count=1)


def process(path: Path):
    global CURRENT_DOC
    CURRENT_DOC = path.parent
    text = path.read_text(encoding="utf-8")
    new = replace_block(text, NAV, navigation_rows(text))
    new = replace_block(new, BIND, binding_rows(new))
    return text, new


def main(argv):
    check = "--check" in argv
    documents = [ROOT / "README.md"] + sorted((ROOT / "docs").glob("*.md"))
    stale, optedin, pending = [], 0, []
    for path in documents:
        old, new = process(path)
        if NAV[0] not in old and BIND[0] not in old:
            pending.append(path.relative_to(ROOT).as_posix())
            continue
        optedin += 1
        if old != new:
            stale.append(path.relative_to(ROOT).as_posix())
            if not check:
                path.write_text(new, encoding="utf-8")
    if pending:
        print("not yet bilingual (no navigation markers): " + ", ".join(pending))
    if check and stale:
        print("out of date, run python3 scripts/update-docs-navigation.py: " + ", ".join(stale))
        return 1
    print(f"{optedin} document(s) {'checked' if check else 'updated'}" + (f", rewrote {', '.join(stale)}" if stale and not check else ""))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
