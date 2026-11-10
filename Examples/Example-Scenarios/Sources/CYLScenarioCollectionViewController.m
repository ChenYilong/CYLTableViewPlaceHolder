//
//  CYLScenarioCollectionViewController.m
//  Example-Scenarios
//

#import "CYLScenarioCollectionViewController.h"
#import "CYLScenarioLocalization.h"
#import <CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.h>

static NSString *const CYLGridCellIdentifier = @"photo";

@interface CYLScenarioCollectionViewController ()
@property (nonatomic, strong) CYLScenario *scenario;
@property (nonatomic) NSInteger items;
@end

@implementation CYLScenarioCollectionViewController

- (instancetype)initWithScenario:(CYLScenario *)scenario {
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake(104, 104);
    layout.minimumInteritemSpacing = 8;
    layout.minimumLineSpacing = 8;
    layout.sectionInset = UIEdgeInsetsMake(12, 12, 12, 12);
    if (self = [super initWithCollectionViewLayout:layout]) {
        _scenario = scenario;
        self.title = scenario.title;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.backgroundColor = UIColor.systemBackgroundColor;
    [self.collectionView registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:CYLGridCellIdentifier];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:CYLScenarioLocalizedString(CYLScenarioL10nActionAdd)
        style:UIBarButtonItemStylePlain target:self action:@selector(toggleItems)];
    __weak typeof(self) weakSelf = self;
    [self.collectionView cyl_placeholderViewBlock:^UIView *(UICollectionView *collectionView) {
        return weakSelf.scenario.makePlaceholder();
    }];
    [self.collectionView reloadData];
}

- (void)toggleItems {
    self.items = self.items > 0 ? 0 : 18;
    self.navigationItem.rightBarButtonItem.title = self.items > 0 ? CYLScenarioLocalizedString(CYLScenarioL10nActionClear) : CYLScenarioLocalizedString(CYLScenarioL10nActionAdd);
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CYLGridCellIdentifier forIndexPath:indexPath];
    CGFloat hue = (CGFloat)(indexPath.item % 12) / 12.0;
    cell.contentView.backgroundColor = [UIColor colorWithHue:hue saturation:0.35 brightness:0.95 alpha:1];
    cell.contentView.layer.cornerRadius = 10;
    return cell;
}

@end
