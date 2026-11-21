// The Rive options read like iOS CYLPlaceholderRiveItemAnimationConfiguration (RiveSwift): pure helpers kept apart
// from @ohos/rive so the host-run unit tests can check them.
//
// iOS has two runtimes: the view-model one (`active`, `duration`, `trigger`, `color`) and the legacy one (state
// machine inputs `input` / `triggerInput` / `numberInput`, a linear animation `animation`, or `legacy` = "1"). @ohos/rive is one runtime
// with both APIs (StateMachineInstance.viewModelInstance and RiveAnimationView inputs), so the option picks the API
// the same way iOS picks the runtime; nothing is unavailable.
import {
  CYLPlaceholderAnimationOptionRiveActiveProperty,
  CYLPlaceholderAnimationOptionRiveAnimation,
  CYLPlaceholderAnimationOptionRiveColor,
  CYLPlaceholderAnimationOptionRiveInput,
  CYLPlaceholderAnimationOptionRiveLegacyRuntime,
  CYLPlaceholderAnimationOptionRiveNumberInput,
  CYLPlaceholderAnimationOptionRiveTriggerInput,
  CYLPlaceholderAnimationOptionRiveTriggerProperty
} from './CYLPlaceholderAnimation';

function nonEmpty(options: Record<string, string>, name: string): string | null {
  const value: string | undefined = options[name];
  return value !== undefined && value.length > 0 ? value : null;
}

/** Whether the legacy (state machine input / linear animation) API plays the file (iOS `usesLegacyRuntime`). */
export function CYLRiveUsesLegacyRuntime(options: Record<string, string>): boolean {
  return options[CYLPlaceholderAnimationOptionRiveLegacyRuntime] === '1' ||
    nonEmpty(options, CYLPlaceholderAnimationOptionRiveInput) !== null ||
    nonEmpty(options, CYLPlaceholderAnimationOptionRiveTriggerInput) !== null ||
    nonEmpty(options, CYLPlaceholderAnimationOptionRiveNumberInput) !== null ||
    nonEmpty(options, CYLPlaceholderAnimationOptionRiveAnimation) !== null;
}

/** The view-model boolean set true while active: the `active` option, "active" by default. */
export function CYLRiveActivePropertyPath(options: Record<string, string>): string {
  const path = nonEmpty(options, CYLPlaceholderAnimationOptionRiveActiveProperty);
  return path !== null ? path : 'active';
}

/** The view-model trigger fired on play (`trigger`), or null: the active boolean is used instead. */
export function CYLRiveTriggerPropertyPath(options: Record<string, string>): string | null {
  return nonEmpty(options, CYLPlaceholderAnimationOptionRiveTriggerProperty);
}

/** The view-model color property the `color` option is written to (iOS `colorPropertyPath`). */
export const CYLRiveColorPropertyPath: string = 'color';

/**
 * The `color` option ("#RRGGBB" or "#RRGGBBAA", "#" optional) as the Rive color integer 0xAARRGGBB, or null when it
 * is missing or not a color (iOS `color(hex:)`).
 */
export function CYLRiveColorValue(options: Record<string, string>): number | null {
  const text = nonEmpty(options, CYLPlaceholderAnimationOptionRiveColor);
  if (text === null) {
    return null;
  }
  const digits = text.startsWith('#') ? text.substring(1) : text;
  if ((digits.length !== 6 && digits.length !== 8) || !/^[0-9a-fA-F]+$/.test(digits)) {
    return null;
  }
  const rgb = parseInt(digits.substring(0, 6), 16);
  const alpha = digits.length === 8 ? parseInt(digits.substring(6, 8), 16) : 0xFF;
  return alpha * 0x1000000 + rgb;
}

function colorByte(value: number): number {
  return Math.max(0, Math.min(255, Math.round(value)));
}

/** A color (0...255 channels) as the signed Rive color integer 0xAARRGGBB (iOS `riveColor(_:)`). */
export function CYLRiveColorInteger(red: number, green: number, blue: number, alpha: number): number {
  return (colorByte(alpha) * 0x1000000 + colorByte(red) * 0x10000 + colorByte(green) * 0x100 + colorByte(blue)) | 0;
}

/**
 * The value after `current` in the `values` option ("3,4,5,6"), cycling (an unknown value starts the list); without
 * values, `current + 1`. As CYLTabBarController's cylRiveNextNumber on iOS, Android, HarmonyOS and the mini program.
 */
export function CYLRiveNextNumber(values: string | undefined, current: number | undefined): number {
  const list: number[] = (values ?? '').split(',').map((value: string) => value.trim())
    .filter((value: string) => value !== '').map((value: string) => Number(value))
    .filter((value: number) => Number.isFinite(value));
  if (list.length === 0) {
    return (current ?? 0) + 1;
  }
  const index = current === undefined ? -1 : list.indexOf(current);
  return list[(index + 1) % list.length];
}
