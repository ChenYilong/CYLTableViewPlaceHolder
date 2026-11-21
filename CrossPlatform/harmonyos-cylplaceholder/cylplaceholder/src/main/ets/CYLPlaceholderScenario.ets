// The HarmonyOS counterpart of iOS CYLPlaceholderScenario.h: the 35 scenarios, their category and permission, the
// actions, the button styles, CYLPlaceholderComponent and CYLPlaceholderScenarioCatalog. Translated from the Android
// port (CYLPlaceholderScenario.kt, CYLPlaceholderComponent.kt) and the mini program's cyl_scenario_catalog.js.
import { CYLPlaceholderLocalization } from './CYLPlaceholderLocalization';
import { CYLPlaceholderImageBundle } from './CYLPlaceholderImages';
import {
  CYLPlaceholderIconNameForStyle,
  CYLPlaceholderItemAccessibilityIdentifier,
  CYLPlaceholderItemAnimationFilePath,
  CYLPlaceholderItemAnimationRepeatCount,
  CYLPlaceholderItemImage,
  CYLPlaceholderItemInteractionEnabled,
  CYLPlaceholderItemStyle,
  CYLPlaceholderItemTapHighlightStyle,
  CYLPlaceholderItemTitle,
  CYLPlaceholderItemTitleColor,
  CYLPlaceholderItemTitleFont,
  CYLPlaceholderSnakeCase,
  CYLPlaceholderStyle,
  CYLPlaceholderStyleNamed,
  CYLPlaceholderStyleValues,
  CYLPlaceholderTapHighlightStyle
} from './CYLPlaceholderViewTypes';

/** The ready-made scenarios, in the iOS order (iOS `CYLPlaceholderScenario`). */
export enum CYLPlaceholderScenario {
  NetworkUnavailable,
  NoContent,
  TapToReload,
  LoadFailedWithHint,
  TapToReconnect,
  RetryButton,
  RetryOutlinedButton,
  RetryWithHint,
  RetryOrContactSupport,
  IllustrationRetry,
  RefreshIcon,
  TitleAboveIllustration,
  TextOnly,
  TapMeRetry,
  LocationPermissionDenied,
  NoSearchResults,
  EmptyCart,
  NoOrders,
  NoFavorites,
  NoMessages,
  NoNotifications,
  NoPermission,
  CameraPermissionDenied,
  PhotoLibraryPermissionDenied,
  MicrophonePermissionDenied,
  ContactsPermissionDenied,
  CalendarPermissionDenied,
  BluetoothPermissionDenied,
  NotificationPermissionDenied,
  ServerError,
  SyncFailed,
  Loading,
  Uploading,
  Success,
  HUD
}


const ALL_SCENARIOS: CYLPlaceholderScenario[] = [
  CYLPlaceholderScenario.NetworkUnavailable, CYLPlaceholderScenario.NoContent, CYLPlaceholderScenario.TapToReload, CYLPlaceholderScenario.LoadFailedWithHint, CYLPlaceholderScenario.TapToReconnect, CYLPlaceholderScenario.RetryButton,
  CYLPlaceholderScenario.RetryOutlinedButton, CYLPlaceholderScenario.RetryWithHint, CYLPlaceholderScenario.RetryOrContactSupport, CYLPlaceholderScenario.IllustrationRetry, CYLPlaceholderScenario.RefreshIcon,
  CYLPlaceholderScenario.TitleAboveIllustration, CYLPlaceholderScenario.TextOnly, CYLPlaceholderScenario.TapMeRetry, CYLPlaceholderScenario.LocationPermissionDenied, CYLPlaceholderScenario.NoSearchResults, CYLPlaceholderScenario.EmptyCart,
  CYLPlaceholderScenario.NoOrders, CYLPlaceholderScenario.NoFavorites, CYLPlaceholderScenario.NoMessages, CYLPlaceholderScenario.NoNotifications, CYLPlaceholderScenario.NoPermission, CYLPlaceholderScenario.CameraPermissionDenied,
  CYLPlaceholderScenario.PhotoLibraryPermissionDenied, CYLPlaceholderScenario.MicrophonePermissionDenied, CYLPlaceholderScenario.ContactsPermissionDenied,
  CYLPlaceholderScenario.CalendarPermissionDenied, CYLPlaceholderScenario.BluetoothPermissionDenied, CYLPlaceholderScenario.NotificationPermissionDenied, CYLPlaceholderScenario.ServerError,
  CYLPlaceholderScenario.SyncFailed, CYLPlaceholderScenario.Loading, CYLPlaceholderScenario.Uploading, CYLPlaceholderScenario.Success, CYLPlaceholderScenario.HUD
];

const SCENARIO_NAMES: string[] = [
  'NetworkUnavailable', 'NoContent', 'TapToReload', 'LoadFailedWithHint', 'TapToReconnect', 'RetryButton',
  'RetryOutlinedButton', 'RetryWithHint', 'RetryOrContactSupport', 'IllustrationRetry', 'RefreshIcon',
  'TitleAboveIllustration', 'TextOnly', 'TapMeRetry', 'LocationPermissionDenied', 'NoSearchResults', 'EmptyCart',
  'NoOrders', 'NoFavorites', 'NoMessages', 'NoNotifications', 'NoPermission', 'CameraPermissionDenied',
  'PhotoLibraryPermissionDenied', 'MicrophonePermissionDenied', 'ContactsPermissionDenied',
  'CalendarPermissionDenied', 'BluetoothPermissionDenied', 'NotificationPermissionDenied', 'ServerError',
  'SyncFailed', 'Loading', 'Uploading', 'Success', 'HUD'
];

