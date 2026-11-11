//
//  CYLGIFPlaceholderItemAnimator.m
//  CYLTableViewPlaceHolder
//
//  Adapted from CYLTabBarController (`CYLGIFTabBarItemAnimator`, branch
//  feat/cross-platform-components), MIT License,
//  Copyright © 2026 https://github.com/ChenYilong . All rights reserved.
//

#import "CYLGIFPlaceholderItemAnimator.h"
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

#if CYL_PLACEHOLDER_GIF_AVAILABLE

#import <ImageIO/ImageIO.h>
#import <math.h>

static NSString *const CYLGIFPlaceholderPlayAnimationKey = @"CYLGIFPlaceholderItemPlayAnimation";
/// Decoding limits shared with Core's built-in decoder.
static const unsigned long long CYLGIFPlaceholderMaximumInputBytes = 16 * 1024 * 1024;
static const size_t CYLGIFPlaceholderMaximumFrames = 500;
static const uint64_t CYLGIFPlaceholderMaximumPixelBytes = 64 * 1024 * 1024;

@interface CYLGIFPlaceholderItemAnimationView : UIImageView <CYLPlaceholderItemAnimationPlayableView, CYLPlaceholderItemAnimationViewProviding>
@property (nonatomic, copy) NSArray<UIImage *> *frames;
/// 0 loops until stopped; 1 (the default) plays once.
@property (nonatomic) NSInteger repeatCount;
@property (nonatomic, copy) NSArray<NSNumber *> *frameDelays;
@end

@implementation CYLGIFPlaceholderItemAnimationView

+ (nullable UIView<CYLPlaceholderItemAnimationPlayableView> *)cyl_animationViewWithFileURL:(NSURL *)fileURL
                                                                                  options:(NSDictionary<NSString *, NSString *> *)options
                                                                              contentMode:(UIViewContentMode)contentMode {
    NSNumber *fileSize = nil;
    if (!fileURL.isFileURL || ![fileURL getResourceValue:&fileSize forKey:NSURLFileSizeKey error:NULL] ||
        fileSize.unsignedLongLongValue > CYLGIFPlaceholderMaximumInputBytes) {
        return nil;
    }
    NSData *data = [NSData dataWithContentsOfURL:fileURL options:0 error:NULL];
    if (data.length == 0 || data.length > CYLGIFPlaceholderMaximumInputBytes) {
        return nil;
    }
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    if (!source) {
        return nil;
    }
    size_t count = CGImageSourceGetCount(source);
    if (!CGImageSourceGetType(source) || !CFEqual(CGImageSourceGetType(source), CFSTR("com.compuserve.gif")) ||
        count == 0 || count > CYLGIFPlaceholderMaximumFrames) {
        CFRelease(source);
        return nil;
    }
    NSMutableArray<UIImage *> *frames = [NSMutableArray arrayWithCapacity:count];
    NSMutableArray<NSNumber *> *frameDelays = [NSMutableArray arrayWithCapacity:count];
    uint64_t pixelBytes = 0;
    for (size_t index = 0; index < count; index++) {
        NSDictionary *properties = CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source, index, NULL));
        uint64_t width = [properties[(__bridge NSString *)kCGImagePropertyPixelWidth] unsignedLongLongValue];
        uint64_t height = [properties[(__bridge NSString *)kCGImagePropertyPixelHeight] unsignedLongLongValue];
        if (width == 0 || height == 0 || width > 4096 || height > 4096 ||
            width * height * 4 > CYLGIFPlaceholderMaximumPixelBytes - pixelBytes) {
            CFRelease(source);
            return nil;
        }
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, index, NULL);
        if (!imageRef) {
            continue;
        }
        pixelBytes += width * height * 4;
        [frames addObject:[UIImage imageWithCGImage:imageRef]];
        CGImageRelease(imageRef);
        NSDictionary *gif = properties[(__bridge NSString *)kCGImagePropertyGIFDictionary];
        NSNumber *delay = gif[(__bridge NSString *)kCGImagePropertyGIFUnclampedDelayTime] ?:
            gif[(__bridge NSString *)kCGImagePropertyGIFDelayTime];
        double seconds = delay.doubleValue;
        // Browsers' rule, as in CYLTabBarController: delays under 20 ms play at 100 ms.
        [frameDelays addObject:@(isfinite(seconds) && seconds >= 0.02 ? seconds : 0.1)];
    }
    CFRelease(source);
    if (frames.count == 0) {
        return nil;
    }
    CYLGIFPlaceholderItemAnimationView *view = [[self alloc] initWithImage:frames.firstObject];
    view.frames = frames;
    view.repeatCount = 1;
    view.frameDelays = frameDelays;
    view.contentMode = contentMode;
    return view;
}

