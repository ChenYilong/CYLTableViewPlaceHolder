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

@end