/** The group a scenario belongs to (iOS `CYLPlaceholderScenarioCategory`). */
export enum CYLPlaceholderScenarioCategory {
  LoadFailed,
  Empty,
  Permission,
  Progress,
  Success
}

/** The permission a scenario is about (iOS `CYLPlaceholderPermission`). */
export enum CYLPlaceholderPermission {
  None,
  Location,
  Camera,
  PhotoLibrary,
  Microphone,
  Contacts,
  Calendar,
  Bluetooth,
  Notifications
}

const PERMISSIONS: CYLPlaceholderPermission[] = [
  CYLPlaceholderPermission.None, CYLPlaceholderPermission.Location, CYLPlaceholderPermission.Camera,
  CYLPlaceholderPermission.PhotoLibrary, CYLPlaceholderPermission.Microphone, CYLPlaceholderPermission.Contacts,
  CYLPlaceholderPermission.Calendar, CYLPlaceholderPermission.Bluetooth, CYLPlaceholderPermission.Notifications
];

const PERMISSION_SCENARIOS: CYLPlaceholderScenario[] = [
  CYLPlaceholderScenario.NoPermission, CYLPlaceholderScenario.LocationPermissionDenied, CYLPlaceholderScenario.CameraPermissionDenied, CYLPlaceholderScenario.PhotoLibraryPermissionDenied,
  CYLPlaceholderScenario.MicrophonePermissionDenied, CYLPlaceholderScenario.ContactsPermissionDenied, CYLPlaceholderScenario.CalendarPermissionDenied, CYLPlaceholderScenario.BluetoothPermissionDenied,
  CYLPlaceholderScenario.NotificationPermissionDenied
];

/** The look of a button component (iOS `CYLPlaceholderButtonStyle`). */
export enum CYLPlaceholderButtonStyle {
  Filled,
  Outlined,
  Capsule
}

/**
 * The actions of the scenarios' buttons and taps (iOS `CYLPlaceholderAction`, an NSString enum): a string, with the
 * iOS values. An app may use its own strings as well.
 */
export type CYLPlaceholderAction = string;

export class CYLPlaceholderActions {
  static readonly Retry: CYLPlaceholderAction = 'CYLPlaceholderActionRetry';
  static readonly ContactSupport: CYLPlaceholderAction = 'CYLPlaceholderActionContactSupport';
  static readonly OpenSettings: CYLPlaceholderAction = 'CYLPlaceholderActionOpenSettings';
  static readonly GoShopping: CYLPlaceholderAction = 'CYLPlaceholderActionGoShopping';
  static readonly Done: CYLPlaceholderAction = 'CYLPlaceholderActionDone';
  static readonly ChooseManually: CYLPlaceholderAction = 'CYLPlaceholderActionChooseManually';
}

const ACTION_NAMES: string[] = ['Retry', 'ContactSupport', 'OpenSettings', 'GoShopping', 'Done', 'ChooseManually'];
const ACTION_VALUES: string[] = [CYLPlaceholderActions.Retry, CYLPlaceholderActions.ContactSupport, CYLPlaceholderActions.OpenSettings, CYLPlaceholderActions.GoShopping, CYLPlaceholderActions.Done, CYLPlaceholderActions.ChooseManually];
const ACTION_TITLE_KEYS: string[] = ['action_retry_title', 'action_contact_support_title',
  'action_open_settings_title', 'action_go_shopping_title', 'action_done_title', 'action_choose_manually_title'];

/** The side of an icon in vp (iOS CYLScenarioIconSide). */
export const CYLScenarioIconSide: number = 96;
/** The side of an illustration in vp (iOS CYLScenarioIllustrationSide). */
export const CYLScenarioIllustrationSide: number = 160;
/** The accent color of texts and buttons. */
export const CYLPlaceholderAccentColor: string = '#007AFF';

/** What a component draws. */
export enum CYLPlaceholderComponentKind {
  /** An icon or illustration with an optional title, or a title alone. */
  Item,
  /** A secondary line of text. */
  Hint,
  /** A title drawn as a button. */
  Button,
  /** "——  or  ——". */
  Separator
}

/**
 * One element of a placeholder stack (iOS `CYLPlaceholderComponent`).
 */
/**
 * Whether a bundled animation is a spinner (loading, progress, activity…), which loops by default so a loading
 * indicator never freezes; every other one plays once and rests on its last frame (iOS
 * `CYLScenarioAnimationLoopsByDefault`, 2026-11-19; the examples' `loopsByDefault` list).
 */
export function CYLPlaceholderAnimationLoopsByDefault(fileName: string): boolean {
  return ['Loading', 'Spinner', 'Progress', 'Throbber', 'Activity', 'Ring', 'Dots', 'Cycle', 'Arc', 'Clockwise',
    'Uploading', 'Infinity'].some((word: string) => fileName.includes(word));
}

export class CYLPlaceholderComponent {
  readonly kind: CYLPlaceholderComponentKind;
  /** A bundled icon name ("wifi_off"), or an app's Resource / path. */
  readonly image: ResourceStr | null;
  /** Whether the icon is tinted with the icon color (the bundled icons are black templates). */
  readonly tinted: boolean;
  readonly imageSide: number;
  readonly title: string | null;
  /** The title's font size in fp; 0 uses the default. */
  readonly titleFont: number;
  readonly titleColor: ResourceColor | null;
  readonly buttonStyle: CYLPlaceholderButtonStyle | null;
  /** The action sent when the component is tapped, or null. */
  action: CYLPlaceholderAction | null;
  /** Where image names in `attributes` are looked up (iOS `imageBundle`); null uses the library's bundled icons. */
  imageBundle: CYLPlaceholderImageBundle | null = null;
  /** The space above the component, in vp. */
  spacingBefore: number;
  /** false ignores taps on the component. */
  interactionEnabled: boolean = true;
  tapHighlightStyle: CYLPlaceholderTapHighlightStyle = CYLPlaceholderTapHighlightStyle.Dim;
  /** 0 loops the animation, N plays it N times; once by default, spinners loop (componentWithBundledAnimation, iOS). */
  animationRepeatCount: number = 1;
  /** The bundled animation of the component ("CYLPlaceholderNoInternet.json"), played in place of its image. */
  animationFileName: string | null = null;
  accessibilityIdentifier: string | null = null;

