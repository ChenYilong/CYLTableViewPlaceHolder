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

- (void)testFlutterEasyRefreshStyleOptions {
    UIScrollView *scrollView = [self scrollView];
    CYLRefreshNormalHeader *header = [CYLRefreshNormalHeader attach:scrollView];
    CYLRefreshBackNormalFooter *footer = [CYLRefreshBackNormalFooter attach:scrollView];
    XCTAssertTrue(header.isRefreshEnabled, @"on by default");

    // [EN] External phase observers (listenable / ListenerHeader). [CN] 外部阶段观察者（listenable / ListenerHeader）。
    NSMutableArray<NSNumber *> *seen = [NSMutableArray array];
    id token = [header addPhaseObserver:^(CYLRefreshComponent *component, CYLRefreshPhase oldPhase, CYLRefreshPhase phase) {
        XCTAssertEqual(component, header);
        [seen addObject:@(phase)];
    }];
    header.state = CYLRefreshStateRefreshing;
    XCTAssertEqualObjects(seen.lastObject, @(CYLRefreshPhaseRefreshing));
    [header removePhaseObserver:token];
    header.state = CYLRefreshStateIdle;
    XCTAssertEqualObjects(seen.lastObject, @(CYLRefreshPhaseRefreshing), @"removed observers stay silent");

    // [EN] resetsFooterAfterRefresh. [CN] 刷新后重置加载尾。
    [footer endRefreshingWithNoMoreData];
    XCTAssertTrue(footer.isNoMoreData);
    header.resetsFooterAfterRefresh = YES;
    header.state = CYLRefreshStateRefreshing;
    [header endRefreshingWithSuccess:YES];
    XCTAssertFalse(footer.isNoMoreData, @"a successful refresh resets no more data");
    [footer endRefreshingWithNoMoreData];
    header.state = CYLRefreshStateRefreshing;
    [header endRefreshingWithSuccess:NO];
    XCTAssertTrue(footer.isNoMoreData, @"a failed refresh keeps it");

    // [EN] notifiesWhenHidden: hooks still follow the scroll view. [CN] 隐藏时仍跟随滚动。
    header.hidden = YES;
    header.notifiesWhenHidden = YES;
    scrollView.contentOffset = CGPointMake(0, -10);
    XCTAssertGreaterThan(header.pullingPercent, 0, @"still followed while hidden");
    header.hidden = NO;

    header.triggersWhenReached = YES;
    header.hapticFeedback = YES;
    header.maxPullDistance = 120;
    header.refreshEnabled = NO;
    footer.loadsAfterNoMoreData = YES;
    XCTAssertTrue(header.triggersWhenReached && header.hapticFeedback && footer.loadsAfterNoMoreData);
    XCTAssertEqual(header.maxPullDistance, 120);
    XCTAssertFalse(header.isRefreshEnabled);
}

- (void)testTriggerModeBehindModeStartHeaderAndCupertino {
    UIScrollView *scrollView = [self scrollView];
    CYLRefreshNormalHeader *header = [CYLRefreshNormalHeader attach:scrollView];
    XCTAssertEqual(header.triggerMode, CYLRefreshTriggerModeAnywhere, @"default");
    header.triggerMode = CYLRefreshTriggerModeOnEdge;
    XCTAssertEqual(header.triggerMode, CYLRefreshTriggerModeOnEdge);

    // [EN] Behind: pinned behind the content. [CN] 后置：固定在内容后面。
    header.scrollMode = CYLRefreshScrollModeBehind;
    scrollView.contentOffset = CGPointMake(0, -120);
    XCTAssertEqual(header.layer.zPosition, -1);
    XCTAssertEqual(scrollView.subviews.firstObject, header, @"sent to the back");
    XCTAssertEqualWithAccuracy(CGRectGetMinY(header.frame), -120, 0.5, @"pinned at the visible top");
    header.scrollMode = CYLRefreshScrollModeMove;
    XCTAssertEqual(header.layer.zPosition, 0);

    // [EN] A start header refreshes once, then the regular header comes back. [CN] 起始刷新头刷新一次后换回常规刷新头。
    __block NSInteger calls = 0;
    header.refreshingBlock = ^{ calls++; };
    CYLRefreshCupertinoHeader *start = [CYLRefreshCupertinoHeader new];
    [scrollView cyl_beginRefreshingWithStartHeader:start];
    XCTAssertEqual(scrollView.cyl_header, start);
    XCTAssertTrue(start.isRefreshing || start.state == CYLRefreshStateWillRefresh);
    [start executeRefreshingCallback];
    XCTAssertEqual(calls, 1, @"the regular header's callback runs");
    XCTestExpectation *back = [self expectationWithDescription:@"regular header back"];
    [start endRefreshingWithCompletionBlock:^{}];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertEqual(scrollView.cyl_header, header);
        [back fulfill];
    });
    [self waitForExpectationsWithTimeout:3 handler:nil];

    // [EN] Cupertino: the indicator spins only while refreshing. [CN] Cupertino：菊花只在刷新时旋转。
    CYLRefreshCupertinoFooter *footer = [CYLRefreshCupertinoFooter attach:scrollView];
    XCTAssertFalse(footer.activityIndicator.isAnimating);
    footer.state = CYLRefreshStateRefreshing;
    XCTAssertTrue(footer.activityIndicator.isAnimating);
    footer.state = CYLRefreshStateIdle;
    XCTAssertFalse(footer.activityIndicator.isAnimating);
    CYLRefreshCupertinoHeader *cupertino = [CYLRefreshCupertinoHeader new];
    cupertino.pullingPercent = 0.5;
    XCTAssertEqualWithAccuracy(cupertino.activityIndicator.alpha, 0.5, 0.01, @"fades in with the pull");
    cupertino.state = CYLRefreshStateRefreshing;
    XCTAssertTrue(cupertino.activityIndicator.isAnimating);
    XCTAssertNotNil(cupertino.activityIndicator.accessibilityLabel);
}

