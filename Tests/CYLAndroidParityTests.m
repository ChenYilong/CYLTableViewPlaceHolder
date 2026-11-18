#import <XCTest/XCTest.h>
#import "CYLPlaceholderView.h"
#import "CYLPlaceholderStackView.h"
#import "CYLPlaceholderLocalization.h"
#import "UITableView+CYLPlaceholder.h"
#import "UIViewController+CYLPlaceholderStatus.h"
#import "CYLRefreshFlyHeader.h"
// CYLPlaceholderView is Swift: its interface comes with the umbrella header (the generated Swift header).
#import "CYLTableViewPlaceHolder.h"

#if CYL_ANIMATION_ENGINE_AVAILABLE
/// [EN] The view and player of the test animator below; the player does nothing, the test only checks that a view is
///      made. [CN] 下面测试 animator 的视图与播放器；播放器不做任何事，本测试只检查视图是否创建。
@interface CYLParityGIFView : UIView
@end
@implementation CYLParityGIFView
@end
@interface CYLParityGIFPlayer : CYLTabBarItemAnimationBasePlayer <CYLTabBarItemAnimationPlayer>
@end
@implementation CYLParityGIFPlayer
- (void)play {}
- (void)stop {}
- (void)showLastFrame {}
@end

/// [EN] A GIF animator for the engine, as the GIF subspec registers one. [CN] 引擎的 GIF animator，与 GIF 子库注册的相同。
@interface CYLParityGIFAnimator : NSObject <CYLTabBarItemAnimator>
@end
@implementation CYLParityGIFAnimator
- (NSString *)identifier { return @"CYLParityGIF"; }
- (CYLTabBarItemAnimatorPriority)priority { return 2000; }
- (BOOL)canAnimateFileAtURL:(NSURL *)URL { return [URL.pathExtension.lowercaseString isEqualToString:@"gif"]; }
- (UIView *)animationViewWithURL:(NSURL *)URL size:(CGSize)size contentMode:(UIViewContentMode)contentMode {
    return [[CYLParityGIFView alloc] initWithFrame:(CGRect){CGPointZero, size}];
}
- (id<CYLTabBarItemAnimationPlayer>)playerForAnimationView:(UIView *)view {
    return [view isKindOfClass:CYLParityGIFView.class] ? [[CYLParityGIFPlayer alloc] initWithAnimationView:view] : nil;
}
@end
#endif

/// A table data source whose row count the test sets.
@interface CYLParityRows : NSObject <UITableViewDataSource>
@property (nonatomic) NSInteger rows;
@end

@implementation CYLParityRows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rows;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
}
@end

/// The iOS APIs added for parity with the Android core (docs/iOS-API-Map.md); each test mirrors the Android unit test
/// named in its comment.
@interface CYLAndroidParityTests : XCTestCase
@property (nonatomic, strong) UIWindow *window;
@end

@implementation CYLAndroidParityTests

- (void)setUp {
    [super setUp];
    CYLPlaceholderLocalization.language = @"en";
}

- (void)tearDown {
    self.window.hidden = YES;
    self.window = nil;
    CYLPlaceholderLocalization.language = nil;
    [super tearDown];
}

/// Runs the main run loop until `condition` holds or 10 seconds pass; the placeholder updates on the next turn.
- (BOOL)waitFor:(BOOL (^)(void))condition {
    NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:10];
    while (!condition() && deadline.timeIntervalSinceNow > 0) {
        [NSRunLoop.mainRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.05]];
    }
    return condition();
}

/// Android: CYLTableViewPlaceHolderTest (`RecyclerView.cyl_placeholderView`).
- (void)testTheListReportsThePlaceholderItShows {
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) style:UITableViewStylePlain];
    [table registerClass:UITableViewCell.class forCellReuseIdentifier:@"cell"];
    CYLParityRows *rows = [[CYLParityRows alloc] init];
    table.dataSource = rows;
    self.window = [[UIWindow alloc] initWithFrame:table.frame];
    [self.window addSubview:table];
    self.window.hidden = NO;
    XCTAssertNil(table.cyl_placeholderView, @"no placeholder before the block API is used");

    UIView *placeholder = [[UIView alloc] init];
    [table cyl_placeholderViewBlock:^UIView *(UITableView *tableView) { return placeholder; }];
    [table reloadData];
    XCTAssertTrue([self waitFor:^BOOL { return table.cyl_placeholderView == placeholder; }],
                  @"an empty list reports the placeholder it shows");

    rows.rows = 3;
    [table reloadData];
    XCTAssertTrue([self waitFor:^BOOL { return table.cyl_placeholderView == nil; }], @"data came: the placeholder goes");
    [table cyl_placeholderViewBlock:nil];
}

