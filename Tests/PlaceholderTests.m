#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import "../CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLTableViewPlaceHolderDelegate.h"
#import "../CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/UITableView+CYLTableViewPlaceHolder.h"
#import "CYLRefresh.h"
#import "CYLRefreshValueAnimator.h"
// CYLPlaceholderView is Swift: its interface comes with the umbrella header (the generated Swift header).
#import "CYLTableViewPlaceHolder.h"

/// Upper bound for condition-based waits. UIView animation completions, even for 0-second
/// animations, have stalled for over 5 s on loaded CI runners; waits still end as soon as the
/// expectation is fulfilled, so a generous bound costs nothing when tests pass.
static const NSTimeInterval CYLTestTimeout = 30;

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

// [EN] A scroll view that reports a drag and a pan state set by the test. [CN] 由测试设置拖动与手势状态的滚动视图。
@interface CYLTestDraggingScrollView : UIScrollView
@property (nonatomic) BOOL cyl_testDragging;
@property (nonatomic, strong) CYLTestPanGestureRecognizer *cyl_testPan;
@end
@implementation CYLTestDraggingScrollView
- (BOOL)isDragging { return self.cyl_testDragging; }
- (UIPanGestureRecognizer *)panGestureRecognizer { return self.cyl_testPan ?: [super panGestureRecognizer]; }
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

