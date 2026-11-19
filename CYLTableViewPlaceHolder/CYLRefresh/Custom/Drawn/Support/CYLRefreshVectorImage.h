//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Vector/VectorImage.h (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.
//
//  [EN] Swift since 2026-11-19: the class is in `CYLRefreshVectorImage.swift` (docs/Swift-Migration.md, step 7), with the same
//       Objective-C API. Objective-C code that uses it imports the umbrella header `CYLTableViewPlaceHolder.h`, which
//       brings the generated Swift header; this header keeps the forward declaration.
//  [CN] 自 2026-11-19 起该类用 Swift 编写（`CYLRefreshVectorImage.swift`，docs/Swift-Migration.md 第 7 步），Objective-C API 不变。使用它的
//       Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）；本头文件保留前向声明。

#import <UIKit/UIKit.h>

@class CYLRefreshVectorImage;
