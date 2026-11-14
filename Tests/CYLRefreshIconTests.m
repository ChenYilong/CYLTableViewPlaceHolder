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

- (void)assertNoIconIn:(UIView *)control {
    for (UIView *subview in control.subviews) {
        XCTAssertFalse([subview isKindOfClass:CYLRefreshIconView.class], @"%@ never creates an icon view", control.class);
    }
}

- (void)testTheDefaultArrowControlsKeepMJRefreshsArrowLogic {
    // [EN] The arrow controls are the pre-icon code: the arrow image, its rotation and the spinner per state.
    // [CN] 箭头控件是图标改造前的代码：箭头图片、按状态旋转箭头与菊花。
    CYLRefreshNormalHeader *header = [CYLRefreshNormalHeader headerWithRefreshingBlock:^{}];
    [self layOut:header];
    XCTAssertEqualObjects(header.arrowView.image, [NSBundle cyl_arrowImage]);
    XCTAssertFalse(header.arrowView.hidden);
    XCTAssertTrue(CGAffineTransformIsIdentity(header.arrowView.transform), @"idle: the arrow points down");
    header.state = CYLRefreshStatePulling;
    XCTAssertEqualWithAccuracy(header.arrowView.transform.a, -1, 0.001, @"pulling: the arrow turns up");
    XCTAssertFalse(header.loadingView.isAnimating);
    header.state = CYLRefreshStateRefreshing;
    XCTAssertTrue(header.arrowView.hidden, @"refreshing: the spinner replaces the arrow");
    XCTAssertTrue(header.loadingView.isAnimating);
    [self assertNoIconIn:header];

    CYLRefreshBackNormalFooter *backFooter = [CYLRefreshBackNormalFooter footerWithRefreshingBlock:^{}];
    [self layOut:backFooter];
    XCTAssertEqualObjects(backFooter.arrowView.image, [NSBundle cyl_arrowImage]);
    backFooter.state = CYLRefreshStatePulling;
    XCTAssertTrue(CGAffineTransformIsIdentity(backFooter.arrowView.transform), @"pulling: the footer arrow turns down");
    backFooter.state = CYLRefreshStateRefreshing;
    XCTAssertTrue(backFooter.arrowView.hidden);
    XCTAssertTrue(backFooter.loadingView.isAnimating);
    backFooter.state = CYLRefreshStateNoMoreData;
    XCTAssertTrue(backFooter.arrowView.hidden);
    XCTAssertFalse(backFooter.loadingView.isAnimating);
    [self assertNoIconIn:backFooter];

    CYLRefreshAutoNormalFooter *autoFooter = [CYLRefreshAutoNormalFooter footerWithRefreshingBlock:^{}];
    [self layOut:autoFooter];
    autoFooter.state = CYLRefreshStateRefreshing;
    XCTAssertTrue(autoFooter.loadingView.isAnimating);
    autoFooter.state = CYLRefreshStateNoMoreData;
    XCTAssertFalse(autoFooter.loadingView.isAnimating);
    [self assertNoIconIn:autoFooter];

    CYLRefreshNormalTrailer *trailer = [CYLRefreshNormalTrailer trailerWithRefreshingBlock:^{}];
    [self layOut:trailer];
    XCTAssertEqualObjects(trailer.arrowView.image, [NSBundle cyl_trailArrowImage]);
    [self assertNoIconIn:trailer];
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

- (void)testWithoutImagesOrAnIconTheAnimationHeaderCreatesNothing {
    CYLRefreshAnimationHeader *header = [CYLRefreshAnimationHeader headerWithRefreshingBlock:^{}];
    [self layOut:header];
    XCTAssertFalse(header.usesIconView);
    [header setIconAnimationAttributes:nil forState:CYLRefreshStateIdle];
    XCTAssertFalse(header.usesIconView, @"removing nothing creates nothing");
    [self assertNoIconIn:header];
}

- (void)testImageSequencesAreDrawnByTheIconsPlaceholderViewWithTheStateText {
    // [EN] MJRefresh's setImages: / setAnimationImages: go through the same CYLPlaceholderView as every other icon.
    // [CN] MJRefresh 的 setImages: / setAnimationImages: 与其他图标一样经过同一个 CYLPlaceholderView。
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(40, 40)];
    NSMutableArray<UIImage *> *frames = [NSMutableArray array];
    for (NSInteger i = 0; i < 4; i++) {
        [frames addObject:[renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
            [[UIColor colorWithWhite:i / 4.0 alpha:1] setFill];
            [context fillRect:CGRectMake(0, 0, 40, 40)];
        }]];
    }
    CYLRefreshGifHeader *header = [CYLRefreshGifHeader headerWithRefreshingBlock:^{}];
    [header setImages:frames forState:CYLRefreshStateIdle];
    [header setImages:frames duration:0.8 forState:CYLRefreshStateRefreshing];
    [self layOut:header];
    XCTAssertTrue(header.usesIconView);
    XCTAssertTrue(header.gifView.hidden, @"the image view stays for compatibility, hidden");
    CYLPlaceholderView *view = header.iconView.placeholderView;
    XCTAssertEqual(view.imageView.image, frames.firstObject, @"idle: a still frame");
    XCTAssertTrue([view.textLabel.text hasPrefix:header.stateLabel.text], @"the state text is in the same view");
    XCTAssertEqualWithAccuracy(header.iconView.iconSize.width, 40, 0.01, @"the icon has the image's size");
    header.pullingPercent = 0.6;
    XCTAssertEqual(header.iconView.placeholderView.imageView.image, frames[2], @"pulling picks the frame, as in MJRefresh");
    header.state = CYLRefreshStateRefreshing;
    [self layOut:header];
    UIImage *playing = header.iconView.placeholderView.imageView.image;
    XCTAssertEqual(playing.images.count, 4u, @"refreshing: the frames play as one animated image");
    XCTAssertEqualWithAccuracy(playing.duration, 0.8, 0.001);

    CYLRefreshAutoGifFooter *autoFooter = [CYLRefreshAutoGifFooter footerWithRefreshingBlock:^{}];
    [autoFooter setImages:frames forState:CYLRefreshStateRefreshing];
    [self layOut:autoFooter];
    XCTAssertTrue(autoFooter.iconView.hidden, @"the auto footer shows its icon only while loading");
    autoFooter.state = CYLRefreshStateRefreshing;
    [self layOut:autoFooter];
    XCTAssertFalse(autoFooter.iconView.hidden);
    XCTAssertTrue(autoFooter.gifView.hidden);
    XCTAssertEqual(autoFooter.iconView.placeholderView.imageView.image.images.count, 4u);

    CYLRefreshBackGifFooter *backFooter = [CYLRefreshBackGifFooter footerWithRefreshingBlock:^{}];
    [backFooter setImages:frames forState:CYLRefreshStatePulling];
    [self layOut:backFooter];
    XCTAssertEqual(backFooter.iconView.placeholderView.imageView.image, frames.firstObject,
                   @"idle without its own images: the first image, still");
    backFooter.state = CYLRefreshStatePulling;
    XCTAssertEqual(backFooter.iconView.placeholderView.imageView.image.images.count, 4u);
}

