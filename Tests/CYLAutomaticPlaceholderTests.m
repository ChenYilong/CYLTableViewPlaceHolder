#import <XCTest/XCTest.h>
#import <ImageIO/ImageIO.h>
#import "../CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/UITableView+CYLPlaceholder.h"
#import "../CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/UICollectionView+CYLPlaceholder.h"
#import "../CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/UITableView+CYLTableViewPlaceHolder.h"
#import "../CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLTableViewPlaceHolderDelegate.h"
#import "../CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderView.h"
#import "../CYLTableViewPlaceHolder/CYLPlaceholderAnimation/CYLPlaceholderAnimationView.h"
#import "CYLRefresh.h"


/// Scopes appearance-proxy values to these tests.
@interface CYLAppearanceTestContainer : UIView
@end
@implementation CYLAppearanceTestContainer
@end

@interface CYLTestAnimationPlayer : UIView <CYLPlaceholderAnimationPlayer>
@property (nonatomic, getter=isReady) BOOL ready;
@property (nonatomic, copy) void (^errorHandler)(NSError *error);
@property (nonatomic, copy) void (^readyHandler)(void);
@property (nonatomic) NSInteger plays;
@property (nonatomic) NSInteger stops;
@property (nonatomic) NSInteger lastFrames;
@property (nonatomic, copy) NSDictionary<NSString *, UIColor *> *colors;
@end
@implementation CYLTestAnimationPlayer
- (void)play { self.plays++; }
- (void)stop { self.stops++; }
- (void)showLastFrame { self.lastFrames++; }
- (BOOL)setAnimationColors:(NSDictionary<NSString *,UIColor *> *)colors { self.colors = colors; return YES; }
@end

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
- (void)testConfiguredSelectedAppearanceRestoresLiveNormalValues {
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(20, 20)];
    UIImage *normal = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        [UIColor.blueColor setFill]; UIRectFill(CGRectMake(0, 0, 20, 20));
    }];
    UIImage *selected = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        [UIColor.redColor setFill]; UIRectFill(CGRectMake(0, 0, 20, 20));
    }];
    NSError *error = nil;
    CYLPlaceholderView *placeholder = [[CYLPlaceholderView alloc] initWithItemAttributes:@{
        CYLPlaceholderItemImage: normal,
        CYLPlaceholderItemTitle: @"Normal",
        CYLPlaceholderItemSelectedImage: selected,
        CYLPlaceholderItemSelectedTitle: @"Selected",
        CYLPlaceholderItemSelectedTitleColor: UIColor.redColor,
        CYLPlaceholderItemSelectedIconColor: UIColor.blueColor,
        CYLPlaceholderItemSelectedBackgroundColor: UIColor.yellowColor,
        CYLPlaceholderItemSelectedTitleFont: @22
    } imageBundle:nil error:&error];
    XCTAssertNotNil(placeholder);
    placeholder.textLabel.text = @"Changed";
    UIColor *originalColor = placeholder.textLabel.textColor;
    UIFont *originalFont = placeholder.textLabel.font;
    placeholder.selected = YES;
    XCTAssertEqual(placeholder.imageView.image, selected);
    XCTAssertEqualObjects(placeholder.textLabel.text, @"Selected");
    XCTAssertEqualObjects(placeholder.textLabel.textColor, UIColor.redColor);
    XCTAssertEqualObjects(placeholder.imageView.tintColor, UIColor.blueColor);
    XCTAssertEqualObjects(placeholder.backgroundColor, UIColor.yellowColor);
    XCTAssertEqualWithAccuracy(placeholder.textLabel.font.pointSize, 22, 0.01);
    XCTAssertTrue((placeholder.accessibilityTraits & UIAccessibilityTraitSelected) != 0);
    placeholder.selected = NO;
    XCTAssertEqual(placeholder.imageView.image, normal);
    XCTAssertEqualObjects(placeholder.textLabel.text, @"Changed");
    XCTAssertEqualObjects(placeholder.textLabel.textColor, originalColor);
    XCTAssertEqualObjects(placeholder.textLabel.font, originalFont);
    XCTAssertFalse((placeholder.accessibilityTraits & UIAccessibilityTraitSelected) != 0);
    XCTAssertNil([[CYLPlaceholderView alloc] initWithItemAttributes:@{
        CYLPlaceholderItemSelectedTitleColor: @"not-a-color"
    } imageBundle:nil error:&error]);
    XCTAssertNotNil(error);
}

- (void)testSelectedAppearancePreservesEmptyAndHiddenNormalContent {
    NSError *error = nil;
    CYLPlaceholderView *placeholder = [[CYLPlaceholderView alloc] initWithItemAttributes:@{
        CYLPlaceholderItemSelectedTitle: @"Selected"
    } imageBundle:nil error:&error];
    XCTAssertNotNil(placeholder);
    XCTAssertNil(error);
    placeholder.imageView.image = nil;
    placeholder.imageView.hidden = YES;
    placeholder.textLabel.text = nil;
    placeholder.textLabel.hidden = YES;
    placeholder.backgroundColor = nil;
    placeholder.accessibilityTraits |= UIAccessibilityTraitSelected | UIAccessibilityTraitButton;
    for (NSInteger i = 0; i < 2; i++) {
        placeholder.selected = YES;
        XCTAssertEqualObjects(placeholder.textLabel.text, @"Selected");
        XCTAssertFalse(placeholder.textLabel.hidden);
        placeholder.selected = YES;
        placeholder.selected = NO;
        XCTAssertNil(placeholder.imageView.image);
        XCTAssertTrue(placeholder.imageView.hidden);
        XCTAssertNil(placeholder.textLabel.text);
        XCTAssertTrue(placeholder.textLabel.hidden);
        XCTAssertNil(placeholder.backgroundColor);
        XCTAssertTrue((placeholder.accessibilityTraits & UIAccessibilityTraitSelected) != 0);
        XCTAssertTrue((placeholder.accessibilityTraits & UIAccessibilityTraitButton) != 0);
    }
}