  private constructor(kind: CYLPlaceholderComponentKind, image: ResourceStr | null, tinted: boolean, imageSide: number,
    title: string | null, titleFont: number, titleColor: ResourceColor | null,
    buttonStyle: CYLPlaceholderButtonStyle | null, action: CYLPlaceholderAction | null) {
    this.kind = kind;
    this.image = image;
    this.tinted = tinted;
    this.imageSide = imageSide;
    this.title = title;
    this.titleFont = titleFont;
    this.titleColor = titleColor;
    this.buttonStyle = buttonStyle;
    this.action = action;
    switch (kind) {
      case CYLPlaceholderComponentKind.Hint:
        this.spacingBefore = 4;
        break;
      case CYLPlaceholderComponentKind.Button:
        this.spacingBefore = 20;
        break;
      case CYLPlaceholderComponentKind.Separator:
        this.spacingBefore = 14;
        break;
      default:
        this.spacingBefore = 12;
    }
  }

  /** The item attributes the component draws (CYLPlaceholderItem* keys). */
  get attributes(): Record<string, Object> {
    const out: Record<string, Object> = {};
    if (this.title !== null) {
      out[CYLPlaceholderItemTitle] = this.title;
    }
    if (this.image !== null) {
      out[CYLPlaceholderItemImage] = this.image;
    }
    if (this.titleColor !== null) {
      out[CYLPlaceholderItemTitleColor] = this.titleColor;
    }
    if (this.titleFont > 0) {
      out[CYLPlaceholderItemTitleFont] = this.titleFont;
    }
    if (this.animationFileName !== null) {
      out[CYLPlaceholderItemAnimationFilePath] = this.animationFileName;
    }
    if (this.accessibilityIdentifier !== null) {
      out[CYLPlaceholderItemAccessibilityIdentifier] = this.accessibilityIdentifier;
    }
    return out;
  }

  /** A copy (NSCopying). */
  copy(): CYLPlaceholderComponent {
    const c = new CYLPlaceholderComponent(this.kind, this.image, this.tinted, this.imageSide, this.title,
      this.titleFont, this.titleColor, this.buttonStyle, this.action);
    c.imageBundle = this.imageBundle;
    c.spacingBefore = this.spacingBefore;
    c.interactionEnabled = this.interactionEnabled;
    c.tapHighlightStyle = this.tapHighlightStyle;
    c.animationRepeatCount = this.animationRepeatCount;
    c.animationFileName = this.animationFileName;
    c.accessibilityIdentifier = this.accessibilityIdentifier;
    return c;
  }

  /**
   * A component drawing item attributes: CYLPlaceholderItemTitle, CYLPlaceholderItemImage (a bundled icon name or a
   * Resource), CYLPlaceholderItemStyle, CYLPlaceholderItemTitleColor, CYLPlaceholderItemTitleFont,
   * CYLPlaceholderItemInteractionEnabled, CYLPlaceholderItemTapHighlightStyle, CYLPlaceholderItemAnimationRepeatCount,
   * CYLPlaceholderItemAnimationFilePath and CYLPlaceholderItemAccessibilityIdentifier.
   */
  static componentWithAttributes(attributes: Record<string, Object>, action: CYLPlaceholderAction | null):
    CYLPlaceholderComponent {
    let image: ResourceStr | null = null;
    const rawImage: Object | undefined = attributes[CYLPlaceholderItemImage];
    if (typeof rawImage === 'string') {
      image = rawImage as string;
    } else if (rawImage !== undefined && rawImage !== null) {
      image = rawImage as Resource;
    } else {
      const style = readStyle(attributes[CYLPlaceholderItemStyle]);
      if (style !== null) {
        image = CYLPlaceholderIconNameForStyle(style);
      }
    }
    const title = readString(attributes[CYLPlaceholderItemTitle]);
    const font = readNumber(attributes[CYLPlaceholderItemTitleFont]);
    const rawColor: Object | undefined = attributes[CYLPlaceholderItemTitleColor];
    let color: ResourceColor | null = null;
    if (typeof rawColor === 'string') {
      color = rawColor as string;
    } else if (typeof rawColor === 'number') {
      color = rawColor as number;
    } else if (rawColor !== undefined && rawColor !== null) {
      color = rawColor as Resource;
    }
    const c = new CYLPlaceholderComponent(CYLPlaceholderComponentKind.Item, image, true,
      image !== null ? CYLScenarioIconSide : 0, title, font !== null ? font : 0, color, null, action);
    applyCommon(c, attributes[CYLPlaceholderItemInteractionEnabled], attributes[CYLPlaceholderItemTapHighlightStyle],
      attributes[CYLPlaceholderItemAnimationRepeatCount], attributes[CYLPlaceholderItemAccessibilityIdentifier]);
    const animation = readString(attributes[CYLPlaceholderItemAnimationFilePath]);
    if (animation !== null) {
      c.animationFileName = animation;
    }
    return c;
  }

