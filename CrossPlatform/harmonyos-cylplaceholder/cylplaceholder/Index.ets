// cylplaceholder: CYLTableViewPlaceHolder for HarmonyOS (ArkTS), with the iOS names.
export const CYLPlaceholderVersion: string = '0.1.0';

export {
  CYLPlaceholderLocalization,
  CYLPlaceholderLocalizedStringForKey,
  CYLPlaceholderLanguageStorageKey,
  CYLPlaceholderLanguageObserver
} from './src/main/ets/CYLPlaceholderLocalization';
export * from './src/main/ets/CYLPlaceholderViewTypes';
export {
  CYLPlaceholderImageNames,
  CYLPlaceholderImageResource,
  CYLPlaceholderBundledAnimationFileNames,
  CYLPlaceholderImageBundle,
  CYLPlaceholderImageResourceManager,
  CYLPlaceholderResolveImage
} from './src/main/ets/CYLPlaceholderImages';
export {
  CYLPlaceholderScenario,
  CYLPlaceholderScenarioCategory,
  CYLPlaceholderPermission,
  CYLPlaceholderButtonStyle,
  CYLPlaceholderAction,
  CYLPlaceholderActions,
  CYLPlaceholderComponent,
  CYLPlaceholderComponentKind,
  CYLPlaceholderScenarioCatalog,
  CYLScenarioIconSide,
  CYLScenarioIllustrationSide,
  CYLPlaceholderAccentColor
} from './src/main/ets/CYLPlaceholderScenario';
export {
  CYLPlaceholderView,
  CYLPlaceholderViewModel,
  CYLPlaceholderTapHandler,
  CYLPlaceholderTintFilter,
  CYLPlaceholderDrawingColor
} from './src/main/ets/CYLPlaceholderView';
export {
  CYLPlaceholderStackView,
  CYLPlaceholderStackViewModel,
  CYLPlaceholderStackEntry,
  CYLPlaceholderActionHandler
} from './src/main/ets/CYLPlaceholderStackView';
export { CYLPlaceholderConfiguration, CYLPlaceholderConfigurationErrorHandler } from './src/main/ets/CYLPlaceholderConfiguration';
export {
  CYLPlaceholderNetworkStatus,
  CYLPlaceholderNetworkStatusBlock,
  CYLPlaceholderNetworkMonitor,
  CYLPlaceholderNetworkMonitorObserver,
  CYLPlaceholderNetworkStatusDidChangeNotification
} from './src/main/ets/CYLPlaceholderNetworkMonitor';
export {
  CYLPlaceholderStatusView,
  CYLPlaceholderStatusViewModel,
  CYLPlaceholderStatusViewDelegate,
  CYLPlaceholderStatusViewTapHandler,
  CYLPlaceholderStatusViewHight,
  CYLPlaceholderStatusViewHeight
} from './src/main/ets/CYLPlaceholderStatusView';
export {
  CYLPlaceholderList,
  CYLPlaceholderListController,
  CYLPlaceholderTableController,
  CYLPlaceholderCollectionController,
  CYLPlaceholderListPlaceholder,
  CYLPlaceholderRect,
  CYLTableViewPlaceHolderDelegate,
  CYLTablePlaceholderViewBlock,
  CYLTablePlaceholderNormalBlock,
  CYLCollectionPlaceholderViewBlock,
  CYLCollectionPlaceholderNormalBlock
} from './src/main/ets/CYLPlaceholderList';
export {
  CYLPlaceholderStatusDisplay,
  CYLPlaceholderStatusController,
  CYLPlaceholderStatusPage
} from './src/main/ets/CYLPlaceholderStatus';
export {
  CYLPlaceholderHUD,
  CYLPlaceholderHUDStyle,
  CYLPlaceholderHUDMaskType,
  CYLPlaceholderHUDState,
  CYLPlaceholderHUDDismissCompletion,
  CYLPlaceholderHUDObserver,
  CYLPlaceholderHUDPresenter,
  CYLPlaceholderHUDScheduler,
  CYLPlaceholderHUDSize,
  CYLPlaceholderHUDOffset,
  CYLPlaceholderHUDWillAppearNotification,
  CYLPlaceholderHUDDidAppearNotification,
  CYLPlaceholderHUDWillDisappearNotification,
  CYLPlaceholderHUDDidDisappearNotification,
  CYLPlaceholderHUDDidReceiveTouchEventNotification,
  CYLPlaceholderHUDDidTouchDownInsideNotification,
  CYLPlaceholderHUDStatusUserInfoKey,
  CYLPlaceholderSharedHUD,
  CYLPlaceholderHUDSetPresenter
} from './src/main/ets/hud/CYLPlaceholderHUD';
export { CYLPlaceholderHUDView, CYLPlaceholderHUDInstallOverlayPresenter } from './src/main/ets/hud/CYLPlaceholderHUDView';

