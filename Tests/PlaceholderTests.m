#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import "../CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLTableViewPlaceHolderDelegate.h"
#import "../CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/UITableView+CYLTableViewPlaceHolder.h"
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

@interface CYLTestReentrantScrollView : UIScrollView
@property (nonatomic) BOOL cyl_triggerInsetFeedback;
@property (nonatomic) NSInteger cyl_insetDepth;
@property (nonatomic) NSInteger cyl_maxInsetDepth;
@end
@implementation CYLTestReentrantScrollView
- (void)setContentInset:(UIEdgeInsets)contentInset {
    self.cyl_insetDepth++;
    self.cyl_maxInsetDepth = MAX(self.cyl_maxInsetDepth, self.cyl_insetDepth);
    [super setContentInset:contentInset];
    if (self.cyl_triggerInsetFeedback && self.cyl_insetDepth < 8) {
        CGFloat offset = self.contentOffset.y < -15 ? -10 : -20;
        self.contentOffset = CGPointMake(self.contentOffset.x, offset);
    }
    self.cyl_insetDepth--;
}
@end

@interface CYLTestCollectionSource : NSObject <UICollectionViewDataSource>
@end
@implementation CYLTestCollectionSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 40;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
}
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

- (void)testDefaultPlaceholderKeepsRefreshControlsVisible {
    UIView *tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    self.table.tableHeaderView = tableHeader;
    self.table.cyl_header = [CYLRefreshNormalHeader headerWithRefreshingBlock:^{}];
    self.table.cyl_footer = [CYLRefreshAutoNormalFooter footerWithRefreshingBlock:^{}];
    for (NSUInteger pass = 0; pass < 2; pass++) {
        [self.table cyl_reloadData];
        NSArray<UIView *> *subviews = self.table.subviews;
        NSUInteger placeholderIndex = [subviews indexOfObject:self.source.view];
        XCTAssertNotEqual(placeholderIndex, NSNotFound);
        // The placeholder still covers ordinary content but stays below refresh controls (issue #8).
        XCTAssertGreaterThan(placeholderIndex, [subviews indexOfObject:tableHeader]);
        XCTAssertGreaterThan([subviews indexOfObject:self.table.cyl_footer], placeholderIndex);
        XCTAssertGreaterThan([subviews indexOfObject:self.table.cyl_header], placeholderIndex);
        XCTAssertTrue(CGRectEqualToRect(self.source.view.frame, CGRectMake(0, 0, 320, 480)));
    }
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

- (void)testNormalHeaderAndArrowViewDeallocateAfterRemoval {
    __weak CYLRefreshNormalHeader *weakHeader;
    __weak UIImageView *weakArrow;
    UIImage *cachedArrow = [NSBundle cyl_arrowImage];
    XCTAssertNotNil(cachedArrow);
    @autoreleasepool {
        CYLRefreshNormalHeader *header = [CYLRefreshNormalHeader headerWithRefreshingBlock:^{}];
        self.table.cyl_header = header;
        [header layoutIfNeeded];
        UIImageView *arrow = nil;
        for (UIView *view in header.subviews) {
            if ([view isKindOfClass:UIImageView.class] && ((UIImageView *)view).image == cachedArrow) {
                arrow = (UIImageView *)view;
                break;
            }
        }
        XCTAssertNotNil(arrow);
        weakHeader = header;
        weakArrow = arrow;
        self.table.cyl_header = nil;
    }
    XCTAssertNil(weakHeader);
    XCTAssertNil(weakArrow);
    XCTAssertEqual([NSBundle cyl_arrowImage], cachedArrow);
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

- (void)testRefreshComponentDoesNotOverrideDrawing {
    unsigned int count = 0;
    Method *methods = class_copyMethodList(CYLRefreshComponent.class, &count);
    BOOL overridesDrawRect = NO;
    for (unsigned int index = 0; index < count; index++) {
        if (method_getName(methods[index]) == @selector(drawRect:)) {
            overridesDrawRect = YES;
            break;
        }
    }
    free(methods);
    XCTAssertFalse(overridesDrawRect);
}

- (void)testPendingRefreshStartsOnceAfterWindowAttachment {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    window.rootViewController = [UIViewController new];
    [window makeKeyAndVisible];
    NSArray<CYLRefreshComponent *> *components = @[
        [CYLRefreshNormalHeader headerWithRefreshingBlock:^{}],
        [CYLRefreshAutoNormalFooter footerWithRefreshingBlock:^{}],
        [CYLRefreshBackNormalFooter footerWithRefreshingBlock:^{}],
        [CYLRefreshNormalTrailer trailerWithRefreshingBlock:^{}]
    ];
    for (CYLRefreshComponent *component in components) {
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:window.bounds];
        component.fastAnimationDuration = 0;
        component.slowAnimationDuration = 0;
        __block NSUInteger callbacks = 0;
        XCTestExpectation *started = [self expectationWithDescription:@"pending refresh started"];
        component.refreshingBlock = ^{
            callbacks++;
            [started fulfill];
        };
        [scrollView addSubview:component];
        [component beginRefreshing];
        [component beginRefreshing];
        XCTAssertEqual(component.state, CYLRefreshStateWillRefresh);
        XCTAssertEqual(callbacks, 0u);
        [window.rootViewController.view addSubview:scrollView];
        [self waitForExpectations:@[started] timeout:5];
        XCTAssertEqual(component.state, CYLRefreshStateRefreshing);
        XCTAssertEqual(callbacks, 1u);
        [component endRefreshing];
        [component removeFromSuperview];
        [scrollView removeFromSuperview];
    }
    window.hidden = YES;
}

- (void)testPendingRefreshCanBeCancelledBeforeWindowAttachment {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    window.rootViewController = [UIViewController new];
    [window makeKeyAndVisible];
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:window.bounds];
    __block NSUInteger callbacks = 0;
    CYLRefreshAutoFooter *footer = [CYLRefreshAutoNormalFooter footerWithRefreshingBlock:^{ callbacks++; }];
    [scrollView addSubview:footer];
    [footer beginRefreshing];
    [window.rootViewController.view addSubview:scrollView];
    [footer endRefreshing];
    XCTestExpectation *nextTurn = [self expectationWithDescription:@"pending transition processed"];
    dispatch_async(dispatch_get_main_queue(), ^{ [nextTurn fulfill]; });
    [self waitForExpectations:@[nextTurn] timeout:5];
    XCTAssertEqual(footer.state, CYLRefreshStateIdle);
    XCTAssertEqual(callbacks, 0u);
    [footer removeFromSuperview];
    window.hidden = YES;
}

