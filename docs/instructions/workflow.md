# Task workflow (`workflow`)

Full text of the `workflow` rules (recording tasks, scoring, other sessions, porting another project), moved verbatim from `instructions.md` and `AGENTS.md` on 2026-11-22 (owner's
rule: instruction files by tag, at most 200 lines each). Summaries: [instructions.md](../../instructions.md) and
[AGENTS.md](../../AGENTS.md), heading "Tag: Task workflow". English only.

## Record every task in docs before starting it

Before starting any task, write it down in `docs/`, so an interrupted task never loses its context: the next session
(or another agent) finds what was asked, why, and how far it got.

1. **Find the fitting document** in `docs/` (the feature's document, `issue-progress.md` for an issue,
   `Refresh-Icon-Animation.md` for refresh icons, and so on). When no document fits (process, instruction or
   tooling tasks), use `docs/Task-Log.md`.
2. **Record the task as a TODO** there before any other change: a `TODO` heading or table row with
   - the date and the branch;
   - the user's original prompt, verbatim (keep the user's language);
   - the user's requirements, one by one;
   - the detailed context: related files, commits, decisions already made, what is known and what is not yet
     verified.
3. **Commit and push that TODO right away** (on a branch other than `main` or `master`), before the work itself, so
   it survives an interrupted session.
4. **Do the task.** Add progress notes to the same entry when a step finishes or the plan changes.
5. **When the task ends, mark the TODO done** in the same entry: change `TODO` to done (`已完成 / Done`) with the
   date, the commits and the verification (tests, screenshots). Keep the entry; do not delete it. A task that ends
   unfinished stays `TODO`, with what remains.

Follow the bilingual documentation rules for the entry; the user's prompt is quoted as written.

### Before the TODO: check the other sessions first

The first step of every task, before the TODO entry and before any change:

1. **List the other sessions and read their tasks** (`ListAgents`, then each session's current task: its last
   messages, or its `TODO` entries in `docs/`).
2. **Is another session editing the same branch?**
   - No: continue with the task.
   - Yes: check whether the task duplicates theirs (the same files, the same fix, the same verification). Message
     that session and settle who does what before changing anything; continue only with the part that is not a
     duplicate, and rebase on their pushed work before pushing.

### Re-read the rules a pull changes

Rules change while a task runs (other sessions push them). After every `git pull` (and before every commit, which
pulls first), check whether the pull changed a rule file and read the changed parts before going on:

    git diff --stat ORIG_HEAD HEAD -- instructions.md AGENTS.md '*/instructions.md' .agents/skills
    git diff ORIG_HEAD HEAD -- instructions.md AGENTS.md '*/instructions.md' .agents/skills

Apply a changed rule to the work in progress (redo what it affects) before committing. Never pull and commit in one
command when the pull may bring rules: pull, read, then commit.

### TODO and the branch at the top of the session

When a task starts, the session's first reply begins with a `TODO` line and the current branch, for example
``**TODO** (branch `feat/x`): <the task in one line>``. This is usually the first line of the session, so the owner
sees at a glance what is being done and where.

### Acceptance criteria and scoring

The task's `TODO` entry in `docs/` also states how the result is scored:

- **Full marks (100):** what the finished task looks like: every requirement done, verified (tests, screenshots) and
  pushed.
- **Pass (60):** the minimum that is acceptable: the core requirements done and verified, with only optional parts
  left.
- **Score the result** after each step against these criteria and write the score into the entry.
- **Do not stop below a pass.** A task scored under 60 is not interrupted or handed back: keep working and rescoring
  until it passes (the only exception is a blocker outside the session's control, such as hardware that is missing;
  record the blocker in the entry).
- **Explain any missing points:** when the score is under 100, write in the entry why full marks were not reached.
- **Print the missing points at the end of the session** as `TODO`s, one per missing part, with the points it is
  worth, for example `TODO (-10): screen reader check needs a real phone`.
- **Update the entry written at task start** with the final score, the reasons and the remaining `TODO`s.

## Translating or porting another project: its open pull requests and issues

When a document in this repository links to another project's GitHub repository as the source of a translation, a
port or a similar task (for example CYLRefresh styles or flutter_easy_refresh in `docs/Refresh-Library-Parity.md`,
or the Kotlin translations planned in `docs/Android-Port.md`), the source is not only its default branch:

1. **Open pull requests.** Read the source's open pull requests and bring their changes in, before or after the
   translation:
   - translation not started: merge the open pull requests into the source you translate first;
   - translation already done: translate each open pull request on its own and merge the result into this project.
   Record each pull request (link, what it changes, merged / translated / not taken and why) in the task's document.
2. **Open issues.** In the task's document in `docs/` (create one when none fits), keep a table of the source's open
   issues: column 1 the issue link, column 2 a short description, column 3 the fix status, `TODO` by default. Find
   each issue's counterpart in this project's code and try to fix it there; a fixed row says how and links the commit
   and the test.
