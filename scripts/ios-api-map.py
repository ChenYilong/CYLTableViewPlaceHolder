#!/usr/bin/env python3
"""The Android -> iOS API map of CYLTableViewPlaceHolder: the reverse of scripts/android-api-map.py.

Reads every public declaration of the Android core (classes, objects, interfaces, enums, type aliases, functions,
properties and constants of android/placeholder, its Lottie / PAG / Rive animators and android/merged/library, the
CYLRefresh port), finds the iOS counterpart of each one, and writes docs/iOS-API-Map.md: one table per Kotlin file with
the Android API, its description (the first sentence of its KDoc) and the iOS API, plus the score.

The iOS counterpart comes from, in order:
1. android/merged/ios-map.json, keyed by the Android API ("Class", "Class.member" or a top-level name), with
   {"ios": "<iOS API>", "note": "..."}; "ios": "n/a" marks an Android-only API that needs no iOS counterpart (an
   Android-platform detail), counted out of the score;
2. the reverse of android/merged/api-map.json (the iOS -> Android map): an Android API that an iOS symbol maps to;
3. otherwise "TODO".

Score = rows whose iOS column is not TODO / every row that is not n/a, from 0 (all TODO) to 100 (no TODO).
`--check` fails when the document is stale or when ios-map.json names an Android API that no longer exists.

Usage: python3 scripts/ios-api-map.py [--check]
"""
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SOURCES = [
    'android/placeholder/src/main/kotlin',
    'android/placeholder-lottie/src/main/kotlin',
    'android/placeholder-pag/src/main/kotlin',
    'android/placeholder-rive/src/main/kotlin',
    'android/merged/library/src/main/kotlin',
]
# The refresh kernel and the styles folded in from SmartRefreshLayout (com.cyl.refresh.layout / header / footer /
# classics / drawable) are not scored yet: their iOS counterparts (UIScrollView plus the CYLRefresh controls) are a
# TODO recorded in the document (72 / 100 with them counted, 2026-11-17).
KERNEL = [os.path.join('android', 'merged', 'library', 'src', 'main', 'kotlin', 'com', 'cyl', 'refresh', name)
          for name in ('layout', 'header', 'footer', 'classics', 'drawable')]
API_MAP = os.path.join(ROOT, 'android', 'merged', 'api-map.json')
IOS_MAP = os.path.join(ROOT, 'android', 'merged', 'ios-map.json')
DOC = os.path.join(ROOT, 'docs', 'iOS-API-Map.md')

DECLARATION = re.compile(
    r'^(?P<mods>(?:(?:public|open|abstract|sealed|data|enum|inline|value|annotation|final|lateinit|const|'
    r'operator|infix|suspend|tailrec|external|fun)\s+)*)'
    r'(?P<kind>class|object|interface|typealias|fun|val|var)\s+'
    r'(?:<[^>]*>\s*)?(?:[\w.<>?, ]+\.)?(?P<name>`?\w+`?)')
HIDDEN = re.compile(r'\b(private|internal|protected|override)\b')


def kdoc_text(lines, index):
    """The whole KDoc right above line `index`, or ''."""
    j = index - 1
    while j >= 0 and lines[j].strip().startswith('@'):
        j -= 1
    if j < 0 or not lines[j].strip().endswith('*/'):
        return ''
    end = j
    while j >= 0 and '/**' not in lines[j]:
        j -= 1
    return ' '.join(lines[j:end + 1]) if j >= 0 else ''


IOS_TEXT = None


def ios_headers_text():
    """Every public iOS header, joined, to check a name a KDoc cites."""
    global IOS_TEXT
    if IOS_TEXT is None:
        parts = []
        for directory, _, files in os.walk(os.path.join(ROOT, 'CYLTableViewPlaceHolder')):
            for name in files:
                if name.endswith('.h'):
                    parts.append(open(os.path.join(directory, name), encoding='utf-8', errors='ignore').read())
        IOS_TEXT = '\n'.join(parts)
    return IOS_TEXT