- (void)testPendingRefreshWaitsForReattachmentAndWorksWhenHidden {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    window.rootViewController = [UIViewController new];
    [window makeKeyAndVisible];
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:window.bounds];
    XCTestExpectation *started = [self expectationWithDescription:@"reattached refresh started"];
    __block NSUInteger callbacks = 0;
    CYLRefreshAutoFooter *footer = [CYLRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        callbacks++;
        [started fulfill];
    }];
    footer.hidden = YES;
    [scrollView addSubview:footer];
    [footer beginRefreshing];
    [window.rootViewController.view addSubview:scrollView];
    [scrollView removeFromSuperview];
    XCTestExpectation *nextTurn = [self expectationWithDescription:@"detached transition processed"];
    dispatch_async(dispatch_get_main_queue(), ^{ [nextTurn fulfill]; });
    [self waitForExpectations:@[nextTurn] timeout:5];
    XCTAssertEqual(footer.state, CYLRefreshStateWillRefresh);
    XCTAssertEqual(callbacks, 0u);
    [window.rootViewController.view addSubview:scrollView];
    [self waitForExpectations:@[started] timeout:5];
    XCTAssertEqual(callbacks, 1u);
    [footer endRefreshing];
    [footer removeFromSuperview];
    [scrollView removeFromSuperview];
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

- (void)testHeaderInsetFeedbackDuringStartAndResetDoesNotReenterSetter {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    window.rootViewController = [UIViewController new];
    CYLTestReentrantScrollView *scrollView = [[CYLTestReentrantScrollView alloc] initWithFrame:window.bounds];
    scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [window.rootViewController.view addSubview:scrollView];
    [window makeKeyAndVisible];
    CYLRefreshHeader *header = [CYLRefreshNormalHeader headerWithRefreshingBlock:^{}];
    header.fastAnimationDuration = 0;
    header.slowAnimationDuration = 0;
    scrollView.cyl_header = header;
    scrollView.cyl_triggerInsetFeedback = YES;
    XCTestExpectation *started = [self expectationWithDescription:@"header started"];
    [header beginRefreshingWithCompletionBlock:^{ [started fulfill]; }];
    [self waitForExpectations:@[started] timeout:5];
    scrollView.cyl_triggerInsetFeedback = NO;
    XCTAssertEqual(scrollView.cyl_maxInsetDepth, 1);
    XCTAssertEqualWithAccuracy(scrollView.cyl_insetT, header.cyl_h, 0.001);

    scrollView.cyl_maxInsetDepth = 0;
    scrollView.cyl_triggerInsetFeedback = YES;
    scrollView.contentOffset = CGPointMake(0, -20);
    scrollView.cyl_triggerInsetFeedback = NO;
    XCTAssertEqual(scrollView.cyl_maxInsetDepth, 1);
    XCTestExpectation *ended = [self expectationWithDescription:@"header ended"];
    [header endRefreshingWithCompletionBlock:^{ [ended fulfill]; }];
    [self waitForExpectations:@[ended] timeout:5];
    XCTAssertEqualWithAccuracy(scrollView.cyl_insetT, 0, 0.001);
    scrollView.cyl_header = nil;
    window.hidden = YES;
}

