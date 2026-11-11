#import <XCTest/XCTest.h>
#import "CYLRefresh.h"
#import "CYLRefreshIconView.h"
#import "CYLPlaceholderView.h"

/// The animated icon of the refresh controls (CYLRefreshIconView): the controls keep their arrow, spinner and GIF view
/// until an icon animation is set; then the icon takes their place with the same layout and plays by a fixed policy.
@interface CYLRefreshIconTests : XCTestCase
@end

@implementation CYLRefreshIconTests

- (UIScrollView *)scrollViewWithHeader:(CYLRefreshHeader *)header footer:(CYLRefreshFooter *)footer {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    scrollView.contentSize = CGSizeMake(320, 1000);
    scrollView.cyl_header = header;
    scrollView.cyl_footer = footer;
    return scrollView;
}

- (void)layOut:(CYLRefreshComponent *)component {
    component.frame = CGRectMake(0, 0, 320, 54);
    [component setNeedsLayout];
    [component layoutIfNeeded];
}

- (void)testWithoutAnIconAnimationTheControlIsUnchanged {
    CYLRefreshNormalHeader *header = [CYLRefreshNormalHeader headerWithRefreshingBlock:^{}];
    [self layOut:header];
    XCTAssertFalse(header.usesIconView);
    XCTAssertFalse(header.arrowView.hidden);
    for (UIView *subview in header.subviews) {
        XCTAssertFalse([subview isKindOfClass:CYLRefreshIconView.class], @"no icon view until an animation is set");
    }
    [header setIconAnimationAttributes:nil forState:CYLRefreshStateIdle];
    XCTAssertFalse(header.usesIconView, @"removing nothing creates nothing");
}

- (void)testAnIconAnimationReplacesTheArrowAndSpinnerKeepingTheirGap {
    CYLRefreshNormalHeader *header = [CYLRefreshNormalHeader headerWithRefreshingBlock:^{}];
    [self layOut:header];
    CGPoint arrowCenter = header.arrowView.center;
    [header setBundledIconAnimation:@"CYLPlaceholderLoading.json" size:CGSizeMake(36, 36) forState:CYLRefreshStateIdle];
    [self layOut:header];
    XCTAssertTrue(header.usesIconView);
    XCTAssertEqual(header.iconView.superview, header);
    XCTAssertFalse(header.iconView.hidden);
    XCTAssertTrue(header.arrowView.hidden);
    XCTAssertTrue(header.loadingView.hidden);
    CGFloat replaced = MAX(header.arrowView.image.size.width, CGRectGetWidth(header.loadingView.bounds));
    XCTAssertEqualWithAccuracy(CGRectGetMaxX(header.iconView.frame), arrowCenter.x + replaced * 0.5, 0.5,
                               @"a wider icon keeps the arrow's gap to the text, growing away from it");
    XCTAssertEqualWithAccuracy(header.iconView.center.y, arrowCenter.y, 0.5);
    XCTAssertTrue(CGSizeEqualToSize(header.iconView.bounds.size, CGSizeMake(36, 36)));
    XCTAssertNotNil(header.iconView.placeholderView, @"the icon is drawn by the library's icon component");
    XCTAssertTrue(header.iconView.accessibilityElementsHidden, @"decorative: the state label speaks");
    // [EN] Refreshing does not bring the spinner back. [CN] 刷新时不会重新显示菊花。
    header.state = CYLRefreshStateRefreshing;
    XCTAssertTrue(header.loadingView.hidden);
    XCTAssertFalse(header.loadingView.isAnimating);
    XCTAssertTrue(header.arrowView.hidden);
}

