//
//  CYLScenario.h
//  Example-Scenarios
//
//  One placeholder scenario of the aggregated demo: what a list shows when it is empty, failed or loading.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// How the detail page drives the scenario.
typedef NS_ENUM(NSInteger, CYLScenarioFlow) {
    /// The placeholder alone (block API).
    CYLScenarioFlowStatic,
    /// A placeholder with an action button: tapping it shows loading, then data.
    CYLScenarioFlowRetry,
    /// A segmented control switches between empty, failed, offline and data (issue #3).
    CYLScenarioFlowSwitchStates,
    /// Delegate API with a custom frame below the table header (issue #17).
    CYLScenarioFlowKeepTableHeader,
    /// Delegate API with a custom frame below custom section headers (issue #16).
    CYLScenarioFlowKeepSectionHeaders,
    /// Pull to refresh and load more stay visible above a full-size placeholder (issue #8).
    CYLScenarioFlowRefreshControls,
    /// The table keeps scrolling while the placeholder shows (delegate API).
    CYLScenarioFlowScrollable,
    /// UICollectionView placeholder (issue #11).
    CYLScenarioFlowCollectionView,
    /// An animated placeholder (Lottie, PAG, Rive or GIF) with a replay button.
    CYLScenarioFlowAnimation,
};

@interface CYLScenario : NSObject

@property (nonatomic, copy) NSString *title;
/// The API the scenario uses, shown under the title.
@property (nonatomic, copy) NSString *detail;
/// SF Symbol shown in the list.
@property (nonatomic, copy) NSString *symbolName;
@property (nonatomic) CYLScenarioFlow flow;
/// Title of the button shown under the placeholder (retry, open settings…); nil for none.
@property (nonatomic, copy, nullable) NSString *actionTitle;
/// Creates a new placeholder view each time it is called.
@property (nonatomic, copy) UIView *(^makePlaceholder)(void);

/// Sections of the "Scenarios" tab: @{@"title": NSString, @"items": NSArray<CYLScenario *>}.
+ (NSArray<NSDictionary *> *)scenarioSections;
/// Sections of the "Animations" tab: one section per engine, one row per bundled animation.
+ (NSArray<NSDictionary *> *)animationSections;
/// The animated "published" scenario the plus button presents.
+ (CYLScenario *)celebrationScenario;

@end

NS_ASSUME_NONNULL_END
