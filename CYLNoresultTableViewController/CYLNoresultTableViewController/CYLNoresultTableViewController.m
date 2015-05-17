//
//  CYLNoresultTableViewController.h
//
//  Created by https://github.com/ChenYilong on 14/12/24.
//  Copyright (c) 2015年 http://weibo.com/luohanchenyilong/ . All rights reserved.
//

static float const kUIemptyOverlayLabelX         = 0;
static float const kUIemptyOverlayLabelY         = 0;
static float const kUIemptyOverlayLabel2Upstairs = 10;
static float const kUIemptyOverlayLabelWidth     = [UIScreen mainScreen].bounds.size.width;
static float const kUIemptyOverlayLabelHeight    = 20;


#import "CYLNoresultTableViewController.h"
@interface CYLNoresultTableViewController ()
{
    BOOL hasAppeared;
    BOOL scrollWasEnabled;
    UIImageView *_emptyOverlayImageView;
}
@end

@implementation CYLNoresultTableViewController


- (void)viewWillAppear:(BOOL)animated
{
    [self reloadData];
    [super viewWillAppear: animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    hasAppeared = YES;
    
    [super viewDidAppear: animated];
    
    [self checkEmpty];
}

- (void)viewDidUnload
{
    if (_emptyOverlay)
    {
        self.tableView.scrollEnabled = scrollWasEnabled;
        [_emptyOverlay removeFromSuperview];
        _emptyOverlay = nil;
    }
}

- (void) reloadData
{
    [self.tableView reloadData];
    
    if (hasAppeared &&
        [self respondsToSelector: @selector(emptyOverlay)])
        [self checkEmpty];
}

- (void) checkEmpty
{
    BOOL isEmpty = YES;
    
    id<UITableViewDataSource> src = self.tableView.dataSource;
    NSInteger sections = 1;
    if ([src respondsToSelector: @selector(numberOfSectionsInTableView:)])
        sections = [src numberOfSectionsInTableView: self.tableView];
    for (int i =0; i<sections; ++i)
    {
        NSInteger rows = [src tableView:self.tableView numberOfRowsInSection:i];
        if (rows)
            isEmpty = NO;
    }
    
    if (!isEmpty != !_emptyOverlay)
    {
        if (isEmpty)
        {
            scrollWasEnabled = self.tableView.scrollEnabled;
            self.tableView.scrollEnabled = NO;
            //            emptyOverlay = [self makeEmptyOverlayView];
            [self.tableView addSubview:self.emptyOverlay];
            //            [emptyOverlay release];
        }
        else
        {
            self.tableView.scrollEnabled = scrollWasEnabled;
            [_emptyOverlay removeFromSuperview];
            _emptyOverlay = nil;
        }
    }
    else if (isEmpty)
    {
        // Make sure it is still above all siblings.
        //        [emptyOverlay retain];
        [_emptyOverlay removeFromSuperview];
        [self.tableView addSubview:self.emptyOverlay];
        //        [emptyOverlay release];
    }
}
/**
 *  懒加载emptyOverlay
 *
 *  @return UIImageView
 */
- (UIView *)emptyOverlay {
    if (!_emptyOverlay) {
        _emptyOverlay = [[UIView  alloc] init];
        _emptyOverlay.backgroundColor = [UIColor whiteColor];
        //    _emptyOverlay.frame  = CGRectMake(0,64, UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT-49-64);
        _emptyOverlay.frame  = CGRectMake(0,0, UI_SCREEN_WIDTH, ViewHeight(self.tableView));
        _emptyOverlay.contentMode =   UIViewContentModeTop;
        
        [self addUIemptyOverlayImageView];
        [self addUIemptyOverlayLabel];
        [self setupUIemptyOverlay];
    }
    return _emptyOverlay;
}

- (void)addUIemptyOverlayImageView {
    _emptyOverlayImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
    _emptyOverlayImageView.center = CGPointMake(UI_SCREEN_WIDTH/2, ViewHeight(self.tableView)/2 -100);
    _emptyOverlayImageView.image = [UIImage imageNamed:@"WebView_LoadFail_Refresh_Icon@2x"];
    [_emptyOverlay addSubview:_emptyOverlayImageView];
}
-(void)addUIemptyOverlayLabel {
    CGRect emptyOverlayViewFrame = CGRectMake(kUIemptyOverlayLabelX,kUIemptyOverlayLabelY,kUIemptyOverlayLabelWidth,kUIemptyOverlayLabelHeight);
    UILabel *emptyOverlayLabel = [[UILabel alloc] initWithFrame:emptyOverlayViewFrame];
    emptyOverlayLabel.textAlignment = NSTextAlignmentCenter;
    emptyOverlayLabel.numberOfLines = 0;
    // emptyOverlayLabel.backgroundColor = [UIColor blueColor];
    emptyOverlayLabel.backgroundColor = [UIColor clearColor];
    emptyOverlayLabel.text = @"暂无数据,轻触屏幕重新加载";
    emptyOverlayLabel.font= [UIFont boldSystemFontOfSize:15];
    RectMakeSetY(emptyOverlayLabel, height_y(_emptyOverlayImageView)+10);
    emptyOverlayLabel.textColor = RGB_TextDarkGray;
    [_emptyOverlay addSubview:emptyOverlayLabel];
}
- (void)setupUIemptyOverlay
{
    //如果是非UIView之外的UI控件,必须添加下行代码,比如UIImageView,UILabel,因为他们默认是NO.UIView默认是YES;
    _emptyOverlay.userInteractionEnabled = YES;
    //添加手势
    UILongPressGestureRecognizer *longPressUIemptyOverlay = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressUIemptyOverlay:)];
    [longPressUIemptyOverlay setMinimumPressDuration:0.001];
    [_emptyOverlay addGestureRecognizer:longPressUIemptyOverlay];
    //如果是非UIView之外的UI控件,必须添加下行代码,比如UIImageView,UILabel,因为他们默认是NO.UIView默认是YES;
    _emptyOverlay.userInteractionEnabled = YES;
}

- (void)longPressUIemptyOverlay:(UILongPressGestureRecognizer*)gesture {
    //手势开始时,设置背景为类似UIButton的高亮状态
    if ( gesture.state == UIGestureRecognizerStateBegan ){
        _emptyOverlayImageView.alpha = 0.4;
        
    }
    //手势结束时,设置背景为类似UIButton的Normal状态,并执行类似UIButton的如下方法
    //[button addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    if ( gesture.state == UIGestureRecognizerStateEnded ) {
        _emptyOverlayImageView.alpha = 1;
        [self emptyOverlayClicked:nil];
        //NSLog(@"Long Press");
    }
}
- (void)emptyOverlayClicked:(id)sender {
    
}

@end