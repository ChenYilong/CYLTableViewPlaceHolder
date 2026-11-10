//
//  CYLScenarioListViewController.m
//  Example-Scenarios
//

#import "CYLScenarioListViewController.h"
#import "CYLScenario.h"
#import "CYLScenarioDetailViewController.h"
#import "CYLScenarioCollectionViewController.h"

static NSString *const CYLScenarioCellIdentifier = @"scenario";

@interface CYLScenarioListViewController ()
@property (nonatomic, copy) NSArray<NSDictionary *> *sections;
@end

@implementation CYLScenarioListViewController

- (instancetype)initWithSections:(NSArray<NSDictionary *> *)sections {
    if (self = [super initWithStyle:UITableViewStyleInsetGrouped]) {
        _sections = [sections copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:CYLScenarioCellIdentifier];
    self.tableView.accessibilityIdentifier = @"scenarioList";
}

- (CYLScenario *)scenarioAtIndexPath:(NSIndexPath *)indexPath {
    return self.sections[indexPath.section][@"items"][indexPath.row];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.sections[section][@"items"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sections[section][@"title"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CYLScenarioCellIdentifier forIndexPath:indexPath];
    CYLScenario *scenario = [self scenarioAtIndexPath:indexPath];
    UIListContentConfiguration *content = [UIListContentConfiguration subtitleCellConfiguration];
    content.text = scenario.title;
    content.secondaryText = scenario.detail;
    content.secondaryTextProperties.color = UIColor.secondaryLabelColor;
    content.image = [UIImage systemImageNamed:scenario.symbolName] ?: [UIImage systemImageNamed:@"square.dashed"];
    content.imageProperties.tintColor = UIColor.systemTealColor;
    cell.contentConfiguration = content;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.accessibilityIdentifier = scenario.title;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CYLScenario *scenario = [self scenarioAtIndexPath:indexPath];
    UIViewController *next = scenario.flow == CYLScenarioFlowCollectionView
        ? [[CYLScenarioCollectionViewController alloc] initWithScenario:scenario]
        : [[CYLScenarioDetailViewController alloc] initWithScenario:scenario];
    [self.navigationController pushViewController:next animated:YES];
}

@end
