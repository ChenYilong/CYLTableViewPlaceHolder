//
//  CYLRefreshAnimationHeader.m
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24 (as MJRefresh's MJRefreshGifHeader; renamed and generalized for CYLRefresh).
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "CYLRefreshAnimationHeader.h"
#import "CYLRefreshIconView.h"
#import "UIView+CYLExtension.h"
#import "UIScrollView+CYLExtension.h"

@interface CYLRefreshAnimationHeader()
{
    __unsafe_unretained UIImageView *_animationView;
}
/** 所有状态对应的动画图片 */
@property (strong, nonatomic) NSMutableDictionary *stateImages;
/** 所有状态对应的动画时间 */
@property (strong, nonatomic) NSMutableDictionary *stateDurations;
@end

@implementation CYLRefreshAnimationHeader

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
- (instancetype)setAnimationImages:(NSArray *)images duration:(NSTimeInterval)duration forState:(CYLRefreshState)state {
    if (images == nil) return self;

    self.stateImages[@(state)] = images;
    self.stateDurations[@(state)] = @(duration);

    /* 根据图片设置控件的高度 */
    UIImage *image = [images firstObject];
    if (image.size.height > self.cyl_h) {
        self.cyl_h = image.size.height;
    }
    // [EN] The images are drawn by the icon's CYLPlaceholderView, like every other icon, with the state text in the
    //      same view; `animationView` stays for compatibility and is hidden.
    // [CN] 图片由图标的 CYLPlaceholderView 绘制（与其他图标相同），状态文字在同一视图中；`animationView` 为兼容保留并隐藏。
    [self cyl_setIconImages:images duration:duration forState:state];
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

- (void)setPullingPercent:(CGFloat)pullingPercent
{
    [super setPullingPercent:pullingPercent];
    [self cyl_showIconImageFrameOf:self.stateImages[@(CYLRefreshStateIdle)] pullingPercent:pullingPercent];
}

- (void)placeSubviews
{
    [super placeSubviews];

    if (self.animationView.constraints.count) return;

    self.animationView.frame = self.bounds;
    if (self.stateLabel.hidden && self.lastUpdatedTimeLabel.hidden) {
        self.animationView.contentMode = UIViewContentModeCenter;
    } else {
        self.animationView.contentMode = UIViewContentModeRight;

        CGFloat stateWidth = self.stateLabel.cyl_textWidth;
        CGFloat timeWidth = 0.0;
        if (!self.lastUpdatedTimeLabel.hidden) {
            timeWidth = self.lastUpdatedTimeLabel.cyl_textWidth;
        }
        CGFloat textWidth = MAX(stateWidth, timeWidth);
        self.animationView.cyl_w = self.cyl_w * 0.5 - textWidth * 0.5 - self.labelLeftInset;
    }
    [self cyl_placeAnimationIconView];
}

/// [EN] An icon animation takes the animation view's place, and the state and time text go into the same
///      CYLPlaceholderView after the icon, centered as one: icon and text cannot drift apart.
/// [CN] 图标动画替换 动画视图，状态与时间文字放进图标所在的同一个 CYLPlaceholderView，整体居中：图标与文字不会错位。
- (void)cyl_placeAnimationIconView
{
    if (!self.usesIconView) return;
    [self cyl_placeIconViewWithTitle:[self cyl_iconTitle] labels:@[self.stateLabel, self.lastUpdatedTimeLabel]
                             visible:YES replacingViews:@[self.animationView]];
}

/// The text shown after the icon: the visible state and time labels, one per line.
- (NSString *)cyl_iconTitle
{
    NSMutableArray<NSString *> *lines = [NSMutableArray array];
    if (!self.stateLabel.hidden && self.stateLabel.text.length) [lines addObject:self.stateLabel.text];
    if (!self.lastUpdatedTimeLabel.hidden && self.lastUpdatedTimeLabel.text.length) {
        [lines addObject:self.lastUpdatedTimeLabel.text];
    }
    return lines.count ? [lines componentsJoinedByString:@"\n"] : nil;
}

- (void)setState:(CYLRefreshState)state
{
    CYLRefreshCheckState

    // [EN] Back to idle: the frame for the current pull. [CN] 回到空闲：显示与当前下拉距离对应的帧。
    if (state == CYLRefreshStateIdle) {
        [self cyl_showIconImageFrameOf:self.stateImages[@(CYLRefreshStateIdle)] pullingPercent:self.pullingPercent];
    }
    [self cyl_placeAnimationIconView];
}

- (NSArray<UIView *> *)flipsHorizontallyInOppositeLayoutDirectionViews {
    return [super.flipsHorizontallyInOppositeLayoutDirectionViews arrayByAddingObjectsFromArray:@[
        self.animationView
    ]];
}
@end
