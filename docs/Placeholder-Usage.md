# 占位视图用法参考 / Placeholder usage reference

<!-- bound-classes: CYLPlaceholderView, CYLPlaceholderStackView -->

<!-- docs-navigation:start -->

| 中文 | English |
| --- | --- |
| [自动占位视图（开发版本）](#自动占位视图开发版本--automatic-placeholder-view-development-version) | [Automatic placeholder view (development version)](#自动占位视图开发版本--automatic-placeholder-view-development-version) |
| [第一步：使用 CocoaPods 导入](#第一步使用-cocoapods-导入--step-1-install-with-cocoapods) | [Step 1: Install with CocoaPods](#第一步使用-cocoapods-导入--step-1-install-with-cocoapods) |
| [第二步：遵循协议](#第二步遵循协议--step-2-adopt-the-protocol) | [Step 2: Adopt the protocol](#第二步遵循协议--step-2-adopt-the-protocol) |
| [第三步：使用 cyl_reloadData 代替 reloadData](#第三步使用-cyl_reloaddata-代替-reloaddata--step-3-use-cyl_reloaddata-instead-of-reloaddata) | [Step 3: Use cyl_reloadData instead of reloadData](#第三步使用-cyl_reloaddata-代替-reloaddata--step-3-use-cyl_reloaddata-instead-of-reloaddata) |
| [适用于多种应用场景](#适用于多种应用场景--scenarios-it-fits) | [Scenarios it fits](#适用于多种应用场景--scenarios-it-fits) |

<!-- docs-navigation:end -->

<!-- docs-binding:start -->

| 类 / Class | 头文件 / Header |
| --- | --- |
| `CYLPlaceholderView` | [`CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderView.h`](../CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderView.h) |
| `CYLPlaceholderStackView` | [`CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderStackView.h`](../CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderStackView.h) |

<!-- docs-binding:end -->

| 中文 | English |
| --- | --- |
| 自 README 移入（2026-11-20）的占位视图参考：自动占位视图（block API）、`CYLPlaceholderView` 的初始化与配置项、内置动画资源与子规格、CocoaPods 安装细节、委托 API（`cyl_reloadData`）和应用场景示例。README 只保留快速开始；这里是完整说明，示例代码为 Swift。 | Placeholder reference moved from the README (2026-11-20): the automatic placeholder view (the block API), the initialization and configuration of `CYLPlaceholderView`, the bundled animation resources and subspecs, CocoaPods installation details, the delegate API (`cyl_reloadData`) and the scenario galleries. The README keeps only the quick start; this is the full description, with Swift sample code. |

## 自动占位视图（开发版本） / Automatic placeholder view (development version)

| 中文 | English |
| --- | --- |
| block API 支持 `UITableView` 和 `UICollectionView`，无需替换已有的 `reloadData`；`cyl_reloadData` 和 delegate API 同样可用。 | The block API supports `UITableView` and `UICollectionView` and does not require replacing existing `reloadData` calls; `cyl_reloadData` and the delegate API work as well. |

```swift
tableView.cylPlaceholderViewBlock({ tableView in
    tableView.isScrollEnabled = false
    return CYLPlaceholderView()
}, backToNormalBlock: { tableView in
    tableView.isScrollEnabled = true
})

// [CN] 取消自动占位；若占位视图正在显示，会调用恢复 block。
// [EN] Cancel the automatic placeholder; if one is showing, the restore block is called.
tableView.cylPlaceholderViewBlock(nil)
```

| 中文 | English |
| --- | --- |
| `UICollectionView` 使用同名接口和对应的 collection view block 参数。空状态以所有 section 的行或 item 数为准；没有 data source 时不显示占位。支持 `reloadData`、data source 更换、section/row/item 的插入、删除、刷新和移动、批量更新，以及 iOS 15 的 reconfigure 操作。更新会在主队列合并处理；请在主线程配置并更新 UI。占位视图使用 frame layout guide 约束，随列表可视区域及尺寸变化调整。 | `UICollectionView` uses the same interface with the matching collection view block parameters. Emptiness is judged by the number of rows or items across all sections; with no data source, no placeholder is shown. `reloadData`, data source replacement, insertion, deletion, reload and move of sections, rows and items, batch updates, and iOS 15 reconfigure operations are supported. Updates are coalesced on the main queue; configure and update the UI on the main thread. The placeholder view is constrained to the frame layout guide and follows changes of the list's visible area and size. |
| block 若引用控制器，请使用弱引用避免循环引用。内置 `CYLPlaceholderView` 的图片及多语言文本位于 `CYLTableViewPlaceHolder.bundle`，可自行调整其 imageView 和 textLabel。`CYLPlaceholderStyle` 提供 51 种离线图片，`CYLPlaceholderMessage` 提供 9 种可独立组合的提示；内置英文、简体中文、繁体中文、日文、韩文、俄文和乌克兰文，按应用语言选择并回退英文。初始化或自定义图片与文字： | If a block references the controller, use a weak reference to avoid a retain cycle. The images and localized text of the built-in `CYLPlaceholderView` are in `CYLTableViewPlaceHolder.bundle`, and you can adjust its imageView and textLabel. `CYLPlaceholderStyle` provides 51 offline images and `CYLPlaceholderMessage` provides 9 independently combinable messages; English, Simplified Chinese, Traditional Chinese, Japanese, Korean, Russian and Ukrainian are built in, chosen by the app language with a fallback to English. Initialize, or customize the image and text: |

```swift
let offline = CYLPlaceholderView(style: .noInternet, message: .noInternet)
let custom = CYLPlaceholderView(image: myImage, text: "自定义提示")
```

| 中文 | English |
| --- | --- |
| 传入 `nil` 图片或文字会隐藏相应内容。内置 Material 图标使用模板渲染，可通过 `imageView.tintColor` 自定义颜色；默认 Empty 图保持原样。可调用 `imageForStyle:`、`imageNameForStyle:` 和 `localizedTextForMessage:` 单独获取资源。内置图标及许可随资源包离线提供，不需要网络。示例中打开 **Auto → Styles**，点击样式和文案即可预览任意组合；也可输入自定义文案并体验自定义图片。 | Passing a `nil` image or text hides that part. The built-in Material icons are rendered as templates, so their color can be changed through `imageView.tintColor`; the default Empty image stays as it is. Call `imageForStyle:`, `imageNameForStyle:` and `localizedTextForMessage:` to get the resources individually. The built-in icons and their licenses ship offline in the resource bundle and need no network. In the example, open **Auto → Styles** and tap styles and messages to preview any combination; you can also enter custom text and try a custom image. |
| 资源包还提供 `CYLPlaceholderNoResults`、`CYLPlaceholderNoInternet`、`CYLPlaceholderError`、`CYLPlaceholderWarning` 和 `CYLPlaceholderInbox` 图标，分别适用于无搜索结果、无网络、错误、警告和空收件箱；它们不改变默认图片。可使用 `UIImage` 的 `imageNamed:inBundle:compatibleWithTraitCollection:` 从该资源包加载。图标来自 Google Material Design，许可及来源记录随资源包分发。 | The resource bundle also provides the icons `CYLPlaceholderNoResults`, `CYLPlaceholderNoInternet`, `CYLPlaceholderError`, `CYLPlaceholderWarning` and `CYLPlaceholderInbox`, for no search results, no network, error, warning and an empty inbox respectively; they do not change the default image. Load them from the bundle with `UIImage`'s `imageNamed:inBundle:compatibleWithTraitCollection:`. The icons come from Google Material Design, and their license and source records ship with the resource bundle. |
| 也可以用字典或本地 plist 创建 FlatDesign 风格的图片与标题组合： | You can also create FlatDesign-style image and title combinations from a dictionary or a local plist: |

```swift
let item: [String: Any] = [
    CYLPlaceholderItemStyle: CYLPlaceholderStyle.noInternet.rawValue,
    CYLPlaceholderItemMessage: CYLPlaceholderMessage.noInternet.rawValue,
    CYLPlaceholderItemImagePositionAdjustment: [8, -6],
    CYLPlaceholderItemTitlePositionAdjustment: [0, 6],
    CYLPlaceholderItemAnimationFilePath: "future-animation.json",
]
// [CN] 静态配置错误通过 throws 返回；或使用 CYLPlaceholderView(itemContentsOf:imageBundle:) 读取本地 plist。
// [EN] Static configuration errors are thrown; or read a local plist with CYLPlaceholderView(itemContentsOf:imageBundle:).
let view = try CYLPlaceholderView(itemAttributes: item, imageBundle: nil)
```

| 中文 | English |
| --- | --- |
| 配置项兼容 `CYLTabBarItemTitle`、`CYLTabBarItemImage`、`CYLTabBarItemImageInsets`、`CYLTabBarItemImagePositionAdjustment` 和 `CYLTabBarItemTitlePositionAdjustment` 的序列化名称；本库导出的常量使用 `CYLPlaceholderItem` 前缀，避免与 CYLTabBarController 冲突。图片可传 `UIImage` 或指定 bundle 中的图片名；bundle 为 nil 时使用本库资源包。显式图片和标题优先于预设样式和文案。偏移量支持 `[horizontal, vertical]`、包含 `horizontal`/`vertical` 或 `x`/`y` 的字典，以及代码传入的 `NSValue`；内边距支持四元素数组、`top`/`left`/`bottom`/`right` 字典或 `NSValue`。静态配置错误通过 `NSError` 返回，动画加载错误记录日志并回退；不加载网络资源。 | The configuration keys are compatible with the serialized names of `CYLTabBarItemTitle`, `CYLTabBarItemImage`, `CYLTabBarItemImageInsets`, `CYLTabBarItemImagePositionAdjustment` and `CYLTabBarItemTitlePositionAdjustment`; the constants this library exports use the `CYLPlaceholderItem` prefix to avoid clashing with CYLTabBarController. An image can be a `UIImage` or an image name in the given bundle; when the bundle is nil, this library's resource bundle is used. An explicit image and title take priority over the preset style and message. Offsets accept `[horizontal, vertical]`, a dictionary containing `horizontal`/`vertical` or `x`/`y`, and an `NSValue` passed from code; insets accept a four-element array, a `top`/`left`/`bottom`/`right` dictionary, or an `NSValue`. Static configuration errors are returned through `NSError`; animation loading errors are logged and fall back; no network resources are loaded. |
| 普通状态的文字、图标、背景颜色支持 `UIColor` 或 `#RGB`、`#RRGGBB`、`#RRGGBBAA`；文字字体支持 `UIFont`、字号、`bold:18` 或包含 `name`、`size`、`weight` 的字典。图片名也支持 `system:` SF Symbols。可配置无障碍标识、标签和提示。 | In the normal state, text, icon and background colors accept a `UIColor` or `#RGB`, `#RRGGBB`, `#RRGGBBAA`; the text font accepts a `UIFont`, a point size, `bold:18`, or a dictionary containing `name`, `size` and `weight`. Image names also support `system:` SF Symbols. The accessibility identifier, label and hint can be configured. |
| 可设置 `view.selected = YES` 使用 `CYLPlaceholderItemSelectedImage`、`CYLPlaceholderItemSelectedTitle` 以及选中态颜色和字体；恢复普通态时保留进入选中态前对普通图片、文字和样式的修改。选中状态设置 VoiceOver 的 selected trait。 | Set `view.selected = YES` to use `CYLPlaceholderItemSelectedImage`, `CYLPlaceholderItemSelectedTitle` and the selected-state colors and fonts; returning to the normal state keeps the changes made to the normal image, text and style before entering the selected state. The selected state sets VoiceOver's selected trait. |
| `CYLPlaceholderItemDarkImage` 和 `CYLPlaceholderItemSelectedDarkImage` 支持 `UIImage` 或资源名，按界面外观选择相应图片；只提供其中一个图片时，该图片作为所有外观的回退。 | `CYLPlaceholderItemDarkImage` and `CYLPlaceholderItemSelectedDarkImage` accept a `UIImage` or a resource name and choose the matching image by interface style; if only one of them is provided, it is used as the fallback for all appearances. |
| 设置 `selectionIndicatorImage` 可在选中项后方显示指示图，另可设置 `selectionIndicatorTintColor`。 | Set `selectionIndicatorImage` to show an indicator behind the selected item; `selectionIndicatorTintColor` can be set as well. |
| 角标可通过 `showBadgeWithStyle:value:` 选择隐藏、红点、数字或自定义文字；数字大于 99 显示为 `99+`，不大于 0 时隐藏。也可直接设置 `badgeValue`（`nil` 隐藏，空字符串显示红点）、`badgeCenterOffset` 和 `badgeLabel` 的字体与颜色。角标会作为占位视图的无障碍值；红点使用本地化的“有新内容”。占位视图本身不是无障碍元素时，角标标签可独立朗读；若外层容器本身是无障碍元素，应由调用方提供包含角标含义的标签或值。示例的 Styles 列表包含三种角标预览。 | A badge can be hidden, a red dot, a number or custom text through `showBadgeWithStyle:value:`; numbers above 99 show as `99+`, and a value not greater than 0 hides it. You can also set `badgeValue` directly (`nil` hides it, an empty string shows a red dot), `badgeCenterOffset`, and the font and color of `badgeLabel`. The badge becomes the placeholder view's accessibility value; the red dot uses the localized "New content". When the placeholder view itself is not an accessibility element, the badge label is read on its own; if the outer container is an accessibility element, the caller should provide a label or value that includes the badge's meaning. The Styles list in the example includes three badge previews. |
| 图片与标题作为一个居中的整体布局；item 内移植 FlatDesign 的图片和标题定位、图片原始尺寸及偏移计算，长文案在可用宽度内换行；只有图片或文字时单独居中。图片与标题可分别设置偏移。通过 `CYLPlaceholderItemGIFURL` 或 `CYLPlaceholderItemGIFFilePath` 可传入本地 GIF；`CYLPlaceholderItemGIFSize` 支持 `[width, height]`、尺寸字典或 `NSValue`。GIF 在进入窗口时播放一次，离开窗口时停止；启用“减弱动态效果”时保持首帧。GIF 不支持网络地址。GIF 输入最大 16 MB、最多 500 帧，解码帧合计最多 64 MB；无效资源或超限时记录错误并保留静态占位图。 | The image and title are laid out as one centered unit; the item ports FlatDesign's image and title positioning, original image size and offset calculation, and long text wraps within the available width; with only an image or only text, it is centered on its own. The image and title can be offset separately. A local GIF can be passed through `CYLPlaceholderItemGIFURL` or `CYLPlaceholderItemGIFFilePath`; `CYLPlaceholderItemGIFSize` accepts `[width, height]`, a size dictionary or an `NSValue`. A GIF plays once when it enters the window and stops when it leaves; with Reduce Motion enabled it stays on the first frame. GIF does not support network URLs. A GIF input can be at most 16 MB and 500 frames, and the decoded frames total at most 64 MB; an invalid or oversized resource logs an error and keeps the static placeholder image. |
| 可通过 `playPlaceholderAnimation`、`stopPlaceholderAnimation` 和 `showPlaceholderAnimationLastFrame` 重播、停止或显示末帧；停止状态在离开并重新进入窗口后保留。Rive 状态机没有通用末帧，显示其静止状态。`setPlaceholderAnimationProgress:` 可暂停并定位 Lottie 或 PAG 到 0–1 的进度；`setPlaceholderAnimationSpeed:` 可设置 Lottie 的正数播放速度。方法返回 `NO` 表示参数无效或当前后端不支持；PAG 定位到最近的帧。显式进度和速度在支持的后端重新加载时会尝试恢复。 | `playPlaceholderAnimation`, `stopPlaceholderAnimation` and `showPlaceholderAnimationLastFrame` replay, stop, or show the last frame; the stopped state is kept after leaving and re-entering the window. A Rive state machine has no general last frame, so its resting state is shown. `setPlaceholderAnimationProgress:` pauses and seeks Lottie or PAG to a progress between 0 and 1; `setPlaceholderAnimationSpeed:` sets a positive playback speed for Lottie. A method returns `NO` when the argument is invalid or the current backend does not support it; PAG seeks to the nearest frame. Explicit progress and speed are restored when a supported backend reloads. |
| `CYLPlaceholderView`（图标 + 标题的封装组件）继承 `CYLAnimatedItem` pod 的 `CYLAnimatedItemView`（位于 CYLTabBarController 仓库，不依赖 TabBar；[接入文档](https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md)）。`Core` 只依赖 `CYLAnimatedItem/Core`，不依赖任何动效引擎：只显示静态图片。只有在应用（例如 example）引入下列动画子规格时才播放动效；每个子规格引入引擎（`CYLAnimatedItem/Engine`）与一种 animator（`CYLAnimatedItem/<类型>`），无需注册。显示优先级：动画能播放时显示动画；不能播放（没有引擎或动画库、文件不存在 / 为空 / 损坏、下载失败、解析错误）时显示传入的静态图片；没有静态图片时显示组件的占位图（`CYLAnimatedItem.bundle`）。URL 动效下载期间先显示静态图片。各平台改造进度、评分与 TODO：[Animated-Item-Migration.md](Animated-Item-Migration.md)。 | `CYLPlaceholderView` (the packaged icon + title view) is a subclass of `CYLAnimatedItemView` from the `CYLAnimatedItem` pod (it lives in the CYLTabBarController repository and does not depend on the tab bar; [integration guide](https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md)). `Core` depends only on `CYLAnimatedItem/Core` and on no animation engine: it shows static images. Animations play only when the app (an example, say) adds one of the animation subspecs below; each adds the engine (`CYLAnimatedItem/Engine`) and one animator (`CYLAnimatedItem/<Type>`), with nothing to register. Display priority: the animation when it can play; otherwise (no engine or library, a missing, empty or corrupted file, a failed download, a parse error) the static image passed in; without one, the component placeholder (`CYLAnimatedItem.bundle`). While a URL file downloads, the static image shows. Migration status per platform, score and TODOs: [Animated-Item-Migration.md](Animated-Item-Migration.md). |

| 子规格 | 依赖 | 最低系统 | 说明 |
| --- | --- | --- | --- |
| `Core`（默认） | `CYLAnimatedItem/Core` | iOS 15 | 占位视图、列表集成、HUD、CYLRefresh；静态图片，不含动效引擎 |
| `LottieSwift`（`Lottie` 为别名） | `CYLAnimatedItem/LottieSwift`（`lottie-ios` ≥ 4.5.1） | iOS 15 | Lottie 动效 |
| `PAG` / `PAGEnterprise` | `CYLAnimatedItem/PAG` / `…PAGEnterprise`（`libpag` / `libpag-enterprise`） | iOS 15 | 二选一，不能同时引入 |
| `Rive` | `CYLAnimatedItem/Rive`（`RiveRuntime` ~> 6.29） | iOS 15 | Rive 动效；Rive 刷新头 `CYLRefresh/Custom/Rive/` |
| `SVGA` | `CYLAnimatedItem/SVGA`（`SVGAPlayerLite`） | iOS 15 | SVGA 动效 |
| `GIF` | `CYLAnimatedItem/GIF`（ImageIO） | iOS 15 | GIF 动效；未引入时 GIF 显示为静态图片 |

| Subspec | Dependency | Minimum OS | Notes |
| --- | --- | --- | --- |
| `Core` (default) | `CYLAnimatedItem/Core` | iOS 15 | Placeholder views, list integration, HUD, CYLRefresh; static images, no animation engine |
| `LottieSwift` (`Lottie` is an alias) | `CYLAnimatedItem/LottieSwift` (`lottie-ios` ≥ 4.5.1) | iOS 15 | Lottie animations |
| `PAG` / `PAGEnterprise` | `CYLAnimatedItem/PAG` / `…PAGEnterprise` (`libpag` / `libpag-enterprise`) | iOS 15 | Choose one; they cannot be included together |
| `Rive` | `CYLAnimatedItem/Rive` (`RiveRuntime` ~> 6.29) | iOS 15 | Rive animations; the Rive refresh header, `CYLRefresh/Custom/Rive/` |
| `SVGA` | `CYLAnimatedItem/SVGA` (`SVGAPlayerLite`) | iOS 15 | SVGA animations |
| `GIF` | `CYLAnimatedItem/GIF` (ImageIO) | iOS 15 | GIF animations; without it a GIF shows as a static image |

```ruby
# [CN] CYLAnimatedItem pod 尚未发布到 CocoaPods trunk：按 commit 从 CYLTabBarController 仓库引入（Cartfile 固定的最新 commit）。
# [EN] The CYLAnimatedItem pod is not on the CocoaPods trunk yet: take it from the CYLTabBarController repository by commit (the newest, pinned in the Cartfile).
pod 'CYLAnimatedItem', :git => 'https://github.com/ChenYilong/CYLTabBarController.git', :commit => '<sha>'
pod 'CYLTableViewPlaceHolder', :subspecs => ['Core', 'LottieSwift', 'PAG', 'Rive', 'GIF']
```

### 内置动画资源 / Built-in animation resources

| 中文 | English |
| --- | --- |
| `CYLTableViewPlaceHolder.bundle/Animations/` 随 `Core` 提供 40 个按场景命名的动画和 22 个刷新图标动画 `CYLRefresh*`（共约 480 KB），可直接用于占位图；播放需要引入对应的动画子规格（GIF 也一样），否则显示静态图片： | `CYLTableViewPlaceHolder.bundle/Animations/` ships 40 scenario-named animations and 22 refresh icon animations `CYLRefresh*` with `Core` (about 480 KB in total) that can be used directly as placeholders; playing them needs the matching animation subspec (GIF too); without it the static image shows: |

| 格式 | 文件 | 场景 |
| --- | --- | --- |
| Lottie (`.json`) | `CYLPlaceholderLoading`、`LoadingInfinity`、`Empty`、`EmptyCart`、`NoDrafts`、`NoFavorites`、`Location`、`Success`、`Celebrate` | 加载、同步、空列表、空购物车、无草稿、无收藏、定位、成功、完成 |
| PAG (`.pag`) | `CYLPlaceholderLoading`、`NoFavorites`、`PullHint`、`Progress` | 加载、无点赞、下拉提示、处理中 |
| Rive (`.riv`) | `CYLPlaceholderLoading`、`PullToRefresh`、`Success` | 加载、下拉刷新、成功 |
| GIF (`.gif`) | `CYLPlaceholderUploading`、`NoFavorites` | 上传中、暂无收藏 |
| Lottie 线条图标 (`.json`) | `CYLPlaceholderNoInternet`、`LoadFailed`、`ServerError`、`Refresh`、`NoResults`、`NoPermission`、`ContactSupport`、`NoMessages`、`NoNotifications`、`Sad`、`CloudOff`、`TapHint`、`Settings`、`NoOrders`；权限：`LocationPermission`、`CameraPermission`、`PhotoLibraryPermission`、`MicrophonePermission`、`ContactsPermission`、`CalendarPermission`、`BluetoothPermission`、`NotificationPermission` | 无网络、加载失败、服务器错误、刷新、无结果、无权限、联系客服、无消息、无通知、难过、云端不可用、点击提示、设置、暂无订单（包裹）；定位、相机、相册、麦克风、通讯录、日历、蓝牙、通知权限缺失（场景占位使用） |

| Format | Files | Scenarios |
| --- | --- | --- |
| Lottie (`.json`) | `CYLPlaceholderLoading`, `LoadingInfinity`, `Empty`, `EmptyCart`, `NoDrafts`, `NoFavorites`, `Location`, `Success`, `Celebrate` | Loading, syncing, empty list, empty cart, no drafts, no favorites, location, success, done |
| PAG (`.pag`) | `CYLPlaceholderLoading`, `NoFavorites`, `PullHint`, `Progress` | Loading, no likes, pull-down hint, processing |
| Rive (`.riv`) | `CYLPlaceholderLoading`, `PullToRefresh`, `Success` | Loading, pull to refresh, success |
| GIF (`.gif`) | `CYLPlaceholderUploading`, `NoFavorites` | Uploading, no favorites |
| Lottie line icons (`.json`) | `CYLPlaceholderNoInternet`, `LoadFailed`, `ServerError`, `Refresh`, `NoResults`, `NoPermission`, `ContactSupport`, `NoMessages`, `NoNotifications`, `Sad`, `CloudOff`, `TapHint`, `Settings`, `NoOrders`; permissions: `LocationPermission`, `CameraPermission`, `PhotoLibraryPermission`, `MicrophonePermission`, `ContactsPermission`, `CalendarPermission`, `BluetoothPermission`, `NotificationPermission` | No internet, load failed, server error, refresh, no results, no permission, contact support, no messages, no notifications, sad, cloud off, tap hint, settings, no orders (a parcel); missing location, camera, photo, microphone, contacts, calendar, Bluetooth and notification permissions (used by the scenario placeholders) |

```swift
let path = CYLPlaceholderView.path(forBundledAnimation: "CYLPlaceholderLoading.json") ?? ""
let loading = try CYLPlaceholderView(itemAttributes: [
    CYLPlaceholderItemTitle: "加载中",
    // [CN] 动画加载前或缺少子规格时显示的图片
    // [EN] The image shown before the animation loads, or when the subspec is missing
    CYLPlaceholderItemStyle: CYLPlaceholderStyle.hourglass.rawValue,
    CYLPlaceholderItemAnimationFilePath: path,
    CYLPlaceholderItemAnimationSize: [180, 180],
], imageBundle: nil)
```

| 中文 | English |
| --- | --- |
| 只收录内容本身表示占位状态的动画（加载、进度、空、无结果、无网络或请求失败、权限缺失、占位图提供的操作、完成），不收录吉祥物、场景或控件演示。`+bundledAnimationFileNames` 列出全部文件名。文件均下载自开源仓库且未修改：Lottie 来自 `airbnb/lottie-ios`（Apache-2.0），PAG 来自 `Tencent/libpag`（Apache-2.0），Rive 来自 `rive-app/rive-ios`（MIT），GIF 来自 CYLTabBarController（MIT），线条图标来自 `useAnimations/react-useanimations`（MIT）；逐个文件的来源路径、提交和 SHA-256 记录在 `Animations/NOTICE.animations`，许可证全文随资源包分发。占位动画按 tab 图标的方式只播放一次，尚无循环选项；需要持续播放时可定时调用 `playPlaceholderAnimation`（聚合 Demo 即如此）。 | Only animations whose content means a placeholder state are bundled (loading, progress, empty, no results, no network or a failed request, a missing permission, an action the placeholder offers, done); mascots, scenes and widget demos are not. `+bundledAnimationFileNames` lists all the file names. The files are all downloaded unmodified from open-source repositories: Lottie from `airbnb/lottie-ios` (Apache-2.0), PAG from `Tencent/libpag` (Apache-2.0), Rive from `rive-app/rive-ios` (MIT), GIF from CYLTabBarController (MIT), and the line icons from `useAnimations/react-useanimations` (MIT); each file's source path, commit and SHA-256 are recorded in `Animations/NOTICE.animations`, and the full license texts ship with the resource bundle. A placeholder animation plays only once, the way tab icons do, and there is no loop option yet; to keep one playing, call `playPlaceholderAnimation` on a timer (the aggregate demo does this). |
| 每种动画类型的 animator 都在 CYLTabBarController 的引擎中（`CYLTabBarItemAnimatorRegistry`），本库不再自带引擎。应用可向 `CYLTabBarItemAnimatorRegistry` 注册自己的 animator（新增动画类型只改这个组件），或用 `+[CYLPlaceholderView registerAnimationFactory:forFileExtension:]` 按扩展名注册工厂（需要引擎；没有引擎时返回 NO，注册是全局的，也作用于 TabBar）。 | Every animation type's animator lives in CYLTabBarController's engine (`CYLTabBarItemAnimatorRegistry`); this library no longer has an engine of its own. An app can register its own animator with `CYLTabBarItemAnimatorRegistry` (a new animation type changes only that component), or a factory per file extension with `+[CYLPlaceholderView registerAnimationFactory:forFileExtension:]` (needs the engine; returns NO without one; the registration is global, so it applies to tab bars too). |
| 对应的 `CYLPlaceholderItemLottieFilePath`、`CYLPlaceholderItemPAGFilePath`、`CYLPlaceholderItemRiveFilePath` 或通用动画路径可指定本地文件或 URL；支持对应的尺寸键（动画尺寸即图标尺寸，没有引擎时布局不变）。动画 URL 与路径支持各格式对应的 `DarkURL`/`DarkFilePath`，深浅色切换时重新加载。`CYLPlaceholderItemAnimationOptions` 以 URL fragment 传给 CYLTabBarController 的 animator（Rive 的 `artboard`、`stateMachine` 等由其 Rive animator 解释）。Rive 的数据绑定与旧版输入不再有本库的测试。 | The matching `CYLPlaceholderItemLottieFilePath`, `CYLPlaceholderItemPAGFilePath`, `CYLPlaceholderItemRiveFilePath` or the generic animation path can name a local file or a URL, and the matching size keys are supported (the animation size is the icon size, so the layout is the same without an engine). Animation URLs and paths support the matching `DarkURL`/`DarkFilePath` of each format, and the animation reloads when switching between light and dark. `CYLPlaceholderItemAnimationOptions` reach CYLTabBarController's animators as a URL fragment (Rive's `artboard`, `stateMachine` and so on are read by its Rive animator). Rive data binding and legacy inputs are no longer tested by this library. |
| Carthage：`Cartfile` 固定 CYLTabBarController 的最新 commit，framework target 链接 `Carthage/Build/CYLTabBarController.xcframework` 与 `CYLAnimatedItem.xcframework`（由 `scripts/cyltabbarcontroller-xcframework.sh` 生成；`carthage bootstrap` 目前无法构建 CYLTabBarController：Carthage 会列出其 checkout 中所有 Xcode 工程，其 Flutter 示例需要生成的 Swift 包）。CYLTabBarController 的 framework 总是包含动效引擎（`CYL_ANIMATION_ENGINE_AVAILABLE` 为 1），只有 CocoaPods 能做到不引入动效引擎、只显示静态图片；Lottie、PAG、Rive、SVGA 的 animator 只通过 CocoaPods 提供。`CYLPlaceholderItemAnimationOptions` 的 `contentMode`（数值或 `scaleAspectFit` 等名称）对所有动画库生效，`animationSpeed` 设置初始播放速度。选项值必须是字符串或数字。重复次数大于 1 时，Lottie 与 PAG 按次数播放；GIF、Rive、SVGA 在引擎中没有循环或进度控制，按文件本身播放。 | Carthage: the `Cartfile` pins CYLTabBarController's newest commit and the framework target links `Carthage/Build/CYLTabBarController.xcframework` and `CYLAnimatedItem.xcframework` (built by `scripts/cyltabbarcontroller-xcframework.sh`; `carthage bootstrap` cannot build CYLTabBarController yet: Carthage lists every Xcode project in its checkout, and its Flutter example needs generated Swift packages). CYLTabBarController's framework always includes the animation engine (`CYL_ANIMATION_ENGINE_AVAILABLE` is 1); only CocoaPods leaves the engine out and shows static images only. The Lottie, PAG, Rive and SVGA animators come through CocoaPods only. The `contentMode` of `CYLPlaceholderItemAnimationOptions` (a number or a name such as `scaleAspectFit`) applies to all animation libraries, and `animationSpeed` sets the initial playback speed. Option values must be strings or numbers. With a repeat count above 1, Lottie and PAG play that many times; GIF, Rive and SVGA have no loop or progress control in the engine and play as their file defines. |
| Lottie 支持 `CYLPlaceholderItemAnimationColors`、`CYLPlaceholderItemAnimationDarkColors` 以及 `CYLPlaceholderItemLottieDarkColors`：字典的键是 Lottie keypath，值为 `UIColor` 或十六进制颜色字符串。深色配置覆盖普通配置，格式专属配置优先。Rive 支持 `CYLPlaceholderItemAnimationColors`、`CYLPlaceholderItemRiveDarkColors`，键为 view model 颜色属性路径；`color` 选项设置浅色颜色。自定义播放器可实现 `setAnimationColors:`；PAG 与 GIF 与 CYLTabBarController 一样不支持颜色覆盖。Lottie keypath 颜色已通过渲染像素测试验证。 | Lottie supports `CYLPlaceholderItemAnimationColors`, `CYLPlaceholderItemAnimationDarkColors` and `CYLPlaceholderItemLottieDarkColors`: the dictionary keys are Lottie keypaths and the values are a `UIColor` or a hexadecimal color string. Dark configuration overrides the normal one, and format-specific configuration takes priority. Rive supports `CYLPlaceholderItemAnimationColors` and `CYLPlaceholderItemRiveDarkColors`, with view model color property paths as keys; the `color` option sets the light color. A custom player can implement `setAnimationColors:`; PAG and GIF, like CYLTabBarController, do not support color overrides. Lottie keypath colors have been verified with a rendered-pixel test. |
| `itemAttributes` 保留传入的其他键，供将来使用；其他未实现的 TabBar 配置目前不会生效。示例 **Auto → Styles** 底部提供代码和 plist 两种配置演示。布局参考 CYLTabBarController；其 MIT 许可随资源包提供。 | `itemAttributes` keeps the other keys that are passed in, for future use; other TabBar settings that are not implemented have no effect for now. The example **Auto → Styles** shows both the code and the plist configuration at the bottom. The layout follows CYLTabBarController; its MIT license ships with the resource bundle. |
| 实现通过 method swizzling 拦截 UIKit 方法，影响进程中对应类的方法分发；未启用 block 的列表不安装占位视图。子类覆盖更新方法而不调用 `super`、以及 diffable data source 的内部更新不保证触发检查。示例应用右上角的 **Auto** 可体验两种列表、数据更新及取消功能。不要在同一个列表上同时依赖旧 API 与新 API；启用新 API 会移除旧占位视图。 | The implementation intercepts UIKit methods with method swizzling, which affects the method dispatch of those classes in the process; lists that have not enabled the block do not install a placeholder view. Subclasses that override the update methods without calling `super`, and the internal updates of a diffable data source, are not guaranteed to trigger the check. **Auto** at the top right of the example app lets you try both kinds of list, data updates and cancellation. Do not rely on both the old and the new API on the same list; enabling the new API removes the old placeholder view. |
| 开发版本可用 CocoaPods 本地路径或 Git 分支集成，例如 `pod 'CYLTableViewPlaceHolder', :path => '../CYLTableViewPlaceHolder'`。Carthage 可使用 `github "ChenYilong/CYLTableViewPlaceHolder" "<branch-or-commit>"`，以 `carthage update --use-xcframeworks --platform iOS` 构建，将 `CYLTableViewPlaceHolder.xcframework` 链接并嵌入应用；资源 bundle 已包含在 framework 中。 | A development version can be integrated with a CocoaPods local path or a Git branch, for example `pod 'CYLTableViewPlaceHolder', :path => '../CYLTableViewPlaceHolder'`. Carthage can use `github "ChenYilong/CYLTableViewPlaceHolder" "<branch-or-commit>"`, built with `carthage update --use-xcframeworks --platform iOS`; link and embed `CYLTableViewPlaceHolder.xcframework` in the app; the resource bundle is already included in the framework. |

## 第一步：使用 CocoaPods 导入 / Step 1: Install with CocoaPods

| 中文 | English |
| --- | --- |
| 在 `Podfile` 中进行如下导入： | Add the following to your `Podfile`: |

```ruby
pod 'CYLTableViewPlaceHolder', '~> 1.1.0'
```

| 中文 | English |
| --- | --- |
| 本库内置刷新组件 `CYLRefresh`，无需添加其他刷新库。最低支持 **iOS 15**。 | The library includes the refresh component `CYLRefresh`; no other refresh library is needed. It supports **iOS 15** and later. |
| 开发版本也可通过 Git 分支或本地 `:path` 集成。分页刷新等已知限制及验证状态见 [`issue-progress.md`](issue-progress.md)。 | A development version can also be integrated through a Git branch or a local `:path`. Known limitations such as paging refresh, and their verification status, are in [`issue-progress.md`](issue-progress.md). |
| 然后使用 `cocoaPods` 进行安装。如果尚未安装 CocoaPods，运行以下命令进行安装： | Then install with `cocoaPods`. If CocoaPods is not installed yet, run this command: |

```sh
gem install cocoapods
```

| 中文 | English |
| --- | --- |
| 安装成功后就可以安装依赖了。建议使用如下方式： | Once it is installed you can install the dependencies. The following is recommended: |

```sh
# [CN] 禁止升级 CocoaPods 的 spec 仓库，否则会卡在 Analyzing dependencies，非常慢
# [EN] Do not update the CocoaPods spec repo, or it hangs at "Analyzing dependencies" and is very slow
pod update --verbose --no-repo-update
```

| 中文 | English |
| --- | --- |
| 如果提示找不到库，则可去掉 `--no-repo-update`： | If it says the library cannot be found, remove `--no-repo-update`: |

```sh
pod update
```

| 中文 | English |
| --- | --- |
| 如果链接时报 `ld: library not found for -lPods`（见 [#10](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/10)），通常是工程与 Pods 的集成状态不一致，而不是本库的问题： | If linking reports `ld: library not found for -lPods` (see [#10](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/10)), it is usually an inconsistent integration state between the project and Pods, not a problem of this library: |
| 1. 用 `pod install` 生成的 `.xcworkspace` 打开工程，不要直接打开 `.xcodeproj`。 | 1. Open the project through the `.xcworkspace` generated by `pod install`, not the `.xcodeproj`. |
| 2. `Podfile` 须保持为纯文本（UTF-8）且文件名就是 `Podfile`；改过扩展名或编码后，应确认已恢复。 | 2. The `Podfile` must be plain text (UTF-8) and named exactly `Podfile`; if you changed its extension or encoding, make sure it is restored. |
| 3. 重新集成并清理缓存： | 3. Re-integrate and clear the caches: |

```sh
pod deintegrate
pod install
rm -rf ~/Library/Developer/Xcode/DerivedData
```

| 中文 | English |
| --- | --- |
| 然后在 Xcode 中执行 Product › Clean Build Folder 后重新编译。 | Then run Product › Clean Build Folder in Xcode and build again. |

## 第二步：遵循协议 / Step 2: Adopt the protocol

| 中文 | English |
| --- | --- |
| 导入头文件： | Import the header: |

```swift
import CYLTableViewPlaceHolder
```

| 中文 | English |
| --- | --- |
| 遵循协议： | Adopt the protocol: |

```swift
class ViewController: UIViewController, CYLTableViewPlaceHolderDelegate {
    // ...
}
```

| 中文 | English |
| --- | --- |
| 实现协议方法。仅一个必须实现的协议方法：创建一个自定义的占位视图并返回。 | Implement the protocol methods. Only one is required: create a custom placeholder view and return it. |

```swift
// [CN] 唯一必须实现的协议方法：创建占位视图并返回（Objective-C 选择器名 makePlaceHolderView）。
// [EN] The only required protocol method: create and return the placeholder view (Objective-C selector makePlaceHolderView).
@objc(makePlaceHolderView) func makePlaceHolderView() -> UIView {
    CYLPlaceholderView(style: .empty, message: .empty)
}
```

| 中文 | English |
| --- | --- |
| 这里注意两点： | Note two points: |
| 1. 默认占位视图填满 table view 的 bounds，宽高随 table view 调整。每次空数据刷新都会重新调用 `makePlaceHolderView`，因此可以切换网络错误与无数据视图。 | 1. The default placeholder view fills the table view's bounds, and its width and height follow the table view. `makePlaceHolderView` is called again on every empty-data refresh, so you can switch between a network error view and a no-data view. |
| 2. `makePlaceHolderView` 可由自定义 table view、delegate 或独立的 data source 实现，按此顺序查找；应返回非空视图。 | 2. `makePlaceHolderView` can be implemented by a custom table view, the delegate, or a separate data source, looked up in that order; it should return a non-nil view. |
| 如果表头或刷新 footer 需要保持可见，可在提供占位图的对象中实现可选方法，返回 table view 坐标系中的区域；每次布局需求变化时调用 `cyl_reloadData` 更新区域： | If the table header or the refresh footer must stay visible, implement the optional method in the object that provides the placeholder and return a region in the table view's coordinate system; call `cyl_reloadData` whenever the layout needs change, to update the region: |

```swift
// [CN] 可选：占位图的区域（table view 坐标系），保留表头可见
// [EN] Optional: the placeholder's region in the table view's coordinate system, keeping the table header visible
@objc(frameForPlaceHolderViewInTableView:)
func frameForPlaceHolderView(in tableView: UITableView) -> CGRect {
    let top = tableView.tableHeaderView?.frame.maxY ?? 0
    return CGRect(x: 0, y: top, width: tableView.bounds.width, height: max(0, tableView.bounds.height - top))
}
```

| 中文 | English |
| --- | --- |
| 自定义 frame 不会自动跟随尺寸变化，必要时请为返回的视图设置 autoresizing mask，或在布局变化后重新加载。对于 section header 和刷新 footer，需根据它们在 table view 内容坐标系中的实际 frame 计算不重叠区域；空数据时自动 footer 不一定在屏幕底部。占位图位于其 frame 内其他子视图之上，但 `CYLRefresh`（以及仍在使用的 `MJRefresh`）的 header、footer 和 trailer 始终保持在占位图之上，因此默认全屏占位时刷新控件也不会被遮挡（[#8](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/8)）；旧版 block API 和 `cyl_reloadData` 均如此。 | A custom frame does not follow size changes automatically; if needed, set an autoresizing mask on the returned view, or reload after layout changes. For section headers and refresh footers, compute the non-overlapping region from their actual frames in the table view's content coordinate system; with empty data the automatic footer is not necessarily at the bottom of the screen. The placeholder sits above the other subviews within its frame, but the headers, footers and trailers of `CYLRefresh` (and of `MJRefresh`, if you still use it) always stay above the placeholder, so refresh controls are not covered by a full-screen placeholder by default ([#8](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/8)); this holds for the old block API and `cyl_reloadData` alike. |
| 例如，在使用 `CYLRefreshAutoNormalFooter` 且 footer 位于内容顶部的场景中，可将占位图放在 footer 之后： | For example, with `CYLRefreshAutoNormalFooter` where the footer is at the top of the content, the placeholder can be placed after the footer: |

```swift
@objc(frameForPlaceHolderViewInTableView:)
func frameForPlaceHolderView(in tableView: UITableView) -> CGRect {
    let top = tableView.cylFooter?.frame.maxY ?? 0
    return CGRect(x: 0, y: top, width: tableView.bounds.width, height: max(0, tableView.bounds.height - top))
}
```

| 中文 | English |
| --- | --- |
| 此示例不是所有布局的通用解：footer 位置变化后应重新计算；若还有表头或 section header，也需结合它们的实际位置。 | This example is not a general solution for every layout: recompute it after the footer position changes; if there is also a table header or section headers, take their actual positions into account too. |
| 有自定义 section header 时（[#16](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/16)），可从最后一个 section header 的底部开始放置占位图；`rectForHeaderInSection:` 已包含表头高度。调用该回调前库会先布局 table view，因此读到的是最终位置（包括 iOS 15 起 plain 样式的 section header 顶部间距）；旋转或尺寸变化后再次调用 `cyl_reloadData` 即可重新计算： | With custom section headers ([#16](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/16)), place the placeholder starting at the bottom of the last section header; `rectForHeaderInSection:` already includes the table header height. The library lays out the table view before calling this callback, so the values read are the final positions (including the top spacing of plain-style section headers since iOS 15); calling `cyl_reloadData` again after a rotation or size change recomputes it: |

```swift
@objc(frameForPlaceHolderViewInTableView:)
func frameForPlaceHolderView(in tableView: UITableView) -> CGRect {
    let lastSection = tableView.numberOfSections - 1
    let top = lastSection >= 0 ? tableView.rectForHeader(inSection: lastSection).maxY : 0
    return CGRect(x: 0, y: top, width: tableView.bounds.width, height: max(0, tableView.bounds.height - top))
}
```

| 中文 | English |
| --- | --- |
| 既可以让代理遵循协议，实现协议方法： | You can let the delegate adopt the protocol and implement the methods: |

```swift
class ViewController: UIViewController, CYLTableViewPlaceHolderDelegate { /* ... */ }
```

| 中文 | English |
| --- | --- |
| 也可以让自定义的 `TableView` 遵循协议，实现协议方法： | Or let your custom `TableView` adopt the protocol and implement the methods: |

```swift
class MyTableView: UITableView, CYLTableViewPlaceHolderDelegate { /* ... */ }
```

| 中文 | English |
| --- | --- |
| 这里推荐在自定义的 `TableView` 中实现，以降低耦合性，同时也可以为 Controller 瘦身。 | Implementing it in a custom `TableView` is recommended: it lowers coupling and also slims down the controller. |
| 占位视图的点击事件等，请自行在 `- (UIView *)makePlaceHolderView;` 中所创建的 View 中实现。 | Implement tap handling and the like yourself in the view created in `- (UIView *)makePlaceHolderView;`. |
| 另外，占位视图默认的设置是不能滚动的，也就不能下拉刷新了，但是如果想让占位视图可以滚动，则需要实现下面的可选代理方法。 | Also, the placeholder view is not scrollable by default, so pull-to-refresh does not work either; to make the placeholder view scrollable, implement the optional delegate method below. |

```swift
// [CN] 可选：占位图显示时允许 table view 滚动（默认不允许）
// [EN] Optional: let the table view scroll while the placeholder shows (off by default)
@objc(enableScrollWhenPlaceHolderViewShowing) func enableScrollWhenPlaceHolderViewShowing() -> Bool {
    true
}
```

## 第三步：使用 cyl_reloadData 代替 reloadData / Step 3: Use cyl_reloadData instead of reloadData

| 中文 | English |
| --- | --- |
| 使用方法：仅需使用 `cyl_reloadData` 代替 `reloadData` 即可。 | Usage: just use `cyl_reloadData` instead of `reloadData`. |

```swift
tableView.cylReloadData()
```

| 中文 | English |
| --- | --- |
| 注意：`cyl_reloadData` 内部已经实现了 `[self.tableView reloadData];` 方法，请避免重复调用。 | Note: `cyl_reloadData` already calls `[self.tableView reloadData];` internally, so avoid calling it again. |
| `cyl_reloadData` 与 delegate API 只管理 `UITableView`；`UICollectionView` 请使用上文的 block API（`cyl_placeholderViewBlock:`）。普通页面没有 data source 可供判断空状态，库不自动管理；可以直接把 `CYLPlaceholderView` 当作普通 `UIView` 加到页面上，由应用决定何时显示。需要全局统一的断网或空状态处理时，可在列表基类中统一配置 block。使用独立 data source 时，delegate 或 table view 仍可负责创建占位图，也可以让 data source 实现该协议。 | `cyl_reloadData` and the delegate API manage only `UITableView`; for `UICollectionView` use the block API above (`cyl_placeholderViewBlock:`). An ordinary page has no data source from which to judge emptiness, so the library does not manage it automatically; you can add a `CYLPlaceholderView` to the page like any `UIView` and decide when to show it. For app-wide handling of offline or empty states, configure the block once in a list base class. With a separate data source, the delegate or the table view can still create the placeholder, or the data source can implement the protocol. |

## 适用于多种应用场景 / Scenarios it fits

| 中文 | English |
| --- | --- |
| [CYLTableViewPlaceHolder](https://github.com/ChenYilong/CYLTableViewPlaceHolder) 是基于 `dataSource` 数据源是否为空，所以只需操作 `dataSource` 数据源。只要为空就会触发。并且每次在操作占位视图的 `addSubview` 和 `removeFromSuperview` 时，每次都会将旧的销毁，并触发 `- (UIView *)makePlaceHolderView` 创建一个新的视图。如果在该方法中进行 if 判断，也就能适用于不同的场景。 | [CYLTableViewPlaceHolder](https://github.com/ChenYilong/CYLTableViewPlaceHolder) is based on whether the `dataSource` is empty, so you only need to operate on the `dataSource`. It triggers whenever the data source is empty. And each time the placeholder view is added with `addSubview` and removed with `removeFromSuperview`, the old one is destroyed and `- (UIView *)makePlaceHolderView` is triggered to create a new view. If you add an if check in that method, it fits different scenarios. |

### 网络故障 / Network failure

| 中文 | English |
| --- | --- |
| 适用于那些造成 dataSource 为空的原因只能是网络故障，比如首页、团购列表、商品列表等。比如： | For cases where the only reason the dataSource is empty is a network failure, such as the home page, a group-buying list or a product list. For example: |

| 携程：网络故障 / 携程: network failure | 携程：网络故障 / 携程: network failure | 携程：网络故障 / 携程: network failure |
| --- | --- | --- |
| ![应用场景之加载失败（携程） / Scenario: load failed (携程)](../assets/cyl-placeholder-scenario-01-load-failed.jpg) | ![应用场景之加载失败（携程） / Scenario: load failed (携程)](../assets/cyl-placeholder-scenario-02-load-failed.jpg) | ![应用场景之加载失败（携程） / Scenario: load failed (携程)](../assets/cyl-placeholder-scenario-03-load-failed.jpg) |

| 中文 | English |
| --- | --- |
| 代码实现时直接返回网络故障占位视图，用伪代码表示则是： | In code, simply return the network failure placeholder view; in pseudocode: |

```swift
@objc(makePlaceHolderView) func makePlaceHolderView() -> UIView {
    netNotAvailableView
}
```

#### 网络不可用，禁止重新加载 / Network unavailable: block reloading

| 中文 | English |
| --- | --- |
| 如果此时检测到网络断开可以禁止用户刷新的行为，比如： | If the network is detected to be down, you can stop the user from refreshing, for example: |

| QQ空间 | 苏宁易购 | 嘟嘟美甲 |
| --- | --- | --- |
| ![应用场景之加载失败 / Scenario: load failed](../assets/cyl-placeholder-scenario-04-load-failed.jpg) | ![应用场景之加载失败 / Scenario: load failed](../assets/cyl-placeholder-scenario-05-load-failed.jpg) | ![应用场景之加载失败 / Scenario: load failed](../assets/cyl-placeholder-scenario-06-load-failed.jpg) |

### 暂无数据 / No data

| 中文 | English |
| --- | --- |
| 适用于那些造成 dataSource 为空的原因不仅有网络故障，也可能是确实是服务端也没有数据，这种场景下需要判断下当前网络再返回占位视图，比如： | For cases where the dataSource may be empty not only because of a network failure but also because the server really has no data; here you need to check the current network before returning the placeholder view, for example: |

| App | 暂无数据 / No data | 网络故障 / Network failure |
| --- | --- | --- |
| 百度传课 | ![应用场景之暂无数据 / Scenario: no data](../assets/cyl-placeholder-scenario-07-no-data.jpg) | ![应用场景之加载失败 / Scenario: load failed](../assets/cyl-placeholder-scenario-08-load-failed.jpg) |

| 暂无数据 / No data | 暂无数据（美团） / No data (美团) |
| --- | --- |
| ![应用场景之暂无数据 / Scenario: no data](../assets/cyl-placeholder-scenario-09-no-data.jpg) | ![应用场景之暂无数据 / Scenario: no data](../assets/cyl-placeholder-scenario-10-no-data.jpg) |

| 中文 | English |
| --- | --- |
| 代码实现，用伪代码表示则是： | In code, in pseudocode: |

```swift
@objc(makePlaceHolderView) func makePlaceHolderView() -> UIView {
    isNetworkAvailable ? noDataView : netNotAvailableView
}
```

### 网络不可达场景 / Unreachable network gallery

| 应用场景之加载失败 / Scenario: load failed | 应用场景之加载失败 / Scenario: load failed | 应用场景之加载失败 / Scenario: load failed |
| --- | --- | --- |
| ![应用场景之加载失败 / Scenario: load failed](../assets/cyl-placeholder-scenario-11-load-failed.jpg) | ![应用场景之加载失败 / Scenario: load failed](../assets/cyl-placeholder-scenario-12-load-failed.jpg) | ![应用场景之加载失败 / Scenario: load failed](../assets/cyl-placeholder-scenario-13-load-failed.jpg) |
| ![应用场景之加载失败 / Scenario: load failed](../assets/cyl-placeholder-scenario-14-load-failed.jpg) | ![应用场景之加载失败 / Scenario: load failed](../assets/cyl-placeholder-scenario-15-load-failed.jpg) | ![应用场景之加载失败 / Scenario: load failed](../assets/cyl-placeholder-scenario-16-load-failed.jpg) |
| ![应用场景之加载失败 / Scenario: load failed](../assets/cyl-placeholder-scenario-17-load-failed.jpg) | ![应用场景之加载失败 / Scenario: load failed](../assets/cyl-placeholder-scenario-18-load-failed.jpg) | ![应用场景之加载失败 / Scenario: load failed](../assets/cyl-placeholder-scenario-19-load-failed.jpg) |
| ![应用场景之加载失败 / Scenario: load failed](../assets/cyl-placeholder-scenario-20-load-failed.jpg) | ![应用场景之加载失败 / Scenario: load failed](../assets/cyl-placeholder-scenario-21-load-failed.jpg) | ![应用场景之加载失败 / Scenario: load failed](../assets/cyl-placeholder-scenario-22-load-failed.jpg) |
| ![应用场景之加载失败 / Scenario: load failed](../assets/cyl-placeholder-scenario-23-load-failed.jpg) | ![应用场景之加载失败 / Scenario: load failed](../assets/cyl-placeholder-scenario-24-load-failed.jpg) | ![应用场景之加载失败 / Scenario: load failed](../assets/cyl-placeholder-scenario-25-load-failed.jpg) |
| ![应用场景之加载失败 / Scenario: load failed](../assets/cyl-placeholder-scenario-26-load-failed.jpg) | ![应用场景之加载失败 / Scenario: load failed](../assets/cyl-placeholder-scenario-27-load-failed.jpg) | ![应用场景之加载失败 / Scenario: load failed](../assets/cyl-placeholder-scenario-28-load-failed.jpg) |
| ![应用场景之加载失败 / Scenario: load failed](../assets/cyl-placeholder-scenario-29-load-failed.jpg) | ![应用场景之加载失败 / Scenario: load failed](../assets/cyl-placeholder-scenario-30-load-failed.jpg) | ![应用场景之加载失败 / Scenario: load failed](../assets/cyl-placeholder-scenario-31-load-failed.jpg) |
| ![应用场景之加载失败 / Scenario: load failed](../assets/cyl-placeholder-scenario-32-load-failed.jpg) | ![应用场景之加载失败 / Scenario: load failed](../assets/cyl-placeholder-scenario-33-load-failed.jpg) | ![应用场景之加载失败 / Scenario: load failed](../assets/cyl-placeholder-scenario-34-load-failed.jpg) |
| ![应用场景之加载失败 / Scenario: load failed](../assets/cyl-placeholder-scenario-35-load-failed.jpg) | ![应用场景之加载失败 / Scenario: load failed](../assets/cyl-placeholder-scenario-36-load-failed.jpg) | ![应用场景之加载失败 / Scenario: load failed](../assets/cyl-placeholder-scenario-37-load-failed.jpg) |
| ![应用场景之加载失败 / Scenario: load failed](../assets/cyl-placeholder-scenario-38-load-failed.jpg) | ![应用场景之加载失败 / Scenario: load failed](../assets/cyl-placeholder-scenario-39-load-failed.jpg) | ![应用场景之加载失败 / Scenario: load failed](../assets/cyl-placeholder-scenario-40-load-failed.jpg) |
| ![应用场景之加载失败 / Scenario: load failed](../assets/cyl-placeholder-scenario-41-load-failed.jpg) | ![应用场景之加载失败 / Scenario: load failed](../assets/cyl-placeholder-scenario-42-load-failed.jpg) | ![应用场景之加载失败 / Scenario: load failed](../assets/cyl-placeholder-scenario-43-load-failed.jpg) |
