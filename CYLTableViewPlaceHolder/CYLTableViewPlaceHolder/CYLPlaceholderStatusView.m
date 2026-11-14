//
//  CYLPlaceholderStatusView.m
//  CYLTableViewPlaceHolder
//
//  [EN] Adapted from LCCKStatusView of CYLChatKit (https://github.com/ChenYilong/CYLChatKit, commit b730b8d,
//       ChatKit/Class/View/LCCKStatusView.m). Original header: "v2.1.1 Created by ElonChan on 16/3/11.
//       Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved." Repository license: MIT,
//       Copyright (c) 2016 LeanCloud (LICENSE.CYLChatKit in the resource bundle). The icon,
//       CYLPlaceholderStatusFail@2x/@3x.png, is ChatKit's MessageBubble.bundle/MessageSendFail, unmodified.
//  [CN] 改编自 CYLChatKit 的 LCCKStatusView（MIT），保留原作者与版权信息；图标为 ChatKit 的 MessageSendFail，未修改。
//

#import "CYLPlaceholderStatusView.h"
#import "CYLPlaceholderLocalization.h"

const CGFloat CYLPlaceholderStatusViewHight = 44;
const CGFloat CYLPlaceholderStatusViewHeight = 44;

/// [EN] The icon is 28 points; ChatKit draws it at 20. [CN] 图标原始为 28 点；ChatKit 以 20 点绘制。
static const CGFloat CYLPlaceholderStatusIconInset = 4;
/// [EN] Space above and below the text when Dynamic Type makes it tall. [CN] 动态字体变大时文字上下的留白。
static const CGFloat CYLPlaceholderStatusVerticalPadding = 12;

/// [EN] ChatKit's pink, rgb(255, 199, 199); a dark red in Dark Mode. [CN] ChatKit 的粉红色；深色模式下为暗红色。
static UIColor *CYLPlaceholderStatusBackgroundColor(void) {
    UIColor *light = [UIColor colorWithRed:255 / 255.0 green:199 / 255.0 blue:199 / 255.0 alpha:1];
    if (@available(iOS 13.0, *)) {
        UIColor *dark = [UIColor colorWithRed:90 / 255.0 green:30 / 255.0 blue:30 / 255.0 alpha:1];
        return [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection *traits) {
            return traits.userInterfaceStyle == UIUserInterfaceStyleDark ? dark : light;
        }];
    }
    return light;
}

/*!
 * [EN] ChatKit used gray (about 3:1 on the pink); #555555 keeps the look and reaches 4.9:1 (WCAG AA). Light pink text in
 *      Dark Mode. [CN] ChatKit 使用灰色（在粉红背景上约 3:1）；#555555 保持观感并达到 4.9:1（WCAG AA）。深色模式下为浅粉色文字。
 */
static UIColor *CYLPlaceholderStatusTextColor(void) {
    UIColor *light = [UIColor colorWithWhite:0x55 / 255.0 alpha:1];
    if (@available(iOS 13.0, *)) {
        UIColor *dark = [UIColor colorWithRed:242 / 255.0 green:208 / 255.0 blue:208 / 255.0 alpha:1];
        return [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection *traits) {
            return traits.userInterfaceStyle == UIUserInterfaceStyleDark ? dark : light;
        }];
    }
    return light;
}

static NSError *CYLStatusConfigurationError(NSString *description) {
    return [NSError errorWithDomain:@"CYLPlaceholderConfigurationError" code:4
                           userInfo:@{NSLocalizedDescriptionKey: description}];
}

@interface CYLPlaceholderStatusView ()
@property (nonatomic, strong, readwrite) CYLPlaceholderView *placeholderView;
- (instancetype)initWithFrame:(CGRect)frame
                        itemAttributes:(NSDictionary<NSString *, id> *)attributes
                                 error:(NSError **)error;
@end

@implementation CYLPlaceholderStatusView

