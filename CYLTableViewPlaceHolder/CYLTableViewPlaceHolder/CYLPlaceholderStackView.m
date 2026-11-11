//
//  CYLPlaceholderStackView.m
//  CYLTableViewPlaceHolder
//

#import "CYLPlaceholderStackView.h"

/// Side margin between the view and its components.
static const CGFloat CYLPlaceholderStackMargin = 16;

@interface CYLPlaceholderStackView () <UIGestureRecognizerDelegate>
@property (nonatomic, strong, readwrite) UIStackView *stackView;
@property (nonatomic, readwrite) CYLPlaceholderScenario scenario;
@property (nonatomic, strong) NSMutableArray<CYLPlaceholderView *> *mutableComponentViews;
/// Parallel to `mutableComponentViews`: each component's action, or NSNull.
@property (nonatomic, strong) NSMutableArray *componentActions;
@property (nonatomic, strong) NSMutableDictionary<CYLPlaceholderAction, CYLPlaceholderActionHandler> *handlers;
@property (nonatomic, strong) UITapGestureRecognizer *backgroundTapRecognizer;
@end

/// Applies the shared component fields ("action", "interactionEnabled", "highlightStyle", "repeatCount", …).
@interface CYLPlaceholderComponent (CYLStackConfiguration)
- (BOOL)cyl_applyConfiguration:(NSDictionary<NSString *, id> *)dictionary error:(NSError **)error;
@end

static NSError *CYLStackConfigurationError(NSString *description) {
    return [NSError errorWithDomain:@"CYLPlaceholderConfigurationError" code:3
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

        _stackView = [[UIStackView alloc] init];
        _stackView.axis = UILayoutConstraintAxisVertical;
        _stackView.alignment = UIStackViewAlignmentCenter;
        _stackView.distribution = UIStackViewDistributionFill;
        _stackView.spacing = 16;
        _stackView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_stackView];
        [NSLayoutConstraint activateConstraints:@[
            [_stackView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [_stackView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
            [_stackView.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.leadingAnchor
                                                                  constant:CYLPlaceholderStackMargin],
            [_stackView.topAnchor constraintGreaterThanOrEqualToAnchor:self.topAnchor constant:CYLPlaceholderStackMargin],
        ]];

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
    return view;
}

- (void)appendComponentView:(CYLPlaceholderView *)view action:(CYLPlaceholderAction)action spacingBefore:(CGFloat)spacingBefore {
    if (!view || [self.mutableComponentViews indexOfObjectIdenticalTo:view] != NSNotFound) return;
    view.reportsContentSize = YES;
    view.preferredMaxLayoutWidth = [self cyl_componentMaxWidth];
    [view setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [view setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    UIView *previous = self.stackView.arrangedSubviews.lastObject;
    [self.stackView addArrangedSubview:view];
    if (previous) [self.stackView setCustomSpacing:MAX(0, spacingBefore) afterView:previous];
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
    // [EN] VoiceOver users reach the background action through the reserved component.
    // [CN] VoiceOver 用户通过保留组件触发背景点击动作。
    CYLPlaceholderView *reserved = self.placeholderView;
    if (reserved && !reserved.isTapInteractive) {
        if (backgroundAction) {
            reserved.isAccessibilityElement = YES;
            reserved.accessibilityTraits |= UIAccessibilityTraitButton;
        } else {
            reserved.accessibilityTraits &= ~UIAccessibilityTraitButton;
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
