//
//  CYLPlaceholderItemAnimatorRegistry.m
//  CYLTableViewPlaceHolder
//
//  Adapted from CYLTabBarController (`CYLTabBarItemAnimation/`, branch
//  feat/cross-platform-components), MIT License,
//  Copyright © 2026 https://github.com/ChenYilong . All rights reserved.
//

#import "CYLPlaceholderItemAnimatorRegistry.h"

/// [EN] YES when `attributes` give a value for one of `animator`'s own keys. [CN] `attributes` 为 `animator` 自己的某个 key 提供了值时返回 YES。
static BOOL CYLPlaceholderItemAnimatorKeysHaveValue(id<CYLPlaceholderItemAnimator> animator, NSDictionary *attributes) {
    if (![animator respondsToSelector:@selector(attributeKeys)]) {
        return NO;
    }
    for (NSString *key in animator.attributeKeys.allValues) {
        if ([key isKindOfClass:[NSString class]] && key.length > 0 && attributes[key] != nil) {
            return YES;
        }
    }
    return NO;
}

static CYLPlaceholderItemAnimatorPriority CYLPlaceholderItemAnimatorPriorityOf(id<CYLPlaceholderItemAnimator> animator) {
    return [animator respondsToSelector:@selector(priority)] ? animator.priority : CYLPlaceholderItemAnimatorPriorityDefault;
}

@implementation CYLPlaceholderItemAnimatorRegistry {
    /// [EN] The animators in registration order; under `@synchronized (self)`. [CN] 按注册顺序保存的 animator；在 `@synchronized (self)` 下读写。
    NSMutableArray<id<CYLPlaceholderItemAnimator>> *_registeredAnimators;
    /// [EN] URL (absolute string) -> identifier of the animator a tab's keys chose for it; under `@synchronized (self)`.
    /// [CN] URL（absoluteString）-> Tab 的 key 为其选择的 animator 名称；在 `@synchronized (self)` 下读写。
    NSMutableDictionary<NSString *, NSString *> *_boundIdentifiers;
}

+ (instancetype)sharedRegistry {
    static CYLPlaceholderItemAnimatorRegistry *sharedRegistry;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedRegistry = [[self alloc] init];
    });
    return sharedRegistry;
}

