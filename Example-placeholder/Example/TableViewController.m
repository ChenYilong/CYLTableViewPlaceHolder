//
//  TableViewController.m
//  Example
//
//  Created by 柯磊 on 2017/2/24.
//  Copyright © 2017年 https://github.com/klaus01 All rights reserved.
//

#import "TableViewController.h"
#import "KLTableViewAndCollectionViewPlaceholder.h"

@interface TableViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray<NSDate *> *dataList;

@end

@implementation TableViewController

static NSString *const kCellReuseIdentifier = @"MYCELL";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataList = [NSMutableArray array];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellReuseIdentifier];
    
    [self.tableView kl_placeholderViewBlock:^UIView * _Nonnull(UITableView * _Nonnull tableView) {
        tableView.scrollEnabled = NO;
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        imageView.image = [UIImage imageNamed:@"warning"];
        
        UILabel *label = [[UILabel alloc] init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.text = @"no data";
        
        UIView *view = [[UIView alloc] init];
        [view addSubview:imageView];
        [view addSubview:label];
        
        [view addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [view addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterY multiplier:1 constant:-25]];
        
        [view addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [view addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:imageView attribute:NSLayoutAttributeBottom multiplier:1 constant:10]];
        
        return view;
    } backToNormalBlock:^(UITableView * _Nonnull tableView) {
        tableView.scrollEnabled = YES;
    }];
}

#pragma mark - actions

- (IBAction)addAction:(id)sender {
    NSInteger count = self.dataList.count;
    [self.dataList addObject:[NSDate date]];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:count inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (IBAction)add2Action:(id)sender {
    [self.tableView beginUpdates];
    
    [self.dataList addObject:[NSDate date]];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.dataList.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.dataList addObject:[NSDate date]];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.dataList.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self.tableView endUpdates];
}

- (IBAction)deleteAction:(id)sender {
    NSInteger count = self.dataList.count;
    if (count > 0) {
        [self.dataList removeLastObject];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (IBAction)clearAction:(id)sender {
    [self.dataList removeAllObjects];
    [self.tableView reloadData];
}

- (IBAction)restoreAction:(id)sender {
    [self.tableView kl_placeholderViewBlock:nil];
}

#pragma mark - table view delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier forIndexPath:indexPath];
    cell.textLabel.text = self.dataList[indexPath.row].description;
    return cell;
}

@end
