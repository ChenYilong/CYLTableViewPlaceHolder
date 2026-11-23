// CYLRefreshConst: the HarmonyOS counterpart of iOS CYLRefreshConst.h, CYLRefreshConfig.h and the text half of
// NSBundle+CYLRefresh.h (the images are in CYLRefreshBundle.ets). Sizes are in vp and durations in seconds, as on
// iOS; the text constants are the keys of the localized texts (CYLRefresh.strings, 7 languages, in ./locales).
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { CYLPlaceholderLocalization } from '../CYLPlaceholderLocalization';
import { CYLRefreshStringsEn } from './locales/CYLRefreshStringsEn';
import { CYLRefreshStringsZhHans } from './locales/CYLRefreshStringsZhHans';
import { CYLRefreshStringsZhHant } from './locales/CYLRefreshStringsZhHant';
import { CYLRefreshStringsJa } from './locales/CYLRefreshStringsJa';
import { CYLRefreshStringsKo } from './locales/CYLRefreshStringsKo';
import { CYLRefreshStringsRu } from './locales/CYLRefreshStringsRu';
import { CYLRefreshStringsUk } from './locales/CYLRefreshStringsUk';

/** The gap between the state label and the arrow, in vp. */
export const CYLRefreshLabelLeftInset: number = 25;
/** The header's height, in vp. */
export const CYLRefreshHeaderHeight: number = 54;
/** The footer's height, in vp. */
export const CYLRefreshFooterHeight: number = 44;
/** The trailer's width, in vp. */
export const CYLRefreshTrailWidth: number = 60;
/** The fast animation's duration, in seconds. */
export const CYLRefreshFastAnimationDuration: number = 0.25;
/** The slow animation's duration, in seconds. */
export const CYLRefreshSlowAnimationDuration: number = 0.4;

/** The key path of a scroll view's content offset (an iOS key-value observing name, kept for portable code). */
export const CYLRefreshKeyPathContentOffset: string = 'contentOffset';
/** The key path of a scroll view's content size. */
export const CYLRefreshKeyPathContentSize: string = 'contentSize';
/** The key path of a scroll view's content inset. */
export const CYLRefreshKeyPathContentInset: string = 'contentInset';
/** The key path of a pan gesture's state. */
export const CYLRefreshKeyPathPanState: string = 'state';

/** The default key under which a header stores its last update time. */
export const CYLRefreshHeaderLastUpdatedTimeKey: string = 'CYLRefreshHeaderLastUpdatedTimeKey';
export const CYLRefreshHeaderIdleText: string = 'CYLRefreshHeaderIdleText';
export const CYLRefreshHeaderPullingText: string = 'CYLRefreshHeaderPullingText';
export const CYLRefreshHeaderRefreshingText: string = 'CYLRefreshHeaderRefreshingText';
export const CYLRefreshTrailerIdleText: string = 'CYLRefreshTrailerIdleText';
export const CYLRefreshTrailerPullingText: string = 'CYLRefreshTrailerPullingText';
export const CYLRefreshAutoFooterIdleText: string = 'CYLRefreshAutoFooterIdleText';
export const CYLRefreshAutoFooterRefreshingText: string = 'CYLRefreshAutoFooterRefreshingText';
export const CYLRefreshAutoFooterNoMoreDataText: string = 'CYLRefreshAutoFooterNoMoreDataText';
export const CYLRefreshBackFooterIdleText: string = 'CYLRefreshBackFooterIdleText';
export const CYLRefreshBackFooterPullingText: string = 'CYLRefreshBackFooterPullingText';
export const CYLRefreshBackFooterRefreshingText: string = 'CYLRefreshBackFooterRefreshingText';
export const CYLRefreshBackFooterNoMoreDataText: string = 'CYLRefreshBackFooterNoMoreDataText';
export const CYLRefreshHeaderFinishedText: string = 'CYLRefreshHeaderFinishedText';
export const CYLRefreshHeaderFailedText: string = 'CYLRefreshHeaderFailedText';
export const CYLRefreshFooterFinishedText: string = 'CYLRefreshFooterFinishedText';
export const CYLRefreshFooterFailedText: string = 'CYLRefreshFooterFailedText';
export const CYLRefreshHeaderLastTimeText: string = 'CYLRefreshHeaderLastTimeText';
export const CYLRefreshHeaderDateTodayText: string = 'CYLRefreshHeaderDateTodayText';
export const CYLRefreshHeaderNoneLastDateText: string = 'CYLRefreshHeaderNoneLastDateText';
/** The name of the notice sent when the refresh texts' language changes (CYLRefreshConfig.addLanguageObserver). */
export const CYLRefreshDidChangeLanguageNotification: string = 'CYLRefreshDidChangeLanguageNotification';

