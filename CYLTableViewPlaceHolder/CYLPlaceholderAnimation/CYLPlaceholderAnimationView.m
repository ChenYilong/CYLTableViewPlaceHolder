//
//  CYLPlaceholderAnimationView.m
//  CYLTableViewPlaceHolder
//
//  Animation adapter patterns are informed by CYLTabBarController, distributed
//  under the MIT License (Copyright (c) 2026 CYLTabBarController).
//

#import "CYLPlaceholderAnimationView.h"
#import "CYLPlaceholderItemAnimatorRegistry.h"
#import "CYLPlaceholderItemAnimationFactory.h"
#import "CYLPlaceholderItemAnimationPlayableView.h"
#import <math.h>

NSErrorDomain const CYLPlaceholderAnimationErrorDomain = @"CYLPlaceholderAnimationErrorDomain";

@interface CYLPlaceholderAnimationView ()
@property (nonatomic, strong, readwrite) UIView *animationView;
@property (nonatomic, strong, readwrite) id<CYLPlaceholderItemAnimationPlayer> player;
@property (nonatomic, copy, readwrite) NSString *animatorIdentifier;
@property (nonatomic, readwrite) CYLPlaceholderAnimationBackend backend;
@property (nonatomic, readwrite, getter=isPlaying) BOOL playing;
@end

static NSError *CYLPlaceholderAnimationMakeError(CYLPlaceholderAnimationErrorCode code, NSString *description) {
    return [NSError errorWithDomain:CYLPlaceholderAnimationErrorDomain
                               code:code
                           userInfo:@{NSLocalizedDescriptionKey: description}];
}

/// The engines this library ships as subspecs; a missing one is "unavailable", not "unsupported".
static NSString *CYLPlaceholderAnimationKnownEngine(NSString *extension) {
    NSDictionary<NSString *, NSString *> *engines = @{
        @"json": @"Lottie", @"lottie": @"Lottie", @"pag": @"PAG", @"riv": @"Rive", @"gif": @"GIF"
    };
    return engines[extension];
}

/// Encodes options into the URL fragment that `CYLPlaceholderItemViewAnimator` reads.
static NSURL *CYLPlaceholderAnimationURLWithOptions(NSURL *URL, NSDictionary<NSString *, NSString *> *options) {
    if (options.count == 0) return URL;
    NSMutableCharacterSet *allowed = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [allowed removeCharactersInString:@"&=#"];
    NSMutableArray<NSString *> *items = [NSMutableArray array];
    for (NSString *name in [options.allKeys sortedArrayUsingSelector:@selector(compare:)]) {
        [items addObject:[NSString stringWithFormat:@"%@=%@",
            [name stringByAddingPercentEncodingWithAllowedCharacters:allowed],
            [options[name] stringByAddingPercentEncodingWithAllowedCharacters:allowed]]];
    }
    NSURLComponents *components = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:YES];
    components.percentEncodedFragment = [items componentsJoinedByString:@"&"];
    return components.URL ?: URL;
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
    if (![fileURL isKindOfClass:NSURL.class] || !fileURL.isFileURL || fileURL.path.length == 0) {
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
    NSMutableDictionary<NSString *, NSString *> *stringOptions = [NSMutableDictionary dictionary];
    for (id name in options) {
        id value = options[name];
        if (![name isKindOfClass:NSString.class] ||
            !([value isKindOfClass:NSString.class] || [value isKindOfClass:NSNumber.class])) {
            if (error) *error = CYLPlaceholderAnimationMakeError(CYLPlaceholderAnimationErrorInvalidOptions,
                                                                 @"Animation option names must be strings and values strings or numbers.");
            return nil;
        }
        if ([name isEqualToString:@"contentMode"]) continue; // applied through `contentMode`
        stringOptions[name] = [value isKindOfClass:NSNumber.class] ? [value stringValue] : value;
    }
    NSString *extension = fileURL.pathExtension.lowercaseString;
    if ([extension isEqualToString:@"riv"] && stringOptions[@"duration"]) {
        NSScanner *scanner = [NSScanner scannerWithString:stringOptions[@"duration"]];
        double duration = NAN;
        if (![scanner scanDouble:&duration] || !scanner.isAtEnd || !isfinite(duration) || duration < 0 || duration > 60) {
            if (error) *error = CYLPlaceholderAnimationMakeError(CYLPlaceholderAnimationErrorInvalidOptions,
                                                                 @"Rive duration must be between 0 and 60 seconds.");
            return nil;
        }
    }

    id<CYLPlaceholderItemAnimator> animator = [CYLPlaceholderItemAnimatorRegistry animatorForURL:fileURL];
    if (!animator) {
        NSString *engine = CYLPlaceholderAnimationKnownEngine(extension);
        if (error) *error = engine ?
            CYLPlaceholderAnimationMakeError(CYLPlaceholderAnimationErrorBackendUnavailable,
                [NSString stringWithFormat:@"%@ support is not linked. Add the CYLTableViewPlaceHolder/%@ subspec.", engine, engine]) :
            CYLPlaceholderAnimationMakeError(CYLPlaceholderAnimationErrorUnsupportedFormat,
                @"No registered animator plays this file type.");
        return nil;
    }

    self = [super initWithFrame:(CGRect){CGPointZero, size}];
    if (!self) return nil;
    NSURL *URL = CYLPlaceholderAnimationURLWithOptions(fileURL, stringOptions);
    UIView *view = [[CYLPlaceholderItemAnimationFactory sharedFactory] animationViewWithURL:URL size:size contentMode:contentMode];
    id<CYLPlaceholderItemAnimationPlayer> player = view ? [[CYLPlaceholderItemAnimationFactory sharedFactory] playerForView:view] : nil;
    if (!view || !player) {
        if (error) *error = CYLPlaceholderAnimationMakeError(CYLPlaceholderAnimationErrorAssetLoadFailed,
            [NSString stringWithFormat:@"The %@ animator could not load %@.", animator.identifier, fileURL.lastPathComponent]);
        return nil;
    }
    _animatorIdentifier = [animator.identifier copy];
    NSDictionary<NSString *, NSNumber *> *backends = @{
        @"Lottie": @(CYLPlaceholderAnimationBackendLottie), @"PAG": @(CYLPlaceholderAnimationBackendPAG),
        @"Rive": @(CYLPlaceholderAnimationBackendRive), @"GIF": @(CYLPlaceholderAnimationBackendGIF)
    };
    _backend = backends[animator.identifier] ? backends[animator.identifier].integerValue : CYLPlaceholderAnimationBackendCustom;
    _animationView = view;
    _player = player;
    view.frame = self.bounds;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.backgroundColor = UIColor.clearColor;
    [self addSubview:view];
    return self;
}