// CYLRefresh: the MJRefresh-compatible pull-to-refresh controls, with the iOS names (models + ArkUI container).
export * from './src/main/ets/refresh/CYLRefreshConst';
export * from './src/main/ets/refresh/CYLRefreshComponent';
export * from './src/main/ets/refresh/CYLRefreshClassics';
export * from './src/main/ets/refresh/CYLRefreshIconView';
export * from './src/main/ets/refresh/CYLRefreshImage';
export * from './src/main/ets/refresh/CYLRefreshPaging';
export { CYLRefreshBundle } from './src/main/ets/refresh/CYLRefreshBundle';
export {
  CYLRefreshContainer,
  CYLRefreshComponentView,
  CYLRefreshCustomControlView,
  CYLRefreshFooterView
} from './src/main/ets/refresh/CYLRefreshView';
export {
  CYLPlaceholderItemAnimatorPriority,
  CYLPlaceholderItemAnimatorPriorityDefault,
  CYLPlaceholderItemAnimatorPriorityFallback,
  CYLPlaceholderAnimationOption,
  CYLPlaceholderAnimationOptionRiveArtboard,
  CYLPlaceholderAnimationOptionRiveStateMachine,
  CYLPlaceholderAnimationOptionRiveActiveProperty,
  CYLPlaceholderAnimationOptionRiveActiveDuration,
  CYLPlaceholderAnimationOptionRiveTriggerProperty,
  CYLPlaceholderAnimationOptionRiveColor,
  CYLPlaceholderAnimationOptionRiveInput,
  CYLPlaceholderAnimationOptionRiveTriggerInput,
  CYLPlaceholderAnimationOptionRiveAnimation,
  CYLPlaceholderAnimationOptionRiveLegacyRuntime,
  CYLPlaceholderAnimationErrorDomain,
  CYLPlaceholderAnimationErrorCode,
  CYLPlaceholderAnimationError,
  CYLPlaceholderAnimationErrorHandler,
  CYLPlaceholderAnimationColors,
  CYLPlaceholderAnimationContentView,
  CYLPlaceholderAnimationContent,
  CYLPlaceholderPlayableContentView,
  CYLPlaceholderItemAnimationPlayableView,
  CYLPlaceholderItemAnimationViewProviding,
  CYLPlaceholderItemAnimationPlayer,
  CYLPlaceholderItemAnimationBasePlayer,
  CYLPlaceholderItemAnimationFileMatching,
  CYLPlaceholderItemAnimationViewFactory,
  CYLPlaceholderItemAnimator,
  CYLPlaceholderItemViewAnimator,
  CYLPlaceholderItemAnimatorRegistering,
  CYLPlaceholderItemAnimatorRegistry,
  CYLPlaceholderItemAnimationViewMaking,
  CYLPlaceholderItemAnimationFactory,
  CYLPlaceholderAnimationBackend,
  CYLPlaceholderAnimationPlayer,
  CYLPlaceholderAnimationFactory,
  CYLPlaceholderAnimationViewModel,
  CYLPlaceholderAnimationSetDefaultContext,
  CYLPlaceholderAnimationDefaultContext,
  CYLPlaceholderAnimationView,
  CYLPlaceholderAnimationURLWithOptions,
  CYLPlaceholderAnimationOptionsOfURL
} from './src/main/ets/CYLPlaceholderAnimation';
export { CYLGIFPlaceholderItemAnimator } from './src/main/ets/CYLGIFPlaceholderItemAnimator';
export { CYLLottiePlaceholderItemAnimator } from './src/main/ets/CYLLottiePlaceholderItemAnimator';
export { CYLPAGPlaceholderItemAnimator } from './src/main/ets/CYLPAGPlaceholderItemAnimator';
export { CYLRivePlaceholderItemAnimator } from './src/main/ets/CYLRivePlaceholderItemAnimator';
export {
  CYLRiveUsesLegacyRuntime,
  CYLRiveActivePropertyPath,
  CYLRiveTriggerPropertyPath,
  CYLRiveColorPropertyPath,
  CYLRiveColorValue
} from './src/main/ets/CYLRiveOptions';
// Registers the GIF, Lottie, PAG and Rive animators in the shared registry when the HAR is imported.
export { CYLPlaceholderItemAnimationEngine } from './src/main/ets/CYLPlaceholderItemAnimationEngine';

