//
//  CYLPlaceholderAnimationView.m
//  CYLTableViewPlaceHolder
//
//  Animation adapter patterns are informed by CYLTabBarController, distributed
//  under the MIT License (Copyright (c) 2026 CYLTabBarController).
//

#import "CYLPlaceholderAnimationView.h"
#import <math.h>

#if __has_include(<libpag/PAGView.h>)
#import <libpag/PAGView.h>
#define CYL_PLACEHOLDER_HAS_PAG 1
#else
#define CYL_PLACEHOLDER_HAS_PAG 0
#endif

#if __has_include(<CYLTableViewPlaceHolder/CYLTableViewPlaceHolder-Swift.h>)
#import <CYLTableViewPlaceHolder/CYLTableViewPlaceHolder-Swift.h>
#define CYL_PLACEHOLDER_HAS_SWIFT_BACKENDS 1
#elif __has_include("CYLTableViewPlaceHolder-Swift.h")
#import "CYLTableViewPlaceHolder-Swift.h"
#define CYL_PLACEHOLDER_HAS_SWIFT_BACKENDS 1
#else
#define CYL_PLACEHOLDER_HAS_SWIFT_BACKENDS 0
#endif

NSErrorDomain const CYLPlaceholderAnimationErrorDomain = @"CYLPlaceholderAnimationErrorDomain";

@interface UIView (CYLPlaceholderAnimationBackendControls)
- (void)playAnimation;
- (void)stopAnimation;
- (void)showAnimationLastFrame;
- (BOOL)setAnimationProgress:(CGFloat)progress;
- (BOOL)setAnimationSpeed:(CGFloat)speed;
- (BOOL)setAnimationColors:(NSDictionary<NSString *, UIColor *> *)colors;
- (void)setErrorHandler:(CYLPlaceholderAnimationErrorHandler _Nullable)errorHandler;
- (void)setReadyHandler:(void (^ _Nullable)(void))readyHandler;
- (BOOL)isReady;
@end

@interface CYLPlaceholderAnimationView ()
@property (nonatomic, strong, readwrite) UIView *animationView;
@property (nonatomic, readwrite) CYLPlaceholderAnimationBackend backend;
@property (nonatomic, readwrite, getter=isPlaying) BOOL playing;
@end

static NSError *CYLPlaceholderAnimationMakeError(CYLPlaceholderAnimationErrorCode code, NSString *description) {
    return [NSError errorWithDomain:CYLPlaceholderAnimationErrorDomain
                               code:code
                           userInfo:@{NSLocalizedDescriptionKey: description}];
}

@implementation CYLPlaceholderAnimationView

- (nullable instancetype)initWithFileURL:(NSURL *)fileURL
                                    size:(CGSize)size
                             contentMode:(UIViewContentMode)contentMode
                                   error:(NSError **)error {
    return [self initWithFileURL:fileURL size:size contentMode:contentMode options:@{} error:error];
}

- (nullable instancetype)initWithFileURL:(NSURL *)fileURL
                                    size:(CGSize)size
                             contentMode:(UIViewContentMode)contentMode
                                 options:(NSDictionary<NSString *, id> *)options
                                   error:(NSError **)error {
    if (!fileURL.isFileURL || fileURL.path.length == 0) {
        if (error) *error = CYLPlaceholderAnimationMakeError(CYLPlaceholderAnimationErrorInvalidURL,
                                                             @"Animation files must use a local file URL.");
        return nil;
    }
    if (!isfinite(size.width) || !isfinite(size.height) || size.width <= 0 || size.height <= 0 ||
        size.width > 1000 || size.height > 1000) {
        if (error) *error = CYLPlaceholderAnimationMakeError(CYLPlaceholderAnimationErrorInvalidSize,
                                                             @"Animation size must be finite, positive, and no larger than 1000 points.");
        return nil;
    }

    NSString *extension = fileURL.pathExtension.lowercaseString;
    CYLPlaceholderAnimationBackend backend;
    if ([extension isEqualToString:@"json"]) {
        backend = CYLPlaceholderAnimationBackendLottie;
    } else if ([extension isEqualToString:@"pag"]) {
        backend = CYLPlaceholderAnimationBackendPAG;
    } else if ([extension isEqualToString:@"riv"]) {
        backend = CYLPlaceholderAnimationBackendRive;
    } else {
        if (error) *error = CYLPlaceholderAnimationMakeError(CYLPlaceholderAnimationErrorUnsupportedFormat,
                                                             @"Supported animation files are .json, .pag, and .riv.");
        return nil;
    }

    self = [super initWithFrame:(CGRect){CGPointZero, size}];
    if (!self) return nil;
    _backend = backend;
    _animationView = [self cyl_animationViewWithURL:fileURL contentMode:contentMode options:options error:error];
    if (!_animationView) return nil;

    _animationView.frame = self.bounds;
    _animationView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _animationView.userInteractionEnabled = NO;
    _animationView.backgroundColor = UIColor.clearColor;
    [self addSubview:_animationView];
    return self;
}

