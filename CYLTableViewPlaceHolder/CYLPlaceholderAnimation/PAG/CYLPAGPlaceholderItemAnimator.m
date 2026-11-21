//
//  CYLPAGPlaceholderItemAnimator.m
//  CYLTableViewPlaceHolder
//
//  Adapted from CYLTabBarController (`CYLPAGTabBarItemAnimator`, branch
//  feat/cross-platform-components), MIT License,
//  Copyright © 2026 https://github.com/ChenYilong . All rights reserved.
//

#import "CYLPAGPlaceholderItemAnimator.h"
#if __has_include("../CYLPlaceholderItemAnimatorRegistry.h")
#import "../CYLPlaceholderItemAnimatorRegistry.h"
#else
#import "CYLPlaceholderItemAnimatorRegistry.h"
#endif
#if __has_include("../../CYLTableViewPlaceHolder/CYLPlaceholderView.h")
#import "../../CYLTableViewPlaceHolder/CYLPlaceholderView.h"
#else
#import "CYLPlaceholderView.h"
#endif

#if CYL_PLACEHOLDER_PAG_AVAILABLE

#import <libpag/PAGView.h>

@interface CYLPAGPlaceholderItemAnimationPlayer : CYLPlaceholderItemAnimationBasePlayer <CYLPlaceholderItemAnimationPlayer>
@end

@implementation CYLPAGPlaceholderItemAnimationPlayer {
    /// [EN] The file's own duration in microseconds, read before the first speed change. [CN] 文件自身时长（微秒），首次调速前读取。
    int64_t _originalDuration;
    CGFloat _animationSpeed;
}

- (PAGView *)pagView {
    return (PAGView *)self.animationView;
}

- (void)play {
    PAGView *pagView = self.pagView;
    [pagView stop];
    [pagView setProgress:0];
    [pagView play];
}

- (void)showLastFrame {
    PAGView *pagView = self.pagView;
    [pagView stop];
    [pagView setProgress:1];
    [pagView flush];
}

- (void)stop {
    PAGView *pagView = self.pagView;
    [pagView stop];
    if ([pagView getProgress] <= 0) {
        return;
    }
    [pagView setProgress:0];
    [pagView flush];
}

- (BOOL)setAnimationRepeatCount:(NSInteger)repeatCount {
    PAGView *pagView = self.pagView;
    if (!pagView || repeatCount < 0 || repeatCount > INT_MAX) return NO;
    // [EN] libpag: 0 repeats forever. [CN] libpag：0 表示无限循环。
    [pagView setRepeatCount:(int)repeatCount];
    return YES;
}

- (CGFloat)animationSpeed {
    return _animationSpeed > 0 ? _animationSpeed : 1;
}

/// [EN] libpag's view has no rate: the file's duration is stretched instead (progress stays where it is, so the change is
///      live). [CN] libpag 的视图没有播放速率：改为拉伸文件时长（进度保持不变，因此实时生效）。
- (void)setAnimationSpeed:(CGFloat)animationSpeed {
    if (!isfinite(animationSpeed) || animationSpeed <= 0) return;
    PAGComposition *composition = [self.pagView getComposition];
    if (![composition isKindOfClass:PAGFile.class]) return;
    PAGFile *file = (PAGFile *)composition;
    if (_originalDuration <= 0) _originalDuration = [file duration];
    if (_originalDuration <= 0) return;
    double progress = [self.pagView getProgress];
    [file setDuration:(int64_t)llround((double)_originalDuration / animationSpeed)];
    [self.pagView setProgress:progress];
    _animationSpeed = animationSpeed;
}

- (CGFloat)progress {
    return (CGFloat)[self.pagView getProgress];
}

- (void)setProgress:(CGFloat)progress {
    PAGView *pagView = self.pagView;
    [pagView setProgress:progress];
    [pagView flush];
}

@end

@implementation CYLPAGPlaceholderItemAnimator

+ (void)load {
    [CYLPlaceholderItemAnimatorRegistry registerAnimator:[[self alloc] init]];
}

- (NSString *)identifier {
    return @"PAG";
}

- (NSArray<NSString *> *)fileExtensions {
    return @[ @"pag" ];
}

- (NSDictionary<NSString *, NSString *> *)attributeKeys {
    return @{
        CYLPlaceholderItemAnimationURL : CYLPlaceholderItemPAGURL,
        CYLPlaceholderItemAnimationFilePath : CYLPlaceholderItemPAGFilePath,
        CYLPlaceholderItemAnimationSize : CYLPlaceholderItemPAGSize,
        CYLPlaceholderItemAnimationDarkURL : CYLPlaceholderItemPAGDarkURL,
        CYLPlaceholderItemAnimationDarkFilePath : CYLPlaceholderItemPAGDarkFilePath,
    };
}

- (BOOL)canAnimateFileAtURL:(NSURL *)URL {
    return [URL.pathExtension.lowercaseString isEqualToString:@"pag"];
}

- (UIView *)animationViewWithURL:(NSURL *)URL size:(CGSize)size contentMode:(UIViewContentMode)contentMode {
    PAGFile *pagFile = URL.path.length > 0 ? [PAGFile Load:URL.path] : nil;
    if (!pagFile) {
        return nil;
    }
    PAGView *pagView = [[PAGView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    [pagView setSync:YES];
    [pagView setComposition:pagFile];
    [pagView setRepeatCount:1];
    switch (contentMode) {
        case UIViewContentModeScaleToFill: [pagView setScaleMode:PAGScaleModeStretch]; break;
        case UIViewContentModeScaleAspectFill: [pagView setScaleMode:PAGScaleModeZoom]; break;
        default: [pagView setScaleMode:PAGScaleModeLetterBox]; break;
    }
    [pagView setProgress:0];
    [pagView flush];
    return pagView;
}

- (id<CYLPlaceholderItemAnimationPlayer>)playerForAnimationView:(UIView *)view {
    return [view isKindOfClass:[PAGView class]] ? [[CYLPAGPlaceholderItemAnimationPlayer alloc] initWithAnimationView:view] : nil;
}

@end

#endif
