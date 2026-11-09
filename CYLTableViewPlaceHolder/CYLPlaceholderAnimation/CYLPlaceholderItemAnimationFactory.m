//
//  CYLPlaceholderItemAnimationFactory.m
//  CYLTableViewPlaceHolder
//
//  Adapted from CYLTabBarController (`CYLTabBarItemAnimation/`, branch
//  feat/cross-platform-components), MIT License,
//  Copyright © 2026 https://github.com/ChenYilong . All rights reserved.
//

#import "CYLPlaceholderItemAnimationFactory.h"
#import <objc/runtime.h>

/// [EN] The view keeps its player; the player holds the view weakly, so there is no retain cycle.
/// [CN] 视图持有其播放器；播放器弱引用视图，因此没有循环引用。
static const void *CYLPlaceholderItemAnimationPlayerKey = &CYLPlaceholderItemAnimationPlayerKey;

@implementation CYLPlaceholderItemAnimationFactory

+ (instancetype)sharedFactory {
    static CYLPlaceholderItemAnimationFactory *sharedFactory;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFactory = [[self alloc] init];
    });
    return sharedFactory;
}

- (instancetype)initWithRegistry:(id<CYLPlaceholderItemAnimatorRegistering>)registry {
    if (self = [super init]) {
        _registry = registry ?: [CYLPlaceholderItemAnimatorRegistry sharedRegistry];
    }
    return self;
}

- (instancetype)init {
    return [self initWithRegistry:[CYLPlaceholderItemAnimatorRegistry sharedRegistry]];
}

#pragma mark - Class methods (the shared factory) 类方法（共享工厂）

+ (UIView *)animationViewWithURL:(NSURL *)URL size:(CGSize)size contentMode:(UIViewContentMode)contentMode {
    return [[self sharedFactory] animationViewWithURL:URL size:size contentMode:contentMode];
}

+ (id<CYLPlaceholderItemAnimationPlayer>)playerForView:(UIView *)view {
    return [[self sharedFactory] playerForView:view];
}

+ (BOOL)isAnimationView:(UIView *)view {
    return [[self sharedFactory] isAnimationView:view];
}

#pragma mark - CYLPlaceholderItemAnimationViewMaking

- (UIView *)animationViewWithURL:(NSURL *)URL size:(CGSize)size contentMode:(UIViewContentMode)contentMode {
    id<CYLPlaceholderItemAnimator> animator = [self.registry animatorForURL:URL];
    UIView *animationView = [animator animationViewWithURL:URL size:size contentMode:contentMode];
    id<CYLPlaceholderItemAnimationPlayer> player = animationView ? [animator playerForAnimationView:animationView] : nil;
    if (!player) {
        return nil;
    }
    objc_setAssociatedObject(animationView, CYLPlaceholderItemAnimationPlayerKey, player, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    // The same set-up for every library, for a view inside a tab button. 所有动画库相同：作为 Tab 按钮子视图的设置。
    animationView.frame = CGRectMake(0, 0, size.width, size.height);
    animationView.userInteractionEnabled = NO;
    animationView.contentMode = contentMode;
    animationView.translatesAutoresizingMaskIntoConstraints = YES; // FIX: issue #653, see `_CYLTabButtonLayoutTracker`
    animationView.clipsToBounds = NO;
    return animationView;
}

- (id<CYLPlaceholderItemAnimationPlayer>)playerForView:(UIView *)view {
    if (!view || [view isMemberOfClass:[UIView class]]) {
        return nil;
    }
    id<CYLPlaceholderItemAnimationPlayer> player = objc_getAssociatedObject(view, CYLPlaceholderItemAnimationPlayerKey);
    if (player) {
        return player;
    }
    // [EN] A library view made elsewhere (e.g. added by the app): its library recognizes it and gives it a player.
    // [CN] 在别处创建的动画库视图（例如由 App 添加）：由其动画库识别并为它创建播放器。
    for (id<CYLPlaceholderItemAnimator> animator in [self.registry animators]) {
        player = [animator playerForAnimationView:view];
        if (player) {
            objc_setAssociatedObject(view, CYLPlaceholderItemAnimationPlayerKey, player, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            return player;
        }
    }
    return nil;
}

- (BOOL)isAnimationView:(UIView *)view {
    return [self playerForView:view] != nil;
}

@end