- (nullable UIView *)cyl_animationViewWithURL:(NSURL *)fileURL
                                 contentMode:(UIViewContentMode)contentMode
                                     options:(NSDictionary<NSString *, id> *)options
                                       error:(NSError **)error {
    if (self.backend == CYLPlaceholderAnimationBackendPAG) {
#if CYL_PLACEHOLDER_HAS_PAG
        PAGFile *file = [PAGFile Load:fileURL.path];
        if (!file) {
            if (error) *error = CYLPlaceholderAnimationMakeError(CYLPlaceholderAnimationErrorAssetLoadFailed,
                                                                 @"The PAG file could not be decoded.");
            return nil;
        }
        PAGView *view = [[PAGView alloc] initWithFrame:CGRectZero];
        [view setSync:YES];
        [view setComposition:file];
        [view setRepeatCount:1];
        switch (contentMode) {
            case UIViewContentModeScaleToFill:
                [view setScaleMode:PAGScaleModeStretch];
                break;
            case UIViewContentModeScaleAspectFill:
                [view setScaleMode:PAGScaleModeZoom];
                break;
            default:
                [view setScaleMode:PAGScaleModeLetterBox];
                break;
        }
        [view setProgress:0];
        [view flush];
        return view;
#else
        if (error) *error = CYLPlaceholderAnimationMakeError(CYLPlaceholderAnimationErrorBackendUnavailable,
                                                             @"PAG support is not linked. Add the libpag-backed placeholder animation subspec.");
        return nil;
#endif
    }

#if CYL_PLACEHOLDER_HAS_SWIFT_BACKENDS
    NSError *backendError = nil;
    UIView *view = [CYLPlaceholderAnimationBackendFactory makeBackendViewWithFileURL:fileURL
                                                                         contentMode:contentMode
                                                                             options:options
                                                                               error:&backendError];
    if (!view && error) *error = backendError ?: CYLPlaceholderAnimationMakeError(
        CYLPlaceholderAnimationErrorBackendUnavailable, @"The requested animation backend is unavailable.");
    return view;
#else
    if (error) *error = CYLPlaceholderAnimationMakeError(CYLPlaceholderAnimationErrorBackendUnavailable,
                                                         @"Lottie and Rive support requires the Swift animation adapters.");
    return nil;
#endif
}

- (void)setErrorHandler:(CYLPlaceholderAnimationErrorHandler)errorHandler {
    _errorHandler = [errorHandler copy];
    if ([self.animationView respondsToSelector:@selector(setErrorHandler:)]) {
        [self.animationView setErrorHandler:_errorHandler];
    }
}

- (BOOL)isReady {
    if ([self.animationView respondsToSelector:@selector(isReady)]) {
        return [self.animationView isReady];
    }
    return YES;
}

- (void)setReadyHandler:(void (^)(void))readyHandler {
    _readyHandler = [readyHandler copy];
    if ([self.animationView respondsToSelector:@selector(setReadyHandler:)]) {
        [self.animationView setReadyHandler:_readyHandler];
    }
}

- (void)play {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self play]; });
        return;
    }
    if (self.backend == CYLPlaceholderAnimationBackendPAG) {
#if CYL_PLACEHOLDER_HAS_PAG
        PAGView *view = (PAGView *)self.animationView;
        [view setProgress:0];
        [view play];
#endif
    } else if ([self.animationView respondsToSelector:@selector(playAnimation)]) {
        [self.animationView playAnimation];
    }
    self.playing = YES;
}

- (void)stop {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self stop]; });
        return;
    }
    if (self.backend == CYLPlaceholderAnimationBackendPAG) {
#if CYL_PLACEHOLDER_HAS_PAG
        PAGView *view = (PAGView *)self.animationView;
        [view stop];
        [view setProgress:0];
        [view flush];
#endif
    } else if ([self.animationView respondsToSelector:@selector(stopAnimation)]) {
        [self.animationView stopAnimation];
    }
    self.playing = NO;
}

- (void)showLastFrame {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self showLastFrame]; });
        return;
    }
    if (self.backend == CYLPlaceholderAnimationBackendPAG) {
#if CYL_PLACEHOLDER_HAS_PAG
        PAGView *view = (PAGView *)self.animationView;
        [view stop];
        [view setProgress:1];
        [view flush];
#endif
    } else if ([self.animationView respondsToSelector:@selector(showAnimationLastFrame)]) {
        [self.animationView showAnimationLastFrame];
    } else {
        [self stop];
    }
    self.playing = NO;
}

- (BOOL)setAnimationProgress:(CGFloat)progress {
    if (![NSThread isMainThread] || !isfinite(progress) || progress < 0 || progress > 1) return NO;
    if (self.backend == CYLPlaceholderAnimationBackendPAG) {
#if CYL_PLACEHOLDER_HAS_PAG
        PAGView *view = (PAGView *)self.animationView;
        [view stop];
        [view setProgress:progress];
        [view flush];
        self.playing = NO;
        return YES;
#else
        return NO;
#endif
    }
    if ([self.animationView respondsToSelector:@selector(setAnimationProgress:)] &&
        [self.animationView setAnimationProgress:progress]) {
        self.playing = NO;
        return YES;
    }
    return NO;
}

- (BOOL)setAnimationSpeed:(CGFloat)speed {
    if (![NSThread isMainThread] || !isfinite(speed) || speed <= 0) return NO;
    if (self.backend == CYLPlaceholderAnimationBackendPAG) return NO;
    return [self.animationView respondsToSelector:@selector(setAnimationSpeed:)] &&
        [self.animationView setAnimationSpeed:speed];
}

- (BOOL)setAnimationColors:(NSDictionary<NSString *,UIColor *> *)colors {
    if (![NSThread isMainThread]) return NO;
    return [self.animationView respondsToSelector:@selector(setAnimationColors:)] &&
        [self.animationView setAnimationColors:colors];
}

@end
