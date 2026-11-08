#import <XCTest/XCTest.h>
#import "../CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/UITableView+CYLPlaceholder.h"
#import "../CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/UICollectionView+CYLPlaceholder.h"
#import "../CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/UITableView+CYLTableViewPlaceHolder.h"
#import "../CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLTableViewPlaceHolderDelegate.h"
#import "../CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderView.h"

@interface CYLAutomaticTestSource : NSObject <UITableViewDataSource, UICollectionViewDataSource, CYLTableViewPlaceHolderDelegate>
@property (nonatomic) NSInteger count;
@property (nonatomic, strong) UIView *legacyView;
@end

@interface CYLMultipleAutomaticTestSource : CYLAutomaticTestSource
@property (nonatomic) NSInteger sections;
@end
@implementation CYLMultipleAutomaticTestSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return self.sections; }
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView { return self.sections; }
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == self.sections - 1 ? self.count : 0;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return section == self.sections - 1 ? self.count : 0;
}
@end

@implementation CYLAutomaticTestSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return self.count; }
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section { return self.count; }
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
}
- (UIView *)makePlaceHolderView { return self.legacyView; }
@end

@interface CYLAutomaticPlaceholderTests : XCTestCase
@end
@implementation CYLAutomaticPlaceholderTests
- (void)drainUpdates {
    XCTestExpectation *done = [self expectationWithDescription:@"placeholder update"];
    dispatch_async(dispatch_get_main_queue(), ^{ [done fulfill]; });
    [self waitForExpectations:@[done] timeout:5];
}

- (void)testTableReloadInsertDeleteAndCancellation {
    CYLAutomaticTestSource *source = [CYLAutomaticTestSource new];
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    table.dataSource = source;
    UIView *placeholder = [UIView new];
    __block NSInteger restores = 0;
    [table cyl_placeholderViewBlock:^UIView *(UITableView *view) {
        view.scrollEnabled = NO;
        return placeholder;
    } backToNormalBlock:^(UITableView *view) {
        restores++;
        view.scrollEnabled = YES;
    }];
    [table reloadData];
    [self drainUpdates];
    XCTAssertEqual(placeholder.superview, table);
    XCTAssertFalse(table.scrollEnabled);
    [table layoutIfNeeded];
    XCTAssertEqualWithAccuracy(CGRectGetWidth(placeholder.frame), 320, 0.1);
    table.frame = CGRectMake(0, 0, 480, 320);
    [table layoutIfNeeded];
    XCTAssertEqualWithAccuracy(CGRectGetWidth(placeholder.frame), 480, 0.1);
    source.count = 1;
    [table insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self drainUpdates];
    XCTAssertNil(placeholder.superview);
    XCTAssertEqual(restores, 1);
    XCTAssertTrue(table.scrollEnabled);
    source.count = 0;
    [table deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self drainUpdates];
    XCTAssertEqual(placeholder.superview, table);
    [table cyl_placeholderViewBlock:nil];
    XCTAssertNil(placeholder.superview);
    XCTAssertEqual(restores, 2);
    [table reloadData];
    [self drainUpdates];
    XCTAssertNil(placeholder.superview);
}

