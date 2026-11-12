#import <XCTest/XCTest.h>
#import "CYLRefresh.h"
#import "UIView+CYLExtension.h"
#import "UIScrollView+CYLExtension.h"

/// The hand-drawn headers ported from SmartRefreshControl (CYLRefresh/Custom/Drawn): each one runs a whole refresh in a
/// window and draws; the base reports SmartRefreshControl's status order; inset handling survives mode switches.
@interface CYLRefreshDrawnHeaderTests : XCTestCase
@property (nonatomic, strong) UIWindow *window;
@end

@interface CYLStatusRecordingHeader : CYLRefreshBezierRadarHeader
@property (nonatomic, strong) NSMutableArray<NSNumber *> *statuses;
@end

@implementation CYLStatusRecordingHeader
- (void)onStatus:(CYLRefreshPhase)oldStatus changed:(CYLRefreshPhase)status {
    [super onStatus:oldStatus changed:status];
    if (!self.statuses) self.statuses = [NSMutableArray array];
    [self.statuses addObject:@(status)];
}
@end

@implementation CYLRefreshDrawnHeaderTests

- (void)setUp {
    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 375, 667)];
    self.window.hidden = NO;
}

- (void)tearDown {
    self.window.hidden = YES;
    self.window = nil;
}

- (UIScrollView *)scrollView {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.window.bounds];
    scrollView.contentSize = CGSizeMake(375, 2000);
    [self.window addSubview:scrollView];
    return scrollView;
}

- (void)spin:(NSTimeInterval)seconds {
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:seconds]];
}

- (void)render:(UIView *)view {
    if (CGRectIsEmpty(view.bounds)) return;
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithBounds:view.bounds];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        [view.layer renderInContext:context.CGContext];
    }];
    XCTAssertNotNil(image);
}

- (NSArray<Class> *)styles {
    return @[CYLRefreshBezierCircleHeader.class, CYLRefreshBezierRadarHeader.class, CYLRefreshDeliveryHeader.class,
             CYLRefreshDropBoxHeader.class, CYLRefreshFlyHeader.class, CYLRefreshGameBattleCityHeader.class,
             CYLRefreshGameHitBlockHeader.class, CYLRefreshMaterialHeader.class, CYLRefreshOriginalHeader.class,
             CYLRefreshPhoenixHeader.class, CYLRefreshStoreHouseHeader.class, CYLRefreshTaurusHeader.class,
             CYLRefreshWaveSwipeHeader.class];
}

- (void)testEveryStyleRunsARefreshAndDraws {
    for (Class style in self.styles) {
        UIScrollView *scrollView = [self scrollView];
        UIEdgeInsets before = scrollView.contentInset;
        CYLRefreshDrawnHeader *header = [style attach:scrollView];
        XCTAssertTrue([header isKindOfClass:CYLRefreshDrawnHeader.class]);
        XCTAssertEqual(scrollView.cyl_header, header);
        XCTAssertGreaterThan(header.expandHeight, 0, @"%@", style);
        [self spin:0.05];
        for (CGFloat y = 0; y >= -220; y -= 20) {
            scrollView.contentOffset = CGPointMake(0, y - scrollView.cyl_inset.top);
            [header layoutIfNeeded];
            [header setNeedsDisplay];
            [header.layer displayIfNeeded];
        }
        [self render:header];
        [header beginRefreshing];
        [self spin:0.4];
        XCTAssertTrue(header.isRefreshing, @"%@", style);
        [self render:header];
        [header endRefreshing];
        [self spin:1.8];
        [self render:header];
        XCTAssertEqual(header.state, CYLRefreshStateIdle, @"%@", style);
        scrollView.cyl_header = nil;
        XCTAssertEqualWithAccuracy(scrollView.contentInset.top, before.top, 0.5, @"%@ leaves the inset as it found it", style);
        [scrollView removeFromSuperview];
    }
}

- (void)testTheBaseReportsSmartRefreshControlsStatusOrder {
    UIScrollView *scrollView = [self scrollView];
    CYLStatusRecordingHeader *header = [CYLStatusRecordingHeader attach:scrollView];
    [self spin:0.05];
    [header beginRefreshing];
    [self spin:0.4];
    [header finishRefreshWithSuccess:NO];
    XCTAssertFalse(header.isSuccess);
    [self spin:1.5];
    NSArray *expected = @[@(CYLRefreshPhaseReleasing), @(CYLRefreshPhaseRefreshing), @(CYLRefreshPhaseFinishing),
                          @(CYLRefreshPhaseIdle)];
    NSArray *tail = header.statuses.count >= 4 ? [header.statuses subarrayWithRange:NSMakeRange(header.statuses.count - 4, 4)] : header.statuses;
    XCTAssertEqualObjects(tail, expected, @"%@", header.statuses);
    XCTAssertTrue(([header inStatus:CYLRefreshPhaseRefreshing, CYLRefreshPhaseIdle, 0]));
}

- (void)testAModeSwitchDuringARefreshStillRestoresTheInset {
    UIScrollView *scrollView = [self scrollView];
    CGFloat top = scrollView.cyl_inset.top;
    CYLRefreshNormalHeader *header = [CYLRefreshNormalHeader attach:scrollView];
    [self spin:0.05];
    [header beginRefreshing];
    [self spin:0.5];
    XCTAssertGreaterThan(scrollView.cyl_inset.top, top + 1, @"refreshing pushed the content down");
    header.scrollMode = CYLRefreshScrollModeFront;
    [header endRefreshing];
    [self spin:0.8];
    XCTAssertEqualWithAccuracy(scrollView.cyl_inset.top, top, 0.5, @"the added inset is removed although the mode changed");

    header.scrollMode = CYLRefreshScrollModeMove;
    header.addsRefreshingInset = NO;
    [header beginRefreshing];
    [self spin:0.5];
    XCTAssertEqualWithAccuracy(scrollView.cyl_inset.top, top, 0.5, @"addsRefreshingInset NO keeps the content in place");
    [header endRefreshing];
    [self spin:0.5];
}

@end