- (void)testHeaderRefreshWithNavigationSearchController {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    UIViewController *controller = [UIViewController new];
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
    controller.navigationItem.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    controller.navigationItem.hidesSearchBarWhenScrolling = YES;
    window.rootViewController = navigation;
    UITableView *table = [[UITableView alloc] initWithFrame:controller.view.bounds style:UITableViewStylePlain];
    table.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [controller.view addSubview:table];
    [window makeKeyAndVisible];
    [controller.view layoutIfNeeded];
    CGFloat initialInset = table.contentInset.top;
    CYLRefreshHeader *header = [CYLRefreshNormalHeader headerWithRefreshingBlock:^{}];
    header.fastAnimationDuration = 0;
    header.slowAnimationDuration = 0;
    table.cyl_header = header;
    XCTestExpectation *started = [self expectationWithDescription:@"search header started"];
    [header beginRefreshingWithCompletionBlock:^{ [started fulfill]; }];
    [self waitForExpectations:@[started] timeout:5];
    table.contentOffset = CGPointMake(0, 100);
    [controller.view layoutIfNeeded];
    [header endRefreshing];
    XCTAssertEqualWithAccuracy(table.contentInset.top, initialInset, 0.01);
    table.cyl_header = nil;
    window.hidden = YES;
}

- (void)testHiddenHeaderRestoresInsetAfterProgrammaticRefresh {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    window.rootViewController = [UIViewController new];
    [window.rootViewController.view addSubview:self.table];
    self.table.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.table.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    [window makeKeyAndVisible];
    CYLRefreshHeader *header = [CYLRefreshNormalHeader headerWithRefreshingBlock:^{}];
    header.fastAnimationDuration = 0;
    header.slowAnimationDuration = 0;
    header.hidden = YES;
    self.table.cyl_header = header;
    XCTAssertEqualWithAccuracy(header.cyl_y, -header.cyl_h, 0.001);
    for (NSUInteger index = 0; index < 3; index++) {
        XCTestExpectation *started = [self expectationWithDescription:@"hidden header started"];
        [header beginRefreshingWithCompletionBlock:^{ [started fulfill]; }];
        [self waitForExpectations:@[started] timeout:5];
        XCTAssertEqualWithAccuracy(self.table.cyl_insetT, 20 + header.cyl_h, 0.001);
        XCTestExpectation *ended = [self expectationWithDescription:@"hidden header ended"];
        [header endRefreshingWithCompletionBlock:^{ [ended fulfill]; }];
        [self waitForExpectations:@[ended] timeout:5];
        XCTAssertEqualWithAccuracy(self.table.cyl_insetT, 20, 0.001);
    }
    self.table.cyl_header = nil;
    window.hidden = YES;
}

