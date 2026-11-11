#import <XCTest/XCTest.h>
#import "CYLRefresh.h"
#import "CYLRefreshIconView.h"
#import "CYLPlaceholderView.h"

/// The animated icon of MJRefresh's animated images (CYLRefreshIconAnimating): the GIF header and footers keep their
/// images until an icon animation is set; then the icon takes the GIF view's place with its layout and plays by a fixed
/// policy. The arrow and spinner controls keep their arrow and spinner.
@interface CYLRefreshIconTests : XCTestCase
@end

@implementation CYLRefreshIconTests

- (void)layOut:(CYLRefreshComponent *)component {
    component.frame = CGRectMake(0, 0, 320, 54);
    [component setNeedsLayout];
    [component layoutIfNeeded];
}

- (void)testTheArrowAndSpinnerControlsKeepTheirArrowAndSpinner {
    XCTAssertFalse([CYLRefreshNormalHeader conformsToProtocol:@protocol(CYLRefreshIconAnimating)]);
    XCTAssertFalse([CYLRefreshBackNormalFooter conformsToProtocol:@protocol(CYLRefreshIconAnimating)]);
    XCTAssertFalse([CYLRefreshAutoNormalFooter conformsToProtocol:@protocol(CYLRefreshIconAnimating)]);
    XCTAssertFalse([CYLRefreshNormalTrailer conformsToProtocol:@protocol(CYLRefreshIconAnimating)]);
    XCTAssertTrue([CYLRefreshAnimationHeader conformsToProtocol:@protocol(CYLRefreshIconAnimating)]);
    XCTAssertTrue([CYLRefreshBackAnimationFooter conformsToProtocol:@protocol(CYLRefreshIconAnimating)]);
    XCTAssertTrue([CYLRefreshAutoAnimationFooter conformsToProtocol:@protocol(CYLRefreshIconAnimating)]);
    CYLRefreshNormalHeader *header = [CYLRefreshNormalHeader headerWithRefreshingBlock:^{}];
    [self layOut:header];
    XCTAssertFalse(header.arrowView.hidden, @"the default arrow, as in MJRefresh");
    for (UIView *subview in header.subviews) {
        XCTAssertFalse([subview isKindOfClass:CYLRefreshIconView.class]);
    }
}

- (void)testTheMJRefreshGifNamesCallTheGeneralAnimationMethods {
    // [EN] The old names are subclasses of the general classes, so old code compiles and behaves the same.
    // [CN] 旧名称是通用类的子类，旧代码照常编译、行为不变。
    XCTAssertTrue([CYLRefreshGifHeader isSubclassOfClass:CYLRefreshAnimationHeader.class]);
    XCTAssertTrue([CYLRefreshBackGifFooter isSubclassOfClass:CYLRefreshBackAnimationFooter.class]);
    XCTAssertTrue([CYLRefreshAutoGifFooter isSubclassOfClass:CYLRefreshAutoAnimationFooter.class]);
    XCTAssertTrue([CYLRefreshGifHeader conformsToProtocol:@protocol(CYLRefreshIconAnimating)]);

    UIImage *small = [CYLPlaceholderView imageForStyle:CYLPlaceholderStyleRefresh];
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(10, 120)];
    UIImage *tall = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {}];
    // [EN] The control grows to the first image's height. [CN] 控件高度随第一张图片增大。
    NSArray<UIImage *> *images = @[tall, small];

    CYLRefreshGifHeader *header = [CYLRefreshGifHeader headerWithRefreshingBlock:^{}];
    XCTAssertEqual(header.gifView, header.animationView, @"gifView is the animation view");
    XCTAssertEqual([header setImages:images forState:CYLRefreshStateRefreshing], header);
    XCTAssertEqualWithAccuracy(header.frame.size.height, 120, 0.5, @"setImages: grows the control like setAnimationImages:");

    CYLRefreshAutoGifFooter *autoFooter = [CYLRefreshAutoGifFooter footerWithRefreshingBlock:^{}];
    XCTAssertEqual(autoFooter.gifView, autoFooter.animationView);
    XCTAssertEqual([autoFooter setImages:images duration:1 forState:CYLRefreshStateRefreshing], autoFooter);
    XCTAssertEqualWithAccuracy(autoFooter.frame.size.height, 120, 0.5);

    CYLRefreshBackGifFooter *backFooter = [CYLRefreshBackGifFooter footerWithRefreshingBlock:^{}];
    XCTAssertEqual(backFooter.gifView, backFooter.animationView);
    XCTAssertEqual([backFooter setImages:images forState:CYLRefreshStatePulling], backFooter);
    XCTAssertEqualWithAccuracy(backFooter.frame.size.height, 120, 0.5);
}

