//
//  CYLScenarioLocalization.h
//  Example-Scenarios
//
//  The demo's text lives in its own bundle, CYLScenarioExample.bundle/<language>.lproj/CYLScenarioExample.strings,
//  never in the library's core bundle. Code reads it only through these macros: one lookup macro and one key macro per
//  string, so code, keys and translations map in one place (see "Localization" in instructions.md). API, file and
//  subspec names shown as technical hints are identifiers and are not localized.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// The table's text in the current app language (one of en, zh-Hans, zh-Hant, ja, ko, ru, uk), else English, else the key.
FOUNDATION_EXPORT NSString *CYLScenarioLocalizedStringForKey(NSString *key);

NS_ASSUME_NONNULL_END

#define CYLScenarioLocalizedString(key) CYLScenarioLocalizedStringForKey(key)

#define CYLScenarioL10nTabScenarios            @"CYLScenarioTabScenarios"
#define CYLScenarioL10nTabAnimations           @"CYLScenarioTabAnimations"
#define CYLScenarioL10nTabFeed                 @"CYLScenarioTabFeed"
#define CYLScenarioL10nTabResources            @"CYLScenarioTabResources"
#define CYLScenarioL10nSectionMessages         @"CYLScenarioSectionMessages"
#define CYLScenarioL10nSectionCases            @"CYLScenarioSectionCases"
#define CYLScenarioL10nSectionFlows            @"CYLScenarioSectionFlows"
#define CYLScenarioL10nTitleEmpty              @"CYLScenarioTitleEmpty"
#define CYLScenarioL10nTitleNoResults          @"CYLScenarioTitleNoResults"
#define CYLScenarioL10nTitleNoInternet         @"CYLScenarioTitleNoInternet"
#define CYLScenarioL10nTitleServerUnavailable  @"CYLScenarioTitleServerUnavailable"
#define CYLScenarioL10nTitleError              @"CYLScenarioTitleError"
#define CYLScenarioL10nTitleLoading            @"CYLScenarioTitleLoading"
#define CYLScenarioL10nTitleNoPermission       @"CYLScenarioTitleNoPermission"
#define CYLScenarioL10nTitleEmptyCart          @"CYLScenarioTitleEmptyCart"
#define CYLScenarioL10nTitleNoNotifications    @"CYLScenarioTitleNoNotifications"
#define CYLScenarioL10nTitleLocationOff        @"CYLScenarioTitleLocationOff"
#define CYLScenarioL10nTitleBluetoothOff       @"CYLScenarioTitleBluetoothOff"
#define CYLScenarioL10nTitleBlocked            @"CYLScenarioTitleBlocked"
#define CYLScenarioL10nTitleDeleted            @"CYLScenarioTitleDeleted"
#define CYLScenarioL10nTitleBrokenImage        @"CYLScenarioTitleBrokenImage"
#define CYLScenarioL10nTitleNoFavorites        @"CYLScenarioTitleNoFavorites"
#define CYLScenarioL10nTitleNoOrders           @"CYLScenarioTitleNoOrders"
#define CYLScenarioL10nTitleEmptyInbox         @"CYLScenarioTitleEmptyInbox"
#define CYLScenarioL10nTitleNoHistory          @"CYLScenarioTitleNoHistory"
#define CYLScenarioL10nTitleBusy               @"CYLScenarioTitleBusy"
#define CYLScenarioL10nTitleCustomImage        @"CYLScenarioTitleCustomImage"
#define CYLScenarioL10nTitleBadge              @"CYLScenarioTitleBadge"
#define CYLScenarioL10nTitlePlist              @"CYLScenarioTitlePlist"
#define CYLScenarioL10nTitleSwitchStates       @"CYLScenarioTitleSwitchStates"
#define CYLScenarioL10nTitleKeepTableHeader    @"CYLScenarioTitleKeepTableHeader"
#define CYLScenarioL10nTitleKeepSectionHeaders @"CYLScenarioTitleKeepSectionHeaders"
#define CYLScenarioL10nTitleRefreshControls    @"CYLScenarioTitleRefreshControls"
#define CYLScenarioL10nTitleScrollable         @"CYLScenarioTitleScrollable"
#define CYLScenarioL10nTitleCollection         @"CYLScenarioTitleCollection"
#define CYLScenarioL10nAnimSyncing             @"CYLScenarioAnimSyncing"
#define CYLScenarioL10nAnimNothingHere         @"CYLScenarioAnimNothingHere"
#define CYLScenarioL10nAnimNoDrafts            @"CYLScenarioAnimNoDrafts"
#define CYLScenarioL10nAnimLocating            @"CYLScenarioAnimLocating"
#define CYLScenarioL10nAnimDone                @"CYLScenarioAnimDone"
#define CYLScenarioL10nAnimAllDone             @"CYLScenarioAnimAllDone"
#define CYLScenarioL10nAnimNoLikes             @"CYLScenarioAnimNoLikes"
#define CYLScenarioL10nAnimPullToRefresh       @"CYLScenarioAnimPullToRefresh"
#define CYLScenarioL10nAnimProcessing          @"CYLScenarioAnimProcessing"
#define CYLScenarioL10nAnimNoShipments         @"CYLScenarioAnimNoShipments"
#define CYLScenarioL10nAnimNoReviews           @"CYLScenarioAnimNoReviews"
#define CYLScenarioL10nAnimUploading           @"CYLScenarioAnimUploading"
#define CYLScenarioL10nAnimPublished           @"CYLScenarioAnimPublished"
#define CYLScenarioL10nActionRetry             @"CYLScenarioActionRetry"
#define CYLScenarioL10nActionReload            @"CYLScenarioActionReload"
#define CYLScenarioL10nActionRequestAccess     @"CYLScenarioActionRequestAccess"
#define CYLScenarioL10nActionShopNow           @"CYLScenarioActionShopNow"
#define CYLScenarioL10nActionOpenSettings      @"CYLScenarioActionOpenSettings"
#define CYLScenarioL10nActionReplay            @"CYLScenarioActionReplay"
#define CYLScenarioL10nActionClear             @"CYLScenarioActionClear"
#define CYLScenarioL10nActionAdd               @"CYLScenarioActionAdd"
#define CYLScenarioL10nActionSources           @"CYLScenarioActionSources"
#define CYLScenarioL10nActionPublish           @"CYLScenarioActionPublish"
#define CYLScenarioL10nTextLocationOff         @"CYLScenarioTextLocationOff"
#define CYLScenarioL10nTextBluetoothOff        @"CYLScenarioTextBluetoothOff"
#define CYLScenarioL10nTextBlocked             @"CYLScenarioTextBlocked"
#define CYLScenarioL10nTextDeleted             @"CYLScenarioTextDeleted"
#define CYLScenarioL10nTextBrokenImage         @"CYLScenarioTextBrokenImage"
#define CYLScenarioL10nTextNoFavorites         @"CYLScenarioTextNoFavorites"
#define CYLScenarioL10nTextNoOrders            @"CYLScenarioTextNoOrders"
#define CYLScenarioL10nTextEmptyInbox          @"CYLScenarioTextEmptyInbox"
#define CYLScenarioL10nTextNoHistory           @"CYLScenarioTextNoHistory"
#define CYLScenarioL10nTextBusy                @"CYLScenarioTextBusy"
#define CYLScenarioL10nTextCustomImage         @"CYLScenarioTextCustomImage"
#define CYLScenarioL10nTextPullToTry           @"CYLScenarioTextPullToTry"
#define CYLScenarioL10nTextNoAnimations        @"CYLScenarioTextNoAnimations"
#define CYLScenarioL10nTextNoticeMissing       @"CYLScenarioTextNoticeMissing"
#define CYLScenarioL10nTextConfigurationError  @"CYLScenarioTextConfigurationError"
#define CYLScenarioL10nTextFeedHint            @"CYLScenarioTextFeedHint"
#define CYLScenarioL10nFormatItem              @"CYLScenarioFormatItem"
#define CYLScenarioL10nFormatPost              @"CYLScenarioFormatPost"
#define CYLScenarioL10nSearchPlaceholder       @"CYLScenarioSearchPlaceholder"
#define CYLScenarioL10nSectionPinned           @"CYLScenarioSectionPinned"
#define CYLScenarioL10nSectionAll              @"CYLScenarioSectionAll"
#define CYLScenarioL10nStateEmpty              @"CYLScenarioStateEmpty"
#define CYLScenarioL10nStateFailed             @"CYLScenarioStateFailed"
#define CYLScenarioL10nStateOffline            @"CYLScenarioStateOffline"
#define CYLScenarioL10nStateData               @"CYLScenarioStateData"
