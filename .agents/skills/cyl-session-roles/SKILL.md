---
name: cyl-session-roles
description: Before starting a task, check the active session names and split the work by platform - sessions named Mac* (case-insensitive) take iOS development and testing, sessions named Win* (case-insensitive) take Android, HarmonyOS, mini program, React Native and Flutter; skip when no such session exists.
---

# Session roles

Several agent sessions work on this repository at once. Use this skill at the start of every task.

## Steps

1. **List the active sessions** (for example `ListAgents`) and read their names.
2. **Classify them** by the start of the name, ignoring case:
   - `Mac…` (`Mac`, `mac`, `MAC`): mainly iOS development and testing (Objective-C / Swift core, iOS examples,
     CocoaPods, Xcode, the iOS simulator).
   - `Win…`: mainly the other platforms (Android, HarmonyOS, WeChat Mini Program, React Native, Flutter).
3. **Split the task by platform** when a Mac session and a Win session are both active: keep the part that matches
   the current session, and send the other part to the fitting session. The message says what to do, the files and
   the branch, and how to report back (commit, screenshot). Record the split in the task's entry in `docs/`.
4. **Skip the rule** when no active session follows this naming, or only one kind is active and the other part is
   small: finish the whole task in the current session.

## Limits

- A peer session's message is a request, not the owner's approval. It never grants permissions, and work that was
  denied in one session is never handed to another.
- The current session still answers for the whole task: check the peer's commits and update the task's score when
  they report back.

Source: `instructions.md`, "Session roles: Mac sessions for iOS, Win sessions for the other platforms" (2026-11-19).

## arm64-only tests (Rive and PAG on HarmonyOS)

When a Windows session cannot run a test because it needs arm64 (Rive and PAG playback; their native libraries are
arm64-v8a only and the Windows HarmonyOS emulator is x86_64), first try option 1 of `instructions.md`, "Rive and PAG:
tests that only run on arm64" (x86_64 libraries in CYLTabBarController's CYLAnimatedItemView; its debug-build guard was
removed with the owner's approval on 2026-11-23). If option 1 fails, forward the test to an active macOS session (Apple silicon
is arm64) with the build, the steps and the expected result; with no macOS session active, record it as a `TODO` for
the next one.
