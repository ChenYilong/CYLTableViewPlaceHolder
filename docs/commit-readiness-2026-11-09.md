# 提交就绪规则 / Commit readiness rules

<!-- bound-classes: none -->

<!-- docs-navigation:start -->

| 中文 | English |
| --- | --- |
| [摘要](#摘要--summary) | [Summary](#摘要--summary) |
| [已完成](#已完成--completed) | [Completed](#已完成--completed) |
| [待办](#待办--todo) | [TODO](#待办--todo) |

<!-- docs-navigation:end -->

<!-- docs-binding:start -->

| 类 / Class | 头文件 / Header |
| --- | --- |
| 无 / none | — |

<!-- docs-binding:end -->

## 摘要 / Summary

| 中文 | English |
| --- | --- |
| 在仓库的提交说明中加入了英文 Conventional Commit 与详细描述的要求，与已有的提交前 TODO 审查并列。 | Added English Conventional Commit and long-description requirements to the repository commit instructions, alongside the existing pre-commit TODO audit. |

## 已完成 / Completed

| 中文 | English |
| --- | --- |
| 要求每个低于 100 分的对齐项都有详细、以证据为依据的 TODO。 | Required detailed, evidence-based TODOs for every sub-100 parity item. |
| 在 `.gitignore` 中加入 `*.base`，用于本地 Obsidian 文件夹笔记元数据。 | Added `*.base` to `.gitignore` for local Obsidian folder-note metadata. |
| 写明 API 风险、已知缺陷、实现约束和验证步骤都必须明确列出。 | Documented that API risks, known defects, implementation constraints, and verification steps must be explicit. |
| 要求当详细提交描述超过 50 个字符时，链接一份 `docs/` 笔记。 | Required a linked `docs/` note when a detailed commit description exceeds 50 characters. |
| 未完成的对齐项及其当前分数保留在[对照跟踪表](flatdesign-item-comparison.md)中。 | Kept the outstanding parity items and their current scores in [the comparison tracker](flatdesign-item-comparison.md). |

## 待办 / TODO

| 中文 | English |
| --- | --- |
| 状态（2026-11-19，Windows 会话）：下面每个未完成项都是需要 macOS、Xcode、iOS 模拟器或 iOS 设备的 iOS 工作，因此按会话角色规则属于 Mac 会话；Windows 会话已于 2026-11-19 移交该清单。项目中 Android、HarmonyOS 和小程序部分分别在 `docs/Android-API-Map.md`（100）、`docs/HarmonyOS.md` 和 `docs/WeChat-MiniProgram.md` 中跟踪。 | Status (2026-11-19, Windows session): every open item below is iOS work that needs macOS, Xcode, an iOS simulator or an iOS device, so by the session-roles rule it belongs to the Mac session; the Windows session handed the list over on 2026-11-19. The Android, HarmonyOS and mini program parts of the project are tracked in `docs/Android-API-Map.md` (100), `docs/HarmonyOS.md` and `docs/WeChat-MiniProgram.md`. |
| TODO：完成并验证[对照跟踪表](flatdesign-item-comparison.md)中最后一个低于 100 分的对齐项（Carthage 与 iOS 15 最低版本，95 分；2026-11-21 由“Carthage 与 iOS 12”改名，库的最低版本自 2026-11-20 起为 iOS 15.0，iOS 12 真机要求已取消）；它还需要在真实的 iOS 15 运行时上运行一次（Mac 会话）。其余 18 行已为 100 分，并有测试证据。 | TODO: Complete and verify the last sub-100 parity item (Carthage and the iOS 15 minimum, 95; renamed from "Carthage and iOS 12" on 2026-11-21, because the library's minimum has been iOS 15.0 since 2026-11-20 and the iOS 12 device requirement is gone) listed in [the comparison tracker](flatdesign-item-comparison.md); it still needs one run on a real iOS 15 runtime (Mac session). The other 18 rows are at 100 with test evidence. |
| TODO：低于 100 分的占位图与上游刷新 issue 在 [issue-progress.md](issue-progress.md) 的 `TODO` 一节中跟踪。 | TODO: The placeholder and upstream-refresh issues below 100 are tracked in the `TODO` section of [issue-progress.md](issue-progress.md). |
| 审查（2026-11-19，Mac 会话）：Carthage 与 iOS 12 这一行仍为 95 分，受阻于没有 iOS 12 真机（这台 Mac 上无法运行任何 iOS 12 运行时）。issue-progress `TODO` 一节的每一行当天都重新评分：三行达到 100 分（#1628 通过核心修复、CYLTabBarController by commit、内置动画），其余各行都注明了带日期的阻碍或 “本轮未完成” 的说明；见该节顶部的审查记录。 | Audit (2026-11-19, Mac session): the Carthage and iOS 12 row stays at 95, blocked on a physical iOS 12 device (no iOS 12 runtime can run on this Mac). Every row of the issue-progress `TODO` section was rescored the same day: three rows reached 100 (#1628 with a core fix, CYLTabBarController by commit, bundled animations), the others carry a dated blocker or a "not done in this pass" note; see the audit line at the top of that section. |
