//
//  ViewController.m
//  CYLNoResultTableViewController
//
//  Created by 微博@iOS程序犭袁 (http://weibo.com/luohanchenyilong/) on 15/12/22.
//  Copyright © 2015年 https://github.com/ChenYilong . All rights reserved.
//

#import "ViewController.h"
#import "MJRefresh.h"
#import "XTNetReloader.h"
#import "WeChatStylePlaceHolder.h"

static const CGFloat CYLDuration = 1.0;
#define CYLRandomData [NSString stringWithFormat:@"随机数据---%d", arc4random_uniform(1000000)]

@interface ViewController ()<CYLTableViewPlaceHolderDelegate, WeChatStylePlaceHolderDelegate>
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, assign, getter=isNoResult) BOOL noResult;

@end

@implementation ViewController

/**
 *  lazy load dataSource
 *
 *  @return NSMutableArray
 */
- (NSMutableArray *)dataSource {
    if (_dataSource == nil) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

- (BOOL)isNoResult {
    _noResult = (self.dataSource.count == 0);
    return _noResult;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"CYLTableViewPlaceHolder";
    self.tableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    self.view.backgroundColor = [UIColor yellowColor];
    self.dataSource = nil;
    [self setUpMJRefresh];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.tableView cyl_reloadData];
}

- (void)setUpMJRefresh {
    __unsafe_unretained __typeof(self) weakSelf = self;
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadNewData];
    }];
    
    // 马上进入刷新状态
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", @"Random Data", self.dataSource[indexPath.row]];
    return cell;
}

#pragma mark - 下拉刷新数据

- (void)loadNewData {
    if (!self.isNoResult) {
        self.dataSource = nil;
    } else {
        // 1.添加假数据
        for (int i = 0; i<5; i++) {
            [self.dataSource insertObject:CYLRandomData atIndex:0];
        }
    }
    // 2.模拟2秒后刷新表格UI（真实开发中，可以移除这段gcd代码）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(CYLDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 刷新表格
        [self.tableView cyl_reloadData];
        // 拿到当前的下拉刷新控件，结束刷新状态
        [self.tableView.mj_header endRefreshing];
    });
}

#pragma mark - CYLTableViewPlaceHolderDelegate Method

- (UIView *)makePlaceHolderView {
    UIView *taobaoStyle = [self taoBaoStylePlaceHolder];
    UIView *weChatStyle = [self weChatStylePlaceHolder];
    return (arc4random_uniform(2)==0)?taobaoStyle:weChatStyle;
}

- (UIView *)taoBaoStylePlaceHolder {
    __block XTNetReloader *netReloader = [[XTNetReloader alloc] initWithFrame:CGRectMake(0, 0, 0, 0)
                                                                  reloadBlock:^{
                                                                      [self.tableView.mj_header beginRefreshing];
                                                                  }] ;
    return netReloader;
}

- (UIView *)weChatStylePlaceHolder {
    WeChatStylePlaceHolder *weChatStylePlaceHolder = [[WeChatStylePlaceHolder alloc] initWithFrame:self.tableView.frame];
    weChatStylePlaceHolder.delegate = self;
    return weChatStylePlaceHolder;
}

//- (BOOL)enableScrollWhenPlaceHolderViewShowing {
//    return YES;
//}

#pragma mark - WeChatStylePlaceHolderDelegate Method

- (void)emptyOverlayClicked:(id)sender {
    [self.tableView.mj_header beginRefreshing];
}

@end
