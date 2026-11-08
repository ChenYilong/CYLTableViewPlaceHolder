#import "CYLPlaceholderDemoViewController.h"
#import "CYLTableViewPlaceHolder.h"

@interface CYLPlaceholderDemoViewController () <UITableViewDataSource, UICollectionViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic) NSInteger count;
@property (nonatomic) BOOL placeholderEnabled;
@end

@implementation CYLPlaceholderDemoViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Automatic placeholder";
    self.view.backgroundColor = UIColor.whiteColor;
    UISegmentedControl *mode = [[UISegmentedControl alloc] initWithItems:@[@"Table", @"Collection"]];
    mode.selectedSegmentIndex = 0;
    [mode addTarget:self action:@selector(cyl_changeMode:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = mode;
    self.navigationItem.rightBarButtonItems = @[
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(cyl_add)],
        [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(cyl_clear)],
        [[UIBarButtonItem alloc] initWithTitle:@"Disable" style:UIBarButtonItemStylePlain target:self action:@selector(cyl_togglePlaceholder:)]
    ];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake(100, 100);
    layout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.backgroundColor = UIColor.whiteColor;
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:@"cell"];
    self.collectionView.hidden = YES;
    [self.view addSubview:self.collectionView];

    self.placeholderEnabled = YES;
    [self cyl_enablePlaceholder];
    [self.tableView reloadData];
    [self.collectionView reloadData];
}
- (void)cyl_enablePlaceholder {
    [self.tableView cyl_placeholderViewBlock:^UIView *(UITableView *tableView) {
        return [CYLPlaceholderView new];
    }];
    [self.collectionView cyl_placeholderViewBlock:^UIView *(UICollectionView *collectionView) {
        return [CYLPlaceholderView new];
    }];
}
- (void)cyl_togglePlaceholder:(UIBarButtonItem *)sender {
    self.placeholderEnabled = !self.placeholderEnabled;
    sender.title = self.placeholderEnabled ? @"Disable" : @"Enable";
    if (self.placeholderEnabled) {
        [self cyl_enablePlaceholder];
    } else {
        [self.tableView cyl_placeholderViewBlock:nil];
        [self.collectionView cyl_placeholderViewBlock:nil];
    }
}
- (void)cyl_changeMode:(UISegmentedControl *)sender {
    self.tableView.hidden = sender.selectedSegmentIndex != 0;
    self.collectionView.hidden = sender.selectedSegmentIndex == 0;
}
- (void)cyl_add {
    NSInteger index = self.count++;
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
}
- (void)cyl_clear {
    self.count = 0;
    [self.tableView reloadData];
    [self.collectionView reloadData];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return self.count; }
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.textLabel.text = [NSString stringWithFormat:@"Item %ld", (long)indexPath.row + 1];
    return cell;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section { return self.count; }
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = UIColor.lightGrayColor;
    return cell;
}
@end
