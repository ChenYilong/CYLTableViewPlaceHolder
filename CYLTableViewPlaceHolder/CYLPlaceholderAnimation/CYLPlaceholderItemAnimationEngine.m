//
//  CYLPlaceholderItemAnimationEngine.m
//  CYLTableViewPlaceHolder
//
//  Adapted from CYLTabBarController (`CYLTabBarItemAnimationEngine`, branch
//  feat/cross-platform-components), MIT License,
//  Copyright © 2026 https://github.com/ChenYilong . All rights reserved.
//

#import "CYLPlaceholderItemAnimationEngine.h"
#import "CYLPlaceholderAnimationView.h"

@implementation CYLPlaceholderItemAnimationEngine

/// Hands itself to Core when the subspec is linked (dependency inversion, as in CYLTabBarController).
+ (void)load {
    CYLPlaceholderItemAnimationSetService([[self alloc] init]);
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

- (BOOL)canAnimateFileAtURL:(NSURL *)URL {
    return [self.registry animatorForURL:URL] != nil;
}

- (UIView<CYLPlaceholderAnimationPlayer> *)animationViewWithFileURL:(NSURL *)URL
                                                               size:(CGSize)size
                                                        contentMode:(UIViewContentMode)contentMode
                                                            options:(NSDictionary<NSString *, id> *)options
                                                              error:(NSError **)error {
    return [[CYLPlaceholderAnimationView alloc] initWithFileURL:URL size:size contentMode:contentMode
                                                        options:options ?: @{} error:error];
}

- (NSArray<NSString *> *)animationFileExtensions {
    return [self.registry fileExtensions];
}

@end
