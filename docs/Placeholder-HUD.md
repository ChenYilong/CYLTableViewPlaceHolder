# 占位图的 HUD 样式 / The HUD style of the placeholder

<!-- bound-classes: CYLPlaceholderHUD, CYLPlaceholderStackView -->

<!-- docs-navigation:start -->

| 中文 | English |
| --- | --- |
| [概述](#概述--overview) | [Overview](#概述--overview) |
| [接口](#接口--api) | [API](#接口--api) |
| [行为与无障碍](#行为与无障碍--behavior-and-accessibility) | [Behavior and accessibility](#行为与无障碍--behavior-and-accessibility) |
| [演示与限制](#演示与限制--demo-and-limits) | [Demo and limits](#演示与限制--demo-and-limits) |

<!-- docs-navigation:end -->

<!-- docs-binding:start -->

| 类 / Class | 头文件 / Header |
| --- | --- |
| `CYLPlaceholderHUD` | [`CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderHUD.h`](../CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderHUD.h) |
| `CYLPlaceholderStackView` | [`CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderStackView.h`](../CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderStackView.h) |

<!-- docs-binding:end -->

## 概述 / Overview

| 中文 | English |
| --- | --- |
| 新增场景 `CYLPlaceholderScenarioHUD`（Swift `.hud`）与类 `CYLPlaceholderHUD`：页面加载进度，也是空白页占位图的一种，更适合动效。场景本身是一个循环播放的刷新加载圈（核心资源包的 `CYLRefreshActivity.gif`，Core 即可播放）加“加载中…”，可以像其他场景一样作为全屏占位图使用。`CYLPlaceholderHUD` 把它放进页面上方的小方框，接口参考 [SVProgressHUD](https://github.com/SVProgressHUD/SVProgressHUD)（MIT，commit `ece669b`）的 README 与头文件：显示、带文字显示、显示进度、成功/错误/提示/图片、按次数抵消的 `popActivity`、延迟关闭、样式、遮罩、通知、触感反馈与宽限时间。 | New: the scenario `CYLPlaceholderScenarioHUD` (Swift `.hud`) and the class `CYLPlaceholderHUD`: a page's loading progress, also a kind of empty-page placeholder, and one that suits animation best. The scenario itself is a looping refresh spinner (the core bundle's `CYLRefreshActivity.gif`, which Core plays) and "Loading…", usable as a full-screen placeholder like every scenario. `CYLPlaceholderHUD` puts it in a small box over the page, with an API modeled on the README and header of [SVProgressHUD](https://github.com/SVProgressHUD/SVProgressHUD) (MIT, commit `ece669b`): show, show with a status, show a progress, success / error / info / image, `popActivity` balancing each show, delayed dismissal, styles, masks, notifications, haptics and a grace time. |
| 方框的内容是 `CYLPlaceholderStackView`，所以占位图的全部接口都可使用：组件、组件堆叠、每个组件自己的点击动作（`actions`、`showComponents:actions:`、`placeholderView.performAction:`）、内置 GIF/Lottie/PAG/Rive 动画（`loadingAnimationFileName` 可设为任意内置动画，`CYLPlaceholderScenarioCatalog animationFileNamesForScenario:CYLPlaceholderScenarioHUD` 列出每种格式各一个合适的刷新动画）。与刷新图标不同（刷新图标跟随下拉进度），HUD 的加载动画默认循环播放（`animationRepeatCount` 为 0）；成功动画播放一次。 | The box's content is a `CYLPlaceholderStackView`, so every placeholder API works: components, stacks of them, each component's own tap action (`actions`, `showComponents:actions:`, `placeholderView.performAction:`), bundled GIF / Lottie / PAG / Rive animations (`loadingAnimationFileName` takes any bundled animation; `CYLPlaceholderScenarioCatalog animationFileNamesForScenario:CYLPlaceholderScenarioHUD` lists a suitable refresh animation in every format). Unlike a refresh icon, which follows the pull, the HUD's loading animation loops by default (`animationRepeatCount` 0); the success animation plays once. |
| 这样本库的组件覆盖了页面的整个生命周期：加载中（HUD）、加载失败与空（占位图）、加载成功后下拉刷新与上拉加载更多（CYLRefresh）。 | So the library's components cover a page's whole life cycle: loading (the HUD), failed and empty (the placeholder), and after loading, refreshing and loading more (CYLRefresh). |

## 接口 / API

| SVProgressHUD | CYLPlaceholderHUD | Swift |
| --- | --- | --- |
| `+show`, `+showWithStatus:` | 同名类方法与实例方法 / class and instance methods of the same names | `show()`, `show(status:)` |
| `+showProgress:`, `+showProgress:status:` | 同上；负数为不确定进度 / the same; negative is indeterminate | `show(progress:)`, `show(progress:status:)` |
| `+setStatus:` | 同上，不重启动画 / the same, without restarting the animation | `setStatus(_:)` |
| `+showInfoWithStatus:`, `+showSuccessWithStatus:`, `+showErrorWithStatus:`, `+showImage:status:` | 同上，`displayDurationForString:` 后自动关闭 / the same, dismissed after `displayDurationForString:` | `showInfo(status:)`, `showSuccess(status:)`, `showError(status:)`, `show(image:status:)` |
| — | `-showComponents:actions:`, `-showScenario:actions:` | `show(components:actions:)`, `show(scenario:actions:)` |
| `+popActivity`, `+dismiss`, `+dismissWithCompletion:`, `+dismissWithDelay:`, `+dismissWithDelay:completion:` | 同名 / same | `popActivity()`, `dismiss()`, `dismiss(completion:)`, `dismiss(withDelay:)`, `dismiss(withDelay:completion:)` |
| `+isVisible`, `+displayDurationForString:` | 同名，另有实例属性 `visible` / same, plus the instance property `visible` | `isVisible`, `displayDuration(for:)` |
| `SVProgressHUDStyle`（Light/Dark/Custom/Automatic） | `CYLPlaceholderHUDStyle`（Automatic 为默认 / Automatic is the default） | `.automatic`, `.light`, `.dark`, `.custom` |
| `SVProgressHUDMaskType`（None/Clear/Black/Gradient/Custom） | `CYLPlaceholderHUDMaskType` | `.none`, `.clear`, `.black`, `.gradient`, `.custom` |
| `foregroundColor`, `backgroundColor`, `backgroundLayerColor`, `font`, `cornerRadius`, `minimumSize`, `imageViewSize`, `offsetFromCenter`, `containerView` | `foregroundColor`, `hudBackgroundColor`, `backgroundLayerColor`, `font`, `cornerRadius`, `minimumSize`, `animationSize`, `offsetFromCenter`, `containerView` | 同名 / same |
| `successImage`, `errorImage`, `infoImage` | 同名，另有 `loadingAnimationFileName`、`progressAnimationFileName`、`successAnimationFileName` / same, plus the three animation names | 同名 / same |
| `graceTimeInterval`, `minimumDismissTimeInterval`, `maximumDismissTimeInterval`, `fadeIn/OutAnimationDuration`, `hapticsEnabled` | 同名 / same | `isHapticsEnabled` |
| `SVProgressHUDWillAppear/DidAppear/WillDisappear/DidDisappear/DidReceiveTouchEvent/DidTouchDownInsideNotification`, `SVProgressHUDStatusUserInfoKey` | `CYLPlaceholderHUD…Notification`, `CYLPlaceholderHUDStatusUserInfoKey` | `NSNotification.Name` |
| — | `state`（Hidden/Loading/Progress/Success/Error/Info/Image/Custom）、`status`、`progress`、`activityCount`、`placeholderView`、`hudView`、`actions`、`sharedHUD`（Swift `shared`）、`-initWithContainerView:` | 同名 / same |

```swift
// [CN] 与 SVProgressHUD 相同的用法 / [EN] Used as SVProgressHUD is
CYLPlaceholderHUD.shared.show(status: "Loading…")
loadData { ok in
    ok ? CYLPlaceholderHUD.shared.dismiss() : CYLPlaceholderHUD.shared.showError(status: "Couldn't load")
}
// [CN] 方框里的组件可以有自己的点击动作 / [EN] Components in the box keep their tap actions
let cancel = CYLPlaceholderAction(rawValue: "cancel")
hud.show(components: CYLPlaceholderScenarioCatalog.components(for: .hud) +
         [.button(title: "Cancel", style: .outlined, action: cancel)],
         actions: [cancel: { _, _ in task.cancel() }])
```

## 行为与无障碍 / Behavior and accessibility

| 中文 | English |
| --- | --- |
| 进度：设置 `progressAnimationFileName` 时按进度定位该动画；未设置或引擎无法定位时绘制圆环，VoiceOver 读出百分比（`accessibilityValue`）。同一种状态再次显示时原地更新文字与进度，动画不重启。 | Progress: with `progressAnimationFileName` the animation is scrubbed to the progress; without it, or when the engine cannot seek, a ring is drawn and VoiceOver reads the percentage (`accessibilityValue`). Showing the same state again updates the text and progress in place, without restarting the animation. |
| 无障碍：显示时朗读状态文字；有遮罩时方框为模态（`accessibilityViewIsModal`），VoiceOver 不会离开它；“减弱动态效果”时只淡入淡出（不缩放，动画由占位组件按系统设置处理）；“降低透明度”时方框为实色；文字随动态字体缩放。 | Accessibility: the status is announced on show; with a mask the box is modal (`accessibilityViewIsModal`) so VoiceOver stays in it; Reduce Motion fades only (no scaling; the component handles the animation per the system setting); Reduce Transparency makes the box solid; text follows Dynamic Type. |
| 容器：默认是应用的 key window（运行时查找，App Extension 中也能链接，但扩展里必须设置 `containerView`）。 | Container: the app's key window by default (looked up at run time, so the library still links in app extensions, where `containerView` must be set). |

## 演示与限制 / Demo and limits

| 中文 | English |
| --- | --- |
| `Examples/Example-Scenarios` 的“交互流程”Tab 新增“HUD”分组：逐项演示显示、文字、进度、成功、错误、提示、图片、带“取消”按钮的组件、方框中的场景、三次显示三次抵消、关闭；“外观”行循环切换样式、遮罩、加载动画（每种格式一个刷新动画）与触感反馈；“页面生命周期”页依次展示 HUD 加载、失败占位图与重试、成功后下拉刷新与上拉加载更多。“场景”Tab 也会列出新的 HUD 场景。 | The Flows tab of `Examples/Example-Scenarios` gains a "HUD" section: show, status, progress, success, error, info, image, components with a "Cancel" button, a scenario in the box, three shows balanced by three pops, and dismiss; the "Look" rows cycle the style, the mask, the loading animation (a refresh animation in each format) and haptics; the "Page life cycle" page shows the HUD while loading, the failed placeholder with Retry, then refreshing and loading more. The Scenarios tab lists the new HUD scenario too. |
| 未验证：本机无法编译，等待 CI；不支持 SVProgressHUD 的 tvOS、`UI_APPEARANCE_SELECTOR` 外观代理、`ringThickness`/`ringRadius`、`motionEffectEnabled`、`maxSupportedWindowLevel` 与自定义模糊效果；各引擎动画在方框中的实际画面需要在模拟器中查看。 | Not verified: nothing compiles here, so CI comes first. Not supported from SVProgressHUD: tvOS, `UI_APPEARANCE_SELECTOR` appearance proxies, `ringThickness` / `ringRadius`, `motionEffectEnabled`, `maxSupportedWindowLevel` and a custom blur effect; how each engine looks in the box needs a simulator check. |