// CYLRefresh drawn styles: SmartRefreshControl's headers and footers drawn on a Canvas, with their support classes.
export * from './src/main/ets/refresh/drawn/CYLRefreshDrawnSupport';
export * from './src/main/ets/refresh/drawn/CYLRefreshValueAnimator';
export * from './src/main/ets/refresh/drawn/CYLRefreshVectorPathsParser';
export * from './src/main/ets/refresh/drawn/CYLRefreshVector';
export * from './src/main/ets/refresh/drawn/CYLRefreshStoreHouse';
export * from './src/main/ets/refresh/drawn/CYLRefreshDrawnHeader';
export * from './src/main/ets/refresh/drawn/CYLRefreshDrawnShapes';
export * from './src/main/ets/refresh/drawn/CYLRefreshDrawnVectors';
export * from './src/main/ets/refresh/drawn/CYLRefreshStoreHouseHeader';
export * from './src/main/ets/refresh/drawn/CYLRefreshFly';
export * from './src/main/ets/refresh/drawn/CYLRefreshGame';
export * from './src/main/ets/refresh/drawn/CYLRefreshDrawnFooters';
export { CYLRefreshDrawnView, CYLRefreshVectorViewComponent, cylRefreshDrawnStyle } from './src/main/ets/refresh/drawn/CYLRefreshDrawnView';
export * from './src/main/ets/refresh/drawn/CYLRefreshRiveHeader';
export { CYLRefreshRiveView, cylRefreshRiveHeader } from './src/main/ets/refresh/drawn/CYLRefreshRiveView';

// The public Swift API of iOS RiveSwift / LottieSwift: the Rive views and the lottie-ios 2 compatible Lottie view.
export {
  CYLPlaceholderRiveItemAnimationView,
  CYLPlaceholderRiveLegacyItemAnimationView,
  CYLPlaceholderRiveLegacyViewProvider,
  CYLPlaceholderRiveLegacyOptions
} from './src/main/ets/CYLPlaceholderRiveItemAnimationView';
export { CYLRiveColorInteger } from './src/main/ets/CYLRiveOptions';
export {
  CYLPlaceholderCompatibleLOTAnimation,
  CYLPlaceholderCompatibleLOTAnimationView,
  CYLPlaceholderCompatibleLOTAnimationViewComponent
} from './src/main/ets/CYLPlaceholderCompatibleLottie';
export * from './src/main/ets/CYLPlaceholderCompatibleLottieSupport';
export { CYLPlaceholderAnimationFileExists, CYLPlaceholderAnimationReadFileSync } from './src/main/ets/CYLPlaceholderAnimation';
