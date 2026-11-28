/**
 * The built-in placeholder styles, in the same order and with the same names as the Flutter package's `CYLPlaceholderStyle`.
 * A constant object plus a union type, so the file also runs where TypeScript enums are not available.
 */
export const CYLPlaceholderStyle = {
  /** An empty list. */
  empty: 'empty',
  /** A search without results. */
  noResults: 'noResults',
  /** A failed load. */
  error: 'error',
  /** Wi-Fi is off. */
  wifiOff: 'wifiOff',
  /** No signal. */
  signalWifiOff: 'signalWifiOff',
  /** Connected without internet. */
  noInternet: 'noInternet',
  /** The cloud is unreachable. */
  cloudOff: 'cloudOff',
  /** A sync problem. */
  syncProblem: 'syncProblem',
  /** Sync is off. */
  syncDisabled: 'syncDisabled',
  /** The network is locked. */
  networkLocked: 'networkLocked',
  /** Bluetooth is off. */
  bluetoothDisabled: 'bluetoothDisabled',
  /** Location is off. */
  locationOff: 'locationOff',
  /** Public access is off. */
  publicOff: 'publicOff',
  /** An error outline. */
  errorOutline: 'errorOutline',
  /** A warning. */
  warning: 'warning',
  /** Report a problem. */
  reportProblem: 'reportProblem',
  /** Blocked. */
  blocked: 'blocked',
  /** Help. */
  help: 'help',
  /** Waiting. */
  hourglass: 'hourglass',
  /** Locked. */
  locked: 'locked',
} as const;

/** One of the `CYLPlaceholderStyle` names. */
export type CYLPlaceholderStyle = (typeof CYLPlaceholderStyle)[keyof typeof CYLPlaceholderStyle];

/** The style names in declaration order: the index form of the `CYLPlaceholderItemStyle` attribute. */
export const CYLPlaceholderStyles: readonly CYLPlaceholderStyle[] = Object.values(CYLPlaceholderStyle);

/** A glyph that stands in for each style's icon (React Native ships no icon font); an app can pass its own `image`. */
export const CYLPlaceholderStyleGlyphs: Record<CYLPlaceholderStyle, string> = {
  empty: '\u{1F4E5}',
  noResults: '\u{1F50D}',
  error: '⚠️',
  wifiOff: '\u{1F4F6}',
  signalWifiOff: '\u{1F4F5}',
  noInternet: '\u{1F310}',
  cloudOff: '☁️',
  syncProblem: '\u{1F504}',
  syncDisabled: '⏸️',
  networkLocked: '\u{1F512}',
  bluetoothDisabled: '\u{1F535}',
  locationOff: '\u{1F4CD}',
  publicOff: '\u{1F30D}',
  errorOutline: '❗',
  warning: '⚠️',
  reportProblem: '\u{1F6A9}',
  blocked: '\u{1F6AB}',
  help: '❓',
  hourglass: '⏳',
  locked: '\u{1F512}',
};

/** The item attribute keys, the iOS names (a configuration dictionary uses them too). */
export const CYLPlaceholderItemKey = {
  /** The title (String). */
  title: 'CYLTabBarItemTitle',
  /** The message under the title (String). */
  message: 'CYLPlaceholderItemMessage',
  /** The style: a name or an index into `CYLPlaceholderStyles`. */
  style: 'CYLPlaceholderItemStyle',
  /** The animation file or URL (String). */
  animationURL: 'CYLTabBarAnimationURL',
  /** The animation size, `[width, height]`. */
  animationSize: 'CYLTabBarAnimationSize',
  /** The title color, `#RRGGBB`, `#AARRGGBB` or a number. */
  titleColor: 'CYLTabBarItemTitleColor',
  /** The icon color. */
  iconColor: 'CYLTabBarItemIconColor',
  /** The background color. */
  backgroundColor: 'CYLTabBarItemBackgroundColor',
} as const;

