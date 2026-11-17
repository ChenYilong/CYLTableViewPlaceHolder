#import <XCTest/XCTest.h>
#import "CYLRefresh.h"

/// The shared state-title and animation-image logic of CYLRefresh (docs/Task-Log.md, the iOS CYLRefresh
/// consolidation): every state control reads its texts from one table, every animation control its images.
@interface CYLRefreshConsolidationTests : XCTestCase
@end

@implementation CYLRefreshConsolidationTests

- (void)testEveryStateControlKeepsItsTitlesTheSameWay {
    // [EN] Typed receivers: on `id`, `setTitle:forState:` is ambiguous with UIButton's.
    // [CN] 使用具体类型：在 `id` 上，`setTitle:forState:` 与 UIButton 的同名方法冲突。
    CYLRefreshStateHeader *header = [CYLRefreshStateHeader headerWithRefreshingBlock:^{}];
    CYLRefreshAutoStateFooter *autoFooter = [CYLRefreshAutoStateFooter footerWithRefreshingBlock:^{}];
    CYLRefreshBackStateFooter *backFooter = [CYLRefreshBackStateFooter footerWithRefreshingBlock:^{}];
    CYLRefreshStateTrailer *trailer = [[CYLRefreshStateTrailer alloc] init];
    [header setTitle:@"Pull" forState:CYLRefreshStatePulling];
    [autoFooter setTitle:@"Pull" forState:CYLRefreshStatePulling];
    [backFooter setTitle:@"Pull" forState:CYLRefreshStatePulling];
    [trailer setTitle:@"Pull" forState:CYLRefreshStatePulling];
    XCTAssertEqualObjects([header titleForState:CYLRefreshStatePulling], @"Pull");
    XCTAssertEqualObjects([autoFooter titleForState:CYLRefreshStatePulling], @"Pull");
    XCTAssertEqualObjects([backFooter titleForState:CYLRefreshStatePulling], @"Pull");
    XCTAssertEqualObjects([trailer titleForState:CYLRefreshStatePulling], @"Pull");
    for (CYLRefreshComponent *control in @[header, autoFooter, backFooter, trailer]) {
        XCTAssertEqualObjects([control cyl_stateTitleForState:CYLRefreshStatePulling], @"Pull", @"%@", control.class);
        [control cyl_setStateTitle:nil forState:CYLRefreshStatePulling];
        XCTAssertEqualObjects([control cyl_stateTitleForState:CYLRefreshStatePulling], @"Pull", @"nil is ignored: %@", control.class);
    }
}

- (void)testEveryAnimationControlKeepsItsImagesTheSameWay {
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(10, 90)];
    UIImage *tall = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {}];
    CYLRefreshAnimationHeader *header = [CYLRefreshAnimationHeader headerWithRefreshingBlock:^{}];
    CYLRefreshAutoAnimationFooter *autoFooter = [CYLRefreshAutoAnimationFooter footerWithRefreshingBlock:^{}];
    CYLRefreshBackAnimationFooter *backFooter = [CYLRefreshBackAnimationFooter footerWithRefreshingBlock:^{}];
    [header setAnimationImages:@[tall, tall] forState:CYLRefreshStateRefreshing];
    [autoFooter setAnimationImages:@[tall, tall] forState:CYLRefreshStateRefreshing];
    [backFooter setAnimationImages:@[tall, tall] forState:CYLRefreshStateRefreshing];
    for (CYLRefreshComponent *control in @[header, autoFooter, backFooter]) {
        XCTAssertEqual([control cyl_animationImagesForState:CYLRefreshStateRefreshing].count, 2u, @"%@", control.class);
        XCTAssertGreaterThanOrEqual(control.bounds.size.height, 90, @"grows to the tallest image: %@", control.class);
        XCTAssertTrue(control.cyl_usesIconView, @"the images become the icon: %@", control.class);
    }
}

- (void)testBothNormalFootersShowTheNoMoreDataImageOnlyWithoutMoreData {
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(12, 12)];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {}];
    NSArray<CYLRefreshFooter *> *footers = @[
        [CYLRefreshAutoNormalFooter footerWithRefreshingBlock:^{}],
        [CYLRefreshBackNormalFooter footerWithRefreshingBlock:^{}],
    ];
    for (CYLRefreshFooter *footer in footers) {
        footer.frame = CGRectMake(0, 0, 320, 44);
        if ([footer isKindOfClass:CYLRefreshAutoNormalFooter.class]) ((CYLRefreshAutoNormalFooter *)footer).noMoreDataImage = image;
        else ((CYLRefreshBackNormalFooter *)footer).noMoreDataImage = image;
        UIImageView *(^shown)(void) = ^UIImageView * {
            for (UIView *view in footer.subviews) {
                if ([view isMemberOfClass:UIImageView.class] && ((UIImageView *)view).image == image && !view.hidden) return (UIImageView *)view;
            }
            return nil;
        };
        XCTAssertNil(shown(), @"hidden while idle: %@", footer.class);
        [footer endRefreshingWithNoMoreData];
        // [EN] The state changes on the next main-queue turn. [CN] 状态在下一个主队列循环中改变。
        NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:3];
        while (!shown() && deadline.timeIntervalSinceNow > 0) {
            [NSRunLoop.mainRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.05]];
            [footer layoutIfNeeded];
        }
        XCTAssertNotNil(shown(), @"shown without more data: %@", footer.class);
    }
}

@end
