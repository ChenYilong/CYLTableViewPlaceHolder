import { forwardRef, useImperativeHandle, useRef, type ReactElement, type Ref } from 'react';
import { findNodeHandle, requireNativeComponent, UIManager, type StyleProp, type ViewStyle } from 'react-native';
import type { CYLPlaceholderComponent } from './components.ts';

/** The props of the native `CYLPlaceholderStack`. */
export interface CYLPlaceholderStackProps {
  /** The components, top to bottom. Without them `scenario` names a built-in scenario. */
  components?: CYLPlaceholderComponent[];
  /** A built-in scenario name of the native catalog, used when there are no `components`. */
  scenario?: string;
  /** The action name of a tap on the background. */
  backgroundAction?: string;
  /** Called with the `action` name of a tapped component. */
  onAction?: (action: string) => void;
  /**
   * Grows: every animation plays again from the start (the `restartAnimation()` of the native stack, as a prop). The rule is the same on
   * Android and iOS: the animations replay only when the token GROWS once the stack exists; the first value is a baseline, and an equal
   * or smaller value (a reset to 0) never replays.
   */
  restartToken?: number;
  style?: StyleProp<ViewStyle>;
}

/** What a ref to `CYLPlaceholderStack` offers. */
export interface CYLPlaceholderStackHandle {
  /** Plays every animation of the stack again from the start (the native `restartAnimation()`). */
  restartAnimation(): void;
}

const NATIVE_NAME = 'CYLPlaceholderStack';

/** Whether the app was built with the native stack (the Android half and the iOS half of this package: `CYLPlaceholderStackManager` on both). */
export function isCYLPlaceholderStackAvailable(): boolean {
  return UIManager.getViewManagerConfig?.(NATIVE_NAME) != null;
}

const Native = isCYLPlaceholderStackAvailable()
  ? requireNativeComponent<{
      components?: CYLPlaceholderComponent[];
      scenario?: string;
      backgroundAction?: string;
      restartToken?: number;
      onAction?: (event: { nativeEvent: { action: string } }) => void;
      style?: StyleProp<ViewStyle>;
    }>(NATIVE_NAME)
  : null;

/**
 * The native `CYLPlaceholderStackView` (the Android component of this repository) as a React Native view: the components are
 * the configuration dictionary of `docs/Placeholder-Scenarios.md`. Returns null without the native half
 * (`isCYLPlaceholderStackAvailable()` tells).
 */
export const CYLPlaceholderStack = forwardRef(function CYLPlaceholderStack(
  { components, scenario, backgroundAction, onAction, restartToken, style }: CYLPlaceholderStackProps,
  ref: Ref<CYLPlaceholderStackHandle>
): ReactElement | null {
  const native = useRef<React.ComponentRef<NonNullable<typeof Native>>>(null);
  useImperativeHandle(ref, () => ({
    restartAnimation() {
      const tag = findNodeHandle(native.current);
      if (tag != null) UIManager.dispatchViewManagerCommand(tag, 'restartAnimation', []);
    },
  }));
  if (Native == null) return null;
  return (
    <Native
      ref={native}
      components={components}
      scenario={scenario}
      backgroundAction={backgroundAction}
      restartToken={restartToken}
      onAction={onAction === undefined ? undefined : (event) => onAction(event.nativeEvent.action)}
      style={[{ flex: 1 }, style]}
    />
  );
});
