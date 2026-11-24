import type { ReactElement, ReactNode } from 'react';
import { requireNativeComponent, UIManager, type StyleProp, type ViewStyle } from 'react-native';

/** The properties of the native container `CYLRefreshContainer`. */
export interface CYLRefreshContainerProps {
  /** Shows the refreshing state while true, as `RefreshControl.refreshing`. */
  refreshing: boolean;
  /** Called when the user pulls the header (not when `refreshing` was set from JavaScript). */
  onRefresh: () => void;
  /** Whether the pull is on, default true. */
  enabled?: boolean;
  /** Whether the native footer (load more) is on, default false. Android only: the iOS half has no footer yet (TODO). */
  loadMoreEnabled?: boolean;
  /** Shows the footer's loading state while true, as `refreshing` does for the header. */
  loadingMore?: boolean;
  /** Shows "no more data" in the footer while true; set together with `loadingMore: false` to end a load with it. */
  noMoreData?: boolean;
  /** Called when the footer starts loading (not when `loadingMore` was set from JavaScript). */
  onLoadMore?: () => void;
  /** The header's look on iOS (`classic` default, `cupertino`, `material`, `bezierRadar`, `bezierCircle`, `delivery`, `phoenix`, `taurus`); an unknown name is the classic one. Android ignores it for now. */
  headerStyle?: string;
  /** The footer's look on iOS, the same names as `headerStyle`. */
  footerStyle?: string;
  /** The pull, in points, past which a release opens the second floor instead of refreshing; 0 (default) is no second floor. iOS first; Android follows the same names. */
  secondaryTriggerOffset?: number;
  /** The open extent of the second floor; 0 (default) is the scroll view's visible height. */
  secondaryDimension?: number;
  /** Pushing the content up this far and releasing closes the second floor; default 80. */
  secondaryCloseTriggerOffset?: number;
  /** Controlled like `refreshing`: true opens the second floor, false closes it; set it from `onSecondaryOpen` / `onSecondaryClose`. */
  secondaryOpen?: boolean;
  /** Called after the second floor opened from a pull (not when `secondaryOpen` was set from JavaScript). */
  onSecondaryOpen?: () => void;
  /** Called after the second floor closed from a push (not when `secondaryOpen` was set from JavaScript). */
  onSecondaryClose?: () => void;
  style?: StyleProp<ViewStyle>;
  /** One scroll view (`ScrollView`, `FlatList`, `SectionList`): it gets the native CYLRefresh header. */
  children: ReactNode;
}

const NATIVE_NAME = 'CYLRefreshContainer';

/** Whether the app was built with the native container (the iOS and Android halves of this package). */
export function isCYLRefreshContainerAvailable(): boolean {
  return UIManager.getViewManagerConfig?.(NATIVE_NAME) != null;
}

const Native = isCYLRefreshContainerAvailable()
  ? requireNativeComponent<{
      refreshing: boolean;
      enabled: boolean;
      loadMoreEnabled: boolean;
      loadingMore: boolean;
      noMoreData: boolean;
      onRefresh: () => void;
      onLoadMore?: () => void;
      headerStyle?: string;
      footerStyle?: string;
      secondaryTriggerOffset?: number;
      secondaryDimension?: number;
      secondaryCloseTriggerOffset?: number;
      secondaryOpen?: boolean;
      onSecondaryOpen?: () => void;
      onSecondaryClose?: () => void;
      style?: StyleProp<ViewStyle>;
      children: ReactNode;
    }>(NATIVE_NAME)
  : null;

/**
 * Wraps one scroll view in the native CYLRefresh container: on iOS the scroll view's `cyl_header`, on Android a
 * `CYLRefreshLayout` around it, so the native headers and their phase machine do the pulling. The second floor's content is a
 * child view with `nativeID="cyl.refresh.secondary"` beside the scroll view. Returns null when the app has
 * no native half (use `CYLRefresh`, the JavaScript implementation, then; `isCYLRefreshContainerAvailable()` tells).
 */
export function CYLRefreshContainer({
  refreshing,
  onRefresh,
  enabled = true,
  loadMoreEnabled = false,
  loadingMore = false,
  noMoreData = false,
  onLoadMore,
  headerStyle,
  footerStyle,
  secondaryTriggerOffset,
  secondaryDimension,
  secondaryCloseTriggerOffset,
  secondaryOpen,
  onSecondaryOpen,
  onSecondaryClose,
  style,
  children,
}: CYLRefreshContainerProps): ReactElement | null {
  if (Native == null) return null;
  return (
    <Native
      refreshing={refreshing}
      enabled={enabled}
      onRefresh={onRefresh}
      loadMoreEnabled={loadMoreEnabled}
      loadingMore={loadingMore}
      noMoreData={noMoreData}
      onLoadMore={onLoadMore}
      headerStyle={headerStyle}
      footerStyle={footerStyle}
      secondaryTriggerOffset={secondaryTriggerOffset}
      secondaryDimension={secondaryDimension}
      secondaryCloseTriggerOffset={secondaryCloseTriggerOffset}
      secondaryOpen={secondaryOpen}
      onSecondaryOpen={onSecondaryOpen}
      onSecondaryClose={onSecondaryClose}
      style={[{ flex: 1 }, style]}
    >
      {children}
    </Native>
  );
}
