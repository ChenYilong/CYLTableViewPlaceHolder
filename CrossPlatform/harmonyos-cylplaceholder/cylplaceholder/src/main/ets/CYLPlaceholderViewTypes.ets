// The non-UI part of iOS CYLPlaceholderView.h: icon styles, messages, tap highlight, badge styles and appearance, and
// the item attribute keys (same values as iOS).
import { CYLPlaceholderLocalization } from './CYLPlaceholderLocalization';

/** A bundled icon (iOS `CYLPlaceholderStyle`), in the iOS order; `Count` is the number of styles. */
export enum CYLPlaceholderStyle {
  Empty,
  NoResults,
  Error,
  WifiOff,
  SignalWifiOff,
  NoInternet,
  CloudOff,
  SyncProblem,
  SyncDisabled,
  NetworkLocked,
  BluetoothDisabled,
  LocationOff,
  PublicOff,
  ErrorOutline,
  Warning,
  ReportProblem,
  Blocked,
  Help,
  Hourglass,
  Locked,
  VisibilityOff,
  SearchOff,
  FolderOff,
  FolderOpen,
  DownloadOff,
  UploadOff,
  Inbox,
  BrokenImage,
  ImageUnavailable,
  PhotoLibrary,
  MusicOff,
  VideoOff,
  PersonOff,
  GroupOff,
  EventBusy,
  EmptyCart,
  Favorite,
  BatteryAlert,
  UnknownDevice,
  PhoneDisabled,
  WrongLocation,
  Archive,
  Info,
  Refresh,
  Delete,
  Search,
  Mail,
  Image,
  Cloud,
  NotificationsOff,
  History,
  Count
}

/** The names of CYLPlaceholderStyle, by value. */
export const CYLPlaceholderStyleNames: string[] = [
  'Empty',
  'NoResults',
  'Error',
  'WifiOff',
  'SignalWifiOff',
  'NoInternet',
  'CloudOff',
  'SyncProblem',
  'SyncDisabled',
  'NetworkLocked',
  'BluetoothDisabled',
  'LocationOff',
  'PublicOff',
  'ErrorOutline',
  'Warning',
  'ReportProblem',
  'Blocked',
  'Help',
  'Hourglass',
  'Locked',
  'VisibilityOff',
  'SearchOff',
  'FolderOff',
  'FolderOpen',
  'DownloadOff',
  'UploadOff',
  'Inbox',
  'BrokenImage',
  'ImageUnavailable',
  'PhotoLibrary',
  'MusicOff',
  'VideoOff',
  'PersonOff',
  'GroupOff',
  'EventBusy',
  'EmptyCart',
  'Favorite',
  'BatteryAlert',
  'UnknownDevice',
  'PhoneDisabled',
  'WrongLocation',
  'Archive',
  'Info',
  'Refresh',
  'Delete',
  'Search',
  'Mail',
  'Image',
  'Cloud',
  'NotificationsOff',
  'History'
];

/** A ready-made text (iOS `CYLPlaceholderMessage`); `Count` is the number of messages. */
export enum CYLPlaceholderMessage {
  Empty,
  NoResults,
  NoInternet,
  ServerUnavailable,
  Error,
  Loading,
  NoPermission,
  EmptyCart,
  NoNotifications,
  Count
}

const MESSAGE_KEYS: string[] = ['empty_text', 'no_results_text', 'no_internet_text', 'server_unavailable_text',
  'error_text', 'loading_text', 'no_permission_text', 'empty_cart_text', 'no_notifications_text'];

/** How a tappable placeholder reacts while pressed (iOS `CYLPlaceholderTapHighlightStyle`). */
export enum CYLPlaceholderTapHighlightStyle {
  /** Dims to half opacity. */
  Dim,
  /** Shrinks to 95%. */
  Shrink,
  /** No feedback. */
  None
}

/** The kind of badge (iOS `CYLPlaceholderBadgeStyle`). */
export enum CYLPlaceholderBadgeStyle {
  None,
  Dot,
  Number,
  Text
}

/** Edge insets in vp (UIEdgeInsets). */
export class CYLEdgeInsets {
  top: number;
  left: number;
  bottom: number;
  right: number;

  constructor(top: number = 0, left: number = 0, bottom: number = 0, right: number = 0) {
    this.top = top;
    this.left = left;
    this.bottom = bottom;
    this.right = right;
  }
}

/** An offset in vp (CGPoint / UIOffset). */
export class CYLOffset {
  x: number;
  y: number;

  constructor(x: number = 0, y: number = 0) {
    this.x = x;
    this.y = y;
  }
}

