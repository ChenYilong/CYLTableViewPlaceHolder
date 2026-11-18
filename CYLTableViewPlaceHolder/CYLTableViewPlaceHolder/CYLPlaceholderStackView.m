//
//  CYLPlaceholderStackView.m
//  CYLTableViewPlaceHolder
//

#import "CYLPlaceholderStackView.h"
// [EN] The generated Swift interface of CYLPlaceholderView (Swift since 2026-11-19). [CN] CYLPlaceholderView 的 Swift 接口。
#import "CYLTableViewPlaceHolder.h"
#import "CYLPlaceholderLocalization.h"

/// Side margin between the view and its components.
static const CGFloat CYLPlaceholderStackMargin = 16;

@interface CYLPlaceholderStackView () <UIGestureRecognizerDelegate>
/// [EN] CYLTabBarController's CYLAnimatedItemStackView, every element a CYLAnimatedItemView (each component is a
///      CYLPlaceholderView): it lays the components out (centered vertical stack, side margins, spacing before each
///      component, titles wrapped to the width) and groups them for VoiceOver. This view keeps the components' own tap
///      events (`tapHandler`, `tapInteractionEnabled`) and the background action, so their behavior is unchanged; the
///      inner stack gets the actions (for `itemViewForAction:` and the button trait) but no handlers, so nothing runs twice.
/// [CN] CYLTabBarController 的 CYLAnimatedItemStackView，每个元素都是 CYLAnimatedItemView（每个组件是 CYLPlaceholderView）：
///      它负责组件布局（居中的竖直堆叠、两侧边距、组件前的间距、标题按宽度换行）并为 VoiceOver 分组。本视图保留组件自己的点击事件
///      （`tapHandler`、`tapInteractionEnabled`）与背景动作，行为不变；内部堆叠视图知道各动作（用于 `itemViewForAction:` 与按钮 trait），
///      但没有处理，因此不会执行两次。
@property (nonatomic, strong) CYLAnimatedItemStackView *itemStack;
@property (nonatomic, readwrite) CYLPlaceholderScenario scenario;
@property (nonatomic, strong) NSMutableArray<CYLPlaceholderView *> *mutableComponentViews;
/// Parallel to `mutableComponentViews`: each component's action, or NSNull.
@property (nonatomic, strong) NSMutableArray *componentActions;
/// [EN] Each component view's kind ("item", "hint", "button", "separator"), for `hintLabel` and `button`.
/// [CN] 每个组件视图的种类，供 `hintLabel` 与 `button` 使用。
@property (nonatomic, strong) NSMapTable<CYLPlaceholderView *, NSString *> *componentKinds;
@property (nonatomic, strong) NSMutableDictionary<CYLPlaceholderAction, CYLPlaceholderActionHandler> *handlers;
@property (nonatomic, strong) UITapGestureRecognizer *backgroundTapRecognizer;
@end

/// The factory that made a component ("item", "hint", "button", "separator"), set in CYLPlaceholderScenario.m.
@interface CYLPlaceholderComponent (CYLStackKind)
@property (nonatomic, copy) NSString *cyl_kind;
@end

/// Applies the shared component fields ("action", "interactionEnabled", "highlightStyle", "repeatCount", …).
@interface CYLPlaceholderComponent (CYLStackConfiguration)
- (BOOL)cyl_applyConfiguration:(NSDictionary<NSString *, id> *)dictionary error:(NSError **)error;
@end

static NSError *CYLStackConfigurationError(NSString *description) {
    return [NSError errorWithDomain:CYLPlaceholderConfigurationErrorDomain code:CYLPlaceholderConfigurationErrorStackView
                           userInfo:@{NSLocalizedDescriptionKey: description}];
}

@implementation CYLPlaceholderStackView

- (instancetype)initWithScenario:(CYLPlaceholderScenario)scenario
                         actions:(NSDictionary<CYLPlaceholderAction, CYLPlaceholderActionHandler> *)actions {
    self = [self initWithComponents:[CYLPlaceholderScenarioCatalog componentsForScenario:scenario] actions:actions];
    if (self) {
        _scenario = scenario;
        self.backgroundAction = [CYLPlaceholderScenarioCatalog backgroundActionForScenario:scenario];
        self.accessibilityIdentifier = [NSString stringWithFormat:@"CYLPlaceholderScenario%ld", (long)scenario];
    }
    return self;
}