- (void)testCollectionHeaderRestoresInsetForVisibleAndHiddenRefreshes {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    window.rootViewController = [UIViewController new];
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    UICollectionView *collection = [[UICollectionView alloc] initWithFrame:window.bounds
                                                      collectionViewLayout:layout];
    collection.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    collection.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    [window.rootViewController.view addSubview:collection];
    [window makeKeyAndVisible];
    CYLRefreshHeader *header = [CYLRefreshNormalHeader headerWithRefreshingBlock:^{}];
    header.isCollectionViewAnimationBug = YES;
    header.fastAnimationDuration = 0.01;
    header.slowAnimationDuration = 0.01;
    collection.cyl_header = header;
    for (NSUInteger index = 0; index < 4; index++) {
        header.hidden = index % 2 == 0;
        XCTestExpectation *started = [self expectationWithDescription:@"collection header started"];
        [header beginRefreshingWithCompletionBlock:^{ [started fulfill]; }];
        [self waitForExpectations:@[started] timeout:5];
        XCTAssertEqualWithAccuracy(collection.cyl_insetT, 20 + header.cyl_h, 0.001);
        XCTestExpectation *ended = [self expectationWithDescription:@"collection header ended"];
        [header endRefreshingWithCompletionBlock:^{ [ended fulfill]; }];
        [self waitForExpectations:@[ended] timeout:5];
        XCTAssertEqualWithAccuracy(collection.cyl_insetT, 20, 0.001);
        XCTAssertTrue(collection.userInteractionEnabled);
    }
    collection.cyl_header = nil;
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

- (void)testRemovingActiveTrailerRestoresHorizontalInsetAndBounce {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    window.rootViewController = [UIViewController new];
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *collection = [[UICollectionView alloc] initWithFrame:window.bounds
                                                      collectionViewLayout:layout];
    collection.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    collection.contentInset = UIEdgeInsetsMake(0, 0, 0, 17);
    [window.rootViewController.view addSubview:collection];
    [window makeKeyAndVisible];
    CYLRefreshTrailer *trailer = [CYLRefreshNormalTrailer trailerWithRefreshingBlock:^{}];
    trailer.fastAnimationDuration = 0;
    trailer.slowAnimationDuration = 0;
    collection.cyl_trailer = trailer;
    [trailer layoutIfNeeded];
    XCTestExpectation *started = [self expectationWithDescription:@"trailer started"];
    [trailer beginRefreshingWithCompletionBlock:^{ [started fulfill]; }];
    [self waitForExpectations:@[started] timeout:5];
    XCTAssertGreaterThan(collection.cyl_insetR, 17);
    collection.cyl_insetR += 8;
    collection.cyl_trailer = nil;
    XCTAssertEqualWithAccuracy(collection.cyl_insetR, 25, 0.001);
    XCTAssertEqual(trailer.state, CYLRefreshStateIdle);
    XCTAssertFalse(collection.alwaysBounceHorizontal);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    collection.cyl_footer = [CYLRefreshAutoNormalFooter footerWithRefreshingBlock:^{}];
    XCTAssertTrue(collection.alwaysBounceVertical);
    XCTAssertFalse(collection.alwaysBounceHorizontal);
    collection.cyl_footer = nil;
    window.hidden = YES;
}

- (void)testTrailerRemovalRestoresPriorBounceWithoutDoubleInsetReset {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    scrollView.alwaysBounceHorizontal = YES;
    scrollView.alwaysBounceVertical = YES;
    scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 15);
    CYLRefreshTrailer *trailer = [CYLRefreshNormalTrailer trailerWithRefreshingBlock:^{}];
    scrollView.cyl_trailer = trailer;
    scrollView.cyl_trailer = nil;
    XCTAssertTrue(scrollView.alwaysBounceHorizontal);
    XCTAssertTrue(scrollView.alwaysBounceVertical);
    XCTAssertEqualWithAccuracy(scrollView.cyl_insetR, 15, 0.001);
    [trailer beginRefreshing];
    XCTAssertEqual(trailer.state, CYLRefreshStateWillRefresh);
    scrollView.cyl_trailer = trailer;
    scrollView.cyl_trailer = nil;
    XCTAssertEqual(trailer.state, CYLRefreshStateIdle);
    XCTAssertEqualWithAccuracy(scrollView.cyl_insetR, 15, 0.001);
}

- (void)testReparentingActiveTrailerRestoresOldScrollView {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    window.rootViewController = [UIViewController new];
    UIScrollView *oldView = [[UIScrollView alloc] initWithFrame:window.bounds];
    UIScrollView *newView = [[UIScrollView alloc] initWithFrame:window.bounds];
    oldView.contentInset = UIEdgeInsetsMake(0, 0, 0, 12);
    newView.contentInset = UIEdgeInsetsMake(0, 0, 0, 24);
    [window.rootViewController.view addSubview:oldView];
    [window.rootViewController.view addSubview:newView];
    [window makeKeyAndVisible];
    CYLRefreshTrailer *trailer = [CYLRefreshNormalTrailer trailerWithRefreshingBlock:^{}];
    trailer.fastAnimationDuration = 0;
    trailer.slowAnimationDuration = 0;
    [oldView addSubview:trailer];
    [trailer layoutIfNeeded];
    XCTestExpectation *started = [self expectationWithDescription:@"active trailer"];
    [trailer beginRefreshingWithCompletionBlock:^{ [started fulfill]; }];
    [self waitForExpectations:@[started] timeout:5];
    [newView addSubview:trailer];
    XCTAssertEqualWithAccuracy(oldView.cyl_insetR, 12, 0.001);
    XCTAssertEqualWithAccuracy(newView.cyl_insetR, 24, 0.001);
    XCTAssertFalse(oldView.alwaysBounceHorizontal);
    XCTAssertTrue(newView.alwaysBounceHorizontal);
    XCTAssertEqual(trailer.state, CYLRefreshStateIdle);
    [trailer removeFromSuperview];
    XCTAssertFalse(newView.alwaysBounceHorizontal);
    window.hidden = YES;
}