/** The look of every badge (iOS `CYLPlaceholderBadgeAppearance`); change `sharedAppearance` before showing badges. */
export class CYLPlaceholderBadgeAppearance {
  backgroundColor: ResourceColor = '#FF3B30';
  textColor: ResourceColor = '#FFFFFF';
  /** The font size in fp (UIFont). */
  font: number = 12;
  /** A negative value makes a capsule. */
  cornerRadius: number = -1;
  contentInsets: CYLEdgeInsets = new CYLEdgeInsets(1, 5, 1, 5);
  /** Seconds. */
  animationDuration: number = 0.2;
  animatesChanges: boolean = true;

  private static shared: CYLPlaceholderBadgeAppearance = new CYLPlaceholderBadgeAppearance();

  static get sharedAppearance(): CYLPlaceholderBadgeAppearance {
    return CYLPlaceholderBadgeAppearance.shared;
  }
}

/** "NoContent" -> "no_content", "HUD" -> "h_u_d". */
export function CYLPlaceholderSnakeCase(name: string): string {
  let out = '';
  for (let i = 0; i < name.length; i++) {
    const c = name.charAt(i);
    if (i > 0 && c >= 'A' && c <= 'Z') {
      out += '_';
    }
    out += c.toLowerCase();
  }
  return out;
}

/** The bundled icon file of a style ("wifi_off"), or null for Count. */
export function CYLPlaceholderIconNameForStyle(style: CYLPlaceholderStyle): string | null {
  if (style < 0 || style >= CYLPlaceholderStyle.Count) {
    return null;
  }
  return CYLPlaceholderSnakeCase(CYLPlaceholderStyleNames[style]);
}

/** The iOS image name of a style ("CYLPlaceholderWifiOff"), or null for Count (`+imageNameForStyle:`). */
export function CYLPlaceholderImageNameForStyle(style: CYLPlaceholderStyle): string | null {
  if (style < 0 || style >= CYLPlaceholderStyle.Count) {
    return null;
  }
  return 'CYLPlaceholder' + CYLPlaceholderStyleNames[style];
}

/** The style called name ("WifiOff", "CYLPlaceholderStyleWifiOff", "wifi_off", any case), or null. */
export function CYLPlaceholderStyleNamed(name: string): CYLPlaceholderStyle | null {
  const plain = name.toLowerCase().replace(new RegExp('^cylplaceholder(style)?'), '').replace(new RegExp('_', 'g'), '');
  for (let i = 0; i < CYLPlaceholderStyleNames.length; i++) {
    if (CYLPlaceholderStyleNames[i].toLowerCase() === plain) {
      return CYLPlaceholderStyleValues[i];
    }
  }
  return null;
}

/** Every style except Count, in order. */
export const CYLPlaceholderStyleValues: CYLPlaceholderStyle[] = [
  CYLPlaceholderStyle.Empty,
  CYLPlaceholderStyle.NoResults,
  CYLPlaceholderStyle.Error,
  CYLPlaceholderStyle.WifiOff,
  CYLPlaceholderStyle.SignalWifiOff,
  CYLPlaceholderStyle.NoInternet,
  CYLPlaceholderStyle.CloudOff,
  CYLPlaceholderStyle.SyncProblem,
  CYLPlaceholderStyle.SyncDisabled,
  CYLPlaceholderStyle.NetworkLocked,
  CYLPlaceholderStyle.BluetoothDisabled,
  CYLPlaceholderStyle.LocationOff,
  CYLPlaceholderStyle.PublicOff,
  CYLPlaceholderStyle.ErrorOutline,
  CYLPlaceholderStyle.Warning,
  CYLPlaceholderStyle.ReportProblem,
  CYLPlaceholderStyle.Blocked,
  CYLPlaceholderStyle.Help,
  CYLPlaceholderStyle.Hourglass,
  CYLPlaceholderStyle.Locked,
  CYLPlaceholderStyle.VisibilityOff,
  CYLPlaceholderStyle.SearchOff,
  CYLPlaceholderStyle.FolderOff,
  CYLPlaceholderStyle.FolderOpen,
  CYLPlaceholderStyle.DownloadOff,
  CYLPlaceholderStyle.UploadOff,
  CYLPlaceholderStyle.Inbox,
  CYLPlaceholderStyle.BrokenImage,
  CYLPlaceholderStyle.ImageUnavailable,
  CYLPlaceholderStyle.PhotoLibrary,
  CYLPlaceholderStyle.MusicOff,
  CYLPlaceholderStyle.VideoOff,
  CYLPlaceholderStyle.PersonOff,
  CYLPlaceholderStyle.GroupOff,
  CYLPlaceholderStyle.EventBusy,
  CYLPlaceholderStyle.EmptyCart,
  CYLPlaceholderStyle.Favorite,
  CYLPlaceholderStyle.BatteryAlert,
  CYLPlaceholderStyle.UnknownDevice,
  CYLPlaceholderStyle.PhoneDisabled,
  CYLPlaceholderStyle.WrongLocation,
  CYLPlaceholderStyle.Archive,
  CYLPlaceholderStyle.Info,
  CYLPlaceholderStyle.Refresh,
  CYLPlaceholderStyle.Delete,
  CYLPlaceholderStyle.Search,
  CYLPlaceholderStyle.Mail,
  CYLPlaceholderStyle.Image,
  CYLPlaceholderStyle.Cloud,
  CYLPlaceholderStyle.NotificationsOff,
  CYLPlaceholderStyle.History
];