+ (NSDictionary<NSString *, id> *)networkUnavailableItemAttributes {
    NSMutableDictionary<NSString *, id> *attributes = [NSMutableDictionary dictionary];
    attributes[CYLPlaceholderItemTitle] = CYLPlaceholderLocalizedString(@"CYLPlaceholderStatusNetworkUnavailable",
                                                                        @"Network unavailable, Check network");
    UIImage *icon = [UIImage imageNamed:@"CYLPlaceholderStatusFail" inBundle:CYLPlaceholderResourceBundle()
          compatibleWithTraitCollection:nil];
    if (icon) attributes[CYLPlaceholderItemImage] = icon;
    attributes[CYLPlaceholderItemImageInsets] = [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(
        CYLPlaceholderStatusIconInset, CYLPlaceholderStatusIconInset, CYLPlaceholderStatusIconInset, CYLPlaceholderStatusIconInset)];
    attributes[CYLPlaceholderItemTitleColor] = CYLPlaceholderStatusTextColor();
    attributes[CYLPlaceholderItemTitleFont] = [[UIFontMetrics defaultMetrics] scaledFontForFont:[UIFont systemFontOfSize:15]];
    attributes[CYLPlaceholderItemBackgroundColor] = CYLPlaceholderStatusBackgroundColor();
    attributes[CYLPlaceholderItemContentAxis] = @"horizontal";
    attributes[CYLPlaceholderItemAccessibilityIdentifier] = @"CYLPlaceholderStatusView";
    return [attributes copy];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [self initWithFrame:frame itemAttributes:CYLPlaceholderStatusView.networkUnavailableItemAttributes error:NULL];
    NSAssert(self, @"The network status bar attributes are valid.");
    return self;
}

- (instancetype)initWithItemAttributes:(NSDictionary<NSString *, id> *)attributes error:(NSError **)error {
    NSMutableDictionary<NSString *, id> *merged = [CYLPlaceholderStatusView.networkUnavailableItemAttributes mutableCopy];
    [merged addEntriesFromDictionary:attributes ?: @{}];
    // [EN] A custom image or style replaces the failure icon and its insets. [CN] 自定义图片或样式替换失败图标及其内边距。
    if (attributes[CYLPlaceholderItemImage] || attributes[CYLPlaceholderItemStyle]) {
        if (!attributes[CYLPlaceholderItemImage]) [merged removeObjectForKey:CYLPlaceholderItemImage];
        if (!attributes[CYLPlaceholderItemImageInsets]) [merged removeObjectForKey:CYLPlaceholderItemImageInsets];
    }
    merged[CYLPlaceholderItemContentAxis] = @"horizontal";
    return [self initWithFrame:CGRectMake(0, 0, 0, CYLPlaceholderStatusViewHight) itemAttributes:merged error:error];
}

