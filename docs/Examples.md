# 运行示例 / Running the examples

<!-- bound-classes: none -->

<!-- docs-navigation:start -->

| 中文 | English |
| --- | --- |
| [运行 Demo](#运行-demo--running-the-demos) | [Running the demos](#运行-demo--running-the-demos) |

<!-- docs-navigation:end -->

<!-- docs-binding:start -->

| 类 / Class | 头文件 / Header |
| --- | --- |
| 无 / none | — |

<!-- docs-binding:end -->

| 中文 | English |
| --- | --- |
| 自 README 移入（2026-11-20）：各示例工程怎么运行、聚合 Demo `Example-Scenarios` 的各个 Tab。 | Moved from the README (2026-11-20): how to run each example project, and the tabs of the aggregate demo `Example-Scenarios`. |

## 运行 Demo / Running the demos

| 中文 | English |
| --- | --- |
| 主 Demo 源码位于 `Examples/Example/`，使用 Swift 编写，嵌入同一工程中的 `CYLTableViewPlaceHolderFramework` 目标并 `import CYLTableViewPlaceHolder`，打开根目录的 `CYLTableViewPlaceHolder.xcodeproj` 或 workspace 即可，无需运行 `pod install`。发布源码和资源集中在 `CYLTableViewPlaceHolder/`：占位组件位于 `CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/`，刷新组件位于 `CYLTableViewPlaceHolder/CYLRefresh/`，均由根目录的 podspec 指定。Xcode 27 的模拟器 SDK 使用 iOS 15 构建设置，真机最低版本为 iOS 15（自 2026-11-20 起；此前为 iOS 12）。 | The main demo source is in `Examples/Example/`, written in Swift: it embeds the `CYLTableViewPlaceHolderFramework` target of the same project and calls `import CYLTableViewPlaceHolder`: open `CYLTableViewPlaceHolder.xcodeproj` or the workspace at the repository root, with no need to run `pod install`. The published source and resources are gathered in `CYLTableViewPlaceHolder/`: the placeholder component is in `CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/` and the refresh component is in `CYLTableViewPlaceHolder/CYLRefresh/`, both specified by the podspec at the repository root. The Xcode 27 simulator SDK uses iOS 15 build settings, and the minimum for real devices is iOS 15 too (since 2026-11-20; it was iOS 12). |
| `Examples/Example-Scenarios/` 是聚合 Demo，用 Swift 编写，只调用本库核心层的 API：仿照 CYLTabBarController 的 Objective-C Demo，首页为带中间加号按钮的 CYLTabBarController。 | `Examples/Example-Scenarios/` is the aggregate demo, written in Swift and calling only the library's core API: modeled on CYLTabBarController's Objective-C demo, its home screen is a CYLTabBarController with a plus button in the middle. |
| 第五个 Tab“刷新”把 [MJRefresh](https://github.com/CoderMJLee/MJRefresh) 的整个 example 层（MJExampleViewController、MJTableViewController 的 example01–21、UICollectionView 上下拉与左拉、WKWebView、国际化、自定义控件 MJDIYHeader/MJDIYAutoFooter/MJDIYBackFooter 与动画图片控件 MJChiBaoZi…）转写为 Swift，改用本项目 API（`MJ` → `CYL`，`mj_` → `cyl_`）；动画图片使用内置刷新 GIF 的帧，另有一组页面演示 GIF、Lottie、PAG、Rive 动效图标。 | The fifth tab, "Refresh", transcribes the whole example layer of [MJRefresh](https://github.com/CoderMJLee/MJRefresh) to Swift on this project's API (`MJ` → `CYL`, `mj_` → `cyl_`): MJExampleViewController, example01–21 of MJTableViewController, UICollectionView pull down/up and pull left, WKWebView, localization, the custom controls MJDIYHeader/MJDIYAutoFooter/MJDIYBackFooter and the animated-image controls MJChiBaoZi…; the animated images use frames of the bundled refresh GIFs, and another group of pages shows GIF, Lottie, PAG and Rive icons. |
| **场景**：列出 `CYLPlaceholderScenarioCatalog` 的全部 36 个场景，分为“README 截图场景”“权限缺失（非网络失败）”和“常见业务场景”三组，每行显示核心层的场景名、对应的 README 截图编号和组件数；点击 push 到用 `CYLPlaceholderStackView(scenario:actions:)` 创建的页面：“重试”先显示加载场景再显示数据，“联系客服”push 到客服页，“去设置”打开系统设置，“手动选择地址”给出提示，“完成”返回；导航栏的“交互：开/关”切换所有组件的 `tapInteractionEnabled`。“配置文件初始化”分组打开 7 个 JSON/plist 配置文件（按下样式、关闭交互、播放策略、四种动画格式等），并可查看文件内容。页面顶部的 🌐 按钮切换语言（七种语言或跟随系统），切换后整个界面用新语言重建，与 CYLTabBarController Objective-C Demo 的语言演示相同。 | **Scenarios**: lists all 36 scenarios of `CYLPlaceholderScenarioCatalog` in three groups, "README screenshots", "permission missing (not a network failure)" and "business cases"; each row shows the core's scenario name, the README screenshot numbers and the component count. Tapping a row pushes a page created with `CYLPlaceholderStackView(scenario:actions:)`: "Retry" shows the loading scenario and then data, "Contact support" pushes a support page, "Open Settings" opens the system settings, "Choose an address manually" shows a short confirmation, and "Done" goes back; "Tap: on/off" in the navigation bar switches every component's `tapInteractionEnabled`. The "Configuration files" section opens 7 JSON/plist configuration files (pressed looks, interaction off, playback policies, the four animation formats and more) and can show each file. The 🌐 button at the top of the page switches the language (seven languages or the system's), and the whole interface is rebuilt in the new language, as in CYLTabBarController's Objective-C demo. |
| **动画**：按引擎分组列出核心资源包中的 53 个动画文件及大小，逐个播放（每 4 秒重播）；“来源”显示 `NOTICE.animations`。最后一组是示例自己的 `CYLScenarioExample.bundle/Animations`：没有占位含义的动画（吉祥物、场景、控件演示）只放在示例层，按文件路径播放。 | **Animations**: lists the 53 animation files of the core resource bundle by engine, with their sizes, and plays each one (replayed every 4 seconds); "Sources" shows `NOTICE.animations`. The last group is the example's own `CYLScenarioExample.bundle/Animations`: animations without a placeholder meaning (a mascot, a scene, widget demos) live only in the example layer and play by file path. |
| **交互流程**：空 / 失败 / 断网 / 有数据切换、保留表头和分组头、下拉刷新与上拉加载、可滚动占位、`UICollectionView` 占位，占位图均为核心层的场景。 | **Flows**: switching between empty / failed / offline / has data, keeping the table header and section headers, pull-down refresh and pull-up loading, a scrollable placeholder and a `UICollectionView` placeholder; every placeholder is a core scenario. |
| **动态**：模拟真实列表：首次加载显示加载场景，下拉刷新交替失败并显示带“重试”按钮的场景，上拉加载到底显示“没有更多”。 | **Feed**: simulates a real list: the first load shows the loading scenario, pull-down refresh alternately fails and shows the scenario with a "Retry" button, and pull-up loading shows "No more" at the end. |
| **加号按钮**：弹出“上传中”场景（GIF），随后显示“成功”场景（动画加“完成”按钮）。 | **Plus button**: shows the "Uploading" scenario (GIF), then the "Success" scenario (an animation and a "Done" button). |
| 在该目录运行 `pod install` 后打开 `Example-Scenarios.xcworkspace`；它通过本地 Pod 引入全部动画子规格，并按最新 commit 引入 CYLTabBarController（构建前由 `scripts/resolve-cyltabbarcontroller-commit.sh` 更新）。场景文字来自核心资源包；Demo 自己的界面文字（Tab、分组等）放在示例的 `Sources/CYLScenarioExample.bundle`（七种语言），代码只通过 `CYLScenarioLocalization.swift` 中的 `CYLScenarioLocalizedString` 函数和 `CYLScenarioL10n` 键枚举读取；`python3 scripts/check_localizations.py` 检查所有资源包以及键枚举是否完整。 | Run `pod install` in that directory and open `Example-Scenarios.xcworkspace`; it pulls in all animation subspecs through the local pod and CYLTabBarController at its newest commit (updated before each build by `scripts/resolve-cyltabbarcontroller-commit.sh`). Scenario texts come from the core resource bundle; the demo's own UI text (tabs, sections and so on) lives in the example's `Sources/CYLScenarioExample.bundle` (seven languages), and the code reads it only through the `CYLScenarioLocalizedString` function and the `CYLScenarioL10n` key enum in `CYLScenarioLocalization.swift`; `python3 scripts/check_localizations.py` checks that all resource bundles and the key enum are complete. |
| 四个 `Example-*` 工程使用本地 Pod，分别在各自目录运行 `pod install` 后打开 workspace；它们的应用和 Pods 最低版本为 iOS 15，与库的最低版本相同。 | The four `Example-*` projects use the local pod; run `pod install` in each directory and open the workspace; their apps and Pods require iOS 15 at least, the same as the library's minimum. |
| 示例只使用 CYLRefresh 刷新、只使用 `CYLPlaceholderHUD` 显示 HUD，不依赖其他刷新或 HUD 库。仓库根目录的主 Demo 通过同一工程的框架目标使用源码。 | The examples refresh only with CYLRefresh and show HUDs only with `CYLPlaceholderHUD`; they depend on no other refresh or HUD library. The main demo at the repository root uses the source through the framework target of the same project. |