/** A refresh component's state (iOS `CYLRefreshState`). */
export enum CYLRefreshState {
  /** At rest. */
  Idle = 1,
  /** Pulled past the trigger: releasing refreshes. */
  Pulling = 2,
  /** Refreshing (or loading). */
  Refreshing = 3,
  /** Asked to refresh before it is on screen: it refreshes once shown. */
  WillRefresh = 4,
  /** A footer with no more data. */
  NoMoreData = 5
}

/** How the header moves with the pull (iOS `CYLRefreshScrollMode`). */
export enum CYLRefreshScrollMode {
  /** Above the content, moving with it. */
  Move = 0,
  /** Exactly the pulled area, from 0 when idle. */
  Stretch = 1,
  /** Pinned at the visible top, in front of the content, which does not move for it while refreshing. */
  Front = 2,
  /** Pinned at the visible top, behind the content, revealed as the content moves. */
  Behind = 3
}

/**
 * The scroll mode for a mode name (the mini program's `scrollMode`: "move", "stretch", "front", "behind") and the older
 * `behind` flag (`behind` wins); null or an unknown name is Move.
 */
export function CYLRefreshScrollModeFor(name: string | null, behind: boolean = false): CYLRefreshScrollMode {
  if (behind) {
    return CYLRefreshScrollMode.Behind;
  }
  switch (name) {
    case 'stretch':
      return CYLRefreshScrollMode.Stretch;
    case 'front':
      return CYLRefreshScrollMode.Front;
    case 'behind':
      return CYLRefreshScrollMode.Behind;
    default:
      return CYLRefreshScrollMode.Move;
  }
}

/** The header's height while pulled: Stretch is exactly the revealed area, the other modes the header's own height. */
export function CYLRefreshHeaderHeightFor(mode: CYLRefreshScrollMode, revealTop: number, headerHeight: number): number {
  return mode === CYLRefreshScrollMode.Stretch ? Math.max(0, revealTop) : headerHeight;
}

/**
 * The header's top edge in the view: Move rides above the content (revealTop - height - ignored inset); Stretch, Front
 * and Behind are pinned at the visible top (0), Front in front of the content, Behind behind it.
 */
export function CYLRefreshHeaderYFor(mode: CYLRefreshScrollMode, revealTop: number, headerHeight: number,
  ignoredInsetTop: number): number {
  return mode === CYLRefreshScrollMode.Move ? revealTop - headerHeight - ignoredInsetTop : 0;
}

/** Where a pull may start (iOS `CYLRefreshTriggerMode`). */
export enum CYLRefreshTriggerMode {
  /** Any drag that reaches the edge. */
  Anywhere = 0,
  /** Only a drag that started at the edge. */
  OnEdge = 1
}

/** The detailed phase (iOS `CYLRefreshPhase`). */
export enum CYLRefreshPhase {
  Idle = 1,
  PullToRefresh = 2,
  ReleaseToRefresh = 3,
  WillRefresh = 4,
  Releasing = 5,
  Refreshing = 6,
  Finishing = 7,
  NoMoreData = 8,
  SecondaryArmed = 9,
  SecondaryOpen = 10,
  SecondaryClosing = 11
}

/** The direction of the last sampled scroll (iOS `CYLScrollDirection`). */
export enum CYLScrollDirection {
  None = 0,
  Up = 1,
  Down = 2,
  Left = 3,
  Right = 4
}

