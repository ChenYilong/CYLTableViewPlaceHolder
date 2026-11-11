//
//  CYLRefreshGifHeader.m
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "CYLRefreshGifHeader.h"
#import "CYLRefreshIconView.h"
#import "UIView+CYLExtension.h"
#import "UIScrollView+CYLExtension.h"

@interface CYLRefreshGifHeader()
{
    __unsafe_unretained UIImageView *_gifView;
}
/** 所有状态对应的动画图片 */
@property (strong, nonatomic) NSMutableDictionary *stateImages;
/** 所有状态对应的动画时间 */
@property (strong, nonatomic) NSMutableDictionary *stateDurations;
@end

@implementation CYLRefreshGifHeader
#pragma mark - 懒加载
- (UIImageView *)gifView
{
    if (!_gifView) {
        UIImageView *gifView = [[UIImageView alloc] init];
        [self addSubview:_gifView = gifView];
    }
    return _gifView;
}

- (NSMutableDictionary *)stateImages
{
    if (!_stateImages) {
        self.stateImages = [NSMutableDictionary dictionary];
    }
    return _stateImages;
}

- (NSMutableDictionary *)stateDurations
{
    if (!_stateDurations) {
        self.stateDurations = [NSMutableDictionary dictionary];
    }
    return _stateDurations;
}

#pragma mark - 公共方法
- (instancetype)setImages:(NSArray *)images duration:(NSTimeInterval)duration forState:(CYLRefreshState)state {
    if (images == nil) return self;

    self.stateImages[@(state)] = images;
    self.stateDurations[@(state)] = @(duration);

    /* 根据图片设置控件的高度 */
    UIImage *image = [images firstObject];
    if (image.size.height > self.cyl_h) {
        self.cyl_h = image.size.height;
    }
    return self;
}

- (instancetype)setImages:(NSArray *)images forState:(CYLRefreshState)state
{
    return [self setImages:images duration:images.count * 0.1 forState:state];
}

#pragma mark - 实现父类的方法
- (void)prepare
{
    [super prepare];

    // 初始化间距
    self.labelLeftInset = 20;
}

- (void)setPullingPercent:(CGFloat)pullingPercent
{
    [super setPullingPercent:pullingPercent];
    NSArray *images = self.stateImages[@(CYLRefreshStateIdle)];
    if (self.state != CYLRefreshStateIdle || images.count == 0) return;
    // 停止动画
    [self.gifView stopAnimating];
    // 设置当前需要显示的图片
    NSUInteger index =  images.count * pullingPercent;
    if (index >= images.count) index = images.count - 1;
    self.gifView.image = images[index];
}

- (void)placeSubviews
{
    [super placeSubviews];

    if (self.gifView.constraints.count) return;

    self.gifView.frame = self.bounds;
    if (self.stateLabel.hidden && self.lastUpdatedTimeLabel.hidden) {
        self.gifView.contentMode = UIViewContentModeCenter;
    } else {
        self.gifView.contentMode = UIViewContentModeRight;

        CGFloat stateWidth = self.stateLabel.cyl_textWidth;
        CGFloat timeWidth = 0.0;
        if (!self.lastUpdatedTimeLabel.hidden) {
            timeWidth = self.lastUpdatedTimeLabel.cyl_textWidth;
        }
        CGFloat textWidth = MAX(stateWidth, timeWidth);
        self.gifView.cyl_w = self.cyl_w * 0.5 - textWidth * 0.5 - self.labelLeftInset;
    }
    [self cyl_placeGifIconView];
}

/// [EN] An icon animation takes the GIF view's place: centered, or right-aligned next to the text, as the GIF view
///      draws its images. [CN] 图标动画替换 GIF 视图：与 GIF 视图绘制图片的方式一致，居中或靠右紧挨文字。
- (void)cyl_placeGifIconView
{
    if (!self.usesIconView) return;
    CGSize size = self.iconView.iconSize;
    BOOL centered = self.gifView.contentMode == UIViewContentModeCenter;
    CGFloat centerX = centered ? CGRectGetMidX(self.gifView.frame) : CGRectGetMaxX(self.gifView.frame) - size.width * 0.5;
    [self cyl_placeIconViewAtCenter:CGPointMake(centerX, self.cyl_h * 0.5) visible:YES replacingViews:@[self.gifView]];
}

- (void)setState:(CYLRefreshState)state
{
    CYLRefreshCheckState

    // 根据状态做事情
    if (state == CYLRefreshStatePulling || state == CYLRefreshStateRefreshing) {
        NSArray *images = self.stateImages[@(state)];
        if (images.count == 0) return;

        [self.gifView stopAnimating];
        if (images.count == 1) { // 单张图片
            self.gifView.image = [images lastObject];
        } else { // 多张图片
            self.gifView.animationImages = images;
            self.gifView.animationDuration = [self.stateDurations[@(state)] doubleValue];
            [self.gifView startAnimating];
        }
    } else if (state == CYLRefreshStateIdle) {
        [self.gifView stopAnimating];
    }
    [self cyl_updateIconViewVisible:YES replacingViews:@[self.gifView]];
}

- (NSArray<UIView *> *)flipsHorizontallyInOppositeLayoutDirectionViews {
    return [super.flipsHorizontallyInOppositeLayoutDirectionViews arrayByAddingObjectsFromArray:@[
        self.gifView
    ]];
}
@end