  /**
   * A bundled animation with a static fallback style and an optional title: the fallback icon shows until the
   * animation is ready, and when its engine cannot play it. It plays once and rests on its last frame; a spinner
   * (CYLPlaceholderAnimationLoopsByDefault) loops (iOS e8e9eb6, 2026-11-19). Set `animationRepeatCount` to change it.
   */
  static componentWithBundledAnimation(fileName: string | null, fallbackStyle: CYLPlaceholderStyle,
    title: string | null, size: number, action: CYLPlaceholderAction | null): CYLPlaceholderComponent {
    const c = new CYLPlaceholderComponent(CYLPlaceholderComponentKind.Item, CYLPlaceholderIconNameForStyle(fallbackStyle),
      fallbackStyle !== CYLPlaceholderStyle.Empty, size > 0 ? size : CYLScenarioIconSide, title, 0, null, null, action);
    c.animationFileName = fileName;
    c.animationRepeatCount = fileName !== null && CYLPlaceholderAnimationLoopsByDefault(fileName) ? 0 : 1;
    return c;
  }

  /** An icon (a bundled icon name or a Resource) with an optional title (the Android `icon`). */
  static iconComponent(image: ResourceStr, title: string | null, side: number = CYLScenarioIconSide,
    tinted: boolean = true, action: CYLPlaceholderAction | null = null): CYLPlaceholderComponent {
    return new CYLPlaceholderComponent(CYLPlaceholderComponentKind.Item, image, tinted, side, title, 0, null, null,
      action);
  }

  /** A title alone (the Android `text`). */
  static textComponent(title: string, size: number = 0, color: ResourceColor | null = null): CYLPlaceholderComponent {
    return new CYLPlaceholderComponent(CYLPlaceholderComponentKind.Item, null, false, 0, title, size, color, null, null);
  }

  /** A secondary line of text under the title. */
  static hintComponentWithText(text: string): CYLPlaceholderComponent {
    return new CYLPlaceholderComponent(CYLPlaceholderComponentKind.Hint, null, false, 0, text, 0, null, null, null);
  }

  /** A title drawn as a button. */
  static buttonComponentWithTitle(title: string, style: CYLPlaceholderButtonStyle,
    action: CYLPlaceholderAction | null): CYLPlaceholderComponent {
    return new CYLPlaceholderComponent(CYLPlaceholderComponentKind.Button, null, false, 0, title, 0, null, style,
      action);
  }

  /** A separator such as "——  or  ——". */
  static separatorComponentWithText(text: string): CYLPlaceholderComponent {
    return new CYLPlaceholderComponent(CYLPlaceholderComponentKind.Separator, null, false, 0, text, 0, null, null,
      null);
  }

  /**
   * A component from a configuration dictionary (parsed JSON): "type" is "icon", "hint", "button", "separator" or
   * "item" (raw item attributes in "attributes"); "title"/"text" with an optional localization key
   * "titleKey"/"textKey"; "animation", "style" (a CYLPlaceholderStyle name or number), "size", "buttonStyle"
   * ("filled", "outlined", "capsule"), "action", "interactionEnabled", "highlightStyle" ("dim", "shrink", "none"),
   * "repeatCount" (0 or "loop", N, "once"), "spacingBefore" and "accessibilityIdentifier". null, with the reason
   * passed to onError, for an invalid dictionary.
   */
  static componentWithDictionary(dictionary: Record<string, Object>,
    onError: ((message: string) => void) | null = null): CYLPlaceholderComponent | null {
    const fail = (message: string): CYLPlaceholderComponent | null => {
      if (onError !== null) {
        onError(message);
      }
      return null;
    };
    const type = readString(dictionary['type']);
    if (type === null) {
      return fail('A component needs a "type".');
    }
    const action = readString(dictionary['action']);
    const resolvedAction = action !== null ? CYLPlaceholderScenarioCatalog.actionNamed(action) : null;
    let text = readString(dictionary['title']);
    if (text === null) {
      text = readString(dictionary['text']);
    }
    let key = readString(dictionary['titleKey']);
    if (key === null) {
      key = readString(dictionary['textKey']);
    }
    if (key !== null) {
      text = CYLPlaceholderLocalization.localizedStringForKey(key, text);
    }
    let c: CYLPlaceholderComponent;
    switch (type.toLowerCase()) {
      case 'icon': {
        const style = readStyle(dictionary['style']);
        const size = readNumber(dictionary['size']);
        c = CYLPlaceholderComponent.componentWithBundledAnimation(readString(dictionary['animation']),
          style !== null ? style : CYLPlaceholderStyle.Empty, text, size !== null ? size : CYLScenarioIconSide,
          resolvedAction);
        break;
      }
      case 'hint':
        if (text === null) {
          return fail('A hint needs a "text".');
        }
        c = CYLPlaceholderComponent.hintComponentWithText(text);
        break;
      case 'separator':
        if (text === null) {
          return fail('A separator needs a "text".');
        }
        c = CYLPlaceholderComponent.separatorComponentWithText(text);
        break;
      case 'button': {
        if (text === null) {
          return fail('A button needs a "title".');
        }
        const styleName = readString(dictionary['buttonStyle']);
        let style = CYLPlaceholderButtonStyle.Filled;
        if (styleName !== null) {
          const s = styleName.toLowerCase();
          if (s === 'outlined') {
            style = CYLPlaceholderButtonStyle.Outlined;
          } else if (s === 'capsule') {
            style = CYLPlaceholderButtonStyle.Capsule;
          } else if (s !== 'filled') {
            return fail('Unknown buttonStyle "' + styleName + '".');
          }
        }
        c = CYLPlaceholderComponent.buttonComponentWithTitle(text, style, resolvedAction);
        break;
      }
      case 'item': {
        const raw: Object | undefined = dictionary['attributes'];
        const attributes: Record<string, Object> = raw !== undefined && raw !== null && typeof raw === 'object' ?
          raw as Record<string, Object> : dictionary;
        c = CYLPlaceholderComponent.componentWithAttributes(attributes, resolvedAction);
        break;
      }
      default:
        return fail('Unknown component type "' + type + '".');
    }
    applyCommon(c, dictionary['interactionEnabled'], dictionary['highlightStyle'], dictionary['repeatCount'],
      dictionary['accessibilityIdentifier']);
    const spacing = readNumber(dictionary['spacingBefore']);
    if (spacing !== null) {
      c.spacingBefore = spacing;
    }
    return c;
  }
}

