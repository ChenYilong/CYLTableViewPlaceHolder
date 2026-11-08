//
//  CYLPlaceholderAnimationView.h
//  CYLTableViewPlaceHolder
//
//  Animation adapter patterns are informed by CYLTabBarController, distributed
//  under the MIT License (Copyright (c) 2026 CYLTabBarController).
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSErrorDomain const CYLPlaceholderAnimationErrorDomain;

typedef NS_ERROR_ENUM(CYLPlaceholderAnimationErrorDomain, CYLPlaceholderAnimationErrorCode) {
    CYLPlaceholderAnimationErrorInvalidURL = 1,
    CYLPlaceholderAnimationErrorInvalidSize,
    CYLPlaceholderAnimationErrorUnsupportedFormat,
    CYLPlaceholderAnimationErrorBackendUnavailable,
    CYLPlaceholderAnimationErrorAssetLoadFailed
};

typedef NS_ENUM(NSInteger, CYLPlaceholderAnimationBackend) {
    CYLPlaceholderAnimationBackendLottie,
    CYLPlaceholderAnimationBackendPAG,
    CYLPlaceholderAnimationBackendRive
};

typedef void (^CYLPlaceholderAnimationErrorHandler)(NSError *error);

/// A typed host view for an optional Lottie, PAG, or Rive animation backend.
/// The URL must point to a local `.json`, `.pag`, or `.riv` file.
@interface CYLPlaceholderAnimationView : UIView

@property (nonatomic, strong, readonly) UIView *animationView;
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
- (nullable instancetype)initWithFileURL:(NSURL *)fileURL
                                    size:(CGSize)size
                             contentMode:(UIViewContentMode)contentMode
                                 options:(NSDictionary<NSString *, id> *)options
                                   error:(NSError * _Nullable * _Nullable)error NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

/// Starts or resumes playback. Call on the main thread.
- (void)play;
/// Stops playback and restores the backend's resting frame/state. Call on the main thread.
- (void)stop;
/// Stops playback and displays the last frame where the backend supports it.
- (void)showLastFrame;
/// Return NO when this backend does not support the requested operation.
- (BOOL)setAnimationProgress:(CGFloat)progress;
- (BOOL)setAnimationSpeed:(CGFloat)speed;
- (BOOL)setAnimationColors:(NSDictionary<NSString *, UIColor *> *)colors;

@end

NS_ASSUME_NONNULL_END
