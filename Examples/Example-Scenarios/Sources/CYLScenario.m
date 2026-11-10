//
//  CYLScenario.m
//  Example-Scenarios
//

#import "CYLScenario.h"
#import "CYLScenarioLocalization.h"
#import <CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.h>

#pragma mark - Placeholder builders

static UIView *CYLMessagePlaceholder(CYLPlaceholderStyle style, CYLPlaceholderMessage message) {
    return [[CYLPlaceholderView alloc] initWithStyle:style message:message];
}

static UIView *CYLTextPlaceholder(CYLPlaceholderStyle style, NSString *text) {
    return [[CYLPlaceholderView alloc] initWithStyle:style text:text];
}

/// Shows a configuration error instead of a placeholder, so a broken scenario is visible in the demo.
static UIView *CYLConfigurationErrorView(NSError *error) {
    UILabel *label = [UILabel new];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = UIColor.systemRedColor;
    label.text = error.localizedDescription ?: CYLScenarioLocalizedString(CYLScenarioL10nTextConfigurationError);
    return label;
}

/// An animation from the library's bundle (CYLTableViewPlaceHolder.bundle/Animations). The style's image is the
/// fallback while the animation loads, or when its engine's subspec is not installed.
static UIView *CYLAnimatedPlaceholder(NSString *fileName, NSString *title, CYLPlaceholderStyle fallback,
                                      NSDictionary<NSString *, id> *options) {
    NSMutableDictionary<NSString *, id> *attributes = [@{
        CYLPlaceholderItemTitle: title,
        CYLPlaceholderItemStyle: @(fallback),
        CYLPlaceholderItemAnimationSize: @[@180, @180],
    } mutableCopy];
    NSString *path = [CYLPlaceholderView pathForBundledAnimation:fileName];
    if (path) attributes[CYLPlaceholderItemAnimationFilePath] = path;
    if (options.count) attributes[CYLPlaceholderItemAnimationOptions] = options;
    NSError *error = nil;
    CYLPlaceholderView *view = [[CYLPlaceholderView alloc] initWithItemAttributes:attributes imageBundle:nil error:&error];
    return view ?: CYLConfigurationErrorView(error);
}

#pragma mark - Scenario factories

static CYLScenario *CYLMakeScenario(NSString *title, NSString *detail, NSString *symbol, CYLScenarioFlow flow,
                                    NSString *actionTitle, UIView *(^make)(void)) {
    CYLScenario *scenario = [CYLScenario new];
    scenario.title = title;
    scenario.detail = detail;
    scenario.symbolName = symbol;
    scenario.flow = flow;
    scenario.actionTitle = actionTitle;
    scenario.makePlaceholder = make;
    return scenario;
}

static CYLScenario *CYLStatic(NSString *title, NSString *detail, NSString *symbol, UIView *(^make)(void)) {
    return CYLMakeScenario(title, detail, symbol, CYLScenarioFlowStatic, nil, make);
}

static CYLScenario *CYLRetry(NSString *title, NSString *detail, NSString *symbol, NSString *action, UIView *(^make)(void)) {
    return CYLMakeScenario(title, detail, symbol, CYLScenarioFlowRetry, action, make);
}

static CYLScenario *CYLAnimation(NSString *fileName, NSString *title, CYLPlaceholderStyle fallback,
                                 NSDictionary<NSString *, id> *options) {
    NSString *symbol = @{@"json": @"wand.and.stars", @"pag": @"sparkles", @"riv": @"circle.hexagongrid",
                         @"gif": @"photo.stack"}[fileName.pathExtension] ?: @"sparkles";
    return CYLMakeScenario(title, fileName, symbol, CYLScenarioFlowAnimation, nil, ^UIView *{
        return CYLAnimatedPlaceholder(fileName, title, fallback, options);
    });
}

@implementation CYLScenario

