// cylplaceholder: CYLTableViewPlaceHolder for HarmonyOS (ArkTS), with the iOS names.
export const CYLPlaceholderVersion: string = '0.1.0';

export {
  CYLPlaceholderLocalization,
  CYLPlaceholderLocalizedStringForKey,
  CYLPlaceholderLanguageStorageKey,
  CYLPlaceholderLanguageObserver
} from './src/main/ets/CYLPlaceholderLocalization';
export * from './src/main/ets/CYLPlaceholderViewTypes';
export { CYLPlaceholderImageNames, CYLPlaceholderImageResource, CYLPlaceholderBundledAnimationFileNames } from './src/main/ets/CYLPlaceholderImages';
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

// CYLRefresh: the MJRefresh-compatible pull-to-refresh controls, with the iOS names (models + ArkUI container).
export * from './src/main/ets/refresh/CYLRefreshConst';
export * from './src/main/ets/refresh/CYLRefreshComponent';
export * from './src/main/ets/refresh/CYLRefreshClassics';
export * from './src/main/ets/refresh/CYLRefreshIconView';
export * from './src/main/ets/refresh/CYLRefreshPaging';
export { CYLRefreshBundle } from './src/main/ets/refresh/CYLRefreshBundle';
export { CYLRefreshContainer, CYLRefreshComponentView, CYLRefreshFooterView } from './src/main/ets/refresh/CYLRefreshView';
