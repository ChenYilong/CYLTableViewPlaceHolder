//
//  CYLPlaceholderAnimationView.h
//  CYLTableViewPlaceHolder
//
//  Animation adapter patterns are informed by CYLTabBarController, distributed
//  under the MIT License (Copyright (c) 2026 CYLTabBarController).
//

#import <UIKit/UIKit.h>
#import "CYLPlaceholderView.h"
#import "CYLPlaceholderItemAnimationPlayer.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSErrorDomain const CYLPlaceholderAnimationErrorDomain;

typedef NS_ERROR_ENUM(CYLPlaceholderAnimationErrorDomain, CYLPlaceholderAnimationErrorCode) {
    CYLPlaceholderAnimationErrorInvalidURL = 1,
    CYLPlaceholderAnimationErrorInvalidSize,
    CYLPlaceholderAnimationErrorUnsupportedFormat,
    CYLPlaceholderAnimationErrorBackendUnavailable,
    CYLPlaceholderAnimationErrorAssetLoadFailed,
    CYLPlaceholderAnimationErrorInvalidOptions
};

typedef NS_ENUM(NSInteger, CYLPlaceholderAnimationBackend) {
    CYLPlaceholderAnimationBackendLottie,
    CYLPlaceholderAnimationBackendPAG,
    CYLPlaceholderAnimationBackendRive,
    CYLPlaceholderAnimationBackendGIF,
    /// An animator registered by the app with `CYLPlaceholderItemAnimatorRegistry`.
    CYLPlaceholderAnimationBackendCustom
};

typedef void (^CYLPlaceholderAnimationErrorHandler)(NSError *error);

/// Hosts the view made by the animator that `CYLPlaceholderItemAnimatorRegistry`
/// picks for a local file, and drives it through that view's
/// `CYLPlaceholderItemAnimationPlayer`. Lottie, PAG, Rive and GIF animators come
/// from their own subspecs.
@interface CYLPlaceholderAnimationView : UIView <CYLPlaceholderAnimationPlayer>

@property (nonatomic, strong, readonly) UIView *animationView;
@property (nonatomic, strong, readonly) id<CYLPlaceholderItemAnimationPlayer> player;
/// The identifier of the animator that made `animationView` ("Lottie", "PAG", "Rive", "GIF", or a custom one).
@property (nonatomic, copy, readonly) NSString *animatorIdentifier;
@property (nonatomic, readonly) CYLPlaceholderAnimationBackend backend;
@property (nonatomic, readonly, getter=isPlaying) BOOL playing;
@property (nonatomic, readonly, getter=isReady) BOOL ready;
/// Reports failures that occur after creation, such as asynchronous Rive loading errors.
@property (nonatomic, copy, nullable) CYLPlaceholderAnimationErrorHandler errorHandler;
@property (nonatomic, copy, nullable) void (^readyHandler)(void);

- (nullable instancetype)initWithFileURL:(NSURL *)fileURL
                                    size:(CGSize)size
                             contentMode:(UIViewContentMode)contentMode
                                   error:(NSError * _Nullable * _Nullable)error;
/// Option values must be strings or numbers; they reach the animator in the URL fragment,
/// as in CYLTabBarController (`#artboard=Main&duration=1`).
- (nullable instancetype)initWithFileURL:(NSURL *)fileURL
                                    size:(CGSize)size
                             contentMode:(UIViewContentMode)contentMode
                                 options:(NSDictionary<NSString *, id> *)options
                                   error:(NSError * _Nullable * _Nullable)error NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

/// Plays once from the start. Call on the main thread.
- (void)play;
/// Stops and restores the resting frame/state.
- (void)stop;
/// Stops and displays the last frame where the engine supports it.
- (void)showLastFrame;
/// Return NO when the engine does not support the requested operation.
- (BOOL)setAnimationProgress:(CGFloat)progress;
- (BOOL)setAnimationSpeed:(CGFloat)speed;
- (BOOL)setAnimationColors:(NSDictionary<NSString *, UIColor *> *)colors;

@end

NS_ASSUME_NONNULL_END