- (void)testThePlaybackFollowsTheControlState {
    CYLRefreshNormalHeader *header = [CYLRefreshNormalHeader headerWithRefreshingBlock:^{}];
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

- (void)testFootersShowTheIconWhenTheirSpinnerWouldShow {
    CYLRefreshAutoNormalFooter *autoFooter = [CYLRefreshAutoNormalFooter footerWithRefreshingBlock:^{}];
    [autoFooter setBundledIconAnimation:@"CYLPlaceholderLoading.json" size:CGSizeMake(24, 24) forState:CYLRefreshStateIdle];
    [self layOut:autoFooter];
    XCTAssertTrue(autoFooter.iconView.hidden, @"an auto footer shows its spinner only while loading");
    autoFooter.state = CYLRefreshStateRefreshing;
    XCTAssertFalse(autoFooter.iconView.hidden);
    XCTAssertTrue(autoFooter.loadingView.hidden);
    autoFooter.state = CYLRefreshStateNoMoreData;
    XCTAssertTrue(autoFooter.iconView.hidden);

    CYLRefreshBackNormalFooter *backFooter = [CYLRefreshBackNormalFooter footerWithRefreshingBlock:^{}];
    [backFooter setBundledIconAnimation:@"CYLPlaceholderLoading.json" size:CGSizeMake(24, 24) forState:CYLRefreshStateIdle];
    [self layOut:backFooter];
    XCTAssertFalse(backFooter.iconView.hidden);
    XCTAssertTrue(backFooter.arrowView.hidden);
    backFooter.state = CYLRefreshStateNoMoreData;
    XCTAssertTrue(backFooter.iconView.hidden, @"no more data shows the text only, as before");
}

- (void)testGifControlsKeepTheirImagesAPIAndAcceptAnIconAnimation {
    CYLRefreshGifHeader *header = [CYLRefreshGifHeader headerWithRefreshingBlock:^{}];
    UIImage *image = [CYLPlaceholderView imageForStyle:CYLPlaceholderStyleRefresh];
    XCTAssertEqual([header setImages:@[image] forState:CYLRefreshStateIdle], header, @"the GIF API is unchanged");
    [header setBundledIconAnimation:@"CYLPlaceholderUploading.gif" size:CGSizeMake(40, 40) forState:CYLRefreshStateIdle];
    [self layOut:header];
    XCTAssertTrue(header.gifView.hidden);
    XCTAssertFalse(header.iconView.hidden);
    XCTAssertLessThanOrEqual(CGRectGetMaxX(header.iconView.frame), CGRectGetMaxX(header.gifView.frame) + 0.5,
                             @"right-aligned in the GIF view's area, next to the text");
}

- (void)testMissingBundledAnimationsAreIgnored {
    CYLRefreshNormalTrailer *trailer = [CYLRefreshNormalTrailer trailerWithRefreshingBlock:^{}];
    [trailer setBundledIconAnimation:@"Missing.json" size:CGSizeMake(20, 20) forState:CYLRefreshStateIdle];
    XCTAssertFalse(trailer.usesIconView);
    [trailer setIconAnimationFilePath:@"" size:CGSizeMake(20, 20) forState:CYLRefreshStateIdle];
    XCTAssertFalse(trailer.usesIconView);
}

- (void)testEveryBundledRefreshAnimationBuildsAnIcon {
    NSArray<NSString *> *names = CYLRefreshComponent.bundledIconAnimationFileNames;
    NSUInteger refreshFiles = 0;
    for (NSString *name in names) {
        if ([name hasPrefix:@"CYLRefresh"]) refreshFiles++;
        CYLRefreshNormalHeader *header = [CYLRefreshNormalHeader headerWithRefreshingBlock:^{}];
        [header setBundledIconAnimation:name size:CGSizeMake(32, 32) forState:CYLRefreshStateIdle];
        XCTAssertTrue(header.usesIconView, @"%@", name);
        NSDictionary *attributes = [header.iconView animationAttributesForState:CYLRefreshStateIdle];
        XCTAssertEqualObjects([attributes[CYLPlaceholderItemAnimationFilePath] lastPathComponent], name);
    }
    XCTAssertEqual(refreshFiles, 13u, @"%@", names);
    XCTAssertTrue([names containsObject:@"CYLPlaceholderLoading.pag"], @"PAG comes from the placeholder set");
    for (NSString *extension in @[@"gif", @"json", @"pag", @"riv"]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pathExtension == %@", extension];
        NSUInteger count = [names filteredArrayUsingPredicate:predicate].count;
        XCTAssertGreaterThan(count, 0u, @"%@", extension);
    }
    CYLRefreshNormalHeader *header = [CYLRefreshNormalHeader headerWithRefreshingBlock:^{}];
    [header setBundledIconAnimation:@"CYLRefreshCheck.riv" size:CGSizeMake(32, 32) forState:CYLRefreshStateIdle];
    NSDictionary *options = [header.iconView animationAttributesForState:CYLRefreshStateIdle][CYLPlaceholderItemAnimationOptions];
    XCTAssertEqualObjects(options[@"animation"], @"Loading", @"the bundled Rive file brings its options");
}

- (void)testIconsNeverOverlapTheTextAndDrawInsideTheirFrame {
    // Regression: the component's 16-point placeholder margins left a zero-width item inside a 30-point icon, so the
    // animation started at the icon's center and covered "Last update…".
    for (NSString *name in @[@"CYLRefreshArrows.gif", @"CYLRefreshDots.json", @"CYLPlaceholderLoading.json"]) {
        CYLRefreshNormalHeader *header = [CYLRefreshNormalHeader headerWithRefreshingBlock:^{}];
        [header setBundledIconAnimation:name size:CGSizeMake(48, 32) forState:CYLRefreshStateIdle];
        [self layOut:header];
        CGFloat textWidth = MAX(header.stateLabel.cyl_textWidth, header.lastUpdatedTimeLabel.cyl_textWidth);
        CGFloat textStart = header.cyl_w * 0.5 - textWidth * 0.5;
        XCTAssertLessThan(CGRectGetMaxX(header.iconView.frame), textStart, @"%@ overlaps the text", name);
        CYLPlaceholderView *view = header.iconView.placeholderView;
        XCTAssertEqualWithAccuracy(view.contentMargin, 0, 0.01);
        [view layoutIfNeeded];
        UIView *drawn = view.imageView.superview;
        XCTAssertGreaterThan(CGRectGetWidth(drawn.frame), 0, @"%@: the item has room", name);
        // Core decodes GIF itself; Lottie needs its subspec, absent from this test bundle, so it shows a fallback.
        if ([name.pathExtension isEqualToString:@"gif"]) {
            CGRect content = [header.iconView convertRect:drawn.frame fromView:drawn.superview];
            CGRect frame = CGRectInset(header.iconView.bounds, -0.5, -0.5);
            XCTAssertTrue(CGRectContainsRect(frame, content), @"%@: %@", name, NSStringFromCGRect(content));
        }
    }
    CYLRefreshNormalTrailer *trailer = [CYLRefreshNormalTrailer trailerWithRefreshingBlock:^{}];
    [trailer setBundledIconAnimation:@"CYLRefreshSpinner.json" size:CGSizeMake(40, 40) forState:CYLRefreshStateIdle];
    trailer.frame = CGRectMake(0, 0, 80, 300);
    [trailer setNeedsLayout];
    [trailer layoutIfNeeded];
    XCTAssertFalse(trailer.stateLabel.hidden);
    CGFloat iconRight = CGRectGetMaxX(trailer.iconView.frame);
    XCTAssertLessThanOrEqual(iconRight, CGRectGetMinX(trailer.stateLabel.frame) + 0.5,
                             @"the trailer's text moves over by the icon's extra width");
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
