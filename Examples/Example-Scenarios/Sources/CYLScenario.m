//
//  CYLScenario.m
//  Example-Scenarios
//

#import "CYLScenario.h"
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
    label.text = error.localizedDescription ?: @"Configuration error";
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
        CYLStatic(@"暂无内容 · Empty", @"initWithStyle:message: Empty", @"tray", ^UIView *{
            return CYLMessagePlaceholder(CYLPlaceholderStyleEmpty, CYLPlaceholderMessageEmpty);
        }),
        CYLStatic(@"无搜索结果 · No results", @"SearchOff + NoResults", @"magnifyingglass", ^UIView *{
            return CYLMessagePlaceholder(CYLPlaceholderStyleSearchOff, CYLPlaceholderMessageNoResults);
        }),
        CYLRetry(@"无网络 · No internet", @"NoInternet + retry button", @"wifi.slash", @"重新加载 · Retry", ^UIView *{
            return CYLMessagePlaceholder(CYLPlaceholderStyleNoInternet, CYLPlaceholderMessageNoInternet);
        }),
        CYLRetry(@"服务器不可用 · Server unavailable", @"CloudOff + ServerUnavailable", @"icloud.slash", @"重试 · Retry", ^UIView *{
            return CYLMessagePlaceholder(CYLPlaceholderStyleCloudOff, CYLPlaceholderMessageServerUnavailable);
        }),
        CYLRetry(@"加载失败 · Error", @"ErrorOutline + Error", @"exclamationmark.triangle", @"重试 · Retry", ^UIView *{
            return CYLMessagePlaceholder(CYLPlaceholderStyleErrorOutline, CYLPlaceholderMessageError);
        }),
        CYLStatic(@"加载中 · Loading", @"Hourglass + Loading", @"hourglass", ^UIView *{
            return CYLMessagePlaceholder(CYLPlaceholderStyleHourglass, CYLPlaceholderMessageLoading);
        }),
        CYLRetry(@"无权限 · No permission", @"Locked + NoPermission", @"lock", @"申请权限 · Request access", ^UIView *{
            return CYLMessagePlaceholder(CYLPlaceholderStyleLocked, CYLPlaceholderMessageNoPermission);
        }),
        CYLRetry(@"购物车为空 · Empty cart", @"EmptyCart + EmptyCart", @"cart", @"去逛逛 · Shop now", ^UIView *{
            return CYLMessagePlaceholder(CYLPlaceholderStyleEmptyCart, CYLPlaceholderMessageEmptyCart);
        }),
        CYLStatic(@"暂无通知 · No notifications", @"NotificationsOff + NoNotifications", @"bell.slash", ^UIView *{
            return CYLMessagePlaceholder(CYLPlaceholderStyleNotificationsOff, CYLPlaceholderMessageNoNotifications);
        }),
    ];
    NSArray *business = @[
        CYLRetry(@"定位已关闭 · Location off", @"LocationOff + custom text", @"location.slash", @"打开设置 · Open Settings", ^UIView *{
            return CYLTextPlaceholder(CYLPlaceholderStyleLocationOff, @"开启定位后查看附近内容\nTurn on Location to see nearby places");
        }),
        CYLStatic(@"蓝牙已关闭 · Bluetooth off", @"BluetoothDisabled", @"antenna.radiowaves.left.and.right.slash", ^UIView *{
            return CYLTextPlaceholder(CYLPlaceholderStyleBluetoothDisabled, @"请开启蓝牙以连接设备\nTurn on Bluetooth to connect");
        }),
        CYLStatic(@"账号受限 · Account blocked", @"Blocked", @"nosign", ^UIView *{
            return CYLTextPlaceholder(CYLPlaceholderStyleBlocked, @"该账号暂时无法查看\nThis account is unavailable");
        }),
        CYLStatic(@"内容已删除 · Deleted", @"Delete", @"trash", ^UIView *{
            return CYLTextPlaceholder(CYLPlaceholderStyleDelete, @"内容已被作者删除\nThis post was deleted");
        }),
        CYLRetry(@"图片加载失败 · Broken image", @"BrokenImage", @"photo", @"重新加载 · Reload", ^UIView *{
            return CYLTextPlaceholder(CYLPlaceholderStyleBrokenImage, @"图片加载失败\nThe image could not be loaded");
        }),
        CYLStatic(@"暂无收藏 · No favorites", @"Favorite", @"heart", ^UIView *{
            return CYLTextPlaceholder(CYLPlaceholderStyleFavorite, @"还没有收藏任何内容\nNo favorites yet");
        }),
        CYLStatic(@"暂无订单 · No orders", @"Archive", @"shippingbox", ^UIView *{
            return CYLTextPlaceholder(CYLPlaceholderStyleArchive, @"暂无订单\nNo orders yet");
        }),
        CYLStatic(@"收件箱为空 · Empty inbox", @"Inbox", @"envelope", ^UIView *{
            return CYLTextPlaceholder(CYLPlaceholderStyleInbox, @"收件箱为空\nYour inbox is empty");
        }),
        CYLStatic(@"无浏览记录 · No history", @"History", @"clock.arrow.circlepath", ^UIView *{
            return CYLTextPlaceholder(CYLPlaceholderStyleHistory, @"暂无浏览记录\nNo browsing history");
        }),
        CYLStatic(@"日程已满 · Busy", @"EventBusy", @"calendar.badge.exclamationmark", ^UIView *{
            return CYLTextPlaceholder(CYLPlaceholderStyleEventBusy, @"今天没有可预约的时间\nNo free slots today");
        }),
        CYLStatic(@"自定义图片 · Custom image", @"initWithImage:text:", @"photo.on.rectangle", ^UIView *{
            UIImage *image = [UIImage systemImageNamed:@"moon.zzz"
                                     withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:72]];
            return [[CYLPlaceholderView alloc] initWithImage:image text:@"夜深了，明天再来看看\nCome back tomorrow"];
        }),
        CYLStatic(@"角标 · Badge", @"showBadgeWithStyle:value:", @"app.badge", ^UIView *{
            CYLPlaceholderView *view = [[CYLPlaceholderView alloc] initWithStyle:CYLPlaceholderStyleNotificationsOff
                                                                         message:CYLPlaceholderMessageNoNotifications];
            [view showBadgeWithStyle:CYLPlaceholderBadgeStyleNumber value:@"12"];
            return view;
        }),
        CYLStatic(@"plist 配置 · Property list", @"initWithItemContentsOfURL:", @"doc.text", ^UIView *{
            NSString *bundlePath = [CYLPlaceholderView pathForBundledAnimation:@"CYLPlaceholderLoading.json"];
            NSString *root = bundlePath.stringByDeletingLastPathComponent.stringByDeletingLastPathComponent;
            NSURL *url = root ? [NSURL fileURLWithPath:[root stringByAppendingPathComponent:@"CYLPlaceholderItemDemo.plist"]] : nil;
            NSError *error = nil;
            CYLPlaceholderView *view = url ? [[CYLPlaceholderView alloc] initWithItemContentsOfURL:url imageBundle:nil error:&error] : nil;
            return view ?: CYLConfigurationErrorView(error);
        }),
    ];
    NSArray *flows = @[
        CYLMakeScenario(@"空 / 失败 / 断网 / 有数据切换", @"Switch states (issue #3)", @"arrow.triangle.2.circlepath",
                        CYLScenarioFlowSwitchStates, nil, ^UIView *{
            return CYLMessagePlaceholder(CYLPlaceholderStyleEmpty, CYLPlaceholderMessageEmpty);
        }),
        CYLMakeScenario(@"保留表头 · Keep table header", @"frameForPlaceHolderViewInTableView: (issue #17)", @"rectangle.topthird.inset.filled",
                        CYLScenarioFlowKeepTableHeader, nil, ^UIView *{
            return CYLMessagePlaceholder(CYLPlaceholderStyleSearchOff, CYLPlaceholderMessageNoResults);
        }),
        CYLMakeScenario(@"保留分组头 · Keep section headers", @"Custom frame below section headers (issue #16)", @"list.bullet.indent",
                        CYLScenarioFlowKeepSectionHeaders, nil, ^UIView *{
            return CYLMessagePlaceholder(CYLPlaceholderStyleFolderOpen, CYLPlaceholderMessageEmpty);
        }),
        CYLMakeScenario(@"下拉刷新 + 上拉加载 · Refresh controls", @"CYLRefresh stays above the placeholder (issue #8)", @"arrow.down.circle",
                        CYLScenarioFlowRefreshControls, nil, ^UIView *{
            return CYLMessagePlaceholder(CYLPlaceholderStyleInbox, CYLPlaceholderMessageEmpty);
        }),
        CYLMakeScenario(@"占位时可滚动 · Scrollable", @"enableScrollWhenPlaceHolderViewShowing", @"arrow.up.and.down",
                        CYLScenarioFlowScrollable, nil, ^UIView *{
            return CYLTextPlaceholder(CYLPlaceholderStyleRefresh, @"下拉试试\nPull down to try");
        }),
        CYLMakeScenario(@"UICollectionView 占位", @"cyl_placeholderViewBlock: (issue #11)", @"square.grid.2x2",
                        CYLScenarioFlowCollectionView, nil, ^UIView *{
            return CYLMessagePlaceholder(CYLPlaceholderStylePhotoLibrary, CYLPlaceholderMessageEmpty);
        }),
    ];
    return @[
        @{@"title": @"基础文案 · Built-in messages", @"items": basic},
        @{@"title": @"业务场景 · Real-world cases", @"items": business},
        @{@"title": @"交互流程 · Flows", @"items": flows},
    ];
}

