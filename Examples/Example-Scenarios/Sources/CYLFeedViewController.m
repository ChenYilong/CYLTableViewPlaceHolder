//
//  CYLFeedViewController.m
//  Example-Scenarios
//

#import "CYLFeedViewController.h"
#import "CYLScenarioLocalization.h"
#import <CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.h>

typedef NS_ENUM(NSInteger, CYLFeedState) {
    CYLFeedStateLoading,
    CYLFeedStateLoaded,
    CYLFeedStateFailed,
};

static NSString *const CYLFeedCellIdentifier = @"feed";

@interface CYLFeedViewController ()
@property (nonatomic) CYLFeedState state;
@property (nonatomic) NSInteger rows;
@property (nonatomic) NSInteger refreshCount;
@end

@implementation CYLFeedViewController

- (instancetype)init {
    return [super initWithStyle:UITableViewStylePlain];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:CYLFeedCellIdentifier];
    self.tableView.tableFooterView = [UIView new];
    __weak typeof(self) weakSelf = self;
    [self.tableView cyl_placeholderViewBlock:^UIView *(UITableView *tableView) {
        return [weakSelf placeholderForState];
    }];
    self.tableView.cyl_header = [CYLRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf refresh];
    }];
    self.tableView.cyl_footer = [CYLRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadMore];
    }];
    [self loadFirstPage];
}

- (UIView *)placeholderForState {
    if (self.state == CYLFeedStateLoading) {
        NSMutableDictionary *attributes = [@{
            CYLPlaceholderItemTitle: [CYLPlaceholderView localizedTextForMessage:CYLPlaceholderMessageLoading] ?: CYLScenarioLocalizedString(CYLScenarioL10nTitleLoading),
            CYLPlaceholderItemStyle: @(CYLPlaceholderStyleHourglass),
            CYLPlaceholderItemAnimationSize: @[@200, @120],
        } mutableCopy];
        NSString *path = [CYLPlaceholderView pathForBundledAnimation:@"CYLPlaceholderLoading.json"];
        if (path) attributes[CYLPlaceholderItemAnimationFilePath] = path;
        return [[CYLPlaceholderView alloc] initWithItemAttributes:attributes imageBundle:nil error:NULL]
            ?: [[CYLPlaceholderView alloc] initWithStyle:CYLPlaceholderStyleHourglass message:CYLPlaceholderMessageLoading];
    }
    CYLPlaceholderView *failed = [[CYLPlaceholderView alloc] initWithStyle:CYLPlaceholderStyleCloudOff
                                                                   message:CYLPlaceholderMessageServerUnavailable];
    failed.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *container = [UIView new];
    container.backgroundColor = UIColor.systemBackgroundColor;
    [container addSubview:failed];
    UIButton *retry = [UIButton buttonWithType:UIButtonTypeSystem];
    UIButtonConfiguration *configuration = [UIButtonConfiguration filledButtonConfiguration];
    configuration.title = CYLScenarioLocalizedString(CYLScenarioL10nActionRetry);
    configuration.cornerStyle = UIButtonConfigurationCornerStyleCapsule;
    retry.configuration = configuration;
    retry.translatesAutoresizingMaskIntoConstraints = NO;
    [retry addTarget:self action:@selector(loadFirstPage) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:retry];
    [NSLayoutConstraint activateConstraints:@[
        [failed.leadingAnchor constraintEqualToAnchor:container.leadingAnchor],
        [failed.trailingAnchor constraintEqualToAnchor:container.trailingAnchor],
        [failed.topAnchor constraintEqualToAnchor:container.topAnchor],
        [failed.bottomAnchor constraintEqualToAnchor:container.bottomAnchor],
        [retry.centerXAnchor constraintEqualToAnchor:container.centerXAnchor],
        [retry.centerYAnchor constraintEqualToAnchor:container.centerYAnchor constant:120],
    ]];
    return container;
}

- (void)loadFirstPage {
    self.state = CYLFeedStateLoading;
    self.rows = 0;
    [self.tableView reloadData];
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.state = CYLFeedStateLoaded;
        weakSelf.rows = 15;
        [weakSelf.tableView.cyl_footer resetNoMoreData];
        [weakSelf.tableView reloadData];
    });
}

/// Every other refresh fails, to show the error placeholder replacing the list.
- (void)refresh {
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        strongSelf.refreshCount += 1;
        BOOL fails = strongSelf.refreshCount % 2 == 1;
        strongSelf.state = fails ? CYLFeedStateFailed : CYLFeedStateLoaded;
        strongSelf.rows = fails ? 0 : 15;
        [strongSelf.tableView.cyl_footer resetNoMoreData];
        [strongSelf.tableView reloadData];
        [strongSelf.tableView.cyl_header endRefreshing];
    });
}

- (void)loadMore {
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        if (strongSelf.rows >= 30) {
            [strongSelf.tableView.cyl_footer endRefreshingWithNoMoreData];
            return;
        }
        strongSelf.rows += 15;
        [strongSelf.tableView reloadData];
        [strongSelf.tableView.cyl_footer endRefreshing];
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CYLFeedCellIdentifier forIndexPath:indexPath];
    UIListContentConfiguration *content = [UIListContentConfiguration subtitleCellConfiguration];
    content.text = [NSString stringWithFormat:CYLScenarioLocalizedString(CYLScenarioL10nFormatPost), (long)indexPath.row + 1];
    content.secondaryText = CYLScenarioLocalizedString(CYLScenarioL10nTextFeedHint);
    content.image = [UIImage systemImageNamed:@"person.crop.circle"];
    cell.contentConfiguration = content;
    return cell;
}

@end