/** A callback with no arguments (iOS `CYLRefreshComponentAction`). */
export type CYLRefreshComponentAction = () => void;
/** iOS `CYLRefreshComponentRefreshingBlock` (deprecated there, kept). */
export type CYLRefreshComponentRefreshingBlock = () => void;
/** iOS `CYLRefreshComponentBeginRefreshingCompletionBlock`. */
export type CYLRefreshComponentBeginRefreshingCompletionBlock = () => void;
/** iOS `CYLRefreshComponentEndRefreshingCompletionBlock`. */
export type CYLRefreshComponentEndRefreshingCompletionBlock = () => void;
/** Formats the last update time (iOS NSDateFormatter of `lastUpdatedTimeFormatter`). */
export type CYLRefreshDateFormatter = (date: Date) => string;
/** Called after the refresh language changed (iOS CYLRefreshDidChangeLanguageNotification). */
export type CYLRefreshLanguageObserver = () => void;

/** Custom refresh texts (iOS `i18nBundle`): tables by "language" or "language/i18nFilename". */
export type CYLRefreshI18nBundle = Map<string, Record<string, string>>;

const TABLES: Record<string, Record<string, string>> = {
  'en': CYLRefreshStringsEn,
  'zh-Hans': CYLRefreshStringsZhHans,
  'zh-Hant': CYLRefreshStringsZhHant,
  'ja': CYLRefreshStringsJa,
  'ko': CYLRefreshStringsKo,
  'ru': CYLRefreshStringsRu,
  'uk': CYLRefreshStringsUk
};

/**
 * The refresh components' settings (iOS `CYLRefreshConfig`). `languageCode`, `i18nFilename` and `i18nBundle` choose
 * the texts; a change notifies every attached component (`i18nDidChange`).
 */
export class CYLRefreshConfig {
  private static shared: CYLRefreshConfig = new CYLRefreshConfig();
  private code: string | null = null;
  private filename: string | null = null;
  private bundle: CYLRefreshI18nBundle | null = null;
  private observers: CYLRefreshLanguageObserver[] = [];
  private store: preferences.Preferences | null = null;
  private memory: Map<string, number> = new Map();

  private constructor() {
    CYLPlaceholderLocalization.addLanguageObserver((language: string) => {
      if (this.code === null) {
        this.notifyLanguageChange();
      }
    });
  }

  /** The shared settings (`defaultConfig`). */
  static get defaultConfig(): CYLRefreshConfig {
    return CYLRefreshConfig.shared;
  }

  /** The language of the built-in texts, or null to follow the app (CYLPlaceholderLocalization) (`languageCode`). */
  get languageCode(): string | null {
    return this.code;
  }

  set languageCode(value: string | null) {
    const next = value !== null && value.length > 0 ? value : null;
    if (next === this.code) {
      return;
    }
    this.code = next;
    this.notifyLanguageChange();
  }

  /** The custom table name looked up in `i18nBundle` ("language/name"), or null (`i18nFilename`). */
  get i18nFilename(): string | null {
    return this.filename;
  }

  set i18nFilename(value: string | null) {
    this.filename = value;
    this.notifyLanguageChange();
  }

  /** Custom texts replacing the built-in ones for the keys they hold, or null (`i18nBundle`). */
  get i18nBundle(): CYLRefreshI18nBundle | null {
    return this.bundle;
  }

  set i18nBundle(value: CYLRefreshI18nBundle | null) {
    this.bundle = value;
    this.notifyLanguageChange();
  }

  /** The supported language actually used for the refresh texts. */
  get effectiveLanguage(): string {
    return this.code !== null ? CYLPlaceholderLocalization.resolveLanguage(this.code)
      : CYLPlaceholderLocalization.effectiveLanguage;
  }

  /** Calls `observer` after every language change (CYLRefreshDidChangeLanguageNotification). */
  addLanguageObserver(observer: CYLRefreshLanguageObserver): void {
    this.observers.push(observer);
  }

  removeLanguageObserver(observer: CYLRefreshLanguageObserver): void {
    this.observers = this.observers.filter((o: CYLRefreshLanguageObserver) => o !== observer);
  }

