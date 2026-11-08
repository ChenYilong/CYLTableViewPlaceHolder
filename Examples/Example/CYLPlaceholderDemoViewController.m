#import "CYLPlaceholderDemoViewController.h"
#import "CYLTableViewPlaceHolder.h"

@interface CYLPlaceholderMessageDemoViewController : UITableViewController
@property (nonatomic) CYLPlaceholderStyle style;
@property (nonatomic) BOOL customImage;
@end

@interface CYLPlaceholderStyleDemoViewController : UITableViewController
@end

@implementation CYLPlaceholderStyleDemoViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Placeholder styles";
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return CYLPlaceholderStyleCount + 6;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"style"];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"style"];
    BOOL preset = indexPath.row < CYLPlaceholderStyleCount;
    NSArray *extras = @[@"Custom image", @"FlatDesign: code configuration", @"FlatDesign: plist configuration",
                        @"Badge: dot", @"Badge: number", @"Badge: custom text"];
    cell.textLabel.text = preset ? [CYLPlaceholderView imageNameForStyle:(CYLPlaceholderStyle)indexPath.row] :
        extras[indexPath.row - CYLPlaceholderStyleCount];
    cell.imageView.image = preset ? [CYLPlaceholderView imageForStyle:(CYLPlaceholderStyle)indexPath.row] : nil;
    cell.imageView.tintColor = UIColor.grayColor;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row >= CYLPlaceholderStyleCount + 3) {
        CYLPlaceholderView *placeholder = [[CYLPlaceholderView alloc] initWithStyle:CYLPlaceholderStyleNotificationsOff
            message:CYLPlaceholderMessageNoNotifications];
        NSInteger badgeIndex = indexPath.row - CYLPlaceholderStyleCount - 3;
        if (badgeIndex == 0) [placeholder showBadgeWithStyle:CYLPlaceholderBadgeStyleDot value:nil];
        if (badgeIndex == 1) [placeholder showBadgeWithStyle:CYLPlaceholderBadgeStyleNumber value:@"105"];
        if (badgeIndex == 2) [placeholder showBadgeWithStyle:CYLPlaceholderBadgeStyleText value:@"New"];
        UIViewController *preview = [UIViewController new];
        preview.title = @"Badge preview";
        preview.view.backgroundColor = UIColor.whiteColor;
        placeholder.frame = preview.view.bounds;
        placeholder.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [preview.view addSubview:placeholder];
        [self.navigationController pushViewController:preview animated:YES];
        return;
    }
    if (indexPath.row > CYLPlaceholderStyleCount) {
        NSError *error = nil;
        CYLPlaceholderView *placeholder;
        if (indexPath.row == CYLPlaceholderStyleCount + 1) {
            NSDictionary *attributes = @{CYLPlaceholderItemStyle: @(CYLPlaceholderStyleWarning),
                CYLPlaceholderItemMessage: @(CYLPlaceholderMessageError),
                CYLPlaceholderItemImagePositionAdjustment: @[@8, @(-6)],
                CYLPlaceholderItemTitlePositionAdjustment: @[@0, @6],
                CYLPlaceholderItemAnimationFilePath: @"reserved-animation.json"};
            placeholder = [[CYLPlaceholderView alloc] initWithItemAttributes:attributes imageBundle:nil error:&error];
        } else {
            NSBundle *container = [NSBundle bundleForClass:CYLPlaceholderView.class];
            NSURL *bundleURL = [container URLForResource:@"CYLTableViewPlaceHolder" withExtension:@"bundle"] ?:
                [NSBundle.mainBundle URLForResource:@"CYLTableViewPlaceHolder" withExtension:@"bundle"];
            NSBundle *bundle = bundleURL ? [NSBundle bundleWithURL:bundleURL] : nil;
            NSURL *url = [bundle URLForResource:@"CYLPlaceholderItemDemo" withExtension:@"plist"];
            placeholder = [[CYLPlaceholderView alloc] initWithItemContentsOfURL:url imageBundle:nil error:&error];
        }
        if (!placeholder) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Configuration error"
                message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        UIViewController *preview = [UIViewController new];
        preview.title = @"FlatDesign item";
        preview.view.backgroundColor = UIColor.whiteColor;
        placeholder.frame = preview.view.bounds;
        placeholder.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [preview.view addSubview:placeholder];
        [self.navigationController pushViewController:preview animated:YES];
        return;
    }
    CYLPlaceholderMessageDemoViewController *next = [[CYLPlaceholderMessageDemoViewController alloc] initWithStyle:UITableViewStylePlain];
    next.customImage = indexPath.row == CYLPlaceholderStyleCount;
    next.style = next.customImage ? CYLPlaceholderStyleEmpty : (CYLPlaceholderStyle)indexPath.row;
    [self.navigationController pushViewController:next animated:YES];
}
@end

@implementation CYLPlaceholderMessageDemoViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Choose message";
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return CYLPlaceholderMessageCount + 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"message"];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"message"];
    cell.textLabel.text = indexPath.row == CYLPlaceholderMessageCount ? @"Custom text" :
        [CYLPlaceholderView localizedTextForMessage:(CYLPlaceholderMessage)indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == CYLPlaceholderMessageCount) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Custom text"
            message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *field) {
            field.placeholder = @"Your custom message";
        }];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        __weak typeof(self) weakSelf = self;
        __weak UIAlertController *weakAlert = alert;
        [alert addAction:[UIAlertAction actionWithTitle:@"Preview" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [weakSelf cyl_showPreviewWithText:weakAlert.textFields.firstObject.text message:CYLPlaceholderMessageCount];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    [self cyl_showPreviewWithText:[CYLPlaceholderView localizedTextForMessage:(CYLPlaceholderMessage)indexPath.row]
                         message:(CYLPlaceholderMessage)indexPath.row];
}
- (void)cyl_showPreviewWithText:(NSString *)text message:(CYLPlaceholderMessage)message {
    CYLPlaceholderView *placeholder;
    if (self.customImage) {
        UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(80, 80)];
        UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
            [UIColor.blueColor setFill];
            [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(8, 8, 64, 64)] fill];
        }];
        placeholder = [[CYLPlaceholderView alloc] initWithImage:image text:text];
    } else if (message == CYLPlaceholderMessageCount) {
        placeholder = [[CYLPlaceholderView alloc] initWithStyle:self.style text:text];
    } else {
        placeholder = [[CYLPlaceholderView alloc] initWithStyle:self.style message:message];
    }
    UIViewController *preview = [UIViewController new];
    preview.title = @"Preview";
    preview.view.backgroundColor = UIColor.whiteColor;
    placeholder.frame = preview.view.bounds;
    placeholder.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [preview.view addSubview:placeholder];
    [self.navigationController pushViewController:preview animated:YES];
}
@end

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
    self.navigationItem.leftItemsSupplementBackButton = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Styles"
        style:UIBarButtonItemStylePlain target:self action:@selector(cyl_showStyles)];
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
- (void)cyl_showStyles {
    CYLPlaceholderStyleDemoViewController *styles = [[CYLPlaceholderStyleDemoViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:styles animated:YES];
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