- (void)testCollectionBatchUpdatesAndCancellation {
    CYLAutomaticTestSource *source = [CYLAutomaticTestSource new];
    UICollectionView *collection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)
                                                      collectionViewLayout:[UICollectionViewFlowLayout new]];
    [collection registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:@"cell"];
    collection.dataSource = source;
    UIView *placeholder = [UIView new];
    __block NSInteger restores = 0;
    [collection cyl_placeholderViewBlock:^UIView *(UICollectionView *view) { return placeholder; }
                      backToNormalBlock:^(UICollectionView *view) { restores++; }];
    [collection reloadData];
    [self drainUpdates];
    XCTAssertEqual(placeholder.superview, collection);
    [collection performBatchUpdates:^{
        source.count = 1;
        [collection insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
    } completion:nil];
    [self drainUpdates];
    XCTAssertNil(placeholder.superview);
    XCTAssertEqual(restores, 1);
    [collection performBatchUpdates:^{
        source.count = 0;
        [collection deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
    } completion:nil];
    [self drainUpdates];
    XCTAssertEqual(placeholder.superview, collection);
    [collection cyl_placeholderViewBlock:nil];
    XCTAssertEqual(restores, 2);
}

- (void)testLegacyAndAutomaticPlaceholderDoNotOverlap {
    CYLAutomaticTestSource *source = [CYLAutomaticTestSource new];
    source.legacyView = [UIView new];
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    table.dataSource = source;
    [table cyl_reloadData];
    XCTAssertEqual(source.legacyView.superview, table);
    UIView *view = [UIView new];
    [table cyl_placeholderViewBlock:^UIView *(UITableView *tableView) { return view; }];
    [table cyl_reloadData];
    [self drainUpdates];
    XCTAssertNil(source.legacyView.superview);
    XCTAssertEqual(view.superview, table);
    [table cyl_placeholderViewBlock:nil];
    [table cyl_reloadData];
    XCTAssertEqual(source.legacyView.superview, table);
}

- (void)testCancelledPendingUpdateDoesNotCallBlock {
    CYLAutomaticTestSource *source = [CYLAutomaticTestSource new];
    UITableView *table = [UITableView new];
    table.dataSource = source;
    __block NSInteger calls = 0;
    [table cyl_placeholderViewBlock:^UIView *(UITableView *view) { calls++; return [UIView new]; }];
    [table cyl_placeholderViewBlock:nil];
    [self drainUpdates];
    XCTAssertEqual(calls, 0);
}

- (void)testRestoreCanReplaceConfigurationDuringCancellation {
    CYLAutomaticTestSource *source = [CYLAutomaticTestSource new];
    UITableView *table = [UITableView new];
    table.dataSource = source;
    UIView *first = [UIView new];
    UIView *replacement = [UIView new];
    [table cyl_placeholderViewBlock:^UIView *(UITableView *view) { return first; }
                 backToNormalBlock:^(UITableView *view) {
        [view cyl_placeholderViewBlock:^UIView *(UITableView *tableView) { return replacement; }];
    }];
    [self drainUpdates];
    XCTAssertEqual(first.superview, table);
    [table cyl_placeholderViewBlock:nil];
    [self drainUpdates];
    XCTAssertNil(first.superview);
    XCTAssertEqual(replacement.superview, table);
    [table cyl_placeholderViewBlock:nil];
}

- (void)testDefaultPlaceholderLoadsResources {
    CYLPlaceholderView *placeholder = [[CYLPlaceholderView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    XCTAssertNotNil(placeholder.imageView.image);
    XCTAssertTrue(placeholder.textLabel.text.length > 0);
}

- (void)testAdditionalPlaceholderImagesLoadFromResourceBundle {
    NSBundle *container = [NSBundle bundleForClass:CYLPlaceholderView.class];
    NSURL *url = [container URLForResource:@"CYLTableViewPlaceHolder" withExtension:@"bundle"];
    if (!url) url = [NSBundle.mainBundle URLForResource:@"CYLTableViewPlaceHolder" withExtension:@"bundle"];
    XCTAssertNotNil(url);
    NSBundle *bundle = [NSBundle bundleWithURL:url];
    for (NSString *name in @[@"CYLPlaceholderNoResults", @"CYLPlaceholderNoInternet",
                              @"CYLPlaceholderError", @"CYLPlaceholderWarning", @"CYLPlaceholderInbox"]) {
        XCTAssertNotNil([UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil], @"%@", name);
    }
    XCTAssertNotNil([bundle URLForResource:@"LICENSE" withExtension:@"material-design-icons"]);
    XCTAssertNotNil([bundle URLForResource:@"NOTICE" withExtension:@"material-design-icons"]);
}

- (void)testEveryPlaceholderStyleAndMessage {
    NSMutableSet<NSString *> *names = [NSMutableSet set];
    for (NSInteger i = 0; i < CYLPlaceholderStyleCount; i++) {
        NSString *name = [CYLPlaceholderView imageNameForStyle:(CYLPlaceholderStyle)i];
        XCTAssertNotNil(name, @"Missing style name %ld", (long)i);
        XCTAssertFalse([names containsObject:name], @"Duplicate style %@", name);
        [names addObject:name];
        XCTAssertNotNil([CYLPlaceholderView imageForStyle:(CYLPlaceholderStyle)i], @"Missing image %@", name);
    }
    for (NSInteger i = 0; i < CYLPlaceholderMessageCount; i++) {
        XCTAssertTrue([CYLPlaceholderView localizedTextForMessage:(CYLPlaceholderMessage)i].length > 0);
    }
    CYLPlaceholderView *view = [[CYLPlaceholderView alloc] initWithStyle:CYLPlaceholderStyleNoInternet
                                                                 message:CYLPlaceholderMessageServerUnavailable];
    XCTAssertNotNil(view.imageView.image);
    XCTAssertEqualObjects(view.textLabel.text, [CYLPlaceholderView localizedTextForMessage:CYLPlaceholderMessageServerUnavailable]);
    UIImage *custom = [UIImage new];
    view = [[CYLPlaceholderView alloc] initWithImage:custom text:@"Custom message"];
    XCTAssertEqual(view.imageView.image, custom);
    XCTAssertEqualObjects(view.textLabel.text, @"Custom message");
    view = [[CYLPlaceholderView alloc] initWithStyle:CYLPlaceholderStyleWarning text:nil];
    XCTAssertTrue(view.textLabel.hidden);
    XCTAssertNotNil(view.imageView.image);
    view = [[CYLPlaceholderView alloc] initWithImage:nil text:@"Text only"];
    XCTAssertTrue(view.imageView.hidden);
}

- (void)testPlaceholderLocalizationsHaveAllMessageKeys {
    NSBundle *container = [NSBundle bundleForClass:CYLPlaceholderView.class];
    NSURL *url = [container URLForResource:@"CYLTableViewPlaceHolder" withExtension:@"bundle"];
    if (!url) url = [NSBundle.mainBundle URLForResource:@"CYLTableViewPlaceHolder" withExtension:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithURL:url];
    NSArray<NSString *> *keys = @[@"CYLPlaceholderEmptyText", @"CYLPlaceholderNoResultsText",
        @"CYLPlaceholderNoInternetText", @"CYLPlaceholderServerUnavailableText", @"CYLPlaceholderErrorText",
        @"CYLPlaceholderLoadingText", @"CYLPlaceholderNoPermissionText", @"CYLPlaceholderEmptyCartText",
        @"CYLPlaceholderNoNotificationsText"];
    for (NSString *language in @[@"en", @"zh-Hans", @"zh-Hant", @"ja"]) {
        NSString *path = [bundle pathForResource:language ofType:@"lproj"];
        XCTAssertNotNil(path, @"Missing localization %@", language);
        if (!path) continue;
        NSBundle *languageBundle = [NSBundle bundleWithPath:path];
        for (NSString *key in keys) {
            NSString *text = [languageBundle localizedStringForKey:key value:nil table:nil];
            XCTAssertNotEqualObjects(text, key, @"Missing %@ in %@", key, language);
            XCTAssertTrue(text.length > 0);
        }
    }
}

- (void)testTableBatchAndSectionUpdatesAcrossMultipleSections {
    CYLMultipleAutomaticTestSource *source = [CYLMultipleAutomaticTestSource new];
    source.sections = 2;
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    table.dataSource = source;
    UIView *view = [UIView new];
    [table cyl_placeholderViewBlock:^UIView *(UITableView *tableView) { return view; }];
    [table reloadData];
    [self drainUpdates];
    XCTAssertEqual(view.superview, table);
    [table beginUpdates];
    source.count = 1;
    [table insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
    [table endUpdates];
    [self drainUpdates];
    XCTAssertNil(view.superview);
    XCTestExpectation *batchExecuted = [self expectationWithDescription:@"table batch executed"];
    [table performBatchUpdates:^{
        source.sections = 1;
        source.count = 0;
        [table deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        [batchExecuted fulfill];
    } completion:nil];
    [self waitForExpectations:@[batchExecuted] timeout:5];
    [self drainUpdates];
    XCTAssertEqual(view.superview, table);
    [table cyl_placeholderViewBlock:nil];
}

- (void)testCollectionSectionsAndFrameLayoutWithOffset {
    CYLMultipleAutomaticTestSource *source = [CYLMultipleAutomaticTestSource new];
    source.sections = 2;
    UICollectionView *collection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)
                                                      collectionViewLayout:[UICollectionViewFlowLayout new]];
    collection.dataSource = source;
    [collection registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:@"cell"];
    UIView *view = [UIView new];
    [collection cyl_placeholderViewBlock:^UIView *(UICollectionView *collectionView) { return view; }];
    [collection reloadData];
    [self drainUpdates];
    collection.contentInset = UIEdgeInsetsMake(40, 0, 0, 0);
    collection.contentOffset = CGPointMake(0, -20);
    [collection layoutIfNeeded];
    XCTAssertNotEqualWithAccuracy(collection.contentOffset.y, 0, 0.1);
    XCTAssertEqualWithAccuracy(view.frame.origin.y, collection.contentOffset.y, 0.1);
    source.count = 1;
    [collection reloadSections:[NSIndexSet indexSetWithIndex:1]];
    [self drainUpdates];
    XCTAssertNil(view.superview);
    source.count = 0;
    [collection reloadSections:[NSIndexSet indexSetWithIndex:1]];
    [self drainUpdates];
    XCTAssertEqual(view.superview, collection);
    [collection cyl_placeholderViewBlock:nil];
}
@end
