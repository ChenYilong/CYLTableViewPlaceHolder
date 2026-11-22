# Git and commits (`git`)

Full text of the `git` rules (commit readiness, Commitizen, branches and pull requests), moved verbatim from `instructions.md` and `AGENTS.md` on 2026-11-22 (owner's
rule: instruction files by tag, at most 200 lines each). Summaries: [instructions.md](../../instructions.md) and
[AGENTS.md](../../AGENTS.md), heading "Tag: Git and commits". English only.

## Read this file in full before any git operation

Owner's rule (2026-11-22): before any git operation (commit, push, pull, fetch-and-merge, branch, merge, rebase, tag,
cherry-pick, opening or updating a pull request), read this whole file first, every time, and only then run the git
command. A summary line in `AGENTS.md` or `instructions.md` is not enough.

## Commit readiness and TODO tracking

### `.gitignore` before every commit

Before every commit, update `.gitignore`:

1. Compare it with CYLTabBarController's `.gitignore`
   (https://github.com/ChenYilong/CYLTabBarController/blob/master/.gitignore).
   Add every ignored file and folder pattern it has that this file lacks, in
   the section "Synced from CYLTabBarController's .gitignore". Change only
   what does not match this project: replace `CYLTabBarController` with
   `CYLTableViewPlaceHolder` in paths. Leave out paths that exist only in
   CYLTabBarController (its example folders) and say so in the section's
   comment.
2. Run `git status --short` and `git ls-files -o --exclude-standard`. Every
   generated or machine-local file the change produced (build products,
   `Pods/`, user data, caches, `._*`) must be ignored; add a pattern for any that
   is not.
3. `.gitignore` does not untrack committed files. The `Podfile.lock` files and
   workspaces already in the repository stay tracked although `*.lock` and
   `*.xcworkspace` are ignored; do not remove them from the index without the
   user's approval. Use `git add -f` only for a file that must be committed
   despite a rule, and say why in the commit body.

Before every commit, review the current changes and all project comparison,
parity, issue-progress, and implementation-status documents. For every item
that is not fully complete and verified at 100%, ensure a corresponding entry
exists under a `TODO` heading in the most relevant document under `docs/`.
Use an existing relevant document when possible; do not create duplicate
tracking documents.

Each `TODO` entry must identify the incomplete behavior and current score,
describe the remaining work and implementation constraints, and state how it
will be verified. Explicitly document known defects, compatibility risks, and
optimization opportunities. Review public and serialized API design in
particular: identify missing behaviors, inconsistent keys, ambiguous values,
unsupported backends, lifecycle or accessibility gaps, and migration concerns.
Do not treat reserved keys, stubs, successful compilation, or unverified visual
behavior as complete.

After addressing an item, update its status and score from code and test
evidence. Keep every remaining sub-100 item listed with the literal keyword
`TODO`; do not remove a limitation merely because it was attempted. Before
staging, confirm that the documentation covers every sub-100 row in the
relevant score tables and that the descriptions match the current code.

Use an English Conventional Commit subject compatible with Commitizen. The
subject summarizes completed work; use the body for details and pending tasks.
If the detailed description exceeds 50 characters, create or update a suitable
document under `docs/` and link it in the commit body. Reuse the relevant
existing tracker and avoid duplicate documents.

### Commitizen defaults

- Use `{type}{scope}: {emoji}{subject}` with emojis enabled. Omit an unnecessary
  scope; no scopes are preconfigured. The configured message length is 3–64
  characters. In readable subjects, separate the emoji and subject with a
  space as shown in the project examples below.
- The interactive type choices, in order, are `test`, `feat`, `fix`, `chore`,
  `docs`, `refactor`, `style`, `ci`, and `perf`. `release` has a type definition
  but is not an interactive choice; use it only for an intentional release.
- Default meanings and emojis: `chore` (build or auxiliary-tool changes, 🤖),
  `ci` (CI changes, 🎡), `docs` (documentation only, ✏️), `feat` (new feature,
  🎸), `fix` (bug fix, 🐛), `perf` (performance improvement, ⚡️), `refactor`
  (neither a feature nor a fix, 💡), `style` (markup or formatting only, 💄),
  `test` (adding missing tests, 💍), and `release` (release commit, 🏹).
- The question sequence is `type`, `scope`, `subject`, `body`, `breaking`,
  `issues`, and `lerna`. Prompts request the type, optional scope, short
  imperative subject, longer description, breaking changes, issues closed
  (for example `#123`), and affected packages.
- Respect established repository history when it uses project-specific
  mappings. CYLTabBarController examples include `feat: ✨`, `fix: 🐛`,
  `docs: 📝`, `chore: 🔧`, and `refactor: ♻️`. Commit text must remain English.

### Author line in every commit message

Every commit message carries the owner's line, exactly:

```text
By @ChenYilong <luohanchenyilong@163.com>
```

- Put it on its own line at the end of the body, after the details and before any trailers (such as
  `Co-Authored-By:` or `Claude-Session:`), separated from the body by a blank line.
- It applies to every commit in this repository, whoever or whatever writes it (people, Commitizen,
  agents), on every branch, including fixups and merge commits you author.
- Do not change its spelling, the handle or the address, and do not add it twice. The commit-msg hook
  below appends it when it is missing.

### Commit-message hook before Commitizen commits

Before a Commitizen-style commit, run the following from the repository root:

```sh
mkdir -p .git/hooks
cat > .git/hooks/commit-msg << 'HOOKEOF'
#!/bin/sh
tmpfile="$1"
if grep -qi "Co-Authored-By:" "$tmpfile" 2>/dev/null; then
  tmp_clean=$(mktemp)
  grep -vi "Co-Authored-By:" "$tmpfile" > "$tmp_clean"
  cat "$tmp_clean" > "$tmpfile"
  rm -f "$tmp_clean"
fi
# The owner's author line ("Author line in every commit message"), added once when missing: before the
# trailer block (Co-Authored-By:, Claude-Session:, ...) so Git still reads the trailers, else at the end.
author_line='By @ChenYilong <luohanchenyilong@163.com>'
if ! grep -qxF "$author_line" "$tmpfile" 2>/dev/null; then
  tmp_author=$(mktemp)
  awk -v line="$author_line" '
    { lines[NR] = $0 }
    END {
      n = NR
      while (n > 0 && lines[n] ~ /^[[:space:]]*$/) n--
      start = n
      while (start > 0 && lines[start] ~ /^[A-Za-z][A-Za-z0-9-]*: /) start--
      if (start < n && start > 1 && lines[start] ~ /^[[:space:]]*$/) {
        for (i = 1; i <= start; i++) print lines[i]
        print line; print ""
        for (i = start + 1; i <= n; i++) print lines[i]
      } else {
        for (i = 1; i <= n; i++) print lines[i]
        print ""; print line
      }
    }' "$tmpfile" > "$tmp_author" && cat "$tmp_author" > "$tmpfile"
  rm -f "$tmp_author"
fi
HOOKEOF
chmod +x .git/hooks/commit-msg
```

`mkdir -p` creates `.git/hooks` when it is missing, so writing the hook
always succeeds. This overwrites the existing `commit-msg` hook and removes every line containing
`Co-Authored-By:`, case-insensitively, including other authors' attribution, and appends the author line
`By @ChenYilong <luohanchenyilong@163.com>` when the message does not contain it yet. Without the hook
(for example a commit written with `git commit -F`), add the line yourself.
Inspect any existing hook before replacing it. The command assumes `.git` is
a directory and Git uses its default hooks path; linked worktrees and custom
`core.hooksPath` require the appropriate hooks path instead.

## Commitizen commits

Before every Commitizen-style (`git cz`) commit, run this first in the repository root:

```sh
touch .git/NO_AUTO_SYNC && mkdir -p .git/hooks && touch .git/hooks/NO_AUTO_SYNC
```

The vault's auto sync (`.claude/hooks/git_sync.py` in the vault root) checks `.git/NO_AUTO_SYNC`, not `.git/hooks/NO_AUTO_SYNC`: the hooks path never paused it (verified 2026-11-12). Both files are kept so either reading works; delete them to turn the sync back on. If the hooks directory does not exist (for example in a fresh clone or a container without sample hooks),
`mkdir -p` creates it first so `touch` always succeeds.

### git cz style, English only (owner's rule, 2026-11-16)

- **Every commit is a `git cz` (Commitizen) style commit**: `{type}{scope}: {emoji} {subject}` with the Commitizen
  default types and emojis listed in "Commitizen defaults" (`feat` 🎸, `fix` 🐛, `docs` ✏️, `test` 💍, `ci` 🎡,
  `chore` 🤖, `refactor` 💡, `style` 💄, `perf` ⚡️), whether it is written with `git cz` or by hand.
- **The whole commit message is in English: no Chinese characters anywhere**, not in the subject, the body, the
  scope or a quoted file name or prompt. Describe a Chinese text or prompt in English (or point to the `docs/` entry
  that quotes it) instead of pasting it. This applies to merge commits, cherry-picks and amended messages too.
- Check before committing: `git log -1 --format=%B | LC_ALL=C.UTF-8 grep -nP '[\x{4e00}-\x{9fff}\x{3000}-\x{303f}\x{ff00}-\x{ffef}]'`
  must print nothing.

## Committing on branches

On any branch other than `master` or `main`, commit and push as soon as the
work is written, without asking for confirmation. Follow the commit readiness
and Commitizen rules above. On `master` or `main`, commit or push only when the
user asks; otherwise create a branch and open a pull request (`docs/CI-CD.md`).

### A pull request for every new branch

- Every time you create a branch, open a pull request for it right away, without asking: push the branch and run
  `gh pr create` in the same step. Do not wait for the work to be finished; a draft-quality pull request is fine and
  later commits update it.
- Target branch: the branch the new branch was created from (its source branch) comes first. Use `main` or `master`
  only when the source branch is `main` or `master` itself, or when the source branch no longer exists on the remote.
  Pass it explicitly (`gh pr create --base <source branch>`); never rely on the repository's default.
- Write the source branch into the pull request description, so a reviewer knows where it will merge.
- Still do not merge the pull request without the user's approval.
- **Every branch with commits has an open pull request (added 2026-11-16).** After creating a branch, any commit on it
  must be in a pull request. Never create a branch and keep committing to it without one: commits on a branch with no
  pull request are ignored, because nothing ever merges them.
  - **Before every commit**, check that the current branch has an open pull request
    (`gh pr list --state open --head <branch>`). If it has none (never opened, closed or merged), open a new one right
    after pushing (`gh pr create --base <target> --head <branch>`).
  - **Target branch**: the branch of the pull request that was active (open) before this one was created; only when
    there is none, `master` (or `main`).
  - **More than two open pull requests: ask first.** When the repository already has more than two open pull requests,
    do not open another one on your own: ask the owner whether to create a new branch and pull request or to keep
    committing on the current branch. More than two open branches make merging hard and leave no sensible target for
    each branch.
  - Push only to branches that have an open pull request; do not recreate a branch that was deleted after its pull
    request was closed or merged.
  - **Commit and push at the end of every turn (added 2026-11-16).** When a question-and-answer turn ends and the current
    branch is not `master` or `main`, commit and push the work right away, without asking. The code is always on a
    branch and never pushed to `master` or `main`, so this is safe; there is no risk to weigh after the push.

## AGENTS.md: Commit readiness

- **Before every Commitizen-style (`git cz`) commit**, run this first in the repository root, so the vault's auto sync does not commit or push in the middle of it:

  ```sh
  touch .git/NO_AUTO_SYNC && mkdir -p .git/hooks && touch .git/hooks/NO_AUTO_SYNC
  ```

  The vault's `git_sync.py` checks `.git/NO_AUTO_SYNC`; the hooks path alone never paused it.

  If `.git/hooks` does not exist, `mkdir -p` creates it first so `touch`
  always succeeds.

- Before every commit, update `.gitignore`: add any ignore pattern from
  CYLTabBarController's `.gitignore` that is missing (changing only its project
  name to `CYLTableViewPlaceHolder`), and make sure every generated or
  machine-local file of the change is ignored. Already tracked files stay
  tracked. See "`.gitignore` before every commit" in `instructions.md`.

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