- (void)testConfiguredImagesResolveForLightDarkAndSelection {
    if (@available(iOS 13.0, *)) {
        UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(12, 12)];
        UIImage *(^image)(UIColor *) = ^UIImage *(UIColor *color) {
            return [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
                [color setFill]; UIRectFill(CGRectMake(0, 0, 12, 12));
            }];
        };
        UIImage *light = image(UIColor.redColor), *dark = image(UIColor.blueColor);
        UIImage *selected = image(UIColor.greenColor), *selectedDark = image(UIColor.yellowColor);
        NSError *error = nil;
        CYLPlaceholderView *placeholder = [[CYLPlaceholderView alloc] initWithItemAttributes:@{
            CYLPlaceholderItemImage: light, CYLPlaceholderItemDarkImage: dark,
            CYLPlaceholderItemSelectedImage: selected, CYLPlaceholderItemSelectedDarkImage: selectedDark
        } imageBundle:nil error:&error];
        XCTAssertNotNil(placeholder);
        XCTAssertNil(error);
        UITraitCollection *lightTraits = [UITraitCollection traitCollectionWithTraitsFromCollections:@[
            [UITraitCollection traitCollectionWithDisplayScale:light.scale],
            [UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleLight]]];
        UITraitCollection *darkTraits = [UITraitCollection traitCollectionWithTraitsFromCollections:@[
            [UITraitCollection traitCollectionWithDisplayScale:dark.scale],
            [UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleDark]]];
        XCTAssertEqual([placeholder.imageView.image.imageAsset imageWithTraitCollection:lightTraits].CGImage, light.CGImage);
        XCTAssertEqual([placeholder.imageView.image.imageAsset imageWithTraitCollection:darkTraits].CGImage, dark.CGImage);
        placeholder.selected = YES;
        XCTAssertEqual([placeholder.imageView.image.imageAsset imageWithTraitCollection:lightTraits].CGImage, selected.CGImage);
        XCTAssertEqual([placeholder.imageView.image.imageAsset imageWithTraitCollection:darkTraits].CGImage, selectedDark.CGImage);
        placeholder.selected = NO;
        XCTAssertEqual([placeholder.imageView.image.imageAsset imageWithTraitCollection:darkTraits].CGImage, dark.CGImage);
        UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
        [window addSubview:placeholder];
        XCTAssertEqual(placeholder.imageView.traitCollection.userInterfaceStyle, UIUserInterfaceStyleLight);
        XCTAssertEqual([placeholder.imageView.image.imageAsset imageWithTraitCollection:placeholder.imageView.traitCollection].CGImage, light.CGImage);
        window.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
        [self expectationForPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
            return placeholder.imageView.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark;
        }] evaluatedWithObject:placeholder handler:nil];
        [self waitForExpectationsWithTimeout:3 handler:nil];
        XCTAssertEqual([placeholder.imageView.image.imageAsset imageWithTraitCollection:placeholder.imageView.traitCollection].CGImage, dark.CGImage);
        placeholder.selected = YES;
        XCTAssertEqual([placeholder.imageView.image.imageAsset imageWithTraitCollection:placeholder.imageView.traitCollection].CGImage, selectedDark.CGImage);
        [placeholder removeFromSuperview];
        error = nil;
        XCTAssertNil([[CYLPlaceholderView alloc] initWithItemAttributes:@{
            CYLPlaceholderItemDarkImage: @42
        } imageBundle:nil error:&error]);
        XCTAssertNotNil(error);
    }
}

- (void)testBadgeDotTextLayoutAndAccessibility {
    UIImage *image = [CYLPlaceholderView imageForStyle:CYLPlaceholderStyleEmpty];
    CYLPlaceholderView *placeholder = [[CYLPlaceholderView alloc] initWithImage:image text:@"Empty"];
    placeholder.frame = CGRectMake(0, 0, 320, 480);
    placeholder.accessibilityValue = @"Existing";
    placeholder.badgeCenterOffset = CGPointMake(3, 5);
    placeholder.badgeValue = @"";
    [placeholder layoutIfNeeded];
    [placeholder.imageView.superview layoutIfNeeded];
    XCTAssertFalse(placeholder.badgeLabel.hidden);
    XCTAssertEqualWithAccuracy(placeholder.badgeLabel.bounds.size.width, 8, 0.01);
    XCTAssertEqualWithAccuracy(placeholder.badgeLabel.center.x, CGRectGetMaxX(placeholder.imageView.frame) + 5, 0.01);
    XCTAssertEqualWithAccuracy(placeholder.badgeLabel.center.y, CGRectGetMinY(placeholder.imageView.frame) + 5, 0.01);
    XCTAssertGreaterThan(placeholder.accessibilityValue.length, 0);
    XCTAssertEqualObjects(placeholder.badgeLabel.accessibilityLabel, placeholder.accessibilityValue);
    XCTAssertTrue(placeholder.badgeLabel.isAccessibilityElement);
    placeholder.badgeValue = @"123";
    [placeholder.imageView.superview layoutIfNeeded];
    XCTAssertGreaterThan(placeholder.badgeLabel.bounds.size.width, 8);
    XCTAssertEqualObjects(placeholder.accessibilityValue, @"123");
    placeholder.badgeValue = nil;
    XCTAssertTrue(placeholder.badgeLabel.hidden);
    XCTAssertEqualObjects(placeholder.accessibilityValue, @"Existing");
    placeholder.badgeValue = @"New";
    placeholder.accessibilityValue = @"Custom";
    placeholder.badgeValue = @"Updated";
    placeholder.badgeValue = nil;
    XCTAssertEqualObjects(placeholder.accessibilityValue, @"Custom");
    placeholder.badgeCenterOffset = CGPointMake(NAN, 1);
    XCTAssertEqualWithAccuracy(placeholder.badgeCenterOffset.x, 3, 0.01);
    XCTAssertTrue([placeholder showBadgeWithStyle:CYLPlaceholderBadgeStyleDot value:nil]);
    XCTAssertEqualObjects(placeholder.badgeValue, @"");
    XCTAssertTrue([placeholder showBadgeWithStyle:CYLPlaceholderBadgeStyleNumber value:@"105"]);
    XCTAssertEqualObjects(placeholder.badgeValue, @"99+");
    XCTAssertFalse([placeholder showBadgeWithStyle:CYLPlaceholderBadgeStyleNumber value:@"3x"]);
    XCTAssertEqualObjects(placeholder.badgeValue, @"99+");
    XCTAssertTrue([placeholder showBadgeWithStyle:CYLPlaceholderBadgeStyleText value:@"New"]);
    XCTAssertEqualObjects(placeholder.badgeValue, @"New");
    XCTAssertTrue([placeholder showBadgeWithStyle:CYLPlaceholderBadgeStyleNumber value:@"0"]);
    XCTAssertNil(placeholder.badgeValue);
    XCTAssertFalse([placeholder showBadgeWithStyle:CYLPlaceholderBadgeStyleText value:@""]);
    XCTAssertTrue([placeholder showBadgeWithStyle:CYLPlaceholderBadgeStyleNone value:nil]);
}

- (void)testSelectionIndicatorFollowsStateAndItemBounds {
    UIImage *image = [CYLPlaceholderView imageForStyle:CYLPlaceholderStyleEmpty];
    CYLPlaceholderView *placeholder = [[CYLPlaceholderView alloc] initWithImage:image text:@"Empty"];
    placeholder.frame = CGRectMake(0, 0, 320, 480);
    placeholder.selectionIndicatorImage = image;
    placeholder.selectionIndicatorTintColor = UIColor.blueColor;
    UIView *item = placeholder.imageView.superview;
    XCTAssertEqual(item.subviews.count, 2);
    placeholder.selected = YES;
    [placeholder layoutIfNeeded];
    UIImageView *indicator = (UIImageView *)item.subviews.firstObject;
    XCTAssertNotEqual(indicator, placeholder.imageView);
    XCTAssertEqual(indicator.image.renderingMode, UIImageRenderingModeAlwaysTemplate);
    XCTAssertEqualObjects(indicator.tintColor, UIColor.blueColor);
    XCTAssertEqual(indicator.contentMode, UIViewContentModeCenter);
    XCTAssertTrue(CGRectEqualToRect(indicator.frame, item.bounds));
    placeholder.frame = CGRectMake(0, 0, 480, 320);
    [placeholder layoutIfNeeded];
    XCTAssertTrue(CGRectEqualToRect(indicator.frame, item.bounds));
    placeholder.selectionIndicatorImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    XCTAssertEqual(indicator.contentMode, UIViewContentModeScaleToFill);
    placeholder.selectionIndicatorImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    XCTAssertEqual(indicator.image.renderingMode, UIImageRenderingModeAlwaysOriginal);
    placeholder.selected = NO;
    XCTAssertNil(indicator.superview);
    XCTAssertEqual(item.subviews.count, 2);
}