- (instancetype)initWithContentsOfURL:(NSURL *)url
                              actions:(NSDictionary<CYLPlaceholderAction, CYLPlaceholderActionHandler> *)actions
                                error:(NSError **)error {
    if (!url.isFileURL) {
        if (error) *error = CYLStackConfigurationError(@"The configuration URL must be a local file.");
        return nil;
    }
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:error];
    if (!data) return nil;
    id configuration = [url.pathExtension.lowercaseString isEqualToString:@"json"] ?
        [NSJSONSerialization JSONObjectWithData:data options:0 error:error] :
        [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:error];
    if (!configuration) return nil;
    return [self initWithConfiguration:configuration actions:actions error:error];
}

- (instancetype)initWithConfiguration:(NSDictionary<NSString *, id> *)configuration
                              actions:(NSDictionary<CYLPlaceholderAction, CYLPlaceholderActionHandler> *)actions
                                error:(NSError **)error {
    if (![configuration isKindOfClass:NSDictionary.class]) {
        if (error) *error = CYLStackConfigurationError(@"The configuration must be a dictionary.");
        return nil;
    }
    CYLPlaceholderScenario scenario = CYLPlaceholderScenarioCount;
    id scenarioName = configuration[@"scenario"];
    if (scenarioName) {
        scenario = [scenarioName isKindOfClass:NSString.class] ? [CYLPlaceholderScenarioCatalog scenarioNamed:scenarioName] :
            CYLPlaceholderScenarioCount;
        if (scenario == CYLPlaceholderScenarioCount) {
            if (error) *error = CYLStackConfigurationError([NSString stringWithFormat:@"Unknown scenario %@.", scenarioName]);
            return nil;
        }
    }
    NSMutableArray<CYLPlaceholderComponent *> *components = [NSMutableArray array];
    id componentList = configuration[@"components"];
    if (componentList) {
        if (![componentList isKindOfClass:NSArray.class] || [componentList count] == 0) {
            if (error) *error = CYLStackConfigurationError(@"\"components\" must be a non-empty array.");
            return nil;
        }
        for (id dictionary in componentList) {
            CYLPlaceholderComponent *component = [CYLPlaceholderComponent componentWithDictionary:dictionary error:error];
            if (!component) return nil;
            [components addObject:component];
        }
    } else if (scenario != CYLPlaceholderScenarioCount) {
        for (CYLPlaceholderComponent *component in [CYLPlaceholderScenarioCatalog componentsForScenario:scenario]) {
            [components addObject:[component copy]];
        }
    } else {
        if (error) *error = CYLStackConfigurationError(@"The configuration needs a \"scenario\" or \"components\".");
        return nil;
    }
    id overrides = configuration[@"overrides"];
    if (overrides && ![overrides isKindOfClass:NSArray.class]) {
        if (error) *error = CYLStackConfigurationError(@"\"overrides\" must be an array.");
        return nil;
    }
    for (id override in overrides) {
        id index = [override isKindOfClass:NSDictionary.class] ? override[@"index"] : nil;
        if (![index isKindOfClass:NSNumber.class] || [index integerValue] < 0 ||
            [index integerValue] >= (NSInteger)components.count) {
            if (error) *error = CYLStackConfigurationError(@"Each override needs the \"index\" of an existing component.");
            return nil;
        }
        NSMutableDictionary *fields = [override mutableCopy];
        [fields removeObjectForKey:@"index"];
        if (![components[[index integerValue]] cyl_applyConfiguration:fields error:error]) return nil;
    }
    id background = configuration[@"backgroundAction"];
    if (background && ![background isKindOfClass:NSString.class]) {
        if (error) *error = CYLStackConfigurationError(@"\"backgroundAction\" must be an action name.");
        return nil;
    }
    self = [self initWithComponents:components actions:actions];
    if (self) {
        _scenario = scenario;
        if (background) {
            self.backgroundAction = [background length] ? [CYLPlaceholderScenarioCatalog actionNamed:background] : nil;
        } else if (scenario != CYLPlaceholderScenarioCount) {
            self.backgroundAction = [CYLPlaceholderScenarioCatalog backgroundActionForScenario:scenario];
        }
        id identifier = configuration[@"accessibilityIdentifier"];
        if ([identifier isKindOfClass:NSString.class]) self.accessibilityIdentifier = identifier;
    }
    return self;
}

