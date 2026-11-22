# Documentation scenario (`docs`)

Full text of the `docs` rules (bilingual docs, instruction files and their tags), moved verbatim from `instructions.md` and `AGENTS.md` on 2026-11-22 (owner's
rule: instruction files by tag, at most 200 lines each). Summaries: [instructions.md](../../instructions.md) and
[AGENTS.md](../../AGENTS.md), heading "Tag: Documentation scenario". English only.

## Instruction files: tags and the 200-line limit

Owner's rule (2026-11-22), verbatim intent: find the project's instruction files (including the agent / Claude files),
classify their content, manage it with keywords called tags, and show every category as a heading (for example the
testing scenario, the Windows scenario, the macOS-only scenario, the documentation scenario). Every file is sorted into
categories and tagged under headings; no category heading is hidden; every file stays within 200 lines; when a tag's
content pushes a file past 200 lines, the overflow moves to `docs/instructions/<tag>.md` and is linked by relative path,
so the detailed text is read only when its keyword or tag is triggered.

- **Which files:** `instructions.md`, `AGENTS.md` (loaded through `CLAUDE.md`), `CLAUDE.md`, every folder
  `instructions.md`, and `.github/copilot-instructions.md`.
- **Tags** (the same set in every file): `behavioral` (Behavioral guidelines: the first tag of the root files, linking `behavioral.md`, which must be read in full; `CLAUDE.md` imports it), `workflow` (Task workflow), `testing` (Testing scenario), `ci` (CI/CD scenario), `windows` (Windows scenario), `macos` (macOS-only scenario), `harmonyos` (HarmonyOS scenario), `code` (Code and architecture), `l10n-a11y` (Localization and accessibility), `docs` (Documentation scenario), `git` (Git and commits).
- **Headings:** each tag is a visible `## Tag: <Title> (\`<tag>\`)` heading; never inside `<details>` or another
  collapsed block. A file shows only the tags it has content for; `instructions.md` and `AGENTS.md` show all of them.
- **200 lines:** an instruction file never exceeds 200 lines. Overflow goes to `docs/instructions/<tag>.md` (one file per
  tag; `instructions.md` sections first, then "AGENTS.md: <section>" parts), moved verbatim; the instruction file keeps
  one summary line per rule with a relative link to the exact heading.