- (void)testRegisteredAnimationFactoryLifecycleAndFailure {
    __block CYLTestAnimationPlayer *player;
    __block NSInteger calls = 0;
    XCTAssertTrue([CYLPlaceholderView registerAnimationFactory:^UIView<CYLPlaceholderAnimationPlayer> *(
        NSURL *url, CGSize size, UIViewContentMode mode, NSDictionary *options, NSError **error) {
        calls++;
        XCTAssertEqualObjects(url.pathExtension.lowercaseString, @"cyltest");
        XCTAssertEqualWithAccuracy(size.width, 40, 0.01);
        XCTAssertEqualObjects(options[@"setting"], @"value");
        player = [CYLTestAnimationPlayer new];
        return player;
    } forFileExtension:@"CYLTEST"]);
    XCTAssertFalse([CYLPlaceholderView registerAnimationFactory:nil forFileExtension:@"gif"]);
    XCTAssertFalse([CYLPlaceholderView registerAnimationFactory:nil forFileExtension:@".cyltest"]);
    UIImage *image = [CYLPlaceholderView imageForStyle:CYLPlaceholderStyleNoInternet];
    NSDictionary *attributes = @{
        CYLPlaceholderItemAnimationFilePath: @"/local/example.cyltest",
        CYLPlaceholderItemAnimationSize: @[@40, @30],
        CYLPlaceholderItemAnimationOptions: @{@"setting": @"value"},
        CYLPlaceholderItemImage: image
    };
    NSError *error = nil;
    CYLPlaceholderView *placeholder = [[CYLPlaceholderView alloc] initWithItemAttributes:attributes
        imageBundle:nil error:&error];
    XCTAssertNotNil(placeholder);
    XCTAssertEqual(calls, 1);
    XCTAssertFalse(placeholder.imageView.layer.hidden);
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [window addSubview:placeholder];
    if (!UIAccessibilityIsReduceMotionEnabled()) XCTAssertEqual(player.plays, 1);
    player.ready = YES;
    player.readyHandler();
    XCTAssertTrue(placeholder.imageView.layer.hidden);
    [placeholder showPlaceholderAnimationLastFrame];
    XCTAssertEqual(player.lastFrames, 1);
    [placeholder stopPlaceholderAnimation];
    XCTAssertGreaterThan(player.stops, 0);
    player.errorHandler([NSError errorWithDomain:@"CYLTest" code:1 userInfo:nil]);
    XCTAssertFalse(placeholder.imageView.layer.hidden);
    XCTAssertNil(player.superview);
    NSMutableDictionary *invalidSize = [attributes mutableCopy];
    invalidSize[CYLPlaceholderItemAnimationSize] = @[@0, @30];
    [[CYLPlaceholderView alloc] initWithItemAttributes:invalidSize imageBundle:nil error:&error];
    XCTAssertEqual(calls, 1);
    XCTAssertTrue([CYLPlaceholderView registerAnimationFactory:nil forFileExtension:@"cyltest"]);
}

- (void)testRegisteredAnimationReceivesResolvedAppearanceColors {
    if (@available(iOS 13.0, *)) {} else { return; } // Dark Mode needs iOS 13; iOS 12 runs the rest of the suite.
    __block CYLTestAnimationPlayer *player;
    XCTAssertTrue([CYLPlaceholderView registerAnimationFactory:^UIView<CYLPlaceholderAnimationPlayer> *(
        NSURL *url, CGSize size, UIViewContentMode mode, NSDictionary *options, NSError **error) {
        player = [CYLTestAnimationPlayer new];
        player.ready = YES;
        return player;
    } forFileExtension:@"cylcolors"]);
    NSDictionary *attributes = @{
        CYLPlaceholderItemAnimationFilePath: @"/local/example.cylcolors",
        CYLPlaceholderItemAnimationColors: @{@"Shape.Color": @"#ff0000", @"Other": UIColor.greenColor},
        CYLPlaceholderItemAnimationDarkColors: @{@"Shape.Color": @"#0000ff"}
    };
    NSError *error = nil;
    CYLPlaceholderView *placeholder = [[CYLPlaceholderView alloc] initWithItemAttributes:attributes imageBundle:nil error:&error];
    XCTAssertNotNil(placeholder);
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    [window addSubview:placeholder];
    XCTAssertEqualObjects(player.colors[@"Shape.Color"], UIColor.redColor);
    XCTAssertEqualObjects(player.colors[@"Other"], UIColor.greenColor);
    window.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
    [self expectationForPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        return [player.colors[@"Shape.Color"] isEqual:UIColor.blueColor];
    }] evaluatedWithObject:placeholder handler:nil];
    [self waitForExpectationsWithTimeout:3 handler:nil];
    XCTAssertEqualObjects(player.colors[@"Other"], UIColor.greenColor);
    error = nil;
    XCTAssertNil([[CYLPlaceholderView alloc] initWithItemAttributes:@{
        CYLPlaceholderItemAnimationColors: @{@"Shape.Color": @"invalid"}
    } imageBundle:nil error:&error]);
    XCTAssertNotNil(error);
    [placeholder removeFromSuperview];
    XCTAssertTrue([CYLPlaceholderView registerAnimationFactory:nil forFileExtension:@"cylcolors"]);
}

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

