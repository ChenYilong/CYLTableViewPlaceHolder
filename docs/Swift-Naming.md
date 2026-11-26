# Swift 命名与 `cyl_` / `CYL` 前缀 / Swift naming and the `cyl_` / `CYL` prefixes

| 中文 | English |
| --- | --- |
| 日期：2026-11-22，分支 `fix/ios-swift-todos-placeholder`。依据：SonarCloud 对 CYLTabBarController PR #821 的静态分析（swift:S100 函数名、S116 字段名、S115 常量名，正则 `^[a-z][a-zA-Z0-9]*$`），以及用户要求在 Swift 和其他语言中重新评估前缀的必要性。方案已与 CYLTabBarController 会话（chenyilong-0b）和 CYLSearchViewController 会话对齐。 | Date: 2026-11-22, branch `fix/ios-swift-todos-placeholder`. Basis: SonarCloud's static analysis of CYLTabBarController PR #821 (swift:S100 function names, S116 field names, S115 constant names, regular expression `^[a-z][a-zA-Z0-9]*$`), and the user's request to re-evaluate whether Swift and the other languages need the prefixes. The scheme is agreed with the CYLTabBarController session (chenyilong-0b) and the CYLSearchViewController session. |

## 为什么 Objective-C 需要前缀 / Why Objective-C needs the prefixes

| 中文 | English |
| --- | --- |
| Objective-C 没有命名空间：所有类名在一个运行时中共享，两个库的同名类会冲突；分类方法按选择子注册到类上，两个分类的同名方法会互相覆盖，哪个生效不确定，且没有编译错误。因此 Objective-C 的类名用 `CYL`，分类方法与属性用 `cyl_`。 | Objective-C has no namespaces: every class name shares one runtime, so same-named classes of two libraries collide; category methods are registered on the class by selector, so same-named methods of two categories override each other, which one wins is undefined, and there is no compiler error. That is why Objective-C class names use `CYL` and category methods and properties use `cyl_`. |

## Swift 中的评估 / The evaluation in Swift

