#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import "../CYLTableViewPlaceHolder/CYLTableViewPlaceHolderDelegate.h"
#import "../CYLTableViewPlaceHolder/UITableView+CYLTableViewPlaceHolder.h"
#import "CYLRefresh.h"

@interface NSBundle (CYLTestMissingRefreshBundle)
+ (NSBundle *)cyl_testMissingRefreshBundle;
@end
@implementation NSBundle (CYLTestMissingRefreshBundle)
+ (NSBundle *)cyl_testMissingRefreshBundle { return nil; }
@end

@interface CYLTestPanGestureRecognizer : UIPanGestureRecognizer
@property (nonatomic) UIGestureRecognizerState cyl_testState;
@end
@implementation CYLTestPanGestureRecognizer
- (UIGestureRecognizerState)state { return self.cyl_testState; }
@end

@interface CYLTestScrollView : UIScrollView
@property (nonatomic) CGPoint cyl_testOffset;
@property (nonatomic, strong) CYLTestPanGestureRecognizer *cyl_testPan;
@end
@implementation CYLTestScrollView
- (CGPoint)contentOffset { return self.cyl_testOffset; }
- (UIPanGestureRecognizer *)panGestureRecognizer { return self.cyl_testPan; }
@end

@interface CYLTestPagingScrollView : UIScrollView
@property (nonatomic) BOOL cyl_testDragging;
@property (nonatomic) BOOL cyl_testDecelerating;
@end
@implementation CYLTestPagingScrollView
- (BOOL)isDragging { return self.cyl_testDragging; }
- (BOOL)isDecelerating { return self.cyl_testDecelerating; }
@end

@interface CYLTestSource : NSObject <UITableViewDataSource, CYLTableViewPlaceHolderDelegate>
@property (nonatomic) NSInteger rows;
@property (nonatomic) BOOL allowScroll;
@property (nonatomic, strong) UIView *view;
@end

@interface CYLRefreshSource : CYLTestSource
@end
@implementation CYLRefreshSource
- (CGRect)frameForPlaceHolderViewInTableView:(UITableView *)tableView {
    CGFloat top = CGRectGetMaxY(tableView.cyl_footer.frame);
    return CGRectMake(0, top, CGRectGetWidth(tableView.bounds),
                      MAX(0, CGRectGetHeight(tableView.bounds) - top));
}
@end

@implementation CYLTestSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rows;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
}
- (UIView *)makePlaceHolderView { return self.view; }
- (BOOL)enableScrollWhenPlaceHolderViewShowing { return self.allowScroll; }
@end

@interface CYLFramedSource : CYLTestSource
@end
@implementation CYLFramedSource
- (CGRect)frameForPlaceHolderViewInTableView:(UITableView *)tableView {
    return CGRectMake(0, 40, tableView.bounds.size.width, tableView.bounds.size.height - 80);
}
@end

@interface CYLMultipleSectionsSource : CYLTestSource
@end
@implementation CYLMultipleSectionsSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 2; }
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 1 ? self.rows : 0;
}
@end

@interface CYLTestDelegate : NSObject <UITableViewDelegate, CYLTableViewPlaceHolderDelegate>
@property (nonatomic, strong) UIView *view;
@end
@implementation CYLTestDelegate
- (UIView *)makePlaceHolderView { return self.view; }
@end

@interface PlaceholderTests : XCTestCase
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) CYLTestSource *source;
@end

@implementation PlaceholderTests
- (void)setUp {
    [super setUp];
    self.table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    self.source = [CYLTestSource new];
    self.source.view = [UIView new];
    self.table.dataSource = self.source;
}

- (void)testDefaultSectionAndScrollRestoration {
    self.table.scrollEnabled = YES;
    [self.table cyl_reloadData];
    XCTAssertEqual(self.source.view.superview, self.table);
    XCTAssertFalse(self.table.scrollEnabled);
    XCTAssertTrue(CGRectEqualToRect(self.source.view.frame, CGRectMake(0, 0, 320, 480)));
    self.source.rows = 1;
    [self.table cyl_reloadData];
    XCTAssertNil(self.source.view.superview);
    XCTAssertTrue(self.table.scrollEnabled);
}

- (void)testRepeatedEmptyReloadKeepsSubviewsAndCanSwitchViews {
    UIView *child = [UIView new];
    [self.source.view addSubview:child];
    UIView *first = self.source.view;
    [self.table cyl_reloadData];
    [self.table cyl_reloadData];
    XCTAssertEqual(child.superview, first);
    self.source.view = [UIView new];
    [self.table cyl_reloadData];
    XCTAssertNil(first.superview);
    XCTAssertEqual(self.source.view.superview, self.table);
}

