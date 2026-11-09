//
//  CYLPlaceholderItemAnimationService.h
//  CYLTableViewPlaceHolder
//
//  Adapted from CYLTabBarController (`CYLTabBarItemAnimationService.h`, branch
//  feat/cross-platform-components), MIT License,
//  Copyright © 2026 https://github.com/ChenYilong . All rights reserved.
//
//  Internal interface between Core and the `CYLPlaceholderItemAnimation`
//  subspec; not public API. Core owns the protocol and only calls it; the
//  subspec's `CYLPlaceholderItemAnimationEngine` implements it and installs
//  itself from `+load`, so Core never links an animation library.
//

#import "CYLPlaceholderView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CYLPlaceholderItemAnimationService <NSObject>
/// YES when a registered animator plays the file (by binding or extension).
- (BOOL)canAnimateFileAtURL:(NSURL *)URL;
/// A host view for the file, or nil with an error in `CYLPlaceholderAnimationErrorDomain`.
- (nullable UIView<CYLPlaceholderAnimationPlayer> *)animationViewWithFileURL:(NSURL *)URL
                                                                       size:(CGSize)size
                                                                contentMode:(UIViewContentMode)contentMode
                                                                    options:(NSDictionary<NSString *, id> *)options
                                                                      error:(NSError * _Nullable * _Nullable)error;
/// The lowercase extensions of every registered animator.
- (NSArray<NSString *> *)animationFileExtensions;
@end

FOUNDATION_EXTERN void CYLPlaceholderItemAnimationSetService(id<CYLPlaceholderItemAnimationService> _Nullable service);
FOUNDATION_EXTERN id<CYLPlaceholderItemAnimationService> _Nullable CYLPlaceholderItemAnimationGetService(void);

NS_ASSUME_NONNULL_END