/// Android: CYLPlaceholderStackViewTest (`hintLabel`, `button`, `imageView`, `titleLabel`).
- (void)testTheStackViewNamesItsFirstHintButtonIconAndTitle {
    CYLPlaceholderStackView *results = [[CYLPlaceholderStackView alloc]
        initWithScenario:CYLPlaceholderScenarioNoSearchResults actions:nil];
    XCTAssertEqualObjects(results.hintLabel.text, @"Try different keywords");
    XCTAssertNil(results.button, @"no button in this scenario");
    XCTAssertEqualObjects(results.titleLabel.text, @"No matching results");
    XCTAssertEqual(results.imageView, results.placeholderView.imageView);

    __block NSUInteger tapped = 0;
    CYLPlaceholderActionHandler handler = ^(CYLPlaceholderStackView *placeholder, CYLPlaceholderAction action) {
        tapped++;
    };
    CYLPlaceholderStackView *cart = [[CYLPlaceholderStackView alloc]
        initWithScenario:CYLPlaceholderScenarioEmptyCart actions:@{CYLPlaceholderActionGoShopping: handler}];
    XCTAssertNil(cart.hintLabel);
    XCTAssertEqualObjects(cart.button.textLabel.text, @"Go shopping");
    XCTAssertTrue([cart.button performTap]);
    XCTAssertEqual(tapped, 1u, @"the button runs its action");
}

/// Android: `CYLPlaceholderComponent.text(title, sizeSp, color)`.
- (void)testATextComponentHasItsOwnSizeAndColor {
    CYLPlaceholderComponent *text = [CYLPlaceholderComponent textComponentWithText:@"Hello" fontSize:22
                                                                              color:UIColor.redColor];
    XCTAssertEqualObjects(text.attributes[CYLPlaceholderItemTitle], @"Hello");
    XCTAssertEqualObjects(text.attributes[CYLPlaceholderItemTitleColor], UIColor.redColor);
    UIFont *font = text.attributes[CYLPlaceholderItemTitleFont];
    XCTAssertGreaterThanOrEqual(font.pointSize, 22 - 0.01, @"at least the size asked (Dynamic Type may enlarge it)");
    CYLPlaceholderComponent *plain = [CYLPlaceholderComponent textComponentWithText:@"Plain" fontSize:0 color:nil];
    XCTAssertNil(plain.attributes[CYLPlaceholderItemTitleFont], @"0 keeps the default look");
    XCTAssertNil(plain.attributes[CYLPlaceholderItemTitleColor]);
    CYLPlaceholderStackView *stack = [[CYLPlaceholderStackView alloc] initWithComponents:@[text] actions:nil];
    XCTAssertEqualObjects(stack.titleLabel.text, @"Hello");
}

