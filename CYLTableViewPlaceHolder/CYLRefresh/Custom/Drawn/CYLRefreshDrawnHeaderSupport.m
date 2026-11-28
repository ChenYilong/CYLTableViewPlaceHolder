//
//  CYLRefreshDrawnHeaderSupport.m
//  CYLRefresh
//

// [EN] The Objective-C part of `CYLRefreshDrawnHeader` (Swift since 2026-11-19, `CYLRefreshDrawnHeader.swift`), what Swift
//      cannot express (docs/Swift-Migration.md, rule 6): the variadic `-inStatus:`.
// [CN] `CYLRefreshDrawnHeader`（自 2026-11-19 起用 Swift 编写，见 `CYLRefreshDrawnHeader.swift`）的 Objective-C 部分，即 Swift 无法表达的
//      部分（docs/Swift-Migration.md 第 6 条）：可变参数的 `-inStatus:`。

// [EN] The umbrella header brings the generated Swift header (the class) and the category's declaration.
// [CN] 总头文件导入生成的 Swift 头文件（该类）与本分类的声明。
#import "CYLTableViewPlaceHolder.h"

@implementation CYLRefreshDrawnHeader (CYLStatusList)

- (BOOL)inStatus:(CYLRefreshPhase)status, ...
{
    if (status == 0) return NO;
    if (status == self.status) return YES;
    va_list args;
    va_start(args, status);
    BOOL found = NO;
    for (int next = va_arg(args, int); next != 0; next = va_arg(args, int)) {
        if (next == (int)self.status) { found = YES; break; }
    }
    va_end(args);
    return found;
}

@end