- (void)testWithoutAnIconAnimationTheAnimationHeaderIsUnchanged {
    CYLRefreshAnimationHeader *header = [CYLRefreshAnimationHeader headerWithRefreshingBlock:^{}];
    UIImage *image = [CYLPlaceholderView imageForStyle:CYLPlaceholderStyleRefresh];
    XCTAssertEqual([header setAnimationImages:@[image] forState:CYLRefreshStateIdle], header, @"the animated images API is unchanged");
    [self layOut:header];
    XCTAssertFalse(header.usesIconView);
    XCTAssertFalse(header.animationView.hidden);
    [header setIconAnimationAttributes:nil forState:CYLRefreshStateIdle];
    XCTAssertFalse(header.usesIconView, @"removing nothing creates nothing");
}

- (void)testAnIconAnimationTakesTheAnimationViewsPlaceCenteredVertically {
    CYLRefreshAnimationHeader *header = [CYLRefreshAnimationHeader headerWithRefreshingBlock:^{}];
    [header setBundledIconAnimation:@"CYLRefreshArrows.gif" size:CGSizeMake(36, 36) forState:CYLRefreshStateIdle];
    [self layOut:header];
    XCTAssertTrue(header.usesIconView);
    XCTAssertEqual(header.iconView.superview, header);
    XCTAssertTrue(header.animationView.hidden);
    XCTAssertFalse(header.iconView.hidden);
    XCTAssertTrue(CGSizeEqualToSize(header.iconView.bounds.size, CGSizeMake(36, 36)));
    XCTAssertEqualWithAccuracy(header.iconView.center.y, CGRectGetMidY(header.bounds), 0.5, @"centered in the height");
    XCTAssertEqualWithAccuracy(CGRectGetMaxX(header.iconView.frame), CGRectGetMaxX(header.animationView.frame), 0.5,
                               @"right-aligned where the GIF view draws its images");
    CGFloat textWidth = MAX(header.stateLabel.cyl_textWidth, header.lastUpdatedTimeLabel.cyl_textWidth);
    CGFloat textStart = header.cyl_w * 0.5 - textWidth * 0.5;
    XCTAssertLessThanOrEqual(CGRectGetMaxX(header.iconView.frame), textStart - header.labelLeftInset + 0.5,
                             @"the GIF view's gap to the text");
    // [EN] The component draws inside the icon. [CN] 组件在图标内绘制。
    CYLPlaceholderView *view = header.iconView.placeholderView;
    XCTAssertTrue(CGRectEqualToRect(view.frame, header.iconView.bounds));
    [view layoutIfNeeded];
    UIView *item = view.imageView.superview;
    CGRect content = [header.iconView convertRect:item.frame fromView:item.superview];
    XCTAssertTrue(CGRectContainsRect(CGRectInset(header.iconView.bounds, -0.5, -0.5), content), @"%@",
                  NSStringFromCGRect(content));
    XCTAssertTrue(header.iconView.accessibilityElementsHidden, @"decorative: the state label speaks");
    header.stateLabel.hidden = YES;
    header.lastUpdatedTimeLabel.hidden = YES;
    [self layOut:header];
    XCTAssertEqualWithAccuracy(header.iconView.center.x, CGRectGetMidX(header.bounds), 0.5, @"centered without text");
}