- (void)testOptionalScrollAndNilPlaceholder {
    self.source.allowScroll = YES;
    UIView *oldView = self.source.view;
    [self.table cyl_reloadData];
    XCTAssertTrue(self.table.scrollEnabled);
    self.source.view = nil;
    [self.table cyl_reloadData];
    XCTAssertNil(oldView.superview);
    XCTAssertTrue(self.table.scrollEnabled);
}

- (void)testInitiallyDisabledScrollIsRestored {
    self.table.scrollEnabled = NO;
    self.source.allowScroll = YES;
    [self.table cyl_reloadData];
    XCTAssertTrue(self.table.scrollEnabled);
    self.source.rows = 1;
    [self.table cyl_reloadData];
    XCTAssertFalse(self.table.scrollEnabled);
}

- (void)testRowsInLaterSectionRemovePlaceholder {
    CYLMultipleSectionsSource *source = [CYLMultipleSectionsSource new];
    source.view = [UIView new];
    self.table.dataSource = source;
    [self.table cyl_reloadData];
    XCTAssertEqual(source.view.superview, self.table);
    source.rows = 1;
    [self.table cyl_reloadData];
    XCTAssertNil(source.view.superview);
}

- (void)testDefaultFrameFollowsTableResize {
    [self.table cyl_reloadData];
    self.table.frame = CGRectMake(0, 0, 375, 700);
    [self.table layoutIfNeeded];
    XCTAssertEqualWithAccuracy(CGRectGetWidth(self.source.view.frame), 375, 0.1);
    XCTAssertEqualWithAccuracy(CGRectGetHeight(self.source.view.frame), 700, 0.1);
}

- (void)testDelegateTakesPrecedenceOverDataSource {
    CYLTestDelegate *delegate = [CYLTestDelegate new];
    delegate.view = [UIView new];
    self.table.delegate = delegate;
    [self.table cyl_reloadData];
    XCTAssertEqual(delegate.view.superview, self.table);
    XCTAssertNil(self.source.view.superview);
}

- (void)testCustomFrameLeavesHeaderOutsidePlaceholder {
    CYLFramedSource *source = [CYLFramedSource new];
    source.view = [UIView new];
    self.table.dataSource = source;
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    self.table.tableHeaderView = header;
    [self.table cyl_reloadData];
    XCTAssertTrue(CGRectEqualToRect(source.view.frame, CGRectMake(0, 40, 320, 400)));
    XCTAssertFalse(CGRectIntersectsRect(source.view.frame, header.frame));
    XCTAssertEqual(source.view.superview, self.table);
}

- (void)testRefreshFooterCanRemainOutsidePlaceholder {
    CYLRefreshSource *source = [CYLRefreshSource new];
    source.view = [UIView new];
    self.table.dataSource = source;
    self.table.cyl_footer = [CYLRefreshAutoNormalFooter footerWithRefreshingBlock:^{}];
    [self.table cyl_reloadData];
    [self.table layoutIfNeeded];
    XCTAssertGreaterThan(CGRectGetHeight(self.table.cyl_footer.frame), 0);
    XCTAssertFalse(CGRectIntersectsRect(source.view.frame, self.table.cyl_footer.frame));
    XCTAssertEqual(self.table.cyl_footer.superview, self.table);
}

- (void)testRefreshResourcesAndCategoryAccessors {
    self.table.cyl_header = [CYLRefreshNormalHeader headerWithRefreshingBlock:^{}];
    XCTAssertEqual(self.table.cyl_header.superview, self.table);
    XCTAssertNotNil([NSBundle cyl_refreshBundle]);
    XCTAssertNotNil([NSBundle cyl_arrowImage]);
    CYLRefreshConfig.defaultConfig.languageCode = @"en";
    XCTAssertEqualObjects([NSBundle cyl_localizedStringForKey:CYLRefreshHeaderIdleText], @"Pull down to refresh");
    CYLRefreshConfig.defaultConfig.languageCode = nil;
    self.table.cyl_header = nil;
    XCTAssertNil(self.table.cyl_header);
}

