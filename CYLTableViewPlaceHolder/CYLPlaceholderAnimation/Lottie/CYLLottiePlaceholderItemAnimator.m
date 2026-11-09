//
//  CYLLottiePlaceholderItemAnimator.m
//  CYLTableViewPlaceHolder
//
//  Adapted from CYLTabBarController (`CYLLottieTabBarItemAnimator`, Lottie 4.x
//  Swift player, branch feat/cross-platform-components), MIT License,
//  Copyright © 2026 https://github.com/ChenYilong . All rights reserved.
//

#import "CYLLottiePlaceholderItemAnimator.h"
#if __has_include("../CYLPlaceholderItemAnimatorRegistry.h")
#import "../CYLPlaceholderItemAnimatorRegistry.h"
#import "../CYLPlaceholderItemAnimationPlayableView.h"
#else
#import "CYLPlaceholderItemAnimatorRegistry.h"
#import "CYLPlaceholderItemAnimationPlayableView.h"
#endif
#if __has_include("../../CYLTableViewPlaceHolder/CYLPlaceholderView.h")
#import "../../CYLTableViewPlaceHolder/CYLPlaceholderView.h"
#else
#import "CYLPlaceholderView.h"
#endif

#if __has_include(<CYLTableViewPlaceHolder/CYLTableViewPlaceHolder-Swift.h>)
#import <CYLTableViewPlaceHolder/CYLTableViewPlaceHolder-Swift.h>
#define CYL_PLACEHOLDER_LOTTIE_AVAILABLE 1
#elif __has_include("CYLTableViewPlaceHolder-Swift.h")
#import "CYLTableViewPlaceHolder-Swift.h"
#define CYL_PLACEHOLDER_LOTTIE_AVAILABLE 1
#else
#define CYL_PLACEHOLDER_LOTTIE_AVAILABLE 0
#endif

#if CYL_PLACEHOLDER_LOTTIE_AVAILABLE

#pragma mark - Lottie 4.x (Swift)

@interface CYLLottieSwiftPlaceholderItemAnimationPlayer : CYLPlaceholderItemAnimationBasePlayer <CYLPlaceholderItemAnimationPlayer>
@end

@implementation CYLLottieSwiftPlaceholderItemAnimationPlayer {
    BOOL _darkColorsApplied;
    NSSet<NSString *> *_appliedColorKeypaths;
}

+ (BOOL)isLottieView:(UIView *)view {
    return [view isKindOfClass:[CYLPlaceholderCompatibleLOTAnimationView class]];
}

+ (UIView *)viewWithURL:(NSURL *)URL {
    CYLPlaceholderCompatibleLOTAnimation *composition = [[CYLPlaceholderCompatibleLOTAnimation alloc] initWithFilepath:URL.path];
    // Unlike CYLTabBarController, an unreadable file yields no view, so the placeholder keeps its static image.
    if (!composition.isLoaded) {
        return nil;
    }
    return [[CYLPlaceholderCompatibleLOTAnimationView alloc] initWithCompatibleAnimation:composition];
}

- (CYLPlaceholderCompatibleLOTAnimationView *)lottieView {
    return (CYLPlaceholderCompatibleLOTAnimationView *)self.animationView;
}

- (void)play {
    CYLPlaceholderCompatibleLOTAnimationView *lottieView = self.lottieView;
    lottieView.animationProgress = 0;
    [lottieView play];
}

- (void)showLastFrame {
    CYLPlaceholderCompatibleLOTAnimationView *lottieView = self.lottieView;
    [lottieView stop];
    lottieView.animationProgress = 1;
    [lottieView forceDrawingUpdate];
}

- (void)stop {
    CYLPlaceholderCompatibleLOTAnimationView *lottieView = self.lottieView;
    [lottieView stop];
    lottieView.animationProgress = 0;
}

- (CGFloat)progress {
    return self.lottieView.animationProgress;
}

- (void)setProgress:(CGFloat)progress {
    CYLPlaceholderCompatibleLOTAnimationView *lottieView = self.lottieView;
    lottieView.animationProgress = progress;
    [lottieView forceDrawingUpdate];
}

- (CGFloat)animationSpeed {
    return self.lottieView.animationSpeed;
}

- (void)setAnimationSpeed:(CGFloat)animationSpeed {
    self.lottieView.animationSpeed = animationSpeed;
}