| 中文 | English |
| --- | --- |
| **本库自有类型的成员**：类型本身就是命名空间（`CYLRefreshComponent.link(to:)` 与其他库的 `link` 不冲突）；子类的方法优先于父类上其他库分类的同名方法。前缀没有作用，按 S100/S116 去掉。 | **Members of the library's own types**: the type itself is the namespace (`CYLRefreshComponent.link(to:)` cannot collide with another library's `link`); a subclass method wins over a same-named category method on its superclass. The prefix does nothing there and is dropped per S100/S116. |
| **系统类型扩展的成员**（`UIScrollView`、`UITableView`、`UIView`、`Bundle` 等）：仍然需要前缀。Swift 中两个模块对同一类型的同名扩展成员在同时导入时会产生歧义（编译错误）；带 `@objc` / `dynamic` 的成员还会成为 Objective-C 分类方法，运行时静默覆盖。处理：Swift 名保留 `cyl` 前缀但去掉下划线（`cylHeader`），Objective-C 选择子用 `@objc(cyl_header)` 保持不变。这同时满足 S100 和冲突防护。 | **Members of extensions on system types** (`UIScrollView`, `UITableView`, `UIView`, `Bundle` and so on): still need the prefix. In Swift, same-named extension members of two modules on the same type are ambiguous when both are imported (a compiler error); a member that is `@objc` / `dynamic` also becomes an Objective-C category method and is overridden silently at run time. So the Swift name keeps the `cyl` prefix without the underscore (`cylHeader`), and the Objective-C selector stays the same through `@objc(cyl_header)`. That satisfies S100 and keeps the collision protection. |
| **`CYL` 类名**：保留。S101（类型名 `^[A-Z][a-zA-Z0-9]*$`）通过；`@objc` 类的运行时类名是全局的；`NSClassFromString("CYLRefreshFooter")` 等代码依赖它们；Objective-C 调用方也看到同一个名字。 | **`CYL` class names**: kept. S101 (type names `^[A-Z][a-zA-Z0-9]*$`) passes; the runtime names of `@objc` classes are global; code such as `NSClassFromString("CYLRefreshFooter")` depends on them; Objective-C callers see the same name. |
| **Swift 全局常量与函数**：Swift 全局符号属于模块命名空间，且对 Objective-C 不可见；文件私有的 `CYLXxx` 常量改为小驼峰（`scenarioIconSide`），满足 S115。Objective-C 需要读取的常量仍在 `.h` / `.m` 中以 `CYL` 命名（S115 不检查 Objective-C）。 | **Swift globals**: Swift globals belong to the module namespace and are invisible to Objective-C; the file-private `CYLXxx` constants become lowerCamel (`scenarioIconSide`), per S115. Constants that Objective-C reads stay in the `.h` / `.m` files with `CYL` names (S115 does not check Objective-C). |
| **例外**：对 Objective-C 可见的 UIKit 子类成员（显式 `@objc`、`dynamic`）即使 Swift 名去掉前缀，也写显式 `@objc(cyl_…)`，避免通用名字（`state`、`now`）覆盖 UIKit 的私有选择子。Sonar 只检查标识符，不检查 `@objc` 中的字符串。 | **Exception**: members of UIKit subclasses that are visible to Objective-C (explicit `@objc`, `dynamic`) keep an explicit `@objc(cyl_…)` even when the Swift name loses the prefix, so a generic name (`state`, `now`) cannot override a private UIKit selector. Sonar checks the identifier, not the string inside `@objc`. |
| **兼容性**：Objective-C 选择子全部不变：改名前后生成的 `CYLTableViewPlaceHolder-Swift.h` 逐字相同（Xcode 27.2，Example-objc-02 构建）。Swift 名直接改，不加废弃别名：tag 1.1.0 不含 core 的 Swift 文件，Swift API 尚未发布（项目规则：示例与内部调用不是保留别名的理由）。 | **Compatibility**: every Objective-C selector is unchanged: the generated `CYLTableViewPlaceHolder-Swift.h` is identical before and after the rename (Xcode 27.2, Example-objc-02 build). The Swift names change without deprecated aliases: tag 1.1.0 has no core Swift files, so the Swift API is unreleased (project rule: examples and internal callers are no reason for an alias). |

## 其他语言 / Other languages

| 中文 | English |
| --- | --- |
| Kotlin（Android）：包名（`com.cyl.…`）就是命名空间，扩展函数按 import 解析、没有运行时覆盖，代码符号不需要前缀。**仍需前缀**：Android 资源（`R.id`、`attr`、`string`、`drawable` 在合并时共享一个命名空间），用 Gradle `resourcePrefix "cyl_"` 强制。 | Kotlin (Android): the package (`com.cyl.…`) is the namespace, and extension functions resolve by import with no run-time override, so code symbols need no prefix. **Still prefixed**: Android resources (`R.id`, `attr`, `string`, `drawable` share one namespace when merged), enforced with Gradle `resourcePrefix "cyl_"`. |
| ArkTS（HarmonyOS）：ES 模块的导出就是命名空间，代码符号不需要前缀。**仍需前缀**：`$r` 资源名（HAR/HSP 合并后共享）、`AppStorage` / `PersistentStorage` 的键。 | ArkTS (HarmonyOS): ES module exports are the namespace, so code symbols need no prefix. **Still prefixed**: `$r` resource names (shared after HAR/HSP merging) and `AppStorage` / `PersistentStorage` keys. |
| JavaScript / TypeScript（微信小程序、React Native）：CommonJS / ES 模块是命名空间。**仍需前缀**：小程序组件标签名（`cyl-…`）、`wx.setStorage` 的键、全局 CSS 类名；React Native 原生模块名与原生视图名（全局注册）。 | JavaScript / TypeScript (WeChat Mini Program, React Native): CommonJS / ES modules are the namespace. **Still prefixed**: mini program component tag names (`cyl-…`), `wx.setStorage` keys and global CSS class names; React Native native module and native view names (registered globally). |
| Dart（Flutter）：库是命名空间，扩展冲突可用 `hide` 或显式扩展名解决，代码符号不需要前缀；平台通道名需要前缀。 | Dart (Flutter): the library is the namespace, and extension conflicts are resolved with `hide` or an explicit extension name, so code symbols need no prefix; platform channel names need a prefix. |
| 本轮只评估其他语言，未改名；按语言分批处理（第一个：Kotlin 的 `cyl_placeholderDidChange`，自有接口成员，未发布，违反 Kotlin 命名约定）。 | Other languages are evaluated only in this pass, not renamed; they follow in per-language batches (first: Kotlin's `cyl_placeholderDidChange`, an own-interface member, unreleased, against Kotlin's naming convention). |

