#!/usr/bin/env python3
"""Checks documentation comments of the public API (instructions.md, "Documentation comments on public API").

- Objective-C public headers (CYLTableViewPlaceHolder/**/*.h, except the private ones listed below): a documentation
  comment that spans several lines is one `/*! ... */` block, never stacked `///` lines.
- Swift files of the library (CYLTableViewPlaceHolder/**/*.swift): a multi-line documentation comment is one
  `/** ... */` block (Swift's documentation parser does not read `/*!`), never stacked `///` lines.

Usage: python3 scripts/check_doc_comments.py [repository root]. Exits 1 and lists every violation otherwise.
"""
import pathlib
import re
import sys

ROOT = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else pathlib.Path(__file__).resolve().parent.parent)
LIBRARY = ROOT / 'CYLTableViewPlaceHolder'
PRIVATE_HEADERS = {'CYLPlaceholderItemAnimationService.h', 'CYLPlaceholderItemAnimationEngine.h'}
DOC_LINE = re.compile(r'^\s*///(?!/)')

problems = []
files = [p for p in LIBRARY.rglob('*.h') if p.name not in PRIVATE_HEADERS] + list(LIBRARY.rglob('*.swift'))
for path in sorted(files):
    if path.name.startswith('._'):
        continue
    lines = path.read_text(encoding='utf-8').split('\n')
    expected = '/** */' if path.suffix == '.swift' else '/*! */'
    index = 0
    while index < len(lines):
        if DOC_LINE.match(lines[index]):
            end = index
            while end < len(lines) and DOC_LINE.match(lines[end]):
                end += 1
            if end - index >= 2:
                problems.append(f'{path.relative_to(ROOT)}:{index + 1}: {end - index} stacked /// lines; '
                                f'use one {expected} block')
            index = end
        else:
            index += 1
print(f'{len(files)} public source file(s) checked')
if problems:
    print('\n'.join(problems))
    sys.exit(1)
print('Documentation comments follow the public API rule.')