  /** Posts CYLRefreshDidChangeLanguageNotification (also call it after changing CYLPlaceholderLocalization.language). */
  notifyLanguageChange(): void {
    this.observers.slice().forEach((o: CYLRefreshLanguageObserver) => o());
  }

  /**
   * Keeps the headers' last update times across launches (iOS NSUserDefaults) in the "CYLRefresh" preferences of
   * `context`; without it they are kept in memory only.
   */
  attachContext(context: common.Context): void {
    try {
      this.store = preferences.getPreferencesSync(context, { name: 'CYLRefresh' });
    } catch (e) {
      this.store = null;
    }
  }

  /** The stored time (milliseconds) under `key`, or null. */
  storedTime(key: string): number | null {
    if (this.store !== null) {
      try {
        const v = this.store.getSync(key, 0) as number;
        return v > 0 ? v : null;
      } catch (e) {
        return null;
      }
    }
    const v = this.memory.get(key);
    return v !== undefined ? v : null;
  }

  /** Stores (or with null removes) the time under `key`. */
  storeTime(key: string, time: number | null): void {
    if (this.store !== null) {
      try {
        if (time === null) {
          this.store.deleteSync(key);
        } else {
          this.store.putSync(key, time);
        }
        this.store.flush();
      } catch (e) {
        // Not persisted.
      }
      return;
    }
    if (time === null) {
      this.memory.delete(key);
    } else {
      this.memory.set(key, time);
    }
  }
}

/**
 * A refresh text (iOS `+[NSBundle cyl_localizedStringForKey:value:]`): the custom `i18nBundle` table first, then
 * the built-in table of the language in use, then `value`, then English, then the key.
 */
export function CYLRefreshLocalizedString(key: string, value: string | null = null): string {
  const config = CYLRefreshConfig.defaultConfig;
  const language = config.effectiveLanguage;
  const bundle = config.i18nBundle;
  if (bundle !== null) {
    const names: string[] = [];
    if (config.i18nFilename !== null) {
      names.push(language + '/' + config.i18nFilename);
      names.push(config.i18nFilename);
    }
    names.push(language);
    for (const name of names) {
      const table = bundle.get(name);
      if (table !== undefined && table[key] !== undefined) {
        return table[key];
      }
    }
  }
  const table = TABLES[language];
  if (table !== undefined && table[key] !== undefined) {
    return table[key];
  }
  if (value !== null) {
    return value;
  }
  const english: string | undefined = CYLRefreshStringsEn[key];
  return english !== undefined ? english : key;
}

function pad2(n: number): string {
  return (n < 10 ? '0' : '') + n;
}

/**
 * The state header's "last update" line (iOS CYLRefreshStateHeader): "Last update: Today 09:41", "11-14 09:41" this
 * year, "2025-11-14 09:41" before, "Last update: No record" without a time; `formatter` replaces the date part.
 */
export function CYLRefreshLastUpdatedTimeText(date: Date | null, now: Date = new Date(),
  formatter: CYLRefreshDateFormatter | null = null): string {
  const prefix = CYLRefreshLocalizedString(CYLRefreshHeaderLastTimeText);
  if (formatter !== null) {
    return prefix + (date !== null ? formatter(date) : CYLRefreshLocalizedString(CYLRefreshHeaderNoneLastDateText));
  }
  if (date === null) {
    return prefix + CYLRefreshLocalizedString(CYLRefreshHeaderNoneLastDateText);
  }
  const time = pad2(date.getHours()) + ':' + pad2(date.getMinutes());
  const sameDay = date.getFullYear() === now.getFullYear() && date.getMonth() === now.getMonth() &&
    date.getDate() === now.getDate();
  if (sameDay) {
    return prefix + CYLRefreshLocalizedString(CYLRefreshHeaderDateTodayText) + ' ' + time;
  }
  if (date.getFullYear() === now.getFullYear()) {
    return prefix + pad2(date.getMonth() + 1) + '-' + pad2(date.getDate()) + ' ' + time;
  }
  return prefix + date.getFullYear() + '-' + pad2(date.getMonth() + 1) + '-' + pad2(date.getDate()) + ' ' + time;
}