- (void)testConfiguredPlaceholderLayoutAndValidation {
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(80, 80)];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        [UIColor.redColor setFill];
        UIRectFill(CGRectMake(0, 0, 80, 80));
    }];
    NSDictionary *base = @{@"CYLTabBarItemImage": image, @"CYLTabBarItemTitle": @"Example",
                           @"CYLTabBarAnimationURL": @"future-animation.json"};
    NSError *error = nil;
    CYLPlaceholderView *plain = [[CYLPlaceholderView alloc] initWithItemAttributes:base imageBundle:nil error:&error];
    XCTAssertNotNil(plain);
    XCTAssertNil(error);
    XCTAssertEqualObjects(plain.itemAttributes[@"CYLTabBarAnimationURL"], @"future-animation.json");
    NSMutableDictionary *adjusted = base.mutableCopy;
    adjusted[@"CYLTabBarItemTitlePositionAdjustment"] = @[@4, @6];
    adjusted[@"CYLTabBarItemImagePositionAdjustment"] = @{@"x": @8, @"y": @10};
    adjusted[@"CYLTabBarItemImageInsets"] = @[@1, @2, @3, @4];
    CYLPlaceholderView *view = [[CYLPlaceholderView alloc] initWithItemAttributes:adjusted imageBundle:nil error:&error];
    plain.frame = view.frame = CGRectMake(0, 0, 320, 480);
    [plain layoutIfNeeded];
    [view layoutIfNeeded];
    XCTAssertEqualWithAccuracy(CGRectGetMinX(view.textLabel.frame) - CGRectGetMinX(plain.textLabel.frame), 4, 0.01);
    XCTAssertEqualWithAccuracy(CGRectGetMinY(view.textLabel.frame) - CGRectGetMinY(plain.textLabel.frame), 6, 0.01);
    XCTAssertEqualWithAccuracy(CGRectGetMinX(view.imageView.frame) - CGRectGetMinX(plain.imageView.frame), 8, 0.01);
    XCTAssertEqualWithAccuracy(CGRectGetMinY(view.imageView.frame) - CGRectGetMinY(plain.imageView.frame), 13, 0.01);
    XCTAssertEqualWithAccuracy(view.imageView.frame.size.width, 74, 0.01);
    XCTAssertEqualWithAccuracy(view.imageView.frame.size.height, 76, 0.01);
    adjusted[@"CYLTabBarItemImagePositionAdjustment"] = @[@"bad", @0];
    error = nil;
    XCTAssertNil([[CYLPlaceholderView alloc] initWithItemAttributes:adjusted imageBundle:nil error:&error]);
    XCTAssertNotNil(error);
    error = nil;
    XCTAssertNil([[CYLPlaceholderView alloc] initWithItemContentsOfURL:[NSURL URLWithString:@"https://example.com/item.plist"] imageBundle:nil error:&error]);
    XCTAssertNotNil(error);
}

- (void)testGIFAnimationUsesConfiguredSizeAndStopsOffscreen {
    NSMutableData *data = [NSMutableData data];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)data,
        CFSTR("com.compuserve.gif"), 2, NULL);
    XCTAssertNotEqual(destination, NULL);
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(20, 20)];
    for (UIColor *color in @[UIColor.redColor, UIColor.blueColor]) {
        UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
            [color setFill];
            UIRectFill(CGRectMake(0, 0, 20, 20));
        }];
        NSDictionary *properties = @{(__bridge NSString *)kCGImagePropertyGIFDictionary:
            @{(__bridge NSString *)kCGImagePropertyGIFDelayTime: @0.2}};
        CGImageDestinationAddImage(destination, image.CGImage, (__bridge CFDictionaryRef)properties);
    }
    XCTAssertTrue(CGImageDestinationFinalize(destination));
    CFRelease(destination);
    NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:
        [NSString stringWithFormat:@"CYLPlaceholder-%@.gif", NSUUID.UUID.UUIDString]]];
    NSError *error = nil;
    XCTAssertTrue([data writeToURL:url options:NSDataWritingAtomic error:&error]);
    CYLPlaceholderView *placeholder = [[CYLPlaceholderView alloc] initWithItemAttributes:@{
        CYLPlaceholderItemGIFURL: url, CYLPlaceholderItemGIFSize: @[@40, @30],
        CYLPlaceholderItemTitle: @"Offline"
    } imageBundle:nil error:&error];
    XCTAssertNotNil(placeholder);
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    placeholder.frame = window.bounds;
    [window addSubview:placeholder];
    [placeholder layoutIfNeeded];
    UIImageView *animationView = nil;
    for (UIView *child in placeholder.imageView.superview.subviews) {
        if ([child isKindOfClass:UIImageView.class] && child != placeholder.imageView) animationView = (UIImageView *)child;
    }
    XCTAssertNotNil(animationView);
    XCTAssertEqualWithAccuracy(CGRectGetWidth(animationView.frame), 40, 0.01);
    XCTAssertEqualWithAccuracy(CGRectGetHeight(animationView.frame), 30, 0.01);
    if (!UIAccessibilityIsReduceMotionEnabled()) {
        CAKeyframeAnimation *animation = (CAKeyframeAnimation *)[animationView.layer animationForKey:@"CYLPlaceholderGIF"];
        XCTAssertNotNil(animation);
        XCTAssertEqual(animation.values.count, 3);
        XCTAssertEqual(animation.keyTimes.count, animation.values.count);
        XCTAssertEqualWithAccuracy(animation.duration, 0.4, 0.02);
        placeholder.hidden = YES;
        XCTAssertNil([animationView.layer animationForKey:@"CYLPlaceholderGIF"]);
        placeholder.hidden = NO;
        XCTAssertNotNil([animationView.layer animationForKey:@"CYLPlaceholderGIF"]);
        [placeholder stopPlaceholderAnimation];
        XCTAssertNil([animationView.layer animationForKey:@"CYLPlaceholderGIF"]);
        UIImage *first = animationView.image;
        [placeholder showPlaceholderAnimationLastFrame];
        XCTAssertNil([animationView.layer animationForKey:@"CYLPlaceholderGIF"]);
        XCTAssertNotEqual(first, animationView.image);
        [placeholder removeFromSuperview];
        [window addSubview:placeholder];
        XCTAssertNil([animationView.layer animationForKey:@"CYLPlaceholderGIF"]);
        [placeholder playPlaceholderAnimation];
        XCTAssertNotNil([animationView.layer animationForKey:@"CYLPlaceholderGIF"]);
    }
    [placeholder removeFromSuperview];
    XCTAssertNil([animationView.layer animationForKey:@"CYLPlaceholderGIF"]);
    XCTAssertTrue([[NSFileManager defaultManager] removeItemAtURL:url error:&error]);
}

- (void)testUnavailableAnimationBackendPreservesStaticImage {
    UIImage *image = [CYLPlaceholderView imageForStyle:CYLPlaceholderStyleNoInternet];
    for (NSString *key in @[CYLPlaceholderItemLottieFilePath, CYLPlaceholderItemPAGFilePath,
                             CYLPlaceholderItemRiveFilePath, CYLPlaceholderItemAnimationFilePath]) {
        NSString *extension = [key isEqualToString:CYLPlaceholderItemPAGFilePath] ? @"pag" :
            ([key isEqualToString:CYLPlaceholderItemRiveFilePath] ? @"riv" : @"json");
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:
            [@"missing-placeholder-animation" stringByAppendingPathExtension:extension]];
        NSError *error = nil;
        CYLPlaceholderView *placeholder = [[CYLPlaceholderView alloc] initWithItemAttributes:@{
            key: path, CYLPlaceholderItemImage: image, CYLPlaceholderItemAnimationSize: @[@40, @30]
        } imageBundle:nil error:&error];
        XCTAssertNotNil(placeholder);
        XCTAssertNil(error);
        XCTAssertEqual(placeholder.imageView.image, image);
        XCTAssertFalse(placeholder.imageView.layer.hidden);
        XCTAssertEqual(placeholder.imageView.superview.subviews.count, 2);
    }
}