- (void)setErrorHandler:(CYLPlaceholderAnimationErrorHandler)errorHandler {
    _errorHandler = [errorHandler copy];
    if ([self.animationView respondsToSelector:@selector(setCyl_animationViewErrorHandler:)]) {
        [(id<CYLPlaceholderItemAnimationPlayableView>)self.animationView setCyl_animationViewErrorHandler:_errorHandler];
    }
}

- (BOOL)isReady {
    if ([self.animationView respondsToSelector:@selector(cyl_isAnimationViewReady)]) {
        return [(id<CYLPlaceholderItemAnimationPlayableView>)self.animationView cyl_isAnimationViewReady];
    }
    return YES;
}

- (void)setReadyHandler:(void (^)(void))readyHandler {
    _readyHandler = [readyHandler copy];
    if ([self.animationView respondsToSelector:@selector(setCyl_animationViewReadyHandler:)]) {
        [(id<CYLPlaceholderItemAnimationPlayableView>)self.animationView setCyl_animationViewReadyHandler:_readyHandler];
    }
}

- (void)play {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self play]; });
        return;
    }
    [self.player play];
    self.playing = YES;
}

- (void)stop {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self stop]; });
        return;
    }
    [self.player stop];
    self.playing = NO;
}

- (void)showLastFrame {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self showLastFrame]; });
        return;
    }
    [self.player showLastFrame];
    self.playing = NO;
}

- (BOOL)setAnimationProgress:(CGFloat)progress {
    if (![NSThread isMainThread] || !isfinite(progress) || progress < 0 || progress > 1 ||
        ![self.player respondsToSelector:@selector(setProgress:)]) return NO;
    [self.player stop];
    self.player.progress = progress;
    self.playing = NO;
    return YES;
}

- (BOOL)setAnimationSpeed:(CGFloat)speed {
    if (![NSThread isMainThread] || !isfinite(speed) || speed <= 0 ||
        ![self.player respondsToSelector:@selector(setAnimationSpeed:)]) return NO;
    self.player.animationSpeed = speed;
    return YES;
}

- (BOOL)setAnimationColors:(NSDictionary<NSString *, UIColor *> *)colors {
    if (![NSThread isMainThread] || ![self.player respondsToSelector:@selector(applyColors:traitCollection:)]) return NO;
    [self.player applyColors:colors traitCollection:self.traitCollection];
    return YES;
}

@end
