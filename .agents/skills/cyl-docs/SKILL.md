---
name: cyl-docs
description: Keep project usage, issue tracking, and skills aligned with the Objective-C APIs, and write the bilingual (Chinese/English) README and docs.
---

# Documentation

`README.md` and every document in `docs/` are bilingual, following CYLTabBarController's
`docs/Bilingual-Documentation.md`. The full rules are "Bilingual documentation (Chinese and English)" in
`instructions.md`; the working summary:

- **Reading:** read only the English part (right column of `中文 | English` tables, the part after `/` in
  `中文 / English` headings and cells, the `[EN]` block of a comment). Text with no English version is read
  as it is. Writing is not affected: write both languages.
- **Headings:** `## 中文 / English`; the anchor joins both parts with `--`
  (`#如何阅读-readme--how-to-read-this-readme`).
- **Body:** a two-column table, one paragraph or bullet per row, the same content in both columns. Wide API
  tables: the full Chinese table, then an English table with the same rows. No code fence inside a table.
- **Code samples:** outside tables, shared by both languages, comments as `// [CN] …` then `// [EN] …`.
- **Proper nouns** (app names, the author's handle) stay as they are in both columns.
- **Navigation and binding tables are generated.** Run `python3 scripts/update-docs-navigation.py` after any
  change to `README.md` or `docs/` (editing, adding, removing, renaming or moving files); never edit the
  blocks between `<!-- docs-navigation:start/end -->` or `<!-- docs-binding:start/end -->`. Each `docs/`
  document declares `<!-- bound-classes: ClassA, ClassB -->` (or `none`) under its title. The CI job
  "Docs navigation" runs the script with `--check`.
- **Attachments** live in an `assets/` folder next to the document (`assets/` at the root for the README,
  `docs/assets/` for `docs/*.md`), linked as `assets/name.png`: no absolute paths, no `../`, no other
  folders; lowercase hyphenated names that name the feature. Move assets with the document.
- **New feature or user-visible change:** a bilingual `docs/<feature>.md`, a README line linking to it,
  bug-free debugging screenshots in `docs/assets/` embedded in the document, final screenshots in the
  README. If the change could not be run, say so; never present a diagram as a screenshot.
- **Public API comments:** every public declaration has a documentation comment directly above it; several lines
  are one block, `/*! … */` in Objective-C headers and `/** … */` in Swift, never stacked `///`; a single-line comment
  is the same three-line block (`/*!`, ` * text`, ` */`), never `/*! text */` on one line or a trailing `///<` /
  `/*!< */` / `//` after a declaration; each public file has one format, on every platform and language, and
  each language's official documentation rules win where they differ (Go `//`, Rust `///`, C# `///`, Python PEP 257)
  (`instructions.md`, "Code conventions"). Run `python3 scripts/check_doc_comments.py`.
- **Every commit message** ends its body with the line `By @ChenYilong <luohanchenyilong@163.com>`
  (before trailers, exactly once; `instructions.md`, "Author line in every commit message").
- **Before every commit:** run the navigation script and `scripts/check_localizations.py`, lint the Markdown
  with `.markdownlint.json`, and grep `docs` and `README.md` for stale notes
  (`TODO|Linux|without Xcode|no (iOS )?simulator|no screenshots?|无法(编译|运行)|没有截图|暂无(测试)?截图`);
  keep each incomplete or unverified item under a `TODO` heading in the most relevant `docs/` document.


- Keep `README.md` aligned with public APIs, minimum iOS version, integration,
  resources, and example behavior.
- Keep `docs/issue-progress.md` accurate when a change affects a tracked issue;
  preserve historical context and distinguish verified fixes from limitations.
- Update `cyl-api-map` and other affected skills when API locations, commands,
  or supported build configurations change.
- Localized text follows "Localization" in `instructions.md`: `.lproj`
  folders in a `.bundle` per owner, the core bundle kept and changed only
  additively, example text in an example-level bundle read through macros.
  Each layer reads its bundle through one lookup macro (the core has its own,
  each example has its own, named with the owner's prefix); a project needs at
  least two different ones.
  Document new tables, languages and keys in the README. Resources follow the
  same split (`CYLPlaceholderResourceURL` for the core, each example's own lookup).
- Document accessibility with every user-visible control: its label, trait and
  state, and what is hidden as decoration (`instructions.md`, "Accessibility").
- Instructions and skills are written in English. Preserve required third-party
  copyright notices, licenses, and source attribution.
- Use relative paths for local references. Place attachments in an `assets/`
  subfolder next to their document.
