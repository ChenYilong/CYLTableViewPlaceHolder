//
//  CYLRefreshIconView.m
//  CYLTableViewPlaceHolder
//

#import "CYLRefreshIconView.h"
#import "CYLPlaceholderView.h"

/// [EN] The default icon size, about the arrow's height. [CN] 默认图标尺寸，约为箭头的高度。
static const CGFloat CYLRefreshIconDefaultSide = 30;

@interface CYLRefreshIconView ()
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSDictionary<NSString *, id> *> *stateAttributes;
@property (nonatomic, strong, readwrite, nullable) CYLPlaceholderView *placeholderView;
/// [EN] The attributes the current placeholder view was built from. [CN] 当前图标组件所用的属性。
@property (nonatomic, copy, nullable) NSDictionary<NSString *, id> *shownAttributes;
@property (nonatomic) CYLRefreshState state;
@property (nonatomic) CGFloat pullingPercent;
/// [EN] Whether the icon is playing now, so repeated updates do not restart it. [CN] 当前是否在播放，避免重复更新时重新开始。
@property (nonatomic) BOOL playing;
@end

@implementation CYLRefreshIconView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _stateAttributes = [NSMutableDictionary dictionary];
        _state = CYLRefreshStateIdle;
        _scrubsWhilePulling = YES;
        self.backgroundColor = UIColor.clearColor;
        self.userInteractionEnabled = NO;
        // [EN] Decorative: the state label says what is happening. [CN] 装饰性内容：状态文字已说明当前状态。
        self.isAccessibilityElement = NO;
        self.accessibilityElementsHidden = YES;
    }
    return self;
}

#pragma mark - Attributes

- (void)setAnimationAttributes:(NSDictionary<NSString *, id> *)attributes forState:(CYLRefreshState)state {
    self.stateAttributes[@(state)] = [attributes copy];
    [self cyl_showAttributesForState:self.state];
    [self cyl_applyPlayback];
}

- (NSDictionary<NSString *, id> *)animationAttributesForState:(CYLRefreshState)state {
    return self.stateAttributes[@(state)];
}

- (BOOL)hasAnimations {
    return self.stateAttributes.count > 0;
}

- (CGSize)iconSize {
    // [EN] The size of the animation shown for the current state. [CN] 当前状态所显示动画的尺寸。
    NSDictionary *attributes = self.shownAttributes ?: [self cyl_attributesForState:self.state];
    id size = attributes[CYLPlaceholderItemAnimationSize];
    if ([size isKindOfClass:NSValue.class] && strcmp([size objCType], @encode(CGSize)) == 0) return [size CGSizeValue];
    if ([size isKindOfClass:NSArray.class] && [size count] == 2 && [[size firstObject] respondsToSelector:@selector(doubleValue)]) {
        CGFloat width = [[size firstObject] doubleValue], height = [[size lastObject] doubleValue];
        if (width > 0 && height > 0) return CGSizeMake(width, height);
    }
    return CGSizeMake(CYLRefreshIconDefaultSide, CYLRefreshIconDefaultSide);
}

/// [EN] The state's attributes, else the idle state's, else any. [CN] 该状态的属性，否则空闲状态的，否则任意一个。
- (NSDictionary<NSString *, id> *)cyl_attributesForState:(CYLRefreshState)state {
    return self.stateAttributes[@(state)] ?: (self.stateAttributes[@(CYLRefreshStateIdle)] ?:
                                              self.stateAttributes.allValues.firstObject);
}

- (void)cyl_showAttributesForState:(CYLRefreshState)state {
    NSDictionary<NSString *, id> *attributes = [self cyl_attributesForState:state];
    if (attributes == self.shownAttributes || [attributes isEqualToDictionary:self.shownAttributes]) return;
    [self.placeholderView removeFromSuperview];
    self.placeholderView = nil;
    self.shownAttributes = attributes;
    self.playing = NO;
    if (!attributes) return;
    NSError *error = nil;
    CYLPlaceholderView *view = [[CYLPlaceholderView alloc] initWithItemAttributes:attributes imageBundle:nil error:&error];
    if (!view) {
        NSLog(@"CYLRefresh: icon animation not shown: %@", error.localizedDescription);
        return;
    }
    // [EN] Stopped until the policy plays it; it would otherwise start when it enters the window.
    // [CN] 在播放策略开始播放前保持停止；否则进入 window 时会自动播放。
    [view stopPlaceholderAnimation];
    view.backgroundColor = UIColor.clearColor;
    // [EN] The icon fills its own frame: the component's 16-point placeholder margins left no room in a 30-point icon.
    // [CN] 图标铺满自身 frame：组件默认的 16 点占位图边距在 30 点的图标里没有空间。
    view.contentMargin = 0;
    view.userInteractionEnabled = NO;
    view.isAccessibilityElement = NO;
    view.accessibilityElementsHidden = YES;
    view.frame = self.bounds;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:view];
    self.placeholderView = view;
}

#pragma mark - Playback policy

- (void)updateForState:(CYLRefreshState)state {
    self.state = state;
    if (state != CYLRefreshStateIdle) self.pullingPercent = 0;
    [self cyl_showAttributesForState:state];
    [self cyl_applyPlayback];
}

- (void)updateForPullingPercent:(CGFloat)pullingPercent {
    self.pullingPercent = isfinite(pullingPercent) ? MAX(0, pullingPercent) : 0;
    if (self.state == CYLRefreshStateIdle) [self cyl_applyPlayback];
}

- (void)cyl_applyPlayback {
    CYLPlaceholderView *view = self.placeholderView;
    if (!view) return;
    switch (self.state) {
        case CYLRefreshStatePulling:
        case CYLRefreshStateRefreshing:
        case CYLRefreshStateWillRefresh:
            [self cyl_playLooping];
            break;
        case CYLRefreshStateNoMoreData:
            [self cyl_stop];
            break;
        case CYLRefreshStateIdle:
        default:
            if (self.pullingPercent <= 0) {
                [self cyl_stop];
            } else if (self.scrubsWhilePulling && [view setPlaceholderAnimationProgress:MIN(1, self.pullingPercent)]) {
                // [EN] Seeking stops the animation on that frame. [CN] 定位会把动画停在该帧。
                self.playing = NO;
            } else {
                [self cyl_playLooping];
            }
            break;
    }
}

- (void)cyl_playLooping {
    if (self.playing) return;
    // [EN] An animation that names its own repeat count keeps it; otherwise it loops while the control acts.
    // [CN] 属性中指定了播放次数的动画保持该设置；否则在控件工作期间循环播放。
    if (!self.shownAttributes[CYLPlaceholderItemAnimationRepeatCount]) self.placeholderView.animationRepeatCount = 0;
    [self.placeholderView playPlaceholderAnimation];
    self.playing = YES;
}

- (void)cyl_stop {
    [self.placeholderView stopPlaceholderAnimation];
    self.playing = NO;
}

@end
