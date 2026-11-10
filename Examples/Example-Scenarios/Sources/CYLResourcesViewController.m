//
//  CYLResourcesViewController.m
//  Example-Scenarios
//

#import "CYLResourcesViewController.h"
#import "CYLScenarioLocalization.h"
#import "CYLScenario.h"
#import "CYLScenarioDetailViewController.h"
#import <CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.h>

static NSString *const CYLResourceCellIdentifier = @"resource";

@interface CYLResourcesViewController ()
@property (nonatomic, copy) NSArray<NSString *> *fileNames;
@end

@implementation CYLResourcesViewController

- (instancetype)init {
    return [super initWithStyle:UITableViewStyleInsetGrouped];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fileNames = [CYLPlaceholderView bundledAnimationFileNames];
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:CYLResourceCellIdentifier];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:CYLScenarioLocalizedString(CYLScenarioL10nActionSources)
        style:UIBarButtonItemStylePlain target:self action:@selector(showNotice)];
    // The empty state of this list, should the bundle be missing.
    [self.tableView cyl_placeholderViewBlock:^UIView *(UITableView *tableView) {
        return [[CYLPlaceholderView alloc] initWithStyle:CYLPlaceholderStyleFolderOff text:CYLScenarioLocalizedString(CYLScenarioL10nTextNoAnimations)];
    }];
}

- (void)showNotice {
    NSString *path = [CYLPlaceholderView pathForBundledAnimation:self.fileNames.firstObject ?: @""];
    NSString *notice = path ? [NSString stringWithContentsOfFile:[path.stringByDeletingLastPathComponent
        stringByAppendingPathComponent:@"NOTICE.animations"] encoding:NSUTF8StringEncoding error:NULL] : nil;
    UIViewController *controller = [UIViewController new];
    controller.title = @"NOTICE.animations";
    UITextView *textView = [UITextView new];
    textView.editable = NO;
    textView.font = [UIFont monospacedSystemFontOfSize:12 weight:UIFontWeightRegular];
    textView.text = notice ?: CYLScenarioLocalizedString(CYLScenarioL10nTextNoticeMissing);
    controller.view = textView;
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fileNames.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.fileNames.count ? @"CYLTableViewPlaceHolder.bundle/Animations" : nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"+[CYLPlaceholderView bundledAnimationFileNames] / +pathForBundledAnimation:";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CYLResourceCellIdentifier forIndexPath:indexPath];
    NSString *name = self.fileNames[indexPath.row];
    NSString *path = [CYLPlaceholderView pathForBundledAnimation:name];
    unsigned long long bytes = path ? [[NSFileManager.defaultManager attributesOfItemAtPath:path error:NULL] fileSize] : 0;
    NSString *engine = @{@"json": @"Lottie", @"pag": @"PAG", @"riv": @"Rive", @"gif": @"GIF"}[name.pathExtension] ?: @"?";
    UIListContentConfiguration *content = [UIListContentConfiguration subtitleCellConfiguration];
    content.text = name;
    content.secondaryText = [NSString stringWithFormat:@"%@ · %@", engine,
        [NSByteCountFormatter stringFromByteCount:(long long)bytes countStyle:NSByteCountFormatterCountStyleFile]];
    content.secondaryTextProperties.color = UIColor.secondaryLabelColor;
    cell.contentConfiguration = content;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *name = self.fileNames[indexPath.row];
    for (NSDictionary *section in [CYLScenario animationSections]) {
        for (CYLScenario *scenario in section[@"items"]) {
            if ([scenario.detail isEqualToString:name]) {
                [self.navigationController pushViewController:[[CYLScenarioDetailViewController alloc] initWithScenario:scenario]
                                                     animated:YES];
                return;
            }
        }
    }
}

@end
