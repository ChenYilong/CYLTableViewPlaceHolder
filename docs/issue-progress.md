# Issue 修复进度

更新时间：2026-11-08。分数是当前需求及验证完成程度的人工估计，不代表 GitHub issue 已关闭；只有实现和针对性验证均完成才记为 100。低于 100 分的条目列出至少三次实际调查、修复或验证尝试及剩余限制；这些尝试并不等于三轮独立代码修复。

| Issue 地址 | Issue 描述 | 修复近况 |
| --- | --- | --- |
| [#17](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/17) | 自定义占位位置，避免遮挡表头 | **100/100**：新增可选 frame 回调，保留默认全屏行为；模拟器回归验证表头不重叠。 |
| [#16](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/16) | 自定义表头及 section 时占位图被遮挡 | **65/100**：检查原 issue 与评论、增加可配置区域、测试 table header；原问题缺少 section 实现和复现步骤，尚未验证 section header 的实际层级及布局变化。 |
| [#15](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/15) | iPhone XR、XS、XS Max 适配 | **80/100**：检查原屏幕尺寸代码、改用容器 bounds、在 XS Max 模拟器检查占位图尺寸和缩放；本机无 XR/XS 模拟器，未完成两种机型的实机或模拟器验证。原 issue 已关闭。 |
| [#13](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/13) | 滚动选项返回 NO 时抛异常 | **100/100**：使用类型正确的 BOOL 协议调用；测试 YES、NO 和原滚动状态恢复。 |
| [#11](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/11) | UICollectionView 和普通页面适用范围 | **60/100**：检查提问、查阅库的 table 数据源实现、补充 README 说明；库仍不支持 UICollectionView 和普通页面，是否扩展为通用组件需要明确需求。 |
| [#10](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/10) | CocoaPods 链接失败 `library not found for -lPods` | **80/100**：原始构建发现缺少 Pods、尝试旧 Specs 源、改用 CDN 安装并成功构建 workspace；未取得报告者当时的 Podfile 与工程，无法证明其具体链接错误已解决。 |
| [#9](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/9) | 独立 UITableViewDataSource 不显示占位图 | **100/100**：增加 data source 回退，并保留 table view、delegate 优先级；模拟器测试独立 data source 和 delegate 优先级。 |
| [#8](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/8) | 占位图遮挡 MJRefresh footer | **75/100**：检查 MJRefresh footer 的动态位置、增加可配置区域、在模拟器使用真实 MJRefresh 自动 footer 验证非重叠；默认仍会覆盖 footer，应用需要结合实际布局计算区域，其他 footer 类型和滚动状态尚未覆盖。 |
| [#7](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/7) | 未实现 section 数量方法时空数据判断 | **100/100**：默认按一个 section 判断行数；模拟器测试默认 section 和后续 section 有数据的情况。 |
| [#6](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/6) | 再次空刷新后占位图消失 | **85/100**：检查历史修复、调整重复刷新逻辑、在 iOS 17.5 模拟器通过回归测试；原 issue 已关闭，但无法在最初的 iOS 9 环境复测。 |
| [#3](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/3) | 网络错误和无数据占位图无法切换 | **100/100**：每次空刷新重新请求视图，模拟器验证旧视图移除并显示新视图；PR #14 已合并。 |
| [#2](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/2) | 重复刷新导致占位图子视图消失 | **100/100**：相同视图不再反复移除，模拟器验证子视图保留；原 issue 已关闭。 |
| [#1](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/1) | “NewTableVIew”，内容仅为“下载到桌面” | **10/100**：检查原文和评论、搜索相关 issue、检查相关提交历史；均无法确定期望行为或复现方式，需报告者补充信息。原 issue 已关闭。 |

## 验证与决定

- PR [#14](https://github.com/ChenYilong/CYLTableViewPlaceHolder/pull/14) 的冲突已解决并合并。
- 回归测试通过 `ruby Tests/run-tests.rb` 运行；需要 Xcode、iOS 模拟器和 CocoaPods 的 `xcodeproj` Ruby gem。`DESTINATION` 可指定模拟器。安装 Pods 后会额外编译 MJRefresh 集成测试。
- iPhone 15 和 iPhone XS Max（iOS 17.5）上通过基础回归测试；旧 iOS 9、XR 和 XS 暂未验证。
- 安装 MJRefresh 3.1.15.3 后，在 iPhone 15（iOS 17.5）通过实际 footer 集成测试；该测试覆盖自定义区域而非默认行为。
- 默认仍让占位图覆盖 table view；需要保留 header/footer 的应用应实现 frame 回调，并根据实际布局更新它，避免改变现有用户的默认行为。

### 2026-11-08 刷新组件迁移

- 原外部刷新 Pod 已从示例工程移除，改为使用本仓库中的 `CYLRefresh` 源码；旧接口需迁移到 `CYL` 类名及 `cyl_` 分类接口。
- 最低系统版本调整为 iOS 12；原始组件版权、许可证及来源说明予以保留。历史测试结果保留在上文，新版本以当前回归测试为准。

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
| [#1623](https://github.com/CoderMJLee/MJRefresh/issues/1623) | 自动加载 trailer | 0/100：未调查，未修复。 |
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
| TODO — #16 section header 遮挡（65） | frame 回调已可避开 table header；缺少 section header 场景。需新增带自定义 section header 的回归用例，确认占位图与 section header 的层级和布局。 | 模拟器测试：自定义 `viewForHeaderInSection` 时占位图不遮挡 section header，旋转后仍正确。 |
| TODO — #15 XR/XS 适配（80） | 已改用容器 bounds，仅在 XS Max 上验证。 | 在 iPhone XR、iPhone XS 模拟器运行 `DESTINATION=... ruby Tests/run-tests.rb` 并记录结果。 |
| TODO — #11 UICollectionView / 普通页面（60） | 库只支持 table view。需维护者决定是否扩展为通用组件；若扩展，需新增 collection 分类并保持现有 API 不变。 | 决策记录；如实现，补 collection 空数据回归测试。 |
| TODO — #10 CocoaPods 链接失败（80） | 当前 CDN 安装可构建；缺报告者的 Podfile 与工程，无法证明原错误已解决。 | 获取原工程复现，或在 issue 中请报告者确认后关闭。 |
| TODO — #8 遮挡刷新 footer（75） | 默认仍覆盖 footer（保持兼容），只验证了自动 footer 的自定义区域。 | 补 back footer 与滚动中状态的回归测试；在 README 给出计算区域的示例。 |
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
| TODO — #1523 collection 动画选项闪烁（30） | 手势测试通过，但不检测闪烁；原视觉问题未复现。 | 截帧或录屏比对的视觉测试；移植原 demo 其余页面。 |
| TODO — #1506 collection 大幅加载动画（25） | 仅验证能触发和结束刷新。 | 同 #1523 的视觉测试，确认是否同一根因。 |
| TODO — #1483 collection 连续刷新上移（50） | inset 恢复已修；刷新中反复拖动未复现。 | XCUITest 刷新中反复拖动并检查首项位置。 |
| TODO — #1481 trailer 转 footer 残留（85） | 需先移除 trailer；保留 trailer 的场景未确认。 | 获取切换代码后补用例。 |
| TODO — #1430 刷新后设 offset 跳首项（45） | 分页 footer 增长数据后仍偏移约 190 点，修复未完成。 | 修复偏移后在全屏分页 table 示例中通过真实上拉测试。 |
| TODO — #1317 搜索控制器 inset 递归（80） | 重入保护已覆盖四条路径；未在真实手势和 iOS 12.3 复现。 | XCUITest 搜索控制器 + 下拉刷新；iOS 12 真机。 |
| TODO — #1041 drawRect 内存（80） | 已删除 `drawRect:`；启动时机可能比旧实现早。 | 真机 Instruments 内存对比；转场与真实手势回归。 |
| TODO — PR #1444 header inset 部分移植 | 拖拽时重新计算 inset 及 delta 语义未移植。 | 真实拖拽、旋转与悬浮 section header 测试。 |

### 上游刷新组件（未开始，0/100）

TODO — 以下 32 项尚未调查：#1627、#1625、#1624、#1623、#1615、#1614、#1613、#1607、#1600、#1598、#1597、#1595、#1592、#1591、#1590、#1585、#1583、#1582、#1572、#1571、#1570、#1568、#1564、#1540、#1535、#1507、#1238、#1146、#1067、#1029、#920、#862。每项需：阅读原 issue 与评论、在示例工程复现、修复或记录不修复的决定、补模拟器回归测试，再按上方规则评分。

已知 API 与范围决定（需维护者确认，不属于代码缺陷）：

- #1625 SPM：本仓库没有 `Package.swift`，只提供 CocoaPods 和 Carthage。是否支持 SPM 需单独决策；支持时须保留 refresh bundle、隐私清单和第三方许可证。
- #1570 纯 Swift 版本、#1614 SwiftUI 兼容、#1582 按距离触发不同操作、#1623 自动加载 trailer 属于新功能，需要先确定 API 设计和兼容性。