- (void)testThePlaybackFollowsTheControlState {
    CYLRefreshAnimationHeader *header = [CYLRefreshAnimationHeader headerWithRefreshingBlock:^{}];
    NSString *loading = [CYLPlaceholderView pathForBundledAnimation:@"CYLPlaceholderLoading.json"];
    [header setIconAnimationFilePath:loading size:CGSizeMake(30, 30) forState:CYLRefreshStateIdle];
    CYLPlaceholderView *icon = header.iconView.placeholderView;
    XCTAssertNotNil(icon);
    header.state = CYLRefreshStateRefreshing;
    XCTAssertEqual(icon.animationRepeatCount, 0, @"loops while refreshing");
    header.state = CYLRefreshStateIdle;
    header.pullingPercent = 0.5;
    header.pullingPercent = 0;
    // [EN] A different icon per state is swapped in. [CN] 每个状态可以使用不同的图标。
    [header setBundledIconAnimation:@"CYLPlaceholderRefresh.json" size:CGSizeMake(30, 30) forState:CYLRefreshStatePulling];
    header.state = CYLRefreshStatePulling;
    XCTAssertNotEqual(header.iconView.placeholderView, icon);
    header.state = CYLRefreshStateIdle;
    XCTAssertEqualObjects(header.iconView.placeholderView.itemAttributes[CYLPlaceholderItemAnimationFilePath], loading,
                          @"other states fall back to the idle icon");
    XCTAssertNotNil([header.iconView animationAttributesForState:CYLRefreshStatePulling]);
    XCTAssertNil([header.iconView animationAttributesForState:CYLRefreshStateRefreshing]);
}

- (void)testAnimationFootersShowTheIconWhenTheirImagesWouldShow {
    CYLRefreshAutoAnimationFooter *autoFooter = [CYLRefreshAutoAnimationFooter footerWithRefreshingBlock:^{}];
    [autoFooter setBundledIconAnimation:@"CYLRefreshSpinnerRing.json" size:CGSizeMake(24, 24) forState:CYLRefreshStateIdle];
    [self layOut:autoFooter];
    XCTAssertTrue(autoFooter.iconView.hidden, @"an auto GIF footer shows its images only while loading");
    autoFooter.state = CYLRefreshStateRefreshing;
    [self layOut:autoFooter];
    XCTAssertFalse(autoFooter.iconView.hidden);
    XCTAssertTrue(autoFooter.animationView.hidden);
    XCTAssertEqualWithAccuracy(autoFooter.iconView.center.y, CGRectGetMidY(autoFooter.bounds), 0.5);
    autoFooter.state = CYLRefreshStateNoMoreData;
    XCTAssertTrue(autoFooter.iconView.hidden);

    CYLRefreshBackAnimationFooter *backFooter = [CYLRefreshBackAnimationFooter footerWithRefreshingBlock:^{}];
    [backFooter setBundledIconAnimation:@"CYLRefreshPullArrow.json" size:CGSizeMake(24, 24) forState:CYLRefreshStateIdle];
    [self layOut:backFooter];
    XCTAssertFalse(backFooter.iconView.hidden);
    XCTAssertTrue(backFooter.animationView.hidden);
    XCTAssertEqualWithAccuracy(backFooter.iconView.center.y, CGRectGetMidY(backFooter.bounds), 0.5);
    backFooter.state = CYLRefreshStateNoMoreData;
    XCTAssertTrue(backFooter.iconView.hidden, @"no more data shows the text only, as before");
}

- (void)testMissingBundledAnimationsAreIgnored {
    CYLRefreshBackAnimationFooter *footer = [CYLRefreshBackAnimationFooter footerWithRefreshingBlock:^{}];
    [footer setBundledIconAnimation:@"Missing.json" size:CGSizeMake(20, 20) forState:CYLRefreshStateIdle];
    XCTAssertFalse(footer.usesIconView);
    [footer setIconAnimationFilePath:@"" size:CGSizeMake(20, 20) forState:CYLRefreshStateIdle];
    XCTAssertFalse(footer.usesIconView);
}