- (void)applyDarkColors:(NSDictionary<NSString *, UIColor *> *)darkColors traitCollection:(UITraitCollection *)traitCollection {
    CYLPlaceholderCompatibleLOTAnimationView *view = self.lottieView;
    if (!view || darkColors.count == 0) {
        return;
    }
    BOOL dark = NO;
    if (@available(iOS 13.0, *)) {
        dark = (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark);
    }
    if (_darkColorsApplied == dark) {
        return;
    }
    [darkColors enumerateKeysAndObjectsUsingBlock:^(NSString *keypath, UIColor *color, BOOL *stop) {
        (void)stop;
        if (![keypath isKindOfClass:[NSString class]] || ![color isKindOfClass:[UIColor class]]) {
            return;
        }
        if (dark) {
            UIColor *resolvedColor = color;
            if (@available(iOS 13.0, *)) {
                resolvedColor = [color resolvedColorWithTraitCollection:traitCollection];
            }
            [view setColorValue:resolvedColor forKeypathString:keypath];
        } else {
            [view removeValueProviderForKeypathString:keypath];
        }
    }];
    _darkColorsApplied = dark;
    [view forceDrawingUpdate];
}

- (void)applyColors:(nullable NSDictionary<NSString *, UIColor *> *)colors traitCollection:(UITraitCollection *)traitCollection {
    CYLPlaceholderCompatibleLOTAnimationView *view = self.lottieView;
    if (!view) {
        return;
    }
    for (NSString *keypath in _appliedColorKeypaths) {
        if (!colors[keypath]) {
            [view removeValueProviderForKeypathString:keypath];
        }
    }
    NSMutableSet<NSString *> *appliedKeypaths = [NSMutableSet set];
    [colors enumerateKeysAndObjectsUsingBlock:^(NSString *keypath, UIColor *color, BOOL *stop) {
        (void)stop;
        if (![keypath isKindOfClass:[NSString class]] || ![color isKindOfClass:[UIColor class]]) {
            return;
        }
        UIColor *resolvedColor = color;
        if (@available(iOS 13.0, *)) {
            resolvedColor = [color resolvedColorWithTraitCollection:traitCollection];
        }
        [view setColorValue:resolvedColor forKeypathString:keypath];
        [appliedKeypaths addObject:keypath];
    }];
    _appliedColorKeypaths = appliedKeypaths;
    _darkColorsApplied = NO;
    [view forceDrawingUpdate];
}

@end

@implementation CYLLottiePlaceholderItemAnimator

+ (void)load {
    [CYLPlaceholderItemAnimatorRegistry registerAnimator:[[self alloc] init]];
}

- (NSString *)identifier {
    return @"Lottie";
}

- (CYLPlaceholderItemAnimatorPriority)priority {
    return CYLPlaceholderItemAnimatorPriorityFallback;
}

- (NSArray<NSString *> *)fileExtensions {
    return @[ @"json", @"lottie" ];
}

- (NSDictionary<NSString *, NSString *> *)attributeKeys {
    return @{
        CYLPlaceholderItemAnimationURL : CYLPlaceholderItemLottieURL,
        CYLPlaceholderItemAnimationFilePath : CYLPlaceholderItemLottieFilePath,
        CYLPlaceholderItemAnimationSize : CYLPlaceholderItemLottieSize,
        CYLPlaceholderItemAnimationDarkURL : CYLPlaceholderItemLottieDarkURL,
        CYLPlaceholderItemAnimationDarkFilePath : CYLPlaceholderItemLottieDarkFilePath,
        CYLPlaceholderItemAnimationDarkColors : CYLPlaceholderItemLottieDarkColors,
    };
}

/// CYLTabBarController's Lottie animator takes every file; the placeholder keeps typed
/// "unsupported format" errors, so it takes only its own extensions (still looked up last).
- (BOOL)canAnimateFileAtURL:(NSURL *)URL {
    NSString *extension = URL.pathExtension.lowercaseString;
    return extension.length > 0 && [self.fileExtensions containsObject:extension];
}

- (UIView *)animationViewWithURL:(NSURL *)URL size:(CGSize)size contentMode:(UIViewContentMode)contentMode {
    if (@available(iOS 13.0, *)) {
        return [CYLLottieSwiftPlaceholderItemAnimationPlayer viewWithURL:URL];
    }
    return nil;
}

- (id<CYLPlaceholderItemAnimationPlayer>)playerForAnimationView:(UIView *)view {
    if ([CYLLottieSwiftPlaceholderItemAnimationPlayer isLottieView:view]) {
        return [[CYLLottieSwiftPlaceholderItemAnimationPlayer alloc] initWithAnimationView:view];
    }
    return nil;
}

@end

#endif
