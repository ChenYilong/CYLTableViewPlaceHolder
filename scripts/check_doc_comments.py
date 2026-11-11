#!/usr/bin/env python3
"""Checks documentation comments of the public API (instructions.md, "Documentation comments on public API").

One format per public-API file, for single-line and multi-line comments alike:

- Objective-C public headers (CYLTableViewPlaceHolder/**/*.h, except the private ones listed below): every
  documentation comment is a block on its own lines above the declaration:

      /*!
       * Text, one line or several.
       */

  The opening `/*!` and the closing `*/` stand alone on their lines; every line between starts with `*`. No one-line
  `/*! text */`, no `///` lines, no `/** ... */` blocks.
- Swift files of the library (CYLTableViewPlaceHolder/**/*.swift): the same shape with `/**` (Swift's documentation
  parser does not read `/*!`); no `///` lines, no `/*!` blocks.
- No trailing comment after code on the same line: `//`, `/* */`, `///<`, `/**<` or `/*!<` after a declaration or an
  enum value.

Usage: python3 scripts/check_doc_comments.py [repository root]. Exits 1 and lists every violation otherwise.
"""
import pathlib
import re
import sys

ROOT = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else pathlib.Path(__file__).resolve().parent.parent)
LIBRARY = ROOT / 'CYLTableViewPlaceHolder'
PRIVATE_HEADERS = {'CYLPlaceholderItemAnimationService.h', 'CYLPlaceholderItemAnimationEngine.h'}
STRING = re.compile(r'"(?:\\.|[^"\\])*"')

problems = []
files = [p for p in LIBRARY.rglob('*.h') if p.name not in PRIVATE_HEADERS] + list(LIBRARY.rglob('*.swift'))
for path in sorted(files):
    if path.name.startswith('._'):
        continue
    swift = path.suffix == '.swift'
    marker, foreign = ('/**', '/*!') if swift else ('/*!', '/**')
    where = path.relative_to(ROOT)

    def report(number, message):
        problems.append(f'{where}:{number}: {message}')

    in_doc = in_plain = False
    for number, line in enumerate(path.read_text(encoding='utf-8').split('\n'), start=1):
        stripped = line.strip()
        if in_doc:
            if stripped == '*/':
                in_doc = False
            elif '*/' in stripped:
                report(number, 'put the closing */ on its own line')
                in_doc = False
            elif not stripped.startswith('*'):
                report(number, 'start every line of the comment with *')
            continue
        if in_plain:
            in_plain = '*/' not in stripped
            continue
        if stripped.startswith('///'):
            report(number, f'/// comment; use a {marker} block on its own lines, also for one line')
        elif stripped.startswith(foreign) and not stripped.startswith('/***'):
            report(number, f'{foreign} block; this file uses {marker}')
        elif stripped.startswith(marker) and not stripped.startswith('/***'):
            if stripped != marker:
                report(number, f'put {marker} alone on its line and the text on the lines below, also for one line')
                in_doc = '*/' not in stripped[3:]
            else:
                in_doc = True
        elif stripped.startswith('/*'):
            in_plain = '*/' not in stripped[2:]
        elif stripped and not stripped.startswith('//') and not stripped.startswith('#pragma'):
            code = STRING.sub('""', line)
            if re.search(r'//|/\*', code):
                report(number, 'trailing comment after code; move it into a block above the declaration')
print(f'{len(files)} public source file(s) checked')
if problems:
    print('\n'.join(problems))
    sys.exit(1)
print('Documentation comments follow the public API rule.')
