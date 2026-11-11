#!/usr/bin/env python3
"""Checks documentation comments of the public API (instructions.md, "Documentation comments on public API").

One format per public-API file, for single-line and multi-line comments alike:

- Objective-C public headers (CYLTableViewPlaceHolder/**/*.h, except the private ones listed below): every
  documentation comment is a `/*! ... */` block, one line or several; no `///` lines and no `/** ... */` blocks.
- Swift files of the library (CYLTableViewPlaceHolder/**/*.swift): every documentation comment is a `/** ... */`
  block (Swift's documentation parser does not read `/*!`); no `///` lines and no `/*!` blocks.

Usage: python3 scripts/check_doc_comments.py [repository root]. Exits 1 and lists every violation otherwise.
"""
import pathlib
import re
import sys

ROOT = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else pathlib.Path(__file__).resolve().parent.parent)
LIBRARY = ROOT / 'CYLTableViewPlaceHolder'
PRIVATE_HEADERS = {'CYLPlaceholderItemAnimationService.h', 'CYLPlaceholderItemAnimationEngine.h'}
TRIPLE_SLASH = re.compile(r'^\s*///(?!/)')
OBJC_FOREIGN_BLOCK = re.compile(r'^\s*/\*\*(?![*/])')
SWIFT_FOREIGN_BLOCK = re.compile(r'^\s*/\*!')

problems = []
files = [p for p in LIBRARY.rglob('*.h') if p.name not in PRIVATE_HEADERS] + list(LIBRARY.rglob('*.swift'))
for path in sorted(files):
    if path.name.startswith('._'):
        continue
    swift = path.suffix == '.swift'
    expected = '/** */' if swift else '/*! */'
    foreign = SWIFT_FOREIGN_BLOCK if swift else OBJC_FOREIGN_BLOCK
    for number, line in enumerate(path.read_text(encoding='utf-8').split('\n'), start=1):
        if TRIPLE_SLASH.match(line):
            problems.append(f'{path.relative_to(ROOT)}:{number}: /// comment; use {expected}, also on one line')
        elif foreign.match(line):
            problems.append(f'{path.relative_to(ROOT)}:{number}: {line.strip()[:3]} block; this file uses {expected}')
print(f'{len(files)} public source file(s) checked')
if problems:
    print('\n'.join(problems))
    sys.exit(1)
print('Documentation comments follow the public API rule.')
