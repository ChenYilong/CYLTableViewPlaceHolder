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