- Every commit message must contain the owner's line `By @ChenYilong <luohanchenyilong@163.com>`, on
  its own line at the end of the body (before trailers such as `Co-Authored-By:`), exactly once. See
  "Author line in every commit message" in `instructions.md`; the commit-msg hook there appends it.

- Use an English Conventional Commit subject compatible with Commitizen. The
  subject summarizes completed work; put details and pending work in the body.
  If the detailed description exceeds 50 characters, create or update a
  suitable document under `docs/` and link it in the commit body. Reuse the
  existing tracker and avoid duplicate documents.

- **git cz style, English only:** every commit uses the `git cz` (Commitizen) format with its default types and
  emojis, and the whole message (subject, body, scope, merge and cherry-pick messages) is English with no Chinese
  characters. See "git cz style, English only" in `instructions.md`.

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

## AGENTS.md: Git

- Never commit AppleDouble files named `._*`. Follow the vault's cleanup rule
  before Git commands and check staged paths before committing.

- Do not overwrite another person's changes or rewrite pushed history.

- On any branch other than `master` or `main`, commit and push as soon as the
  work is written, without asking the user first. Still follow the commit
  readiness rules above. On `master` or `main`, do not commit or push unless
  the user asks.

- Every time you create a branch, open a pull request for it right away, without
  asking (`instructions.md`, "A pull request for every new branch"). The base is
  the branch it was created from, first; `main` or `master` only when that is the
  source branch or the source branch is gone. Pass `--base` explicitly.