/** The localized text of a message, or null for Count (`+localizedTextForMessage:`). */
export function CYLPlaceholderLocalizedTextForMessage(message: CYLPlaceholderMessage): string | null {
  if (message < 0 || message >= CYLPlaceholderMessage.Count) {
    return null;
  }
  return CYLPlaceholderLocalization.localizedStringForKey(MESSAGE_KEYS[message], null);
}

// Item attribute keys, with the iOS values.
export const CYLPlaceholderItemTitle: string = 'CYLTabBarItemTitle';
export const CYLPlaceholderItemImage: string = 'CYLTabBarItemImage';
export const CYLPlaceholderItemImageInsets: string = 'CYLTabBarItemImageInsets';
export const CYLPlaceholderItemImagePositionAdjustment: string = 'CYLTabBarItemImagePositionAdjustment';
export const CYLPlaceholderItemTitlePositionAdjustment: string = 'CYLTabBarItemTitlePositionAdjustment';
export const CYLPlaceholderItemStyle: string = 'CYLPlaceholderItemStyle';
export const CYLPlaceholderItemMessage: string = 'CYLPlaceholderItemMessage';
export const CYLPlaceholderItemAnimationURL: string = 'CYLTabBarAnimationURL';
export const CYLPlaceholderItemAnimationFilePath: string = 'CYLTabBarAnimationFilePath';
export const CYLPlaceholderItemAnimationSize: string = 'CYLTabBarAnimationSize';
export const CYLPlaceholderItemSelectedImage: string = 'CYLTabBarItemSelectedImage';
export const CYLPlaceholderItemDarkImage: string = 'CYLTabBarItemDarkImage';
export const CYLPlaceholderItemSelectedDarkImage: string = 'CYLTabBarItemSelectedDarkImage';
export const CYLPlaceholderItemImageURL: string = 'CYLTabBarItemImageURL';
export const CYLPlaceholderItemSelectedImageURL: string = 'CYLTabBarItemSelectedImageURL';
export const CYLPlaceholderItemImageURLSize: string = 'CYLTabBarItemImageURLSize';
export const CYLPlaceholderItemIdentifier: string = 'CYLTabBarItemIdentifier';
export const CYLPlaceholderItemPageIdentifier: string = 'CYLTabBarItemPageIdentifier';
export const CYLPlaceholderItemPageParameters: string = 'CYLTabBarItemPageParameters';
export const CYLPlaceholderItemPlatforms: string = 'CYLTabBarItemPlatforms';
export const CYLPlaceholderItemMinimumAppVersion: string = 'CYLTabBarItemMinimumAppVersion';
export const CYLPlaceholderItemSelectedTitle: string = 'CYLTabBarItemSelectedTitle';
export const CYLPlaceholderItemTitleColor: string = 'CYLTabBarItemTitleColor';
export const CYLPlaceholderItemSelectedTitleColor: string = 'CYLTabBarItemSelectedTitleColor';
export const CYLPlaceholderItemIconColor: string = 'CYLTabBarItemIconColor';
export const CYLPlaceholderItemSelectedIconColor: string = 'CYLTabBarItemSelectedIconColor';
export const CYLPlaceholderItemBackgroundColor: string = 'CYLTabBarItemBackgroundColor';
export const CYLPlaceholderItemSelectedBackgroundColor: string = 'CYLTabBarItemSelectedBackgroundColor';
export const CYLPlaceholderItemTitleFont: string = 'CYLTabBarItemTitleFont';
export const CYLPlaceholderItemSelectedTitleFont: string = 'CYLTabBarItemSelectedTitleFont';
export const CYLPlaceholderItemAccessibilityIdentifier: string = 'CYLTabBarItemAccessibilityIdentifier';
export const CYLPlaceholderItemAccessibilityLabel: string = 'CYLTabBarItemAccessibilityLabel';
export const CYLPlaceholderItemAccessibilityHint: string = 'CYLTabBarItemAccessibilityHint';
export const CYLPlaceholderItemAnimationDarkURL: string = 'CYLTabBarAnimationDarkURL';
export const CYLPlaceholderItemAnimationDarkFilePath: string = 'CYLTabBarAnimationDarkFilePath';
export const CYLPlaceholderItemAnimationColors: string = 'CYLTabBarAnimationColors';
export const CYLPlaceholderItemAnimationDarkColors: string = 'CYLTabBarAnimationDarkColors';
export const CYLPlaceholderItemAnimationOptions: string = 'CYLTabBarAnimationOptions';
export const CYLPlaceholderItemLottieURL: string = 'CYLTabBarLottieURL';
export const CYLPlaceholderItemLottieFilePath: string = 'CYLTabBarLottieFilePath';
export const CYLPlaceholderItemLottieSize: string = 'CYLTabBarLottieSize';
export const CYLPlaceholderItemLottieDarkURL: string = 'CYLTabBarLottieDarkURL';
export const CYLPlaceholderItemLottieDarkFilePath: string = 'CYLTabBarLottieDarkFilePath';
export const CYLPlaceholderItemLottieDarkColors: string = 'CYLTabBarLottieDarkColors';
export const CYLPlaceholderItemLottieLoopsWhenUnselected: string = 'CYLTabBarLottieLoopsWhenUnselected';
export const CYLPlaceholderItemPAGURL: string = 'CYLTabBarPAGURL';
export const CYLPlaceholderItemPAGFilePath: string = 'CYLTabBarPAGFilePath';
export const CYLPlaceholderItemPAGSize: string = 'CYLTabBarPAGSize';
export const CYLPlaceholderItemPAGDarkURL: string = 'CYLTabBarPAGDarkURL';
export const CYLPlaceholderItemPAGDarkFilePath: string = 'CYLTabBarPAGDarkFilePath';
export const CYLPlaceholderItemRiveURL: string = 'CYLTabBarRiveURL';
export const CYLPlaceholderItemRiveFilePath: string = 'CYLTabBarRiveFilePath';
export const CYLPlaceholderItemRiveSize: string = 'CYLTabBarRiveSize';
export const CYLPlaceholderItemRiveDarkURL: string = 'CYLTabBarRiveDarkURL';
export const CYLPlaceholderItemRiveDarkFilePath: string = 'CYLTabBarRiveDarkFilePath';
export const CYLPlaceholderItemRiveDarkColors: string = 'CYLTabBarRiveDarkColors';
export const CYLPlaceholderItemGIFURL: string = 'CYLTabBarGIFURL';
export const CYLPlaceholderItemGIFFilePath: string = 'CYLTabBarGIFFilePath';
export const CYLPlaceholderItemGIFSize: string = 'CYLTabBarGIFSize';
export const CYLPlaceholderItemGIFDarkURL: string = 'CYLTabBarGIFDarkURL';
export const CYLPlaceholderItemGIFDarkFilePath: string = 'CYLTabBarGIFDarkFilePath';
export const CYLPlaceholderItemTitleBackgroundImage: string = 'CYLPlaceholderItemTitleBackgroundImage';
export const CYLPlaceholderItemTitleBackgroundColor: string = 'CYLPlaceholderItemTitleBackgroundColor';
export const CYLPlaceholderItemTitleBorderColor: string = 'CYLPlaceholderItemTitleBorderColor';
export const CYLPlaceholderItemTitleBorderWidth: string = 'CYLPlaceholderItemTitleBorderWidth';
export const CYLPlaceholderItemTitleCornerRadius: string = 'CYLPlaceholderItemTitleCornerRadius';
export const CYLPlaceholderItemTitleContentInsets: string = 'CYLPlaceholderItemTitleContentInsets';
export const CYLPlaceholderItemTitleMinimumWidth: string = 'CYLPlaceholderItemTitleMinimumWidth';
export const CYLPlaceholderItemContentAxis: string = 'CYLPlaceholderItemContentAxis';
export const CYLPlaceholderItemInteractionEnabled: string = 'CYLPlaceholderItemInteractionEnabled';
export const CYLPlaceholderItemTapHighlightStyle: string = 'CYLPlaceholderItemTapHighlightStyle';
export const CYLPlaceholderItemAnimationRepeatCount: string = 'CYLPlaceholderItemAnimationRepeatCount';
