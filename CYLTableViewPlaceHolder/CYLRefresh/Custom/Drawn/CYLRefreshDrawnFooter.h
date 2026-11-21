//
//  CYLRefreshDrawnFooter.h
//  CYLRefresh
//
//  flutter_easy_refresh's BezierFooter, MaterialFooter, DeliveryFooter, PhoenixFooter and TaurusFooter
//  (https://github.com/xuelongqy/flutter_easy_refresh, MIT) reuse the drawing of the matching headers. Here a footer
//  hosts one drawn header and passes it the pull, the progress and the status, so every drawn style can load more.
//
//  [EN] Swift since 2026-11-19: the classes are in `CYLRefreshDrawnFooter.swift` (docs/Swift-Migration.md, step 8), with
//       the same Objective-C API (`+styleClass`, `-initWithStyle:`, `style`; `normalColor` and `animatingColor` of the
//       Ball Pulse footer). Objective-C code that uses them imports the umbrella header `CYLTableViewPlaceHolder.h`, which
//       brings the generated Swift header; this header keeps the forward declarations.
//  [CN] 自 2026-11-19 起这些类用 Swift 编写（`CYLRefreshDrawnFooter.swift`，docs/Swift-Migration.md 第 8 步），Objective-C API 不变
//       （`+styleClass`、`-initWithStyle:`、`style`；Ball Pulse 刷新尾的 `normalColor` 与 `animatingColor`）。使用它们的 Objective-C 代码请
//       导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）；本头文件保留前向声明。
//

#import "CYLRefreshBackStateFooter.h"
#import "CYLRefreshDrawnHeader.h"
#import "CYLRefreshAutoFooter.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] A pull-up footer drawn by a hosted drawn header (`style`), with its five subclasses
 *      `CYLRefreshBezierRadarFooter`, `CYLRefreshMaterialFooter`, `CYLRefreshDeliveryFooter`, `CYLRefreshPhoenixFooter`
 *      and `CYLRefreshTaurusFooter`. The classes are Swift (`CYLRefreshDrawnFooter.swift`); Objective-C code that messages
 *      them imports the umbrella header `CYLTableViewPlaceHolder.h`, which brings the generated Swift header.
 * [CN] 由内嵌的手绘刷新头（`style`）绘制的上拉刷新尾，及其五个子类 `CYLRefreshBezierRadarFooter`、`CYLRefreshMaterialFooter`、
 *      `CYLRefreshDeliveryFooter`、`CYLRefreshPhoenixFooter` 与 `CYLRefreshTaurusFooter`。这些类用 Swift 编写
 *      （`CYLRefreshDrawnFooter.swift`）；需要调用它们的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）。
 */
@class CYLRefreshDrawnFooter, CYLRefreshBezierRadarFooter, CYLRefreshMaterialFooter, CYLRefreshDeliveryFooter,
    CYLRefreshPhoenixFooter, CYLRefreshTaurusFooter;

/*!
 * [EN] Three balls that pulse in turn while loading more; an auto footer (Android CYLRefreshLayout's
 *      `BallPulseFooter`). The class is Swift (`CYLRefreshDrawnFooter.swift`).
 * [CN] 加载更多时依次跳动的三个小球；自动加载尾部（对应 Android CYLRefreshLayout 的 `BallPulseFooter`）。该类用 Swift 编写
 *      （`CYLRefreshDrawnFooter.swift`）。
 */
@class CYLRefreshBallPulseFooter;

NS_ASSUME_NONNULL_END