- (void)testCollectionContentSizeAfterRemovingTrailerAndChangingDirection {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    window.rootViewController = [UIViewController new];
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake(80, 80);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *collection = [[UICollectionView alloc] initWithFrame:window.bounds
                                                      collectionViewLayout:layout];
    collection.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    CYLTestCollectionSource *source = [CYLTestCollectionSource new];
    collection.dataSource = source;
    [collection registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:@"cell"];
    [window.rootViewController.view addSubview:collection];
    [window makeKeyAndVisible];
    [collection reloadData];
    [collection layoutIfNeeded];
    XCTAssertGreaterThan(collection.contentSize.width, collection.bounds.size.width);
    CYLRefreshTrailer *trailer = [CYLRefreshNormalTrailer trailerWithRefreshingBlock:^{}];
    trailer.fastAnimationDuration = 0;
    trailer.slowAnimationDuration = 0;
    collection.cyl_trailer = trailer;
    [trailer layoutIfNeeded];
    XCTestExpectation *started = [self expectationWithDescription:@"collection trailer started"];
    [trailer beginRefreshingWithCompletionBlock:^{ [started fulfill]; }];
    [self waitForExpectations:@[started] timeout:5];
    collection.cyl_trailer = nil;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    [layout invalidateLayout];
    collection.cyl_footer = [CYLRefreshAutoNormalFooter footerWithRefreshingBlock:^{}];
    [collection layoutIfNeeded];
    XCTAssertEqualWithAccuracy(collection.contentSize.width, collection.bounds.size.width, 0.001);
    XCTAssertEqualWithAccuracy(collection.cyl_insetR, 0, 0.001);
    XCTAssertFalse(collection.alwaysBounceHorizontal);
    XCTAssertGreaterThan(collection.contentSize.height, collection.bounds.size.height);
    collection.cyl_footer = nil;
    window.hidden = YES;
}

- (void)testRemovingTrailerAfterEndingDoesNotRestoreInsetTwice {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    window.rootViewController = [UIViewController new];
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:window.bounds];
    scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 18);
    [window.rootViewController.view addSubview:scrollView];
    [window makeKeyAndVisible];
    CYLRefreshTrailer *trailer = [CYLRefreshNormalTrailer trailerWithRefreshingBlock:^{}];
    trailer.fastAnimationDuration = 0;
    trailer.slowAnimationDuration = 0;
    scrollView.cyl_trailer = trailer;
    [trailer layoutIfNeeded];
    XCTestExpectation *started = [self expectationWithDescription:@"trailer began"];
    [trailer beginRefreshingWithCompletionBlock:^{ [started fulfill]; }];
    [self waitForExpectations:@[started] timeout:5];
    XCTestExpectation *ended = [self expectationWithDescription:@"trailer ended"];
    [trailer endRefreshingWithCompletionBlock:^{ [ended fulfill]; }];
    [self waitForExpectations:@[ended] timeout:5];
    XCTAssertEqualWithAccuracy(scrollView.cyl_insetR, 18, 0.001);
    scrollView.cyl_trailer = nil;
    XCTAssertEqualWithAccuracy(scrollView.cyl_insetR, 18, 0.001);
    window.hidden = YES;
}

- (UIScrollView *)cyl_wideScrollViewInWindow:(UIWindow *)window contentWidth:(CGFloat)contentWidth {
    window.rootViewController = [UIViewController new];
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:window.bounds];
    scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    scrollView.contentSize = CGSizeMake(contentWidth, window.bounds.size.height);
    [window.rootViewController.view addSubview:scrollView];
    [window makeKeyAndVisible];
    return scrollView;
}

- (void)testTrailerRefreshesAutomaticallyAtTheEndWhenEnabled {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    UIScrollView *scrollView = [self cyl_wideScrollViewInWindow:window contentWidth:1000];
    XCTestExpectation *refreshed = [self expectationWithDescription:@"automatic trailer refresh"];
    __block NSUInteger callbacks = 0;
    CYLRefreshTrailer *trailer = [CYLRefreshNormalTrailer trailerWithRefreshingBlock:^{
        callbacks++;
        [refreshed fulfill];
    }];
    trailer.fastAnimationDuration = 0;
    trailer.slowAnimationDuration = 0;
    XCTAssertFalse(trailer.isAutomaticallyRefresh);
    XCTAssertEqualWithAccuracy(trailer.triggerAutomaticallyRefreshPercent, 1.0, 0.001);
    XCTAssertEqual(trailer.autoTriggerTimes, 1);
    trailer.automaticallyRefresh = YES;
    trailer.triggerAutomaticallyRefreshPercent = 0.5;
    scrollView.cyl_trailer = trailer;
    [trailer layoutIfNeeded];
    // The end of the content is at 680; half of the 60 pt trailer is 30 pt.
    scrollView.contentOffset = CGPointMake(700, 0);
    XCTAssertEqual(trailer.state, CYLRefreshStateIdle);
    scrollView.contentOffset = CGPointMake(711, 0);
    [self waitForExpectations:@[refreshed] timeout:5];
    XCTAssertEqual(trailer.state, CYLRefreshStateRefreshing);
    XCTAssertEqual(callbacks, 1u);
    XCTestExpectation *ended = [self expectationWithDescription:@"automatic trailer ended"];
    [trailer endRefreshingWithCompletionBlock:^{ [ended fulfill]; }];
    [self waitForExpectations:@[ended] timeout:5];
    XCTAssertEqualWithAccuracy(scrollView.cyl_insetR, 0, 0.001);
    XCTAssertEqual(callbacks, 1u);
    scrollView.cyl_trailer = nil;
    window.hidden = YES;
}

