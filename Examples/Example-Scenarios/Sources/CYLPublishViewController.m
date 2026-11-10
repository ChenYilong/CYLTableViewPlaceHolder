//
//  CYLPublishViewController.m
//  Example-Scenarios
//

#import "CYLPublishViewController.h"
#import "CYLScenarioLocalization.h"
#import "CYLScenario.h"
#import <CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.h>

@interface CYLPublishViewController ()
@property (nonatomic, strong) UIView *placeholder;
@end

@implementation CYLPublishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = CYLScenarioLocalizedString(CYLScenarioL10nActionPublish);
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemClose target:self action:@selector(close)];
    NSMutableDictionary *attributes = [@{
        CYLPlaceholderItemTitle: CYLScenarioLocalizedString(CYLScenarioL10nAnimUploading),
        CYLPlaceholderItemStyle: @(CYLPlaceholderStyleUploadOff),
        CYLPlaceholderItemAnimationSize: @[@120, @120],
    } mutableCopy];
    NSString *gif = [CYLPlaceholderView pathForBundledAnimation:@"CYLPlaceholderUploading.gif"];
    if (gif) attributes[CYLPlaceholderItemGIFFilePath] = gif;
    [self showPlaceholder:[[CYLPlaceholderView alloc] initWithItemAttributes:attributes imageBundle:nil error:NULL]];
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf showPlaceholder:[CYLScenario celebrationScenario].makePlaceholder()];
    });
}

- (void)showPlaceholder:(UIView *)placeholder {
    if (!placeholder) return;
    [self.placeholder removeFromSuperview];
    self.placeholder = placeholder;
    placeholder.frame = self.view.bounds;
    placeholder.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:placeholder];
}

- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