- (void)testAnimationAdapterRejectsInvalidInputs {
    NSError *error = nil;
    NSURL *url = [NSURL fileURLWithPath:@"/missing.json"];
    XCTAssertNil([[CYLPlaceholderAnimationView alloc] initWithFileURL:url size:CGSizeZero
        contentMode:UIViewContentModeScaleAspectFit error:&error]);
    XCTAssertEqual(error.code, CYLPlaceholderAnimationErrorInvalidSize);
    error = nil;
    XCTAssertNil([[CYLPlaceholderAnimationView alloc] initWithFileURL:url size:CGSizeMake(40, 40)
        contentMode:UIViewContentModeScaleAspectFit error:&error]);
    XCTAssertEqual(error.code, CYLPlaceholderAnimationErrorBackendUnavailable);
}

- (void)testGIFFailureKeepsStaticImage {
    UIImage *image = [CYLPlaceholderView imageForStyle:CYLPlaceholderStyleNoInternet];
    NSError *error = nil;
    CYLPlaceholderView *placeholder = [[CYLPlaceholderView alloc] initWithItemAttributes:@{
        CYLPlaceholderItemGIFURL: [NSURL URLWithString:@"https://example.com/image.gif"],
        CYLPlaceholderItemImage: image,
        CYLPlaceholderItemTitle: @"Offline"
    } imageBundle:nil error:&error];
    XCTAssertNotNil(placeholder);
    XCTAssertEqual(placeholder.imageView.image, image);
    XCTAssertFalse(placeholder.imageView.layer.hidden);
    XCTAssertEqual(placeholder.imageView.superview.subviews.count, 2);
}

- (void)testFlatDesignItemUsesSourceGeometryAndUpdates {
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(40, 30)];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        [UIColor.blueColor setFill];
        UIRectFill(CGRectMake(0, 0, 40, 30));
    }];
    CYLPlaceholderView *view = [[CYLPlaceholderView alloc] initWithImage:image text:@"Offline"];
    view.frame = CGRectMake(0, 0, 320, 480);
    [view layoutIfNeeded];
    UIView *item = view.imageView.superview;
    XCTAssertEqual(item, view.textLabel.superview);
    XCTAssertEqualWithAccuracy(CGRectGetWidth(view.imageView.frame), 40, 0.01);
    XCTAssertEqualWithAccuracy(CGRectGetHeight(view.imageView.frame), 30, 0.01);
    XCTAssertEqualWithAccuracy(CGRectGetMinY(view.imageView.frame),
        (CGRectGetMinY(view.textLabel.frame) - 30) / 2, 0.01);
    XCTAssertEqualWithAccuracy(CGRectGetMaxY(view.textLabel.frame), CGRectGetHeight(item.bounds) - 2, 0.01);
    XCTAssertEqualWithAccuracy(CGRectGetMidY(item.frame), CGRectGetMidY(view.bounds), 0.01);
    XCTAssertEqualWithAccuracy(CGRectGetMidX(view.imageView.frame), CGRectGetMidX(item.bounds), 0.01);

    view.textLabel.hidden = YES;
    [view layoutIfNeeded];
    XCTAssertEqualWithAccuracy(CGRectGetMidY(view.imageView.frame), CGRectGetMidY(item.bounds), 0.01);
    view.textLabel.hidden = NO;
    view.imageView.hidden = YES;
    [view layoutIfNeeded];
    XCTAssertEqualWithAccuracy(CGRectGetMidY(view.textLabel.frame), CGRectGetMidY(item.bounds), 0.01);
    view.imageView.hidden = NO;
    view.textLabel.text = @"A longer message that should wrap in a narrow placeholder";
    view.frame = CGRectMake(0, 0, 160, 300);
    [view layoutIfNeeded];
    XCTAssertLessThanOrEqual(CGRectGetWidth(view.textLabel.frame), 128);
    XCTAssertGreaterThan(CGRectGetHeight(view.textLabel.frame), view.textLabel.font.lineHeight);
    XCTAssertEqualWithAccuracy(CGRectGetMidY(item.frame), 150, 0.01);
    view.textLabel.text = @"Short";
    view.textLabel.font = [UIFont systemFontOfSize:24];
    UIGraphicsImageRenderer *secondRenderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(60, 50)];
    view.imageView.image = [secondRenderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        UIRectFill(CGRectMake(0, 0, 60, 50));
    }];
    [view layoutIfNeeded];
    XCTAssertEqualWithAccuracy(CGRectGetWidth(view.imageView.frame), 60, 0.01);
    XCTAssertEqualWithAccuracy(CGRectGetHeight(view.imageView.frame), 50, 0.01);
    XCTAssertGreaterThan(CGRectGetHeight(view.textLabel.frame), 20);
    XCTAssertEqualWithAccuracy(CGRectGetMidY(item.frame), 150, 0.01);
}

- (void)testConfiguredPlaceholderPropertyListAndPresets {
    NSBundle *container = [NSBundle bundleForClass:CYLPlaceholderView.class];
    NSURL *bundleURL = [container URLForResource:@"CYLTableViewPlaceHolder" withExtension:@"bundle"] ?:
        [NSBundle.mainBundle URLForResource:@"CYLTableViewPlaceHolder" withExtension:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithURL:bundleURL];
    NSURL *url = [bundle URLForResource:@"CYLPlaceholderItemDemo" withExtension:@"plist"];
    XCTAssertNotNil(url);
    NSError *error = nil;
    CYLPlaceholderView *view = [[CYLPlaceholderView alloc] initWithItemContentsOfURL:url imageBundle:nil error:&error];
    XCTAssertNotNil(view);
    XCTAssertNil(error);
    XCTAssertNotNil(view.imageView.image);
    XCTAssertEqualObjects(view.textLabel.text, [CYLPlaceholderView localizedTextForMessage:CYLPlaceholderMessageNoInternet]);
    XCTAssertEqualObjects(view.itemAttributes[CYLPlaceholderItemAnimationFilePath], @"reserved-animation.json");
    UIImage *custom = [UIImage new];
    view = [[CYLPlaceholderView alloc] initWithItemAttributes:@{
        CYLPlaceholderItemStyle: @(CYLPlaceholderStyleWarning),
        CYLPlaceholderItemMessage: @(CYLPlaceholderMessageError),
        CYLPlaceholderItemImage: custom,
        CYLPlaceholderItemTitle: @"Custom"
    } imageBundle:nil error:&error];
    XCTAssertEqual(view.imageView.image, custom);
    XCTAssertEqualObjects(view.textLabel.text, @"Custom");
    error = nil;
    XCTAssertNil([[CYLPlaceholderView alloc] initWithItemAttributes:@{CYLPlaceholderItemStyle: @(-1)} imageBundle:nil error:&error]);
    XCTAssertNotNil(error);
    error = nil;
    XCTAssertNil([[CYLPlaceholderView alloc] initWithItemAttributes:@{CYLPlaceholderItemMessage: NSNull.null} imageBundle:nil error:&error]);
    XCTAssertNotNil(error);
    error = nil;
    XCTAssertNil([[CYLPlaceholderView alloc] initWithItemAttributes:@{CYLPlaceholderItemImage: @"missing-image"} imageBundle:bundle error:&error]);
    XCTAssertNotNil(error);
}