def ios_from_kdoc(text, owner):
    """The iOS API a KDoc cites in backticks (`selector:`, `UIScrollView.cyl_x`, `CYLX`), when the iOS headers have it."""
    headers = ios_headers_text()
    for token in re.findall(r'`([^`]+)`', text):
        token = token.strip()
        name = re.sub(r'^(?:iOS\s+)?[-+]?\[?', '', token).rstrip(']')
        name = re.sub(r'^(UIScrollView|UIViewController|UITableView|UICollectionView|UIView)\.', '', name)
        bare = name.split(' ')[-1]
        if not re.match(r'^[A-Za-z_][\w:.]*$', bare) or len(bare) < 3:
            continue
        first = bare.split(':')[0].split('.')[-1]
        if re.search(r'\b' + re.escape(first) + r'\b', headers):
            selector_like = ':' in bare or bare[0].islower()
            if selector_like and owner and not bare.startswith('CYL') and owner.startswith('CYL'):
                return f'`{owner}` `{bare}`'
            return f'`{bare}`'
    return ''


def kdoc_sentence(lines, index):
    """The first sentence of the KDoc right above line `index`, or ''."""
    j = index - 1
    while j >= 0 and (lines[j].strip().startswith('@') or not lines[j].strip()):
        if not lines[j].strip():
            return ''
        j -= 1
    if j < 0 or not lines[j].strip().endswith('*/'):
        return ''
    end = j
    while j >= 0 and '/**' not in lines[j]:
        j -= 1
    if j < 0:
        return ''
    text = ' '.join(l.strip().lstrip('/*').rstrip('*/').strip() for l in lines[j:end + 1])
    text = re.sub(r'\s+', ' ', text).strip()
    text = re.split(r'\[CN\]', text)[0].replace('[EN]', '').strip()
    match = re.match(r'(.+?[.!?])(\s|$)', text)
    sentence = (match.group(1) if match else text).replace('|', '\\|')
    return sentence[:220]


def declarations():
    """[(file, key, kind, description)] for every public declaration of the Android core."""
    found = []
    for source in SOURCES:
        base = os.path.join(ROOT, source)
        for directory, _, files in sorted(os.walk(base)):
            if any(os.path.relpath(directory, ROOT).startswith(kernel) for kernel in KERNEL):
                continue
            for name in sorted(files):
                if not name.endswith('.kt'):
                    continue
                path = os.path.join(directory, name)
                rel = os.path.relpath(path, ROOT)
                lines = open(path, encoding='utf-8').read().split('\n')
                stack = []  # (owner name or None when hidden, depth at which the body opened)
                depth = 0
                in_comment = False
                ctor_owner = None  # [EN] The class whose multi-line primary constructor is being read.
                ctor_parens = 0
                for index, raw in enumerate(lines):
                    line = raw.strip()
                    if in_comment:
                        if '*/' in line:
                            in_comment = False
                        continue
                    if line.startswith('/*'):
                        if '*/' not in line:
                            in_comment = True
                        continue
                    if line.startswith('//'):
                        continue
                    code = re.sub(r'"(?:\\.|[^"\\])*"', '""', raw)
                    code = re.sub(r"'(?:\\.|[^'\\])'", "''", code)
                    code = code.split('//')[0]
                    if ctor_owner is not None:
                        # [EN] `val` / `var` parameters of a primary constructor are properties of the class.
                        param = re.match(r'^(?:@\w+\s+)*(?P<mods>(?:\w+\s+)*)(?:val|var)\s+(?P<name>\w+)', line)
                        if param and ctor_owner and ctor_parens == 1 and not HIDDEN.search(param.group('mods')):
                            kind = 'val' if re.search(r'\bval\b', line.split(param.group('name'))[0]) else 'var'
                            found.append((rel, f'{ctor_owner}.{param.group("name")}', kind, kdoc_sentence(lines, index), kdoc_text(lines, index)))
                        ctor_parens += code.count('(') - code.count(')')
                        if ctor_parens <= 0:
                            ctor_owner = None
                            if '{' in code:
                                stack.append((self_key, depth + 1, 'type'))
                            depth += code.count('{') - code.count('}')
                            while stack and depth < stack[-1][1]:
                                stack.pop()
                        continue
                    owner = stack[-1][0] if stack else ''
                    owner_hidden = stack and stack[-1][0] is None
                    match = DECLARATION.match(line)
                    opened_owner = False
                    companion = re.match(r'^(?:\w+\s+)*companion\s+object\b', line)
                    if companion and '{' in code:
                        private = bool(HIDDEN.search(line.split('companion')[0]))
                        stack.append((owner if not (owner_hidden or private) else None, depth + 1, 'companion'))
                        opened_owner = True
                    elif match and not owner_hidden and not (stack and stack[-1][2] == 'function'):
                        kind = match.group('kind')
                        decl_name = match.group('name').strip('`')
                        hidden = bool(HIDDEN.search(line.split(kind)[0])) or decl_name.startswith('_')
                        key = f'{owner}.{decl_name}' if owner else decl_name
                        if not hidden:
                            if 'enum' in match.group('mods') and kind == 'class':
                                kind = 'enum'
                            found.append((rel, key, kind, kdoc_sentence(lines, index), kdoc_text(lines, index)))
                        if kind in ('class', 'enum') and code.count('(') > code.count(')'):
                            ctor_owner = None if hidden else key
                            ctor_parens = code.count('(') - code.count(')')
                            self_key = None if hidden else key
                            if ctor_owner is None:
                                ctor_owner = ''
                            continue
                        if kind in ('class', 'object', 'interface', 'enum') and '{' in code:
                            stack.append((None if hidden else key, depth + 1, 'type'))
                            opened_owner = True
                        elif kind == 'fun' and '{' in code:
                            stack.append((None, depth + 1, 'function'))
                            opened_owner = True
                    elif ('{' in code and stack and stack[-1][2] == 'type' and not owner_hidden and
                          re.match(r'^[A-Z][A-Z0-9_]*\s*[,({;]?', line) and line[0].isupper()):
                        pass
                    elif '{' in code and not opened_owner:
                        # [EN] Any other block (function body, init, when...): its contents are not API.
                        stack.append((None, depth + 1, 'function'))
                        opened_owner = True
                    depth += code.count('{') - code.count('}')
                    while stack and depth < stack[-1][1]:
                        stack.pop()
                    if opened_owner and depth < (stack[-1][1] if stack else 0):
                        stack.pop()
    return found