function readString(value: Object | undefined): string | null {
  return typeof value === 'string' ? value as string : null;
}

function readNumber(value: Object | undefined): number | null {
  if (typeof value === 'number') {
    return value as number;
  }
  if (typeof value === 'string') {
    const n = Number(value as string);
    return isNaN(n) ? null : n;
  }
  return null;
}

function readStyle(value: Object | undefined): CYLPlaceholderStyle | null {
  if (typeof value === 'number') {
    const n = value as number;
    return n >= 0 && n < CYLPlaceholderStyle.Count ? CYLPlaceholderStyleValues[Math.floor(n)] : null;
  }
  if (typeof value === 'string') {
    return CYLPlaceholderStyleNamed(value as string);
  }
  return null;
}

function applyCommon(c: CYLPlaceholderComponent, interaction: Object | undefined, highlight: Object | undefined,
  repeat: Object | undefined, identifier: Object | undefined): void {
  if (typeof interaction === 'boolean') {
    c.interactionEnabled = interaction as boolean;
  }
  if (typeof highlight === 'number') {
    const h = highlight as number;
    c.tapHighlightStyle = h === 1 ? CYLPlaceholderTapHighlightStyle.Shrink :
      h === 2 ? CYLPlaceholderTapHighlightStyle.None : CYLPlaceholderTapHighlightStyle.Dim;
  } else if (typeof highlight === 'string') {
    const h = (highlight as string).toLowerCase();
    c.tapHighlightStyle = h === 'shrink' ? CYLPlaceholderTapHighlightStyle.Shrink :
      h === 'none' ? CYLPlaceholderTapHighlightStyle.None : CYLPlaceholderTapHighlightStyle.Dim;
  }
  if (typeof repeat === 'number') {
    c.animationRepeatCount = Math.max(0, Math.floor(repeat as number));
  } else if (typeof repeat === 'string') {
    const r = (repeat as string).toLowerCase();
    c.animationRepeatCount = r === 'once' ? 1 : r === 'loop' ? 0 : Math.max(0, Math.floor(Number(r)) || 0);
  }
  const id = readString(identifier);
  if (id !== null) {
    c.accessibilityIdentifier = id;
  }
}

// The animation files of each scenario: the main icon's own files, then variants (as on iOS and Android).
const ICON_FILES: Record<string, string[]> = {
  'NetworkUnavailable': ['CYLPlaceholderNoInternet.json'],
  'NoContent': ['CYLPlaceholderEmpty.json'],
  'TapToReload': ['CYLPlaceholderRefresh.json'],
  'LoadFailedWithHint': ['CYLPlaceholderLoadFailed.json'],
  'TapToReconnect': ['CYLPlaceholderNoInternet.json'],
  'RetryButton': ['CYLPlaceholderSad.json'],
  'RetryOutlinedButton': ['CYLPlaceholderLoadFailed.json'],
  'RetryWithHint': ['CYLPlaceholderNoInternet.json'],
  'RetryOrContactSupport': ['CYLPlaceholderServerError.json'],
  'IllustrationRetry': ['CYLPlaceholderCloudOff.json'],
  'RefreshIcon': ['CYLPlaceholderSad.json', 'CYLPlaceholderRefresh.json'],
  'TitleAboveIllustration': ['CYLPlaceholderPullHint.pag'],
  'TapMeRetry': ['CYLPlaceholderTapHint.json', 'CYLPlaceholderCloudOff.json'],
  'NoSearchResults': ['CYLPlaceholderNoResults.json'],
  'EmptyCart': ['CYLPlaceholderEmptyCart.json'],
  'NoOrders': ['CYLPlaceholderNoOrders.json'],
  'NoFavorites': ['CYLPlaceholderNoFavorites.pag'],
  'NoMessages': ['CYLPlaceholderNoMessages.json'],
  'NoNotifications': ['CYLPlaceholderNoNotifications.json'],
  'NoPermission': ['CYLPlaceholderNoPermission.json'],
  'LocationPermissionDenied': ['CYLPlaceholderLocationPermission.json'],
  'CameraPermissionDenied': ['CYLPlaceholderCameraPermission.json'],
  'PhotoLibraryPermissionDenied': ['CYLPlaceholderPhotoLibraryPermission.json'],
  'MicrophonePermissionDenied': ['CYLPlaceholderMicrophonePermission.json'],
  'ContactsPermissionDenied': ['CYLPlaceholderContactsPermission.json'],
  'CalendarPermissionDenied': ['CYLPlaceholderCalendarPermission.json'],
  'BluetoothPermissionDenied': ['CYLPlaceholderBluetoothPermission.json'],
  'NotificationPermissionDenied': ['CYLPlaceholderNotificationPermission.json'],
  'ServerError': ['CYLPlaceholderServerError.json'],
  'SyncFailed': ['CYLPlaceholderCloudOff.json'],
  'Loading': ['CYLPlaceholderLoading.json'],
  'Uploading': ['CYLPlaceholderUploading.gif'],
  'Success': ['CYLPlaceholderSuccess.riv'],
  'HUD': ['CYLRefreshActivity.gif']
};