- (void)cyl_playAnimationView {
    [self.layer removeAnimationForKey:CYLGIFPlaceholderPlayAnimationKey];
    self.image = self.frames.lastObject;
    if (self.frames.count < 2) {
        return;
    }
    double duration = [[self.frameDelays valueForKeyPath:@"@sum.self"] doubleValue];
    NSMutableArray *contents = [NSMutableArray arrayWithCapacity:self.frames.count];
    NSMutableArray<NSNumber *> *keyTimes = [NSMutableArray arrayWithCapacity:self.frames.count + 1];
    double elapsed = 0;
    for (NSUInteger index = 0; index < self.frames.count; index++) {
        [contents addObject:(__bridge id)self.frames[index].CGImage];
        [keyTimes addObject:@(elapsed / duration)];
        elapsed += self.frameDelays[index].doubleValue;
    }
    // Discrete keyframes need one more value than intervals: hold the last frame at the end.
    [contents addObject:(__bridge id)self.frames.lastObject.CGImage];
    [keyTimes addObject:@1];
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    animation.calculationMode = kCAAnimationDiscrete;
    animation.values = contents;
    animation.keyTimes = keyTimes;
    animation.duration = duration;
    animation.repeatCount = self.repeatCount == 0 ? HUGE_VALF : (float)self.repeatCount;
    [self.layer addAnimation:animation forKey:CYLGIFPlaceholderPlayAnimationKey];
}

- (BOOL)cyl_setAnimationViewRepeatCount:(NSInteger)repeatCount {
    if (repeatCount < 0) return NO;
    self.repeatCount = repeatCount;
    return YES;
}

- (void)cyl_showAnimationViewLastFrame {
    [self.layer removeAnimationForKey:CYLGIFPlaceholderPlayAnimationKey];
    self.image = self.frames.lastObject;
}

- (void)cyl_stopAnimationView {
    [self.layer removeAnimationForKey:CYLGIFPlaceholderPlayAnimationKey];
    self.image = self.frames.firstObject;
}

@end

@implementation CYLGIFPlaceholderItemAnimator

+ (CYLPlaceholderItemViewAnimator *)animator {
    static CYLPlaceholderItemViewAnimator *animator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        animator = [[CYLPlaceholderItemViewAnimator alloc] initWithIdentifier:@"GIF"
                                                               fileExtensions:@[ @"gif" ]
                                                                attributeKeys:@{
            CYLPlaceholderItemAnimationURL : CYLPlaceholderItemGIFURL,
            CYLPlaceholderItemAnimationFilePath : CYLPlaceholderItemGIFFilePath,
            CYLPlaceholderItemAnimationSize : CYLPlaceholderItemGIFSize,
            CYLPlaceholderItemAnimationDarkURL : CYLPlaceholderItemGIFDarkURL,
            CYLPlaceholderItemAnimationDarkFilePath : CYLPlaceholderItemGIFDarkFilePath,
        }
                                                                 viewProvider:[CYLGIFPlaceholderItemAnimationView class]];
    });
    return animator;
}

+ (void)load {
    [CYLPlaceholderItemAnimatorRegistry registerAnimator:self.animator];
}

@end

#endif