def normalize(android):
    """"com.cyl.placeholder.CYLX.member(a, b)" -> "CYLX.member"."""
    text = android.split('(')[0].strip().strip('`')
    text = re.sub(r'^(?:[a-z_][\w]*\.)+(?=[A-Z])', '', text)
    return text


def reverse_map():
    data = json.load(open(API_MAP, encoding='utf-8'))
    reverse = {}
    for ios, entry in data.items():
        if entry.get('status') not in ('done', 'partial'):
            continue
        for android in re.split(r'\s*[;/]\s*|,\s*(?=[A-Z])', entry.get('android', '')):
            key = normalize(android)
            if key:
                reverse.setdefault(key, []).append((ios, entry.get('status')))
    return reverse


def ios_label(ios):
    parts = ios.split(' ', 1)
    return f'`{parts[0]}`' + (f' `{parts[1]}`' if len(parts) > 1 else '')


def build():
    overrides = json.load(open(IOS_MAP, encoding='utf-8')) if os.path.exists(IOS_MAP) else {}
    reverse = reverse_map()
    rows = declarations()
    keys = {row[1] for row in rows}
    stale = sorted(k for k in overrides if k not in keys)
    by_file = {}
    counted = done = 0
    for rel, key, kind, description, full in rows:
        override = overrides.get(key)
        if override:
            ios = override['ios']
            note = override.get('note', '')
            cell = 'n/a' if ios == 'n/a' else ('TODO' if ios == 'TODO' else ios)
        elif key in reverse:
            cell = ', '.join(ios_label(i) for i, _ in reverse[key][:3])
            partial = any(status == 'partial' for _, status in reverse[key])
            note = 'partial (see docs/Android-API-Map.md)' if partial else ''
        else:
            owner = key.split('.')[0] if '.' in key else ''
            cited = ios_from_kdoc(full, owner)
            cell, note = (cited, 'matched by the iOS name its KDoc cites') if cited else ('TODO', '')
        if cell != 'n/a':
            counted += 1
            done += cell != 'TODO'
        by_file.setdefault(rel, []).append((key, kind, description, cell, note))
    return by_file, counted, done, stale


