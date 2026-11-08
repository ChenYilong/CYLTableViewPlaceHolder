//  代码地址: https://github.com/ChenYilong/CYLTableViewPlaceHolder
//  CYLCollectionViewController.m
//  Example-objc-02
//
//  Created by MJ Lee on 15/3/6.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "CYLCollectionViewController.h"
#import <CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.h>

static const CGFloat CYLDuration = 0.8;
/**
 * 随机色
 */
#define CYLRandomColor [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1]

@interface CYLCollectionViewController()
/** 存放假数据 */
@property (strong, nonatomic) NSMutableArray *colors;
@property (assign, nonatomic) NSUInteger headerRefreshCount;
@end

@implementation CYLCollectionViewController
#pragma mark - 示例
#pragma mark UICollectionView 上下拉刷新
- (void)example21
{
    // 增加5条假数据
    for (int i = 0; i<30; i++) {
        [self.colors insertObject:CYLRandomColor atIndex:0];
    }
    __weak __typeof(self) weakSelf = self;
    // 下拉刷新
    CYLRefreshNormalHeader *header = [CYLRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.title = @"Header refreshing";
        // 模拟延迟加载数据，因此2秒后才调用（真实开发中，可以移除这段gcd代码）
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(CYLDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.collectionView reloadData];

            // 结束刷新
            [weakSelf.collectionView.cyl_header endRefreshing];
            weakSelf.headerRefreshCount += 1;
            weakSelf.title = [NSString stringWithFormat:@"Header completed %lu", (unsigned long)weakSelf.headerRefreshCount];
        });
    }];
    self.collectionView.cyl_header = header;
    header.isCollectionViewAnimationBug = YES;
    self.collectionView.cyl_footer = [CYLRefreshBackNormalFooter footerWithRefreshingBlock:^{
        weakSelf.title = @"Footer refreshing";
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(CYLDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.collectionView reloadData];
            [weakSelf.collectionView.cyl_footer endRefreshing];
            weakSelf.title = @"Footer completed";
        });
    }];
}

#pragma mark - 数据相关
- (NSMutableArray *)colors
{
    if (!_colors) {
        self.colors = [NSMutableArray array];
    }
    return _colors;
}

#pragma mark - 其他

/**
 *  初始化
 */
- (id)init
{
    // UICollectionViewFlowLayout的初始化（与刷新控件无关）
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(80, 80);
    layout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);
    layout.minimumInteritemSpacing = 20;
    layout.minimumLineSpacing = 20;
    return [self initWithCollectionViewLayout:layout];
}

static NSString *const CYLCollectionViewCellIdentifier = @"color";
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CYLCollectionViewCellIdentifier];
    self.collectionView.backgroundColor = UIColor.whiteColor;
    self.collectionView.accessibilityIdentifier = @"issue1523Collection";
    self.title = @"Collection animation";
    [self example21];
}

#pragma mark - collection数据源代理
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // 设置尾部控件的显示和隐藏
    self.collectionView.cyl_footer.hidden = self.colors.count == 0;
    return self.colors.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CYLCollectionViewCellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = self.colors[indexPath.row];
    cell.isAccessibilityElement = YES;
    cell.accessibilityIdentifier = [NSString stringWithFormat:@"item-%ld", (long)indexPath.row];
    return cell;
}

@end
