//
//  CYLRefreshComponentSupport.m
//  CYLRefresh
//

// [EN] The Objective-C part of `CYLRefreshComponent` (Swift since 2026-11-20, `CYLRefreshComponent.swift`), what Swift
//      cannot express (docs/Swift-Migration.md, rule 6): the variadic `-isInPhases:`.
// [CN] `CYLRefreshComponent`（自 2026-11-20 起用 Swift 编写，见 `CYLRefreshComponent.swift`）的 Objective-C 部分，即 Swift 无法表达的
//      部分（docs/Swift-Migration.md 第 6 条）：可变参数的 `-isInPhases:`。

// [EN] The umbrella header brings the generated Swift header (the class) and the category's declaration.
// [CN] 总头文件导入生成的 Swift 头文件（该类）与本分类的声明。
#import "CYLTableViewPlaceHolder.h"

@implementation CYLRefreshComponent (CYLPhaseList)

- (BOOL)isInPhases:(CYLRefreshPhase)phase, ...
{
    if (phase == 0) return NO;
    CYLRefreshPhase current = self.phase;
    if (phase == current) return YES;
    // [EN] Enum arguments are promoted to int in a variadic call; the list ends with 0.
    // [CN] 可变参数中的枚举会提升为 int；列表以 0 结尾。
    va_list args;
    va_start(args, phase);
    BOOL found = NO;
    for (int next = va_arg(args, int); next != 0; next = va_arg(args, int)) {
        if (next == (int)current) { found = YES; break; }
    }
    va_end(args);
    return found;
}

@end