const VARIANT_FILES: Record<string, string[]> = {
  'NoContent': ['CYLPlaceholderNoDrafts.json'],
  'TapToReload': ['CYLPlaceholderPullToRefresh.riv'],
  'RetryOrContactSupport': ['CYLPlaceholderContactSupport.json'],
  'RefreshIcon': ['CYLPlaceholderRefresh.json', 'CYLPlaceholderPullToRefresh.riv'],
  'TitleAboveIllustration': ['CYLPlaceholderPullToRefresh.riv'],
  'TapMeRetry': ['CYLPlaceholderNoInternet.json'],
  'LocationPermissionDenied': ['CYLPlaceholderLocation.json'],
  'NoFavorites': ['CYLPlaceholderNoFavorites.gif', 'CYLPlaceholderNoFavorites.json'],
  'NoPermission': ['CYLPlaceholderSettings.json'],
  'SyncFailed': ['CYLPlaceholderLoadingInfinity.json'],
  'Loading': ['CYLPlaceholderLoading.pag', 'CYLPlaceholderLoading.riv', 'CYLPlaceholderLoadingInfinity.json',
    'CYLPlaceholderProgress.pag'],
  'Uploading': ['CYLPlaceholderProgress.pag'],
  'Success': ['CYLPlaceholderSuccess.json', 'CYLPlaceholderCelebrate.json'],
  'HUD': ['CYLRefreshMaterialSpinner.json', 'CYLRefreshGradientSpinner.json', 'CYLRefreshRing.gif',
    'CYLPlaceholderProgress.pag', 'CYLRefreshIcon.riv']
};

const SCREENSHOTS: Record<string, number[]> = {
  'NetworkUnavailable': [4, 5, 6, 25, 36],
  'NoContent': [7, 9, 10],
  'TapToReload': [13, 14, 15, 24, 26, 28, 31, 32, 37, 42, 43],
  'LoadFailedWithHint': [21, 22, 27, 29],
  'TapToReconnect': [8],
  'RetryButton': [1, 2, 11, 19],
  'LocationPermissionDenied': [20],
  'RetryOutlinedButton': [33, 38, 39],
  'RetryWithHint': [16, 23, 40],
  'RetryOrContactSupport': [3],
  'IllustrationRetry': [18],
  'RefreshIcon': [12],
  'TitleAboveIllustration': [17],
  'TextOnly': [30, 41],
  'TapMeRetry': [34, 35]
};

const EMPTY_SCENARIOS: CYLPlaceholderScenario[] = [CYLPlaceholderScenario.NoContent, CYLPlaceholderScenario.NoSearchResults, CYLPlaceholderScenario.EmptyCart, CYLPlaceholderScenario.NoOrders,
  CYLPlaceholderScenario.NoFavorites, CYLPlaceholderScenario.NoMessages, CYLPlaceholderScenario.NoNotifications];
const BACKGROUND_RETRY: CYLPlaceholderScenario[] = [CYLPlaceholderScenario.TapToReload, CYLPlaceholderScenario.TapToReconnect, CYLPlaceholderScenario.TitleAboveIllustration,
  CYLPlaceholderScenario.TextOnly];

/**
 * The scenarios' components, names, categories and permissions (iOS `CYLPlaceholderScenarioCatalog`).
 */
export class CYLPlaceholderScenarioCatalog {
  /** Every scenario, in order. */
  static get allScenarios(): CYLPlaceholderScenario[] {
    return ALL_SCENARIOS.slice();
  }

  /** The scenario's name without the prefix ("RetryButton"). */
  static nameForScenario(scenario: CYLPlaceholderScenario): string {
    return SCENARIO_NAMES[scenario];
  }

  /**
   * The scenario called name, with or without the "CYLPlaceholderScenario" prefix, in any case. iOS returns -1 for
   * an unknown name; this returns null.
   */
  static scenarioNamed(name: string | null): CYLPlaceholderScenario | null {
    if (name === null || name.length === 0) {
      return null;
    }
    const plain = name.toLowerCase().replace(new RegExp('^cylplaceholderscenario'), '');
    for (let i = 0; i < SCENARIO_NAMES.length; i++) {
      if (SCENARIO_NAMES[i].toLowerCase() === plain) {
        return ALL_SCENARIOS[i];
      }
    }
    return null;
  }

  /** The action called name ("retry", "CYLPlaceholderActionRetry", any case); an unknown name is returned as is. */
  static actionNamed(name: string): CYLPlaceholderAction {
    const plain = name.toLowerCase().replace(new RegExp('^cylplaceholderaction'), '');
    for (let i = 0; i < ACTION_NAMES.length; i++) {
      if (ACTION_NAMES[i].toLowerCase() === plain) {
        return ACTION_VALUES[i];
      }
    }
    return name;
  }

  /** The localized button title of a built-in action, or null for an app's own action. */
  static localizedTitleForAction(action: CYLPlaceholderAction): string | null {
    const index = ACTION_VALUES.indexOf(action);
    return index < 0 ? null : CYLPlaceholderLocalization.localizedStringForKey(ACTION_TITLE_KEYS[index], null);
  }