- (void)testEveryBundledRefreshAnimationBuildsAnIcon {
    NSArray<NSString *> *names = CYLRefreshAnimationHeader.bundledIconAnimationFileNames;
    XCTAssertEqualObjects(names, CYLRefreshAutoAnimationFooter.bundledIconAnimationFileNames);
    NSUInteger refreshFiles = 0;
    for (NSString *name in names) {
        if ([name hasPrefix:@"CYLRefresh"]) refreshFiles++;
        CYLRefreshAnimationHeader *header = [CYLRefreshAnimationHeader headerWithRefreshingBlock:^{}];
        [header setBundledIconAnimation:name size:CGSizeMake(32, 32) forState:CYLRefreshStateIdle];
        XCTAssertTrue(header.usesIconView, @"%@", name);
        NSDictionary *attributes = [header.iconView animationAttributesForState:CYLRefreshStateIdle];
        XCTAssertEqualObjects([attributes[CYLPlaceholderItemAnimationFilePath] lastPathComponent], name);
    }
    XCTAssertEqual(refreshFiles, 22u, @"%@", names);
    XCTAssertEqual(names.count, 24u, @"the CYLRefresh files plus two refresh-like placeholder files: %@", names);
    XCTAssertTrue([names containsObject:@"CYLPlaceholderProgress.pag"], @"PAG comes from the placeholder set");
    // [EN] Scenes, hands and play arrows are placeholder art, not refresh icons. [CN] 场景、手势与播放箭头是占位插画，不是刷新图标。
    for (NSString *name in @[@"CYLPlaceholderPullToRefresh.riv", @"CYLPlaceholderLoading.pag", @"CYLPlaceholderPullHint.pag",
                             @"CYLPlaceholderLoading.riv", @"CYLPlaceholderUploading.gif"]) {
        XCTAssertFalse([names containsObject:name], @"%@", name);
    }
    for (NSString *extension in @[@"gif", @"json", @"pag", @"riv"]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pathExtension == %@", extension];
        NSUInteger count = [names filteredArrayUsingPredicate:predicate].count;
        XCTAssertGreaterThan(count, 0u, @"%@", extension);
    }
    CYLRefreshAnimationHeader *header = [CYLRefreshAnimationHeader headerWithRefreshingBlock:^{}];
    [header setBundledIconAnimation:@"CYLRefreshIcon.riv" size:CGSizeMake(32, 32) forState:CYLRefreshStateIdle];
    NSDictionary *options = [header.iconView animationAttributesForState:CYLRefreshStateIdle][CYLPlaceholderItemAnimationOptions];
    XCTAssertEqualObjects(options[@"artboard"], @"refresh", @"the bundled Rive file brings its options");
    XCTAssertEqualObjects(options[@"animation"], @"active");
}

- (void)testAPlaceholderGivesUpItsMarginsOnlyWhenTooNarrow {
    UIImage *image = [CYLPlaceholderView imageForStyle:CYLPlaceholderStyleRefresh];
    CYLPlaceholderView *view = [[CYLPlaceholderView alloc] initWithImage:image text:nil];
    XCTAssertEqualWithAccuracy(view.contentMargin, 16, 0.01, @"a full-screen placeholder keeps 16 points");
    view.frame = CGRectMake(0, 0, image.size.width + 8, 100);
    [view layoutIfNeeded];
    UIView *item = view.imageView.superview;
    XCTAssertGreaterThanOrEqual(CGRectGetWidth(item.frame), image.size.width - 0.5, @"no zero-width item");
    XCTAssertEqualWithAccuracy(CGRectGetMidX(item.frame), CGRectGetMidX(view.bounds), 0.5);
    CYLPlaceholderView *text = [[CYLPlaceholderView alloc] initWithImage:nil text:@"A long title that wraps over several lines of text"];
    text.frame = CGRectMake(0, 0, 200, 300);
    [text layoutIfNeeded];
    XCTAssertGreaterThanOrEqual(CGRectGetMinX(text.textLabel.superview.frame), 16 - 0.5, @"wrapping text keeps the margins");
}

@end
