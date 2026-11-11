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

- (void)testAnIconAnimationReplacesTheArrowAndSpinnerAtTheSameCenter {
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
    XCTAssertEqualWithAccuracy(header.iconView.center.x, arrowCenter.x, 0.5, @"same layout as the arrow");
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

@end
