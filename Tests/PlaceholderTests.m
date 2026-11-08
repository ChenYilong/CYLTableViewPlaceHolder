#import <XCTest/XCTest.h>
#import "../CYLTableViewPlaceHolder/CYLTableViewPlaceHolderDelegate.h"
#import "../CYLTableViewPlaceHolder/UITableView+CYLTableViewPlaceHolder.h"
#if CYL_TEST_MJREFRESH
#import "MJRefresh.h"
#endif

@interface CYLTestSource : NSObject <UITableViewDataSource, CYLTableViewPlaceHolderDelegate>
@property (nonatomic) NSInteger rows;
@property (nonatomic) BOOL allowScroll;
@property (nonatomic, strong) UIView *view;
@end

#if CYL_TEST_MJREFRESH
@interface CYLRefreshSource : CYLTestSource
@end
@implementation CYLRefreshSource
- (CGRect)frameForPlaceHolderViewInTableView:(UITableView *)tableView {
    CGFloat top = CGRectGetMaxY(tableView.mj_footer.frame);
    return CGRectMake(0, top, CGRectGetWidth(tableView.bounds),
                      MAX(0, CGRectGetHeight(tableView.bounds) - top));
}
@end
#endif

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

#if CYL_TEST_MJREFRESH
- (void)testMJRefreshFooterCanRemainOutsidePlaceholder {
    CYLRefreshSource *source = [CYLRefreshSource new];
    source.view = [UIView new];
    self.table.dataSource = source;
    self.table.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{}];
    [self.table cyl_reloadData];
    [self.table layoutIfNeeded];
    XCTAssertGreaterThan(CGRectGetHeight(self.table.mj_footer.frame), 0);
    XCTAssertFalse(CGRectIntersectsRect(source.view.frame, self.table.mj_footer.frame));
    XCTAssertEqual(self.table.mj_footer.superview, self.table);
}
#endif
@end
