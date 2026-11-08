//
//  CollectionViewController.m
//  Example
//
//  Created by 柯磊 on 2017/2/24.
//  Copyright © 2017年 https://github.com/klaus01 All rights reserved.
//

#import "CollectionViewController.h"
#import "KLTableViewAndCollectionViewPlaceholder.h"

@interface CollectionViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) UIView *placeholderView;

@property (nonatomic, strong) NSMutableArray<NSArray<UIColor *> *> *dataList;
@end

@implementation CollectionViewController

static NSString *const kCellReuseIdentifier = @"MYCELL";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataList = [NSMutableArray array];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCellReuseIdentifier];
    
    __weak typeof(self) weakself = self;
    [self.collectionView kl_placeholderViewBlock:^UIView * _Nonnull(UICollectionView * _Nonnull collectionView) {
        return weakself.placeholderView;
    }];
}

- (UIView *)placeholderView {
    if (!_placeholderView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        imageView.image = [UIImage imageNamed:@"warning"];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [button setTitle:@"reload" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(reloadButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *view = [[UIView alloc] init];
        [view addSubview:imageView];
        [view addSubview:button];
        
        [view addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [view addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterY multiplier:1 constant:-25]];
        
        [view addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [view addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:imageView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        [view addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:44]];
        
        _placeholderView = view;
    }
    return _placeholderView;
}

#pragma mark - private methods

- (void)_addData {
    NSInteger count = (arc4random() % 5) + 5;
    NSMutableArray<UIColor *> *colors = [NSMutableArray arrayWithCapacity:count];
    for (NSInteger i = 0; i < count; i++) {
        CGFloat r = (arc4random() % 1000) / 1000.0;
        CGFloat g = (arc4random() % 1000) / 1000.0;
        CGFloat b = (arc4random() % 1000) / 1000.0;
        [colors addObject:[UIColor colorWithRed:r green:g blue:b alpha:1.0]];
    }
    [self.dataList addObject:colors];
}

#pragma mark - actions

- (IBAction)addAction:(id)sender {
    [self _addData];
    [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:self.dataList.count - 1]];
}

- (IBAction)add2Action:(id)sender {
    [self.collectionView performBatchUpdates:^{
        [self _addData];
        [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:self.dataList.count - 1]];
        [self _addData];
        [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:self.dataList.count - 1]];
    } completion:^(BOOL finished) {
        NSLog(@"performBatchUpdates completion");
    }];
}

- (IBAction)deleteAction:(id)sender {
    NSInteger count = self.dataList.count;
    if (count > 0) {
        [self.dataList removeLastObject];
        [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:count - 1]];
    }
}

- (IBAction)clearAction:(id)sender {
    [self.dataList removeAllObjects];
    [self.collectionView reloadData];
}

- (IBAction)restoreAction:(id)sender {
    [self.collectionView kl_placeholderViewBlock:nil];
}

- (void)reloadButtonAction:(id)sender {
    [self _addData];
    [self _addData];
    [self.collectionView reloadData];
}

#pragma mark - collection view delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.dataList.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataList[section].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellReuseIdentifier forIndexPath:indexPath];
    cell.contentView.backgroundColor = self.dataList[indexPath.section][indexPath.item];
    return cell;
}

@end