- **Language:** `docs/instructions/` is English only (the owner's direction), so it is outside the bilingual rule for
  `docs/`; `scripts/update-docs-navigation.py` reads only `docs/*.md`, so it is also outside the docs navigation.
- **New rules:** add the full text to the tag file and one summary line under the tag heading of the instruction file;
  when no tag fits, add a new tag to every index (`instructions.md`, `AGENTS.md`) and create its tag file. Check the
  line count (`wc -l`) after every change.

## Bilingual documentation (Chinese and English)

`README.md` and every document in `docs/` are bilingual: Chinese and English side by side. This
follows CYLTabBarController (`docs/Bilingual-Documentation.md` and its `AGENTS.md`). Instructions,
skills and commit messages stay English only (see "English naming rules").

### Reading

- Read only the English part and skip the Chinese part:
  - in a table with `中文 | English` columns, the right column;
  - in a heading or cell written `中文 / English`, the part after the `/`;
  - in a code comment, the `[EN]` block; skip the `[CN]` block that runs until the next `[EN]`,
    the next tag or the end of the comment.
- Exception: text that has no English version is read as it is, because it is the only source.
- Writing is not affected: new text is always written in both languages.

### Format

1. **Headings** read `## 中文 / English`; the anchor joins both parts with `--`, for example
   `#如何阅读-readme--how-to-read-this-readme`. The same form is used for `###` headings.
2. **Body text** is a two-column table, `| 中文 | English |`, with the same content in each row, one
   paragraph or bullet per row. A wide API table is given twice: the full Chinese table first, then an
   English table with the same rows. Never put a code fence inside a table.
3. **Code samples** sit outside tables and are shared by both languages. Their comments come in pairs,
   `// [CN] …` followed directly by `// [EN] …` in the same comment style. String literals that are
   example data stay as they are.
4. **Proper nouns** stay as they are in both columns: product and app names in a list of apps, and the
   author's handle. Files that are not tied to code declare `<!-- bound-classes: none -->`.
5. **README** starts with "如何阅读 README / How to read this README", then the generated
   "导航 / CONTENTS" table.

### Generated blocks

- The navigation table (`<!-- docs-navigation:start -->` … `<!-- docs-navigation:end -->`, one row
  per `##` heading, both columns linking the same heading) and the binding table
  (`<!-- docs-binding:start -->` … `<!-- docs-binding:end -->`) are written by
  `python3 scripts/update-docs-navigation.py`. Never edit them by hand.
- Run the script after any change to `README.md` or `docs/`: editing Markdown, or adding, removing,
  renaming or moving a file or folder. `--check` exits 1 when a block is stale; the CI job
  "Docs navigation" runs it.
- Each document in `docs/` declares the classes it documents under its title,
  `<!-- bound-classes: CYLPlaceholderView, CYLRefreshHeader -->`, or `none`. The script writes a table
  of class and header path from it. (CYLTabBarController also writes links to the document into each
  class header; this project does not.)
- A document opts in by carrying the markers; the script lists the documents that do not carry them
  yet. Converting those is tracked in `docs/issue-progress.md`.

### Attachments

Attachments (images, recordings) go in an `assets/` subfolder next to the document that uses them,
linked with a short relative path:

| Document | Attachment folder | Link |
| --- | --- | --- |
| `README.md` | `assets/` at the repository root | `assets/name.png` |
| `docs/*.md` | `docs/assets/` | `assets/name.png` |
| `Examples/<Example>/README.md` | `assets/` in that example folder | `assets/name.png` |

No absolute paths, no `../` paths and no other attachment folders. File names are lowercase with
hyphens and name the feature, for example `cyl-placeholder-scenario-04-load-failed.jpg`. When a
folder or document moves, move its assets with it and fix the links.

### New features and user-visible changes

1. Write a bilingual document in `docs/`, named after the feature.
2. Add at least one line about it to `README.md`, linking to that document.
3. Save debugging screenshots of the bug-free result in `docs/assets/` and embed them in the
   feature's document; put the final screenshots in `README.md`.
4. If the change could not be run, say so in the document. Never present a diagram as a screenshot.
5. Keep `docs/issue-progress.md`, the README and the affected `cyl-*` skills current in the same change.

### Comments in code

A comment written in Chinese is tagged `[CN]` and followed directly by its English translation tagged
`[EN]`, in the same comment style (`//`, `///`, inside the same block comment; for a trailing comment,
on the next line). Mark fixes `FIX: issue #N`. Comments that only contain a person's name, and
commented-out code, need no translation. Old Chinese-only comments are translated when the code is
touched.

### Before every commit

- Run `python3 scripts/update-docs-navigation.py` and `python3 scripts/check_localizations.py`.
- Lint the Markdown you changed with the repository's `.markdownlint.json`
  (`npx markdownlint-cli@0.39.0 README.md docs`); table pipe style is leading and trailing pipes.
- Look for notes left by an environment that could not run the code:

  ```sh
  grep -rn -i -E "TODO|Linux|without Xcode|no (iOS )?simulator|no screenshots?|无法(编译|运行)|没有截图|暂无(测试)?截图" docs README.md
  ```

  Each hit is either an item in a `TODO` section that is still true, or stale and removed. Record every
  incomplete or unverified item under a `TODO` heading in the most relevant `docs/` document.

## AGENTS.md: Project and verification

- `README.md` and every document in `docs/` are bilingual (`中文 | English` two-column tables,
  `## 中文 / English` headings, `[CN]` / `[EN]` code comments); read only the English part. Attachments go
  in an `assets/` folder next to the document and are linked relatively. Run
  `python3 scripts/update-docs-navigation.py` after any change to them and never edit the generated
  navigation by hand. See "Bilingual documentation" in `instructions.md`.

- Update relevant documentation and skills with user-visible changes. Explain
  what could not be verified; do not claim a visual behavior from compilation.
