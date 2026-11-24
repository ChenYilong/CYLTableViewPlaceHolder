import { NativeEventEmitter, NativeModules } from 'react-native';
import { CYLPlaceholderHUDBase, type CYLPlaceholderHUDBackend } from './hudBase.ts';

/** Whether the app was built with the native HUD module (the Android half of this package; the iOS half is a TODO). */
export function isCYLPlaceholderHUDAvailable(): boolean {
  return NativeModules.CYLPlaceholderHUD != null;
}

const nativeBackend: CYLPlaceholderHUDBackend = {
  call(method, args) {
    NativeModules.CYLPlaceholderHUD?.call(method, args ?? null);
  },
  onAction(listener) {
    if (!isCYLPlaceholderHUDAvailable()) return () => {};
    const subscription = new NativeEventEmitter(NativeModules.CYLPlaceholderHUD).addListener('CYLPlaceholderHUDAction', listener);
    return () => subscription.remove();
  },
};

/**
 * The HUD of this repository's Android core (`CYLPlaceholderHUD`), drawn over the current activity's content view, with the
 * Flutter package's method names. Calls do nothing without the native half (`isCYLPlaceholderHUDAvailable()` tells).
 */
export class CYLPlaceholderHUD extends CYLPlaceholderHUDBase {
  constructor() {
    super(nativeBackend);
  }
}
