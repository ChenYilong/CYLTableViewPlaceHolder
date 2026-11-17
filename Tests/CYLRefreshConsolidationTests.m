#import <XCTest/XCTest.h>
#import "CYLRefresh.h"

/// The shared state-title and animation-image logic of CYLRefresh (docs/Task-Log.md, the iOS CYLRefresh
/// consolidation): every state control reads its texts from one table, every animation control its images.
@interface CYLRefreshConsolidationTests : XCTestCase
@end

@implementation CYLRefreshConsolidationTests

- (void)testEveryStateControlKeepsItsTitlesTheSameWay {
    NSArray<CYLRefreshComponent *> *controls = @[
        [CYLRefreshStateHeader headerWithRefreshingBlock:^{}],
        [CYLRefreshAutoStateFooter footerWithRefreshingBlock:^{}],
        [CYLRefreshBackStateFooter footerWithRefreshingBlock:^{}],
        [[CYLRefreshStateTrailer alloc] init],
    ];
    for (CYLRefreshComponent *control in controls) {
        id stateControl = control;
        [stateControl setTitle:@"Pull" forState:CYLRefreshStatePulling];
        XCTAssertEqualObjects([stateControl titleForState:CYLRefreshStatePulling], @"Pull", @"%@", control.class);
        XCTAssertEqualObjects([control cyl_stateTitleForState:CYLRefreshStatePulling], @"Pull", @"%@", control.class);
        [control cyl_setStateTitle:nil forState:CYLRefreshStatePulling];
        XCTAssertEqualObjects([stateControl titleForState:CYLRefreshStatePulling], @"Pull", @"nil is ignored: %@", control.class);
    }
}

- (void)testEveryAnimationControlKeepsItsImagesTheSameWay {
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(10, 90)];
    UIImage *tall = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {}];
    NSArray<CYLRefreshComponent *> *controls = @[
        [CYLRefreshAnimationHeader headerWithRefreshingBlock:^{}],
        [CYLRefreshAutoAnimationFooter footerWithRefreshingBlock:^{}],
        [CYLRefreshBackAnimationFooter footerWithRefreshingBlock:^{}],
    ];
    for (CYLRefreshComponent *control in controls) {
        [(id)control setAnimationImages:@[tall, tall] forState:CYLRefreshStateRefreshing];
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
        [(id)footer setNoMoreDataImage:image];
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