- Commit through a branch and a pull request by default, so CI runs
  (`docs/CI-CD.md`): branch from `master`, `touch .git/NO_AUTO_SYNC` (the path the vault's auto sync checks),
  commit, push the branch, and open a pull request against its source branch (here `master`). Do not
  commit directly to `master` unless the user asks. Do not merge a pull request
  without the user's approval, and not before the `iOS` workflow is green.

- Follow the current task's instructions for commits, branches, and pull
  requests when they differ from the default above.

- **Every branch with commits has an open pull request (added 2026-11-16).** After creating a branch, any commit on it
  must be in a pull request. Never create a branch and keep committing to it without one: commits on a branch with no
  pull request are ignored, because nothing ever merges them.
  - **Before every commit**, check that the current branch has an open pull request
    (`gh pr list --state open --head <branch>`). If it has none (never opened, closed or merged), open a new one right
    after pushing (`gh pr create --base <target> --head <branch>`).
  - **Target branch**: the branch of the pull request that was active (open) before this one was created; only when
    there is none, `master` (or `main`).
  - **More than two open pull requests: ask first.** When the repository already has more than two open pull requests,
    do not open another one on your own: ask the owner whether to create a new branch and pull request or to keep
    committing on the current branch. More than two open branches make merging hard and leave no sensible target for
    each branch.
  - Push only to branches that have an open pull request; do not recreate a branch that was deleted after its pull
    request was closed or merged.
  - **Commit and push at the end of every turn (added 2026-11-16).** When a question-and-answer turn ends and the current
    branch is not `master` or `main`, commit and push the work right away, without asking. The code is always on a
    branch and never pushed to `master` or `main`, so this is safe; there is no risk to weigh after the push.