- (instancetype)initWithComponents:(NSArray<CYLPlaceholderComponent *> *)components
                           actions:(NSDictionary<CYLPlaceholderAction, CYLPlaceholderActionHandler> *)actions {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _scenario = CYLPlaceholderScenarioCount;
        _mutableComponentViews = [NSMutableArray array];
        _componentActions = [NSMutableArray array];
        _handlers = [NSMutableDictionary dictionary];
        [actions enumerateKeysAndObjectsUsingBlock:^(CYLPlaceholderAction action, CYLPlaceholderActionHandler handler,
                                                     BOOL *stop) {
            self->_handlers[action] = [handler copy];
        }];

        _itemStack = [[CYLAnimatedItemStackView alloc] initWithFrame:CGRectZero];
        _itemStack.contentMargin = CYLPlaceholderStackMargin;
        _itemStack.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_itemStack];
        [NSLayoutConstraint activateConstraints:@[
            [_itemStack.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [_itemStack.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [_itemStack.topAnchor constraintEqualToAnchor:self.topAnchor],
            [_itemStack.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        ]];
        // [EN] VoiceOver reads the components together, top to bottom, before what is behind the placeholder.
        // [CN] VoiceOver 自上而下连续朗读这些组件，再朗读占位视图后面的内容。
        self.shouldGroupAccessibilityChildren = YES;

        for (CYLPlaceholderComponent *component in components) {
            CYLPlaceholderView *view = [self appendComponent:component];
            if (!view && _mutableComponentViews.count == 0) {
                // [EN] The reserved component must exist: fall back to the default icon and title.
                // [CN] 保留组件必须存在：回退为默认的图标和标题。
                [self appendComponentView:[[CYLPlaceholderView alloc] initWithFrame:CGRectZero] action:nil spacingBefore:0];
            }
        }
        if (_mutableComponentViews.count == 0) {
            [self appendComponentView:[[CYLPlaceholderView alloc] initWithFrame:CGRectZero] action:nil spacingBefore:0];
        }
    }
    return self;
}

// [EN] Unavailable in the header; implemented so the superclass's designated initializers are covered.
// [CN] 头文件中标记为不可用；这里实现以覆盖父类的指定初始化方法。
- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithComponents:@[] actions:nil];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    return [self initWithComponents:@[] actions:nil];
}

#pragma mark - Components

- (UIStackView *)stackView {
    return self.itemStack.stackView;
}

- (CYLPlaceholderView *)placeholderView {
    return self.mutableComponentViews.firstObject;
}

- (NSArray<CYLPlaceholderView *> *)componentViews {
    return [self.mutableComponentViews copy];
}

- (CYLPlaceholderView *)appendComponent:(CYLPlaceholderComponent *)component {
    NSError *error = nil;
    CYLPlaceholderView *view = [[CYLPlaceholderView alloc] initWithItemAttributes:component.attributes
                                                                     imageBundle:component.imageBundle
                                                                           error:&error];
    if (!view) {
        NSLog(@"CYLTableViewPlaceHolder: component not added: %@", error.localizedDescription);
        return nil;
    }
    [self appendComponentView:view action:component.action spacingBefore:component.spacingBefore];
    NSString *kind = [component respondsToSelector:@selector(cyl_kind)] ? component.cyl_kind : nil;
    if (kind) {
        if (!self.componentKinds) self.componentKinds = [NSMapTable weakToStrongObjectsMapTable];
        [self.componentKinds setObject:kind forKey:view];
    }
    return view;
}

- (NSString *)cyl_kindOfComponentView:(CYLPlaceholderView *)view {
    return [self.componentKinds objectForKey:view] ?: @"item";
}

