// CYLPlaceholderLocalization: the HarmonyOS counterpart of iOS CYLPlaceholderLocalization.h. Every placeholder text,
// scenario title and component title is read from the tables in ./locales (generated from the Android strings, keys
// without the "cyl_placeholder_" prefix). An app can switch the language at run time.
import { i18n } from '@kit.LocalizationKit';
import { CYLPlaceholderStringsEn } from './locales/CYLPlaceholderStringsEn';
import { CYLPlaceholderStringsZhHans } from './locales/CYLPlaceholderStringsZhHans';
import { CYLPlaceholderStringsZhHant } from './locales/CYLPlaceholderStringsZhHant';
import { CYLPlaceholderStringsJa } from './locales/CYLPlaceholderStringsJa';
import { CYLPlaceholderStringsKo } from './locales/CYLPlaceholderStringsKo';
import { CYLPlaceholderStringsRu } from './locales/CYLPlaceholderStringsRu';
import { CYLPlaceholderStringsUk } from './locales/CYLPlaceholderStringsUk';

const TABLES: Record<string, Record<string, string>> = {
  'en': CYLPlaceholderStringsEn,
  'zh-Hans': CYLPlaceholderStringsZhHans,
  'zh-Hant': CYLPlaceholderStringsZhHant,
  'ja': CYLPlaceholderStringsJa,
  'ko': CYLPlaceholderStringsKo,
  'ru': CYLPlaceholderStringsRu,
  'uk': CYLPlaceholderStringsUk
};

/** The AppStorage key holding the effective language; components read it with @StorageProp to re-render. */
export const CYLPlaceholderLanguageStorageKey: string = 'CYLPlaceholderLocalization.effectiveLanguage';

/** Called after CYLPlaceholderLocalization.language changes (iOS CYLPlaceholderLocalizationLanguageDidChangeNotification). */
export type CYLPlaceholderLanguageObserver = (effectiveLanguage: string) => void;

const SUPPORTED: string[] = ['en', 'zh-Hans', 'zh-Hant', 'ja', 'ko', 'ru', 'uk'];

/**
 * Language selection for the core tables (iOS `CYLPlaceholderLocalization`).
 */
export class CYLPlaceholderLocalization {
  private static languageOverride: string | null = null;
  private static observers: CYLPlaceholderLanguageObserver[] = [];

  /** The languages the core tables provide: en, zh-Hans, zh-Hant, ja, ko, ru, uk. */
  static get supportedLanguages(): string[] {
    return SUPPORTED.slice();
  }

  /**
   * The language used for core texts. null (the default) follows the app's preferred language. An unsupported
   * language falls back to its base language when that is supported ("zh-HK" to "zh-Hant", "ja-JP" to "ja"), else
   * to English.
   */
  static get language(): string | null {
    return CYLPlaceholderLocalization.languageOverride;
  }

  static set language(value: string | null) {
    CYLPlaceholderLocalization.languageOverride = value && value.length > 0 ? value : null;
    const effective = CYLPlaceholderLocalization.effectiveLanguage;
    try {
      AppStorage.setOrCreate<string>(CYLPlaceholderLanguageStorageKey, effective);
    } catch (e) {
      // No ArkUI runtime (host unit tests).
    }
    CYLPlaceholderLocalization.observers.forEach((observer: CYLPlaceholderLanguageObserver) => observer(effective));
  }

  /** The supported language actually in use. */
  static get effectiveLanguage(): string {
    const chosen = CYLPlaceholderLocalization.languageOverride;
    return CYLPlaceholderLocalization.resolveLanguage(chosen !== null ? chosen : CYLPlaceholderLocalization.systemLanguageTag());
  }

  /**
   * The text for a key (with or without the "cyl_placeholder_" prefix) in effectiveLanguage; the fallback when the
   * language or the key is missing, then the English text, then the key itself.
   */
  static localizedStringForKey(key: string, fallback: string | null = null): string {
    const plain = key.startsWith('cyl_placeholder_') ? key.substring('cyl_placeholder_'.length) : key;
    const table = TABLES[CYLPlaceholderLocalization.effectiveLanguage];
    const text: string | undefined = table !== undefined ? table[plain] : undefined;
    if (text !== undefined) {
      return text;
    }
    if (fallback !== null) {
      return fallback;
    }
    const english: string | undefined = CYLPlaceholderStringsEn[plain];
    return english !== undefined ? english : key;
  }

  /** The text for a key in a given supported language (used by tests and the example). */
  static localizedStringForKeyInLanguage(key: string, language: string): string {
    const table = TABLES[CYLPlaceholderLocalization.resolveLanguage(language)];
    const text: string | undefined = table[key];
    if (text !== undefined) {
      return text;
    }
    const english: string | undefined = CYLPlaceholderStringsEn[key];
    return english !== undefined ? english : key;
  }

  /** Adds an observer called after `language` changes (iOS languageDidChangeNotification). */
  static addLanguageObserver(observer: CYLPlaceholderLanguageObserver): void {
    CYLPlaceholderLocalization.observers.push(observer);
  }

  static removeLanguageObserver(observer: CYLPlaceholderLanguageObserver): void {
    CYLPlaceholderLocalization.observers = CYLPlaceholderLocalization.observers.filter(
      (o: CYLPlaceholderLanguageObserver) => o !== observer);
  }

  /**
   * Maps a language tag ("zh_CN", "zh-TW", "zh-Hant-HK", "en-US", "ja") to a supported language; zh with Hant or
   * TW / HK / MO is zh-Hant, other zh is zh-Hans, unknown languages are English.
   */
  static resolveLanguage(tag: string | null | undefined): string {
    if (tag === null || tag === undefined || tag.length === 0) {
      return 'en';
    }
    const t = tag.replace(new RegExp('_', 'g'), '-').toLowerCase();
    if (t.startsWith('zh')) {
      if (t.includes('hant') || new RegExp('-(tw|hk|mo)(-|$)').test(t)) {
        return 'zh-Hant';
      }
      return 'zh-Hans';
    }
    const base = t.split('-')[0];
    return SUPPORTED.includes(base) ? base : 'en';
  }

  /** The app's preferred language, else the system language with its region; "en" without a runtime. */
  private static systemLanguageTag(): string {
    try {
      const preferred = i18n.System.getAppPreferredLanguage();
      if (preferred && preferred.length > 0) {
        return preferred;
      }
      return i18n.System.getSystemLanguage() + '-' + i18n.System.getSystemRegion();
    } catch (e) {
      return 'en';
    }
  }
}

/** The core lookup function (iOS `CYLPlaceholderLocalizedStringForKey`). */
export function CYLPlaceholderLocalizedStringForKey(key: string, fallback: string | null = null): string {
  return CYLPlaceholderLocalization.localizedStringForKey(key, fallback);
}
