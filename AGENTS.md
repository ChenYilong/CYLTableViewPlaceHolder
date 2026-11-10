# Agent rules for CYLTableViewPlaceHolder

This repository contains an Objective-C iOS table-view placeholder library,
the integrated `CYLRefresh` component, and an example application. Read
`instructions.md` and the relevant project skill before changing code.

## Source of truth

- Public headers under `CYLTableViewPlaceHolder/` define the current API.
- `README.md` documents integration and usage; `docs/issue-progress.md` records
  issue history and known limits. If they disagree, verify the code and update
  the affected documentation.
- Use the project skills in `.agents/skills/`: `cyl-api-map` for API locations,
  `cyl-xcode-compat` for project settings, `cyl-verify` for verification, and
  `cyl-docs` for documentation changes.

## Naming and compatibility

- Follow the English naming rules in `instructions.md`: new project-owned
  classes use `CYL`; UIKit category files use `+CYL`; category methods and
  properties use `cyl_`, except required system overrides.
- Do not rename existing public symbols, serialized keys, or resources without
  assessing compatibility and obtaining approval for breaking changes.
- Preserve third-party copyright, license text, and original attribution. Do
  not replace an author's name with the project author's name.
- The library supports iOS 12.0; preserve that minimum in the podspec and
  guard newer APIs. Runnable projects' Podfiles follow the iOS 15.0 rules in
  `instructions.md`; their CocoaPods dependencies consequently require iOS 15.
- Preserve the Xcode project format: `objectVersion = 46`,
  `compatibilityVersion = "Xcode 3.2"`, explicit file references, and a shared
  scheme. Do not copy device identifiers or signing credentials from another
  machine.

## Project and verification

- The example compiles local refresh sources directly and does not require the
  former external refresh Pod. Keep the source files, the resource bundle,
  privacy manifest, and third-party license in both the project and podspec.
- All localization files and images live in one resource bundle,
  `CYLTableViewPlaceHolder.bundle`: placeholder strings in
  `<language>.lproj/Localizable.strings`, refresh strings in
  `<language>.lproj/CYLRefresh.strings`. Do not add another `.bundle`, loose
  `.strings` files, or hard-coded user-facing text. Every language must have
  every key of `en`. See "Localization" in `instructions.md`.
- Ready-made placeholder animations live in
  `CYLTableViewPlaceHolder.bundle/Animations/`, named `CYLPlaceholder<Scenario>.<ext>`.
  Add only files with a redistributable license, unmodified, and record each
  one's source repository, commit, path, license and SHA-256 in
  `Animations/NOTICE.animations`, shipping the license text next to it.
  Keep the total small: every app that uses Core carries these files.
- Run `ruby Tests/run-tests.rb` for relevant simulator tests. Use `DESTINATION`
  to select an installed simulator. Build the example and validate the
  podspec when their integration changes; see `cyl-verify`.
- Xcode 27's simulator SDK requires a deployment target of at least 15.0 during
  builds. Override the build target for that toolchain instead of changing the
  library's iOS 12.0 minimum.
- Every CI run that builds code must provide a screenshot of each example
  running (artifacts `example-screenshot-*` from the `Demo` jobs). Link them
  when reporting CI results. If none can be produced, first fix the CI to
  produce it; if that still fails, state the concrete reason. See "CI example
  screenshots" in `instructions.md`.
- Update relevant documentation and skills with user-visible changes. Explain
  what could not be verified; do not claim a visual behavior from compilation.

## Commit readiness

- **Before every Commitizen-style (`git cz`) commit**, run this first in the repository root, so the vault's auto sync does not commit or push in the middle of it:

  ```sh
  mkdir -p .git/hooks && touch .git/hooks/NO_AUTO_SYNC
  ```

  If `.git/hooks` does not exist, `mkdir -p` creates it first so `touch`
  always succeeds.

- Before a Commitizen-style commit, follow the commit-message hook instructions
  in `instructions.md`; inspect an existing hook before replacing it.
- Before every commit, audit the changed code and the project's comparison,
  issue-progress, and implementation-status documents.
- In the most relevant existing document under `docs/`, keep a `TODO` entry for
  every tracked item below 100% complete and verified. Include its current
  score, concrete remaining work, implementation and verification notes, and
  any known defects or optimization opportunities.
- Review API design explicitly: record compatibility and migration risks,
  ambiguous or inconsistent keys, unsupported behavior, and lifecycle or
  accessibility gaps. Reserved keys, stubs, compilation, and unverified visual
  behavior do not qualify as completion.
- Update scores only when supported by implementation and test evidence. Before
  staging, verify that each sub-100 item in the relevant score tables has a
  matching `TODO` entry and that the documented limitations match the code.
- Use an English Conventional Commit subject compatible with Commitizen. The
  subject summarizes completed work; put details and pending work in the body.
  If the detailed description exceeds 50 characters, create or update a
  suitable document under `docs/` and link it in the commit body. Reuse the
  existing tracker and avoid duplicate documents.
- Follow the Commitizen defaults: `{type}{scope}: {emoji}{subject}`, emojis
  enabled, no predefined scopes, and a 3–64 character message. The interactive
 examples separate the emoji from the subject with a space. The
  type list is `test`, `feat`, `fix`, `chore`, `docs`, `refactor`, `style`,
  `ci`, `perf`; `release` is defined but not listed. Default emojis are
  `chore` 🤖, `ci` 🎡, `docs` ✏️, `feat` 🎸, `fix` 🐛, `perf` ⚡️,
  `refactor` 💡, `style` 💄, `test` 💍, and `release` 🏹. Follow established
  project emoji mappings where they differ (e.g. CYLTabBarController uses
  `feat: ✨`, `docs: 📝`, `chore: 🔧`, and `refactor: ♻️`). The question
  sequence is `type`, `scope`, `subject`, `body`, `breaking`, `issues`, and
  `lerna`;
  prompts cover optional scope, imperative subject, longer description,
  breaking changes, issue references, and affected packages.

## Git

- Never commit AppleDouble files named `._*`. Follow the vault's cleanup rule
  before Git commands and check staged paths before committing.
- Do not overwrite another person's changes or rewrite pushed history.
- On any branch other than `master` or `main`, commit and push as soon as the
  work is written, without asking the user first. Still follow the commit
  readiness rules above. On `master` or `main`, do not commit or push unless
  the user asks.
- Commit through a branch and a pull request by default, so CI runs
  (`docs/CI-CD.md`): branch from `master`, `mkdir -p .git/hooks && touch .git/hooks/NO_AUTO_SYNC`,
  commit, push the branch, and open a pull request against `master`. Do not
  commit directly to `master` unless the user asks. Do not merge a pull request
  without the user's approval, and not before the `iOS` workflow is green.
- Follow the current task's instructions for commits, branches, and pull
  requests when they differ from the default above.