def render(by_file, counted, done):
    score = round(100 * done / counted) if counted else 100
    todo = counted - done
    out = [
        '# iOS API 对照表（Android → iOS） / The iOS API map (Android → iOS)',
        '',
        '<!-- bound-classes: none -->',
        '',
        '<!-- Generated by scripts/ios-api-map.py from the Android core and android/merged/ios-map.json; '
        'do not edit by hand. -->',
        '<!-- 由 scripts/ios-api-map.py 根据 Android core 与 android/merged/ios-map.json 生成；请勿手动编辑。 -->',
        '',
        '| 中文 | English |',
        '|:---|:---|',
        '| Android core（`android/placeholder` 及其 Lottie / PAG / Rive 动画器、`android/merged/library` 中的 CYLRefresh）的每个公开 '
        'API：第一列为 Android API，第二列为功能描述（KDoc 首句），第三列为 iOS 对应的 API 或功能，默认 TODO。iOS → Android 方向见 '
        '[Android-API-Map.md](Android-API-Map.md)。数据：`android/merged/ios-map.json`（手动对照）与 `android/merged/api-map.json` 的反向映射。 | '
        'Every public API of the Android core (`android/placeholder` with its Lottie / PAG / Rive animators, and CYLRefresh in '
        '`android/merged/library`): the Android API, a description (the first sentence of its KDoc), and the iOS API or feature, '
        'TODO by default. The iOS → Android direction is [Android-API-Map.md](Android-API-Map.md). Data: '
        '`android/merged/ios-map.json` (hand-written matches) and the reverse of `android/merged/api-map.json`. |',
        f'| **评分：{score} / 100**（{done} / {counted} 行已有 iOS 对应，TODO {todo} 行；n/a 为仅 Android 平台的细节，不计入）。第三列没有 TODO 为满分，全部 TODO 为 0 分。 | '
        f'**Score: {score} / 100** ({done} of {counted} rows have an iOS counterpart, {todo} TODO; n/a rows are Android '
        'platform details, counted out). No TODO in the third column is 100; all TODO is 0. |',
        '| TODO：从 SmartRefreshLayout 并入的刷新内核与样式（`com.cyl.refresh.layout` / `header` / `footer` / `classics` / '
        '`drawable`，2026-11-17）尚未计入本表；计入后评分为 72 / 100，需逐个找出 iOS 对应（UIScrollView 与 CYLRefresh 控件）。 | '
        'TODO: the refresh kernel and the styles folded in from SmartRefreshLayout (`com.cyl.refresh.layout` / `header` / '
        '`footer` / `classics` / `drawable`, 2026-11-17) are not counted in this table yet; counted, the score is 72 / 100, '
        'and each needs its iOS counterpart (UIScrollView and the CYLRefresh controls). |',
        '',
    ]
    for rel in sorted(by_file):
        out += [f'## `{rel}`', '', '| Android API | 描述 / Description | iOS API | 说明 / Note |', '|:---|:---|:---|:---|']
        for key, kind, description, cell, note in by_file[rel]:
            out.append(f'| `{key}` ({kind}) | {description} | {cell} | {note} |')
        out.append('')
    return '\n'.join(out)


def main():
    by_file, counted, done, stale = build()
    text = render(by_file, counted, done)
    if '--check' in sys.argv:
        problems = []
        if stale:
            problems.append('ios-map.json names Android APIs that no longer exist: ' + ', '.join(stale))
        if not os.path.exists(DOC) or open(DOC, encoding='utf-8').read() != text + '\n':
            problems.append('docs/iOS-API-Map.md is stale: run python3 scripts/ios-api-map.py')
        if problems:
            print('\n'.join(problems))
            sys.exit(1)
        print(f'docs/iOS-API-Map.md is current ({done} / {counted}).')
        return
    with open(DOC, 'w', encoding='utf-8') as handle:
        handle.write(text + '\n')
    if stale:
        print('warning: stale ios-map.json keys: ' + ', '.join(stale))
    print(f'wrote docs/iOS-API-Map.md: score {round(100 * done / counted) if counted else 100} / 100 '
          f'({done} / {counted}, TODO {counted - done})')


if __name__ == '__main__':
    main()
