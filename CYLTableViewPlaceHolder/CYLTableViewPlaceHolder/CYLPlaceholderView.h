#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// A reusable, localized empty-state view. Customize its image and label as needed.
@interface CYLPlaceholderView : UIView
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UILabel *textLabel;
@end

NS_ASSUME_NONNULL_END