- (void)testTheTrailerTextIsCompleteAndReadableInEveryLanguage {
    // [EN] MJRefresh's one-character-wide column breaks English words letter by letter and cuts them off; CJK text
    //      stays upright, other text is rotated to read top to bottom and wraps instead of being cut off.
    // [CN] MJRefresh 一个字宽的竖列会把英文单词逐字母拆开并截断；中日韩文字保持正立，其他文字旋转后从上往下读，过长时换行而不截断。
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    scrollView.contentSize = CGSizeMake(1600, 200);
    CYLRefreshNormalTrailer *trailer = [CYLRefreshNormalTrailer trailerWithRefreshingBlock:^{}];
    scrollView.cyl_trailer = trailer;
    UILabel *label = trailer.stateLabel;

    [trailer setTitle:@"释放查看图文详情" forState:CYLRefreshStateIdle];
    [trailer setNeedsLayout];
    [trailer layoutIfNeeded];
    XCTAssertTrue(CGAffineTransformIsIdentity(label.transform), @"CJK: upright, as in MJRefresh");
    XCTAssertEqualWithAccuracy(CGRectGetWidth(label.bounds), ceil(label.font.pointSize), 0.5);

    for (NSString *text in @[@"Release to see more", @"Отпустите, чтобы посмотреть подробности",
                             @"Release to see the details of this page, and keep reading what comes next"]) {
        [trailer setTitle:text forState:CYLRefreshStateIdle];
        [trailer setNeedsLayout];
        [trailer layoutIfNeeded];
        XCTAssertEqualWithAccuracy(atan2(label.transform.b, label.transform.a), M_PI_2, 0.001, @"%@: rotated", text);
        CGSize needed = [label sizeThatFits:CGSizeMake(CGRectGetWidth(label.bounds), CGFLOAT_MAX)];
        XCTAssertLessThanOrEqual(needed.height, CGRectGetHeight(label.bounds) + 0.5, @"%@: shown in full", text);
        XCTAssertLessThanOrEqual(CGRectGetHeight(label.frame), CGRectGetHeight(trailer.bounds) + 0.5,
                                 @"%@: within the control's height", text);
        XCTAssertGreaterThan(CGRectGetMinX(label.frame), CGRectGetMaxX(trailer.arrowView.frame) - 0.5,
                             @"%@: right of the arrow", text);
    }
}