/// [EN] The shared initializer (in the init family, so it may assign self). [CN] 共用的初始化方法。
- (instancetype)initWithFrame:(CGRect)frame
                        itemAttributes:(NSDictionary<NSString *, id> *)attributes
                                 error:(NSError **)error {
    NSMutableDictionary<NSString *, id> *content = [attributes mutableCopy];
    // [EN] The red belongs to this view (the parent); the component on it is transparent.
    // [CN] 红色属于本视图（父视图）；其上的组件是透明的。
    id background = content[CYLPlaceholderItemBackgroundColor];
    content[CYLPlaceholderItemBackgroundColor] = UIColor.clearColor;
    CYLPlaceholderView *placeholderView = [[CYLPlaceholderView alloc] initWithItemAttributes:content imageBundle:nil error:error];
    if (!placeholderView) return nil;
    self = [super initWithFrame:frame];
    if (self) {
        // [EN] As LCCKStatusView: the bar stretches with its superview's width. [CN] 与 LCCKStatusView 相同：随父视图宽度拉伸。
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [background isKindOfClass:UIColor.class] ? background : CYLPlaceholderStatusBackgroundColor();
        placeholderView.backgroundColor = UIColor.clearColor;
        placeholderView.reportsContentSize = YES;
        placeholderView.frame = self.bounds;
        placeholderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        placeholderView.textLabel.adjustsFontForContentSizeCategory = YES;
        [self addSubview:placeholderView];
        _placeholderView = placeholderView;
        [self cyl_updateTapHandling];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    return [self initWithFrame:CGRectMake(0, 0, 0, CYLPlaceholderStatusViewHight)];
}

- (instancetype)initWithConfiguration:(NSDictionary<NSString *, id> *)configuration error:(NSError **)error {
    if (![configuration isKindOfClass:NSDictionary.class]) {
        if (error) *error = CYLStatusConfigurationError(@"The status bar configuration must be a dictionary.");
        return nil;
    }
    NSDictionary<NSString *, NSString *> *keys = @{
        @"image": CYLPlaceholderItemImage, @"titleColor": CYLPlaceholderItemTitleColor,
        @"backgroundColor": CYLPlaceholderItemBackgroundColor,
        @"accessibilityIdentifier": CYLPlaceholderItemAccessibilityIdentifier,
    };
    NSMutableDictionary<NSString *, id> *attributes = [NSMutableDictionary dictionary];
    for (NSString *key in @[@"text", @"textKey", @"image", @"titleColor", @"backgroundColor", @"accessibilityIdentifier"]) {
        id value = configuration[key];
        if (!value) continue;
        if (![value isKindOfClass:NSString.class]) {
            if (error) *error = CYLStatusConfigurationError([NSString stringWithFormat:@"\"%@\" must be a string.", key]);
            return nil;
        }
        if (keys[key]) attributes[keys[key]] = value;
    }
    NSString *text = configuration[@"text"];
    if (configuration[@"textKey"]) text = CYLPlaceholderLocalizedString(configuration[@"textKey"], text);
    if (text) attributes[CYLPlaceholderItemTitle] = text;
    return [self initWithItemAttributes:attributes error:error];
}

#pragma mark - Text

- (NSString *)text {
    return self.placeholderView.textLabel.text;
}

- (void)setText:(NSString *)text {
    self.placeholderView.textLabel.text = text;
    [self.placeholderView invalidateIntrinsicContentSize];
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
}

#pragma mark - Taps

- (void)setDelegate:(id<CYLPlaceholderStatusViewDelegate>)delegate {
    _delegate = delegate;
    [self cyl_updateTapHandling];
}

- (void)setTapHandler:(CYLPlaceholderStatusViewTapHandler)tapHandler {
    _tapHandler = [tapHandler copy];
    [self cyl_updateTapHandling];
}

/// [EN] Tappable only when someone listens, so VoiceOver does not offer a button that does nothing.
/// [CN] 只有在有人接收点击时才可点击，避免 VoiceOver 提供一个无效的按钮。
- (void)cyl_updateTapHandling {
    BOOL listens = self.tapHandler != nil || [self.delegate respondsToSelector:@selector(statusViewClicked:)];
    if (!listens) {
        self.placeholderView.tapHandler = nil;
        return;
    }
    __weak typeof(self) weakSelf = self;
    self.placeholderView.tapHandler = ^(CYLPlaceholderView *view) {
        [weakSelf cyl_handleTap];
    };
}

- (void)cyl_handleTap {
    id<CYLPlaceholderStatusViewDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(statusViewClicked:)]) [delegate statusViewClicked:self];
    if (self.tapHandler) self.tapHandler(self);
}

#pragma mark - Layout

- (CGSize)intrinsicContentSize {
    CGFloat height = CYLPlaceholderStatusViewHight;
    CGSize content = self.placeholderView.intrinsicContentSize;
    if (content.height > 0) height = MAX(height, ceil(content.height) + CYLPlaceholderStatusVerticalPadding);
    return CGSizeMake(UIViewNoIntrinsicMetric, height);
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(size.width, self.intrinsicContentSize.height);
}

- (void)layoutSubviews {
    CGFloat width = CGRectGetWidth(self.bounds);
    if (width > 0 && self.placeholderView.preferredMaxLayoutWidth != width) {
        self.placeholderView.preferredMaxLayoutWidth = width;
        [self invalidateIntrinsicContentSize];
    }
    [super layoutSubviews];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (![previousTraitCollection.preferredContentSizeCategory isEqualToString:self.traitCollection.preferredContentSizeCategory]) {
        [self.placeholderView invalidateIntrinsicContentSize];
        [self invalidateIntrinsicContentSize];
    }
}

@end