/** What `CYLPlaceholderView.fromItemAttributes` reads from an item description. */
export interface CYLPlaceholderItemValues {
  /** The style. */
  style: CYLPlaceholderStyle;
  /** The title. */
  title?: string;
  /** The message. */
  message?: string;
  /** The animation file or URL. */
  animationFile?: string;
  /** The animation size in points. */
  animationSize: { width: number; height: number };
  /** The title color as a CSS color string. */
  titleColor?: string;
  /** The icon color as a CSS color string. */
  iconColor?: string;
  /** The background color as a CSS color string. */
  backgroundColor?: string;
}

function toColor(value: unknown): string | undefined {
  if (typeof value === 'number' && Number.isFinite(value)) {
    const argb = value >>> 0;
    const alpha = ((argb >>> 24) & 0xff) / 255;
    return `rgba(${(argb >>> 16) & 0xff}, ${(argb >>> 8) & 0xff}, ${argb & 0xff}, ${alpha})`;
  }
  if (typeof value === 'string') {
    const hex = value.replace(/^#/, '');
    if (!/^[0-9a-fA-F]+$/.test(hex) || (hex.length !== 6 && hex.length !== 8)) {
      return undefined;
    }
    const parsed = parseInt(hex, 16);
    return toColor(hex.length <= 6 ? (0xff000000 | parsed) >>> 0 : parsed);
  }
  return undefined;
}

/** Reads an item description with the iOS keys (`CYLPlaceholderItemKey`); unknown or invalid values fall back to defaults. */
export function cylPlaceholderValuesFromAttributes(attributes: Record<string, unknown>): CYLPlaceholderItemValues {
  const rawStyle = attributes[CYLPlaceholderItemKey.style];
  let style: CYLPlaceholderStyle = CYLPlaceholderStyle.empty;
  if (typeof rawStyle === 'number' && Number.isInteger(rawStyle) && rawStyle >= 0 && rawStyle < CYLPlaceholderStyles.length) {
    style = CYLPlaceholderStyles[rawStyle]!;
  } else if (typeof rawStyle === 'string') {
    style = CYLPlaceholderStyles.find((name) => name === rawStyle) ?? style;
  }
  const rawSize = attributes[CYLPlaceholderItemKey.animationSize];
  let size = { width: 120, height: 120 };
  if (Array.isArray(rawSize) && rawSize.length === 2 && typeof rawSize[0] === 'number' && typeof rawSize[1] === 'number') {
    size = { width: rawSize[0], height: rawSize[1] };
  }
  const text = (key: string): string | undefined => (typeof attributes[key] === 'string' ? (attributes[key] as string) : undefined);
  return {
    style,
    title: text(CYLPlaceholderItemKey.title),
    message: text(CYLPlaceholderItemKey.message),
    animationFile: text(CYLPlaceholderItemKey.animationURL),
    animationSize: size,
    titleColor: toColor(attributes[CYLPlaceholderItemKey.titleColor]),
    iconColor: toColor(attributes[CYLPlaceholderItemKey.iconColor]),
    backgroundColor: toColor(attributes[CYLPlaceholderItemKey.backgroundColor]),
  };
}

/** The item description of a placeholder, with the iOS keys: the inverse of `cylPlaceholderValuesFromAttributes`. */
export function cylPlaceholderItemAttributes(values: {
  style: CYLPlaceholderStyle;
  title?: string;
  message?: string;
  animationFile?: string;
}): Record<string, string> {
  const attributes: Record<string, string> = { [CYLPlaceholderItemKey.style]: values.style };
  if (values.title !== undefined) {
    attributes[CYLPlaceholderItemKey.title] = values.title;
  }
  if (values.message !== undefined) {
    attributes[CYLPlaceholderItemKey.message] = values.message;
  }
  if (values.animationFile !== undefined) {
    attributes[CYLPlaceholderItemKey.animationURL] = values.animationFile;
  }
  return attributes;
}