  /** The localized display name of a scenario. */
  static localizedNameForScenario(scenario: CYLPlaceholderScenario): string {
    return CYLPlaceholderLocalization.localizedStringForKey(
      'scenario_' + CYLPlaceholderSnakeCase(SCENARIO_NAMES[scenario]) + '_name', null);
  }

  /** The README screenshot numbers a scenario stands for (empty when none). */
  static readmeScreenshotNumbersForScenario(scenario: CYLPlaceholderScenario): number[] {
    const found: number[] | undefined = SCREENSHOTS[SCENARIO_NAMES[scenario]];
    return found !== undefined ? found.slice() : [];
  }

  /** Every animation file of a scenario (Lottie / PAG / Rive / GIF), the main icon's first. */
  static animationFileNamesForScenario(scenario: CYLPlaceholderScenario): string[] {
    const name = SCENARIO_NAMES[scenario];
    const out: string[] = [];
    const icon: string[] | undefined = ICON_FILES[name];
    const variants: string[] | undefined = VARIANT_FILES[name];
    const all: string[] = (icon !== undefined ? icon : []).concat(variants !== undefined ? variants : []);
    all.forEach((f: string) => {
      if (!out.includes(f)) {
        out.push(f);
      }
    });
    return out;
  }

  /** The action of a tap anywhere on the placeholder, or null. */
  static backgroundActionForScenario(scenario: CYLPlaceholderScenario): CYLPlaceholderAction | null {
    return BACKGROUND_RETRY.includes(scenario) ? CYLPlaceholderActions.Retry : null;
  }

  static permissionForScenario(scenario: CYLPlaceholderScenario): CYLPlaceholderPermission {
    const index = PERMISSION_SCENARIOS.indexOf(scenario);
    return index <= 0 ? CYLPlaceholderPermission.None : PERMISSIONS[index];
  }

  /** The scenario of a permission; None gives NoPermission. */
  static scenarioForPermission(permission: CYLPlaceholderPermission): CYLPlaceholderScenario {
    const index = PERMISSIONS.indexOf(permission);
    return PERMISSION_SCENARIOS[index < 0 ? 0 : index];
  }

  static categoryForScenario(scenario: CYLPlaceholderScenario): CYLPlaceholderScenarioCategory {
    if (PERMISSION_SCENARIOS.includes(scenario)) {
      return CYLPlaceholderScenarioCategory.Permission;
    }
    if (EMPTY_SCENARIOS.includes(scenario)) {
      return CYLPlaceholderScenarioCategory.Empty;
    }
    if (scenario === CYLPlaceholderScenario.Loading || scenario === CYLPlaceholderScenario.Uploading || scenario === CYLPlaceholderScenario.HUD) {
      return CYLPlaceholderScenarioCategory.Progress;
    }
    if (scenario === CYLPlaceholderScenario.Success) {
      return CYLPlaceholderScenarioCategory.Success;
    }
    return CYLPlaceholderScenarioCategory.LoadFailed;
  }

  /**
   * The components of a scenario, in the effective language. The first icon carries the scenario's main animation
   * file (`animationFileName`; once, a spinner loops), played in place of its static icon once loaded.
   */
  static componentsForScenario(scenario: CYLPlaceholderScenario): CYLPlaceholderComponent[] {
    const components = staticComponents(scenario);
    const files = CYLPlaceholderScenarioCatalog.animationFileNamesForScenario(scenario);
    for (let i = 0; i < components.length; i++) {
      const c = components[i];
      if (c.kind === CYLPlaceholderComponentKind.Item && c.image !== null) {
        if (files.length > 0) {
          c.animationFileName = files[0];
          // Once by default, spinners loop (iOS componentWithBundledAnimation:, e8e9eb6).
          c.animationRepeatCount = CYLPlaceholderAnimationLoopsByDefault(files[0]) ? 0 : 1;
        }
        break;
      }
    }
    return components;
  }
}

function t(key: string): string {
  return CYLPlaceholderLocalization.localizedStringForKey(key, null);
}

function actionButton(action: CYLPlaceholderAction, style: CYLPlaceholderButtonStyle): CYLPlaceholderComponent {
  const title = CYLPlaceholderScenarioCatalog.localizedTitleForAction(action);
  return CYLPlaceholderComponent.buttonComponentWithTitle(title !== null ? title : '', style, action);
}

function withSpacing(c: CYLPlaceholderComponent, spacing: number): CYLPlaceholderComponent {
  c.spacingBefore = spacing;
  return c;
}