- (void)testConfiguredPlaceholderAppearance {
    NSError *error = nil;
    CYLPlaceholderView *view = [[CYLPlaceholderView alloc] initWithItemAttributes:@{
        CYLPlaceholderItemStyle: @(CYLPlaceholderStyleWarning),
        CYLPlaceholderItemTitle: @"Example",
        CYLPlaceholderItemTitleColor: @"#123",
        CYLPlaceholderItemIconColor: UIColor.redColor,
        CYLPlaceholderItemBackgroundColor: @"#44556680",
        CYLPlaceholderItemTitleFont: @"bold:18",
        CYLPlaceholderItemAccessibilityLabel: @"Offline",
        CYLPlaceholderItemAccessibilityHint: @"Try again later"
    } imageBundle:nil error:&error];
    XCTAssertNotNil(view);
    XCTAssertNil(error);
    CGFloat red = 0, green = 0, blue = 0, alpha = 0;
    XCTAssertTrue([view.textLabel.textColor getRed:&red green:&green blue:&blue alpha:&alpha]);
    XCTAssertEqualWithAccuracy(red, 0x11 / 255.0, 0.001);
    XCTAssertEqualWithAccuracy(green, 0x22 / 255.0, 0.001);
    XCTAssertEqualWithAccuracy(blue, 0x33 / 255.0, 0.001);
    XCTAssertEqualObjects(view.imageView.tintColor, UIColor.redColor);
    XCTAssertEqualWithAccuracy(view.textLabel.font.pointSize, 18, 0.001);
    XCTAssertEqualObjects(view.accessibilityLabel, @"Offline");
    XCTAssertEqualObjects(view.accessibilityHint, @"Try again later");
    XCTAssertTrue(view.isAccessibilityElement);
    error = nil;
    XCTAssertNil([[CYLPlaceholderView alloc] initWithItemAttributes:@{CYLPlaceholderItemTitleColor: @"#ZZZ"} imageBundle:nil error:&error]);
    XCTAssertNotNil(error);
    error = nil;
    XCTAssertNil([[CYLPlaceholderView alloc] initWithItemAttributes:@{CYLPlaceholderItemTitleFont: @"bold:-1"} imageBundle:nil error:&error]);
    XCTAssertNotNil(error);
    if (@available(iOS 13.0, *)) {
        view = [[CYLPlaceholderView alloc] initWithItemAttributes:@{CYLPlaceholderItemImage: @"system:house"} imageBundle:nil error:&error];
        XCTAssertNotNil(view.imageView.image);
    }
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

- (void)testBundledAnimationsAreListedValidAndAttributed {
    NSArray<NSString *> *names = [CYLPlaceholderView bundledAnimationFileNames];
    XCTAssertEqual(names.count, 40u, @"%@", names);
    NSDictionary<NSString *, NSString *> *magic = @{@"pag": @"PAG", @"riv": @"RIVE", @"gif": @"GIF8"};
    NSString *notice = nil;
    for (NSString *name in names) {
        NSString *path = [CYLPlaceholderView pathForBundledAnimation:name];
        XCTAssertNotNil(path, @"%@", name);
        NSData *data = path ? [NSData dataWithContentsOfFile:path] : nil;
        XCTAssertGreaterThan(data.length, 64u, @"%@", name);
        NSString *extension = name.pathExtension;
        if ([extension isEqualToString:@"json"]) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            XCTAssertNotNil(json[@"layers"], @"%@ is not a Lottie animation", name);
        } else {
            NSString *prefix = magic[extension];
            XCTAssertNotNil(prefix, @"Unexpected file %@", name);
            NSData *head = [data subdataWithRange:NSMakeRange(0, MIN(prefix.length, data.length))];
            XCTAssertEqualObjects([[NSString alloc] initWithData:head encoding:NSASCIIStringEncoding], prefix, @"%@", name);
        }
        if (!notice && path) {
            NSString *noticePath = [path.stringByDeletingLastPathComponent stringByAppendingPathComponent:@"NOTICE.animations"];
            notice = [NSString stringWithContentsOfFile:noticePath encoding:NSUTF8StringEncoding error:NULL];
        }
        XCTAssertTrue([notice containsString:name], @"%@ has no attribution in NOTICE.animations", name);
    }
    for (NSString *scenario in @[@"CYLPlaceholderLoading.json", @"CYLPlaceholderLoading.pag", @"CYLPlaceholderLoading.riv",
                                 @"CYLPlaceholderUploading.gif", @"CYLPlaceholderEmptyCart.json"]) {
        XCTAssertTrue([names containsObject:scenario], @"%@", scenario);
    }
    XCTAssertNil([CYLPlaceholderView pathForBundledAnimation:@"Missing.json"]);
    XCTAssertNil([CYLPlaceholderView pathForBundledAnimation:@"../Animations/CYLPlaceholderLoading.json"]);
    XCTAssertNil([CYLPlaceholderView pathForBundledAnimation:@""]);
}

