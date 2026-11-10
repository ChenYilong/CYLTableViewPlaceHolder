# Issue 修复进度

更新时间：2026-11-08。分数是当前需求及验证完成程度的人工估计，不代表 GitHub issue 已关闭；只有实现和针对性验证均完成才记为 100。低于 100 分的条目列出至少三次实际调查、修复或验证尝试及剩余限制；这些尝试并不等于三轮独立代码修复。

| Issue 地址 | Issue 描述 | 修复近况 |
| --- | --- | --- |
| [#17](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/17) | 自定义占位位置，避免遮挡表头 | **100/100**：新增可选 frame 回调，保留默认全屏行为；模拟器回归验证表头不重叠。 |
| [#16](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/16) | 自定义表头及 section 时占位图被遮挡 | **100/100**：frame 回调可避开表头和 section header；调用回调前先布局，读到含 iOS 15 顶部间距的最终位置。回归测试覆盖两个自定义 section header 及横竖屏尺寸，CI 通过。默认仍全屏覆盖以保持兼容。 |
| [#15](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/15) | iPhone XR、XS、XS Max 适配 | **80/100**：检查原屏幕尺寸代码、改用容器 bounds、在 XS Max 模拟器检查占位图尺寸和缩放；本机无 XR/XS 模拟器，未完成两种机型的实机或模拟器验证。原 issue 已关闭。 |
| [#13](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/13) | 滚动选项返回 NO 时抛异常 | **100/100**：使用类型正确的 BOOL 协议调用；测试 YES、NO 和原滚动状态恢复。 |
| [#11](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/11) | UICollectionView 和普通页面适用范围 | **100/100**：block API `cyl_placeholderViewBlock:` 已支持 `UICollectionView`（`testCollectionBatchUpdatesAndCancellation`、`testCollectionSectionsAndFrameLayoutWithOffset`，CI 通过）；修正 README 中“只管理 UITableView”的过时说法。普通页面没有 data source，按设计不自动管理，文档说明可直接使用 `CYLPlaceholderView`。 |
| [#10](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/10) | CocoaPods 链接失败 `library not found for -lPods` | **100/100**：结论为集成环境问题而非库缺陷（报告者手动改过 Podfile 扩展名）。README 新增排查步骤（打开 workspace、恢复纯文本 Podfile、`pod deintegrate && pod install`、清理 DerivedData）。CocoaPods 集成由 CI 验证：`pod lib lint` 全部子规格通过，三个使用本地 Pod 的示例（Example-objc-01、Example-objc-02、Example-SwiftUI）经 `pod install` 后通过 workspace 构建成功。报告者原工程不可得，未复现其具体错误。 |
| [#9](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/9) | 独立 UITableViewDataSource 不显示占位图 | **100/100**：增加 data source 回退，并保留 table view、delegate 优先级；模拟器测试独立 data source 和 delegate 优先级。 |
| [#8](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/8) | 占位图遮挡 MJRefresh footer | **100/100**：默认全屏占位时，刷新 header/footer/trailer（含 MJRefresh）始终位于占位图之上，delegate API 与 block API 均有回归测试，CI 通过；需要完全不重叠时仍可用 frame 回调。 |
| [#7](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/7) | 未实现 section 数量方法时空数据判断 | **100/100**：默认按一个 section 判断行数；模拟器测试默认 section 和后续 section 有数据的情况。 |
| [#6](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/6) | 再次空刷新后占位图消失 | **85/100**：检查历史修复、调整重复刷新逻辑、在 iOS 17.5 模拟器通过回归测试；原 issue 已关闭，但无法在最初的 iOS 9 环境复测。 |
| [#3](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/3) | 网络错误和无数据占位图无法切换 | **100/100**：每次空刷新重新请求视图，模拟器验证旧视图移除并显示新视图；PR #14 已合并。 |
| [#2](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/2) | 重复刷新导致占位图子视图消失 | **100/100**：相同视图不再反复移除，模拟器验证子视图保留；原 issue 已关闭。 |
| [#1](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/1) | “NewTableVIew”，内容仅为“下载到桌面” | **10/100**：检查原文和评论、搜索相关 issue、检查相关提交历史；均无法确定期望行为或复现方式，需报告者补充信息。原 issue 已关闭。 |

## 开放 issue 处理进度

2026-11-09 快照：本仓库 9 个开放 issue。100 分须同时具备实现和针对性测试；证据列出测试名，CI 指 PR #20 的 `iOS` 工作流（run 42714531428 重跑，80 项单元测试全部通过）。PR #20 合并时以 `Closes` 关联并关闭达到 100 分的 issue。

| Issue | 问题 | 分数 | 处理与验证证据 | 关联 |
| --- | --- | ---: | --- | --- |
| [#17](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/17) | 自定义占位位置，避免遮挡表头 | 100 | `frameForPlaceHolderViewInTableView:` 回调；`testCustomFrameLeavesHeaderOutsidePlaceholder`、`testDefaultFrameFollowsTableResize`，CI 通过。 | PR #20 Closes |
| [#13](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/13) | 滚动选项返回 NO 时抛异常 | 100 | 按 BOOL 正确调用；`testOptionalScrollAndNilPlaceholder`、`testDefaultSectionAndScrollRestoration`、`testInitiallyDisabledScrollIsRestored`，CI 通过。 | PR #20 Closes |
| [#9](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/9) | 独立 data source 不显示占位图 | 100 | table view → delegate → data source 依次回退；`testDelegateTakesPrecedenceOverDataSource`，CI 通过。 | PR #20 Closes |
| [#7](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/7) | 未实现 section 数量方法时判断错误 | 100 | 默认 1 个 section；`testDefaultSectionAndScrollRestoration`、`testRowsInLaterSectionRemovePlaceholder`，CI 通过。 | PR #20 Closes |
| [#3](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/3) | 网络错误与无数据占位图无法切换 | 100 | 每次空刷新重新请求视图；`testRepeatedEmptyReloadKeepsSubviewsAndCanSwitchViews`，CI 通过。 | PR #20 Closes |
| [#11](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/11) | 为什么只基于 tableView | 100 | collection view 由 block API 支持，`testCollectionBatchUpdatesAndCancellation`、`testCollectionSectionsAndFrameLayoutWithOffset`，CI 通过；README 过时说法已修正；普通页面按设计不自动管理（无 data source），文档给出直接使用 `CYLPlaceholderView` 的做法。 | PR #20 Closes |
| [#10](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/10) | CocoaPods 链接失败 `-lPods` | 100 | 判定为集成环境问题（手动改动 Podfile 后未正确重新集成）；README 增加排查步骤。CI 的 `pod lib lint` 与三个 Pod 集成示例（`pod install` + workspace 构建）通过。原工程不可得，未复现原始报错。 | PR #20 Closes |
| [#8](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/8) | 占位图遮挡刷新 footer | 100 | 默认行为修复：占位图置前后，再把 `CYLRefreshComponent`/`MJRefreshComponent` 子视图移到其上方，两套 API 共用；`testDefaultPlaceholderKeepsRefreshControlsVisible`、`testAutomaticPlaceholderStaysBelowRefreshControls` 在 CI（f425754）通过。行为变化：刷新控件始终显示在占位图之上。 | PR #20 Closes |
| [#16](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/16) | 自定义 header/section 后被遮挡 | 100 | frame 回调从最后一个 section header 底部开始，README 给出示例；修复回调在布局前读取位置、漏算 iOS 15 section header 顶部间距的问题（调用前先 `layoutIfNeeded`）。`testCustomFrameLeavesSectionHeadersOutsidePlaceholder`（表头 + 两个 section header，竖屏和横屏）在 CI（f425754）通过。 | PR #20 Closes |

## 验证与决定

- PR [#14](https://github.com/ChenYilong/CYLTableViewPlaceHolder/pull/14) 的冲突已解决并合并。
- 回归测试通过 `ruby Tests/run-tests.rb` 运行；需要 Xcode、iOS 模拟器和 CocoaPods 的 `xcodeproj` Ruby gem。`DESTINATION` 可指定模拟器。安装 Pods 后会额外编译 MJRefresh 集成测试。
- iPhone 15 和 iPhone XS Max（iOS 17.5）上通过基础回归测试；旧 iOS 9、XR 和 XS 暂未验证。
- 安装 MJRefresh 3.1.15.3 后，在 iPhone 15（iOS 17.5）通过实际 footer 集成测试；该测试覆盖自定义区域而非默认行为。
- 默认仍让占位图覆盖 table view；需要保留 header/footer 的应用应实现 frame 回调，并根据实际布局更新它，避免改变现有用户的默认行为。

### 2026-11-08 刷新组件迁移

- 原外部刷新 Pod 已从示例工程移除，改为使用本仓库中的 `CYLRefresh` 源码；旧接口需迁移到 `CYL` 类名及 `cyl_` 分类接口。
- 最低系统版本调整为 iOS 12；原始组件版权、许可证及来源说明予以保留。历史测试结果保留在上文，新版本以当前回归测试为准。

### 2026-11-10 国际化资源合并

- 全部本地化文件和图片统一放入 `CYLTableViewPlaceHolder.bundle`，删除 `CYLRefresh.bundle`：刷新文案移入 `<语言>.lproj/CYLRefresh.strings`（与占位的 `Localizable.strings` 分表，避免 key 冲突），箭头图片改名为 `CYLRefreshArrow@2x.png`、`CYLRefreshTrailArrow@2x.png`。`cyl_refreshBundle` 保留并返回统一资源包；podspec、Xcode 工程和两个测试 runner 只引用这一个资源包。
- 两张字符串表统一为 en、zh-Hans、zh-Hant、ja、ko、ru、uk 七种语言：补齐占位文案的韩、俄、乌克兰文，刷新文案的日文，以及此前只有中文的 trailer 文案（英、韩、俄、乌克兰文下原会显示 key 名）。
- 刷新 header 的“最后更新”时间改为按 locale 模板格式化（日期顺序、12/24 小时制），并修复只比较“日”导致上月同一天显示“今天”的问题。
- 兼容性：CocoaPods、Carthage 集成无需改动；手动集成需删除工程中的 `CYLRefresh.bundle`；直接读取旧 bundle 路径或旧图片名的代码需改用 `cyl_refreshBundle` / `cyl_arrowImage` / `cyl_trailArrowImage`。时间显示格式随 locale 变化。

### 2026-11-10 内置动画资源与聚合 Demo

- 从开源仓库下载 19 个占位动画（未修改，约 300 KB），放入 `CYLTableViewPlaceHolder.bundle/Animations/`：Lottie 9 个（airbnb/lottie-ios，Apache-2.0）、PAG 4 个（Tencent/libpag，Apache-2.0，经 Git LFS 下载并核对 SHA-256）、Rive 5 个（rive-app/rive-ios，MIT）、GIF 1 个（CYLTabBarController，MIT）。`NOTICE.animations` 记录逐个文件的来源、提交、路径、许可证与 SHA-256，许可证全文随资源包分发。
- 新增公开 API `+[CYLPlaceholderView bundledAnimationFileNames]`、`+pathForBundledAnimation:`，以及测试 `testBundledAnimationsAreListedValidAndAttributed`（数量、各格式文件头、NOTICE 条目、拒绝路径穿越）。
- 新增聚合 Demo `Examples/Example-Scenarios`：仿照 CYLTabBarController Objective-C Demo 的带加号按钮 TabBar；“场景”Tab 分三组列出 28 个场景，每个 cell push 到对应占位图；“动画”Tab 播放全部内置动画；“动态”Tab 演示加载、失败重试、下拉刷新与上拉加载；“资源”Tab 列出资源与来源。已加入 CI 的 Demo 矩阵并上传截图。

## 上游刷新组件开放 issues

快照：2026-11-08，以下为上游 issue 页面中的 51 个开放 issue，不包含已关闭 issue 或 PR。旧名称 `MJRefresh`/`mj_` 对应本项目的 `CYLRefresh`/`cyl_`。**0/100** 表示尚未完成调查和验证，不表示已尝试修复；不得把尚未进行的尝试记为已完成。

| Issue 地址 | Issue 描述 | 修复近况 |
| --- | --- | --- |
| [#1630](https://github.com/CoderMJLee/MJRefresh/issues/1630) | 偶发移除 KVO 观察者崩溃 | 60/100：按实际注册对象解绑，并在 iOS 26.3.1 模拟器让自动 footer 在普通容器及两个滚动视图之间切换 100 次；原偶发崩溃及真实控制器销毁场景仍未复现，不能确认根因，尚未进行三轮独立修复。 |
| [#1628](https://github.com/CoderMJLee/MJRefresh/issues/1628) | SwiftUI 刷新动画消失 | 50/100：原 demo 的 introspection 回调每次重新安装刷新控件并重置 inset；数据更新后复现状态丢失。示例改为仅初始化一次后，程序触发的刷新在数据更新期间仍可见，但真实下拉时可见性检查失败，仍需调查；不能认为已完全修复。 |
| [#1627](https://github.com/CoderMJLee/MJRefresh/issues/1627) | Plain 表格 section header 回弹异常 | 0/100：未调查，未修复。 |
| [#1626](https://github.com/CoderMJLee/MJRefresh/issues/1626) | 本地化 bundle 路径为空 | 100/100：对语言目录和资源 bundle 路径进行空值防护；模拟器验证未知语言回退英文，以及整个资源 bundle 缺失时保留调用方提供的回退文本。 |
| [#1625](https://github.com/CoderMJLee/MJRefresh/issues/1625) | SPM 包解析失败 | 0/100：未调查，未修复。 |
| [#1624](https://github.com/CoderMJLee/MJRefresh/issues/1624) | 安全改进建议 | 0/100：未调查，未修复。 |
| [#1623](https://github.com/CoderMJLee/MJRefresh/issues/1623) | 自动加载 trailer | 70/100：`CYLRefreshTrailer` 新增可选的 `automaticallyRefresh`（默认 NO，保持原行为）、`triggerAutomaticallyRefreshPercent` 和 `autoTriggerTimes`，语义与自动 footer 一致，State/Normal trailer 自动继承。三项新增模拟器测试（阈值触发与结束复原、默认不自动触发、回弹/header 刷新中/内容不足一屏不触发）在 PR #20 的 CI（macOS 26 runner）中通过，全部 80 项单元测试通过；iOS 12 部署构建通过。未阅读原 issue 原文核对需求，拖拽次数限制和真实手势未测试。 |
| [#1615](https://github.com/CoderMJLee/MJRefresh/issues/1615) | 自定义 header 快速下拉崩溃 | 0/100：未调查，未修复。 |
| [#1614](https://github.com/CoderMJLee/MJRefresh/issues/1614) | SwiftUI 兼容功能 | 0/100：未调查，未修复。 |
| [#1613](https://github.com/CoderMJLee/MJRefresh/issues/1613) | 偶发上拉刷新无法恢复 | 0/100：未调查，未修复。 |
| [#1610](https://github.com/CoderMJLee/MJRefresh/issues/1610) | 自动 footer 结束时 contentOffset 复位异常 | 75/100：分页模式结束刷新时不再减去整个底部 inset；静止时仅限制越界 offset，拖拽或减速时不强制移动。模拟器以受控状态验证正常位置、越界、拖拽和减速分支；真实手势减速、数据变化及分页对齐尚未验证，未完成三轮独立修复。 |
| [#1607](https://github.com/CoderMJLee/MJRefresh/issues/1607) | Plain 表格的 section footer 悬空 | 0/100：未调查，未修复。 |
| [#1600](https://github.com/CoderMJLee/MJRefresh/issues/1600) | 自适应 collection cell 加载后抖动 | 0/100：未调查，未修复。 |
| [#1598](https://github.com/CoderMJLee/MJRefresh/issues/1598) | scrollToRowAtIndexPath 后 footer 露出 | 0/100：未调查，未修复。 |
| [#1597](https://github.com/CoderMJLee/MJRefresh/issues/1597) | JXCategoryView 中 header 子控件不显示 | 0/100：未调查，未修复。 |
| [#1595](https://github.com/CoderMJLee/MJRefresh/issues/1595) | collection 悬浮 header 加载更多时闪烁 | 0/100：未调查，未修复。 |
| [#1593](https://github.com/CoderMJLee/MJRefresh/issues/1593) | 真机编译时消息发送参数错误 | 45/100：检查原报告及评论，当前代码在开启 strict objc_msgSend 时可编译通用 iOS 真机目标；缺少原始工程、报错文本和实际设备验证，不能确认根因或完成三轮独立修复。 |
| [#1592](https://github.com/CoderMJLee/MJRefresh/issues/1592) | 自定义 collection layout 固定 header 动画异常 | 0/100：未调查，未修复。 |
| [#1591](https://github.com/CoderMJLee/MJRefresh/issues/1591) | pagingEnabled 时加载结束偏移和闪烁 | 0/100：未调查，未修复。 |
| [#1590](https://github.com/CoderMJLee/MJRefresh/issues/1590) | WKWebView Auto Layout 初次显示不全 | 0/100：未调查，未修复。 |
| [#1589](https://github.com/CoderMJLee/MJRefresh/issues/1589) | SwiftUI 非 scroll view 容器移除 KVO 崩溃 | 90/100：按实际注册对象解绑；模拟器让自动 footer 在普通 UIView 和两个 scroll view 间切换 100 次，检查底部 inset 恢复；新增 `UIViewRepresentable` 包装 back footer 的 SwiftUI 页面，在 iOS 17.5 上往返五次未崩溃。尚未在报告的 iOS 15.4 环境验证或用原代码重现崩溃，未进行三轮独立修复。 |
| [#1587](https://github.com/CoderMJLee/MJRefresh/issues/1587) | 下拉刷新和上拉加载互斥 | 40/100：检查自动 footer 两个触发路径、阻止 header 刷新时自动触发、测试 header 刷新前后状态；反向互斥、其他 footer 类型和状态提示未实现，未进行三轮独立修复。 |
| [#1586](https://github.com/CoderMJLee/MJRefresh/issues/1586) | 隐藏 header 时开始刷新位置异常 | 85/100：复现并修复隐藏时首次加入未定位以及刷新结束后顶部 inset 未恢复；iOS 17.5 模拟器验证隐藏 table header 连续三次刷新，以及隐藏和可见 collection header 交替刷新。iOS 26.3.1 测试停在另一条用例，未完成；尚未比对原报告截图或验证真实页面，未完成三轮独立修复。 |
| [#1585](https://github.com/CoderMJLee/MJRefresh/issues/1585) | 无更多数据提示停留及其他定制场景 | 0/100：未调查，未修复。 |
| [#1583](https://github.com/CoderMJLee/MJRefresh/issues/1583) | 空表 reloadData 后 footer 上移 | 0/100：未调查，未修复。 |
| [#1582](https://github.com/CoderMJLee/MJRefresh/issues/1582) | 不同下拉距离触发不同操作 | 0/100：未调查，未修复。 |
| [#1575](https://github.com/CoderMJLee/MJRefresh/issues/1575) | JXSegmentedView 场景崩溃 | 50/100：检查原报告、上游 PR #1576 和报告者的 collection demo；当前 header 的 inset 判断已包含浮点容差。将 demo 改为 SceneDelegate 并指向本地 pod 后，在 iPhone 15 / iOS 17.5 模拟器通过一次下拉刷新，未复现崩溃。iPhone 14 Pro Max / iOS 26.4 模拟器测试启动停滞，未得结果；原 iOS 16、iPhone 14 Pro 和 JXSegmentedView 场景未验证，未完成三轮独立修复。 |
| [#1572](https://github.com/CoderMJLee/MJRefresh/issues/1572) | grouped 表格底部额外空白 | 0/100：未调查，未修复。 |
| [#1571](https://github.com/CoderMJLee/MJRefresh/issues/1571) | collection gif footer 初次出现卡顿 | 0/100：未调查，未修复。 |
| [#1570](https://github.com/CoderMJLee/MJRefresh/issues/1570) | 纯 Swift 版本需求 | 0/100：未调查，未修复。 |
| [#1568](https://github.com/CoderMJLee/MJRefresh/issues/1568) | collection 背景在刷新时弹动 | 0/100：未调查，未修复。 |
| [#1564](https://github.com/CoderMJLee/MJRefresh/issues/1564) | 自定义 gif header 偶发无法复位 | 0/100：未调查，未修复。 |
| [#1563](https://github.com/CoderMJLee/MJRefresh/issues/1563) | 箭头图片内存泄漏疑问 | 50/100：静态检查 bundle 路径和箭头图片使用 ARC，静态缓存是进程生命周期内有意持有的共享对象；Clang 静态分析未报告这条路径的泄漏，模拟器验证移除 header 后 header 与箭头视图释放且缓存复用。尚未在报告的真机、iOS 13.7 和 Instruments Leaks 复现 `NSPathStore2`，无法断言泄漏不存在或已修复；未做无证据的所有权改动。 |
| [#1540](https://github.com/CoderMJLee/MJRefresh/issues/1540) | 全屏分页 collection 加载结束偏移 | 0/100：未调查，未修复。 |
| [#1535](https://github.com/CoderMJLee/MJRefresh/issues/1535) | 不同机型上拉不调用 footer block | 0/100：未调查，未修复。 |
| [#1523](https://github.com/CoderMJLee/MJRefresh/issues/1523) | collection 防动画异常选项导致 item 闪烁 | 30/100：将原 demo 中的 collection 控制器适配至 `Examples/Example-objc-02`，启用 `isCollectionViewAnimationBug` 并接入本地 pod；iOS 17.5 模拟器通过下拉刷新和加载完成的手势测试。测试未检测画面闪烁，原 demo 的其他页面尚未全部移植，也未验证 #225 悬浮 header；尚未复现或修复原视觉问题。 |
| [#1507](https://github.com/CoderMJLee/MJRefresh/issues/1507) | Plain section header 加载结束跳动 | 0/100：未调查，未修复。 |
| [#1506](https://github.com/CoderMJLee/MJRefresh/issues/1506) | collection 大幅度加载动画异常 | 25/100：`Examples/Example-objc-02` 增加 back footer，iOS 17.5 模拟器验证大幅上拉能触发并结束刷新；该测试不检测 cell 漂移或闪烁，也不证明其与 #1523 根因相同。视觉复现及修复尚未完成。 |
| [#1488](https://github.com/CoderMJLee/MJRefresh/issues/1488) | 浮点误差导致自动 footer 不触发 | 100/100：松手判定加入按数值大小缩放的浮点误差容限；模拟器针对临界点相差约 1e-11、恰好相等和差 0.01 分别验证触发、触发和不触发；另以报告中的 1367.666666666687 / 1367.666666666698 原值和分页开启状态验证触发。原 iOS 13.6 环境未复测。 |
| [#1483](https://github.com/CoderMJLee/MJRefresh/issues/1483) | collection 连续刷新位置上移 | 50/100：修复刷新开始时 inset 恢复量未初始化；模拟器在 collection 动画分支验证顶部 inset 恢复和交互恢复，并在 `Examples/Example-objc-02` 中连续四次实际下拉，检查首个 item 在动画结束后的位置。尚未复现原视频中的布局和刷新中反复拖动场景，未完成三轮独立修复。 |
| [#1481](https://github.com/CoderMJLee/MJRefresh/issues/1481) | trailer 转 footer 后横向内容尺寸残留 | 85/100：三项相关修复及验证：①恢复移除时的右侧 inset 和横向弹性，模拟真实 collection 切换方向；②防止开始动画未完成时结束或复用导致旧开始回调重复触发，并避免旧结束动画重置新刷新进度；③为重叠的结束动画分别保存完成回调，修复旧回调丢失和新回调重复执行。②③分别先复现失败，再于 iOS 17.5 模拟器验证修复。仍需先移除 trailer；原 issue 缺少切换代码，保留 trailer 的场景仍未确认，这三项修复不代表对该未知场景进行了三次独立修复尝试。 |
| [#1430](https://github.com/CoderMJLee/MJRefresh/issues/1430) | 刷新后设置 offset 并滑动时跳到首项 | 45/100：新增全屏分页 table 示例；iOS 17.5 模拟器通过刷新、恢复 offset 再滑动的测试，但未复现原跳转。另测分页 footer 增长数据后真实上拉，原页面仍偏移约 190 点且无法通过后续滑动检查；相关修复未完成，原 iOS 13 和真机未验证，也未完成三轮独立修复。 |
| [#1317](https://github.com/CoderMJLee/MJRefresh/issues/1317) | navigation 搜索控制器引发 inset 递归崩溃 | 80/100：静态定位刷新期间 inset 写入同步触发 contentOffset KVO 后再次进入 inset 写入；header 的重入保护现覆盖刷新开始、`resetInset` 及两种结束动画路径。模拟 inset/offset 反馈分别在刷新开始和刷新中触发，验证嵌套写入深度保持为 1、结束后恢复原 inset；iOS 17.5 模拟器通过 46 项测试。尚未在原 iOS 12.3 和真实手势下复现原崩溃，未完成三轮独立修复。该问题是递归重入，不是已证实的循环引用泄漏。 |
| [#1258](https://github.com/CoderMJLee/MJRefresh/issues/1258) | 异步结束刷新覆盖调用方设置的状态 | 100/100：主线程立即结束刷新，模拟器验证随后设置的无更多数据状态不会被排队任务覆盖；后台调用仍异步派发到主线程。 |
| [#1238](https://github.com/CoderMJLee/MJRefresh/issues/1238) | 表头搜索控制器影响刷新显示 | 0/100：未调查，未修复。 |
| [#1146](https://github.com/CoderMJLee/MJRefresh/issues/1146) | 自适应行高加载后回滚异常 | 0/100：未调查，未修复。 |
| [#1067](https://github.com/CoderMJLee/MJRefresh/issues/1067) | 带内边距的 collection 下拉时跳动 | 0/100：未调查，未修复。 |
| [#1041](https://github.com/CoderMJLee/MJRefresh/issues/1041) | drawRect 额外内存开销 | 80/100：审阅原 issue 和引用的 Stack Overflow 文章；组件的 `drawRect:` 不绘图，仅把待刷新状态切换为刷新，因此删除该重写及 `setNeedsDisplay`，使用现有 `WillRefresh` 状态和入窗后主线程布局切换，不增加破坏兼容性的公开 `init` 状态。入窗后即使控件隐藏也可启动待刷新，不再依赖实际绘制，时机可能比旧实现更早。模拟器回归验证四类控件延迟启动、重复请求只回调一次和取消待刷新，以及不再重写绘图方法；尚未在真机用 Instruments 对比内存或覆盖所有转场及真实手势，无法量化内存收益，也未完成三轮独立修复尝试。 |
| [#1029](https://github.com/CoderMJLee/MJRefresh/issues/1029) | 大标题导航栏刷新崩溃 | 0/100：未调查，未修复。 |
| [#920](https://github.com/CoderMJLee/MJRefresh/issues/920) | 表格 section index 随刷新跳动 | 0/100：未调查，未修复。 |
| [#862](https://github.com/CoderMJLee/MJRefresh/issues/862) | viewDidLoad 初始刷新动画影响转场 | 0/100：未调查，未修复。 |

### 上游开放 PR 移植记录

| PR 地址 | 内容 | 本项目状态 |
| --- | --- | --- |
| [#1629](https://github.com/CoderMJLee/MJRefresh/pull/1629) | 本地化 bundle 路径为空防护 | 已适配空路径处理并验证语言目录及资源 bundle 缺失场景，见 #1626。 |
| [#1606](https://github.com/CoderMJLee/MJRefresh/pull/1606) | 主线程同步状态更新 | 已对结束和重置刷新状态定向适配，保留原本用于延迟布局的异步宏；未照搬会改变所有调用点的补丁。 |
| [#1444](https://github.com/CoderMJLee/MJRefresh/pull/1444) | header inset、section header 与动画 | 部分适配：在普通及 collection 动画路径设置刷新开始时的 inset 恢复量，验证连续刷新恢复 inset；尚未移植拖拽时重新计算 inset 及其 delta 语义，仍缺少真实拖拽、旋转与悬浮 section header 验证。 |
| [#1329](https://github.com/CoderMJLee/MJRefresh/pull/1329) | 同步执行 header 刷新动画 | 当前版本已经直接调用 header 刷新动作；未声称所有旧系统的回弹问题已解决。 |
| [#1328](https://github.com/CoderMJLee/MJRefresh/pull/1328) | 下拉时避免自动触发 footer | 已适配 adjusted inset 边界及 header 刷新期间的保护；其他互斥需求见 #1587。 |
| [#1181](https://github.com/CoderMJLee/MJRefresh/pull/1181) | 滚动距离及方向 | 已改为显式采样、`CGFloat` 距离及 `CYL` 类型，避免原补丁的读取副作用和方向计算错误；调用方式不同，见 README。 |
| [#759](https://github.com/CoderMJLee/MJRefresh/pull/759) | 同步执行 header 刷新动画 | 当前版本已直接执行动画；未验证报告中的全部历史系统与场景。 |

## TODO

汇总上文所有低于 100 分的条目（2026-11-09 核对）。分数与剩余工作以上方表格为准，此处列出完成所需的工作和验证方式。所有验证都需要 macOS、Xcode 和 iOS 模拟器（部分需真机）；Linux 环境只能核对文档，不能计入完成度。

### 占位组件

| TODO | 剩余工作与实现说明 | 所需验证 |
| --- | --- | --- |
| TODO — #15 XR/XS 适配（80） | 已改用容器 bounds，仅在 XS Max 上验证。 | 在 iPhone XR、iPhone XS 模拟器运行 `DESTINATION=... ruby Tests/run-tests.rb` 并记录结果。 |
| TODO — #6 再次空刷新后消失（85） | iOS 17.5 回归通过；原 iOS 9 环境无法复测。 | 若坚持旧系统证据，需在最低支持的 iOS 12 真机运行 `scripts/device-tests.sh`；否则说明 iOS 9 已不在支持范围并改为 100。 |
| TODO — #1 “NewTableVIew”（10） | 原文无法确定期望行为。 | 需报告者补充信息；issue 已关闭，可由维护者决定标记为无法处理。 |

### 上游刷新组件（部分完成）

| TODO | 剩余工作与实现说明 | 所需验证 |
| --- | --- | --- |
| TODO — #1630 KVO 移除崩溃（60） | 已按注册对象解绑；未复现原偶发崩溃。 | 真实控制器销毁场景的压力测试；Zombie/ASan 下运行。 |
| TODO — #1628 SwiftUI 刷新动画消失（50） | 程序触发刷新可见；真实下拉时可见性检查失败。 | 修复后用 XCUITest 真实下拉验证刷新控件全程可见。 |
| TODO — #1610 自动 footer 复位（75） | 受控状态分支已测；真实减速、数据变化、分页对齐未测。 | XCUITest 真实手势 + 分页数据增长场景。 |
| TODO — #1593 真机编译参数错误（45） | strict objc_msgSend 下通用真机目标可编译；缺原始报错。 | 获取原工程或报错文本，在真机构建确认。 |
| TODO — #1589 SwiftUI 非 scroll view KVO 崩溃（90） | iOS 17.5 往返未崩溃；未在 iOS 15.4 验证。 | iOS 15 模拟器运行同一 SwiftUI 页面测试。 |
| TODO — #1587 下拉与上拉互斥（40） | 只实现 header 刷新时阻止自动 footer；反向互斥、其他 footer 类型和状态提示未实现。 | 新增反向互斥实现及 back/auto footer 双向测试。 |
| TODO — #1586 隐藏 header 刷新位置（85） | iOS 26.3.1 测试未完成；未比对原截图。 | 在 iOS 26 模拟器跑完整套件并记录。 |
| TODO — #1575 JXSegmentedView 崩溃（50） | iOS 17.5 未复现；iOS 26.4 启动停滞；原 iOS 16 场景未验证。 | iOS 16 模拟器 + JXSegmentedView demo 下拉刷新。 |
| TODO — #1563 箭头图片泄漏疑问（50） | 静态分析与释放测试无泄漏；未在 Instruments Leaks 复现。 | 真机 Instruments Leaks 记录，确认或排除 `NSPathStore2`。 |
| TODO — #1523 collection 动画选项闪烁（30） | 手势测试通过，但不检测闪烁；原视觉问题未复现。另报问题（2026-11-10，用户）：滑到底上拉加载、没有新数据（含 `endRefreshingWithNoMoreData`）后，顶部刷新控件无法归位，y 坐标从导航栏下方算起，而应与导航栏同一 y 轴起点。曾误用 `edgesForExtendedLayout = UIRectEdgeNone` 隐藏 objc-02 标题下透出的刷新头（f01ddb4），该做法改变了视图原点，已撤回。阅读代码未找到确定原因，且本机无法运行模拟器：新增 `testHeaderReturnsAfterFooterLoad` 与 `...WithNoMoreData`（demo 启动参数 `-noMoreData`），比较回到顶部后首个 item 与刷新头文字的位置是否与启动时一致，并在 CI（objc-02 Demo job）保存三步截图到 PR 截图评论。 | 先用 CI 截图和测试结果复现，再修复根因并让两个测试通过；截帧或录屏比对的闪烁测试；移植原 demo 其余页面。 |
| TODO — #1506 collection 大幅加载动画（25） | 仅验证能触发和结束刷新。 | 同 #1523 的视觉测试，确认是否同一根因。 |
| TODO — #1483 collection 连续刷新上移（50） | inset 恢复已修；刷新中反复拖动未复现。 | XCUITest 刷新中反复拖动并检查首项位置。 |
| TODO — #1481 trailer 转 footer 残留（85） | 需先移除 trailer；保留 trailer 的场景未确认。 | 获取切换代码后补用例。 |
| TODO — #1430 刷新后设 offset 跳首项（45） | 分页 footer 增长数据后仍偏移约 190 点，修复未完成。 | 修复偏移后在全屏分页 table 示例中通过真实上拉测试。 |
| TODO — #1317 搜索控制器 inset 递归（80） | 重入保护已覆盖四条路径；未在真实手势和 iOS 12.3 复现。 | XCUITest 搜索控制器 + 下拉刷新；iOS 12 真机。 |
| TODO — #1041 drawRect 内存（80） | 已删除 `drawRect:`；启动时机可能比旧实现早。 | 真机 Instruments 内存对比；转场与真实手势回归。 |
| TODO — #1623 自动加载 trailer（70） | 实现已加入 `CYLRefreshTrailer`，默认关闭；新增测试已在 CI 通过。阅读原 issue 核对期望（是否需要单独的 `CYLRefreshAutoTrailer` 类）；为拖拽次数限制补测试（需真实拖拽或 XCUITest）。已知差异：自动 footer 常驻底部 inset，trailer 未刷新时不占右侧 inset，因此只在越过内容末端（回弹区）时触发，而非提前预加载。已知风险：CI 曾在一次异常缓慢的 runner 上让本测试和既有的 `testReparentingActiveTrailerRestoresOldScrollView` 同时因 5 秒等待超时失败，重跑通过；若再次出现，应改为确定性地等待开始动画，而不是只延长超时。 | 横向 collection 示例中真实滑动验证一次拖拽只触发一次；核对原 issue 后更新分数。 |
| TODO — 国际化资源合并（译文待审校） | 资源合并、七种语言补齐、时间格式化已在 PR #20 CI（run 42739832343，f4d3ca1）全部 15 个 job 中验证：新增的 `testRefreshResourcesLiveInTheSingleLibraryBundle`、`testRefreshTrailerAndJapaneseTextsAreLocalized`、`testLastUpdatedTimeIsLocaleAwareAndComparesWholeDates` 及七种语言的占位测试通过，Carthage 与 `pod lib lint` 通过，四个示例截图已上传。剩余：新增的韩、俄、乌克兰、日文译文未经母语者审校。 | 请母语者审校译文后关闭。 |
| TODO — 内置动画资源与聚合 Demo（待人工查看） | PR #20 CI（run 42748403104，9d1b8e7）全部通过：`testBundledAnimationsAreListedValidAndAttributed` 通过（19 个文件均在构建产物中、文件头正确、有 NOTICE 条目）；Carthage、`pod lib lint`、framework 与 iOS 12 构建包含 `Animations/` 后通过；`Example-Scenarios` 经 `pod install`（CYLTabBarController 1.99.72 + LottieSwift/PAG/Rive/GIF）编译、在模拟器启动并上传 `example-screenshot-Examples-Example-Scenarios`。截图只证明首页启动；各场景页面和 19 个动画是否实际播放（尤其 Rive 的 `legacy` / `State Machine 1` 选项）尚未逐个查看。已知限制：占位动画只播放一次，没有循环选项（Demo 用定时器重播）；lottie-ios `Tests/Samples/LottieFiles/` 下 6 个文件原始来自 lottiefiles.com；Demo 文案尚未迁移到示例级 bundle（见下一条）。 | 在模拟器逐个打开“场景”和“动画”Tab 确认显示与播放；评估统一的循环选项 API。 |
| TODO — 聚合 Demo 文案本地化（CI 已通过，待译文审校） | 已迁移：`Examples/Example-Scenarios/Sources/CYLScenarioExample.bundle/<语言>.lproj/CYLScenarioExample.strings`（83 个 key × en、zh-Hans、zh-Hant、ja、ko、ru、uk），`CYLScenarioLocalization.h` 为每个 key 定义宏，`CYLScenarioLocalization.m` 按当前语言查找并回退英文；源码中的界面文案全部改为宏，API、文件名等技术提示保留为字面量。新增 `scripts/check_localizations.py`（CI job "Localization files"）检查全仓库 bundle 的 key、格式占位符、宏与 key 一致，以及没有游离的 `.strings`；已用 5 种人为错误验证能检出。CI run 42754589457 中 Localization files 与 Scenarios Demo 均通过；同次运行的 static PAG 套件 `testRiveDataBindingBooleanFollowsPlayback` 两次失败，原因是 10 秒的 Rive 加载等待在 runner 编译 Metal shader 时超时，之后的 nil 读数都由此导致，已把该文件的异步等待改为 `CYLTestTimeout`（30 秒）。CI run [42759261472](https://github.com/ChenYilong/CYLTableViewPlaceHolder/actions/runs/42759261472)（`9460eac`）全部 17 个 job 通过，含 static PAG 套件，并上传 5 个截图 artifact（`example-screenshot-Example`、`-Examples-Example-objc-01`、`-objc-02`、`-SwiftUI`、`-Scenarios`）；截图内容未在本地查看。剩余：新增日、韩、俄、乌克兰文译文未经母语者审校。 | 母语者审校译文；人工查看截图确认各语言界面。 |
| TODO — CI 示例截图内联显示（已在 CI 验证，objc-02 刷新头问题见 #1523） | 原因：截图一直在生成，但只能在运行页下载 zip，PR 与 job summary 中看不到。新增 `Example screenshots` job（`scripts/ci-publish-screenshots.sh`）把截图提交到 `ci-screenshots` 分支 `pr-<编号>/`，在 job summary 和一条原地更新的 PR 评论中内联显示；fork PR 只链接 artifact。CI run [42806497998](https://github.com/ChenYilong/CYLTableViewPlaceHolder/actions/runs/42806497998)（`0788a47`）全部 18 个 job 通过，PR #20 出现[截图评论](https://github.com/ChenYilong/CYLTableViewPlaceHolder/pull/20#issuecomment-6765692131)；已从分支取回并查看 5 张图（1206×2622）：主示例列表 + 黄色占位区、objc-01 collection 网格与“Ready”刷新头、objc-02 collection、Scenarios 首页（场景列表 + 带加号的 CYLTabBar）、SwiftUI “Refresh demo”。评论中的提交号原为 PR 的临时合并提交，已改为 head 提交。objc-02 截图中导航标题“Collection animation”与刷新头文字“Pull down to refresh”重叠：原因是 iOS 15 起导航栏在滚动边缘透明（iOS 26 为玻璃），布局在导航栏下方的 collection view 会透出位于内容上方的空闲刷新头；曾用 `edgesForExtendedLayout = UIRectEdgeNone` 隐藏，但这改变了视图的 y 轴起点，用户指出应与导航栏同一起点，已撤回；改为按 #1523 追踪（见该条 TODO）。objc-01 截图中刷新头同样透出（未与标题重叠），未改。其他已知问题：本地测试曾向 `ci-screenshots` 推送两个 1 字节假图（已被覆盖，仍在分支历史中，删除需用户操作）；分支历史持续增长需定期清理。 | 新 CI 截图中 objc-02 标题下不再出现刷新头文字；UI 测试 `CYLCollectionAnimationUITests` 仍通过；用户决定是否重建 `ci-screenshots` 分支。 |
| TODO — PR #1444 header inset 部分移植 | 拖拽时重新计算 inset 及 delta 语义未移植。 | 真实拖拽、旋转与悬浮 section header 测试。 |

### 上游刷新组件（未开始，0/100）

TODO — 以下 31 项尚未调查：#1627、#1625、#1624、#1615、#1614、#1613、#1607、#1600、#1598、#1597、#1595、#1592、#1591、#1590、#1585、#1583、#1582、#1572、#1571、#1570、#1568、#1564、#1540、#1535、#1507、#1238、#1146、#1067、#1029、#920、#862。每项需：阅读原 issue 与评论、在示例工程复现、修复或记录不修复的决定、补模拟器回归测试，再按上方规则评分。

已知 API 与范围决定（需维护者确认，不属于代码缺陷）：

- #1625 SPM：本仓库没有 `Package.swift`，只提供 CocoaPods 和 Carthage。是否支持 SPM 需单独决策；支持时须保留 refresh bundle、隐私清单和第三方许可证。
- #1570 纯 Swift 版本：建议不重写；改为审查公开头文件的 `NS_SWIFT_NAME` 与 nullability 标注，改善 Swift 调用体验。
- #1614 SwiftUI 兼容：建议在 #1628 修复后，以独立的可选子规格（iOS 13+）提供修饰符，重点覆盖加载更多；iOS 15+ 下拉刷新可用系统 `.refreshable`。
- #1582 按距离触发不同操作：现有 `pullingPercent` 与 `cyl_scrollDistance` 已可实现；建议先补示例与 README，必要时再增加 API。
- #1623 自动加载 trailer：已按上述方式实现为默认关闭的可选属性，见上方 TODO。