- (void)testTrailerKeepsPullAndReleaseBehaviorByDefault {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    UIScrollView *scrollView = [self cyl_wideScrollViewInWindow:window contentWidth:1000];
    __block NSUInteger callbacks = 0;
    CYLRefreshTrailer *trailer = [CYLRefreshNormalTrailer trailerWithRefreshingBlock:^{ callbacks++; }];
    trailer.fastAnimationDuration = 0;
    trailer.slowAnimationDuration = 0;
    scrollView.cyl_trailer = trailer;
    [trailer layoutIfNeeded];
    scrollView.contentOffset = CGPointMake(760, 0);
    XCTestExpectation *nextTurn = [self expectationWithDescription:@"no automatic refresh"];
    dispatch_async(dispatch_get_main_queue(), ^{ [nextTurn fulfill]; });
    [self waitForExpectations:@[nextTurn] timeout:5];
    XCTAssertEqual(trailer.state, CYLRefreshStateIdle);
    XCTAssertEqual(callbacks, 0u);
    scrollView.cyl_trailer = nil;
    window.hidden = YES;
}

- (void)testAutomaticTrailerIgnoresBounceBackShortContentAndActiveHeader {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    UIScrollView *scrollView = [self cyl_wideScrollViewInWindow:window contentWidth:1000];
    CYLRefreshTrailer *trailer = [CYLRefreshNormalTrailer trailerWithRefreshingBlock:^{}];
    trailer.fastAnimationDuration = 0;
    trailer.slowAnimationDuration = 0;
    scrollView.cyl_trailer = trailer;
    [trailer layoutIfNeeded];
    // Moving back toward the start must not trigger, even past the threshold.
    scrollView.contentOffset = CGPointMake(780, 0);
    trailer.automaticallyRefresh = YES;
    scrollView.contentOffset = CGPointMake(770, 0);
    XCTAssertEqual(trailer.state, CYLRefreshStateIdle);
    // While the header refreshes, the trailer waits.
    CYLRefreshNormalHeader *header = [CYLRefreshNormalHeader headerWithRefreshingBlock:^{}];
    scrollView.cyl_header = header;
    [header beginRefreshing];
    scrollView.contentOffset = CGPointMake(790, 0);
    XCTAssertEqual(trailer.state, CYLRefreshStateIdle);
    [header endRefreshing];
    scrollView.cyl_header = nil;
    // Content narrower than the view keeps pull-and-release.
    scrollView.contentOffset = CGPointZero;
    scrollView.contentSize = CGSizeMake(200, 480);
    scrollView.contentOffset = CGPointMake(80, 0);
    XCTAssertEqual(trailer.state, CYLRefreshStateIdle);
    scrollView.cyl_trailer = nil;
    window.hidden = YES;
}

- (void)testReusingTrailerDuringStartAnimationDoesNotRunOldRefreshCallback {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    window.rootViewController = [UIViewController new];
    UIScrollView *oldView = [[UIScrollView alloc] initWithFrame:window.bounds];
    UIScrollView *newView = [[UIScrollView alloc] initWithFrame:window.bounds];
    [window.rootViewController.view addSubview:oldView];
    [window.rootViewController.view addSubview:newView];
    [window makeKeyAndVisible];
    __block NSInteger callbacks = 0;
    CYLRefreshTrailer *trailer = [CYLRefreshNormalTrailer trailerWithRefreshingBlock:^{ callbacks++; }];
    trailer.fastAnimationDuration = 0.5;
    trailer.slowAnimationDuration = 0.2;
    [oldView addSubview:trailer];
    [trailer layoutIfNeeded];
    [trailer beginRefreshing];
    XCTAssertEqual(trailer.state, CYLRefreshStateRefreshing);
    [newView addSubview:trailer];
    [trailer layoutIfNeeded];
    [trailer beginRefreshing];
    XCTestExpectation *animationsFinished = [self expectationWithDescription:@"both start animations finished"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [animationsFinished fulfill];
    });
    [self waitForExpectations:@[animationsFinished] timeout:5];
    XCTAssertEqual(callbacks, 1);
    [trailer removeFromSuperview];
    window.hidden = YES;
}

