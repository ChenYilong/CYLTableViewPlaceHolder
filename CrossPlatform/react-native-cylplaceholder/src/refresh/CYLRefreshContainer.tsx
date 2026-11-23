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
      onRefresh: () => void;
      style?: StyleProp<ViewStyle>;
      children: ReactNode;
    }>(NATIVE_NAME)
  : null;

/**
 * Wraps one scroll view in the native CYLRefresh container: on iOS the scroll view's `cyl_header`, on Android a
 * `CYLRefreshLayout` around it, so the native headers and their phase machine do the pulling. Returns null when the app has
 * no native half (use `CYLRefresh`, the JavaScript implementation, then; `isCYLRefreshContainerAvailable()` tells).
 */
export function CYLRefreshContainer({ refreshing, onRefresh, enabled = true, style, children }: CYLRefreshContainerProps): ReactElement | null {
  if (Native == null) return null;
  return (
    <Native refreshing={refreshing} enabled={enabled} onRefresh={onRefresh} style={[{ flex: 1 }, style]}>
      {children}
    </Native>
  );
}
