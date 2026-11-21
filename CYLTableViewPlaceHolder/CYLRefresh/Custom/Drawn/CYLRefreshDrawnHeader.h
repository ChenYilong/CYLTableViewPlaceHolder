//
//  CYLRefreshDrawnHeader.h
//  CYLRefresh
//
//  The base of the hand-drawn CYLRefresh styles (third-party refresh code, MIT, see LICENSE.refresh-third-party.txt):
//  it offers the styles' subclass API (`UIRefreshComponent` / `UIRefreshHeader`) on top of CYLRefresh's
//  phases, so each ported style keeps its original drawing code.
//
//  [EN] Swift since 2026-11-19: the class is in `CYLRefreshDrawnHeader.swift` (docs/Swift-Migration.md, step 9), with the
//       same Objective-C API (`width`, `height`, `durationFast`, `durationNormal`, `status`, `dragOffset`, `dragPercent`,
//       `isSuccess` and the style hooks). The variadic `-inStatus:` stays Objective-C, in
//       `CYLRefreshDrawnHeader+CYLStatusList.h`. Objective-C code that uses the class imports the umbrella header
//       `CYLTableViewPlaceHolder.h`, which brings the generated Swift header and that category; this header keeps the
//       forward declaration. Objective-C cannot subclass a Swift class: subclasses are written in Swift.
//  [CN] 自 2026-11-19 起该类用 Swift 编写（`CYLRefreshDrawnHeader.swift`，docs/Swift-Migration.md 第 9 步），Objective-C API 不变
//       （`width`、`height`、`durationFast`、`durationNormal`、`status`、`dragOffset`、`dragPercent`、`isSuccess` 与各样式钩子）。可变参数的
//       `-inStatus:` 保留为 Objective-C，见 `CYLRefreshDrawnHeader+CYLStatusList.h`。使用该类的 Objective-C 代码请导入总头文件
//       `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件与该分类）；本头文件保留前向声明。Objective-C 不能继承 Swift 类：子类请用 Swift 编写。
//

#import "CYLRefreshHeader.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] A header whose look is drawn in code (Core Graphics, layers or SpriteKit); subclasses override the style-named
 *      hooks, and the base maps CYLRefresh's phases onto them in the CYLRefresh styles' order. The class is Swift
 *      (`CYLRefreshDrawnHeader.swift`); Objective-C code that messages it imports the umbrella header
 *      `CYLTableViewPlaceHolder.h`, which brings the generated Swift header.
 * [CN] 用代码绘制外观（Core Graphics、图层或 SpriteKit）的刷新头；子类重写以样式命名的钩子，基类按 CYLRefresh styles 的顺序把
 *      CYLRefresh 的阶段映射到这些钩子上。该类用 Swift 编写（`CYLRefreshDrawnHeader.swift`）；需要调用它的 Objective-C 代码请导入
 *      总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）。
 */
@class CYLRefreshDrawnHeader;

NS_ASSUME_NONNULL_END
