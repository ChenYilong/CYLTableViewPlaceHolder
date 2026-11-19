# FlatDesign 条目 UI 与动画对比 / FlatDesign item UI and animation comparison

<!-- bound-classes: CYLPlaceholderView -->

<!-- docs-navigation:start -->

| 中文 | English |
| --- | --- |
| [基准与评分](#基准与评分--baseline-and-scoring) | [Baseline and scoring](#基准与评分--baseline-and-scoring) |
| [逐方法对比](#逐方法对比--method-by-method-comparison) | [Method-by-method comparison](#逐方法对比--method-by-method-comparison) |
| [验证（2026-11-10，本地 Xcode 27.2；GitHub Actions 上 Xcode 26）](#验证2026-11-10本地-xcode-272github-actions-上-xcode-26--verification-2026-11-10-xcode-272-locally-xcode-26-on-github-actions) | [Verification (2026-11-10, Xcode 27.2 locally; Xcode 26 on GitHub Actions)](#验证2026-11-10本地-xcode-272github-actions-上-xcode-26--verification-2026-11-10-xcode-272-locally-xcode-26-on-github-actions) |
| [待办：达到 100% 之前的剩余工作](#待办达到-100-之前的剩余工作--todo-outstanding-work-before-100) | [TODO: outstanding work before 100%](#待办达到-100-之前的剩余工作--todo-outstanding-work-before-100) |

<!-- docs-navigation:end -->

<!-- docs-binding:start -->

| 类 / Class | 头文件 / Header |
| --- | --- |
| `CYLPlaceholderView` | [`CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderView.h`](../CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderView.h) |

<!-- docs-binding:end -->

## 基准与评分 / Baseline and scoring

| 中文 | English |
| --- | --- |
| 参照对象是 `CYLTabBarController` 的 `feat/cross-platform-components` 分支（2026-11-09 时 HEAD 为 `a6e8c36eb3f46feadf325ff1d1bc60ee082c0cb7`）。UI 基准是 `CYLFlatDesignTabBarButton.m`；动画基准是 `CYLTabBarItemAnimation/`、`LottieSwift/`、`RiveSwift/` 以及 `CYLTabBarController.podspec` 中的子 spec。占位图的实现是 `CYLPlaceholderView.m`、`CYLPlaceholderAnimation/`、`LottieSwift/`、`RiveSwift/` 和 `CYLTableViewPlaceHolder.podspec`。 | The reference is `CYLTabBarController` branch `feat/cross-platform-components` (HEAD `a6e8c36eb3f46feadf325ff1d1bc60ee082c0cb7` on 2026-11-09). The UI baseline is `CYLFlatDesignTabBarButton.m`; the animation baseline is `CYLTabBarItemAnimation/`, `LottieSwift/`, `RiveSwift/` and the subspecs in `CYLTabBarController.podspec`. The placeholder implementation is `CYLPlaceholderView.m`, `CYLPlaceholderAnimation/`, `LottieSwift/`, `RiveSwift/` and `CYLTableViewPlaceHolder.podspec`. |
| 范围：只比较条目 UI 及其动画，以占位图公开的条目 API（`CYLPlaceholderItem…` 键、外观属性和播放方法）为衡量对象。标签导航、标签控制器和加号按钮不在范围内。 | Scope: only item UI and its animation, measured against the placeholder's public item API (the `CYLPlaceholderItem…` keys, appearance properties and playback methods). Tab navigation, the tab controller and the plus button are out of scope. |
| 每行评分：100 = 按参照的方式实现（或在参照读取仅属于标签栏的对象时，用占位图的等价物实现）**并且**经模拟器测试验证；较低分数列出具体差距。仅保留的键、能编译或未经验证的视觉行为都不计分。 | Scoring per row: 100 = implemented the way the reference does it (or with a placeholder equivalent where the reference reads a tab-bar-only object) **and** verified by simulator tests; lower scores list the concrete gap. Reserved keys, compilation or unverified visual behavior do not count. |

## 逐方法对比 / Method-by-method comparison

| 中文 | English |
| --- | --- |
| 下面先给出完整的中文表，再给出行相同的英文表。 | The full Chinese table comes first, then the English table with the same rows. |

| FlatDesign 条目（参照） | 占位图实现 | 动画支持 | 分数 |
| --- | --- | --- | ---: |
| `initWithFrame:` 创建图片和标题视图 | 是 —— `CYLPlaceholderItemView` 创建两者；每个初始化方法都使用它。 | — | 100 |
| `layoutSubviews` / `_updateLayout`：标题在底部（−2 pt），图片居中位于其上方，条目和外观的标题偏移、图片偏移，insets 只改变尺寸 | 是 —— 几何关系相同（一次未经测试的重写曾把它改成 24 pt 间距，现已恢复）；条目自身的标题偏移优先，否则用 `defaultTitlePositionAdjustment`。有 frame 测试和一个渲染像素测试。 | 仅动画的条目：图片位置采用动画尺寸，与 `isLottieOnlyItem` 相同。 | 100 |
| `_updateLayout` 仅图片 / 仅标题时居中（`layoutCentered`） | 是 —— 单独存在时总是居中。 | — | 100 |
| `_updateTabBarButton`：图片、标题、颜色、字体、背景 | 是 —— 来自条目键；浅色 / 深色图片资源随 trait 变化。 | — | 100 |
| `setSelected:`、选中态图片 / 标题 / 颜色 / 字体、`_updateSelectionIndicator`（可拉伸图填满，其他居中，着色） | 是 —— 依次使用显式选中值、选中外观默认值、普通值；指示器来自视图或其外观默认值。渲染像素测试检查选中图片、指示器以及恢复。 | — | 100 |
| `_effectiveAppearance`、`_stateAppearance`、`_iconColorForState`、`_appearanceTitlePositionAdjustment`、`tintColorDidChange` | 等价 —— `UI_APPEARANCE_SELECTOR` 默认值（标题 / 图标 / 背景颜色、字体、选中变体、标题位置、指示器图片 / 着色）实时应用，包括通过外观代理设置。显式条目值优先；直接设置在 `textLabel`/`imageView` 上的值保留；没有颜色的图标跟随 `tintColor`。 | — | 100 |
| `_updateBadgeAppearance`、`actualBadgeSuperView`、`CYLBadgeAppearance` | 等价 —— `CYLPlaceholderBadgeAppearance`（颜色、字体、insets、圆角、动画），采用参照的 “applied appearance” 规则：设置在 `badgeLabel` 上的值保留。圆点 / 数字 / 文字样式、偏移、同步状态，加上装饰性的弹出动画。角标位于条目内部，因此不需要查找可访问的祖先视图。 | 角标弹出遵循 “减弱动态效果”。 | 100 |
| `isAccessibilityElement`、`accessibilityLabel`、`accessibilityTraits` | 是 —— 有内容或显式标签时是无障碍元素；标签 = 显式标签或标题；选中 trait 跟随选中状态。角标只播报一次：占位图是元素时包含在其值中，否则由角标标签播报。XCUITest 从 VoiceOver 读取的无障碍树中读取这些信息，Apple 的完整无障碍审核在 iOS 17.5 和 26 上无例外通过（动态字体的标题和角标字体、对比度、无截断）。 | 角标弹出遵循 “减弱动态效果”。 | 100 |
| `initTabBarItemAnimation` / `updateTabBarItemAnimation`、`_animationURL`、`_animationFilePath`、`_animationSizeValue`、`_animationContentMode`、`_animationSpeed` | 是 —— 通用和各引擎专用的 URL/path/size 键；`contentMode` 和 `animationSpeed` 选项是控制器级设置的按条目形式。选项像参照一样通过 URL fragment 传递。 | 所有引擎 | 100 |
| GIF `CYLGIFTabBarItemAnimator` 视图提供者（`cyl_animationViewWithFileURL:options:contentMode:`） | 是 —— `GIF` 子 spec 中的 `CYLGIFPlaceholderItemAnimator`（ImageIO、逐帧延时、16 MB / 500 帧 / 64 MB 上限）。没有该子 spec 时 Core 保留内置解码器。 | GIF | 100 |
| GIF `cyl_playAnimationView` / `cyl_stopAnimationView` / `cyl_showAnimationViewLastFrame` | 是 —— 进入窗口时播放一次，重播 / 停止 / 最后一帧，停止状态在重新加入视图层级后保留，遵循 “减弱动态效果”。 | GIF | 100 |
| Lottie：`LottieSwift` 子 spec（Swift 桥接 + Objective-C 动画器），`lottie-ios` ≥ 4.5.1，iOS 13 | 是 —— `LottieSwift/CYLPlaceholderCompatibleLottie.swift` + `CYLLottiePlaceholderItemAnimator`（回退优先级）；`Lottie` 是别名。按决定只支持 Swift：没有 Objective-C 的 Lottie 2.x 版本。keypath 颜色由渲染像素验证。 | Lottie | 100 |
| PAG：`PAG` 和 `PAGEnterprise` 子 spec（企业版使用 `-fno-modules`） | 是 —— `CYLPAGPlaceholderItemAnimator`；两个子 spec 都通过运行时测试套件。 | PAG | 100 |
| Rive：`CYLRiveTabBarItemAnimator` + `RiveSwift` 视图（数据绑定、旧版 inputs/triggers/linear、颜色） | 是 —— 移植了这些视图，并增加了离屏暂停和加载 / 失败回调。使用数据绑定素材（rive-ios 的 `data_binding_test.riv`，MIT），真实运行时确认：`active` 布尔值在播放时为 true、停止后为 false，播放时触发 trigger，深色颜色传到 view-model 的颜色属性并能恢复。旧版 input/trigger/linear 生命周期、离屏暂停和回退均有测试。 | Rive | 100 |
| `CYLTabBarItemAnimator` 协议、`CYLTabBarItemAnimatorRegistry`、`CYLTabBarItemAnimationFactory`、`CYLTabBarItemAnimationPlayer`、`CYLTabBarItemAnimationPlayableView`、`CYLTabBarItemViewAnimator`、引擎 + Core 服务 | 是 —— 对应的 `CYLPlaceholderItem…` 实现；引擎把自己安装到 Core 私有的 `CYLPlaceholderItemAnimationService` 中；自定义动画器可在运行时注册（已测试）。基于 block 的 `registerAnimationFactory:` API 保留，并具有最高优先级。 | 所有引擎 | 100 |
| 深色 URL、通用 / 深色 / 引擎颜色、实时外观切换 | 是 —— 每个引擎都有深色 URL；通用颜色优先级低于深色 / 引擎颜色；Lottie 颜色已绘制（像素测试）；Rive 颜色在浅色 / 深色切换时传到视图。PAG 和 GIF 没有颜色覆盖，与参照相同。 | Lottie、Rive | 100 |
| 替换时保留速度 / 进度（`copyAnimationStateFromView:toView:`） | 是 —— 速度和 seek 在深色模式替换后保留（已测试）；不支持的操作返回 `NO`。 | Lottie、PAG | 100 |
| CocoaPods 组织方式（`CYLTabBarItemAnimation`、`<Library>/` 文件夹、按库划分的子 spec、`static_framework`、`DEFINES_MODULE`） | 是 —— 相同的布局和子 spec 名称；静态与动态集成都通过；每个子 spec 都通过 `pod lib lint`（见验证）。 | 全部 | 100 |
| Carthage 与 iOS 12 | Carthage 编译带 bundle 的核心 xcframework，与参照的 Carthage 示例相同（两者的后端都只支持 CocoaPods）；CI 在每个拉取请求上编译它。CI 还用 Xcode 16 以 iOS 12.0 编译 Core，任何未用 `@available` 保护的新 API 都会导致失败。在 iOS 12 上运行尚未验证：没有托管 runner 提供 iOS 12 模拟器。 | — | 95 |

| FlatDesign item (reference) | Placeholder implementation | Animation support | Score |
| --- | --- | --- | ---: |
| `initWithFrame:` creates image and title views | Yes — `CYLPlaceholderItemView` creates both; every initializer uses it. | — | 100 |
| `layoutSubviews` / `_updateLayout`: title at the bottom (−2 pt), image centered above it, item and appearance title offsets, image offset, insets change size only | Yes — same geometry (restored after an untested rewrite had replaced it with 24 pt spacing); the item's title offset wins, else `defaultTitlePositionAdjustment`. Frame tests plus a rendered-pixel test. | Animation-only item: the image slot takes the animation size, as `isLottieOnlyItem`. | 100 |
| `_updateLayout` image-only / title-only centering (`layoutCentered`) | Yes — always centered when alone. | — | 100 |
| `_updateTabBarButton`: image, title, colors, font, background | Yes — from item keys; light/dark image assets follow trait changes. | — | 100 |
| `setSelected:`, selected image/title/colors/font, `_updateSelectionIndicator` (resizable fills, others centered, tinted) | Yes — explicit selected values, then selected appearance defaults, then normal values; indicator from the view or its appearance default. Rendered-pixel test checks selected image and indicator, and restoration. | — | 100 |
| `_effectiveAppearance`, `_stateAppearance`, `_iconColorForState`, `_appearanceTitlePositionAdjustment`, `tintColorDidChange` | Equivalent — `UI_APPEARANCE_SELECTOR` defaults (title/icon/background color, font, selected variants, title position, indicator image/tint) applied live, including through the appearance proxy. Explicit item values win; values set directly on `textLabel`/`imageView` are kept; an icon without a color follows `tintColor`. | — | 100 |
| `_updateBadgeAppearance`, `actualBadgeSuperView`, `CYLBadgeAppearance` | Equivalent — `CYLPlaceholderBadgeAppearance` (colors, font, insets, corner radius, animation) with the reference's "applied appearance" rule: values set on `badgeLabel` are kept. Dot/number/text styles, offset, synchronous state with a cosmetic pop animation. The badge lives inside the item, so no accessible-ancestor lookup is needed. | Badge pop honors Reduce Motion. | 100 |
| `isAccessibilityElement`, `accessibilityLabel`, `accessibilityTraits` | Yes — element when it has content or explicit labels; label = explicit label or title; selected trait follows selection. Badge announced once: inside the placeholder's value when it is an element, otherwise by the badge label. XCUITest reads this from the accessibility tree VoiceOver reads, and Apple's full accessibility audit passes with no exception on iOS 17.5 and 26 (Dynamic Type title and badge fonts, contrast, no clipping). | Badge pop honors Reduce Motion. | 100 |
| `initTabBarItemAnimation` / `updateTabBarItemAnimation`, `_animationURL`, `_animationFilePath`, `_animationSizeValue`, `_animationContentMode`, `_animationSpeed` | Yes — generic and engine-specific URL/path/size keys; `contentMode` and `animationSpeed` options are the per-item form of the controller-level settings. Options travel in the URL fragment, as in the reference. | All engines | 100 |
| GIF `CYLGIFTabBarItemAnimator` view provider (`cyl_animationViewWithFileURL:options:contentMode:`) | Yes — `GIF` subspec with `CYLGIFPlaceholderItemAnimator` (ImageIO, per-frame delays, 16 MB / 500 frames / 64 MB caps). Core keeps its built-in decoder when the subspec is absent. | GIF | 100 |
| GIF `cyl_playAnimationView` / `cyl_stopAnimationView` / `cyl_showAnimationViewLastFrame` | Yes — plays once on entering a window, replay/stop/last frame, stop survives reattachment, Reduce Motion. | GIF | 100 |
| Lottie: `LottieSwift` subspec (Swift bridge + Objective-C animator), `lottie-ios` ≥ 4.5.1, iOS 13 | Yes — `LottieSwift/CYLPlaceholderCompatibleLottie.swift` + `CYLLottiePlaceholderItemAnimator` (fallback priority); `Lottie` is an alias. Swift-only by decision: no Objective-C Lottie 2.x flavor. Keypath colors verified by rendered pixels. | Lottie | 100 |
| PAG: `PAG` and `PAGEnterprise` subspecs (`-fno-modules` for enterprise) | Yes — `CYLPAGPlaceholderItemAnimator`; both subspecs pass the runtime suite. | PAG | 100 |
| Rive: `CYLRiveTabBarItemAnimator` + `RiveSwift` views (data binding, legacy inputs/triggers/linear, colors) | Yes — ported views, plus offscreen pause and load/failure callbacks. With a data-bound fixture (rive-ios `data_binding_test.riv`, MIT) the real runtime confirms: the `active` boolean is true while playing and false after stop, the trigger fires on play, and dark colors reach the view-model color property and are restored. Legacy input/trigger/linear lifecycle, offscreen pause and fallback are tested. | Rive | 100 |
| `CYLTabBarItemAnimator` protocols, `CYLTabBarItemAnimatorRegistry`, `CYLTabBarItemAnimationFactory`, `CYLTabBarItemAnimationPlayer`, `CYLTabBarItemAnimationPlayableView`, `CYLTabBarItemViewAnimator`, engine + Core service | Yes — `CYLPlaceholderItem…` equivalents; the engine installs itself into Core's private `CYLPlaceholderItemAnimationService`; custom animators register at runtime (tested). The block-based `registerAnimationFactory:` API is kept and has the highest precedence. | All engines | 100 |
| Dark URL, generic/dark/engine colors, live appearance swap | Yes — dark URLs per engine; generic colors below dark/engine colors; Lottie colors drawn (pixel test); Rive colors reach the view on light/dark switches. PAG and GIF have no color override, as in the reference. | Lottie, Rive | 100 |
| Speed/progress carried across replacement (`copyAnimationStateFromView:toView:`) | Yes — speed and seek survive the dark-mode replacement (tested); unsupported operations return `NO`. | Lottie, PAG | 100 |
| CocoaPods organization (`CYLTabBarItemAnimation`, `<Library>/` folders, per-library subspecs, `static_framework`, `DEFINES_MODULE`) | Yes — same layout and subspec names; static and dynamic integrations pass; `pod lib lint` passes for every subspec (see verification). | All | 100 |
| Carthage and iOS 12 | Carthage builds the core xcframework with its bundles, as the reference's Carthage demo (backends are CocoaPods-only in both); CI builds it on every pull request. CI also builds Core at iOS 12.0 with Xcode 16, failing on any newer API not guarded by `@available`. Running on iOS 12 is not verified: no hosted runner has an iOS 12 simulator. | — | 95 |

## 验证（2026-11-10，本地 Xcode 27.2；GitHub Actions 上 Xcode 26） / Verification (2026-11-10, Xcode 27.2 locally; Xcode 26 on GitHub Actions)

| 中文 | English |
| --- | --- |
| `ruby Tests/run-tests.rb`：77 个测试通过（Core、内置 GIF、没有引擎时的共享动画模块、布局几何、渲染出的选中态、外观代理、角标外观与无障碍）。 | `ruby Tests/run-tests.rb`: 77 tests pass (Core, built-in GIF, shared animation module without engines, layout geometry, rendered selection, appearance proxy, badge appearance and accessibility). |
| `ruby Tests/run-animation-tests.rb`（LottieSwift、GIF、PAG、Rive）：19 个测试在 `LINKAGE=static` 和 `LINKAGE=dynamic` 下通过，在 `PAG_SUBSPEC=PAGEnterprise` 下也通过。覆盖注册表内容与查找、经注册表的 GIF、接收选项的自定义视图动画器、Lottie 播放 / seek / 速度、浅色与深色下绘制的 Lottie keypath 颜色（渲染的 presentation layer）、深色模式替换后保留的速度与 seek、PAG 进度、Rive 加载 / 暂停 / 回退、旧版 input/trigger/linear、跟随外观的 Rive 颜色，以及从运行时读回的 Rive 数据绑定（布尔值、trigger、颜色）。 | `ruby Tests/run-animation-tests.rb` (LottieSwift, GIF, PAG, Rive): 19 tests pass with `LINKAGE=static` and `LINKAGE=dynamic`, and with `PAG_SUBSPEC=PAGEnterprise`. They cover the registry contents and lookup, GIF through the registry, a custom view animator receiving options, Lottie playback/seek/speed, Lottie keypath colors drawn in light and dark (rendered presentation layer), speed and seek kept across the dark-mode replacement, PAG progress, Rive load/pause/fallback, legacy input/trigger/linear, and Rive colors following the appearance, and Rive data binding (boolean, trigger, color) read back from the runtime. |
| `ruby Tests/run-accessibility-tests.rb`：XCUITest 检查无障碍树，以及 Apple 的完整无障碍审核，无例外。 | `ruby Tests/run-accessibility-tests.rb`: XCUITest checks of the accessibility tree and Apple's full accessibility audit, no exceptions. |
| 以上全部在 CI 中运行（`.github/workflows/ios.yml`，见 [CI-CD.md](CI-CD.md)），另有一个用 Xcode 16 的 iOS 12.0 部署编译。 | All of the above run in CI (`.github/workflows/ios.yml`, see [CI-CD.md](CI-CD.md)), plus an iOS 12.0 deployment build with Xcode 16. |
| 示例应用通过 workspace 编译；`carthage build --no-skip-current --use-xcframeworks` 编译出 `CYLTableViewPlaceHolder.xcframework`。 | Example app builds through the workspace; `carthage build --no-skip-current --use-xcframeworks` builds `CYLTableViewPlaceHolder.xcframework`. |
| 使用 `scripts/pod-lint.xcconfig` 运行 `pod lib lint --allow-warnings`：每个子 spec 都通过验证。剩余的警告来自上游（`libpag` 许可证文件、OpenGL ES 弃用、umbrella 头文件）以及早已存在的 CYLRefresh 弃用警告。 | `pod lib lint --allow-warnings` with `scripts/pod-lint.xcconfig`: every subspec passes validation. Remaining warnings are upstream (`libpag` license file, OpenGL ES deprecations, umbrella header) and pre-existing CYLRefresh deprecations. |
| 基准 `master`（826c07e）无法编译：三处属性重复声明、在 `id` 上使用 `title.length`，以及未声明的 `CYLPlaceholderItemPAGDarkColors`。因此 [flatdesign-vs-placeholder-comparison.md](flatdesign-vs-placeholder-comparison.md) 中的分数从未被验证过；本文档取代它们。 | The baseline `master` (826c07e) did not compile: three property redeclarations, `title.length` on `id`, and an undeclared `CYLPlaceholderItemPAGDarkColors`. The scores in [flatdesign-vs-placeholder-comparison.md](flatdesign-vs-placeholder-comparison.md) were therefore never verified; this document replaces them. |

## 待办：达到 100% 之前的剩余工作 / TODO: outstanding work before 100%

| 中文 | English |
| --- | --- |
| 状态（2026-11-19，Windows 会话）：下面每个未完成项都是需要 macOS、Xcode、iOS 模拟器或 iOS 设备的 iOS 工作，因此按会话角色规则属于 Mac 会话；Windows 会话已于 2026-11-19 移交该清单。项目中 Android、HarmonyOS 和小程序部分分别在 `docs/Android-API-Map.md`（100）、`docs/HarmonyOS.md` 和 `docs/WeChat-MiniProgram.md` 中跟踪。 | Status (2026-11-19, Windows session): every open item below is iOS work that needs macOS, Xcode, an iOS simulator or an iOS device, so by the session-roles rule it belongs to the Mac session; the Windows session handed the list over on 2026-11-19. The Android, HarmonyOS and mini program parts of the project are tracked in `docs/Android-API-Map.md` (100), `docs/HarmonyOS.md` and `docs/WeChat-MiniProgram.md`. |

| 待办 | 当前差距与实现说明 | 需要的验证 |
| --- | --- | --- |
| TODO —— Carthage 与 iOS 12（95） | Carthage 打包和 iOS 12.0 部署编译（Xcode 16，未加保护的可用性问题视为错误）在 CI 中通过；单元测试套件也在 15.0 下带这些错误设置编译并通过。用任何可用的机器都无法在 iOS 12 上运行：Apple 的 iOS 12.4 模拟器运行时拒绝 macOS 12.99 之后的主机（已在 GitHub 的 `macos-15-intel` runner 上尝试，PR #19），GitHub 没有 macOS 12 runner，而这台 Mac 运行 macOS 27。 | 决定（2026-11-10）：保留 iOS 12，并在真机上验证。在 iOS 12 设备上用 Xcode 16 或更早版本运行 `scripts/device-tests.sh <UDID> <team ID>` 并在此记录结果；之后这一行即为 100。受阻（2026-11-19，Mac 会话审查）：仍然没有 iOS 12 设备，这台 Mac（macOS 27）上 `xcrun simctl list runtimes` 提供的最旧运行时是 iOS 15.0，且标记为在 macOS 14.99 之后的主机上不可用；CI 的 iOS 12 部署编译和 Carthage 任务仍然通过（CI 运行 44228128863，f9f6abe）。有 iOS 12 设备时重新打开。 |

| TODO | Current gap and implementation notes | Verification needed |
| --- | --- | --- |
| TODO — Carthage and iOS 12 (95) | Carthage packaging and an iOS 12.0 deployment build (Xcode 16, unguarded-availability errors) pass in CI; the unit suite also builds at 15.0 with those errors and passes. Running on iOS 12 is impossible with any available machine: Apple's iOS 12.4 simulator runtime refuses hosts after macOS 12.99 (tried on GitHub's `macos-15-intel` runner, PR #19), GitHub has no macOS 12 runner, and this Mac runs macOS 27. | Decision (2026-11-10): keep iOS 12 and verify on a physical device. Run `scripts/device-tests.sh <UDID> <team ID>` with Xcode 16 or earlier on an iOS 12 device and record the result here; then the row is 100. Blocked (2026-11-19, Mac session audit): still no iOS 12 device, and `xcrun simctl list runtimes` on this Mac (macOS 27) offers iOS 15.0 as the oldest runtime, marked unavailable on hosts after macOS 14.99; the CI iOS 12 deployment build and Carthage job still pass (CI run 44228128863, f9f6abe). Reopen when an iOS 12 device is available. |

| 中文 | English |
| --- | --- |
| 已知风险：`registerAnimationFactory:`（block API）与注册表并存；对于其扩展名，block 工厂优先。Lottie 动画器只接受 `.json`/`.lottie`（参照接受任何文件），因此未知格式仍报告 `CYLPlaceholderAnimationErrorUnsupportedFormat`。`libpag` 许可证文件警告需要在分发前审查。 | Known risks: `registerAnimationFactory:` (block API) and the registry coexist; a block factory wins for its extension. The Lottie animator only takes `.json`/`.lottie` (the reference takes any file) so unknown formats still report `CYLPlaceholderAnimationErrorUnsupportedFormat`. `libpag` license-file warning needs review before distribution. |
