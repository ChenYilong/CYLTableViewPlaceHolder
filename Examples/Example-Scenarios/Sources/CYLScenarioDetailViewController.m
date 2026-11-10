//
//  CYLScenarioDetailViewController.m
//  Example-Scenarios
//
//  Block API (`cyl_placeholderViewBlock:`) for most flows: the placeholder appears whenever the table is empty, after
//  any reload or row update. The "keep header" and "scrollable" flows use the delegate API (`cyl_reloadData` with
//  `CYLTableViewPlaceHolderDelegate`), which supports a custom frame and scrolling.
//

#import "CYLScenarioDetailViewController.h"
#import "CYLScenarioLocalization.h"
#import <CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.h>

typedef NS_ENUM(NSInteger, CYLDemoState) {
    CYLDemoStateEmpty,
    CYLDemoStateFailed,
    CYLDemoStateOffline,
    CYLDemoStateData,
    CYLDemoStateLoading,
};

static NSString *const CYLDetailCellIdentifier = @"row";

@interface CYLScenarioDetailViewController () <CYLTableViewPlaceHolderDelegate>
@property (nonatomic, strong) CYLScenario *scenario;
@property (nonatomic) CYLDemoState state;
@property (nonatomic) NSInteger rows;
@property (nonatomic, weak) CYLPlaceholderView *animatedPlaceholder;
@property (nonatomic, strong) NSTimer *replayTimer;
@end

@implementation CYLScenarioDetailViewController

- (instancetype)initWithScenario:(CYLScenario *)scenario {
    BOOL grouped = scenario.flow == CYLScenarioFlowKeepSectionHeaders;
    if (self = [super initWithStyle:grouped ? UITableViewStyleInsetGrouped : UITableViewStylePlain]) {
        _scenario = scenario;
        self.title = scenario.title;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:CYLDetailCellIdentifier];
    self.tableView.tableFooterView = [UIView new];
    switch (self.scenario.flow) {
        case CYLScenarioFlowKeepTableHeader:
            [self setUpTableHeader];
            [self.tableView cyl_reloadData];
            break;
        case CYLScenarioFlowKeepSectionHeaders:
            [self.tableView cyl_reloadData];
            break;
        case CYLScenarioFlowScrollable:
            [self setUpRefreshHeaderLegacy:YES];
            [self.tableView cyl_reloadData];
            break;
        case CYLScenarioFlowSwitchStates:
            [self setUpStateSwitcher];
            [self installPlaceholderBlock];
            break;
        case CYLScenarioFlowRefreshControls:
            [self setUpRefreshHeaderLegacy:NO];
            [self setUpRefreshFooter];
            [self installPlaceholderBlock];
            break;
        case CYLScenarioFlowAnimation:
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:CYLScenarioLocalizedString(CYLScenarioL10nActionReplay)
                style:UIBarButtonItemStylePlain target:self action:@selector(replayAnimation)];
            [self installPlaceholderBlock];
            break;
        case CYLScenarioFlowRetry:
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:CYLScenarioLocalizedString(CYLScenarioL10nActionClear)
                style:UIBarButtonItemStylePlain target:self action:@selector(clearRows)];
            [self installPlaceholderBlock];
            break;
        case CYLScenarioFlowStatic:
        case CYLScenarioFlowCollectionView:
            [self installPlaceholderBlock];
            break;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.scenario.flow == CYLScenarioFlowAnimation) {
        // Placeholder animations play once when they appear; replay them so the demo keeps moving.
        self.replayTimer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(replayAnimation)
                                                          userInfo:nil repeats:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.replayTimer invalidate];
    self.replayTimer = nil;
}

- (void)dealloc {
    [_replayTimer invalidate];
}

#pragma mark - Block API

- (void)installPlaceholderBlock {
    __weak typeof(self) weakSelf = self;
    [self.tableView cyl_placeholderViewBlock:^UIView *(UITableView *tableView) {
        return [weakSelf placeholderForCurrentState];
    }];
    [self.tableView reloadData];
}

- (UIView *)placeholderForCurrentState {
    switch (self.state) {
        case CYLDemoStateLoading:
            return [[CYLPlaceholderView alloc] initWithStyle:CYLPlaceholderStyleHourglass message:CYLPlaceholderMessageLoading];
        case CYLDemoStateFailed:
            return [[CYLPlaceholderView alloc] initWithStyle:CYLPlaceholderStyleErrorOutline message:CYLPlaceholderMessageError];
        case CYLDemoStateOffline:
            return [[CYLPlaceholderView alloc] initWithStyle:CYLPlaceholderStyleNoInternet message:CYLPlaceholderMessageNoInternet];
        case CYLDemoStateEmpty:
        case CYLDemoStateData:
            break;
    }
    UIView *placeholder = self.scenario.makePlaceholder();
    if ([placeholder isKindOfClass:CYLPlaceholderView.class]) {
        self.animatedPlaceholder = (CYLPlaceholderView *)placeholder;
    }
    if (!self.scenario.actionTitle) return placeholder;
    return [self container:placeholder withActionTitle:self.scenario.actionTitle];
}