+ (NSArray<NSDictionary *> *)animationSections {
    NSDictionary *legacyRive = @{@"legacy": @"1"};
    NSArray *lottie = @[
        CYLAnimation(@"CYLPlaceholderLoading.json", @"加载中 · Loading", CYLPlaceholderStyleHourglass, nil),
        CYLAnimation(@"CYLPlaceholderLoadingInfinity.json", @"同步中 · Syncing", CYLPlaceholderStyleRefresh, nil),
        CYLAnimation(@"CYLPlaceholderEmpty.json", @"这里什么都没有 · Nothing here", CYLPlaceholderStyleEmpty, nil),
        CYLAnimation(@"CYLPlaceholderEmptyCart.json", @"购物车为空 · Empty cart", CYLPlaceholderStyleEmptyCart, nil),
        CYLAnimation(@"CYLPlaceholderNoDrafts.json", @"暂无草稿 · No drafts", CYLPlaceholderStyleFolderOpen, nil),
        CYLAnimation(@"CYLPlaceholderNoFavorites.json", @"暂无收藏 · No favorites", CYLPlaceholderStyleFavorite, nil),
        CYLAnimation(@"CYLPlaceholderLocation.json", @"正在定位 · Locating", CYLPlaceholderStyleLocationOff, nil),
        CYLAnimation(@"CYLPlaceholderSuccess.json", @"提交成功 · Done", CYLPlaceholderStyleInfo, nil),
        CYLAnimation(@"CYLPlaceholderCelebrate.json", @"全部完成 · All done", CYLPlaceholderStyleInfo, nil),
    ];
    NSArray *pag = @[
        CYLAnimation(@"CYLPlaceholderLoading.pag", @"加载中 · Loading", CYLPlaceholderStyleHourglass, nil),
        CYLAnimation(@"CYLPlaceholderNoFavorites.pag", @"暂无点赞 · No likes", CYLPlaceholderStyleFavorite, nil),
        CYLAnimation(@"CYLPlaceholderPullHint.pag", @"下拉刷新 · Pull to refresh", CYLPlaceholderStyleRefresh, nil),
        CYLAnimation(@"CYLPlaceholderProgress.pag", @"处理中 · Processing", CYLPlaceholderStyleHourglass, nil),
    ];
    NSArray *rive = @[
        CYLAnimation(@"CYLPlaceholderLoading.riv", @"加载中 · Loading", CYLPlaceholderStyleHourglass, legacyRive),
        CYLAnimation(@"CYLPlaceholderPullToRefresh.riv", @"下拉刷新 · Pull to refresh", CYLPlaceholderStyleRefresh, legacyRive),
        CYLAnimation(@"CYLPlaceholderSuccess.riv", @"提交成功 · Done", CYLPlaceholderStyleInfo,
                     @{@"stateMachine": @"State Machine 1"}),
        CYLAnimation(@"CYLPlaceholderNoOrders.riv", @"暂无物流 · No shipments", CYLPlaceholderStyleArchive, legacyRive),
        CYLAnimation(@"CYLPlaceholderNoReviews.riv", @"暂无评价 · No reviews", CYLPlaceholderStyleFavorite, legacyRive),
    ];
    NSArray *gif = @[
        CYLAnimation(@"CYLPlaceholderUploading.gif", @"上传中 · Uploading", CYLPlaceholderStyleUploadOff, nil),
    ];
    return @[
        @{@"title": @"Lottie · CYLTableViewPlaceHolder/LottieSwift", @"items": lottie},
        @{@"title": @"PAG · CYLTableViewPlaceHolder/PAG", @"items": pag},
        @{@"title": @"Rive · CYLTableViewPlaceHolder/Rive", @"items": rive},
        @{@"title": @"GIF · Core", @"items": gif},
    ];
}

+ (CYLScenario *)celebrationScenario {
    return CYLAnimation(@"CYLPlaceholderCelebrate.json", @"发布成功 · Published", CYLPlaceholderStyleInfo, nil);
}

@end