- (void)testTheHeaderIsHiddenWhileIdleAndRetracted {
    // [EN] iOS 26's glass navigation bar shows what is under it: the retracted header is masked out while idle.
    // [CN] iOS 26 的玻璃导航栏会透出下方内容：空闲时把收回的刷新头遮住。
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    scrollView.contentSize = CGSizeMake(320, 1000);
    CYLRefreshNormalHeader *header = [CYLRefreshNormalHeader headerWithRefreshingBlock:^{}];
    scrollView.cyl_header = header;
    [self layOut:header];
    if (@available(iOS 26.0, *)) {
        XCTAssertTrue(header.autoHideRefresh, @"on by default where the navigation bar is transparent by default");
    } else {
        XCTAssertFalse(header.autoHideRefresh, @"off by default on earlier systems");
        header.autoHideRefresh = YES;
    }
    XCTAssertNotNil(header.layer.mask, @"idle and retracted: masked out");
    XCTAssertTrue(header.accessibilityElementsHidden);
    XCTAssertFalse(header.hidden, @"the caller's hidden is not touched");
    XCTAssertEqual(header.alpha, 1, @"nor alpha");
    scrollView.contentOffset = CGPointMake(0, -20);
    XCTAssertNil(header.layer.mask, @"pulled down: shown");
    XCTAssertFalse(header.accessibilityElementsHidden);
    scrollView.contentOffset = CGPointMake(0, 200);
    XCTAssertNotNil(header.layer.mask, @"scrolled away: hidden again");
    header.state = CYLRefreshStateRefreshing;
    XCTAssertNil(header.layer.mask, @"refreshing: shown");
    header.state = CYLRefreshStateIdle;
    XCTAssertNil(header.layer.mask, @"retracting after the refresh: still shown");
    header.autoHideRefresh = NO;
    header.pullingPercent = 0;
    XCTAssertNil(header.layer.mask, @"NO: MJRefresh's behavior");
}

