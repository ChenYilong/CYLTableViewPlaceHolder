#import "CYLPlaceholderView.h"

static NSBundle *CYLPlaceholderResourceBundle(void) {
    NSBundle *container = [NSBundle bundleForClass:CYLPlaceholderView.class];
    NSURL *url = [container URLForResource:@"CYLTableViewPlaceHolder" withExtension:@"bundle"];
    if (!url) url = [NSBundle.mainBundle URLForResource:@"CYLTableViewPlaceHolder" withExtension:@"bundle"];
    NSBundle *bundle = url ? [NSBundle bundleWithURL:url] : nil;
    if (!bundle) NSLog(@"CYLTableViewPlaceHolder: placeholder resource bundle not found.");
    return bundle;
}

@implementation CYLPlaceholderView

+ (NSString *)imageNameForStyle:(CYLPlaceholderStyle)style {
    static NSArray<NSString *> *names;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        names = @[
            @"Empty", @"NoResults", @"Error", @"WifiOff", @"SignalWifiOff", @"NoInternet",
            @"CloudOff", @"SyncProblem", @"SyncDisabled", @"NetworkLocked", @"BluetoothDisabled",
            @"LocationOff", @"PublicOff", @"ErrorOutline", @"Warning", @"ReportProblem", @"Blocked",
            @"Help", @"Hourglass", @"Locked", @"VisibilityOff", @"SearchOff", @"FolderOff",
            @"FolderOpen", @"DownloadOff", @"UploadOff", @"Inbox", @"BrokenImage", @"ImageUnavailable",
            @"PhotoLibrary", @"MusicOff", @"VideoOff", @"PersonOff", @"GroupOff", @"EventBusy",
            @"EmptyCart", @"Favorite", @"BatteryAlert", @"UnknownDevice", @"PhoneDisabled",
            @"WrongLocation", @"Archive", @"Info", @"Refresh", @"Delete", @"Search", @"Mail",
            @"Image", @"Cloud", @"NotificationsOff", @"History"
        ];
    });
    if (style < 0 || style >= names.count) {
        NSLog(@"CYLTableViewPlaceHolder: invalid placeholder style %ld.", (long)style);
        return nil;
    }
    return [@"CYLPlaceholder" stringByAppendingString:names[style]];
}

+ (UIImage *)imageForStyle:(CYLPlaceholderStyle)style {
    NSString *name = [self imageNameForStyle:style];
    if (!name) return nil;
    NSBundle *bundle = CYLPlaceholderResourceBundle();
    if (!bundle) return nil;
    UIImage *image = [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
    if (!image) {
        NSLog(@"CYLTableViewPlaceHolder: missing placeholder image %@.", name);
        return nil;
    }
    return style == CYLPlaceholderStyleEmpty ? image : [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

+ (NSString *)localizedTextForMessage:(CYLPlaceholderMessage)message {
    static NSArray<NSString *> *keys;
    static NSArray<NSString *> *fallbacks;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keys = @[@"CYLPlaceholderEmptyText", @"CYLPlaceholderNoResultsText", @"CYLPlaceholderNoInternetText",
                 @"CYLPlaceholderServerUnavailableText", @"CYLPlaceholderErrorText", @"CYLPlaceholderLoadingText",
                 @"CYLPlaceholderNoPermissionText", @"CYLPlaceholderEmptyCartText", @"CYLPlaceholderNoNotificationsText"];
        fallbacks = @[@"Nothing here yet", @"No results found", @"No internet connection",
                      @"Server unavailable", @"Something went wrong", @"Loading",
                      @"Access unavailable", @"Your cart is empty", @"No notifications"];
    });
    if (message < 0 || message >= keys.count) {
        NSLog(@"CYLTableViewPlaceHolder: invalid placeholder message %ld.", (long)message);
        return nil;
    }
    NSBundle *bundle = CYLPlaceholderResourceBundle();
    if (!bundle) return fallbacks[message];
    NSArray<NSString *> *languages = @[@"en", @"zh-Hans", @"zh-Hant", @"ja"];
    NSString *language = [NSBundle preferredLocalizationsFromArray:languages
                                                    forPreferences:NSLocale.preferredLanguages].firstObject;
    NSString *path = [bundle pathForResource:language ofType:@"lproj"];
    NSBundle *localizedBundle = path ? [NSBundle bundleWithPath:path] : nil;
    if (!localizedBundle) {
        NSLog(@"CYLTableViewPlaceHolder: localization %@ is missing.", language);
        return fallbacks[message];
    }
    return [localizedBundle localizedStringForKey:keys[message] value:fallbacks[message] table:nil];
}

- (instancetype)initWithStyle:(CYLPlaceholderStyle)style message:(CYLPlaceholderMessage)message {
    return [self initWithImage:[CYLPlaceholderView imageForStyle:style]
                         text:[CYLPlaceholderView localizedTextForMessage:message]];
}

- (instancetype)initWithStyle:(CYLPlaceholderStyle)style text:(NSString *)text {
    return [self initWithImage:[CYLPlaceholderView imageForStyle:style] text:text];
}

- (instancetype)initWithImage:(UIImage *)image text:(NSString *)text {
    self = [self initWithFrame:CGRectZero];
    if (self) {
        self.imageView.image = image;
        self.imageView.hidden = image == nil;
        self.textLabel.text = text;
        self.textLabel.hidden = text == nil;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithImage:[CYLPlaceholderView imageForStyle:CYLPlaceholderStyleEmpty]];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.tintColor = UIColor.grayColor;
        _textLabel = [UILabel new];
        _textLabel.text = [CYLPlaceholderView localizedTextForMessage:CYLPlaceholderMessageEmpty];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.numberOfLines = 0;
        _textLabel.textColor = UIColor.grayColor;
        UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[_imageView, _textLabel]];
        stack.axis = UILayoutConstraintAxisVertical;
        stack.spacing = 12;
        stack.alignment = UIStackViewAlignmentCenter;
        stack.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:stack];
        NSLayoutConstraint *imageHeight = [_imageView.heightAnchor constraintEqualToConstant:80];
        imageHeight.priority = UILayoutPriorityDefaultHigh;
        [NSLayoutConstraint activateConstraints:@[
            [stack.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [stack.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
            [stack.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.leadingAnchor constant:16],
            [stack.trailingAnchor constraintLessThanOrEqualToAnchor:self.trailingAnchor constant:-16],
            [_imageView.widthAnchor constraintEqualToConstant:80],
            imageHeight
        ]];
    }
    return self;
}

@end
