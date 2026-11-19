//  代码地址: https://github.com/ChenYilong/CYLTableViewPlaceHolder
#import <UIKit/UIKit.h>
#import <objc/message.h>
#import <objc/runtime.h>

/*!
 * [CN] 弱引用 [EN] A weak reference to self named weakSelf.
 */
#define CYLWeakSelf __weak typeof(self) weakSelf = self;

/*!
 * [CN] 日志输出（仅 DEBUG） [EN] Logging, in DEBUG builds only.
 */
#ifdef DEBUG
#define CYLRefreshLog(...) NSLog(__VA_ARGS__)
#else
#define CYLRefreshLog(...)
#endif

#ifndef cyl_cguard
/*!
 * [EN] Guard helper: expands to `if (X);`, so `cyl_cguard(condition) else { return; }` leaves early when the
 *      condition is false. Defined only when no other header defines it.
 * [CN] 守卫辅助宏：展开为 `if (X);`，写成 `cyl_cguard(条件) else { return; }`
 *      时条件不成立即提前返回。仅在其他头文件未定义时定义。
 */
#define cyl_cguard(X) if (X);
#endif

/*!
 * [CN] 过期提醒 [EN] Marks a declaration as deprecated with a message.
 */
#define CYLRefreshDeprecated(DESCRIPTION) __attribute__((deprecated(DESCRIPTION)))

/*!
 * [CN] 运行时 objc_msgSend [EN] Calls objc_msgSend with a view argument.
 */
#define CYLRefreshMsgSend(...) ((void (*)(void *, SEL, UIView *))objc_msgSend)(__VA_ARGS__)
/*!
 * [EN] Bridges an object to the `void *` receiver that `CYLRefreshMsgSend` takes, without changing its ownership.
 * [CN] 把对象桥接为 `CYLRefreshMsgSend` 需要的 `void *` 接收者，不改变其所有权。
 */
#define CYLRefreshMsgTarget(target) (__bridge void *)(target)

/*!
 * [CN] RGB 颜色 [EN] A color from 0–255 red, green and blue values.
 */
#define CYLRefreshColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

/*!
 * [CN] 文字颜色 [EN] The default text color of the refresh labels.
 */
#define CYLRefreshLabelTextColor CYLRefreshColor(90, 90, 90)

/*!
 * [CN] 字体大小 [EN] The default font of the refresh labels.
 */
#define CYLRefreshLabelFont [UIFont boldSystemFontOfSize:14]

/*!
 * [CN] 常量 [EN] Layout constants and keys of the refresh components.
 */
UIKIT_EXTERN const CGFloat CYLRefreshLabelLeftInset;
/*!
 * [EN] The height of a refresh header, 54 points; a header sets it as its height when it is prepared.
 * [CN] 刷新头的高度，54 点；刷新头在 prepare 时设为自己的高度。
 */
UIKIT_EXTERN const CGFloat CYLRefreshHeaderHeight;
/*!
 * [EN] The height of a refresh footer, 44 points; a footer sets it as its height when it is prepared.
 * [CN] 刷新尾的高度，44 点；刷新尾在 prepare 时设为自己的高度。
 */
UIKIT_EXTERN const CGFloat CYLRefreshFooterHeight;
/*!
 * [EN] The width of a refresh trailer (the horizontal "swipe to see details" component), 60 points.
 * [CN] 刷新 trailer（横向“滑动查看详情”组件）的宽度，60 点。
 */
UIKIT_EXTERN const CGFloat CYLRefreshTrailWidth;
/*!
 * [EN] 0.25 seconds: the duration of the fast refresh animations, the default of `fastAnimationDuration`.
 * [CN] 0.25 秒：快速刷新动画的时长，即 `fastAnimationDuration` 的默认值。
 */
UIKIT_EXTERN const CGFloat CYLRefreshFastAnimationDuration;
/*!
 * [EN] 0.4 seconds: the duration of the slow refresh animations, the default of `slowAnimationDuration`.
 * [CN] 0.4 秒：慢速刷新动画的时长，即 `slowAnimationDuration` 的默认值。
 */
UIKIT_EXTERN const CGFloat CYLRefreshSlowAnimationDuration;


