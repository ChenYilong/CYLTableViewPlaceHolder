# Swift migration of the core

This document tracks the task of transcribing the core (the library under `CYLTableViewPlaceHolder/`) from
Objective-C to Swift, and its score after every commit.

## Tasks

### TODO: Transcribe the core to Swift

- **Status:** not started (recorded 2026-11-12, while branch `feat/smartrefresh-parity` was in progress; when work
  starts, create a new branch and open its pull request per "A pull request for every new branch").
- **The user's original prompt (verbatim):** "将下面的任务找一个合适的文档，标注 TODO：全英文写入：注意本操作仅仅设计iOS端，重点修改 本项目的Core核心层面代码。 不涉及第三方库，首先创建swift编码规范文档，更新instructions和skills相关文档。如果网络有现成的swift skills请直接复制安装到本项目中，按照swift编码规范以及swift相关skilla，将Core 核心层面代码全部转录为Swift代码，如果无必要不要修改example层代码。在该文档中记录swift翻译进度。以项目中不存在objc代码为准，如果无法翻译为swift以宏定义 关键字形式 进行兼容swift的也可以算作翻译成功。不存在objc代码为满分，每提交一次就打一次分。每提交一次检查是否满分。一直到满分为止。"
- **Requirements:**
  1. iOS only; the focus is the project's core code. Third-party libraries are out of scope.
  2. First write a Swift coding standard document, and update the instruction files and the skills.
  3. If ready-made Swift skills exist online, copy and install them into this project.
  4. Following the Swift coding standard and the Swift skills, transcribe all of the core to Swift. Change the
     example layer only when necessary.
  5. Record the translation progress in this document.
  6. Scoring: the goal is no Objective-C code left in the project. Code that cannot be translated to Swift counts as
     translated when it is made Swift-compatible through macros or keywords (for example `NS_SWIFT_NAME`,
     `NS_REFINED_FOR_SWIFT`). No Objective-C code left is 100. Score after every commit, check for 100 after every
     commit, and continue until 100.
  7. Write everything for this task in English.
- **Context:**
  - The core is Objective-C today: `CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/` (placeholder view, stack view,
    scenarios, HUD, status view, localization, UIKit categories), `CYLTableViewPlaceHolder/CYLRefresh/` (the MJRefresh
    fork, now with the SmartRefreshControl API from `a30557c`) and `CYLTableViewPlaceHolder/CYLPlaceholderAnimation/`
    (optional Lottie, GIF, PAG and Rive backends). The examples are already Swift.
  - Existing Swift rules: `instructions.md` ("Swift examples and a Swift-friendly core"), `docs/Swift-Guide.md` (how
    the Objective-C API reads in Swift), and the public API comment rule (Swift sources use three-line `/** */`
    blocks).
  - Constraints to check when work starts: the podspec and its subspecs, Carthage and the framework build, the
    iOS 12 deployment build on Xcode 16 in CI (Swift raises the minimum runtime needs), the unit tests in
    `Tests/*.m` (Objective-C; they count toward "no Objective-C code"), and source compatibility for Objective-C
    callers (`@objc` names must keep today's selectors).
  - The parallel task in `docs/Refresh-Library-Parity.md` keeps adding Objective-C API to CYLRefresh; the two tasks
    touch the same files, so they must not run at the same time on different branches without a plan for merging.
- **Progress and scores:** none yet.