- (void)testSecondFloorOpensAndCloses {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    window.hidden = NO;
    UIScrollView *scrollView = [self scrollView];
    [window addSubview:scrollView];
    CYLRefreshNormalHeader *header = [CYLRefreshNormalHeader attach:scrollView];
    UIView *floor = [UIView new];
    header.secondaryTriggerOffset = 160;
    header.secondaryDimension = 300;
    header.secondaryView = floor;
    XCTAssertEqual(floor.superview, scrollView, @"the second floor's view sits in the scroll view");
    XCTAssertEqualWithAccuracy(CGRectGetMinY(floor.frame), -300, 0.5, @"above the content");
    XCTAssertEqualWithAccuracy(header.secondaryCloseTriggerOffset, 80, 0.01);
    CGFloat top = scrollView.adjustedContentInset.top;

    __block BOOL opened = NO, closed = NO;
    NSMutableArray<NSNumber *> *phases = [NSMutableArray array];
    [header addPhaseObserver:^(CYLRefreshComponent *c, CYLRefreshPhase old, CYLRefreshPhase phase) { [phases addObject:@(phase)]; }];
    header.secondaryOpenedBlock = ^{ opened = YES; };
    header.secondaryClosedBlock = ^{ closed = YES; };
    [header openSecondary];
    XCTAssertTrue(header.isSecondaryOpen);
    XCTAssertEqual(header.phase, CYLRefreshPhaseSecondaryOpen);
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.7]];
    XCTAssertTrue(opened);
    XCTAssertEqualWithAccuracy(scrollView.adjustedContentInset.top, top + 300, 0.5, @"the content moved down by the floor");
    XCTAssertNil(header.layer.mask, @"not auto-hidden while the floor is open");

    [header closeSecondary];
    XCTAssertEqual(header.phase, CYLRefreshPhaseSecondaryClosing);
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.7]];
    XCTAssertTrue(closed);
    XCTAssertFalse(header.isSecondaryOpen);
    XCTAssertEqualWithAccuracy(scrollView.adjustedContentInset.top, top, 0.5, @"the inset is back");
    XCTAssertTrue([phases containsObject:@(CYLRefreshPhaseSecondaryOpen)]);
    XCTAssertEqualObjects(phases.lastObject, @(CYLRefreshPhaseIdle));
    window.hidden = YES;
}

- (void)testFooterSecondFloorOpensAndCloses {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    window.hidden = NO;
    UIScrollView *scrollView = [self scrollView];
    [window addSubview:scrollView];
    CYLRefreshBackNormalFooter *footer = [CYLRefreshBackNormalFooter attach:scrollView];
    UIView *floor = [UIView new];
    footer.secondaryTriggerOffset = 160;
    footer.secondaryDimension = 260;
    footer.secondaryView = floor;
    XCTAssertEqual(floor.superview, scrollView);
    XCTAssertEqualWithAccuracy(CGRectGetMinY(floor.frame), 2000, 0.5, @"right below the content");
    XCTAssertEqualWithAccuracy(footer.secondaryCloseTriggerOffset, 80, 0.01);
    CGFloat bottom = scrollView.adjustedContentInset.bottom;
    __block BOOL opened = NO, closed = NO;
    footer.secondaryOpenedBlock = ^{ opened = YES; };
    footer.secondaryClosedBlock = ^{ closed = YES; };
    [footer openSecondary];
    XCTAssertEqual(footer.phase, CYLRefreshPhaseSecondaryOpen);
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.7]];
    XCTAssertTrue(opened && footer.isSecondaryOpen);
    XCTAssertEqualWithAccuracy(scrollView.adjustedContentInset.bottom, bottom + 260, 0.5);
    [footer closeSecondary];
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.7]];
    XCTAssertTrue(closed);
    XCTAssertFalse(footer.isSecondaryOpen);
    XCTAssertEqualWithAccuracy(scrollView.adjustedContentInset.bottom, bottom, 0.5);
    XCTAssertEqual(footer.phase, CYLRefreshPhaseIdle);
    window.hidden = YES;
}

@end