/// The placeholder with a button under it, for retry and "open settings" cases.
- (UIView *)container:(UIView *)placeholder withActionTitle:(NSString *)title {
    UIView *container = [UIView new];
    container.backgroundColor = UIColor.systemBackgroundColor;
    placeholder.translatesAutoresizingMaskIntoConstraints = NO;
    [container addSubview:placeholder];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    UIButtonConfiguration *configuration = [UIButtonConfiguration filledButtonConfiguration];
    configuration.title = title;
    configuration.cornerStyle = UIButtonConfigurationCornerStyleCapsule;
    button.configuration = configuration;
    button.accessibilityIdentifier = @"placeholderAction";
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button addTarget:self action:@selector(performAction) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:button];
    [NSLayoutConstraint activateConstraints:@[
        [placeholder.leadingAnchor constraintEqualToAnchor:container.leadingAnchor],
        [placeholder.trailingAnchor constraintEqualToAnchor:container.trailingAnchor],
        [placeholder.topAnchor constraintEqualToAnchor:container.topAnchor],
        [placeholder.bottomAnchor constraintEqualToAnchor:container.bottomAnchor],
        [button.centerXAnchor constraintEqualToAnchor:container.centerXAnchor],
        [button.centerYAnchor constraintEqualToAnchor:container.centerYAnchor constant:120],
    ]];
    return container;
}

- (void)performAction {
    self.state = CYLDemoStateLoading;
    [self.tableView reloadData];
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.state = CYLDemoStateData;
        weakSelf.rows = 12;
        [weakSelf.tableView reloadData];
    });
}

- (void)clearRows {
    self.state = CYLDemoStateEmpty;
    self.rows = 0;
    [self.tableView reloadData];
}

- (void)replayAnimation {
    [self.animatedPlaceholder playPlaceholderAnimation];
}

#pragma mark - Switch states (issue #3)

- (void)setUpStateSwitcher {
    UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:@[CYLScenarioLocalizedString(CYLScenarioL10nStateEmpty), CYLScenarioLocalizedString(CYLScenarioL10nStateFailed),
        CYLScenarioLocalizedString(CYLScenarioL10nStateOffline), CYLScenarioLocalizedString(CYLScenarioL10nStateData)]];
    control.selectedSegmentIndex = 0;
    control.accessibilityIdentifier = @"stateSwitcher";
    [control addTarget:self action:@selector(stateChanged:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = control;
}

- (void)stateChanged:(UISegmentedControl *)control {
    self.state = (CYLDemoState)control.selectedSegmentIndex;
    self.rows = self.state == CYLDemoStateData ? 12 : 0;
    // Each empty reload asks the block again, so the same table switches between different placeholders.
    [self.tableView reloadData];
}

#pragma mark - Refresh controls (issue #8)

- (void)setUpRefreshHeaderLegacy:(BOOL)legacy {
    __weak typeof(self) weakSelf = self;
    self.tableView.cyl_header = [CYLRefreshNormalHeader headerWithRefreshingBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            strongSelf.rows = strongSelf.rows > 0 ? 0 : 12;
            [strongSelf.tableView.cyl_footer resetNoMoreData];
            if (legacy) {
                [strongSelf.tableView cyl_reloadData];
            } else {
                [strongSelf.tableView reloadData];
            }
            [strongSelf.tableView.cyl_header endRefreshing];
        });
    }];
}

- (void)setUpRefreshFooter {
    __weak typeof(self) weakSelf = self;
    self.tableView.cyl_footer = [CYLRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.tableView.cyl_footer endRefreshingWithNoMoreData];
        });
    }];
}

#pragma mark - Delegate API (issues #16, #17)

- (void)setUpTableHeader {
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 56)];
    searchBar.placeholder = CYLScenarioLocalizedString(CYLScenarioL10nSearchPlaceholder);
    self.tableView.tableHeaderView = searchBar;
}

- (UIView *)makePlaceHolderView {
    return self.scenario.makePlaceholder();
}

- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return self.scenario.flow == CYLScenarioFlowScrollable;
}

- (CGRect)frameForPlaceHolderViewInTableView:(UITableView *)tableView {
    CGFloat top = 0;
    if (self.scenario.flow == CYLScenarioFlowKeepTableHeader) {
        top = CGRectGetMaxY(tableView.tableHeaderView.frame);
    } else if (self.scenario.flow == CYLScenarioFlowKeepSectionHeaders) {
        NSInteger lastSection = [tableView numberOfSections] - 1;
        top = lastSection >= 0 ? CGRectGetMaxY([tableView rectForHeaderInSection:lastSection]) : 0;
    }
    return CGRectMake(0, top, CGRectGetWidth(tableView.bounds), MAX(0, CGRectGetHeight(tableView.bounds) - top));
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.scenario.flow == CYLScenarioFlowKeepSectionHeaders ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.scenario.flow != CYLScenarioFlowKeepSectionHeaders) return nil;
    return section == 0 ? CYLScenarioLocalizedString(CYLScenarioL10nSectionPinned) : CYLScenarioLocalizedString(CYLScenarioL10nSectionAll);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CYLDetailCellIdentifier forIndexPath:indexPath];
    UIListContentConfiguration *content = [UIListContentConfiguration cellConfiguration];
    content.text = [NSString stringWithFormat:CYLScenarioLocalizedString(CYLScenarioL10nFormatItem), (long)indexPath.row + 1];
    content.image = [UIImage systemImageNamed:@"doc.text"];
    cell.contentConfiguration = content;
    return cell;
}

@end