## 验证 / Verification

| 中文 | English |
| --- | --- |
| ①改名脚本按映射表替换 186 个声明及调用（跳过 `@objc(…)`、字符串字面量与 Objective-C 选择子写法 `name:`；字符串插值内的调用单独处理）；②生成的 `-Swift.h` 改名前后逐字相同（39 个原先只写 `@objc` 的声明补上了显式 `@objc(cyl_…)`）；③218 个单元测试 0 失败（含 Objective-C API 冒烟测试）；④五个示例按 CI 脚本构建；⑤本地 S100/S116 检查：core 中 `(func\|var\|let) [a-z]+_` 为 0。 | ① a rename script applied the mapping to 186 declarations and their callers (skipping `@objc(…)`, string literals and the Objective-C selector spelling `name:`; calls inside string interpolations handled separately); ② the generated `-Swift.h` is identical before and after (39 declarations that had a bare `@objc` got an explicit `@objc(cyl_…)`); ③ 218 unit tests, 0 failures (the Objective-C API smoke test included); ④ the five examples built with the CI script; ⑤ local S100/S116 check: `(func\|var\|let) [a-z]+_` finds 0 in the core. |

## 公开 Swift 名对照 / Public Swift name mapping

| 类型 / Type | 旧 Swift 名 / Old Swift name | 新 Swift 名 / New Swift name | 类别 / Kind |
| --- | --- | --- | --- |
| `CYLRefreshAutoFooter` | `cyl_beginRefreshingWithoutValidation` | `beginRefreshingWithoutValidation` | 自有类型 / own type |
| `CYLRefreshComponent` | `cyl_iconView` | `refreshIconView` | 自有类型 / own type |
| `CYLRefreshComponent` | `cyl_usesIconView` | `usesRefreshIconView` | 自有类型 / own type |
| `CYLRefreshComponent` | `cyl_setIconAnimation` | `applyIconAnimation` | 自有类型 / own type |
| `CYLRefreshComponent` | `cyl_placeIconView` | `placeIconView` | 自有类型 / own type |
| `CYLRefreshComponent` | `cyl_updateIconView` | `updateIconView` | 自有类型 / own type |
| `CYLRefreshComponent` | `cyl_setIconImages` | `setIconImages` | 自有类型 / own type |
| `CYLRefreshComponent` | `cyl_setAnimationImages` | `applyAnimationImages` | 自有类型 / own type |
| `CYLRefreshComponent` | `cyl_animationImages` | `animationImages` | 自有类型 / own type |
| `CYLRefreshComponent` | `cyl_showIdleAnimationFrame` | `showIdleAnimationFrame` | 自有类型 / own type |
| `CYLRefreshComponent` | `cyl_setBundledIconAnimation` | `setBundledIconAnimation` | 自有类型 / own type |
| `CYLRefreshComponent` | `cyl_showIconImageFrame` | `showIconImageFrame` | 自有类型 / own type |
| `CYLRefreshComponent` | `cyl_setStateTitle` | `setStateTitle` | 自有类型 / own type |
| `CYLRefreshComponent` | `cyl_stateTitle` | `stateTitle` | 自有类型 / own type |
| `CYLRefreshComponent` | `cyl_autoChangeTransparency` | `autoChangeTransparency` | 自有类型 / own type |
| `CYLRefreshComponent` | `cyl_endingAnimationBeginningAction` | `endingAnimationBeginningAction` | 自有类型 / own type |
| `CYLRefreshComponent` | `cyl_link` | `link` | 自有类型 / own type |
| `UILabel` | `cyl_textWidth` | `cylTextWidth` | 系统类型扩展 / system-type extension |
| `CYLRefreshFooter` | `cyl_link` | `link` | 自有类型 / own type |
| `CYLRefreshFooter` | `cyl_updateNoMoreDataImage` | `updateNoMoreDataImage` | 自有类型 / own type |
| `CYLRefreshFooter` | `cyl_placeNoMoreDataImage` | `placeNoMoreDataImage` | 自有类型 / own type |
| `CYLRefreshHeader` | `cyl_link` | `link` | 自有类型 / own type |
| `CYLRefreshTrailer` | `cyl_link` | `link` | 自有类型 / own type |
| `CYLRefreshDrawnHeader` | `cyl_beginDriven` | `beginDriven` | 自有类型 / own type |
| `CYLRefreshDrawnHeader` | `cyl_driveFrame` | `driveFrame` | 自有类型 / own type |
| `CYLRefreshDrawnHeader` | `cyl_driveOffset` | `driveOffset` | 自有类型 / own type |
| `CYLRefreshDrawnHeader` | `cyl_driveStatus` | `driveStatus` | 自有类型 / own type |
| `CYLRefreshDrawnHeader` | `cyl_driveFinished` | `driveFinished` | 自有类型 / own type |
| `Scanner` | `cyl_scanCharacters` | `cylScanCharacters` | 系统类型扩展 / system-type extension |
| `Scanner` | `cyl_scanUpToCharacters` | `cylScanUpToCharacters` | 系统类型扩展 / system-type extension |
| `Scanner` | `cyl_scanString` | `cylScanString` | 系统类型扩展 / system-type extension |
| `Scanner` | `cyl_scanDouble` | `cylScanDouble` | 系统类型扩展 / system-type extension |
| `Scanner` | `cyl_moveBack` | `cylMoveBack` | 系统类型扩展 / system-type extension |
| `UIActivityIndicatorView.Style` | `cyl_refreshDefault` | `cylRefreshDefault` | 系统类型扩展 / system-type extension |
| `CYLRefreshStateHeader` | `cyl_modifyLastUpdatedTimeText` | `modifyLastUpdatedTimeText` | 自有类型 / own type |
| `CYLRefreshStateTrailer` | `cyl_placeStateLabel` | `placeStateLabel` | 自有类型 / own type |
| `Bundle` | `cyl_refresh` | `cylRefresh` | 系统类型扩展 / system-type extension |
| `Bundle` | `cyl_arrowImage` | `cylArrowImage` | 系统类型扩展 / system-type extension |
| `Bundle` | `cyl_trailArrowImage` | `cylTrailArrowImage` | 系统类型扩展 / system-type extension |
| `Bundle` | `cyl_localizedString` | `cylLocalizedString` | 系统类型扩展 / system-type extension |
| `Bundle` | `cyl_resetLanguageResourceCache` | `cylResetLanguageResourceCache` | 系统类型扩展 / system-type extension |
| `UICollectionViewLayout` | `cyl_installFooterUpdateFix` | `cylInstallFooterUpdateFix` | 系统类型扩展 / system-type extension |
| `UICollectionViewLayout` | `cyl_finalizeCollectionViewUpdates` | `cylFinalizeCollectionViewUpdates` | 系统类型扩展 / system-type extension |
| `UIScrollView` | `cyl_installSideInsetWriter` | `cylInstallSideInsetWriter` | 系统类型扩展 / system-type extension |
| `UIScrollView` | `cyl_refreshPerform` | `cylRefreshPerform` | 系统类型扩展 / system-type extension |
| `UIScrollView` | `cyl_isWritingSideInset` | `cylIsWritingSideInset` | 系统类型扩展 / system-type extension |
| `UIScrollView` | `cyl_inset` | `cylInset` | 系统类型扩展 / system-type extension |
| `UIScrollView` | `cyl_insetT` | `cylInsetT` | 系统类型扩展 / system-type extension |
| `UIScrollView` | `cyl_insetB` | `cylInsetB` | 系统类型扩展 / system-type extension |
| `UIScrollView` | `cyl_insetL` | `cylInsetL` | 系统类型扩展 / system-type extension |
| `UIScrollView` | `cyl_insetR` | `cylInsetR` | 系统类型扩展 / system-type extension |
| `UIScrollView` | `cyl_offsetX` | `cylOffsetX` | 系统类型扩展 / system-type extension |
| `UIScrollView` | `cyl_offsetY` | `cylOffsetY` | 系统类型扩展 / system-type extension |
| `UIScrollView` | `cyl_contentW` | `cylContentW` | 系统类型扩展 / system-type extension |
| `UIScrollView` | `cyl_contentH` | `cylContentH` | 系统类型扩展 / system-type extension |
| `UIScrollView` | `cyl_updateScrollMetrics` | `cylUpdateScrollMetrics` | 系统类型扩展 / system-type extension |
| `UIScrollView` | `cyl_scrollDistance` | `cylScrollDistance` | 系统类型扩展 / system-type extension |
| `UIScrollView` | `cyl_scrollDirection` | `cylScrollDirection` | 系统类型扩展 / system-type extension |
| `UIScrollView` | `cyl_header` | `cylHeader` | 系统类型扩展 / system-type extension |
| `UIScrollView` | `cyl_footer` | `cylFooter` | 系统类型扩展 / system-type extension |
| `UIScrollView` | `cyl_trailer` | `cylTrailer` | 系统类型扩展 / system-type extension |
| `UIScrollView` | `cyl_totalDataCount` | `cylTotalDataCount` | 系统类型扩展 / system-type extension |
| `UIScrollView` | `cyl_autoHideRefreshHeader` | `cylAutoHideRefreshHeader` | 系统类型扩展 / system-type extension |
| `UIScrollView` | `cyl_autoHideRefreshFooter` | `cylAutoHideRefreshFooter` | 系统类型扩展 / system-type extension |
| `UIScrollView` | `cyl_autoHideRefresh` | `cylAutoHideRefresh` | 系统类型扩展 / system-type extension |
| `UIScrollView` | `cyl_endRefreshing` | `cylEndRefreshing` | 系统类型扩展 / system-type extension |
| `UIScrollView` | `cyl_endLoadingMore` | `cylEndLoadingMore` | 系统类型扩展 / system-type extension |
| `UIScrollView` | `cyl_installDefaultRefreshControls` | `cylInstallDefaultRefreshControls` | 系统类型扩展 / system-type extension |
| `UIScrollView` | `cyl_beginRefreshing` | `cylBeginRefreshing` | 系统类型扩展 / system-type extension |
| `UIView` | `cyl_x` | `cylX` | 系统类型扩展 / system-type extension |
| `UIView` | `cyl_y` | `cylY` | 系统类型扩展 / system-type extension |
| `UIView` | `cyl_w` | `cylW` | 系统类型扩展 / system-type extension |
| `UIView` | `cyl_h` | `cylH` | 系统类型扩展 / system-type extension |
| `UIView` | `cyl_size` | `cylSize` | 系统类型扩展 / system-type extension |
| `UIView` | `cyl_origin` | `cylOrigin` | 系统类型扩展 / system-type extension |
| `CYLPlaceholderView` | `cyl_imageViewDidSetImage` | `imageViewDidSetImage` | 自有类型 / own type |
| `UIScrollView` | `cyl_ph_installAutomaticPlaceholder` | `cylPh_installAutomaticPlaceholder` | 系统类型扩展 / system-type extension |
| `UIScrollView` | `cyl_ph_controller` | `cylPh_controller` | 系统类型扩展 / system-type extension |
| `UITableView` | `cyl_placeholderViewBlock` | `cylPlaceholderViewBlock` | 系统类型扩展 / system-type extension |
| `UICollectionView` | `cyl_placeholderViewBlock` | `cylPlaceholderViewBlock` | 系统类型扩展 / system-type extension |
| `UIScrollView` | `cyl_placeholderHidden` | `cylPlaceholderHidden` | 系统类型扩展 / system-type extension |
| `UIScrollView` | `cyl_placeholderView` | `cylPlaceholderView` | 系统类型扩展 / system-type extension |
| `UITableView` | `cyl_reloadData` | `cylReloadData` | 系统类型扩展 / system-type extension |
| `UITableView` | `cyl_scrollWasEnabled` | `cylScrollWasEnabled` | 系统类型扩展 / system-type extension |
| `UITableView` | `cyl_legacyPlaceHolderView` | `cylLegacyPlaceHolderView` | 系统类型扩展 / system-type extension |
| `UITableView` | `cyl_removeLegacyPlaceholder` | `cylRemoveLegacyPlaceholder` | 系统类型扩展 / system-type extension |
| `UIViewController` | `cyl_statusView` | `cylStatusView` | 系统类型扩展 / system-type extension |
| `UIViewController` | `cyl_placeholderScrollView` | `cylPlaceholderScrollView` | 系统类型扩展 / system-type extension |
| `UIViewController` | `cyl_statusDisplay` | `cylStatusDisplay` | 系统类型扩展 / system-type extension |
| `UIViewController` | `cyl_setStatusDisplay` | `cylSetStatusDisplay` | 系统类型扩展 / system-type extension |
| `UIViewController` | `cyl_showsStatusViewWhenOffline` | `cylShowsStatusViewWhenOffline` | 系统类型扩展 / system-type extension |
| `UIViewController` | `cyl_applyStatusConfiguration` | `cylApplyStatusConfiguration` | 系统类型扩展 / system-type extension |
| `UIViewController` | `cyl_showsMissingResources` | `cylShowsMissingResources` | 系统类型扩展 / system-type extension（2026-11-27 合并 PR #35 时补改，`@objc(cyl_showsMissingResources)` / renamed when PR #35 was merged, 2026-11-27, `@objc(cyl_showsMissingResources)`） |
| `CYLRefreshComponent` | `cyl_(afterBeginningAction:)`, `cyl_(afterEndingAction:)` | `afterBeginningAction(_:)`, `afterEndingAction(_:)` | 自有类型 / own type |
| `UILabel` | `cyl_()` | `cylLabel()` | 系统类型扩展 / system-type extension |