- (void)testRemovingTrailerDuringStartCancelsStartCallbacksButCompletesEnding {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    window.rootViewController = [UIViewController new];
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:window.bounds];
    scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 19);
    [window.rootViewController.view addSubview:scrollView];
    [window makeKeyAndVisible];
    __block NSInteger refreshCallbacks = 0;
    __block NSInteger beginCallbacks = 0;
    CYLRefreshTrailer *trailer = [CYLRefreshNormalTrailer trailerWithRefreshingBlock:^{ refreshCallbacks++; }];
    trailer.fastAnimationDuration = 0.5;
    trailer.slowAnimationDuration = 0.2;
    scrollView.cyl_trailer = trailer;
    [trailer layoutIfNeeded];
    XCTestExpectation *ended = [self expectationWithDescription:@"detached refresh ended"];
    trailer.endRefreshingCompletionBlock = ^{ [ended fulfill]; };
    [trailer beginRefreshingWithCompletionBlock:^{ beginCallbacks++; }];
    scrollView.cyl_trailer = nil;
    XCTAssertEqualWithAccuracy(scrollView.cyl_insetR, 19, 0.001);
    XCTestExpectation *startAnimationFinished = [self expectationWithDescription:@"cancelled start animation finished"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [startAnimationFinished fulfill];
    });
    [self waitForExpectations:@[ended, startAnimationFinished] timeout:5];
    XCTAssertEqual(refreshCallbacks, 0);
    XCTAssertEqual(beginCallbacks, 0);
    window.hidden = YES;
}

- (void)testOldTrailerEndAnimationDoesNotResetNewRefreshProgress {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    window.rootViewController = [UIViewController new];
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:window.bounds];
    [window.rootViewController.view addSubview:scrollView];
    [window makeKeyAndVisible];
    CYLRefreshTrailer *trailer = [CYLRefreshNormalTrailer trailerWithRefreshingBlock:^{}];
    trailer.fastAnimationDuration = 0;
    trailer.slowAnimationDuration = 0.5;
    scrollView.cyl_trailer = trailer;
    [trailer layoutIfNeeded];
    XCTestExpectation *started = [self expectationWithDescription:@"first refresh started"];
    [trailer beginRefreshingWithCompletionBlock:^{ [started fulfill]; }];
    [self waitForExpectations:@[started] timeout:5];
    XCTestExpectation *ended = [self expectationWithDescription:@"first refresh ended"];
    [trailer endRefreshingWithCompletionBlock:^{ [ended fulfill]; }];
    trailer.beginRefreshingCompletionBlock = nil;
    [trailer beginRefreshing];
    [self waitForExpectations:@[ended] timeout:5];
    XCTAssertTrue(trailer.isRefreshing);
    XCTAssertEqualWithAccuracy(trailer.pullingPercent, 1, 0.001);
    trailer.endRefreshingCompletionBlock = nil;
    scrollView.cyl_trailer = nil;
    window.hidden = YES;
}

- (void)testOverlappingTrailerEndsCallTheirOwnCompletions {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    window.rootViewController = [UIViewController new];
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:window.bounds];
    [window.rootViewController.view addSubview:scrollView];
    [window makeKeyAndVisible];
    CYLRefreshTrailer *trailer = [CYLRefreshNormalTrailer trailerWithRefreshingBlock:^{}];
    trailer.fastAnimationDuration = 0;
    trailer.slowAnimationDuration = 0.5;
    scrollView.cyl_trailer = trailer;
    [trailer layoutIfNeeded];
    __block NSInteger firstEnds = 0;
    __block NSInteger secondEnds = 0;
    [trailer beginRefreshing];
    [trailer endRefreshingWithCompletionBlock:^{ firstEnds++; }];
    [trailer beginRefreshing];
    [trailer endRefreshingWithCompletionBlock:^{ secondEnds++; }];
    XCTestExpectation *finished = [self expectationWithDescription:@"end animations finished"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [finished fulfill];
    });
    [self waitForExpectations:@[finished] timeout:5];
    XCTAssertEqual(firstEnds, 1);
    XCTAssertEqual(secondEnds, 1);
    scrollView.cyl_trailer = nil;
    window.hidden = YES;
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

