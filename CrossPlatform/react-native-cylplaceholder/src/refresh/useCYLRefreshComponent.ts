import { useCallback, useSyncExternalStore } from 'react';
import type { CYLRefreshNotifier } from './notifier.ts';

/**
 * Re-renders the calling component whenever `component` (a header, a footer or a `CYLRefreshPaging`) notifies, and returns
 * it. `undefined` is allowed, so a hook call can stay unconditional.
 */
export function useCYLRefreshComponent<T extends CYLRefreshNotifier>(component: T | undefined): T | undefined {
  const subscribe = useCallback(
    (listener: () => void) => (component !== undefined ? component.subscribe(listener) : () => {}),
    [component]
  );
  useSyncExternalStore(subscribe, () => (component !== undefined ? component.version : 0));
  return component;
}