- (instancetype)init {
    if (self = [super init]) {
        _registeredAnimators = [NSMutableArray array];
        _boundIdentifiers = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Class methods (the shared registry) 类方法（共享注册表）

+ (void)registerAnimator:(id<CYLPlaceholderItemAnimator>)animator {
    [[self sharedRegistry] registerAnimator:animator];
}

+ (void)unregisterAnimatorWithIdentifier:(NSString *)identifier {
    [[self sharedRegistry] unregisterAnimatorWithIdentifier:identifier];
}

+ (NSArray<id<CYLPlaceholderItemAnimator>> *)animators {
    return [[self sharedRegistry] animators];
}

+ (id<CYLPlaceholderItemAnimator>)animatorWithIdentifier:(NSString *)identifier {
    return [[self sharedRegistry] animatorWithIdentifier:identifier];
}

+ (id<CYLPlaceholderItemAnimator>)animatorForURL:(NSURL *)URL {
    return [[self sharedRegistry] animatorForURL:URL];
}

+ (id<CYLPlaceholderItemAnimator>)animatorForAttributes:(NSDictionary *)attributes {
    return [[self sharedRegistry] animatorForAttributes:attributes];
}

+ (NSString *)attributeKeyForGenericKey:(NSString *)genericKey inAttributes:(NSDictionary *)attributes {
    return [[self sharedRegistry] attributeKeyForGenericKey:genericKey inAttributes:attributes];
}

+ (void)bindURL:(NSURL *)URL toAnimator:(id<CYLPlaceholderItemAnimator>)animator {
    [[self sharedRegistry] bindURL:URL toAnimator:animator];
}

+ (NSArray<NSString *> *)attributeKeysForGenericKey:(NSString *)genericKey {
    return [[self sharedRegistry] attributeKeysForGenericKey:genericKey];
}

+ (NSArray<NSString *> *)fileExtensions {
    return [[self sharedRegistry] fileExtensions];
}

#pragma mark - CYLPlaceholderItemAnimatorRegistering

- (void)registerAnimator:(id<CYLPlaceholderItemAnimator>)animator {
    if (![animator conformsToProtocol:@protocol(CYLPlaceholderItemAnimator)] || animator.identifier.length == 0) {
        return;
    }
    @synchronized (self) {
        NSMutableArray<id<CYLPlaceholderItemAnimator>> *animators = _registeredAnimators;
        NSUInteger index = [animators indexOfObjectPassingTest:^BOOL(id<CYLPlaceholderItemAnimator> obj, NSUInteger idx, BOOL *stop) {
            return [obj.identifier isEqualToString:animator.identifier];
        }];
        if (index == NSNotFound) {
            [animators addObject:animator];
        } else {
            [animators replaceObjectAtIndex:index withObject:animator];
        }
    }
}

- (void)unregisterAnimatorWithIdentifier:(NSString *)identifier {
    if (identifier.length == 0) {
        return;
    }
    @synchronized (self) {
        NSMutableArray<id<CYLPlaceholderItemAnimator>> *animators = _registeredAnimators;
        NSIndexSet *indexes = [animators indexesOfObjectsPassingTest:^BOOL(id<CYLPlaceholderItemAnimator> obj, NSUInteger idx, BOOL *stop) {
            return [obj.identifier isEqualToString:identifier];
        }];
        [animators removeObjectsAtIndexes:indexes];
    }
}

- (NSArray<id<CYLPlaceholderItemAnimator>> *)animators {
    NSArray<id<CYLPlaceholderItemAnimator>> *animators;
    @synchronized (self) {
        animators = [_registeredAnimators copy];
    }
    // A stable sort: equal priorities keep their registration order. 稳定排序：相同优先级保持注册顺序。
    return [animators sortedArrayWithOptions:NSSortStable usingComparator:^NSComparisonResult(id<CYLPlaceholderItemAnimator> a, id<CYLPlaceholderItemAnimator> b) {
        CYLPlaceholderItemAnimatorPriority priorityA = CYLPlaceholderItemAnimatorPriorityOf(a);
        CYLPlaceholderItemAnimatorPriority priorityB = CYLPlaceholderItemAnimatorPriorityOf(b);
        if (priorityA == priorityB) {
            return NSOrderedSame;
        }
        return priorityA > priorityB ? NSOrderedAscending : NSOrderedDescending;
    }];
}

- (id<CYLPlaceholderItemAnimator>)animatorWithIdentifier:(NSString *)identifier {
    for (id<CYLPlaceholderItemAnimator> animator in [self animators]) {
        if ([animator.identifier isEqualToString:identifier]) {
            return animator;
        }
    }
    return nil;
}

- (id<CYLPlaceholderItemAnimator>)animatorForURL:(NSURL *)URL {
    if (!URL) {
        return nil;
    }
    // [EN] First: the library a tab's keys chose for this URL, if it is still registered.
    // [CN] 首先：Tab 的 key 为该 URL 选择的动画库（仍已注册时）。
    NSString *boundIdentifier;
    @synchronized (self) {
        boundIdentifier = _boundIdentifiers[URL.absoluteString];
    }
    id<CYLPlaceholderItemAnimator> boundAnimator = boundIdentifier ? [self animatorWithIdentifier:boundIdentifier] : nil;
    if (boundAnimator) {
        return boundAnimator;
    }
    for (id<CYLPlaceholderItemAnimator> animator in [self animators]) {
        if ([animator canAnimateFileAtURL:URL]) {
            return animator;
        }
    }
    return nil;
}

- (id<CYLPlaceholderItemAnimator>)animatorForAttributes:(NSDictionary *)attributes {
    if (![attributes isKindOfClass:[NSDictionary class]] || attributes.count == 0) {
        return nil;
    }
    id<CYLPlaceholderItemAnimator> chosen = nil;
    for (id<CYLPlaceholderItemAnimator> animator in [self animators]) {
        if (!CYLPlaceholderItemAnimatorKeysHaveValue(animator, attributes)) {
            continue;
        }
        if (!chosen) {
            chosen = animator;
            continue;
        }
#if defined(DEBUG)
        NSLog(@"[CYLTableViewPlaceHolder] A placeholder item uses the keys of both %@ and %@; %@ is used.", chosen.identifier, animator.identifier, chosen.identifier);
#endif
        break;
    }
    return chosen;
}

- (NSString *)attributeKeyForGenericKey:(NSString *)genericKey inAttributes:(NSDictionary *)attributes {
    id<CYLPlaceholderItemAnimator> animator = [self animatorForAttributes:attributes];
    if (genericKey.length == 0 || ![animator respondsToSelector:@selector(attributeKeys)]) {
        return nil;
    }
    NSString *key = animator.attributeKeys[genericKey];
    return ([key isKindOfClass:[NSString class]] && key.length > 0) ? key : nil;
}

- (void)bindURL:(NSURL *)URL toAnimator:(id<CYLPlaceholderItemAnimator>)animator {
    NSString *key = [URL isKindOfClass:[NSURL class]] ? URL.absoluteString : nil;
    if (key.length == 0) {
        return;
    }
    @synchronized (self) {
        _boundIdentifiers[key] = animator.identifier.length > 0 ? animator.identifier : nil;
    }
}

- (NSArray<NSString *> *)attributeKeysForGenericKey:(NSString *)genericKey {
    NSMutableArray<NSString *> *keys = [NSMutableArray array];
    for (id<CYLPlaceholderItemAnimator> animator in [self animators]) {
        if (![animator respondsToSelector:@selector(attributeKeys)]) {
            continue;
        }
        NSString *key = animator.attributeKeys[genericKey];
        if ([key isKindOfClass:[NSString class]] && key.length > 0 && ![keys containsObject:key]) {
            [keys addObject:key];
        }
    }
    return [keys copy];
}

- (NSArray<NSString *> *)fileExtensions {
    NSMutableArray<NSString *> *extensions = [NSMutableArray array];
    for (id<CYLPlaceholderItemAnimator> animator in [self animators]) {
        if (![animator respondsToSelector:@selector(fileExtensions)]) {
            continue;
        }
        for (NSString *extension in animator.fileExtensions) {
            NSString *lowercaseExtension = [extension isKindOfClass:[NSString class]] ? extension.lowercaseString : nil;
            if (lowercaseExtension.length > 0 && ![extensions containsObject:lowercaseExtension]) {
                [extensions addObject:lowercaseExtension];
            }
        }
    }
    return [extensions copy];
}

@end
