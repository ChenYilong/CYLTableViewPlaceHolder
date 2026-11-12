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

@interface CYLDrawnDemoTableController : UITableViewController
@property (nonatomic) Class style;
@property (nonatomic, strong) CYLRefreshHeader *header;
@end

@implementation CYLDrawnDemoTableController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.header = [self.style new];
    [self.header attach:self.tableView];
    [self.header beginRefreshing];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return 20; }
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
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

/// [EN] Core Animation drops a whole commit with a NaN in any layer, freezing the screen; report every such layer.
/// [CN] 任何图层出现 NaN 时 Core Animation 会丢弃整次提交、画面冻结；报告所有这样的图层。
- (void)collectInvalidLayers:(CALayer *)layer path:(NSString *)path into:(NSMutableArray<NSString *> *)out {
    CGRect b = layer.bounds; CGPoint p = layer.position; CATransform3D t = layer.transform;
    BOOL bad = !isfinite(b.origin.x) || !isfinite(b.origin.y) || !isfinite(b.size.width) || !isfinite(b.size.height) ||
               !isfinite(p.x) || !isfinite(p.y) || !isfinite(layer.anchorPoint.x) || !isfinite(layer.opacity) ||
               !isfinite(t.m11) || !isfinite(t.m22) || !isfinite(t.m41) || !isfinite(t.m42) ||
               !isfinite(layer.cornerRadius) || !isfinite(layer.shadowRadius);
    if ([layer isKindOfClass:CAShapeLayer.class]) {
        CAShapeLayer *shape = (CAShapeLayer *)layer;
        CGRect box = shape.path ? CGPathGetPathBoundingBox(shape.path) : CGRectZero;
        bad = bad || !isfinite(box.origin.x) || !isfinite(box.origin.y) || !isfinite(box.size.width) ||
              !isfinite(shape.lineWidth) || !isfinite(shape.strokeEnd) || !isfinite(shape.strokeStart);
    }
    if (bad) [out addObject:[NSString stringWithFormat:@"%@ %@ bounds=%@ position=%@", path, layer.class,
                            NSStringFromCGRect(b), NSStringFromCGPoint(p)]];
    [layer.sublayers enumerateObjectsUsingBlock:^(CALayer *sub, NSUInteger idx, BOOL *stop) {
        [self collectInvalidLayers:sub path:[path stringByAppendingFormat:@"/%lu", (unsigned long)idx] into:out];
    }];
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
        NSMutableArray<NSString *> *invalid = [NSMutableArray array];
        scrollView.contentOffset = CGPointMake(0, -scrollView.cyl_inset.top);
        [self spin:0.1];
        [self collectInvalidLayers:header.layer path:@"idle" into:invalid];
        scrollView.contentOffset = CGPointMake(0, -scrollView.cyl_inset.top - 60);
        [self spin:0.1];
        [self collectInvalidLayers:header.layer path:@"pulled" into:invalid];
        [header beginRefreshing];
        [self spin:0.4];
        [self collectInvalidLayers:header.layer path:@"refreshing" into:invalid];
        XCTAssertEqual(invalid.count, 0, @"%@ has NaN layers: %@", style, invalid);
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

- (void)testBeginRefreshingBeforeTheListIsOnScreenOpensTheHeader {
    // [EN] The demo pages call beginRefreshing in viewDidLoad, before the list has a window.
    // [CN] 示例页面在 viewDidLoad 中调用 beginRefreshing，那时列表还没有 window。
    for (Class style in @[CYLRefreshDeliveryHeader.class, CYLRefreshBezierRadarHeader.class, CYLRefreshNormalHeader.class]) {
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.window.bounds];
        scrollView.contentSize = CGSizeMake(375, 2000);
        CGFloat top = scrollView.cyl_inset.top;
        CYLRefreshHeader *header = [style new];
        [header attach:scrollView];
        [header beginRefreshing];
        [self.window addSubview:scrollView];
        [self spin:0.6];
        XCTAssertTrue(header.isRefreshing, @"%@", style);
        XCTAssertGreaterThan(scrollView.cyl_inset.top, top + 1, @"%@ pushes the content down", style);
        [header endRefreshing];
        [self spin:0.6];
        [scrollView removeFromSuperview];
    }
}

- (void)testADemoPageOpensRefreshingInANavigationController {
    for (Class style in @[CYLRefreshNormalHeader.class, CYLRefreshBezierRadarHeader.class]) {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[UIViewController new]];
        self.window.rootViewController = nav;
        [self spin:0.2];
        CYLDrawnDemoTableController *page = [[CYLDrawnDemoTableController alloc] initWithStyle:UITableViewStyleGrouped];
        page.style = style;
        [nav pushViewController:page animated:NO];
        [self spin:0.8];
        UITableView *table = page.tableView;
        XCTAssertTrue(page.header.isRefreshing, @"%@", style);
        [page.header endRefreshing];
        [self spin:0.6];
        self.window.rootViewController = nil;
    }
}

@end
