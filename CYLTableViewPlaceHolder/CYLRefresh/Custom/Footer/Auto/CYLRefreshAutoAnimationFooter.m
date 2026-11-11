//
//  CYLRefreshAutoAnimationFooter.m
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24 (as MJRefresh's MJRefreshAutoGifFooter; renamed and generalized for CYLRefresh).
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "CYLRefreshAutoAnimationFooter.h"
#import "CYLRefreshIconView.h"
#import "NSBundle+CYLRefresh.h"
#import "UIView+CYLExtension.h"
#import "UIScrollView+CYLExtension.h"
#import "UIScrollView+CYLRefresh.h"

@interface CYLRefreshAutoAnimationFooter()
{
    __unsafe_unretained UIImageView *_animationView;
}
/** 所有状态对应的动画图片 */
@property (strong, nonatomic) NSMutableDictionary *stateImages;
/** 所有状态对应的动画时间 */
@property (strong, nonatomic) NSMutableDictionary *stateDurations;
@end

@implementation CYLRefreshAutoAnimationFooter

#pragma mark - CYLRefreshIconAnimating

- (CYLRefreshIconView *)iconView
{
    return self.cyl_iconView;
}

- (BOOL)usesIconView
{
    return self.cyl_usesIconView;
}

- (instancetype)setIconAnimationAttributes:(NSDictionary<NSString *, id> *)attributes forState:(CYLRefreshState)state
{
    [self cyl_setIconAnimationAttributes:attributes forState:state];
    return self;
}

- (instancetype)setIconAnimationFilePath:(NSString *)filePath size:(CGSize)size forState:(CYLRefreshState)state
{
    NSDictionary<NSString *, id> *attributes = [CYLRefreshIconView attributesForAnimationFilePath:filePath size:size];
    if (attributes) [self cyl_setIconAnimationAttributes:attributes forState:state];
    return self;
}

- (instancetype)setBundledIconAnimation:(NSString *)fileName size:(CGSize)size forState:(CYLRefreshState)state
{
    NSDictionary<NSString *, id> *attributes = [CYLRefreshIconView attributesForBundledAnimation:fileName size:size];
    if (attributes) [self cyl_setIconAnimationAttributes:attributes forState:state];
    return self;
}

+ (NSArray<NSString *> *)bundledIconAnimationFileNames
{
    return CYLRefreshIconView.bundledAnimationFileNames;
}
#pragma mark - 懒加载
- (UIImageView *)animationView
{
    if (!_animationView) {
        UIImageView *animationView = [[UIImageView alloc] init];
        [self addSubview:_animationView = animationView];
    }
    return _animationView;
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
- (instancetype)setAnimationImages:(NSArray *)images duration:(NSTimeInterval)duration forState:(CYLRefreshState)state
{
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

- (instancetype)setAnimationImages:(NSArray *)images forState:(CYLRefreshState)state
{
    return [self setAnimationImages:images duration:images.count * 0.1 forState:state];
}

#pragma mark - 实现父类的方法
- (void)prepare
{
    [super prepare];

    // 初始化间距
    self.labelLeftInset = 20;
}

- (void)placeSubviews
{
    [super placeSubviews];

    if (self.animationView.constraints.count) return;

    self.animationView.frame = self.bounds;
    if (self.isRefreshingTitleHidden) {
        self.animationView.contentMode = UIViewContentModeCenter;
    } else {
        self.animationView.contentMode = UIViewContentModeRight;
        self.animationView.cyl_w = self.cyl_w * 0.5 - self.labelLeftInset - self.stateLabel.cyl_textWidth * 0.5;
    }
    // [EN] An icon animation takes the animation view's place and, like it, shows only while loading.
    // [CN] 图标动画替换 动画视图，并与其一样只在加载时显示。
    // [EN] The loading text goes into the icon's CYLPlaceholderView, so icon and text are one centered view.
    // [CN] 加载文字放进图标的 CYLPlaceholderView，图标与文字是一个整体并居中。
    [self cyl_placeIconViewWithTitle:(self.isRefreshingTitleHidden || self.stateLabel.hidden) ? nil : self.stateLabel.text
                              labels:@[self.stateLabel] visible:self.state == CYLRefreshStateRefreshing
                      replacingViews:@[self.animationView]];
}

- (void)setState:(CYLRefreshState)state
{
    CYLRefreshCheckState

    // 根据状态做事情
    if (state == CYLRefreshStateRefreshing) {
        NSArray *images = self.stateImages[@(state)];
        if (images.count == 0) return;
        [self.animationView stopAnimating];

        self.animationView.hidden = NO;
        if (images.count == 1) { // 单张图片
            self.animationView.image = [images lastObject];
        } else { // 多张图片
            self.animationView.animationImages = images;
            self.animationView.animationDuration = [self.stateDurations[@(state)] doubleValue];
            [self.animationView startAnimating];
        }
    } else if (state == CYLRefreshStateNoMoreData || state == CYLRefreshStateIdle) {
        [self.animationView stopAnimating];
        self.animationView.hidden = YES;
    }
    [self setNeedsLayout];
    [self cyl_updateIconViewVisible:state == CYLRefreshStateRefreshing replacingViews:@[self.animationView]];
}

- (NSArray<UIView *> *)flipsHorizontallyInOppositeLayoutDirectionViews {
    return [super.flipsHorizontallyInOppositeLayoutDirectionViews arrayByAddingObjectsFromArray:@[
        self.animationView
    ]];
}

@end
