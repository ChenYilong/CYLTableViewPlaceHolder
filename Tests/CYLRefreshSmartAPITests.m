#import <XCTest/XCTest.h>
#import "CYLRefresh.h"
#import "UIView+CYLExtension.h"

/// SmartRefreshControl-style API on CYLRefresh: attach / addTarget, triggerRate, finishDuration with a result,
/// phases, scroll modes, theme colors and the subclass hooks (docs/Refresh-Library-Parity.md).
@interface CYLRefreshSmartAPITests : XCTestCase
@property (nonatomic) NSInteger targetCalls;
@property (nonatomic, weak) id lastSender;
@end

@interface CYLHookHeader : CYLRefreshNormalHeader
@property (nonatomic) NSInteger attachCount;
@property (nonatomic) NSMutableArray<NSNumber *> *phases;
@property (nonatomic) NSNumber *finishedWith;
@end

@implementation CYLHookHeader
- (void)didAttachToScrollView:(UIScrollView *)scrollView { [super didAttachToScrollView:scrollView]; self.attachCount++; }
- (void)phaseDidChangeFrom:(CYLRefreshPhase)oldPhase to:(CYLRefreshPhase)phase {
    if (!self.phases) self.phases = [NSMutableArray array];
    [self.phases addObject:@(phase)];
}
- (void)refreshDidFinishWithSuccess:(BOOL)success { [super refreshDidFinishWithSuccess:success]; self.finishedWith = @(success); }
@end

@implementation CYLRefreshSmartAPITests

- (void)onRefresh:(id)sender {
    self.targetCalls++;
    self.lastSender = sender;
}

- (UIScrollView *)scrollView {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    scrollView.contentSize = CGSizeMake(320, 2000);
    return scrollView;
}

- (void)testAttachPicksTheSlotByClassAndCallsEveryTarget {
    UIScrollView *scrollView = [self scrollView];
    CYLRefreshNormalHeader *header = [CYLRefreshNormalHeader attach:scrollView target:self action:@selector(onRefresh:)];
    XCTAssertEqual(scrollView.cyl_header, header);
    XCTAssertTrue(header.isAttached);
    CYLRefreshAutoNormalFooter *footer = [CYLRefreshAutoNormalFooter attach:scrollView];
    XCTAssertEqual(scrollView.cyl_footer, footer);
    CYLRefreshNormalTrailer *trailer = [CYLRefreshNormalTrailer new];
    [trailer attach:scrollView];
    XCTAssertEqual(scrollView.cyl_trailer, trailer);

    __block id handled = nil;
    header.refreshingHandler = ^(CYLRefreshComponent *component) { handled = component; };
    [header addTarget:self action:@selector(onRefresh:)];
    [header executeRefreshingCallback];
    XCTAssertEqual(self.targetCalls, 2, @"both added target-actions run");
    XCTAssertEqual(self.lastSender, header);
    XCTAssertEqual(handled, header, @"the handler gets the control");
    [header removeTarget:self action:@selector(onRefresh:)];
    [header executeRefreshingCallback];
    XCTAssertEqual(self.targetCalls, 2, @"removed");
    scrollView.cyl_header = nil;
    XCTAssertFalse(header.isAttached);
}

- (void)testTriggerRateScalesThePullDistance {
    UIScrollView *scrollView = [self scrollView];
    CYLRefreshNormalHeader *header = [CYLRefreshNormalHeader attach:scrollView];
    header.triggerRate = 2;
    CGFloat height = header.expandHeight;
    // [EN] Pulled one header height: half the trigger distance. [CN] 拉动一个刷新头高度：触发距离的一半。
    scrollView.contentOffset = CGPointMake(0, -height);
    XCTAssertEqualWithAccuracy(header.pullingPercent, 0.5, 0.01);
    XCTAssertEqualWithAccuracy(header.dragOffset, height, 0.5);
    header.triggerRate = 0;
    XCTAssertEqual(header.triggerRate, 1, @"invalid rates fall back to 1");
}