/*!
 * [EN] The key path `contentOffset`, which a refresh component observes on its scroll view to follow the pull.
 * [CN] 键路径 `contentOffset`：刷新组件在其滚动视图上观察它以跟随拖动。
 */
UIKIT_EXTERN NSString *const CYLRefreshKeyPathContentOffset;
/*!
 * [EN] The key path `contentSize`, which a refresh component observes on its scroll view (a footer follows the
 *      content's end).
 * [CN] 键路径 `contentSize`：刷新组件在其滚动视图上观察它（刷新尾跟随内容末尾）。
 */
UIKIT_EXTERN NSString *const CYLRefreshKeyPathContentSize;
/*!
 * [EN] The key path `contentInset` of the scroll view, as the refresh components spell it.
 * [CN] 滚动视图的键路径 `contentInset`，供刷新组件使用。
 */
UIKIT_EXTERN NSString *const CYLRefreshKeyPathContentInset;
/*!
 * [EN] The key path `state`, which a refresh component observes on the scroll view's pan gesture recognizer to see
 *      the drag end.
 * [CN] 键路径 `state`：刷新组件在滚动视图的拖动手势上观察它，以得知拖动结束。
 */
UIKIT_EXTERN NSString *const CYLRefreshKeyPathPanState;

/*!
 * [EN] The default `lastUpdatedTimeKey` of a header: the `NSUserDefaults` key under which it saves the time of its
 *      last refresh.
 * [CN] 刷新头 `lastUpdatedTimeKey` 的默认值：保存上次刷新时间所用的 `NSUserDefaults` 键。
 */
UIKIT_EXTERN NSString *const CYLRefreshHeaderLastUpdatedTimeKey;

/*!
 * [EN] The localization key of the header's idle text (English "Pull down to refresh").
 * [CN] 刷新头闲置状态文案的本地化键（英文 "Pull down to refresh"）。
 */
UIKIT_EXTERN NSString *const CYLRefreshHeaderIdleText;
/*!
 * [EN] The localization key of the header's pulling text (English "Release to refresh").
 * [CN] 刷新头松手即刷新状态文案的本地化键（英文 "Release to refresh"）。
 */
UIKIT_EXTERN NSString *const CYLRefreshHeaderPullingText;
/*!
 * [EN] The localization key of the header's refreshing text (English "Loading...").
 * [CN] 刷新头刷新中文案的本地化键（英文 "Loading..."）。
 */
UIKIT_EXTERN NSString *const CYLRefreshHeaderRefreshingText;

/*!
 * [EN] The localization key of the trailer's idle text (English "Swipe to see details").
 * [CN] trailer 闲置状态文案的本地化键（英文 "Swipe to see details"）。
 */
UIKIT_EXTERN NSString *const CYLRefreshTrailerIdleText;
/*!
 * [EN] The localization key of the trailer's pulling text (English "Release to see details").
 * [CN] trailer 松手状态文案的本地化键（英文 "Release to see details"）。
 */
UIKIT_EXTERN NSString *const CYLRefreshTrailerPullingText;

/*!
 * [EN] The localization key of the automatic footer's idle text (English "Tap or pull up to load more").
 * [CN] 自动刷新尾闲置状态文案的本地化键（英文 "Tap or pull up to load more"）。
 */
UIKIT_EXTERN NSString *const CYLRefreshAutoFooterIdleText;
/*!
 * [EN] The localization key of the automatic footer's loading text (English "Loading...").
 * [CN] 自动刷新尾加载中文案的本地化键（英文 "Loading..."）。
 */
UIKIT_EXTERN NSString *const CYLRefreshAutoFooterRefreshingText;
/*!
 * [EN] The localization key of the automatic footer's no-more-data text (English "No more data").
 * [CN] 自动刷新尾没有更多数据文案的本地化键（英文 "No more data"）。
 */
UIKIT_EXTERN NSString *const CYLRefreshAutoFooterNoMoreDataText;

/*!
 * [EN] The localization key of the back footer's idle text (English "Pull up to load more").
 * [CN] 回弹刷新尾闲置状态文案的本地化键（英文 "Pull up to load more"）。
 */
