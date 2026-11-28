# iTerm2 标签页显示会话名与文件夹名 / iTerm2 tab shows the session and folder name

<!-- bound-classes: none -->

<!-- docs-navigation:start -->

| 中文 | English |
| --- | --- |
| [效果](#效果--result) | [Result](#效果--result) |
| [已安装的配置（2026-11-22）](#已安装的配置2026-11-22--what-is-installed-2026-11-22) | [What is installed (2026-11-22)](#已安装的配置2026-11-22--what-is-installed-2026-11-22) |
| [你需要做的](#你需要做的--what-you-do) | [What you do](#你需要做的--what-you-do) |
| [检查与排错](#检查与排错--check-and-troubleshoot) | [Check and troubleshoot](#检查与排错--check-and-troubleshoot) |
| [来源与状态](#来源与状态--sources-and-status) | [Sources and status](#来源与状态--sources-and-status) |

<!-- docs-navigation:end -->

<!-- docs-binding:start -->

| 类 / Class | 头文件 / Header |
| --- | --- |
| 无 / none | — |

<!-- docs-binding:end -->

## 效果 / Result

| 中文 | English |
| --- | --- |
| 每个 Claude Code 会话的 iTerm2 标签页和窗口标题显示 `<会话名> · <文件夹名>`；没有会话名时只显示 `<文件夹名>`，例如在 vault 根目录启动的会话显示 `chenyilong`，在 `/tmp/xpr/cyltvph-ios` 启动的会话显示 `cyltvph-ios`。标题在会话开始、每次发送消息、每次回复结束时重写，因此不会被其他程序长期覆盖。 | The iTerm2 tab and window title of every Claude Code session shows `<session name> · <folder name>`, or only `<folder name>` when there is no session name: a session started in the vault root shows `chenyilong`, one started in `/tmp/xpr/cyltvph-ios` shows `cyltvph-ios`. The title is written again when the session starts, on every message you send and at the end of every reply, so nothing else keeps it overwritten for long. |

## 已安装的配置（2026-11-22） / What is installed (2026-11-22)

| 中文 | English |
| --- | --- |
| 1. 钩子脚本 `~/.claude/hooks/iterm-session-title.sh`：读取钩子输入中的 `cwd`，取文件夹名；会话名取环境变量 `CLAUDE_TAB_TITLE`，或钩子输入中的 `session_name` / `session_title`（若 Claude Code 提供）；输出 `{"terminalSequence": "ESC]0;标题BEL"}`，由 Claude Code 写出 OSC 0 标题序列（钩子本身无法写 `/dev/tty`）。 | 1. The hook script `~/.claude/hooks/iterm-session-title.sh`: it reads `cwd` from the hook input and takes the folder name; the session name comes from the `CLAUDE_TAB_TITLE` environment variable, or from `session_name` / `session_title` in the hook input when Claude Code provides one; it prints `{"terminalSequence": "ESC]0;title BEL"}`, and Claude Code writes the OSC 0 title sequence (a hook cannot write to `/dev/tty` itself). |
| 2. `~/.claude/settings.json` 的 `hooks` 中，`SessionStart`、`UserPromptSubmit`、`Stop` 各增加一项调用该脚本，保留原有的 iTerm2 `cc-status` 钩子。 | 2. In `~/.claude/settings.json`, `hooks`: `SessionStart`, `UserPromptSubmit` and `Stop` each gained an entry that runs the script; the existing iTerm2 `cc-status` hooks stay. |
| 3. `~/.claude/settings.json` 的 `env` 中增加 `"CLAUDE_CODE_DISABLE_TERMINAL_TITLE": "1"`：关闭 Claude Code 按对话主题自动改写标题，否则它会覆盖文件夹名。代价（官方文档 env-vars）：不再在后台生成会话标题（`/resume` 列表中未命名的会话没有自动标题），也不再向终端发送状态报告；iTerm2 自己的 `cc-status` 钩子不受影响。 | 3. In `~/.claude/settings.json`, `env`: `"CLAUDE_CODE_DISABLE_TERMINAL_TITLE": "1"`, which stops Claude Code from rewriting the title from the conversation topic; otherwise it overwrites the folder name. The cost (official env-vars docs): no generated session title in the background (unnamed sessions get no automatic title in the `/resume` list), and no status reports to the terminal; iTerm2's own `cc-status` hooks are not affected. |
| 这些是用户级配置，对所有文件夹的所有新会话都生效，不需要每个项目单独配置。 | These are user-level settings: they apply to every new session in every folder, with nothing to set up per project. |

## 你需要做的 / What you do

| 中文 | English |
| --- | --- |
| 1. 确认 iTerm2 允许程序改标题：Settings → Profiles → 选中你用的 Profile → General → Title，勾选 “Applications in terminal may change the title”（当前默认 Profile 已开启：`Allow Title Setting = 1`）。Title 下拉框保持包含 “Session Name”。 | 1. Make sure iTerm2 lets programs change the title: Settings → Profiles → your profile → General → Title, with "Applications in terminal may change the title" checked (already on in the current default profile: `Allow Title Setting = 1`). Keep "Session Name" in the Title menu. |
| 2. 新开一个 iTerm2 标签页，照常运行 `claude`。标签页显示文件夹名，无需其他操作。已在运行的会话在下一次发送消息或回复结束时更新。 | 2. Open a new iTerm2 tab and run `claude` as usual. The tab shows the folder name; nothing else to do. A session that is already running updates on your next message or at the end of the next reply. |
| 3. 想显示会话名时，用环境变量启动：`CLAUDE_TAB_TITLE=placeholder-issues claude`，标签页显示 `placeholder-issues · <文件夹名>`。`claude -n <名字>` 与 `/rename` 设置的名字目前没有在钩子输入中文档化，不保证出现在标签页上；需要固定名字时用 `CLAUDE_TAB_TITLE`。 | 3. To show a session name, start with the environment variable: `CLAUDE_TAB_TITLE=placeholder-issues claude`; the tab shows `placeholder-issues · <folder name>`. The name set by `claude -n <name>` or `/rename` is not documented as part of the hook input, so it may not reach the tab; use `CLAUDE_TAB_TITLE` for a fixed name. |
| 可选：在 `~/.zshrc` 中加一个函数，每次自动带上名字，例如 `cc() { CLAUDE_TAB_TITLE="$1" claude "${@:2}"; }`，然后用 `cc placeholder-issues` 启动。 | Optional: a function in `~/.zshrc` that always passes a name, for example `cc() { CLAUDE_TAB_TITLE="$1" claude "${@:2}"; }`, then start with `cc placeholder-issues`. |

## 检查与排错 / Check and troubleshoot

| 中文 | English |
| --- | --- |
| 脚本自测：`echo '{"cwd":"'$PWD'"}' \| ~/.claude/hooks/iterm-session-title.sh` 应输出 `{"terminalSequence":"\u001b]0;<文件夹名>\u0007"}`。 | Script self-test: `echo '{"cwd":"'$PWD'"}' \| ~/.claude/hooks/iterm-session-title.sh` prints `{"terminalSequence":"\u001b]0;<folder name>\u0007"}`. |
| 标题没变：在会话中运行 `/hooks` 确认三个事件下都有该脚本；确认脚本可执行（`chmod +x`）且 `jq` 在 `/usr/bin/jq`；确认 iTerm2 的 “Applications in terminal may change the title” 已勾选。`terminalSequence` 只在交互式会话中生效，`claude -p` 不会改标题。 | No title change: run `/hooks` in the session and check the script is listed under the three events; check the script is executable (`chmod +x`) and `jq` is at `/usr/bin/jq`; check iTerm2's "Applications in terminal may change the title". `terminalSequence` works only in interactive sessions; `claude -p` does not change the title. |
| 恢复 Claude Code 的主题标题：删除 `env` 中的 `CLAUDE_CODE_DISABLE_TERMINAL_TITLE`；完全撤销：再删除 `hooks` 中三处 `iterm-session-title.sh` 项。 | Get Claude Code's topic titles back: remove `CLAUDE_CODE_DISABLE_TERMINAL_TITLE` from `env`; undo everything: also remove the three `iterm-session-title.sh` entries from `hooks`. |

## 来源与状态 / Sources and status

| 中文 | English |
| --- | --- |
| 官方文档：hooks（`terminalSequence`，允许 OSC 0/1/2）https://code.claude.com/docs/en/hooks.md ；环境变量 https://code.claude.com/docs/en/env-vars.md ；会话名 https://code.claude.com/docs/en/sessions.md 。 | Official docs: hooks (`terminalSequence`, OSC 0/1/2 allowed) https://code.claude.com/docs/en/hooks.md ; environment variables https://code.claude.com/docs/en/env-vars.md ; session names https://code.claude.com/docs/en/sessions.md . |
| 评分 85 / 100。TODO（-10）：在新开的 iTerm2 标签页中目视确认标题（脚本输出已验证，iTerm2 中的显示待用户确认）。TODO（-5）：确认 `/rename` 的名字是否出现在钩子输入中，若有则无需 `CLAUDE_TAB_TITLE`。 | Score 85 / 100. TODO (-10): confirm the title by eye in a new iTerm2 tab (the script output is verified; the display in iTerm2 is for the user to confirm). TODO (-5): check whether the `/rename` name appears in the hook input; if it does, `CLAUDE_TAB_TITLE` is not needed. |