- (UIImageView *)imageView {
    for (CYLPlaceholderView *view in self.mutableComponentViews) {
        if (view.imageView.image && !view.imageView.hidden) return view.imageView;
    }
    return self.placeholderView.imageView;
}

- (UILabel *)titleLabel {
    for (CYLPlaceholderView *view in self.mutableComponentViews) {
        if ([[self cyl_kindOfComponentView:view] isEqualToString:@"item"] && view.textLabel.text.length) return view.textLabel;
    }
    return self.placeholderView.textLabel;
}

- (UILabel *)hintLabel {
    for (CYLPlaceholderView *view in self.mutableComponentViews) {
        if ([[self cyl_kindOfComponentView:view] isEqualToString:@"hint"]) return view.textLabel;
    }
    return nil;
}

- (CYLPlaceholderView *)button {
    for (CYLPlaceholderView *view in self.mutableComponentViews) {
        if ([[self cyl_kindOfComponentView:view] isEqualToString:@"button"]) return view;
    }
    return nil;
}

- (void)appendComponentView:(CYLPlaceholderView *)view action:(CYLPlaceholderAction)action spacingBefore:(CGFloat)spacingBefore {
    if (!view || [self.mutableComponentViews indexOfObjectIdenticalTo:view] != NSNotFound) return;
    view.reportsContentSize = YES;
    view.preferredMaxLayoutWidth = [self cyl_componentMaxWidth];
    [view setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [view setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.itemStack appendItemView:view action:action spacingBefore:spacingBefore];
    // [EN] The inner stack lets only items with an action take touches; a component keeps its own tap event (an app can
    //      set `tapHandler` later), and one that is not tap-interactive passes the tap to the background recognizer.
    // [CN] 内部堆叠视图只让带动作的条目接收触摸；组件保留自己的点击事件（应用可以之后再设置 `tapHandler`），不可点击的组件把点击交给背景手势。
    view.userInteractionEnabled = YES;
    [self.mutableComponentViews addObject:view];
    [self.componentActions addObject:action ?: (id)NSNull.null];
    if (action) {
        // [EN] The component's own tap event performs the action; whether it runs, and whether the tap highlights,
        //      is the component's `tapInteractionEnabled` (`CYLPlaceholderItemInteractionEnabled`).
        // [CN] 由组件自己的点击事件执行动作；是否执行、点击是否高亮，取决于组件的 `tapInteractionEnabled`
        //      （`CYLPlaceholderItemInteractionEnabled`）。
        __weak typeof(self) weakSelf = self;
        CYLPlaceholderAction copiedAction = [action copy];
        view.tapHandler = ^(CYLPlaceholderView *placeholderView) {
            [weakSelf performAction:copiedAction];
        };
    }
    [self cyl_updateAccessibilityOfComponent:view];
}

/// [EN] Decorative components (an icon or illustration with no title, label or tap event) are hidden from VoiceOver,
///      so it reads only text and controls; every component speaks the language the core texts use.
/// [CN] 装饰性组件（没有标题、无障碍标签或点击事件的图标、插图）对 VoiceOver 隐藏，只朗读文字与控件；所有组件都使用核心文案的语言朗读。
- (void)cyl_updateAccessibilityOfComponent:(CYLPlaceholderView *)view {
    if (CYLPlaceholderLocalization.language) view.accessibilityLanguage = CYLPlaceholderLocalization.effectiveLanguage;
    BOOL speaks = view.textLabel.text.length > 0 && !view.textLabel.hidden;
    BOOL labeled = view.accessibilityLabel.length > 0 || speaks;
    BOOL actsOnBackground = view == self.placeholderView && self.backgroundAction != nil;
    if (!view.tapHandler && !labeled && !actsOnBackground) {
        view.isAccessibilityElement = NO;
        view.accessibilityElementsHidden = YES;
    }
}

- (CYLPlaceholderView *)componentViewForAction:(CYLPlaceholderAction)action {
    if (!action) return nil;
    for (NSUInteger index = 0; index < self.componentActions.count; index++) {
        id componentAction = self.componentActions[index];
        if (componentAction != NSNull.null && [componentAction isEqualToString:action]) {
            return self.mutableComponentViews[index];
        }
    }
    return nil;
}

#pragma mark - Actions

- (void)setHandler:(CYLPlaceholderActionHandler)handler forAction:(CYLPlaceholderAction)action {
    if (!action) return;
    self.handlers[action] = [handler copy];
}

- (BOOL)performAction:(CYLPlaceholderAction)action {
    CYLPlaceholderActionHandler handler = action ? self.handlers[action] : nil;
    if (!handler) return NO;
    handler(self, action);
    return YES;
}

- (void)setBackgroundAction:(CYLPlaceholderAction)backgroundAction {
    _backgroundAction = [backgroundAction copy];
    if (backgroundAction && !self.backgroundTapRecognizer) {
        self.backgroundTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(cyl_backgroundTapped:)];
        self.backgroundTapRecognizer.delegate = self;
        [self addGestureRecognizer:self.backgroundTapRecognizer];
    }
    self.backgroundTapRecognizer.enabled = backgroundAction != nil;
    // [EN] The inner stack knows the background action too, so it keeps the reserved component a button when it reads
    //      the component's accessibility again (a title or label change). Its own background recognizer stays off: this
    //      view performs the action and lets a component that is not tap-interactive pass the tap (the inner stack would
    //      skip every component with an action).
    // [CN] 内部堆叠视图也知道背景动作，重新读取组件无障碍信息时（标题或标签变化）保留组件仍是按钮。它自己的背景手势保持关闭：由本视图执行动作，
    //      并让不可点击的组件把点击交给背景（内部堆叠视图会跳过所有带动作的组件）。
    self.itemStack.backgroundAction = backgroundAction;
    for (UIGestureRecognizer *recognizer in self.itemStack.gestureRecognizers) {
        if ([recognizer isKindOfClass:UITapGestureRecognizer.class]) recognizer.enabled = NO;
    }
    // [EN] VoiceOver users reach the background action through the reserved component.
    // [CN] VoiceOver 用户通过保留组件触发背景点击动作。
    CYLPlaceholderView *reserved = self.placeholderView;
    if (reserved && !reserved.isTapInteractive) {
        if (backgroundAction) {
            reserved.isAccessibilityElement = YES;
            reserved.accessibilityElementsHidden = NO;
            reserved.accessibilityTraits |= UIAccessibilityTraitButton;
            // [EN] An icon-only reserved component is named after the action. [CN] 只有图标的保留组件以动作名称命名。
            if (!reserved.accessibilityLabel.length) {
                reserved.accessibilityLabel = [CYLPlaceholderScenarioCatalog localizedTitleForAction:backgroundAction];
            }
        } else {
            reserved.accessibilityTraits &= ~UIAccessibilityTraitButton;
            [self cyl_updateAccessibilityOfComponent:reserved];
        }
    }
}

