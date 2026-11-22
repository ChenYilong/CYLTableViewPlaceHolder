---
name: cyl-docs
description: Keep project usage, issue tracking, and skills aligned with the Objective-C APIs, and write the bilingual (Chinese/English) README and docs.
---

# Documentation

**Every task starts in `docs/`.** Before any change, record the task as a `TODO` in the fitting document
(`docs/Task-Log.md` when none fits) with the date, the branch, the user's original prompt verbatim, the user's
requirements and the detailed context; commit and push it first. Mark it done (`已完成 / Done`, date, commits,
verification) when the task ends. See `instructions.md`, "Record every task in docs before starting it".

- **Check the other sessions first** (step one of every task): list them and read their tasks; if one edits the same
  branch, check whether the task duplicates theirs and settle it with that session before changing anything.
- **Start with `TODO` and the branch:** the session's first reply begins with a `TODO` line naming the task and the
  current branch.
- **Score against acceptance criteria:** the `TODO` entry states what full marks (100) and a pass (60) are. Score
  after each step; never stop below a pass, keep rescoring until it passes. Write down why full marks were not
  reached, print the missing points as `TODO`s at the end of the session, and update the entry written at task start.
- **A hung emulator is restarted:** when a shared emulator stays hung or does not open, tell the other sessions
  first, then restart it from the command line without asking (restart is the first strategy); say "done" after.
- See `instructions.md`, "Record every task in docs before starting it" and "Shared emulators: restart a hung
  emulator".

**Another project as a source** (a translation or port of a linked GitHub repository): the task's document also
lists that project's open pull requests (merged, translated or not taken, with why) and a table of its open issues
(issue link, description, status `TODO` by default) with a score that rises after every fixed issue until 100;
translation starts at 60. See `instructions.md`, "Translating or porting another project".

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
  README. If the change could not be run, say so; never present a diagram as a screenshot. Every screenshot, local
  or CI/CD, lives in `docs/` (committed) and, once the result is right, in the README with the platform, the OS /
  simulator / SDK versions, the commit link and the time; key details only, stitched in a portrait sheet: one column with several
  rows first, two columns with several rows only when one column would be taller than one phone screen (height above
  about 2.17 times the width), a single row last (at most three per row), with an English header (platform and
  device, simulator OS, IDE version, host OS, library and repository commits, date, test purpose), a caption band
  above each panel and a footer (verdict, measured values, method, original file names) that never overlap the
  screenshots (`instructions.md`, "Header and footer on stitched screenshots"), from clear original images (`instructions.md`,
  "Screenshots of local builds and CI/CD").
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

## Animation playback controls in examples

Example pages that show animations are tracked in `docs/Example-Animation-Playback.md` (the rule, the engine table and
one row per page and platform). When a page gains or changes its "Play all" / speed slider / loop switch, update its row
and screenshot there; the rule itself is in `instructions.md`, "Animation playback controls in examples".

When a bug is fixed in an example instead of the core (only with the owner's approval, `instructions.md`, "Fix bugs
in the core first"), the related document (issue table, task entry or feature document) states why the core cannot
solve it and why the example layer does.

## Screenshots: enforced

- **Screenshots are enforced:** every stitched image is made with `python3 scripts/screenshot_sheet.py` (portrait, one
  column first, bold English header / captions / footer outside the panels, recorded in the PNG; another tool adds a
  `<sheet>.sheet.json` sidecar), originals are named `<platform>-...-<commit>-<yyyymmdd>`, and
  `python3 scripts/check_screenshots.py` must pass before every commit that adds an image (a local check; CI does not run it). Never add to
  `docs/assets/screenshot-legacy.txt`. After every pull, read the rule changes it brought
  (`git diff ORIG_HEAD HEAD -- instructions.md AGENTS.md .agents/skills`) before committing; never pull and commit in
  one command. See `instructions.md`, "Enforcement: every screenshot passes the checker" and "Re-read the rules a pull
  changes".

## Instruction files: tags and the 200-line limit (owner's rule, 2026-11-22)

- Every instruction file (`instructions.md`, `AGENTS.md`, `CLAUDE.md`, each folder `instructions.md`,
  `.github/copilot-instructions.md`) groups its content under visible `## Tag: <Title> (\`<tag>\`)` headings, never
  hidden or collapsed. Tags: `workflow`, `testing`, `ci`, `windows`, `macos`, `harmonyos`, `code`, `l10n-a11y`, `docs`, `git` (for example the testing scenario, the Windows
  scenario, the macOS-only scenario, the documentation scenario).
- Each instruction file stays within 200 lines. When a tag's content pushes a file past 200 lines, move the overflow
  verbatim to `docs/instructions/<tag>.md` (English only; outside the bilingual rule and the docs navigation) and keep
  one summary line per rule with a relative link to the exact heading, so the details are read when the tag or keyword
  applies.
- New rule: full text in the tag file, one summary line under the tag heading; check `wc -l` afterwards. Full rule:
  `docs/instructions/docs.md`, "Instruction files: tags and the 200-line limit".
