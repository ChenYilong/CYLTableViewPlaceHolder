#import "CYLPagingViewController.h"
#import <CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.h>

@interface CYLPagingViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (assign, nonatomic) NSInteger rowCount;
@end

@implementation CYLPagingViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Paging";
    self.rowCount = 8;
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.tableView.pagingEnabled = YES;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.accessibilityIdentifier = @"pagingTable";
    [self.view addSubview:self.tableView];
    __weak typeof(self) weakSelf = self;
    self.tableView.cyl_header = [CYLRefreshNormalHeader headerWithRefreshingBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            typeof(self) self = weakSelf;
            if (!self) return;
            self.rowCount++;
            [self.tableView reloadData];
            [self.tableView layoutIfNeeded];
            [self.tableView setContentOffset:CGPointMake(0, 2 * self.tableView.bounds.size.height) animated:NO];
            [self.tableView.cyl_header endRefreshingWithCompletionBlock:^{
                weakSelf.title = @"Refresh completed";
            }];
        });
    }];
    self.tableView.cyl_footer = [CYLRefreshBackNormalFooter footerWithRefreshingBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            typeof(self) self = weakSelf;
            if (!self) return;
            self.rowCount++;
            [self.tableView reloadData];
            [self.tableView layoutIfNeeded];
            [self.tableView.cyl_footer endRefreshingWithCompletionBlock:^{
                weakSelf.title = @"Load completed";
            }];
        });
    }];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Refresh"
        style:UIBarButtonItemStylePlain target:self action:@selector(cyl_startRefresh)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Last page"
        style:UIBarButtonItemStylePlain target:self action:@selector(cyl_showLastPage)];
}

- (void)cyl_startRefresh {
    [self.tableView.cyl_header beginRefreshing];
}

- (void)cyl_showLastPage {
    [self.tableView setContentOffset:CGPointMake(0, (self.rowCount - 1) * self.tableView.bounds.size.height)
                           animated:NO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rowCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableView.bounds.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"page"];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"page"];
    cell.textLabel.text = [NSString stringWithFormat:@"Page %ld", (long)indexPath.row];
    cell.accessibilityIdentifier = [NSString stringWithFormat:@"page-%ld", (long)indexPath.row];
    return cell;
}
@end