/// Two empty sections with custom section headers; the placeholder starts below the last one (issue #16).
@interface CYLSectionHeaderSource : NSObject <UITableViewDataSource, UITableViewDelegate, CYLTableViewPlaceHolderDelegate>
@property (nonatomic, strong) UIView *view;
@end
@implementation CYLSectionHeaderSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 2; }
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return 0; }
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section { return 30; }
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 30)];
}
- (UIView *)makePlaceHolderView { return self.view; }
- (CGRect)frameForPlaceHolderViewInTableView:(UITableView *)tableView {
    NSInteger lastSection = [tableView numberOfSections] - 1;
    CGFloat top = lastSection >= 0 ? CGRectGetMaxY([tableView rectForHeaderInSection:lastSection]) : 0;
    return CGRectMake(0, top, CGRectGetWidth(tableView.bounds), MAX(0, CGRectGetHeight(tableView.bounds) - top));
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

- (void)testDefaultFrameStaysAboveTheKeyboard {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [window addSubview:self.table];
    [self.table cyl_reloadData];
    XCTAssertEqualWithAccuracy(CGRectGetHeight(self.source.view.frame), 480, 0.1, @"no keyboard: the whole table");
    // [EN] A 200-point keyboard at the bottom of the screen (CYLSearchViewController's report). [CN] 屏幕底部 200 点高的键盘。
    CGRect keyboard = [window convertRect:CGRectMake(0, 280, 320, 200) toCoordinateSpace:window.screen.coordinateSpace];
    [NSNotificationCenter.defaultCenter postNotificationName:UIKeyboardWillChangeFrameNotification object:nil
        userInfo:@{UIKeyboardFrameEndUserInfoKey: [NSValue valueWithCGRect:keyboard]}];
    XCTAssertEqualWithAccuracy(CGRectGetHeight(self.source.view.frame), 280, 0.1, @"above the keyboard, live");
    [self.table cyl_reloadData];
    XCTAssertEqualWithAccuracy(CGRectGetHeight(self.source.view.frame), 280, 0.1, @"a reload keeps it above the keyboard");
    [NSNotificationCenter.defaultCenter postNotificationName:UIKeyboardWillHideNotification object:nil userInfo:nil];
    XCTAssertEqualWithAccuracy(CGRectGetHeight(self.source.view.frame), 480, 0.1, @"the keyboard hides: the whole table again");
    [self.table removeFromSuperview];
}

- (void)testPlaceholderShownWhileTheKeyboardIsUpEndsAtTheKeyboard {
    // [EN] CYLSearchViewController's search: the keyboard is up before the first empty result, and the table has a top
    //      bar inset. [CN] CYLSearchViewController 的搜索：键盘在第一次空结果之前已显示，表格有顶部栏内边距。
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [window addSubview:self.table];
    self.table.contentInset = UIEdgeInsetsMake(100, 0, 0, 0);
    CGRect keyboard = [window convertRect:CGRectMake(0, 280, 320, 200) toCoordinateSpace:window.screen.coordinateSpace];
    [NSNotificationCenter.defaultCenter postNotificationName:UIKeyboardWillChangeFrameNotification object:nil
        userInfo:@{UIKeyboardFrameEndUserInfoKey: [NSValue valueWithCGRect:keyboard]}];
    [self.table cyl_reloadData];
    CGFloat inset = self.table.adjustedContentInset.top;
    XCTAssertEqualWithAccuracy(CGRectGetHeight(self.source.view.frame), 480 - inset - 200, 0.1,
                               @"from below the top bar to the keyboard's top");
    [NSNotificationCenter.defaultCenter postNotificationName:UIKeyboardWillHideNotification object:nil userInfo:nil];
    XCTAssertEqualWithAccuracy(CGRectGetHeight(self.source.view.frame), 480, 0.1, @"no keyboard: as before");
    [self.table removeFromSuperview];
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

- (void)testCustomFrameLeavesSectionHeadersOutsidePlaceholder {
    CYLSectionHeaderSource *source = [CYLSectionHeaderSource new];
    source.view = [UIView new];
    self.table.dataSource = source;
    self.table.delegate = source;
    UIView *tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    self.table.tableHeaderView = tableHeader;
    for (NSValue *size in @[[NSValue valueWithCGSize:CGSizeMake(320, 480)], [NSValue valueWithCGSize:CGSizeMake(480, 320)]]) {
        // Rotation: the app reloads after the size changes and the frame is recomputed.
        self.table.frame = (CGRect){CGPointZero, size.CGSizeValue};
        [self.table cyl_reloadData];
        [self.table layoutIfNeeded];
        CGRect placeholder = source.view.frame;
        XCTAssertEqual(source.view.superview, self.table);
        XCTAssertEqualWithAccuracy(CGRectGetWidth(placeholder), size.CGSizeValue.width, 0.001);
        XCTAssertGreaterThan(CGRectGetHeight(placeholder), 0);
        XCTAssertFalse(CGRectIntersectsRect(placeholder, tableHeader.frame), @"%@ vs table header %@",
                       NSStringFromCGRect(placeholder), NSStringFromCGRect(tableHeader.frame));
        for (NSInteger section = 0; section < 2; section++) {
            CGRect header = [self.table rectForHeaderInSection:section];
            XCTAssertGreaterThan(CGRectGetHeight(header), 0);
            XCTAssertFalse(CGRectIntersectsRect(placeholder, header), @"%@ vs section %ld header %@ at %@",
                           NSStringFromCGRect(placeholder), (long)section, NSStringFromCGRect(header),
                           NSStringFromCGSize(size.CGSizeValue));
        }
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
    [self waitForExpectations:@[started] timeout:CYLTestTimeout];
    XCTAssertTrue(self.table.cyl_header.isRefreshing);
    XCTestExpectation *ended = [self expectationWithDescription:@"refresh completion"];
    [self.table.cyl_header endRefreshingWithCompletionBlock:^{
        [ended fulfill];
    }];
    [self waitForExpectations:@[ended] timeout:CYLTestTimeout];
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
        [self waitForExpectations:@[started] timeout:CYLTestTimeout];
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
    [self waitForExpectations:@[nextTurn] timeout:CYLTestTimeout];
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
    [self waitForExpectations:@[nextTurn] timeout:CYLTestTimeout];
    XCTAssertEqual(footer.state, CYLRefreshStateWillRefresh);
    XCTAssertEqual(callbacks, 0u);
    [window.rootViewController.view addSubview:scrollView];
    [self waitForExpectations:@[started] timeout:CYLTestTimeout];
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
        [self waitForExpectations:@[started] timeout:CYLTestTimeout];
        XCTAssertEqualWithAccuracy(self.table.cyl_insetT, 20 + header.cyl_h, 0.001);
        XCTestExpectation *ended = [self expectationWithDescription:@"header ended"];
        [header endRefreshingWithCompletionBlock:^{ [ended fulfill]; }];
        [self waitForExpectations:@[ended] timeout:CYLTestTimeout];
        XCTAssertEqualWithAccuracy(self.table.cyl_insetT, 20, 0.001);
    }
    self.table.cyl_header = nil;
    window.hidden = YES;
}

// FIX: issue MJRefresh#1628
// [EN] SwiftUI's ScrollView resets the inset and the offset when its data changes during a refresh; the header adds its
//      refreshing inset again on the new original inset and stays visible, and ending the refresh returns to that inset.
// [CN] 刷新期间 SwiftUI 的 ScrollView 在数据变化时重置 inset 和 offset；刷新头在新的原始 inset 上重新加上刷新 inset 并保持可见，
//      结束刷新后回到该 inset。
- (void)testHeaderKeepsItsRefreshingInsetWhenTheInsetIsResetDuringARefresh {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    window.rootViewController = [UIViewController new];
    [window.rootViewController.view addSubview:self.table];
    self.table.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.table.contentInset = UIEdgeInsetsZero;
    [window makeKeyAndVisible];
    CYLRefreshHeader *header = [CYLRefreshNormalHeader headerWithRefreshingBlock:^{}];
    header.fastAnimationDuration = 0;
    header.slowAnimationDuration = 0;
    self.table.cyl_header = header;
    XCTestExpectation *started = [self expectationWithDescription:@"header started"];
    [header beginRefreshingWithCompletionBlock:^{ [started fulfill]; }];
    [self waitForExpectations:@[started] timeout:CYLTestTimeout];
    XCTAssertEqualWithAccuracy(self.table.cyl_insetT, header.cyl_h, 0.001);

    // [EN] The reset of the original issue: inset and offset back to zero. [CN] 原 issue 中的重置：inset 与 offset 归零。
    self.table.contentOffset = CGPointZero;
    self.table.contentInset = UIEdgeInsetsZero;
    XCTAssertTrue(header.isRefreshing);
    XCTAssertEqualWithAccuracy(self.table.cyl_insetT, header.cyl_h, 0.001);
    XCTAssertEqualWithAccuracy(self.table.contentOffset.y, -header.cyl_h, 0.001);
    CGRect headerFrame = [header convertRect:header.bounds toView:window];
    CGRect viewport = [self.table convertRect:self.table.bounds toView:window];
    XCTAssertTrue(CGRectIntersectsRect(headerFrame, viewport));

    // [EN] A new inset written during the refresh becomes the original inset. [CN] 刷新期间写入的新 inset 成为原始 inset。
    self.table.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    XCTAssertEqualWithAccuracy(self.table.cyl_insetT, 20 + header.cyl_h, 0.001);
    XCTAssertEqualWithAccuracy(self.table.contentOffset.y, -(20 + header.cyl_h), 0.001);

    XCTestExpectation *ended = [self expectationWithDescription:@"header ended"];
    [header endRefreshingWithCompletionBlock:^{ [ended fulfill]; }];
    [self waitForExpectations:@[ended] timeout:CYLTestTimeout];
    XCTAssertEqualWithAccuracy(self.table.cyl_insetT, 20, 0.001);
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
    [self waitForExpectations:@[started] timeout:CYLTestTimeout];
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
    [self waitForExpectations:@[ended] timeout:CYLTestTimeout];
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
    [self waitForExpectations:@[started] timeout:CYLTestTimeout];
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
        [self waitForExpectations:@[started] timeout:CYLTestTimeout];
        XCTAssertEqualWithAccuracy(self.table.cyl_insetT, 20 + header.cyl_h, 0.001);
        XCTestExpectation *ended = [self expectationWithDescription:@"hidden header ended"];
        [header endRefreshingWithCompletionBlock:^{ [ended fulfill]; }];
        [self waitForExpectations:@[ended] timeout:CYLTestTimeout];
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
        [self waitForExpectations:@[started] timeout:CYLTestTimeout];
        XCTAssertEqualWithAccuracy(collection.cyl_insetT, 20 + header.cyl_h, 0.001);
        XCTestExpectation *ended = [self expectationWithDescription:@"collection header ended"];
        [header endRefreshingWithCompletionBlock:^{ [ended fulfill]; }];
        [self waitForExpectations:@[ended] timeout:CYLTestTimeout];
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

- (void)testRefreshResourcesLiveInTheSingleLibraryBundle {
    NSBundle *bundle = [NSBundle cyl_refreshBundle];
    XCTAssertNotNil(bundle);
    XCTAssertEqualObjects(bundle.bundlePath.lastPathComponent, @"CYLTableViewPlaceHolder.bundle");
    // The former separate resource bundle is gone everywhere it used to be copied.
    NSBundle *container = [NSBundle bundleForClass:CYLRefreshComponent.class];
    XCTAssertNil([container pathForResource:@"CYLRefresh" ofType:@"bundle"]);
    XCTAssertNil([NSBundle.mainBundle pathForResource:@"CYLRefresh" ofType:@"bundle"]);
    XCTAssertNotNil([NSBundle cyl_arrowImage]);
    XCTAssertNotNil([NSBundle cyl_trailArrowImage]);
    NSArray<NSString *> *keys = @[@"CYLRefreshHeaderIdleText", @"CYLRefreshHeaderPullingText",
        @"CYLRefreshHeaderRefreshingText", @"CYLRefreshTrailerIdleText", @"CYLRefreshTrailerPullingText",
        @"CYLRefreshAutoFooterIdleText", @"CYLRefreshAutoFooterRefreshingText", @"CYLRefreshAutoFooterNoMoreDataText",
        @"CYLRefreshBackFooterIdleText", @"CYLRefreshBackFooterPullingText", @"CYLRefreshBackFooterRefreshingText",
        @"CYLRefreshBackFooterNoMoreDataText", @"CYLRefreshHeaderLastTimeText", @"CYLRefreshHeaderDateTodayText",
        @"CYLRefreshHeaderNoneLastDateText", @"CYLRefreshHeaderFinishedText", @"CYLRefreshHeaderFailedText",
        @"CYLRefreshFooterFinishedText", @"CYLRefreshFooterFailedText"];
    for (NSString *language in @[@"en", @"zh-Hans", @"zh-Hant", @"ja", @"ko", @"ru", @"uk"]) {
        NSString *path = [bundle pathForResource:language ofType:@"lproj"];
        XCTAssertNotNil(path, @"Missing localization %@", language);
        if (!path) continue;
        NSBundle *languageBundle = [NSBundle bundleWithPath:path];
        for (NSString *key in keys) {
            NSString *text = [languageBundle localizedStringForKey:key value:nil table:@"CYLRefresh"];
            XCTAssertNotEqualObjects(text, key, @"Missing %@ in %@", key, language);
            XCTAssertTrue(text.length > 0);
        }
    }
}

- (void)testRefreshTrailerAndJapaneseTextsAreLocalized {
    @try {
        // Before the bundles were merged, the trailer texts existed only in Chinese.
        CYLRefreshConfig.defaultConfig.languageCode = @"en";
        XCTAssertEqualObjects([NSBundle cyl_localizedStringForKey:CYLRefreshTrailerIdleText], @"Swipe to see details");
        CYLRefreshConfig.defaultConfig.languageCode = @"ja-JP";
        XCTAssertEqualObjects([NSBundle cyl_localizedStringForKey:CYLRefreshHeaderIdleText], @"下に引っ張って更新");
        CYLRefreshConfig.defaultConfig.languageCode = @"ko";
        XCTAssertEqualObjects([NSBundle cyl_localizedStringForKey:CYLRefreshTrailerPullingText], @"놓으면 상세 정보 보기");
    } @finally {
        CYLRefreshConfig.defaultConfig.languageCode = nil;
    }
}

- (void)testLastUpdatedTimeIsLocaleAwareAndComparesWholeDates {
    NSString *key = @"CYLTestLastUpdatedTime";
    CYLRefreshNormalHeader *header = [CYLRefreshNormalHeader headerWithRefreshingBlock:^{}];
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    @try {
        CYLRefreshConfig.defaultConfig.languageCode = @"en-US";
        [NSUserDefaults.standardUserDefaults setObject:[NSDate date] forKey:key];
        header.lastUpdatedTimeKey = key;
        XCTAssertTrue([header.lastUpdatedTimeLabel.text containsString:@"Today"], @"%@", header.lastUpdatedTimeLabel.text);

        // A month ago is usually the same day of the month; it used to be shown as "Today".
        NSDate *lastMonth = [calendar dateByAddingUnit:NSCalendarUnitMonth value:-1 toDate:[NSDate date] options:0];
        [NSUserDefaults.standardUserDefaults setObject:lastMonth forKey:key];
        header.lastUpdatedTimeKey = key;
        NSString *english = header.lastUpdatedTimeLabel.text;
        XCTAssertFalse([english containsString:@"Today"], @"%@", english);
        // en-US uses a 12-hour clock.
        XCTAssertTrue([english containsString:@"AM"] || [english containsString:@"PM"], @"%@", english);

        // German has no built-in strings (English is used) but its locale formats a 24-hour clock.
        CYLRefreshConfig.defaultConfig.languageCode = @"de-DE";
        header.lastUpdatedTimeKey = key;
        NSString *german = header.lastUpdatedTimeLabel.text;
        XCTAssertTrue([german hasPrefix:@"Last update: "], @"%@", german);
        XCTAssertFalse([german containsString:@"AM"] || [german containsString:@"PM"], @"%@", german);
    } @finally {
        [NSUserDefaults.standardUserDefaults removeObjectForKey:key];
        CYLRefreshConfig.defaultConfig.languageCode = nil;
    }
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

// FIX: issue MJRefresh#1630
// [EN] A controller torn down while its table's header and footer refresh, after the footer moved to another table and
//      back, 100 times: no "not registered as an observer" exception, and the table, the header and the footer are
//      released.
// [CN] 控制器在表格的刷新头和刷新尾正在刷新时销毁（刷新尾先移到另一个表格再移回），重复 100 次：不抛出“未注册为观察者”的异常，
//      表格、刷新头和刷新尾都被释放。
- (void)testControllerTeardownWhileRefreshingReleasesWithoutObserverExceptions {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:[UIViewController new]];
    window.rootViewController = navigation;
    [window makeKeyAndVisible];
    __weak UITableView *weakTable = nil;
    __weak CYLRefreshComponent *weakHeader = nil;
    __weak CYLRefreshComponent *weakFooter = nil;
    for (NSUInteger index = 0; index < 100; index++) {
        @autoreleasepool {
            UIViewController *controller = [UIViewController new];
            UITableView *table = [[UITableView alloc] initWithFrame:controller.view.bounds style:UITableViewStylePlain];
            UITableView *other = [[UITableView alloc] initWithFrame:controller.view.bounds style:UITableViewStylePlain];
            [controller.view addSubview:table];
            [controller.view addSubview:other];
            CYLRefreshHeader *header = [CYLRefreshNormalHeader headerWithRefreshingBlock:^{}];
            CYLRefreshFooter *footer = index % 2 ? [CYLRefreshAutoNormalFooter footerWithRefreshingBlock:^{}]
                                                 : [CYLRefreshBackNormalFooter footerWithRefreshingBlock:^{}];
            for (CYLRefreshComponent *component in @[header, footer]) {
                component.fastAnimationDuration = 0;
                component.slowAnimationDuration = 0;
            }
            table.cyl_header = header;
            table.cyl_footer = footer;
            [navigation pushViewController:controller animated:NO];
            [controller.view layoutIfNeeded];
            XCTAssertNoThrow([other addSubview:footer]);
            XCTAssertNoThrow([table addSubview:footer]);
            [header beginRefreshing];
            [footer beginRefreshing];
            weakTable = table;
            weakHeader = header;
            weakFooter = footer;
            XCTAssertNoThrow([navigation popViewControllerAnimated:NO]);
            XCTAssertNoThrow([table removeFromSuperview]);
        }
        // [EN] Let the queued start, animation and layout work run after the teardown; then the table and header are released.
        // [CN] 让排队的开始、动画与布局任务在销毁后执行；之后表格和刷新头被释放。
        NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:CYLTestTimeout];
        while ((weakTable || weakHeader || weakFooter) && deadline.timeIntervalSinceNow > 0) {
            [NSRunLoop.mainRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        }
        XCTAssertNil(weakTable);
        XCTAssertNil(weakHeader);
        XCTAssertNil(weakFooter, @"iteration %lu", (unsigned long)index);
    }
    window.hidden = YES;
}

/// [EN] Tears down a controller whose table refreshes with `component` (a footer, a trailer or a header) and waits, at
///      most CYLTestTimeout, for the table and the component to be released. Returns YES when both were released.
/// [CN] 销毁一个控制器，其表格正在用 `component`（刷新尾、trailer 或刷新头）刷新，并最多等待 CYLTestTimeout，直到表格与该控件都被释放。
///      两者都释放时返回 YES。
- (BOOL)cyl_tearDownWhileRefreshing:(CYLRefreshComponent * (^)(void))makeComponent
                         navigation:(UINavigationController *)navigation
                      zeroDurations:(BOOL)zeroDurations
{
    __weak CYLRefreshComponent *weakComponent = nil;
    __weak UITableView *weakTable = nil;
    @autoreleasepool {
        UIViewController *controller = [UIViewController new];
        UITableView *table = [[UITableView alloc] initWithFrame:controller.view.bounds style:UITableViewStylePlain];
        UITableView *other = [[UITableView alloc] initWithFrame:controller.view.bounds style:UITableViewStylePlain];
        [controller.view addSubview:table];
        [controller.view addSubview:other];
        CYLRefreshComponent *component = makeComponent();
        component.refreshingBlock = ^{};
        BOOL isHeader = [component isKindOfClass:CYLRefreshHeader.class];
        CYLRefreshHeader *header = isHeader ? (CYLRefreshHeader *)component
                                            : [CYLRefreshNormalHeader headerWithRefreshingBlock:^{}];
        for (CYLRefreshComponent *each in @[header, component]) {
            if (!zeroDurations) continue;
            each.fastAnimationDuration = 0;
            each.slowAnimationDuration = 0;
        }
        table.cyl_header = header;
        if ([component isKindOfClass:CYLRefreshTrailer.class]) {
            table.cyl_trailer = (CYLRefreshTrailer *)component;
        } else if ([component isKindOfClass:CYLRefreshFooter.class]) {
            table.cyl_footer = (CYLRefreshFooter *)component;
        }
        [navigation pushViewController:controller animated:NO];
        [controller.view layoutIfNeeded];
        if (!isHeader) {
            [other addSubview:component];
            [table addSubview:component];
        }
        [header beginRefreshing];
        [component beginRefreshing];
        // [EN] Let the refresh start and its animations, timers and display links run. [CN] 让刷新开始，并让其动画、定时器与 display link 运行。
        [NSRunLoop.mainRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.3]];
        weakComponent = component;
        weakTable = table;
        [navigation popViewControllerAnimated:NO];
        [table removeFromSuperview];
    }
    NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:CYLTestTimeout];
    while ((weakTable || weakComponent) && deadline.timeIntervalSinceNow > 0) {
        [NSRunLoop.mainRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    }
    return !weakTable && !weakComponent;
}

// FIX: issue MJRefresh#1630
// [EN] Every footer kind and both trailers (with icon images where the kind takes them, and a drawn footer hosting the
//      StoreHouse style, which runs a timer), torn down while refreshing, with zero and with default animation
//      durations: the table and the footer are released.
// [CN] 每种刷新尾和两种 trailer（支持图标图片的设置图片，另加一个内嵌 StoreHouse 样式、会运行定时器的手绘刷新尾），在刷新中销毁，动画时长为 0
//      与默认值各一次：表格和刷新尾都被释放。
- (void)testEveryFooterKindIsReleasedAfterTeardownWhileRefreshing {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:[UIViewController new]];
    window.rootViewController = navigation;
    [window makeKeyAndVisible];
    UIImage *image = [UIImage systemImageNamed:@"star"];
    NSArray<Class> *kinds = @[
        CYLRefreshAutoFooter.class, CYLRefreshAutoStateFooter.class, CYLRefreshAutoNormalFooter.class,
        CYLRefreshAutoAnimationFooter.class, CYLRefreshAutoGifFooter.class,
        CYLRefreshBackFooter.class, CYLRefreshBackStateFooter.class, CYLRefreshBackNormalFooter.class,
        CYLRefreshBackAnimationFooter.class, CYLRefreshBackGifFooter.class,
        CYLRefreshCupertinoFooter.class, CYLRefreshBallPulseFooter.class,
        CYLRefreshBezierRadarFooter.class, CYLRefreshMaterialFooter.class, CYLRefreshDeliveryFooter.class,
        CYLRefreshPhoenixFooter.class, CYLRefreshTaurusFooter.class, CYLRefreshDrawnFooter.class,
        CYLRefreshStateTrailer.class, CYLRefreshNormalTrailer.class,
    ];
    for (NSNumber *zero in @[@YES, @NO]) {
        for (Class kind in kinds) {
            BOOL released = [self cyl_tearDownWhileRefreshing:^CYLRefreshComponent *{
                if (kind == CYLRefreshDrawnFooter.class) {
                    return [[CYLRefreshDrawnFooter alloc] initWithStyle:[CYLRefreshStoreHouseHeader newWithString:@"CYL"]];
                }
                if ([kind isSubclassOfClass:CYLRefreshTrailer.class]) return [kind trailerWithRefreshingBlock:^{}];
                CYLRefreshFooter *footer = [kind footerWithRefreshingBlock:^{}];
                if ([footer conformsToProtocol:@protocol(CYLRefreshIconAnimating)]) {
                    [footer cyl_setIconImages:@[image, image] duration:0.2 forState:CYLRefreshStateIdle];
                    [footer cyl_setIconImages:@[image, image] duration:0.2 forState:CYLRefreshStateRefreshing];
                }
                return footer;
            } navigation:navigation zeroDurations:zero.boolValue];
            XCTAssertTrue(released, @"%@ (zero durations: %@) is still alive", NSStringFromClass(kind), zero);
        }
    }
    window.hidden = YES;
}

// [EN] Every header kind torn down while refreshing is released. The StoreHouse header was not: its loading timer was a
//      target-action NSTimer, which retains the header, and it was invalidated only on a tick after the refresh ended.
// [CN] 每种刷新头在刷新中销毁后都被释放。StoreHouse 刷新头此前不会：其加载定时器是强持有刷新头的 target-action NSTimer，只在刷新结束后的某次
//      触发时才失效。
- (void)testEveryHeaderKindIsReleasedAfterTeardownWhileRefreshing {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:[UIViewController new]];
    window.rootViewController = navigation;
    [window makeKeyAndVisible];
    NSArray<Class> *kinds = @[
        CYLRefreshStateHeader.class, CYLRefreshNormalHeader.class, CYLRefreshAnimationHeader.class,
        CYLRefreshGifHeader.class, CYLRefreshCupertinoHeader.class, CYLRefreshBezierCircleHeader.class,
        CYLRefreshBezierRadarHeader.class, CYLRefreshDeliveryHeader.class, CYLRefreshDropBoxHeader.class,
        CYLRefreshFlyHeader.class, CYLRefreshGameBattleCityHeader.class, CYLRefreshGameHitBlockHeader.class,
        CYLRefreshMaterialHeader.class, CYLRefreshOriginalHeader.class, CYLRefreshPhoenixHeader.class,
        CYLRefreshStoreHouseHeader.class, CYLRefreshTaurusHeader.class, CYLRefreshWaveSwipeHeader.class,
    ];
    for (Class kind in kinds) {
        BOOL released = [self cyl_tearDownWhileRefreshing:^CYLRefreshComponent *{
            if (kind == CYLRefreshStoreHouseHeader.class) return [CYLRefreshStoreHouseHeader newWithString:@"CYL"];
            return [kind headerWithRefreshingBlock:^{}];
        } navigation:navigation zeroDurations:NO];
        XCTAssertTrue(released, @"%@ is still alive", NSStringFromClass(kind));
    }
    window.hidden = YES;
}