UIKIT_EXTERN NSString *const CYLRefreshBackFooterIdleText;
/*!
 * [EN] The localization key of the back footer's pulling text (English "Release to load more").
 * [CN] 回弹刷新尾松手即加载状态文案的本地化键（英文 "Release to load more"）。
 */
UIKIT_EXTERN NSString *const CYLRefreshBackFooterPullingText;
/*!
 * [EN] The localization key of the back footer's loading text (English "Loading...").
 * [CN] 回弹刷新尾加载中文案的本地化键（英文 "Loading..."）。
 */
UIKIT_EXTERN NSString *const CYLRefreshBackFooterRefreshingText;
/*!
 * [EN] The localization key of the back footer's no-more-data text (English "No more data").
 * [CN] 回弹刷新尾没有更多数据文案的本地化键（英文 "No more data"）。
 */
UIKIT_EXTERN NSString *const CYLRefreshBackFooterNoMoreDataText;

/*!
 * [EN] The localization key of the text a state header shows after a successful refresh (English "Refresh complete").
 * [CN] 状态刷新头刷新成功后显示文案的本地化键（英文 "Refresh complete"）。
 */
UIKIT_EXTERN NSString *const CYLRefreshHeaderFinishedText;
/*!
 * [EN] The localization key of the text a state header shows after a failed refresh (English "Refresh failed").
 * [CN] 状态刷新头刷新失败后显示文案的本地化键（英文 "Refresh failed"）。
 */
UIKIT_EXTERN NSString *const CYLRefreshHeaderFailedText;
/*!
 * [EN] The localization key of the text a state footer shows after a successful load (English "Load complete").
 * [CN] 状态刷新尾加载成功后显示文案的本地化键（英文 "Load complete"）。
 */
UIKIT_EXTERN NSString *const CYLRefreshFooterFinishedText;
/*!
 * [EN] The localization key of the text a state footer shows after a failed load (English "Load failed").
 * [CN] 状态刷新尾加载失败后显示文案的本地化键（英文 "Load failed"）。
 */
UIKIT_EXTERN NSString *const CYLRefreshFooterFailedText;

/*!
 * [EN] The localization key of the prefix of the header's last-updated line (English "Last update: ").
 * [CN] 刷新头“最后更新”一行前缀的本地化键（英文 "Last update: "）。
 */
UIKIT_EXTERN NSString *const CYLRefreshHeaderLastTimeText;
/*!
 * [EN] The localization key of the word for today in the header's last-updated line (English "Today").
 * [CN] 刷新头“最后更新”一行中“今天”的本地化键（英文 "Today"）。
 */
UIKIT_EXTERN NSString *const CYLRefreshHeaderDateTodayText;
/*!
 * [EN] The localization key shown in the last-updated line when the header has never refreshed (English "No record").
 * [CN] 刷新头从未刷新过时“最后更新”一行显示内容的本地化键（英文 "No record"）。
 */
UIKIT_EXTERN NSString *const CYLRefreshHeaderNoneLastDateText;

/*!
 * [EN] Posted by `CYLRefreshConfig.defaultConfig` when its language changes; every refresh component observes it and
 *      reloads its texts.
 * [CN] `CYLRefreshConfig.defaultConfig` 的语言改变时发出；每个刷新组件监听它并重新加载文案。
 */
UIKIT_EXTERN NSString *const CYLRefreshDidChangeLanguageNotification;

/*!
 * [CN] 状态检查：状态未变时返回，否则调用 super [EN] Returns when the state did not change, else calls super.
 */
#define CYLRefreshCheckState \
CYLRefreshState oldState = self.state; \
if (state == oldState) return; \
[super setState:state];

/*!
 * [CN] 异步主线程执行，不强持有 self [EN] Runs the code asynchronously on the main queue without retaining self.
 */
#define CYLRefreshDispatchAsyncOnMainQueue(x) \
__weak typeof(self) weakSelf = self; \
dispatch_async(dispatch_get_main_queue(), ^{ \
typeof(weakSelf) self = weakSelf; \
{x} \
});

/*!
 * 替换方法实现
 * @param _fromClass 源类
 * @param _originSelector 源类的 Selector
 * @param _toClass  目标类
 * @param _newSelector 目标类的 Selector
 */
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