- (void)testHeaderRefreshingCallbackAndCompletion {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    window.rootViewController = [UIViewController new];
    [window.rootViewController.view addSubview:self.table];
    [window makeKeyAndVisible];
    XCTestExpectation *started = [self expectationWithDescription:@"refresh callback"];
    self.table.cyl_header = [CYLRefreshNormalHeader headerWithRefreshingBlock:^{
        [started fulfill];
    }];
    self.table.cyl_header.fastAnimationDuration = 0;
    self.table.cyl_header.slowAnimationDuration = 0;
    [self.table.cyl_header beginRefreshing];
    [self waitForExpectations:@[started] timeout:5];
    XCTAssertTrue(self.table.cyl_header.isRefreshing);
    XCTestExpectation *ended = [self expectationWithDescription:@"refresh completion"];
    [self.table.cyl_header endRefreshingWithCompletionBlock:^{
        [ended fulfill];
    }];
    [self waitForExpectations:@[ended] timeout:5];
    XCTAssertFalse(self.table.cyl_header.isRefreshing);
    self.table.cyl_header = nil;
    window.hidden = YES;
}

- (void)testHeaderRestoresInsetAcrossRepeatedRefreshes {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    window.rootViewController = [UIViewController new];
    [window.rootViewController.view addSubview:self.table];
    self.table.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.table.contentInset = UIEdgeInsetsMake(20, 0, 12, 0);
    [window makeKeyAndVisible];
    CYLRefreshHeader *header = [CYLRefreshNormalHeader headerWithRefreshingBlock:^{}];
    header.fastAnimationDuration = 0;
    header.slowAnimationDuration = 0;
    self.table.cyl_header = header;
    for (NSUInteger index = 0; index < 3; index++) {
        XCTestExpectation *started = [self expectationWithDescription:@"header started"];
        [header beginRefreshingWithCompletionBlock:^{ [started fulfill]; }];
        [self waitForExpectations:@[started] timeout:5];
        XCTAssertEqualWithAccuracy(self.table.cyl_insetT, 20 + header.cyl_h, 0.001);
        XCTestExpectation *ended = [self expectationWithDescription:@"header ended"];
        [header endRefreshingWithCompletionBlock:^{ [ended fulfill]; }];
        [self waitForExpectations:@[ended] timeout:5];
        XCTAssertEqualWithAccuracy(self.table.cyl_insetT, 20, 0.001);
    }
    self.table.cyl_header = nil;
    window.hidden = YES;
}

- (void)testRefreshLocaleCanChange {
    CYLRefreshConfig.defaultConfig.languageCode = @"zh-Hans";
    NSString *chinese = [NSBundle cyl_localizedStringForKey:CYLRefreshHeaderIdleText];
    CYLRefreshConfig.defaultConfig.languageCode = @"en";
    NSString *english = [NSBundle cyl_localizedStringForKey:CYLRefreshHeaderIdleText];
    XCTAssertNotEqualObjects(chinese, english);
    XCTAssertEqualObjects(english, @"Pull down to refresh");
    CYLRefreshConfig.defaultConfig.languageCode = nil;
}

- (void)testRefreshUnsupportedLocaleFallsBackToEnglish {
    CYLRefreshConfig.defaultConfig.languageCode = @"zz-XX";
    XCTAssertEqualObjects([NSBundle cyl_localizedStringForKey:CYLRefreshHeaderIdleText], @"Pull down to refresh");
    CYLRefreshConfig.defaultConfig.languageCode = nil;
}

- (void)testMissingRefreshBundleFallsBackWithoutException {
    Method original = class_getClassMethod(NSBundle.class, @selector(cyl_refreshBundle));
    Method missing = class_getClassMethod(NSBundle.class, @selector(cyl_testMissingRefreshBundle));
    method_exchangeImplementations(original, missing);
    @try {
        CYLRefreshConfig.defaultConfig.languageCode = @"zz-test-missing";
        XCTAssertNoThrow(XCTAssertEqualObjects([NSBundle cyl_localizedStringForKey:CYLRefreshHeaderIdleText
                                                                           value:@"Fallback"],
                                              @"Fallback"));
    } @finally {
        method_exchangeImplementations(original, missing);
        CYLRefreshConfig.defaultConfig.languageCode = nil;
    }
}

- (void)testResetNoMoreDataBeforeBeginningRefresh {
    CYLRefreshFooter *footer = [CYLRefreshAutoNormalFooter footerWithRefreshingBlock:^{}];
    self.table.cyl_footer = footer;
    [footer endRefreshingWithNoMoreData];
    XCTAssertEqual(footer.state, CYLRefreshStateNoMoreData);
    [footer resetNoMoreData];
    [footer beginRefreshing];
    XCTAssertTrue(footer.isRefreshing);
    self.table.cyl_footer = nil;
}

