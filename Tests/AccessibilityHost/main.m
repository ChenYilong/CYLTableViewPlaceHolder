//
//  main.m
//  CYLTableViewPlaceHolder accessibility host
//
//  A minimal app for `Tests/run-accessibility-tests.rb`: XCUITest reads the
//  accessibility tree VoiceOver reads, and runs Apple's accessibility audit.
//

#import <UIKit/UIKit.h>
#import "CYLPlaceholderView.h"

@interface CYLAccessibilityHostViewController : UIViewController
@property (nonatomic, strong) CYLPlaceholderView *element;
@property (nonatomic, strong) CYLPlaceholderView *grouped;
@end

@implementation CYLAccessibilityHostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemBackgroundColor;

    // 1. A configured placeholder: it is itself an accessibility element.
    NSError *error = nil;
    self.element = [[CYLPlaceholderView alloc] initWithItemAttributes:@{
        CYLPlaceholderItemStyle: @(CYLPlaceholderStyleInbox),
        CYLPlaceholderItemTitle: @"Inbox",
        CYLPlaceholderItemAccessibilityIdentifier: @"element",
        CYLPlaceholderItemAccessibilityHint: @"No messages yet",
        CYLPlaceholderItemTitleColor: UIColor.labelColor,
        CYLPlaceholderItemTitleFont: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]
    } imageBundle:nil error:&error];
    NSAssert(self.element, @"%@", error);
    self.element.accessibilityValue = @"Synced";
    self.element.badgeValue = @"3";
    self.element.badgeLabel.accessibilityIdentifier = @"elementBadge";

    // 2. A plain placeholder inside an accessible container: the badge is read on its own.
    UIView *group = [[UIView alloc] init];
    group.accessibilityContainerType = UIAccessibilityContainerTypeSemanticGroup;
    group.accessibilityLabel = @"Notifications";
    group.accessibilityIdentifier = @"group";
    self.grouped = [[CYLPlaceholderView alloc] initWithStyle:CYLPlaceholderStyleNotificationsOff text:@"Nothing new"];
    self.grouped.textLabel.textColor = UIColor.labelColor;
    self.grouped.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.grouped.textLabel.accessibilityIdentifier = @"groupTitle";
    [self.grouped showBadgeWithStyle:CYLPlaceholderBadgeStyleText value:@"New"];
    self.grouped.badgeLabel.accessibilityIdentifier = @"groupBadge";
    [group addSubview:self.grouped];

    UIButton *toggle = [UIButton buttonWithType:UIButtonTypeSystem];
    [toggle setTitle:@"Toggle selection" forState:UIControlStateNormal];
    toggle.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    toggle.titleLabel.adjustsFontForContentSizeCategory = YES;
    toggle.accessibilityIdentifier = @"toggle";
    [toggle addTarget:self action:@selector(toggleSelection) forControlEvents:UIControlEventTouchUpInside];

    UIButton *clear = [UIButton buttonWithType:UIButtonTypeSystem];
    [clear setTitle:@"Clear badges" forState:UIControlStateNormal];
    clear.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    clear.titleLabel.adjustsFontForContentSizeCategory = YES;
    clear.accessibilityIdentifier = @"clear";
    [clear addTarget:self action:@selector(clearBadges) forControlEvents:UIControlEventTouchUpInside];

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[self.element, group, toggle, clear]];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.distribution = UIStackViewDistributionFill;
    stack.spacing = 12;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:stack];
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [stack.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:16],
        [stack.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-16],
        [stack.topAnchor constraintEqualToAnchor:safe.topAnchor constant:16],
        [stack.bottomAnchor constraintLessThanOrEqualToAnchor:safe.bottomAnchor constant:-16],
        [self.element.heightAnchor constraintEqualToConstant:220],
        [group.heightAnchor constraintEqualToConstant:220],
    ]];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.grouped.frame = self.grouped.superview.bounds;
}

- (void)toggleSelection {
    self.element.selected = !self.element.selected;
}

- (void)clearBadges {
    self.element.badgeValue = nil;
    self.grouped.badgeValue = nil;
}

@end

@interface CYLAccessibilityHostAppDelegate : UIResponder <UIApplicationDelegate>
@property (nonatomic, strong) UIWindow *window;
@end

@implementation CYLAccessibilityHostAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = [[CYLAccessibilityHostViewController alloc] init];
    [self.window makeKeyAndVisible];
    return YES;
}

@end

int main(int argc, char *argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass(CYLAccessibilityHostAppDelegate.class));
    }
}