function staticComponents(scenario: CYLPlaceholderScenario): CYLPlaceholderComponent[] {
  const s = 'scenario_' + CYLPlaceholderSnakeCase(SCENARIO_NAMES[scenario]) + '_';
  const own = (image: string, side: number = CYLScenarioIconSide): CYLPlaceholderComponent =>
    CYLPlaceholderComponent.iconComponent(image, t(s + 'title'), side);
  const hint = (key: string): CYLPlaceholderComponent => CYLPlaceholderComponent.hintComponentWithText(t(key));
  const titled = (key: string, style: CYLPlaceholderButtonStyle, action: CYLPlaceholderAction):
    CYLPlaceholderComponent => CYLPlaceholderComponent.buttonComponentWithTitle(t(key), style, action);
  const permission = (image: string): CYLPlaceholderComponent[] =>
    [own(image), hint(s + 'hint'), actionButton(CYLPlaceholderActions.OpenSettings, CYLPlaceholderButtonStyle.Filled)];
  const F = CYLPlaceholderButtonStyle.Filled;
  const O = CYLPlaceholderButtonStyle.Outlined;
  switch (scenario) {
    case CYLPlaceholderScenario.NetworkUnavailable:
      return [own('wifi_off')];
    case CYLPlaceholderScenario.NoContent:
      return [CYLPlaceholderComponent.iconComponent('empty', t(s + 'title'), CYLScenarioIllustrationSide, false)];
    case CYLPlaceholderScenario.TapToReload:
      return [own('refresh')];
    case CYLPlaceholderScenario.LoadFailedWithHint:
      return [own('error_outline'), hint(s + 'hint')];
    case CYLPlaceholderScenario.TapToReconnect:
      return [own('signal_wifi_off'), hint(s + 'hint')];
    case CYLPlaceholderScenario.RetryButton:
      return [own('no_internet'), actionButton(CYLPlaceholderActions.Retry, F)];
    case CYLPlaceholderScenario.RetryOutlinedButton:
      return [own('report_problem'), actionButton(CYLPlaceholderActions.Retry, O)];
    case CYLPlaceholderScenario.RetryWithHint:
      return [own('wifi_off'), hint(s + 'hint'), titled('scenario_reload_title', O, CYLPlaceholderActions.Retry)];
    case CYLPlaceholderScenario.RetryOrContactSupport:
      return [own('cloud_off'), actionButton(CYLPlaceholderActions.Retry, F),
        CYLPlaceholderComponent.separatorComponentWithText(t('scenario_or_separator')),
        withSpacing(actionButton(CYLPlaceholderActions.ContactSupport, O), 14)];
    case CYLPlaceholderScenario.IllustrationRetry:
      return [CYLPlaceholderComponent.iconComponent('cloud_off', null, CYLScenarioIllustrationSide),
        titled('scenario_tap_to_retry_title', CYLPlaceholderButtonStyle.Capsule, CYLPlaceholderActions.Retry)];
    case CYLPlaceholderScenario.RefreshIcon:
      return [own('help'), withSpacing(CYLPlaceholderComponent.iconComponent('refresh', null, 44, true, CYLPlaceholderActions.Retry), 28)];
    case CYLPlaceholderScenario.TitleAboveIllustration:
      return [CYLPlaceholderComponent.textComponent(t(s + 'title')),
        CYLPlaceholderComponent.iconComponent('refresh', null, CYLScenarioIllustrationSide)];
    case CYLPlaceholderScenario.TextOnly:
      return [CYLPlaceholderComponent.textComponent(t(s + 'title'), 20), hint(s + 'hint')];
    case CYLPlaceholderScenario.TapMeRetry:
      return [CYLPlaceholderComponent.textComponent(t('scenario_tap_me_title'), 0, CYLPlaceholderAccentColor),
        withSpacing(CYLPlaceholderComponent.iconComponent('info', null, 36), 4),
        withSpacing(titled('scenario_reload_now_title', F, CYLPlaceholderActions.Retry), 4),
        withSpacing(CYLPlaceholderComponent.iconComponent('cloud_off', null, 96), 12)];
    case CYLPlaceholderScenario.NoSearchResults:
      return [own('search_off'), hint(s + 'hint')];
    case CYLPlaceholderScenario.EmptyCart:
      return [own('empty_cart', CYLScenarioIllustrationSide), actionButton(CYLPlaceholderActions.GoShopping, O)];
    case CYLPlaceholderScenario.NoOrders:
      return [own('archive'), actionButton(CYLPlaceholderActions.GoShopping, F)];
    case CYLPlaceholderScenario.NoFavorites:
      return [own('favorite', CYLScenarioIllustrationSide), hint(s + 'hint')];
    case CYLPlaceholderScenario.NoMessages:
      return [own('inbox')];
    case CYLPlaceholderScenario.NoNotifications:
      return [own('notifications_off'), hint(s + 'hint')];
    case CYLPlaceholderScenario.NoPermission:
      return [own('locked'), hint(s + 'hint'), actionButton(CYLPlaceholderActions.OpenSettings, F)];
    case CYLPlaceholderScenario.LocationPermissionDenied:
      return permission('location_off').concat([
        withSpacing(titled('scenario_choose_address_title', O, CYLPlaceholderActions.ChooseManually), 12)]);
    case CYLPlaceholderScenario.CameraPermissionDenied:
      return permission('video_off');
    case CYLPlaceholderScenario.PhotoLibraryPermissionDenied:
      return permission('photo_library');
    case CYLPlaceholderScenario.MicrophonePermissionDenied:
      return permission('music_off');
    case CYLPlaceholderScenario.ContactsPermissionDenied:
      return permission('group_off');
    case CYLPlaceholderScenario.CalendarPermissionDenied:
      return permission('event_busy');
    case CYLPlaceholderScenario.BluetoothPermissionDenied:
      return permission('bluetooth_disabled');
    case CYLPlaceholderScenario.NotificationPermissionDenied:
      return permission('notifications_off');
    case CYLPlaceholderScenario.ServerError:
      return [own('cloud_off'), hint(s + 'hint'), actionButton(CYLPlaceholderActions.Retry, F)];
    case CYLPlaceholderScenario.SyncFailed:
      return [own('sync_problem'), actionButton(CYLPlaceholderActions.Retry, O)];
    case CYLPlaceholderScenario.Loading:
      return [own('hourglass', CYLScenarioIllustrationSide)];
    case CYLPlaceholderScenario.Uploading:
      return [own('upload_off', CYLScenarioIllustrationSide)];
    case CYLPlaceholderScenario.Success:
      return [own('check_circle', CYLScenarioIllustrationSide), actionButton(CYLPlaceholderActions.Done, F)];
    case CYLPlaceholderScenario.HUD:
      return [own('hourglass', 56)];
    default:
      return [];
  }
}