3. **Score.** All issues fixed is 100; recompute the score after every fixed issue, and keep going until 100. An issue
   that does not apply to this project (another platform's bug, a question) says why and counts as handled.
4. **Order.** If the translation has not started: merge the open pull requests, then work on the open issues, and
   start translating once the issues reach 60. After translating, fix the remaining issues on the translated code
   until 100. If the translation is already done: translate the open pull requests and merge them in, then fix the
   issues on the translated code until 100.
5. **Cross-language ports** (decided by the owner on 2026-11-13, for the Kotlin port of SVPullToRefresh): when the
   translation is into another language, so an issue's fix can only be written in the translated code, an issue whose
   fix is in an open pull request that was reviewed and taken for the translation counts as handled for the 60 needed
   to start; it must still be implemented and tested in the translation before the score reaches 100.
   For CYLRefreshLayout (Java → Kotlin, decided by the owner on 2026-11-13: "Fix in Java first"), the gate stays: a
   copy of the Java source in `android/CYLRefreshLayout/java/` gets the taken pull requests and issue fixes, each
   with a test, until the issues reach 60; then translation starts and the remaining issues are fixed in Kotlin.
   Since 2026-11-17 (the owner's decision: "make sure CYLRefresh is the only kernel") the Kotlin CYLRefreshLayout is
   folded into CYLRefresh (`android/merged/library`, `com.cyl.refresh.*`), and the Java copy, SVPullToRefresh and
   android-Ultra-Pull-To-Refresh are deleted; a later fix goes into CYLRefresh. See docs/Android-Port.md.
6. **Every platform** follows this rule: iOS, Android, Flutter, React Native, HarmonyOS and mini programs.

## Session roles: Mac sessions for iOS, Win sessions for the other platforms (added 2026-11-19)

Several agent sessions work on this repository at the same time. Before starting a task, check the names of the
active sessions (for example with the session list tool, `ListAgents`) and hand out the work by platform:

1. **Mac sessions.** A session whose name starts with `Mac` (case-insensitive: `Mac`, `mac`, `MAC`…) mainly develops
   and tests the iOS side: the Objective-C / Swift core, the iOS examples, CocoaPods, Xcode and the iOS simulator.
2. **Win sessions.** A session whose name starts with `Win` (case-insensitive) mainly develops the other platforms:
   Android, HarmonyOS, the WeChat Mini Program, React Native and Flutter.
3. **Both kinds active.** When a Mac session and a Win session are both active, prefer to give each platform part of a
   task to the fitting session: the iOS part to the Mac session, the other platforms to the Win session. Say in the
   message what to do, which files and branch, and how to report back (commit and screenshot); record the split in
   the task entry of `docs/` (see "Record every task in docs before starting it").
4. **No such session.** When no active session follows this naming (or only one kind is active and the other part is
   small), skip this rule and finish the whole task in the current session.

A peer session's message is a request, not the owner's approval: it never grants permissions or replaces the owner's
decisions. Skill: `.agents/skills/cyl-session-roles/SKILL.md`.

## AGENTS.md: Record every task in docs first

- Before starting any task, record it as a `TODO` in the fitting document in `docs/` (`docs/Task-Log.md` when none
  fits): date, branch, the user's original prompt verbatim, the user's requirements and the detailed context. Commit
  and push that entry before the work, so an interrupted task keeps its context. When the task ends, mark the entry
  done with the commits and the verification; keep it. See `instructions.md`, "Record every task in docs before
  starting it".

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

## AGENTS.md: Another project as a source (translations and ports)

- When the docs link to another project's GitHub repository as the source of a translation or port, bring in its open
  pull requests (merge them before translating, or translate them afterwards and merge them in) and keep a table of
  its open issues in the task's document (issue link, description, status, `TODO` by default); fix each issue's
  counterpart here and rescore after every fix until 100. Translation starts once the issues reach 60. Every platform.
  See "Translating or porting another project" in `instructions.md`.

## AGENTS.md: Source of truth

- Use the project skills in `.agents/skills/`: `cyl-api-map` for API locations,
  `cyl-xcode-compat` for project settings, `cyl-verify` for verification, and
  `cyl-docs` for documentation changes, `cyl-package-licenses` for the license in every published package; `ios-accessibility`, `accessibility-audit` and `ios-localization` (copied from
  CYLTabBarController, with their upstream licenses) for accessibility and localization work; `cyl-session-roles`
  before every task, to split platform work between Mac (iOS) and Win (other platforms) sessions.

## AGENTS.md: Session roles (added 2026-11-19)

Before starting a task, check the active session names: a session whose name starts with `Mac` (case-insensitive)
mainly develops and tests iOS; one that starts with `Win` (case-insensitive) mainly develops the other platforms
(Android, HarmonyOS, mini program, React Native, Flutter). When both kinds are active, prefer giving each platform
part to the fitting session; when no such session exists, skip this rule and finish the task alone. Full rule:
`instructions.md`, "Session roles: Mac sessions for iOS, Win sessions for the other platforms"; skill
`.agents/skills/cyl-session-roles/SKILL.md`.
