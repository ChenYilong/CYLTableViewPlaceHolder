//  代码地址: https://github.com/ChenYilong/CYLTableViewPlaceHolder
#import <UIKit/UIKit.h>
#import <objc/message.h>
#import <objc/runtime.h>

// 弱引用
#define CYLWeakSelf __weak typeof(self) weakSelf = self;

// 日志输出
#ifdef DEBUG
#define CYLRefreshLog(...) NSLog(__VA_ARGS__)
#else
#define CYLRefreshLog(...)
#endif

#ifndef cyl_cguard
#define cyl_cguard(X) if (X);
#endif

// 过期提醒
#define CYLRefreshDeprecated(DESCRIPTION) __attribute__((deprecated(DESCRIPTION)))

// 运行时objc_msgSend
#define CYLRefreshMsgSend(...) ((void (*)(void *, SEL, UIView *))objc_msgSend)(__VA_ARGS__)
#define CYLRefreshMsgTarget(target) (__bridge void *)(target)

// RGB颜色
#define CYLRefreshColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

// 文字颜色
#define CYLRefreshLabelTextColor CYLRefreshColor(90, 90, 90)

// 字体大小
#define CYLRefreshLabelFont [UIFont boldSystemFontOfSize:14]

// 常量
UIKIT_EXTERN const CGFloat CYLRefreshLabelLeftInset;
UIKIT_EXTERN const CGFloat CYLRefreshHeaderHeight;
UIKIT_EXTERN const CGFloat CYLRefreshFooterHeight;
UIKIT_EXTERN const CGFloat CYLRefreshTrailWidth;
UIKIT_EXTERN const CGFloat CYLRefreshFastAnimationDuration;
UIKIT_EXTERN const CGFloat CYLRefreshSlowAnimationDuration;


UIKIT_EXTERN NSString *const CYLRefreshKeyPathContentOffset;
UIKIT_EXTERN NSString *const CYLRefreshKeyPathContentSize;
UIKIT_EXTERN NSString *const CYLRefreshKeyPathContentInset;
UIKIT_EXTERN NSString *const CYLRefreshKeyPathPanState;

UIKIT_EXTERN NSString *const CYLRefreshHeaderLastUpdatedTimeKey;

UIKIT_EXTERN NSString *const CYLRefreshHeaderIdleText;
UIKIT_EXTERN NSString *const CYLRefreshHeaderPullingText;
UIKIT_EXTERN NSString *const CYLRefreshHeaderRefreshingText;

UIKIT_EXTERN NSString *const CYLRefreshTrailerIdleText;
UIKIT_EXTERN NSString *const CYLRefreshTrailerPullingText;

UIKIT_EXTERN NSString *const CYLRefreshAutoFooterIdleText;
UIKIT_EXTERN NSString *const CYLRefreshAutoFooterRefreshingText;
UIKIT_EXTERN NSString *const CYLRefreshAutoFooterNoMoreDataText;

UIKIT_EXTERN NSString *const CYLRefreshBackFooterIdleText;
UIKIT_EXTERN NSString *const CYLRefreshBackFooterPullingText;
UIKIT_EXTERN NSString *const CYLRefreshBackFooterRefreshingText;
UIKIT_EXTERN NSString *const CYLRefreshBackFooterNoMoreDataText;

UIKIT_EXTERN NSString *const CYLRefreshHeaderLastTimeText;
UIKIT_EXTERN NSString *const CYLRefreshHeaderDateTodayText;
UIKIT_EXTERN NSString *const CYLRefreshHeaderNoneLastDateText;

UIKIT_EXTERN NSString *const CYLRefreshDidChangeLanguageNotification;

// 状态检查
#define CYLRefreshCheckState \
CYLRefreshState oldState = self.state; \
if (state == oldState) return; \
[super setState:state];

// 异步主线程执行，不强持有Self
#define CYLRefreshDispatchAsyncOnMainQueue(x) \
__weak typeof(self) weakSelf = self; \
dispatch_async(dispatch_get_main_queue(), ^{ \
typeof(weakSelf) self = weakSelf; \
{x} \
});

/// 替换方法实现
/// @param _fromClass 源类
/// @param _originSelector 源类的 Selector
/// @param _toClass  目标类
/// @param _newSelector 目标类的 Selector
CG_INLINE BOOL CYLRefreshExchangeImplementations(
                                                Class _fromClass, SEL _originSelector,
                                                Class _toClass, SEL _newSelector) {
    if (!_fromClass || !_toClass) {
        return NO;
    }

    Method oriMethod = class_getInstanceMethod(_fromClass, _originSelector);
    Method newMethod = class_getInstanceMethod(_toClass, _newSelector);
    if (!newMethod) {
        return NO;
    }

    BOOL isAddedMethod = class_addMethod(_fromClass, _originSelector,
                                         method_getImplementation(newMethod),
                                         method_getTypeEncoding(newMethod));
    if (isAddedMethod) {
        // 如果 class_addMethod 成功了，说明之前 fromClass 里并不存在 originSelector，所以要用一个空的方法代替它，以避免 class_replaceMethod 后，后续 toClass 的这个方法被调用时可能会 crash
        IMP emptyIMP = imp_implementationWithBlock(^(id selfObject) {});
        IMP oriMethodIMP = method_getImplementation(oriMethod) ?: emptyIMP;
        const char *oriMethodTypeEncoding = method_getTypeEncoding(oriMethod) ?: "v@:";
        class_replaceMethod(_toClass, _newSelector, oriMethodIMP, oriMethodTypeEncoding);
    } else {
        method_exchangeImplementations(oriMethod, newMethod);
    }
    return YES;
}