## 合并 PR #35（2026-11-27）/ Merging PR #35 (2026-11-27)

| 中文 | English |
| --- | --- |
| 集成分支 `feat/android-refresh-port-followup` 在合并基 `581aeebb` 之后新增的 Swift 代码仍使用旧名。合并时按 `0c8961f6` 的映射（从该提交的逐词 diff 提取，218 个旧名）改名，跳过字符串字面量（插值除外）与 `@objc(…)`；注释中紧跟 `:` 的 Objective-C 选择子写法不改。集成分支新增、映射中没有的名字按同一方案改名：自有类型成员 `cyl_drivenDragBegan` → `drivenDragBegan`、`cyl_drivenReleased` → `drivenReleased`、`cyl_endFinishingHold` → `endFinishingHold`、`cyl_finishAnimationDidEnd` → `finishAnimationDidEnd`，`CYLPlaceholderView` 的私有方法 `cyl_reportMissingResource`、`cyl_applyResourceReport`、`cyl_reapplyAnimationColors`、`cyl_setIconColor`、`cyl_showAnimationAgain` 去掉前缀；系统类型扩展 `UIViewController.cyl_showsMissingResources` → `cylShowsMissingResources`，选择子不变。 | Swift code the integration branch `feat/android-refresh-port-followup` added after the merge base `581aeebb` still used the old names. The merge renamed it with the mapping of `0c8961f6` (taken from that commit's word diff, 218 old names), skipping string literals (not their interpolations) and `@objc(…)`; Objective-C selector spellings followed by `:` in comments stay. Names the integration branch added that the mapping lacks follow the same scheme: own-type members `cyl_drivenDragBegan` → `drivenDragBegan`, `cyl_drivenReleased` → `drivenReleased`, `cyl_endFinishingHold` → `endFinishingHold`, `cyl_finishAnimationDidEnd` → `finishAnimationDidEnd`; `CYLPlaceholderView`'s private `cyl_reportMissingResource`, `cyl_applyResourceReport`, `cyl_reapplyAnimationColors`, `cyl_setIconColor`, `cyl_showAnimationAgain` lose the prefix; the system-type extension `UIViewController.cyl_showsMissingResources` becomes `cylShowsMissingResources` with the selector unchanged. |
