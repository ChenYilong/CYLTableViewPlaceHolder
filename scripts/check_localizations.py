#!/usr/bin/env python3
"""Checks the repository's localization files against the rules in instructions.md ("Localization").

- `.strings`, `.stringsdict` and `.xcstrings` files live only in `<language>.lproj` folders inside a `.bundle`.
- Every table of a bundle has the same keys in every language as in `en`, no duplicates, no empty values, and the
  same format specifiers (`%ld`, `%@`) as `en`.
- A localization header next to a bundle (`#define <Prefix>L10n<Name> @"<key>"`) names only keys of its table, and
  every key of the table has a macro.

Usage: python3 scripts/check_localizations.py [repository root]. Exits 1 and lists every problem otherwise.
"""
import collections
import pathlib
import re
import sys

ROOT = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else pathlib.Path(__file__).resolve().parent.parent)
SKIP = {'.git', 'Pods', 'build', 'DerivedData', 'node_modules'}
ENTRY = re.compile(r'^\s*"((?:[^"\\]|\\.)*)"\s*=\s*"((?:[^"\\]|\\.)*)"\s*;\s*$')
FORMAT = re.compile(r'%(?:\d+\$)?[-+ #0]*\d*(?:\.\d+)?(?:hh|h|ll|l|q|z|t|j)?[@dDiuUxXoOfeEgGcCsSp]')
MACRO = re.compile(r'^\s*#define\s+\w+L10n\w+\s+@"([^"]+)"', re.M)
problems = []


def visible(path):
    return not any(part in SKIP or part.startswith('._') for part in path.relative_to(ROOT).parts)


def parse(path):
    text = re.sub(r'/\*.*?\*/', '', path.read_text(encoding='utf-8'), flags=re.S)
    entries = []
    for number, line in enumerate(text.splitlines(), 1):
        if not line.strip() or line.strip().startswith('//'):
            continue
        match = ENTRY.match(line)
        if not match:
            problems.append(f'{path.relative_to(ROOT)}:{number}: not a "key" = "value"; line')
            continue
        if not match.group(2):
            problems.append(f'{path.relative_to(ROOT)}:{number}: empty value for {match.group(1)}')
        entries.append(match.groups())
    duplicates = [key for key, count in collections.Counter(k for k, _ in entries).items() if count > 1]
    for key in duplicates:
        problems.append(f'{path.relative_to(ROOT)}: duplicate key {key}')
    return dict(entries)


for path in sorted(p for p in ROOT.rglob('*') if p.suffix in {'.strings', '.stringsdict', '.xcstrings'} and visible(p)):
    if path.parent.suffix != '.lproj' or path.parent.parent.suffix != '.bundle':
        problems.append(f'{path.relative_to(ROOT)}: localization file outside <language>.lproj in a .bundle')

bundles = sorted(p for p in ROOT.rglob('*.bundle') if p.is_dir() and visible(p) and any(p.glob('*.lproj')))
for bundle in bundles:
    tables = sorted({f.stem for f in bundle.glob('*.lproj/*.strings')})
    for table in tables:
        reference_path = bundle / 'en.lproj' / f'{table}.strings'
        if not reference_path.exists():
            problems.append(f'{reference_path.relative_to(ROOT)}: missing English table')
            continue
        reference = parse(reference_path)
        for language_dir in sorted(bundle.glob('*.lproj')):
            if language_dir.name == 'en.lproj':
                continue
            path = language_dir / f'{table}.strings'
            if not path.exists():
                problems.append(f'{path.relative_to(ROOT)}: missing table')
                continue
            entries = parse(path)
            for key in sorted(reference.keys() - entries.keys()):
                problems.append(f'{path.relative_to(ROOT)}: missing key {key}')
            for key in sorted(entries.keys() - reference.keys()):
                problems.append(f'{path.relative_to(ROOT)}: key {key} is not in en')
            for key in sorted(reference.keys() & entries.keys()):
                if sorted(FORMAT.findall(reference[key])) != sorted(FORMAT.findall(entries[key])):
                    problems.append(f'{path.relative_to(ROOT)}: format specifiers of {key} differ from en')
        for header in sorted(bundle.parent.glob('*Localization.h')):
            source = header.with_suffix('.m')
            text = header.read_text(encoding='utf-8') + (source.read_text(encoding='utf-8') if source.exists() else '')
            macros = set(MACRO.findall(text))
            if not macros or f'@"{table}"' not in text:
                continue  # This header belongs to another table.
            for key in sorted(macros - reference.keys()):
                problems.append(f'{header.relative_to(ROOT)}: macro key {key} is not in {table}.strings')
            for key in sorted(reference.keys() - macros):
                problems.append(f'{header.relative_to(ROOT)}: no macro for {table}.strings key {key}')
    print(f'{bundle.relative_to(ROOT)}: {len(tables)} table(s), '
          f'{len(list(bundle.glob("*.lproj")))} language(s)')

if problems:
    print('\n'.join(problems))
    sys.exit(1)
print('Localization files are consistent.')