- (void)testAnIconAnimationAndTheStateTextAreOneCenteredPlaceholderView {
    CYLRefreshAnimationHeader *header = [CYLRefreshAnimationHeader headerWithRefreshingBlock:^{}];
    [header setBundledIconAnimation:@"CYLRefreshArrows.gif" size:CGSizeMake(36, 36) forState:CYLRefreshStateIdle];
    [self layOut:header];
    XCTAssertTrue(header.usesIconView);
    XCTAssertEqual(header.iconView.superview, header);
    XCTAssertTrue(header.animationView.hidden);
    XCTAssertFalse(header.iconView.hidden);
    // [EN] One CYLPlaceholderView holds the icon and both lines of text. [CN] 一个 CYLPlaceholderView 同时包含图标与两行文字。
    CYLPlaceholderView *view = header.iconView.placeholderView;
    NSString *expected = [NSString stringWithFormat:@"%@\n%@", header.stateLabel.text, header.lastUpdatedTimeLabel.text];
    XCTAssertEqualObjects(view.textLabel.text, expected);
    XCTAssertEqual(header.stateLabel.alpha, 0, @"the label's text is inside the icon's view");
    XCTAssertEqual(header.lastUpdatedTimeLabel.alpha, 0);
    XCTAssertFalse(header.stateLabel.hidden, @"the caller's hidden setting is kept");
    XCTAssertEqualWithAccuracy(header.iconView.center.x, CGRectGetMidX(header.bounds), 0.5, @"icon and text centered as one");
    XCTAssertEqualWithAccuracy(header.iconView.center.y, CGRectGetMidY(header.bounds), 0.5, @"centered in the height");
    XCTAssertTrue(CGRectEqualToRect(view.frame, header.iconView.bounds));
    [view layoutIfNeeded];
    CGRect icon = [header.iconView convertRect:view.imageView.frame fromView:view.imageView.superview];
    CGRect text = [header.iconView convertRect:view.textLabel.frame fromView:view.textLabel.superview];
    XCTAssertTrue(CGSizeEqualToSize(icon.size, CGSizeMake(36, 36)), @"%@", NSStringFromCGRect(icon));
    XCTAssertLessThanOrEqual(CGRectGetMaxX(icon), CGRectGetMinX(text), @"the text follows the icon");
    XCTAssertEqualWithAccuracy(CGRectGetMidY(icon), CGRectGetMidY(text), 0.5, @"icon and text share a center line");
    XCTAssertTrue(CGRectContainsRect(CGRectInset(header.iconView.bounds, -0.5, -0.5), CGRectUnion(icon, text)));
    XCTAssertTrue(header.iconView.isAccessibilityElement, @"VoiceOver reads the text from the view that shows it");
    XCTAssertEqualObjects(header.iconView.accessibilityLabel, expected);
    XCTAssertTrue(header.stateLabel.accessibilityElementsHidden);

    [header setState:CYLRefreshStateRefreshing];
    [self layOut:header];
    XCTAssertEqual(header.iconView.placeholderView, view, @"a new state text updates in place");
    XCTAssertTrue([view.textLabel.text hasPrefix:header.stateLabel.text]);
    [header setState:CYLRefreshStateIdle];

    header.stateLabel.hidden = YES;
    header.lastUpdatedTimeLabel.hidden = YES;
    [self layOut:header];
    XCTAssertEqualWithAccuracy(header.iconView.center.x, CGRectGetMidX(header.bounds), 0.5, @"centered without text");
    XCTAssertTrue(CGSizeEqualToSize(header.iconView.bounds.size, CGSizeMake(36, 36)), @"the icon alone");
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

- (void)testHeaderAndFooterAutoHideCanBeSetSeparatelyOrTogether {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    scrollView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    scrollView.contentSize = CGSizeMake(320, 1000);
    // [EN] Set before attaching: applied when the controls arrive. [CN] 挂上之前设置：控件挂上时生效。
    scrollView.cyl_autoHideRefreshHeader = NO;
    scrollView.cyl_autoHideRefreshFooter = YES;
    CYLRefreshNormalHeader *header = [CYLRefreshNormalHeader headerWithRefreshingBlock:^{}];
    CYLRefreshBackNormalFooter *footer = [CYLRefreshBackNormalFooter footerWithRefreshingBlock:^{}];
    scrollView.cyl_header = header;
    scrollView.cyl_footer = footer;
    XCTAssertFalse(header.autoHideRefresh);
    XCTAssertTrue(footer.autoHideRefresh);
    XCTAssertFalse(scrollView.cyl_autoHideRefresh, @"YES only when both hide");
    [footer layoutIfNeeded];
    scrollView.contentOffset = CGPointMake(0, 0);
    XCTAssertNotNil(footer.layer.mask, @"idle footer below the bottom bar: hidden");
    XCTAssertNil(header.layer.mask, @"header auto-hide is off");
    // [EN] Scrolled to the end and pulled: the footer shows. [CN] 滚到底并上拉：刷新尾显示。
    scrollView.contentOffset = CGPointMake(0, 1000 + 50 - 480 + 30);
    XCTAssertNil(footer.layer.mask, @"pulled into view: shown");
    footer.state = CYLRefreshStateRefreshing;
    XCTAssertNil(footer.layer.mask, @"loading: shown");
    footer.state = CYLRefreshStateIdle;
    scrollView.contentOffset = CGPointMake(0, 0);
    XCTAssertNotNil(footer.layer.mask, @"idle again and out of view: hidden");

    scrollView.cyl_autoHideRefresh = YES;
    XCTAssertTrue(header.autoHideRefresh && footer.autoHideRefresh && scrollView.cyl_autoHideRefresh);
    scrollView.cyl_autoHideRefresh = NO;
    XCTAssertFalse(header.autoHideRefresh || footer.autoHideRefresh);
    XCTAssertNil(footer.layer.mask, @"off: never masked");
    XCTAssertFalse(footer.hidden, @"hidden is never touched");
}

@end