- (void)testPlaceholderLocalizationsHaveAllMessageKeys {
    NSBundle *container = [NSBundle bundleForClass:CYLPlaceholderView.class];
    NSURL *url = [container URLForResource:@"CYLTableViewPlaceHolder" withExtension:@"bundle"];
    if (!url) url = [NSBundle.mainBundle URLForResource:@"CYLTableViewPlaceHolder" withExtension:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithURL:url];
    NSArray<NSString *> *keys = @[@"CYLPlaceholderEmptyText", @"CYLPlaceholderNoResultsText",
        @"CYLPlaceholderNoInternetText", @"CYLPlaceholderServerUnavailableText", @"CYLPlaceholderErrorText",
        @"CYLPlaceholderLoadingText", @"CYLPlaceholderNoPermissionText", @"CYLPlaceholderEmptyCartText",
        @"CYLPlaceholderNoNotificationsText", @"CYLPlaceholderBadgeNewContent"];
    for (NSString *language in @[@"en", @"zh-Hans", @"zh-Hant", @"ja", @"ko", @"ru", @"uk"]) {
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

- (void)testAutomaticPlaceholderStaysBelowRefreshControls {
    CYLMultipleAutomaticTestSource *source = [CYLMultipleAutomaticTestSource new];
    source.sections = 1;
    UICollectionView *collection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)
                                                      collectionViewLayout:[UICollectionViewFlowLayout new]];
    collection.dataSource = source;
    [collection registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:@"cell"];
    collection.cyl_header = [CYLRefreshNormalHeader headerWithRefreshingBlock:^{}];
    collection.cyl_footer = [CYLRefreshAutoNormalFooter footerWithRefreshingBlock:^{}];
    UIView *view = [UIView new];
    [collection cyl_placeholderViewBlock:^UIView *(UICollectionView *collectionView) { return view; }];
    [collection reloadData];
    [self drainUpdates];
    NSArray<UIView *> *subviews = collection.subviews;
    NSUInteger placeholderIndex = [subviews indexOfObject:view];
    XCTAssertNotEqual(placeholderIndex, NSNotFound);
    XCTAssertGreaterThan([subviews indexOfObject:collection.cyl_footer], placeholderIndex);
    XCTAssertGreaterThan([subviews indexOfObject:collection.cyl_header], placeholderIndex);
    [collection cyl_placeholderViewBlock:nil];
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
- (void)testAppearanceDefaultsApplyLiveAndKeepExplicitValues {
    UIImage *image = [CYLPlaceholderView imageForStyle:CYLPlaceholderStyleEmpty];
    CYLPlaceholderView *placeholder = [[CYLPlaceholderView alloc] initWithImage:image text:@"Empty"];
    XCTAssertEqualObjects(placeholder.textLabel.textColor, UIColor.grayColor);
    XCTAssertEqualObjects(placeholder.imageView.tintColor, placeholder.tintColor);
    placeholder.defaultTitleColor = UIColor.redColor;
    placeholder.defaultIconColor = UIColor.greenColor;
    placeholder.defaultTitleFont = [UIFont systemFontOfSize:21];
    XCTAssertEqualObjects(placeholder.textLabel.textColor, UIColor.redColor);
    XCTAssertEqualObjects(placeholder.imageView.tintColor, UIColor.greenColor);
    XCTAssertEqualWithAccuracy(placeholder.textLabel.font.pointSize, 21, 0.01);
    placeholder.defaultIconColor = nil;
    XCTAssertEqualObjects(placeholder.imageView.tintColor, placeholder.tintColor);
    // Selected defaults sit above the normal values and below explicit selected values.
    placeholder.defaultSelectedTitleColor = UIColor.blueColor;
    placeholder.selected = YES;
    XCTAssertEqualObjects(placeholder.textLabel.textColor, UIColor.blueColor);
    placeholder.defaultTitleColor = UIColor.orangeColor;
    XCTAssertEqualObjects(placeholder.textLabel.textColor, UIColor.blueColor);
    placeholder.selected = NO;
    XCTAssertEqualObjects(placeholder.textLabel.textColor, UIColor.orangeColor);
    // A value set directly on the label wins over later appearance changes.
    placeholder.textLabel.textColor = UIColor.purpleColor;
    placeholder.defaultTitleColor = UIColor.brownColor;
    XCTAssertEqualObjects(placeholder.textLabel.textColor, UIColor.purpleColor);
    // An explicit item color wins over the appearance default.
    NSError *error = nil;
    CYLPlaceholderView *configured = [[CYLPlaceholderView alloc] initWithItemAttributes:@{
        CYLPlaceholderItemTitle: @"Item", CYLPlaceholderItemTitleColor: UIColor.cyanColor,
        CYLPlaceholderItemSelectedTitleColor: UIColor.magentaColor
    } imageBundle:nil error:&error];
    configured.defaultTitleColor = UIColor.redColor;
    configured.defaultSelectedTitleColor = UIColor.yellowColor;
    XCTAssertEqualObjects(configured.textLabel.textColor, UIColor.cyanColor);
    configured.selected = YES;
    XCTAssertEqualObjects(configured.textLabel.textColor, UIColor.magentaColor);
    configured.selected = NO;
    XCTAssertEqualObjects(configured.textLabel.textColor, UIColor.cyanColor);
}

- (void)testAppearanceProxyAndTintFollowTheHierarchy {
    UIColor *proxyColor = [UIColor colorWithRed:0.1 green:0.2 blue:0.3 alpha:1];
    [[CYLPlaceholderView appearanceWhenContainedInInstancesOfClasses:@[CYLAppearanceTestContainer.class]] setDefaultTitleColor:proxyColor];
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    CYLAppearanceTestContainer *container = [[CYLAppearanceTestContainer alloc] initWithFrame:window.bounds];
    [window addSubview:container];
    window.hidden = NO;
    CYLPlaceholderView *placeholder = [[CYLPlaceholderView alloc] initWithImage:nil text:@"Proxy"];
    placeholder.frame = container.bounds;
    [container addSubview:placeholder];
    [placeholder layoutIfNeeded];
    XCTAssertEqualObjects(placeholder.textLabel.textColor, proxyColor);
    window.tintColor = UIColor.orangeColor;
    XCTAssertEqualObjects(placeholder.imageView.tintColor, UIColor.orangeColor);
    CGRect titleFrame = placeholder.textLabel.frame;
    placeholder.defaultTitlePositionAdjustment = UIOffsetMake(3, -4);
    [placeholder layoutIfNeeded];
    XCTAssertEqualWithAccuracy(CGRectGetMinX(placeholder.textLabel.frame) - CGRectGetMinX(titleFrame), 3, 0.01);
    XCTAssertEqualWithAccuracy(CGRectGetMinY(placeholder.textLabel.frame) - CGRectGetMinY(titleFrame), -4, 0.01);
    placeholder.defaultTitlePositionAdjustment = UIOffsetZero;
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(4, 4)];
    UIImage *indicator = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        UIRectFill(CGRectMake(0, 0, 4, 4));
    }];
    placeholder.defaultSelectionIndicatorImage = indicator;
    XCTAssertNil([placeholder valueForKey:@"selectionIndicatorView"]);
    placeholder.selected = YES;
    UIImageView *indicatorView = [placeholder valueForKey:@"selectionIndicatorView"];
    XCTAssertNotNil(indicatorView);
    placeholder.selected = NO;
    XCTAssertNil([placeholder valueForKey:@"selectionIndicatorView"]);
    window.hidden = YES;
}

- (void)testBadgeSharedAppearanceAndSingleAnnouncement {
    CYLPlaceholderBadgeAppearance *shared = [CYLPlaceholderBadgeAppearance sharedAppearance];
    UIColor *savedText = shared.textColor;
    UIFont *savedFont = shared.font;
    shared.textColor = UIColor.redColor;
    shared.font = [UIFont boldSystemFontOfSize:15];
    CYLPlaceholderView *placeholder = [[CYLPlaceholderView alloc] initWithImage:nil text:@"Inbox"];
    placeholder.badgeValue = @"3";
    XCTAssertEqualObjects(placeholder.badgeLabel.textColor, UIColor.redColor);
    XCTAssertEqualWithAccuracy(placeholder.badgeLabel.font.pointSize, 15, 0.01);
    placeholder.badgeLabel.textColor = UIColor.greenColor; // customized directly
    shared.textColor = UIColor.blueColor;
    shared.font = [UIFont boldSystemFontOfSize:11];
    placeholder.badgeValue = @"4";
    XCTAssertEqualObjects(placeholder.badgeLabel.textColor, UIColor.greenColor);
    XCTAssertEqualWithAccuracy(placeholder.badgeLabel.font.pointSize, 11, 0.01);
    shared.textColor = savedText;
    shared.font = savedFont;

    // A placeholder that is itself an accessibility element announces the badge in its own value only.
    NSError *error = nil;
    CYLPlaceholderView *element = [[CYLPlaceholderView alloc] initWithItemAttributes:@{CYLPlaceholderItemTitle: @"Inbox"}
                                                                       imageBundle:nil error:&error];
    XCTAssertTrue(element.isAccessibilityElement);
    element.accessibilityValue = @"Synced";
    element.badgeValue = @"2";
    XCTAssertEqualObjects(element.accessibilityValue, @"Synced, 2");
    XCTAssertFalse(element.badgeLabel.isAccessibilityElement);
    element.badgeValue = nil;
    XCTAssertEqualObjects(element.accessibilityValue, @"Synced");

    // Badge state changes are synchronous even when the change is animated.
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [window addSubview:element];
    element.badgeValue = @"5";
    element.badgeValue = @"6";
    XCTAssertEqualObjects(element.badgeLabel.text, @"6");
    XCTAssertFalse(element.badgeLabel.hidden);
    element.badgeValue = nil;
    XCTAssertTrue(element.badgeLabel.hidden);
    XCTAssertTrue(CGAffineTransformIsIdentity(element.badgeLabel.transform));
}