- (void)testFinishDurationHoldsAndShowsTheResult {
    UIScrollView *scrollView = [self scrollView];
    CYLHookHeader *header = [CYLHookHeader attach:scrollView];
    XCTAssertEqual(header.attachCount, 1);
    header.finishDuration = 0.2;
    header.state = CYLRefreshStateRefreshing;
    XCTAssertEqual(header.phase, CYLRefreshPhaseRefreshing);
    [header endRefreshingWithSuccess:NO];
    XCTAssertEqualObjects(header.finishedWith, @NO);
    XCTAssertFalse(header.lastRefreshSucceeded);
    XCTAssertEqual(header.phase, CYLRefreshPhaseFinishing, @"holding");
    XCTAssertTrue(([header isInPhases:CYLRefreshPhaseRefreshing, CYLRefreshPhaseFinishing, 0]));
    XCTAssertTrue([header isInAnyPhase:@[@(CYLRefreshPhaseFinishing)]]);
    XCTAssertFalse(([header isInPhases:CYLRefreshPhaseIdle, 0]));
    XCTAssertEqualObjects(header.stateLabel.text, [NSBundle cyl_localizedStringForKey:CYLRefreshHeaderFailedText]);
    XCTestExpectation *done = [self expectationWithDescription:@"retracts"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertEqual(header.state, CYLRefreshStateIdle);
        XCTAssertTrue([header.phases containsObject:@(CYLRefreshPhaseFinishing)]);
        [done fulfill];
    });
    [self waitForExpectationsWithTimeout:2 handler:nil];

    // [EN] Without a finish duration, ending is immediate, as before. [CN] 不设停留时间时立即结束，与以前相同。
    header.finishDuration = 0;
    header.state = CYLRefreshStateRefreshing;
    [header endRefreshing];
    XCTAssertEqual(header.state, CYLRefreshStateIdle);
    XCTAssertTrue(header.lastRefreshSucceeded);
}

- (void)testScrollModesPlaceTheHeader {
    UIScrollView *scrollView = [self scrollView];
    CYLRefreshNormalHeader *header = [CYLRefreshNormalHeader attach:scrollView];
    CGFloat height = header.expandHeight;
    header.scrollMode = CYLRefreshScrollModeStretch;
    scrollView.contentOffset = CGPointMake(0, -150);
    XCTAssertEqualWithAccuracy(header.cyl_h, 150, 0.5, @"stretched over the pulled distance");
    XCTAssertEqualWithAccuracy(header.cyl_y, -150, 0.5);
    XCTAssertEqualWithAccuracy(header.expandHeight, height, 0.5, @"the open height is kept");
    header.scrollMode = CYLRefreshScrollModeFront;
    scrollView.contentOffset = CGPointMake(0, -150);
    XCTAssertEqualWithAccuracy(header.cyl_h, height, 0.5);
    XCTAssertEqualWithAccuracy(header.cyl_y, -150, 0.5, @"pinned at the visible top, in front");
    XCTAssertEqual(header.layer.zPosition, 1);
    header.scrollMode = CYLRefreshScrollModeMove;
    XCTAssertEqualWithAccuracy(header.cyl_y, -height, 0.5, @"back to moving with the content");
}

- (void)testThemeColorsAndHeaderDetails {
    UIScrollView *scrollView = [self scrollView];
    CYLRefreshNormalHeader *header = [CYLRefreshNormalHeader attach:scrollView];
    header.colorAccent = UIColor.systemRedColor;
    header.colorPrimary = UIColor.systemYellowColor;
    header.frame = CGRectMake(0, -54, 320, 54);
    [header layoutIfNeeded];
    XCTAssertEqualObjects(header.stateLabel.textColor, UIColor.systemRedColor);
    XCTAssertEqualObjects(header.lastUpdatedTimeLabel.textColor, UIColor.systemRedColor);
    XCTAssertEqualObjects(header.loadingView.color, UIColor.systemRedColor);
    XCTAssertEqualObjects(header.backgroundColor, UIColor.systemYellowColor);

    header.lastUpdatedTimeKey = @"CYLRefreshSmartAPITests";
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
    header.lastUpdatedTime = date;
    XCTAssertEqualObjects(header.lastUpdatedTime, date);
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"yyyy";
    formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    header.lastUpdatedTimeFormatter = formatter;
    XCTAssertTrue([header.lastUpdatedTimeString hasSuffix:@"1970"], @"%@", header.lastUpdatedTimeString);
    header.lastUpdatedTime = nil;
    XCTAssertNil(header.lastUpdatedTime);

    header.titleTimeSpacing = 6;
    [header setNeedsLayout];
    [header layoutIfNeeded];
    XCTAssertEqualWithAccuracy(CGRectGetMinY(header.lastUpdatedTimeLabel.frame) - CGRectGetMaxY(header.stateLabel.frame), 6, 0.5);

    CYLRefreshBackNormalFooter *footer = [CYLRefreshBackNormalFooter attach:scrollView];
    XCTAssertFalse(footer.isNoMoreData);
    [footer endRefreshingWithNoMoreData];
    XCTAssertTrue(footer.isNoMoreData);
    XCTAssertEqual(footer.phase, CYLRefreshPhaseNoMoreData);
}

@end