+ (NSArray<NSDictionary *> *)scenarioSections {
    NSArray *basic = @[
        CYLStatic(CYLScenarioLocalizedString(CYLScenarioL10nTitleEmpty), @"initWithStyle:message: Empty", @"tray", ^UIView *{
            return CYLMessagePlaceholder(CYLPlaceholderStyleEmpty, CYLPlaceholderMessageEmpty);
        }),
        CYLStatic(CYLScenarioLocalizedString(CYLScenarioL10nTitleNoResults), @"SearchOff + NoResults", @"magnifyingglass", ^UIView *{
            return CYLMessagePlaceholder(CYLPlaceholderStyleSearchOff, CYLPlaceholderMessageNoResults);
        }),
        CYLRetry(CYLScenarioLocalizedString(CYLScenarioL10nTitleNoInternet), @"NoInternet + UIButton", @"wifi.slash", CYLScenarioLocalizedString(CYLScenarioL10nActionRetry), ^UIView *{
            return CYLMessagePlaceholder(CYLPlaceholderStyleNoInternet, CYLPlaceholderMessageNoInternet);
        }),
        CYLRetry(CYLScenarioLocalizedString(CYLScenarioL10nTitleServerUnavailable), @"CloudOff + ServerUnavailable", @"icloud.slash", CYLScenarioLocalizedString(CYLScenarioL10nActionRetry), ^UIView *{
            return CYLMessagePlaceholder(CYLPlaceholderStyleCloudOff, CYLPlaceholderMessageServerUnavailable);
        }),
        CYLRetry(CYLScenarioLocalizedString(CYLScenarioL10nTitleError), @"ErrorOutline + Error", @"exclamationmark.triangle", CYLScenarioLocalizedString(CYLScenarioL10nActionRetry), ^UIView *{
            return CYLMessagePlaceholder(CYLPlaceholderStyleErrorOutline, CYLPlaceholderMessageError);
        }),
        CYLStatic(CYLScenarioLocalizedString(CYLScenarioL10nTitleLoading), @"Hourglass + Loading", @"hourglass", ^UIView *{
            return CYLMessagePlaceholder(CYLPlaceholderStyleHourglass, CYLPlaceholderMessageLoading);
        }),
        CYLRetry(CYLScenarioLocalizedString(CYLScenarioL10nTitleNoPermission), @"Locked + NoPermission", @"lock", CYLScenarioLocalizedString(CYLScenarioL10nActionRequestAccess), ^UIView *{
            return CYLMessagePlaceholder(CYLPlaceholderStyleLocked, CYLPlaceholderMessageNoPermission);
        }),
        CYLRetry(CYLScenarioLocalizedString(CYLScenarioL10nTitleEmptyCart), @"EmptyCart + EmptyCart", @"cart", CYLScenarioLocalizedString(CYLScenarioL10nActionShopNow), ^UIView *{
            return CYLMessagePlaceholder(CYLPlaceholderStyleEmptyCart, CYLPlaceholderMessageEmptyCart);
        }),
        CYLStatic(CYLScenarioLocalizedString(CYLScenarioL10nTitleNoNotifications), @"NotificationsOff + NoNotifications", @"bell.slash", ^UIView *{
            return CYLMessagePlaceholder(CYLPlaceholderStyleNotificationsOff, CYLPlaceholderMessageNoNotifications);
        }),
    ];
    NSArray *business = @[
        CYLRetry(CYLScenarioLocalizedString(CYLScenarioL10nTitleLocationOff), @"initWithStyle:text: LocationOff", @"location.slash", CYLScenarioLocalizedString(CYLScenarioL10nActionOpenSettings), ^UIView *{
            return CYLTextPlaceholder(CYLPlaceholderStyleLocationOff, CYLScenarioLocalizedString(CYLScenarioL10nTextLocationOff));
        }),
        CYLStatic(CYLScenarioLocalizedString(CYLScenarioL10nTitleBluetoothOff), @"BluetoothDisabled", @"antenna.radiowaves.left.and.right.slash", ^UIView *{
            return CYLTextPlaceholder(CYLPlaceholderStyleBluetoothDisabled, CYLScenarioLocalizedString(CYLScenarioL10nTextBluetoothOff));
        }),
        CYLStatic(CYLScenarioLocalizedString(CYLScenarioL10nTitleBlocked), @"Blocked", @"nosign", ^UIView *{
            return CYLTextPlaceholder(CYLPlaceholderStyleBlocked, CYLScenarioLocalizedString(CYLScenarioL10nTextBlocked));
        }),
        CYLStatic(CYLScenarioLocalizedString(CYLScenarioL10nTitleDeleted), @"Delete", @"trash", ^UIView *{
            return CYLTextPlaceholder(CYLPlaceholderStyleDelete, CYLScenarioLocalizedString(CYLScenarioL10nTextDeleted));
        }),
        CYLRetry(CYLScenarioLocalizedString(CYLScenarioL10nTitleBrokenImage), @"BrokenImage", @"photo", CYLScenarioLocalizedString(CYLScenarioL10nActionReload), ^UIView *{
            return CYLTextPlaceholder(CYLPlaceholderStyleBrokenImage, CYLScenarioLocalizedString(CYLScenarioL10nTextBrokenImage));
        }),
        CYLStatic(CYLScenarioLocalizedString(CYLScenarioL10nTitleNoFavorites), @"Favorite", @"heart", ^UIView *{
            return CYLTextPlaceholder(CYLPlaceholderStyleFavorite, CYLScenarioLocalizedString(CYLScenarioL10nTextNoFavorites));
        }),
        CYLStatic(CYLScenarioLocalizedString(CYLScenarioL10nTitleNoOrders), @"Archive", @"shippingbox", ^UIView *{
            return CYLTextPlaceholder(CYLPlaceholderStyleArchive, CYLScenarioLocalizedString(CYLScenarioL10nTextNoOrders));
        }),
        CYLStatic(CYLScenarioLocalizedString(CYLScenarioL10nTitleEmptyInbox), @"Inbox", @"envelope", ^UIView *{
            return CYLTextPlaceholder(CYLPlaceholderStyleInbox, CYLScenarioLocalizedString(CYLScenarioL10nTextEmptyInbox));
        }),
        CYLStatic(CYLScenarioLocalizedString(CYLScenarioL10nTitleNoHistory), @"History", @"clock.arrow.circlepath", ^UIView *{
            return CYLTextPlaceholder(CYLPlaceholderStyleHistory, CYLScenarioLocalizedString(CYLScenarioL10nTextNoHistory));
        }),
        CYLStatic(CYLScenarioLocalizedString(CYLScenarioL10nTitleBusy), @"EventBusy", @"calendar.badge.exclamationmark", ^UIView *{
            return CYLTextPlaceholder(CYLPlaceholderStyleEventBusy, CYLScenarioLocalizedString(CYLScenarioL10nTextBusy));
        }),
        CYLStatic(CYLScenarioLocalizedString(CYLScenarioL10nTitleCustomImage), @"initWithImage:text:", @"photo.on.rectangle", ^UIView *{
            UIImage *image = [UIImage systemImageNamed:@"moon.zzz"
                                     withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:72]];
            return [[CYLPlaceholderView alloc] initWithImage:image text:CYLScenarioLocalizedString(CYLScenarioL10nTextCustomImage)];
        }),
        CYLStatic(CYLScenarioLocalizedString(CYLScenarioL10nTitleBadge), @"showBadgeWithStyle:value:", @"app.badge", ^UIView *{
            CYLPlaceholderView *view = [[CYLPlaceholderView alloc] initWithStyle:CYLPlaceholderStyleNotificationsOff
                                                                         message:CYLPlaceholderMessageNoNotifications];
            [view showBadgeWithStyle:CYLPlaceholderBadgeStyleNumber value:@"12"];
            return view;
        }),
        CYLStatic(CYLScenarioLocalizedString(CYLScenarioL10nTitlePlist), @"initWithItemContentsOfURL:", @"doc.text", ^UIView *{
            NSString *bundlePath = [CYLPlaceholderView pathForBundledAnimation:@"CYLPlaceholderLoading.json"];
            NSString *root = bundlePath.stringByDeletingLastPathComponent.stringByDeletingLastPathComponent;
            NSURL *url = root ? [NSURL fileURLWithPath:[root stringByAppendingPathComponent:@"CYLPlaceholderItemDemo.plist"]] : nil;
            NSError *error = nil;
            CYLPlaceholderView *view = url ? [[CYLPlaceholderView alloc] initWithItemContentsOfURL:url imageBundle:nil error:&error] : nil;
            return view ?: CYLConfigurationErrorView(error);
        }),
    ];
    NSArray *flows = @[
        CYLMakeScenario(CYLScenarioLocalizedString(CYLScenarioL10nTitleSwitchStates), @"reloadData #3", @"arrow.triangle.2.circlepath",
                        CYLScenarioFlowSwitchStates, nil, ^UIView *{
            return CYLMessagePlaceholder(CYLPlaceholderStyleEmpty, CYLPlaceholderMessageEmpty);
        }),
        CYLMakeScenario(CYLScenarioLocalizedString(CYLScenarioL10nTitleKeepTableHeader), @"frameForPlaceHolderViewInTableView: #17", @"rectangle.topthird.inset.filled",
                        CYLScenarioFlowKeepTableHeader, nil, ^UIView *{
            return CYLMessagePlaceholder(CYLPlaceholderStyleSearchOff, CYLPlaceholderMessageNoResults);
        }),
        CYLMakeScenario(CYLScenarioLocalizedString(CYLScenarioL10nTitleKeepSectionHeaders), @"rectForHeaderInSection: #16", @"list.bullet.indent",
                        CYLScenarioFlowKeepSectionHeaders, nil, ^UIView *{
            return CYLMessagePlaceholder(CYLPlaceholderStyleFolderOpen, CYLPlaceholderMessageEmpty);
        }),
        CYLMakeScenario(CYLScenarioLocalizedString(CYLScenarioL10nTitleRefreshControls), @"cyl_header + cyl_footer #8", @"arrow.down.circle",
                        CYLScenarioFlowRefreshControls, nil, ^UIView *{
            return CYLMessagePlaceholder(CYLPlaceholderStyleInbox, CYLPlaceholderMessageEmpty);
        }),
        CYLMakeScenario(CYLScenarioLocalizedString(CYLScenarioL10nTitleScrollable), @"enableScrollWhenPlaceHolderViewShowing", @"arrow.up.and.down",
                        CYLScenarioFlowScrollable, nil, ^UIView *{
            return CYLTextPlaceholder(CYLPlaceholderStyleRefresh, CYLScenarioLocalizedString(CYLScenarioL10nTextPullToTry));
        }),
        CYLMakeScenario(CYLScenarioLocalizedString(CYLScenarioL10nTitleCollection), @"cyl_placeholderViewBlock: #11", @"square.grid.2x2",
                        CYLScenarioFlowCollectionView, nil, ^UIView *{
            return CYLMessagePlaceholder(CYLPlaceholderStylePhotoLibrary, CYLPlaceholderMessageEmpty);
        }),
    ];
    return @[
        @{@"title": CYLScenarioLocalizedString(CYLScenarioL10nSectionMessages), @"items": basic},
        @{@"title": CYLScenarioLocalizedString(CYLScenarioL10nSectionCases), @"items": business},
        @{@"title": CYLScenarioLocalizedString(CYLScenarioL10nSectionFlows), @"items": flows},
    ];
}