- (void)cyl_backgroundTapped:(UITapGestureRecognizer *)recognizer {
    if (self.backgroundAction) [self performAction:self.backgroundAction];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer != self.backgroundTapRecognizer) return YES;
    // [EN] A tappable component handles its own taps; one with interaction turned off lets the background act.
    // [CN] 可点击的组件自己处理点击；关闭了交互的组件让背景处理。
    for (UIView *view = touch.view; view && view != self; view = view.superview) {
        if ([view isKindOfClass:CYLPlaceholderView.class] && ((CYLPlaceholderView *)view).isTapInteractive) return NO;
    }
    return YES;
}

- (BOOL)accessibilityActivate {
    if (!self.backgroundAction) return NO;
    return [self performAction:self.backgroundAction];
}

#pragma mark - Layout

- (CGFloat)cyl_componentMaxWidth {
    CGFloat width = CGRectGetWidth(self.bounds);
    return width > 0 ? MAX(0, width - 2 * CYLPlaceholderStackMargin) : 0;
}

- (void)layoutSubviews {
    CGFloat maxWidth = [self cyl_componentMaxWidth];
    for (CYLPlaceholderView *view in self.mutableComponentViews) {
        view.preferredMaxLayoutWidth = maxWidth;
    }
    [super layoutSubviews];
}

@end
