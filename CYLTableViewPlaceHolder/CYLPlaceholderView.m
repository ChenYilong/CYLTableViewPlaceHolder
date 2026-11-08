#import "CYLPlaceholderView.h"

@implementation CYLPlaceholderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSBundle *container = [NSBundle bundleForClass:CYLPlaceholderView.class];
        NSURL *url = [container URLForResource:@"CYLTableViewPlaceHolder" withExtension:@"bundle"];
        if (!url) url = [NSBundle.mainBundle URLForResource:@"CYLTableViewPlaceHolder" withExtension:@"bundle"];
        NSBundle *bundle = url ? [NSBundle bundleWithURL:url] : nil;
        if (!bundle) NSLog(@"CYLTableViewPlaceHolder: placeholder resource bundle not found.");

        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CYLPlaceholderEmpty"
                                                                   inBundle:bundle
                                              compatibleWithTraitCollection:nil]];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _textLabel = [UILabel new];
        _textLabel.text = bundle ? [bundle localizedStringForKey:@"CYLPlaceholderEmptyText"
                                                           value:@"No data"
                                                           table:nil] : @"No data";
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.numberOfLines = 0;
        _textLabel.textColor = UIColor.grayColor;
        UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[_imageView, _textLabel]];
        stack.axis = UILayoutConstraintAxisVertical;
        stack.spacing = 12;
        stack.alignment = UIStackViewAlignmentCenter;
        stack.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:stack];
        [NSLayoutConstraint activateConstraints:@[
            [stack.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [stack.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
            [stack.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.leadingAnchor constant:16],
            [stack.trailingAnchor constraintLessThanOrEqualToAnchor:self.trailingAnchor constant:-16],
            [_imageView.widthAnchor constraintEqualToConstant:80],
            [_imageView.heightAnchor constraintEqualToConstant:80]
        ]];
    }
    return self;
}

@end
