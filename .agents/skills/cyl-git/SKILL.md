---
name: cyl-git
description: Use before any git operation in this repository (commit, push, pull, branch, merge, rebase, tag, pull request) - read docs/instructions/git.md in full first, then follow it.
---

# Git operations in CYLTableViewPlaceHolder

1. **Read [docs/instructions/git.md](../../../docs/instructions/git.md) in full** before every git operation (owner's rule,
   2026-11-22): commit, push, pull, branch, merge, rebase, tag, cherry-pick, or a pull request. Do not rely on the
   one-line summaries in `AGENTS.md` / `instructions.md`.
2. Then run the git command following that file: among others, `touch .git/NO_AUTO_SYNC && mkdir -p .git/hooks &&
   touch .git/hooks/NO_AUTO_SYNC` before a commit, an English `git cz` message ending with the owner's
   `By @ChenYilong <luohanchenyilong@163.com>` line, an open pull request for the branch, and commit and push at the end of
   every turn on a non-default branch.
3. The rule's place: tag `git` in `AGENTS.md` and `instructions.md` (instruction files by tag: `docs/instructions/docs.md`).
