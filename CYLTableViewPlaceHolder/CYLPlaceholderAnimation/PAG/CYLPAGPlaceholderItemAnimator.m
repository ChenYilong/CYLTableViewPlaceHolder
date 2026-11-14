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

@implementation CYLPAGPlaceholderItemAnimationPlayer

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
