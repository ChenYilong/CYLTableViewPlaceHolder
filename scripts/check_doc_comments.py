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
- Every public declaration has a documentation comment directly above it (conditional-compilation lines and, in Swift,
  attribute lines may stand between them). Public declarations: in the headers, classes, categories, protocols,
  methods, properties, enums and each enum value, typedefs, exported constants and functions, and macros (not include
  guards or the empty `#ifndef X` / `#define X` fallbacks); in the Swift files, every `public` or `open` declaration
  and each case of a public enum, except overrides, which inherit the documentation of what they override.

Usage: python3 scripts/check_doc_comments.py [--list] [repository root]
  --list  print every public declaration that has no documentation comment, with no other output, and exit 0.
Exits 1 and lists every violation otherwise.
"""
import pathlib
import re
import sys

ARGUMENTS = [argument for argument in sys.argv[1:] if not argument.startswith('--')]
LIST_ONLY = '--list' in sys.argv[1:]
ROOT = pathlib.Path(ARGUMENTS[0] if ARGUMENTS else pathlib.Path(__file__).resolve().parent.parent)
LIBRARY = ROOT / 'CYLTableViewPlaceHolder'
PRIVATE_HEADERS = {'CYLPlaceholderItemAnimationService.h', 'CYLPlaceholderItemAnimationEngine.h'}
STRING = re.compile(r'"(?:\\.|[^"\\])*"')

def objc_declarations(lines):
    """
    [EN] (line number, declaration, documented) of each public Objective-C declaration of a header.
    [CN] 头文件中每个 Objective-C 公开声明：(行号, 声明, 是否有文档注释)。
    """
    found = []
    documented_macros, undocumented_macros = set(), {}
    in_doc = in_plain = False
    doc_ends = -2
    in_container = False
    enum_depth = 0
    pending_method = False
    previous = -2
    for number, line in enumerate(lines, start=1):
        stripped = line.strip()
        if in_doc:
            if '*/' in stripped:
                in_doc = False
                doc_ends = number
            continue
        if in_plain:
            in_plain = '*/' not in stripped
            continue
        if stripped.startswith('/*!') or (stripped.startswith('/**') and not stripped.startswith('/***')):
            in_doc = '*/' not in stripped[3:]
            if not in_doc:
                doc_ends = number
            continue
        if stripped.startswith('/*'):
            in_plain = '*/' not in stripped[2:]
            continue
        if not stripped or stripped.startswith('//'):
            continue
        # [EN] Conditional-compilation lines pass a comment on to the declaration below them.
        # [CN] 条件编译行把注释传给其下的声明。
        if re.match(r'#\s*(if|ifdef|ifndef|else|elif|endif)\b', stripped):
            if doc_ends == number - 1:
                doc_ends = number
            continue
        documented = doc_ends == number - 1
        if pending_method:
            pending_method = ';' not in stripped and '{' not in stripped
            continue
        declaration = None
        macro = re.match(r'#\s*define\s+([A-Za-z_]\w*)', stripped)
        if macro:
            name = macro.group(1)
            # [EN] Include guards and empty fallbacks of guarded macros (`#ifndef X` / `#define X`) are not API.
            # [CN] 头文件保护宏与 `#ifndef X` / `#define X` 的空回退定义不是 API。
            guard = re.match(r'#\s*ifndef\s+(\w+)', lines[number - 2].strip()) if number > 1 else None
            empty = not re.sub(r'#\s*define\s+\w+(\([^)]*\))?', '', stripped).strip()
            if not (guard and guard.group(1) == name and empty) and not name.endswith('_h'):
                if documented:
                    documented_macros.add(name)
                else:
                    undocumented_macros.setdefault(name, (number, stripped))
            continue
        if stripped.startswith('#') or stripped.startswith(('NS_ASSUME_NONNULL', '@class', '@end', 'NS_HEADER_AUDIT')):
            if stripped.startswith('@end'):
                in_container = False
            continue
        if enum_depth:
            if stripped.startswith('}'):
                enum_depth = 0
                continue
            declaration = stripped.rstrip(',')
        elif re.match(r'(typedef\s+)?NS_(ENUM|OPTIONS|CLOSED_ENUM|ERROR_ENUM)\b|typedef\s+(enum|struct)\b', stripped):
            declaration = stripped
            if '{' in stripped and '}' not in stripped:
                enum_depth = 1
        elif re.match(r'@(interface|protocol)\b', stripped):
            if not stripped.endswith(';'):
                in_container = True
                if not re.match(r'@interface\s+\w+\s*\(\s*\)', stripped):
                    declaration = stripped
        elif in_container and re.match(r'[-+]\s*\(', stripped):
            declaration = stripped
            pending_method = ';' not in stripped
        elif in_container and stripped.startswith('@property'):
            declaration = stripped
        elif in_container and stripped.startswith(('@optional', '@required', '@public', '@private', '{', '}')):
            continue
        elif not in_container and re.match(r'(typedef|UIKIT_EXTERN|FOUNDATION_EXPORT|FOUNDATION_EXTERN|extern|static\s+inline|NS_INLINE|CG_INLINE)\b', stripped):
            declaration = stripped
        elif not in_container and re.match(r'[A-Za-z_][\w\s\*]*\b[A-Za-z_]\w*\s*\(.*\)\s*(NS_\w+(\([^)]*\))?\s*)*;$', stripped):
            declaration = stripped
        if declaration:
            found.append((number, declaration, documented))
    for name, (number, text) in undocumented_macros.items():
        found.append((number, text, name in documented_macros))
    found += [(0, '#define ' + name, True) for name in documented_macros if name not in undocumented_macros]
    return sorted(found)


def swift_declarations(lines):
    """
    [EN] (line number, declaration, documented) of each `public` or `open` Swift declaration and each case of a public
         enum; overrides are left out, they inherit the documentation of what they override.
    [CN] 每个 `public` / `open` Swift 声明及公开枚举的每个 case：(行号, 声明, 是否有文档注释)；不含 override，它们继承被重写声明的文档。
    """
    found = []
    in_doc = in_plain = False
    doc_ends = -2
    attributes_start = None
    stack = []
    public_enum_depths = set()
    public_extension_depths = set()
    depth = 0
    for number, line in enumerate(lines, start=1):
        stripped = line.strip()
        if in_doc:
            if '*/' in stripped:
                in_doc = False
                doc_ends = number
            continue
        if in_plain:
            in_plain = '*/' not in stripped
            continue
        if stripped.startswith('/**') and not stripped.startswith('/***'):
            in_doc = '*/' not in stripped[3:]
            if not in_doc:
                doc_ends = number
            continue
        if stripped.startswith('/*'):
            in_plain = '*/' not in stripped[2:]
            continue
        if not stripped or stripped.startswith('//'):
            attributes_start = None
            continue
        code = STRING.sub('""', stripped)
        code = re.sub(r'//.*', '', code)
        documented = doc_ends == number - 1 or (attributes_start is not None and doc_ends == attributes_start - 1)
        if re.fullmatch(r'(@\w+(\([^)]*\))?\s*)+', code):
            if attributes_start is None:
                attributes_start = number
            continue
        start = attributes_start
        attributes_start = None
        body = re.sub(r'^(@\w+(\([^)]*\))?\s*)+', '', code)
        words = body.split()
        keyword = re.search(r'\b(class|struct|enum|protocol|extension|func|var|let|init|deinit|subscript|typealias|case|actor)\b', body)
        modifiers = set(body[:keyword.start()].split()) if keyword else set()
        is_public = bool(modifiers & {'public', 'open'})
        inside_public_enum = depth in public_enum_depths
        inside_public_extension = depth in public_extension_depths
        kind = keyword.group(1) if keyword else None
        if kind == 'case' and inside_public_enum and body.startswith('case '):
            found.append((start or number, body, documented))
        elif kind and kind not in ('extension', 'deinit') and (is_public or (inside_public_extension and not modifiers & {'private', 'fileprivate', 'internal'})) \
                and body.split()[0] in ('public', 'open', 'final', 'static', 'class', 'struct', 'enum', 'protocol', 'func', 'var', 'let', 'init', 'convenience', 'required', 'override', 'dynamic', 'nonisolated', 'indirect', 'subscript', 'typealias', 'mutating', 'lazy', 'weak', 'unowned', 'actor', 'optional'):
            if 'override' not in modifiers:
                found.append((start or number, body, documented))
        opened = code.count('{') - code.count('}')
        if opened > 0:
            if kind == 'enum' and is_public:
                public_enum_depths.add(depth + 1)
            if kind == 'extension' and 'public' in modifiers:
                public_extension_depths.add(depth + 1)
        depth += opened
        public_enum_depths = {d for d in public_enum_depths if d <= depth}
        public_extension_depths = {d for d in public_extension_depths if d <= depth}
    return found


problems = []
missing = []
declared = 0
# The drawn headers' support code is private (podspec private_header_files).
files = [p for p in LIBRARY.rglob('*.h') if p.name not in PRIVATE_HEADERS and 'Drawn/Support' not in p.as_posix()] + list(LIBRARY.rglob('*.swift'))
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
    lines = path.read_text(encoding='utf-8').split('\n')
    declarations = swift_declarations(lines) if swift else objc_declarations(lines)
    declared += len(declarations)
    missing += [f'{where}:{number}: no documentation comment: {text}' for number, text, documented in declarations if not documented]
if LIST_ONLY:
    print('\n'.join(missing))
    sys.exit(0)
problems += missing
print(f'{len(files)} public source file(s) checked, {declared} public declaration(s), {declared - len(missing)} documented')
if problems:
    print('\n'.join(problems))
    sys.exit(1)
print('Documentation comments follow the public API rule.')