/// Android: CYLPlaceholderViewTest (`setAnimationFile`).
- (void)testAnAnimationFileReplacesTheIconOnlyWhenItPlays {
    CYLPlaceholderView *view = [[CYLPlaceholderView alloc] initWithStyle:CYLPlaceholderStyleEmpty text:@"Empty"];
    XCTAssertFalse([view setAnimationFile:@"Missing.json"], @"a missing file keeps the icon");
    XCTAssertNil(view.itemAttributes[CYLPlaceholderItemAnimationFilePath]);
#if CYL_ANIMATION_ENGINE_AVAILABLE
    // [EN] Animations play through CYLTabBarController's engine: with no animator for GIF (the test build has the engine
    //      and no animation library) the icon is kept; with one registered, the file replaces it.
    // [CN] 动画通过 CYLTabBarController 的引擎播放：没有 GIF 的 animator 时（测试工程有引擎、没有动画库）保留图标；注册之后文件代替图标。
    XCTAssertFalse([view setAnimationFile:@"CYLRefreshArrows.gif"]);
    XCTAssertNil(view.itemAttributes[CYLPlaceholderItemAnimationFilePath]);
    CYLParityGIFAnimator *animator = [CYLParityGIFAnimator new];
    [CYLTabBarItemAnimatorRegistry registerAnimator:animator];
    XCTAssertTrue([view setAnimationFile:@"CYLRefreshArrows.gif"]);
    XCTAssertEqualObjects([view.itemAttributes[CYLPlaceholderItemAnimationFilePath] lastPathComponent],
                          @"CYLRefreshArrows.gif");
    XCTAssertNotNil(view.animationView);
    [CYLTabBarItemAnimatorRegistry unregisterAnimatorWithIdentifier:animator.identifier];
#else
    XCTAssertFalse([view setAnimationFile:@"CYLRefreshArrows.gif"], @"no engine: nothing plays");
#endif
}

/// Android: CYLPlaceholderConfigurationTest (`CYLPlaceholderConfigurationError`).
- (void)testARefusedConfigurationNamesItsDomainAndKind {
    NSError *error = nil;
    NSDictionary *badItem = @{CYLPlaceholderItemTitle: @42};
    XCTAssertNil([[CYLPlaceholderView alloc] initWithItemAttributes:badItem imageBundle:nil error:&error]);
    XCTAssertEqualObjects(error.domain, CYLPlaceholderConfigurationErrorDomain);
    XCTAssertEqual(error.code, CYLPlaceholderConfigurationErrorItemAttributes);

    error = nil;
    NSDictionary *badStack = @{@"scenario": @"Nope"};
    XCTAssertNil([[CYLPlaceholderStackView alloc] initWithConfiguration:badStack actions:nil error:&error]);
    XCTAssertEqualObjects(error.domain, CYLPlaceholderConfigurationErrorDomain);
    XCTAssertEqual(error.code, CYLPlaceholderConfigurationErrorStackView);
}

/// Android: `CYLRefreshIconView.IMAGES` and `DURATION`.
- (void)testImageFramesBecomeOneAnimatedIcon {
    UIImage *first = [CYLPlaceholderView imageForStyle:CYLPlaceholderStyleRefresh];
    UIImage *second = [CYLPlaceholderView imageForStyle:CYLPlaceholderStyleEmpty];
    NSArray<UIImage *> *frames = @[first, second];
    NSDictionary *attributes = @{CYLPlaceholderItemImages: frames, CYLPlaceholderItemAnimationDuration: @0.4};
    NSError *error = nil;
    CYLPlaceholderView *view = [[CYLPlaceholderView alloc] initWithItemAttributes:attributes imageBundle:nil error:&error];
    XCTAssertNotNil(view, @"%@", error);
    UIImage *icon = view.imageView.image;
    XCTAssertNotNil(icon);
    if (!UIAccessibilityIsReduceMotionEnabled()) {
        XCTAssertEqual(icon.images.count, 2u, @"the frames play in a loop");
        XCTAssertEqualWithAccuracy(icon.duration, 0.4, 0.001);
    }
    NSDictionary *bad = @{CYLPlaceholderItemImages: @[@"not an image"]};
    XCTAssertNil([[CYLPlaceholderView alloc] initWithItemAttributes:bad imageBundle:nil error:&error]);
    XCTAssertEqual(error.code, CYLPlaceholderConfigurationErrorItemAttributes);
}

/// Android: `CYLRefreshFlyHeader.mountainView`, `flyView`, `floatView`.
- (void)testThePaperPlaneHeaderShowsItsSceneViews {
    CYLRefreshFlyHeader *header = [CYLRefreshFlyHeader headerWithRefreshingBlock:^{}];
    XCTAssertNotNil(header.mountainView);
    XCTAssertNotNil(header.flyView);
    XCTAssertNotNil(header.floatView);
    XCTAssertEqual(header.flyView.superview, header);
    XCTAssertEqual(header.floatView.superview, header);
}

@end
