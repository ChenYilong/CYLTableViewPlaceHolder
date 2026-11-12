//  代码地址: https://github.com/ChenYilong/CYLTableViewPlaceHolder
#import <UIKit/UIKit.h>

const CGFloat CYLRefreshLabelLeftInset = 25;
const CGFloat CYLRefreshHeaderHeight = 54.0;
const CGFloat CYLRefreshFooterHeight = 44.0;
const CGFloat CYLRefreshTrailWidth = 60.0;
const CGFloat CYLRefreshFastAnimationDuration = 0.25;
const CGFloat CYLRefreshSlowAnimationDuration = 0.4;


NSString *const CYLRefreshKeyPathContentOffset = @"contentOffset";
NSString *const CYLRefreshKeyPathContentInset = @"contentInset";
NSString *const CYLRefreshKeyPathContentSize = @"contentSize";
NSString *const CYLRefreshKeyPathPanState = @"state";

NSString *const CYLRefreshHeaderLastUpdatedTimeKey = @"CYLRefreshHeaderLastUpdatedTimeKey";

NSString *const CYLRefreshHeaderIdleText = @"CYLRefreshHeaderIdleText";
NSString *const CYLRefreshHeaderPullingText = @"CYLRefreshHeaderPullingText";
NSString *const CYLRefreshHeaderRefreshingText = @"CYLRefreshHeaderRefreshingText";

NSString *const CYLRefreshTrailerIdleText = @"CYLRefreshTrailerIdleText";
NSString *const CYLRefreshTrailerPullingText = @"CYLRefreshTrailerPullingText";

NSString *const CYLRefreshAutoFooterIdleText = @"CYLRefreshAutoFooterIdleText";
NSString *const CYLRefreshAutoFooterRefreshingText = @"CYLRefreshAutoFooterRefreshingText";
NSString *const CYLRefreshAutoFooterNoMoreDataText = @"CYLRefreshAutoFooterNoMoreDataText";

NSString *const CYLRefreshBackFooterIdleText = @"CYLRefreshBackFooterIdleText";
NSString *const CYLRefreshBackFooterPullingText = @"CYLRefreshBackFooterPullingText";
NSString *const CYLRefreshBackFooterRefreshingText = @"CYLRefreshBackFooterRefreshingText";
NSString *const CYLRefreshBackFooterNoMoreDataText = @"CYLRefreshBackFooterNoMoreDataText";

NSString *const CYLRefreshHeaderFinishedText = @"CYLRefreshHeaderFinishedText";
NSString *const CYLRefreshHeaderFailedText = @"CYLRefreshHeaderFailedText";
NSString *const CYLRefreshFooterFinishedText = @"CYLRefreshFooterFinishedText";
NSString *const CYLRefreshFooterFailedText = @"CYLRefreshFooterFailedText";

NSString *const CYLRefreshHeaderLastTimeText = @"CYLRefreshHeaderLastTimeText";
NSString *const CYLRefreshHeaderDateTodayText = @"CYLRefreshHeaderDateTodayText";
NSString *const CYLRefreshHeaderNoneLastDateText = @"CYLRefreshHeaderNoneLastDateText";

NSString *const CYLRefreshDidChangeLanguageNotification = @"CYLRefreshDidChangeLanguageNotification";