+ (NSArray<NSDictionary *> *)animationSections {
    NSDictionary *legacyRive = @{@"legacy": @"1"};
    NSArray *lottie = @[
        CYLAnimation(@"CYLPlaceholderLoading.json", CYLScenarioLocalizedString(CYLScenarioL10nTitleLoading), CYLPlaceholderStyleHourglass, nil),
        CYLAnimation(@"CYLPlaceholderLoadingInfinity.json", CYLScenarioLocalizedString(CYLScenarioL10nAnimSyncing), CYLPlaceholderStyleRefresh, nil),
        CYLAnimation(@"CYLPlaceholderEmpty.json", CYLScenarioLocalizedString(CYLScenarioL10nAnimNothingHere), CYLPlaceholderStyleEmpty, nil),
        CYLAnimation(@"CYLPlaceholderEmptyCart.json", CYLScenarioLocalizedString(CYLScenarioL10nTitleEmptyCart), CYLPlaceholderStyleEmptyCart, nil),
        CYLAnimation(@"CYLPlaceholderNoDrafts.json", CYLScenarioLocalizedString(CYLScenarioL10nAnimNoDrafts), CYLPlaceholderStyleFolderOpen, nil),
        CYLAnimation(@"CYLPlaceholderNoFavorites.json", CYLScenarioLocalizedString(CYLScenarioL10nTitleNoFavorites), CYLPlaceholderStyleFavorite, nil),
        CYLAnimation(@"CYLPlaceholderLocation.json", CYLScenarioLocalizedString(CYLScenarioL10nAnimLocating), CYLPlaceholderStyleLocationOff, nil),
        CYLAnimation(@"CYLPlaceholderSuccess.json", CYLScenarioLocalizedString(CYLScenarioL10nAnimDone), CYLPlaceholderStyleInfo, nil),
        CYLAnimation(@"CYLPlaceholderCelebrate.json", CYLScenarioLocalizedString(CYLScenarioL10nAnimAllDone), CYLPlaceholderStyleInfo, nil),
    ];
    NSArray *pag = @[
        CYLAnimation(@"CYLPlaceholderLoading.pag", CYLScenarioLocalizedString(CYLScenarioL10nTitleLoading), CYLPlaceholderStyleHourglass, nil),
        CYLAnimation(@"CYLPlaceholderNoFavorites.pag", CYLScenarioLocalizedString(CYLScenarioL10nAnimNoLikes), CYLPlaceholderStyleFavorite, nil),
        CYLAnimation(@"CYLPlaceholderPullHint.pag", CYLScenarioLocalizedString(CYLScenarioL10nAnimPullToRefresh), CYLPlaceholderStyleRefresh, nil),
        CYLAnimation(@"CYLPlaceholderProgress.pag", CYLScenarioLocalizedString(CYLScenarioL10nAnimProcessing), CYLPlaceholderStyleHourglass, nil),
    ];
    NSArray *rive = @[
        CYLAnimation(@"CYLPlaceholderLoading.riv", CYLScenarioLocalizedString(CYLScenarioL10nTitleLoading), CYLPlaceholderStyleHourglass, legacyRive),
        CYLAnimation(@"CYLPlaceholderPullToRefresh.riv", CYLScenarioLocalizedString(CYLScenarioL10nAnimPullToRefresh), CYLPlaceholderStyleRefresh, legacyRive),
        CYLAnimation(@"CYLPlaceholderSuccess.riv", CYLScenarioLocalizedString(CYLScenarioL10nAnimDone), CYLPlaceholderStyleInfo,
                     @{@"stateMachine": @"State Machine 1"}),
        CYLAnimation(@"CYLPlaceholderNoOrders.riv", CYLScenarioLocalizedString(CYLScenarioL10nAnimNoShipments), CYLPlaceholderStyleArchive, legacyRive),
        CYLAnimation(@"CYLPlaceholderNoReviews.riv", CYLScenarioLocalizedString(CYLScenarioL10nAnimNoReviews), CYLPlaceholderStyleFavorite, legacyRive),
    ];
    NSArray *gif = @[
        CYLAnimation(@"CYLPlaceholderUploading.gif", CYLScenarioLocalizedString(CYLScenarioL10nAnimUploading), CYLPlaceholderStyleUploadOff, nil),
    ];
    return @[
        @{@"title": @"Lottie · CYLTableViewPlaceHolder/LottieSwift", @"items": lottie},
        @{@"title": @"PAG · CYLTableViewPlaceHolder/PAG", @"items": pag},
        @{@"title": @"Rive · CYLTableViewPlaceHolder/Rive", @"items": rive},
        @{@"title": @"GIF · Core", @"items": gif},
    ];
}

+ (CYLScenario *)celebrationScenario {
    return CYLAnimation(@"CYLPlaceholderCelebrate.json", CYLScenarioLocalizedString(CYLScenarioL10nAnimPublished), CYLPlaceholderStyleInfo, nil);
}

@end