- (void)testPagingAutoFooterAcceptsReportedFloatingPointValues {
    CYLTestScrollView *scrollView = [[CYLTestScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    scrollView.cyl_testPan = [CYLTestPanGestureRecognizer new];
    scrollView.cyl_testPan.cyl_testState = UIGestureRecognizerStateEnded;
    scrollView.pagingEnabled = YES;
    CYLRefreshAutoFooter *footer = [CYLRefreshAutoNormalFooter footerWithRefreshingBlock:^{}];
    scrollView.cyl_footer = footer;

    CGFloat reportedThreshold = 1367.666666666698;
    CGFloat reportedOffset = 1367.666666666687;
    scrollView.contentSize = CGSizeMake(320, reportedThreshold + scrollView.cyl_h - scrollView.cyl_insetB);
    CGFloat actualThreshold = scrollView.cyl_contentH + scrollView.cyl_insetB - scrollView.cyl_h;
    XCTAssertEqualWithAccuracy(actualThreshold, reportedThreshold, 1e-12);
    XCTAssertLessThan(reportedOffset, actualThreshold);
    scrollView.cyl_testOffset = CGPointMake(0, reportedOffset);
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

- (void)testPagingBackFooterReturnsToLastPageAfterRefresh {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    window.rootViewController = [UIViewController new];
    CYLTestPagingScrollView *scrollView = [[CYLTestPagingScrollView alloc] initWithFrame:window.bounds];
    scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    scrollView.contentSize = CGSizeMake(320, 1440);
    scrollView.pagingEnabled = YES;
    [window.rootViewController.view addSubview:scrollView];
    [window makeKeyAndVisible];
    CYLRefreshBackFooter *footer = [CYLRefreshBackNormalFooter footerWithRefreshingBlock:^{}];
    footer.fastAnimationDuration = 0;
    footer.slowAnimationDuration = 0;
    scrollView.cyl_footer = footer;
    scrollView.contentOffset = CGPointMake(0, 960);
    XCTestExpectation *started = [self expectationWithDescription:@"paging back footer started"];
    [footer beginRefreshingWithCompletionBlock:^{ [started fulfill]; }];
    [self waitForExpectations:@[started] timeout:5];
    XCTAssertGreaterThan(scrollView.contentOffset.y, 960);
    XCTestExpectation *ended = [self expectationWithDescription:@"paging back footer ended"];
    [footer endRefreshingWithCompletionBlock:^{ [ended fulfill]; }];
    [self waitForExpectations:@[ended] timeout:5];
    XCTAssertEqualWithAccuracy(scrollView.contentOffset.y, 960, 0.01);
    scrollView.cyl_footer = nil;
    window.hidden = YES;
}

- (void)testPagingBackFooterPreservesPreviousPageWhenContentGrows {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    window.rootViewController = [UIViewController new];
    CYLTestPagingScrollView *scrollView = [[CYLTestPagingScrollView alloc] initWithFrame:window.bounds];
    scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    scrollView.contentSize = CGSizeMake(320, 1440);
    scrollView.pagingEnabled = YES;
    [window.rootViewController.view addSubview:scrollView];
    [window makeKeyAndVisible];
    CYLRefreshBackFooter *footer = [CYLRefreshBackNormalFooter footerWithRefreshingBlock:^{}];
    footer.fastAnimationDuration = 0;
    footer.slowAnimationDuration = 0;
    scrollView.cyl_footer = footer;
    scrollView.contentOffset = CGPointMake(0, 960);
    XCTestExpectation *started = [self expectationWithDescription:@"paging back footer started"];
    [footer beginRefreshingWithCompletionBlock:^{ [started fulfill]; }];
    [self waitForExpectations:@[started] timeout:5];
    scrollView.contentSize = CGSizeMake(320, 1920);
    XCTestExpectation *ended = [self expectationWithDescription:@"paging back footer ended"];
    [footer endRefreshingWithCompletionBlock:^{ [ended fulfill]; }];
    [self waitForExpectations:@[ended] timeout:5];
    XCTAssertEqualWithAccuracy(scrollView.contentOffset.y, 960, 0.01);
    scrollView.cyl_footer = nil;
    window.hidden = YES;
}

- (void)testPagingBackFooterDoesNotOverrideCallerOrActiveScrolling {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    window.rootViewController = [UIViewController new];
    CYLTestPagingScrollView *scrollView = [[CYLTestPagingScrollView alloc] initWithFrame:window.bounds];
    scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    scrollView.contentSize = CGSizeMake(320, 1440);
    scrollView.pagingEnabled = YES;
    [window.rootViewController.view addSubview:scrollView];
    [window makeKeyAndVisible];
    CYLRefreshBackFooter *footer = [CYLRefreshBackNormalFooter footerWithRefreshingBlock:^{}];
    footer.fastAnimationDuration = 0;
    footer.slowAnimationDuration = 0;
    scrollView.cyl_footer = footer;
    for (NSInteger scenario = 0; scenario < 3; scenario++) {
        scrollView.cyl_testDragging = NO;
        scrollView.cyl_testDecelerating = NO;
        scrollView.contentSize = CGSizeMake(320, 1440);
        scrollView.contentOffset = CGPointMake(0, 960);
        XCTestExpectation *started = [self expectationWithDescription:@"paging footer started"];
        [footer beginRefreshingWithCompletionBlock:^{ [started fulfill]; }];
        [self waitForExpectations:@[started] timeout:5];
        scrollView.contentSize = CGSizeMake(320, 1920);
        if (scenario == 0) scrollView.contentOffset = CGPointMake(0, 1440);
        if (scenario == 1) scrollView.cyl_testDragging = YES;
        if (scenario == 2) scrollView.cyl_testDecelerating = YES;
        CGFloat expectedOffset = scrollView.contentOffset.y;
        XCTestExpectation *ended = [self expectationWithDescription:@"paging footer ended"];
        [footer endRefreshingWithCompletionBlock:^{ [ended fulfill]; }];
        [self waitForExpectations:@[ended] timeout:5];
        XCTAssertEqualWithAccuracy(scrollView.contentOffset.y, expectedOffset, 0.01);
    }
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