// [EN] An endless value animator (repeatCount INFINITY) stops once its weak target is released, so its display link and
//      the animator itself are released instead of ticking for ever.
// [CN] 无限重复（repeatCount INFINITY）的数值动画器在其弱引用 target 释放后停止，使 display link 与动画器本身被释放，而不是永远空转。
- (void)testEndlessValueAnimatorStopsWhenItsTargetIsReleased {
    __weak CYLRefreshValueAnimator *weakAnimator = nil;
    @autoreleasepool {
        UIView *target = [UIView new];
        CYLRefreshValueAnimator *animator = [CYLRefreshValueAnimator newWithTarget:target selector:@selector(setNeedsDisplay)];
        animator.repeatCount = INFINITY;
        animator.duration = 0.1;
        [animator start];
        XCTAssertTrue(animator.isRunning);
        weakAnimator = animator;
    }
    NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:CYLTestTimeout];
    while (weakAnimator && deadline.timeIntervalSinceNow > 0) {
        [NSRunLoop.mainRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    }
    XCTAssertNil(weakAnimator);
}

// FIX: MJRefresh PR #1444 (device rotation)
// [EN] The system part of the top inset changes while the header refreshes (a rotation changes the bars' height and the
//      safe area; here additionalSafeAreaInsets), then the user scrolls and the refresh ends: the header works from the
//      new system inset, never adds more than its own height, and gives back exactly what it added.
// [CN] 刷新头刷新期间顶部 inset 的系统部分发生变化（旋转会改变栏高与安全区；这里用 additionalSafeAreaInsets 模拟），随后用户滚动、刷新
//      结束：刷新头以新的系统 inset 为准，增加的量不超过自身高度，结束时恰好归还所增加的量。
- (void)testSystemInsetChangeDuringRefreshRestoresTheContentInset {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    UIViewController *controller = [UIViewController new];
    window.rootViewController = controller;
    [window makeKeyAndVisible];
    UITableView *table = [[UITableView alloc] initWithFrame:controller.view.bounds style:UITableViewStylePlain];
    table.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    table.contentSize = CGSizeMake(320, 2000);
    [controller.view addSubview:table];
    controller.additionalSafeAreaInsets = UIEdgeInsetsMake(100, 0, 0, 0);
    [controller.view layoutIfNeeded];
    CGFloat systemTop = table.adjustedContentInset.top - table.contentInset.top;
    CYLRefreshHeader *header = [CYLRefreshNormalHeader headerWithRefreshingBlock:^{}];
    header.fastAnimationDuration = 0;
    header.slowAnimationDuration = 0;
    table.cyl_header = header;
    table.contentOffset = CGPointMake(0, -table.adjustedContentInset.top);
    [header beginRefreshing];
    NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:CYLTestTimeout];
    while (header.state != CYLRefreshStateRefreshing && deadline.timeIntervalSinceNow > 0) {
        [NSRunLoop.mainRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    }
    XCTAssertEqual(header.state, CYLRefreshStateRefreshing);
    XCTAssertEqualWithAccuracy(table.contentInset.top, header.cyl_h, 0.5);

    // [EN] "Rotate": the system inset shrinks from 100 to 30 + the safe area. [CN] “旋转”：系统 inset 从 100 缩小到 30 + 安全区。
    controller.additionalSafeAreaInsets = UIEdgeInsetsMake(30, 0, 0, 0);
    [controller.view layoutIfNeeded];
    CGFloat newSystemTop = table.adjustedContentInset.top - table.contentInset.top;
    XCTAssertEqualWithAccuracy(systemTop - newSystemTop, 70, 0.5);
    // [EN] The user scrolls 20 pt up into the header, then back to the refreshing position.
    // [CN] 用户向上滚入刷新头 20 点，然后回到刷新位置。
    table.contentOffset = CGPointMake(0, -(newSystemTop + header.cyl_h) + 20);
    XCTAssertLessThanOrEqual(table.contentInset.top, header.cyl_h + 0.5, @"never more than the header's own height");
    table.contentOffset = CGPointMake(0, -(newSystemTop + header.cyl_h));
    XCTAssertEqualWithAccuracy(table.contentInset.top, header.cyl_h, 0.5);

    [header endRefreshing];
    deadline = [NSDate dateWithTimeIntervalSinceNow:CYLTestTimeout];
    while (header.state != CYLRefreshStateIdle && deadline.timeIntervalSinceNow > 0) {
        [NSRunLoop.mainRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    }
    XCTAssertEqualWithAccuracy(table.contentInset.top, 0, 0.5, @"the header gives back exactly what it added");
    window.hidden = YES;
}

// FIX: issue MJRefresh#1483
// [EN] While the header refreshes, the user drags on to the end and the back footer starts loading too; the header ends
//      first, then the footer. Both insets come back to what they were (with and without isCollectionViewAnimationBug),
//      so repeated refreshes do not move the content.
// [CN] 刷新头刷新期间，用户继续拖到底部，返回式刷新尾也开始加载；刷新头先结束，刷新尾后结束。两个 inset 都恢复原值（开启与关闭
//      isCollectionViewAnimationBug 都如此），反复刷新不会移动内容。
- (void)testHeaderEndingWhileTheFooterLoadsRestoresBothInsets {
    for (NSNumber *animationBug in @[@NO, @YES]) {
        UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        window.rootViewController = [UIViewController new];
        [window makeKeyAndVisible];
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.itemSize = CGSizeMake(80, 80);
        UICollectionView *collection = [[UICollectionView alloc] initWithFrame:window.bounds collectionViewLayout:layout];
        collection.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        [collection registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:@"cell"];
        CYLTestCollectionSource *source = [CYLTestCollectionSource new];
        collection.dataSource = source;
        [window.rootViewController.view addSubview:collection];
        CYLRefreshHeader *header = [CYLRefreshNormalHeader headerWithRefreshingBlock:^{}];
        header.isCollectionViewAnimationBug = animationBug.boolValue;
        CYLRefreshBackFooter *footer = [CYLRefreshBackNormalFooter footerWithRefreshingBlock:^{}];
        for (CYLRefreshComponent *component in @[header, footer]) {
            component.fastAnimationDuration = 0.05;
            component.slowAnimationDuration = 0.05;
        }
        collection.cyl_header = header;
        collection.cyl_footer = footer;
        [collection layoutIfNeeded];
        UIEdgeInsets initial = collection.contentInset;
        for (NSUInteger round = 0; round < 3; round++) {
            [header beginRefreshing];
            [self cyl_spinUntil:^BOOL { return header.state == CYLRefreshStateRefreshing && collection.userInteractionEnabled; }];
            footer.exclusiveWithOtherRefresh = NO;
            [footer beginRefreshing];
            [self cyl_spinUntil:^BOOL { return footer.state == CYLRefreshStateRefreshing; }];
            [header endRefreshing];
            [self cyl_spinUntil:^BOOL { return header.state == CYLRefreshStateIdle && collection.userInteractionEnabled; }];
            [NSRunLoop.mainRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
            [footer endRefreshing];
            [self cyl_spinUntil:^BOOL { return footer.state == CYLRefreshStateIdle; }];
            [NSRunLoop.mainRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
            XCTAssertEqualWithAccuracy(collection.contentInset.top, initial.top, 0.5, @"bug path %@, round %lu", animationBug, (unsigned long)round);
            XCTAssertEqualWithAccuracy(collection.contentInset.bottom, initial.bottom, 0.5, @"bug path %@, round %lu", animationBug, (unsigned long)round);
        }
        window.hidden = YES;
    }
}

// [EN] The pull is released past the refreshing position, so the header's inset follows the content (resetInset)
//      before the start animation ends; three refreshes in a row give back exactly the inset they added (with and
//      without isCollectionViewAnimationBug), so the content does not move (MJRefresh #1483, PR #1444).
// [CN] 松手位置超过刷新位置，刷新头的 inset 在开始动画结束前就随内容变化（resetInset）；连续三次刷新恰好归还所增加的 inset（开启与关闭
//      isCollectionViewAnimationBug 都如此），内容不会移动（MJRefresh #1483、PR #1444）。
- (void)testRefreshReleasedPastTheRefreshingPositionGivesBackItsInset {
    for (NSNumber *animationBug in @[@NO, @YES]) {
        UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        window.rootViewController = [UIViewController new];
        [window makeKeyAndVisible];
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        UICollectionView *collection = [[UICollectionView alloc] initWithFrame:window.bounds collectionViewLayout:layout];
        collection.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        collection.contentInset = UIEdgeInsetsMake(30, 0, 0, 0);
        [collection registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:@"cell"];
        CYLTestCollectionSource *source = [CYLTestCollectionSource new];
        collection.dataSource = source;
        [window.rootViewController.view addSubview:collection];
        CYLRefreshHeader *header = [CYLRefreshNormalHeader headerWithRefreshingBlock:^{}];
        header.isCollectionViewAnimationBug = animationBug.boolValue;
        header.fastAnimationDuration = 0.1;
        header.slowAnimationDuration = 0.1;
        collection.cyl_header = header;
        [collection layoutIfNeeded];
        for (NSUInteger round = 0; round < 3; round++) {
            collection.contentOffset = CGPointMake(0, -30 - 90);
            [header beginRefreshing];
            collection.contentOffset = CGPointMake(0, -30 - 80);
            [self cyl_spinUntil:^BOOL { return header.state == CYLRefreshStateRefreshing && collection.userInteractionEnabled; }];
            [NSRunLoop.mainRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
            XCTAssertEqualWithAccuracy(collection.contentInset.top, 30 + header.cyl_h, 0.5, @"bug path %@, round %lu", animationBug, (unsigned long)round);
            [header endRefreshing];
            [self cyl_spinUntil:^BOOL { return header.state == CYLRefreshStateIdle && collection.userInteractionEnabled; }];
            [NSRunLoop.mainRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
            XCTAssertEqualWithAccuracy(collection.contentInset.top, 30, 0.5, @"bug path %@, round %lu", animationBug, (unsigned long)round);
        }
        window.hidden = YES;
    }
}

- (void)cyl_spinUntil:(BOOL (^)(void))condition {
    NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:CYLTestTimeout];
    while (!condition() && deadline.timeIntervalSinceNow > 0) {
        [NSRunLoop.mainRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
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
    [self waitForExpectations:@[started] timeout:CYLTestTimeout];
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
    [self waitForExpectations:@[started] timeout:CYLTestTimeout];
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
    [self waitForExpectations:@[started] timeout:CYLTestTimeout];
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
    [self waitForExpectations:@[started] timeout:CYLTestTimeout];
    XCTestExpectation *ended = [self expectationWithDescription:@"trailer ended"];
    [trailer endRefreshingWithCompletionBlock:^{ [ended fulfill]; }];
    [self waitForExpectations:@[ended] timeout:CYLTestTimeout];
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
    [self waitForExpectations:@[refreshed] timeout:CYLTestTimeout];
    XCTAssertEqual(trailer.state, CYLRefreshStateRefreshing);
    XCTAssertEqual(callbacks, 1u);
    XCTestExpectation *ended = [self expectationWithDescription:@"automatic trailer ended"];
    [trailer endRefreshingWithCompletionBlock:^{ [ended fulfill]; }];
    [self waitForExpectations:@[ended] timeout:CYLTestTimeout];
    XCTAssertEqualWithAccuracy(scrollView.cyl_insetR, 0, 0.001);
    XCTAssertEqual(callbacks, 1u);
    scrollView.cyl_trailer = nil;
    window.hidden = YES;
}

// FIX: issue MJRefresh#1623
// [EN] autoTriggerTimes: one drag triggers the automatic trailer once (default 1); moving back and forth in the same
//      drag does not load again, and the next drag (pan began) may trigger once more.
// [CN] autoTriggerTimes：一次拖动只自动触发一次 trailer（默认 1）；同一次拖动中来回移动不会再次加载，下一次拖动（手势开始）可以再触发一次。
- (void)testAutomaticTrailerTriggersOncePerDrag {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    window.rootViewController = [UIViewController new];
    CYLTestDraggingScrollView *scrollView = [[CYLTestDraggingScrollView alloc] initWithFrame:window.bounds];
    scrollView.cyl_testPan = [CYLTestPanGestureRecognizer new];
    scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    scrollView.contentSize = CGSizeMake(1000, window.bounds.size.height);
    [window.rootViewController.view addSubview:scrollView];
    [window makeKeyAndVisible];
    __block NSUInteger callbacks = 0;
    __block XCTestExpectation *refreshed = nil;
    CYLRefreshTrailer *trailer = [CYLRefreshNormalTrailer trailerWithRefreshingBlock:^{
        callbacks++;
        [refreshed fulfill];
    }];
    trailer.fastAnimationDuration = 0;
    trailer.slowAnimationDuration = 0;
    trailer.automaticallyRefresh = YES;
    trailer.triggerAutomaticallyRefreshPercent = 0.5;
    scrollView.cyl_trailer = trailer;
    [trailer layoutIfNeeded];

    for (NSUInteger drag = 1; drag <= 2; drag++) {
        // [EN] A new drag begins. [CN] 新的一次拖动开始。
        scrollView.cyl_testPan.cyl_testState = UIGestureRecognizerStateBegan;
        [trailer scrollViewPanStateDidChange:nil];
        scrollView.cyl_testDragging = YES;
        scrollView.contentOffset = CGPointMake(690, 0);
        refreshed = [self expectationWithDescription:@"automatic trailer refresh"];
        scrollView.contentOffset = CGPointMake(711, 0);
        XCTAssertEqual(trailer.state, CYLRefreshStateRefreshing);
        [self waitForExpectations:@[refreshed] timeout:CYLTestTimeout];
        refreshed = nil;
        XCTestExpectation *ended = [self expectationWithDescription:@"automatic trailer ended"];
        [trailer endRefreshingWithCompletionBlock:^{ [ended fulfill]; }];
        [self waitForExpectations:@[ended] timeout:CYLTestTimeout];
        XCTAssertEqual(callbacks, drag);

        // [EN] Back and forth in the same drag: no second load. [CN] 同一次拖动中来回移动：不再加载。
        scrollView.contentOffset = CGPointMake(690, 0);
        scrollView.contentOffset = CGPointMake(711, 0);
        XCTAssertNotEqual(trailer.state, CYLRefreshStateRefreshing);
        XCTAssertEqual(callbacks, drag);

        // [EN] The drag ends back inside the content. [CN] 拖动在内容范围内结束。
        scrollView.contentOffset = CGPointMake(600, 0);
        scrollView.cyl_testDragging = NO;
        scrollView.cyl_testPan.cyl_testState = UIGestureRecognizerStateEnded;
        [trailer scrollViewPanStateDidChange:nil];
    }
    scrollView.cyl_trailer = nil;
    window.hidden = YES;
}

// CoderMJLee/MJRefresh#1587: pull-down refresh and pull-up load exclude each other when asked to.
- (void)testHeaderAndFooterExcludeEachOtherWhenEnabled {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    window.rootViewController = [UIViewController new];
    [window.rootViewController.view addSubview:self.table];
    [window makeKeyAndVisible];
    __block NSUInteger headerCalls = 0, footerCalls = 0, blocked = 0;
    CYLRefreshHeader *header = [CYLRefreshNormalHeader headerWithRefreshingBlock:^{ headerCalls++; }];
    CYLRefreshFooter *footer = [CYLRefreshBackNormalFooter footerWithRefreshingBlock:^{ footerCalls++; }];
    for (CYLRefreshComponent *component in @[header, footer]) {
        component.fastAnimationDuration = 0;
        component.slowAnimationDuration = 0;
        component.exclusiveWithOtherRefresh = YES;
        component.blockedByOtherRefreshBlock = ^{ blocked++; };
    }
    self.table.cyl_header = header;
    self.table.cyl_footer = footer;

    // The header refreshes: loading more is held back and reported.
    XCTestExpectation *headerStarted = [self expectationWithDescription:@"header started"];
    header.refreshingBlock = ^{ headerCalls++; [headerStarted fulfill]; };
    [header beginRefreshing];
    [self waitForExpectations:@[headerStarted] timeout:CYLTestTimeout];
    footer.state = CYLRefreshStatePulling;
    [footer beginRefreshing];
    XCTAssertEqual(footer.state, CYLRefreshStateIdle, @"the held-back pull is dropped, not left on 'release to load'");
    XCTAssertEqual(footerCalls, 0u);
    XCTAssertEqual(blocked, 1u);
    XCTAssertTrue(header.isRefreshing);

    // After the header ends, loading more works; now the header is held back.
    XCTestExpectation *headerEnded = [self expectationWithDescription:@"header ended"];
    [header endRefreshingWithCompletionBlock:^{ [headerEnded fulfill]; }];
    [self waitForExpectations:@[headerEnded] timeout:CYLTestTimeout];
    XCTestExpectation *footerStarted = [self expectationWithDescription:@"footer started"];
    footer.refreshingBlock = ^{ footerCalls++; [footerStarted fulfill]; };
    [footer beginRefreshing];
    [self waitForExpectations:@[footerStarted] timeout:CYLTestTimeout];
    XCTAssertEqual(footerCalls, 1u);
    NSUInteger headerCallsBefore = headerCalls;
    [header beginRefreshing];
    XCTAssertFalse(header.isRefreshing);
    XCTAssertEqual(headerCalls, headerCallsBefore);
    XCTAssertEqual(blocked, 2u);

    XCTestExpectation *footerEnded = [self expectationWithDescription:@"footer ended"];
    [footer endRefreshingWithCompletionBlock:^{ [footerEnded fulfill]; }];
    [self waitForExpectations:@[footerEnded] timeout:CYLTestTimeout];
    self.table.cyl_header = nil;
    self.table.cyl_footer = nil;
    window.hidden = YES;
}

- (void)testHeaderAndFooterRunIndependentlyByDefault {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    window.rootViewController = [UIViewController new];
    [window.rootViewController.view addSubview:self.table];
    [window makeKeyAndVisible];
    XCTAssertFalse(CYLRefreshNormalHeader.new.isExclusiveWithOtherRefresh);
    __block NSUInteger footerCalls = 0;
    CYLRefreshHeader *header = [CYLRefreshNormalHeader headerWithRefreshingBlock:^{}];
    CYLRefreshFooter *footer = [CYLRefreshBackNormalFooter footerWithRefreshingBlock:^{ footerCalls++; }];
    header.fastAnimationDuration = footer.fastAnimationDuration = 0;
    self.table.cyl_header = header;
    self.table.cyl_footer = footer;
    [header beginRefreshing];
    [footer beginRefreshing];
    XCTAssertTrue(header.isRefreshing);
    XCTAssertTrue(footer.isRefreshing, @"unchanged default: the footer starts while the header refreshes");
    self.table.cyl_header = nil;
    self.table.cyl_footer = nil;
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
    [self waitForExpectations:@[nextTurn] timeout:CYLTestTimeout];
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
    XCTestExpectation *newRefresh = [self expectationWithDescription:@"new start animation finished"];
    CYLRefreshTrailer *trailer = [CYLRefreshNormalTrailer trailerWithRefreshingBlock:^{
        if (++callbacks == 1) [newRefresh fulfill];
    }];
    trailer.fastAnimationDuration = 0.5;
    trailer.slowAnimationDuration = 0.2;
    [oldView addSubview:trailer];
    [trailer layoutIfNeeded];
    [trailer beginRefreshing];
    XCTAssertEqual(trailer.state, CYLRefreshStateRefreshing);
    [newView addSubview:trailer];
    [trailer layoutIfNeeded];
    [trailer beginRefreshing];
    // Wait for the new refresh's callback itself rather than a fixed delay, which slow CI runners miss.
    [self waitForExpectations:@[newRefresh] timeout:CYLTestTimeout];
    // The old animation finishes no later than the new one; give a stale callback time to show up.
    XCTestExpectation *settled = [self expectationWithDescription:@"no stale callback"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [settled fulfill];
    });
    [self waitForExpectations:@[settled] timeout:CYLTestTimeout];
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
    [self waitForExpectations:@[ended, startAnimationFinished] timeout:CYLTestTimeout];
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
    [self waitForExpectations:@[started] timeout:CYLTestTimeout];
    XCTestExpectation *ended = [self expectationWithDescription:@"first refresh ended"];
    [trailer endRefreshingWithCompletionBlock:^{ [ended fulfill]; }];
    trailer.beginRefreshingCompletionBlock = nil;
    [trailer beginRefreshing];
    [self waitForExpectations:@[ended] timeout:CYLTestTimeout];
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
    XCTestExpectation *firstEnded = [self expectationWithDescription:@"first end completion"];
    XCTestExpectation *secondEnded = [self expectationWithDescription:@"second end completion"];
    [trailer beginRefreshing];
    [trailer endRefreshingWithCompletionBlock:^{ if (++firstEnds == 1) [firstEnded fulfill]; }];
    [trailer beginRefreshing];
    [trailer endRefreshingWithCompletionBlock:^{ if (++secondEnds == 1) [secondEnded fulfill]; }];
    // Wait for both completions themselves, then allow time for a duplicate call to show up.
    [self waitForExpectations:@[firstEnded, secondEnded] timeout:CYLTestTimeout];
    XCTestExpectation *settled = [self expectationWithDescription:@"no duplicate completion"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [settled fulfill];
    });
    [self waitForExpectations:@[settled] timeout:CYLTestTimeout];
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

// FIX: issue MJRefresh#1610 (page alignment)
// [EN] A paging auto footer starts loading with its space showing past the last page; the load adds a page. When it
//      ends at rest, the scroll view goes back to the page boundary instead of keeping the page shifted by the
//      footer's height (an Example-objc-02 UI test drives the same case with real swipes).
// [CN] 分页的自动刷新尾在最后一页之后露出自身空间时开始加载，加载新增一页。静止时结束，滚动视图回到分页边界，而不是让该页错开刷新尾的高度
//      （Example-objc-02 的 UI 测试以真实滑动覆盖同一场景）。
- (void)testPagingAutoFooterEndAfterNewPageReturnsToThePageBoundary {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    window.rootViewController = [UIViewController new];
    CYLTestPagingScrollView *scrollView = [[CYLTestPagingScrollView alloc] initWithFrame:window.bounds];
    scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    scrollView.contentSize = CGSizeMake(320, 960);
    scrollView.pagingEnabled = YES;
    [window.rootViewController.view addSubview:scrollView];
    [window makeKeyAndVisible];
    CYLRefreshAutoFooter *footer = [CYLRefreshAutoNormalFooter footerWithRefreshingBlock:^{}];
    footer.fastAnimationDuration = 0;
    footer.slowAnimationDuration = 0;
    scrollView.cyl_footer = footer;
    [footer beginRefreshing];
    scrollView.contentOffset = CGPointMake(0, 480 + footer.cyl_h);
    scrollView.contentSize = CGSizeMake(320, 1440);
    [footer endRefreshing];
    XCTAssertEqualWithAccuracy(scrollView.contentOffset.y, 480, 0.001);
    scrollView.cyl_footer = nil;
    window.hidden = YES;
}

// CoderMJLee/MJRefresh#1585 (case 2): keep "no more data" visible for a while after the last load, then rebound.
- (UIScrollView *)cyl_scrollViewAtBottomWithBackFooter:(CYLRefreshBackFooter **)footerOut inWindow:(UIWindow *)window {
    window.rootViewController = [UIViewController new];
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:window.bounds];
    scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    scrollView.contentSize = CGSizeMake(320, 1440);
    [window.rootViewController.view addSubview:scrollView];
    [window makeKeyAndVisible];
    CYLRefreshBackFooter *footer = [CYLRefreshBackNormalFooter footerWithRefreshingBlock:^{}];
    footer.fastAnimationDuration = 0;
    footer.slowAnimationDuration = 0;
    scrollView.cyl_footer = footer;
    scrollView.contentOffset = CGPointMake(0, 960);
    XCTestExpectation *started = [self expectationWithDescription:@"back footer started"];
    [footer beginRefreshingWithCompletionBlock:^{ [started fulfill]; }];
    [self waitForExpectations:@[started] timeout:CYLTestTimeout];
    // The block stays attached and would fulfill the finished expectation again on every later start.
    footer.beginRefreshingCompletionBlock = nil;
    *footerOut = footer;
    return scrollView;
}

- (void)testBackFooterHoldsNoMoreDataForTheConfiguredDuration {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    CYLRefreshBackFooter *footer = nil;
    UIScrollView *scrollView = [self cyl_scrollViewAtBottomWithBackFooter:&footer inWindow:window];
    footer.noMoreDataDisplayDuration = 0.6;
    CGFloat refreshingInset = scrollView.cyl_insetB;
    XCTAssertGreaterThan(refreshingInset, 0);
    CFTimeInterval began = CACurrentMediaTime();
    [footer endRefreshingWithNoMoreData];
    XCTAssertEqual(footer.state, CYLRefreshStateNoMoreData);
    XCTAssertEqualWithAccuracy(scrollView.cyl_insetB, refreshingInset, 0.01, @"the footer stays held open");
    [self expectationForPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        return fabs(scrollView.cyl_insetB) < 0.01;
    }] evaluatedWithObject:scrollView handler:nil];
    [self waitForExpectationsWithTimeout:CYLTestTimeout handler:nil];
    XCTAssertGreaterThanOrEqual(CACurrentMediaTime() - began, 0.5, @"released only after the configured time");
    XCTAssertEqual(footer.state, CYLRefreshStateNoMoreData, @"the state itself is unchanged");
    scrollView.cyl_footer = nil;
    window.hidden = YES;
}

- (void)testBackFooterNoMoreDataReboundsAtOnceByDefault {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    CYLRefreshBackFooter *footer = nil;
    UIScrollView *scrollView = [self cyl_scrollViewAtBottomWithBackFooter:&footer inWindow:window];
    XCTAssertEqualWithAccuracy(footer.noMoreDataDisplayDuration, 0, 0.0001);
    [footer endRefreshingWithNoMoreData];
    XCTAssertEqualWithAccuracy(scrollView.cyl_insetB, 0, 0.01, @"unchanged default");
    scrollView.cyl_footer = nil;
    window.hidden = YES;
}

- (void)testBackFooterNoMoreDataHoldEndsOnResetNewLoadAndRemoval {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    CYLRefreshBackFooter *footer = nil;
    UIScrollView *scrollView = [self cyl_scrollViewAtBottomWithBackFooter:&footer inWindow:window];
    footer.noMoreDataDisplayDuration = 60;
    [footer endRefreshingWithNoMoreData];
    XCTAssertGreaterThan(scrollView.cyl_insetB, 0);
    [footer resetNoMoreData];
    XCTAssertEqual(footer.state, CYLRefreshStateIdle);
    XCTAssertEqualWithAccuracy(scrollView.cyl_insetB, 0, 0.01, @"reset gives the held inset back");

    // A new load after the hold: the inset is neither lost nor doubled.
    [footer beginRefreshing];
    CGFloat refreshingInset = scrollView.cyl_insetB;
    [footer endRefreshingWithNoMoreData];
    XCTAssertEqualWithAccuracy(scrollView.cyl_insetB, refreshingInset, 0.01);
    [footer beginRefreshing];
    XCTAssertEqual(footer.state, CYLRefreshStateRefreshing);
    XCTAssertEqualWithAccuracy(scrollView.cyl_insetB, refreshingInset, 0.01, @"one footer height, not two");
    [footer endRefreshing];
    XCTAssertEqualWithAccuracy(scrollView.cyl_insetB, 0, 0.01);

    [footer beginRefreshing];
    [footer endRefreshingWithNoMoreData];
    XCTAssertGreaterThan(scrollView.cyl_insetB, 0);
    scrollView.cyl_footer = nil;
    XCTAssertEqualWithAccuracy(scrollView.cyl_insetB, 0, 0.01, @"removing the footer gives the held inset back");
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
    [self waitForExpectations:@[started] timeout:CYLTestTimeout];
    XCTAssertGreaterThan(scrollView.contentOffset.y, 960);
    XCTestExpectation *ended = [self expectationWithDescription:@"paging back footer ended"];
    [footer endRefreshingWithCompletionBlock:^{ [ended fulfill]; }];
    [self waitForExpectations:@[ended] timeout:CYLTestTimeout];
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
    [self waitForExpectations:@[started] timeout:CYLTestTimeout];
    scrollView.contentSize = CGSizeMake(320, 1920);
    XCTestExpectation *ended = [self expectationWithDescription:@"paging back footer ended"];
    [footer endRefreshingWithCompletionBlock:^{ [ended fulfill]; }];
    [self waitForExpectations:@[ended] timeout:CYLTestTimeout];
    XCTAssertEqualWithAccuracy(scrollView.contentOffset.y, 960, 0.01);
    scrollView.cyl_footer = nil;
    window.hidden = YES;
}

- (void)testPagingBackFooterReturnsToItsPageWhenLeftBetweenPages {
    // MJRefresh #1430: UIKit's paging deceleration left the table about 0.22 of a page off the page boundary after the
    // footer's refresh, so the restore (which needed the refresh's exact offset) was skipped.
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
    [self waitForExpectations:@[started] timeout:CYLTestTimeout];
    scrollView.contentSize = CGSizeMake(320, 1920);
    scrollView.contentOffset = CGPointMake(0, 960 - 0.22 * 480);
    XCTestExpectation *ended = [self expectationWithDescription:@"paging back footer ended"];
    [footer endRefreshingWithCompletionBlock:^{ [ended fulfill]; }];
    [self waitForExpectations:@[ended] timeout:CYLTestTimeout];
    XCTAssertEqualWithAccuracy(scrollView.contentOffset.y, 960, 0.01, @"back on the page shown before the refresh");
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
        [self waitForExpectations:@[started] timeout:CYLTestTimeout];
        scrollView.contentSize = CGSizeMake(320, 1920);
        if (scenario == 0) scrollView.contentOffset = CGPointMake(0, 1440);
        if (scenario == 1) scrollView.cyl_testDragging = YES;
        if (scenario == 2) scrollView.cyl_testDecelerating = YES;
        CGFloat expectedOffset = scrollView.contentOffset.y;
        XCTestExpectation *ended = [self expectationWithDescription:@"paging footer ended"];
        [footer endRefreshingWithCompletionBlock:^{ [ended fulfill]; }];
        [self waitForExpectations:@[ended] timeout:CYLTestTimeout];
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
    [self waitForExpectations:@[nextTurn] timeout:CYLTestTimeout];
    XCTAssertEqual(footer.state, CYLRefreshStateNoMoreData);
    self.table.cyl_footer = nil;
}
@end