- (void)testAutoFooterDoesNotTriggerWhileHeaderRefreshes {
    self.table.contentInset = UIEdgeInsetsMake(100, 0, 0, 0);
    self.table.contentSize = CGSizeMake(320, 390);
    CYLRefreshHeader *header = [CYLRefreshNormalHeader headerWithRefreshingBlock:^{}];
    CYLRefreshAutoFooter *footer = [CYLRefreshAutoNormalFooter footerWithRefreshingBlock:^{}];
    self.table.cyl_header = header;
    self.table.cyl_footer = footer;
    [header beginRefreshing];
    self.table.contentOffset = CGPointMake(0, -30);
    self.table.contentOffset = CGPointMake(0, -20);
    XCTAssertTrue(header.isRefreshing);
    XCTAssertFalse(footer.isRefreshing);
    header.state = CYLRefreshStateIdle;
    self.table.contentOffset = CGPointMake(0, -30);
    self.table.contentOffset = CGPointMake(0, -20);
    XCTAssertTrue(footer.isRefreshing);
    self.table.cyl_footer = nil;
    self.table.cyl_header = nil;
}

- (void)testScrollMetricsAreStableAndUseOffsetDeltas {
    UIScrollView *scrollView = [UIScrollView new];
    scrollView.contentOffset = CGPointMake(10, -20);
    [scrollView cyl_updateScrollMetrics];
    XCTAssertEqual(scrollView.cyl_scrollDirection, CYLScrollDirectionNone);
    XCTAssertEqual(scrollView.cyl_scrollDistance, 0);
    CGFloat previousY = scrollView.contentOffset.y;
    scrollView.contentOffset = CGPointMake(10, -17.5);
    CGFloat expectedDistance = scrollView.contentOffset.y - previousY;
    [scrollView cyl_updateScrollMetrics];
    XCTAssertEqual(scrollView.cyl_scrollDirection, CYLScrollDirectionDown);
    XCTAssertEqualWithAccuracy(scrollView.cyl_scrollDistance, expectedDistance, 0.001);
    XCTAssertEqual(scrollView.cyl_scrollDirection, CYLScrollDirectionDown);
    scrollView.contentOffset = CGPointMake(5, -17);
    [scrollView cyl_updateScrollMetrics];
    XCTAssertEqual(scrollView.cyl_scrollDirection, CYLScrollDirectionLeft);
    XCTAssertEqualWithAccuracy(scrollView.cyl_scrollDistance, -5, 0.001);
    [scrollView cyl_updateScrollMetrics];
    XCTAssertEqual(scrollView.cyl_scrollDirection, CYLScrollDirectionNone);
    XCTAssertEqual(scrollView.cyl_scrollDistance, 0);
}

- (void)testRefreshComponentMovesBetweenScrollAndOrdinaryViews {
    CYLRefreshComponent *component = [CYLRefreshComponent new];
    UIView *container = [UIView new];
    XCTAssertNoThrow([container addSubview:component]);
    XCTAssertNoThrow([component removeFromSuperview]);
    XCTAssertNoThrow([self.table addSubview:component]);
    XCTAssertEqual(component.scrollView, self.table);
    XCTAssertNoThrow([container addSubview:component]);
    XCTAssertNil(component.scrollView);
    XCTAssertNoThrow([component removeFromSuperview]);
    XCTAssertNoThrow([self.table addSubview:component]);
    XCTAssertNoThrow([component removeFromSuperview]);
}

- (void)testRefreshFooterRepeatedlyMovesBetweenContainerAndScrollViews {
    CYLRefreshAutoFooter *footer = [CYLRefreshAutoNormalFooter footerWithRefreshingBlock:^{}];
    UIView *container = [UIView new];
    UIScrollView *secondScrollView = [[UIScrollView alloc] initWithFrame:self.table.frame];
    CGFloat initialInset = self.table.cyl_insetB;
    for (NSUInteger index = 0; index < 100; index++) {
        [container addSubview:footer];
        XCTAssertNil(footer.scrollView);
        [self.table addSubview:footer];
        XCTAssertEqual(footer.scrollView, self.table);
        [secondScrollView addSubview:footer];
        XCTAssertEqualWithAccuracy(self.table.cyl_insetB, initialInset, 0.001);
        [footer removeFromSuperview];
        XCTAssertNil(footer.scrollView);
    }
}

- (void)testAutoFooterRestoresInsetWhenRemoved {
    self.table.contentInset = UIEdgeInsetsMake(0, 0, 12, 0);
    CGFloat initialInset = self.table.cyl_insetB;
    self.table.cyl_footer = [CYLRefreshAutoNormalFooter footerWithRefreshingBlock:^{}];
    XCTAssertGreaterThan(self.table.cyl_insetB, initialInset);
    self.table.cyl_footer = nil;
    XCTAssertEqualWithAccuracy(self.table.cyl_insetB, initialInset, 0.001);
}

