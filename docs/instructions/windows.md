# Windows scenario (`windows`)

Full text of the `windows` rules (what Windows sessions (Android, HarmonyOS, mini program) read first), moved verbatim from `instructions.md` and `AGENTS.md` on 2026-11-22 (owner's
rule: instruction files by tag, at most 200 lines each). Summaries: [instructions.md](../../instructions.md) and
[AGENTS.md](../../AGENTS.md), heading "Tag: Windows scenario". English only.

## Windows: where to read

The Windows scenario collects pointers: [HarmonyOS](harmonyos.md), [Testing](testing.md) (shared emulators, screenshots), [Session roles](workflow.md#session-roles-mac-sessions-for-ios-win-sessions-for-the-other-platforms-added-2026-11-19). On Windows, Git Bash runs the scripts; `adb` device paths need `MSYS_NO_PATHCONV=1`; Windows `hdc` reads a forward-slash `C:/...` path as relative, so pass native backslash paths; PowerShell 5.1 scripts with non-ASCII text are saved as UTF-8 with a BOM.