static UIColor *CYLPixelColor(UIImage *image, CGPoint point) {
    unsigned char pixel[4] = {0};
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, space, kCGImageAlphaPremultipliedLast);
    CGFloat scale = image.scale;
    CGContextDrawImage(context, CGRectMake(-point.x * scale, -(image.size.height - point.y) * scale + 1,
                                           image.size.width * scale, image.size.height * scale), image.CGImage);
    CGContextRelease(context);
    CGColorSpaceRelease(space);
    return [UIColor colorWithRed:pixel[0] / 255.0 green:pixel[1] / 255.0 blue:pixel[2] / 255.0 alpha:pixel[3] / 255.0];
}

static BOOL CYLColorIsClose(UIColor *color, CGFloat r, CGFloat g, CGFloat b) {
    CGFloat red, green, blue, alpha;
    return [color getRed:&red green:&green blue:&blue alpha:&alpha] &&
        fabs(red - r) < 0.1 && fabs(green - g) < 0.1 && fabs(blue - b) < 0.1;
}

- (void)testRenderedItemShowsSelectedImageAndIndicator {
    UIImage *(^solid)(UIColor *, CGSize) = ^UIImage *(UIColor *color, CGSize size) {
        UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat preferredFormat];
        format.scale = 1;
        return [[[UIGraphicsImageRenderer alloc] initWithSize:size format:format] imageWithActions:^(UIGraphicsImageRendererContext *context) {
            [color setFill];
            UIRectFill(CGRectMake(0, 0, size.width, size.height));
        }];
    };
    NSError *error = nil;
    CYLPlaceholderView *placeholder = [[CYLPlaceholderView alloc] initWithItemAttributes:@{
        CYLPlaceholderItemImage: [solid(UIColor.blueColor, CGSizeMake(40, 30)) imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal],
        CYLPlaceholderItemSelectedImage: [solid(UIColor.greenColor, CGSizeMake(40, 30)) imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal],
        CYLPlaceholderItemTitle: @"Rendered", CYLPlaceholderItemBackgroundColor: UIColor.whiteColor
    } imageBundle:nil error:&error];
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    placeholder.frame = window.bounds;
    [window addSubview:placeholder];
    window.hidden = NO;
    [placeholder layoutIfNeeded];
    UIImage *(^render)(void) = ^UIImage *{
        [placeholder layoutIfNeeded];
        UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat preferredFormat];
        format.scale = 1;
        return [[[UIGraphicsImageRenderer alloc] initWithSize:placeholder.bounds.size format:format] imageWithActions:^(UIGraphicsImageRendererContext *context) {
            [placeholder.layer renderInContext:context.CGContext];
        }];
    };
    CGPoint imageCenter = [placeholder convertPoint:CGPointMake(CGRectGetMidX(placeholder.imageView.bounds), CGRectGetMidY(placeholder.imageView.bounds))
                                           fromView:placeholder.imageView];
    XCTAssertTrue(CYLColorIsClose(CYLPixelColor(render(), imageCenter), 0, 0, 1));
    placeholder.selectionIndicatorImage = [solid(UIColor.redColor, CGSizeMake(4, 4)) resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    placeholder.selected = YES;
    UIImage *selected = render();
    XCTAssertTrue(CYLColorIsClose(CYLPixelColor(selected, imageCenter), 0, 1, 0));
    CGRect item = [placeholder convertRect:placeholder.imageView.superview.bounds fromView:placeholder.imageView.superview];
    XCTAssertTrue(CYLColorIsClose(CYLPixelColor(selected, CGPointMake(CGRectGetMinX(item) + 2, CGRectGetMinY(item) + 2)), 1, 0, 0));
    placeholder.selected = NO;
    UIImage *normal = render();
    XCTAssertTrue(CYLColorIsClose(CYLPixelColor(normal, imageCenter), 0, 0, 1));
    XCTAssertTrue(CYLColorIsClose(CYLPixelColor(normal, CGPointMake(CGRectGetMinX(item) + 2, CGRectGetMinY(item) + 2)), 1, 1, 1));
    window.hidden = YES;
}

- (void)testBadgeAndTitleFollowAccessibilityTextSizes {
    UIViewController *parent = [[UIViewController alloc] init];
    UIViewController *child = [[UIViewController alloc] init];
    [parent addChildViewController:child];
    [parent.view addSubview:child.view];
    [child didMoveToParentViewController:parent];
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 390, 844)];
    window.rootViewController = parent;
    window.hidden = NO;
    child.view.frame = parent.view.bounds;
    CYLPlaceholderView *placeholder = [[CYLPlaceholderView alloc] initWithImage:nil text:@"Nothing new"];
    placeholder.frame = child.view.bounds;
    [child.view addSubview:placeholder];
    [placeholder showBadgeWithStyle:CYLPlaceholderBadgeStyleText value:@"New"];
    [placeholder layoutIfNeeded];
    [placeholder.imageView.superview layoutIfNeeded];
    CGFloat smallBadge = placeholder.badgeLabel.font.pointSize, smallTitle = placeholder.textLabel.font.pointSize;
    [parent setOverrideTraitCollection:[UITraitCollection traitCollectionWithPreferredContentSizeCategory:
        UIContentSizeCategoryAccessibilityExtraExtraExtraLarge] forChildViewController:child];
    [NSRunLoop.mainRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
    [placeholder layoutIfNeeded];
    [placeholder.imageView.superview layoutIfNeeded];
    UILabel *badge = placeholder.badgeLabel;
    CGSize needed = [badge.text sizeWithAttributes:@{NSFontAttributeName: badge.font}];
    NSLog(@"CYLDynamicType badge %.1f->%.1f title %.1f->%.1f badgeBounds %@ needed %@ titleFrame %@",
          smallBadge, badge.font.pointSize, smallTitle, placeholder.textLabel.font.pointSize,
          NSStringFromCGRect(badge.bounds), NSStringFromCGSize(needed), NSStringFromCGRect(placeholder.textLabel.frame));
    XCTAssertGreaterThan(badge.font.pointSize, smallBadge);
    XCTAssertGreaterThan(placeholder.textLabel.font.pointSize, smallTitle);
    XCTAssertGreaterThanOrEqual(CGRectGetWidth(badge.bounds), ceil(needed.width));
    XCTAssertGreaterThanOrEqual(CGRectGetHeight(badge.bounds), ceil(needed.height));
    window.hidden = YES;
}

@end