- (void)testAutoFooterPanEndToleratesFloatingPointRounding {
    CYLTestScrollView *scrollView = [[CYLTestScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    scrollView.cyl_testPan = [CYLTestPanGestureRecognizer new];
    scrollView.cyl_testPan.cyl_testState = UIGestureRecognizerStateEnded;
    scrollView.contentSize = CGSizeMake(320, 1800);
    CYLRefreshAutoFooter *footer = [CYLRefreshAutoNormalFooter footerWithRefreshingBlock:^{}];
    scrollView.cyl_footer = footer;
    CGFloat threshold = scrollView.cyl_contentH + scrollView.cyl_insetB - scrollView.cyl_h;

    scrollView.cyl_testOffset = CGPointMake(0, threshold - 0.01);
    [footer scrollViewPanStateDidChange:nil];
    XCTAssertFalse(footer.isRefreshing);

    scrollView.cyl_testOffset = CGPointMake(0, threshold - 1e-11);
    [footer scrollViewPanStateDidChange:nil];
    XCTAssertTrue(footer.isRefreshing);
    footer.state = CYLRefreshStateIdle;
    scrollView.cyl_testPan.cyl_testState = UIGestureRecognizerStateBegan;
    [footer scrollViewPanStateDidChange:nil];
    scrollView.cyl_testPan.cyl_testState = UIGestureRecognizerStateEnded;
    scrollView.cyl_testOffset = CGPointMake(0, threshold);
    [footer scrollViewPanStateDidChange:nil];
    XCTAssertTrue(footer.isRefreshing);
    scrollView.cyl_footer = nil;
}

- (void)testPagingAutoFooterEndPreservesValidAndInteractiveOffsets {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    window.rootViewController = [UIViewController new];
    CYLTestPagingScrollView *scrollView = [[CYLTestPagingScrollView alloc] initWithFrame:window.bounds];
    scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    scrollView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);
    scrollView.contentSize = CGSizeMake(320, 960);
    scrollView.pagingEnabled = YES;
    [window.rootViewController.view addSubview:scrollView];
    [window makeKeyAndVisible];
    CYLRefreshAutoFooter *footer = [CYLRefreshAutoNormalFooter footerWithRefreshingBlock:^{}];
    footer.fastAnimationDuration = 0;
    footer.slowAnimationDuration = 0;
    scrollView.cyl_footer = footer;

    [footer beginRefreshing];
    scrollView.contentOffset = CGPointMake(0, 480);
    [footer endRefreshing];
    XCTAssertEqualWithAccuracy(scrollView.contentOffset.y, 480, 0.001);

    [footer beginRefreshing];
    scrollView.contentOffset = CGPointMake(0, 550);
    [footer endRefreshing];
    XCTAssertEqualWithAccuracy(scrollView.contentOffset.y, 510, 0.001);

    [footer beginRefreshing];
    scrollView.contentOffset = CGPointMake(0, 550);
    scrollView.cyl_testDragging = YES;
    [footer endRefreshing];
    XCTAssertEqualWithAccuracy(scrollView.contentOffset.y, 550, 0.001);
    scrollView.cyl_testDragging = NO;

    [footer beginRefreshing];
    scrollView.contentOffset = CGPointMake(0, 550);
    scrollView.cyl_testDecelerating = YES;
    [footer endRefreshing];
    XCTAssertEqualWithAccuracy(scrollView.contentOffset.y, 550, 0.001);
    scrollView.cyl_testDecelerating = NO;

    scrollView.cyl_footer = nil;
    window.hidden = YES;
}

- (void)testEndRefreshingDoesNotOverrideImmediateStateChange {
    CYLRefreshFooter *footer = [CYLRefreshAutoNormalFooter footerWithRefreshingBlock:^{}];
    self.table.cyl_footer = footer;
    [footer beginRefreshing];
    [footer endRefreshing];
    footer.state = CYLRefreshStateNoMoreData;
    XCTestExpectation *nextTurn = [self expectationWithDescription:@"main queue turn"];
    dispatch_async(dispatch_get_main_queue(), ^{ [nextTurn fulfill]; });
    [self waitForExpectations:@[nextTurn] timeout:5];
    XCTAssertEqual(footer.state, CYLRefreshStateNoMoreData);
    self.table.cyl_footer = nil;
}
@end
