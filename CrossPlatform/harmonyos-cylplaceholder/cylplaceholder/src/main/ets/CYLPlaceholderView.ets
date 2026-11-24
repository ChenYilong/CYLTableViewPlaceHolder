// The HarmonyOS counterpart of iOS CYLPlaceholderView: an icon (or illustration) with a title, a badge, selected
// colors, tap handling and highlight. The state lives in the @Observed CYLPlaceholderViewModel (the iOS view's
// properties and initializers); the @Component CYLPlaceholderView draws it:
//
//   @State placeholder: CYLPlaceholderViewModel = CYLPlaceholderViewModel.initWithStyleMessage(
//     CYLPlaceholderStyle.NoInternet, CYLPlaceholderMessage.NoInternet);
//   ...
//   CYLPlaceholderView({ model: this.placeholder })
//
// The icon is CYLTabBarController's CYLAnimatedItemView (module cylanimateditem, copied by
// scripts/sync-harmonyos-cylanimateditem.sh), as iOS CYLPlaceholderView subclasses CYLAnimatedItemView and Android's
// extends com.cyl.animateditem.CYLAnimatedItemView: it shows the animation when a registered engine plays it, else the
// static image, else its placeholder. The core depends on no animation library: the player comes from the animator
// the app registered (CYLPlaceholderItemAnimatorRegistry), drawn by the core's animationBuilder, and the type must be
// registered with CYLAnimatedItemEngines (registering an animator in the shared registry does it).
import { drawing, common2D } from '@kit.ArkGraphics2D';
import { CYLAnimatedItemAnimationContext, CYLAnimatedItemController, CYLAnimatedItemView } from 'cylanimateditem';
import {
  CYLEdgeInsets,
  CYLOffset,
  CYLPlaceholderBadgeAppearance,
  CYLPlaceholderBadgeStyle,
  CYLPlaceholderIconNameForStyle,
  CYLPlaceholderImageNameForStyle,
  CYLPlaceholderItemAccessibilityHint,
  CYLPlaceholderItemAccessibilityIdentifier,
  CYLPlaceholderItemAccessibilityLabel,
  CYLPlaceholderItemAnimationFilePath,
  CYLPlaceholderItemAnimationColors,
  CYLPlaceholderItemAnimationRepeatCount,
  CYLPlaceholderItemBackgroundColor,
  CYLPlaceholderItemIconColor,
  CYLPlaceholderItemImage,
  CYLPlaceholderItemInteractionEnabled,
  CYLPlaceholderItemMessage,
  CYLPlaceholderItemSelectedBackgroundColor,
  CYLPlaceholderItemSelectedIconColor,
  CYLPlaceholderItemSelectedImage,
  CYLPlaceholderItemSelectedTitle,
  CYLPlaceholderItemSelectedTitleColor,
  CYLPlaceholderItemSelectedTitleFont,
  CYLPlaceholderItemStyle,
  CYLPlaceholderItemTapHighlightStyle,
  CYLPlaceholderItemTitle,
  CYLPlaceholderItemTitleBackgroundColor,
  CYLPlaceholderItemTitleBorderColor,
  CYLPlaceholderItemTitleBorderWidth,
  CYLPlaceholderItemTitleColor,
  CYLPlaceholderItemTitleCornerRadius,
  CYLPlaceholderItemTitleFont,
  CYLPlaceholderItemTitleMinimumWidth,
  CYLPlaceholderLocalizedTextForMessage,
  CYLPlaceholderMessage,
  CYLPlaceholderStyle,
  CYLPlaceholderStyleNamed,
  CYLPlaceholderStyleValues,
  CYLPlaceholderTapHighlightStyle
} from './CYLPlaceholderViewTypes';
import {
  CYLPlaceholderBundledAnimationFileNames,
  CYLPlaceholderImageBundle,
  CYLPlaceholderImageResource,
  CYLPlaceholderResolveImage
} from './CYLPlaceholderImages';
import { CYLPlaceholderConfiguration } from './CYLPlaceholderConfiguration';
import {
  CYLPlaceholderAnimationColors,
  CYLPlaceholderAnimationContent,
  CYLPlaceholderAnimationError,
  CYLPlaceholderAnimationFactory,
  CYLPlaceholderAnimationFactoryForURL,
  CYLPlaceholderAnimationFileExists,
  CYLPlaceholderAnimationOptionsOfURL,
  CYLPlaceholderAnimationPlayer,
  CYLPlaceholderAnimationViewModel,
  CYLPlaceholderPlayableContentView,
  CYLPlaceholderRegisterAnimationFactory
} from './CYLPlaceholderAnimation';
import {
  CYLPlaceholderAccentColor,
  CYLPlaceholderButtonStyle,
  CYLPlaceholderComponent,
  CYLPlaceholderComponentKind,
  CYLScenarioIconSide
} from './CYLPlaceholderScenario';

/** Called when a tappable placeholder is tapped (iOS `CYLPlaceholderTapHandler`). */
export type CYLPlaceholderTapHandler = (placeholderView: CYLPlaceholderViewModel) => void;

const MESSAGE_VALUES: CYLPlaceholderMessage[] = [CYLPlaceholderMessage.Empty, CYLPlaceholderMessage.NoResults,
  CYLPlaceholderMessage.NoInternet, CYLPlaceholderMessage.ServerUnavailable, CYLPlaceholderMessage.Error,
  CYLPlaceholderMessage.Loading, CYLPlaceholderMessage.NoPermission, CYLPlaceholderMessage.EmptyCart,
  CYLPlaceholderMessage.NoNotifications];

const DEFAULT_TITLE_COLOR = '#8E8E93';

/** A middle gray that reads on light and dark backgrounds (iOS `CYLScenarioLineIconColor`, white 0.6). */
export const CYLScenarioLineIconColor: string = '#999999';

// The bundled line-art animations, drawn in black: recolored to CYLScenarioLineIconColor so they stay visible in the
// dark appearance (iOS `CYLScenarioIsLineIcon`).
const CYL_LINE_ICON_NAMES: Set<string> = new Set<string>([
  'CYLPlaceholderNoInternet.json', 'CYLPlaceholderLoadFailed.json', 'CYLPlaceholderServerError.json',
  'CYLPlaceholderRefresh.json', 'CYLPlaceholderNoResults.json', 'CYLPlaceholderNoPermission.json',
  'CYLPlaceholderContactSupport.json', 'CYLPlaceholderNoMessages.json',
  'CYLPlaceholderNoNotifications.json', 'CYLPlaceholderSad.json', 'CYLPlaceholderCloudOff.json',
  'CYLPlaceholderTapHint.json', 'CYLPlaceholderSettings.json',
  'CYLPlaceholderLocationPermission.json', 'CYLPlaceholderCameraPermission.json',
  'CYLPlaceholderPhotoLibraryPermission.json', 'CYLPlaceholderMicrophonePermission.json',
  'CYLPlaceholderContactsPermission.json', 'CYLPlaceholderCalendarPermission.json',
  'CYLPlaceholderBluetoothPermission.json', 'CYLPlaceholderNotificationPermission.json',
  'CYLRefreshSpinnerRing.json', 'CYLRefreshArc.json', 'CYLRefreshClockwise.json',
  'CYLRefreshCounterClockwise.json', 'CYLRefreshPullCircle.json', 'CYLRefreshMoreDots.json',
  'CYLRefreshDoneCircle.json', 'CYLRefreshPullArrow.json', 'CYLRefreshLoadMore.json', 'CYLRefreshCycle.json',
  'CYLRefreshDone.json', 'CYLPlaceholderNoOrders.json']);

/** Whether a file name (or path) is one of the bundled black line-art animations (iOS `CYLScenarioIsLineIcon`). */
export function CYLScenarioIsLineIcon(fileName: string | null): boolean {
  if (fileName === null) {
    return false;
  }
  const slash = fileName.lastIndexOf('/');
  return CYL_LINE_ICON_NAMES.has(slash >= 0 ? fileName.substring(slash + 1) : fileName);
}

/** The state of a CYLPlaceholderView (the iOS view's properties and initializers). */
@Observed
export class CYLPlaceholderViewModel {
  /** What the view draws: an item (icon and title), a hint, a button or a separator. */
  kind: CYLPlaceholderComponentKind = CYLPlaceholderComponentKind.Item;
  /** The image (iOS `imageView.image`): a bundled icon name ("wifi_off"), a Resource or a path; null hides it. */
  image: ResourceStr | null = null;
  /** The image shown while selected (CYLPlaceholderItemSelectedImage); null keeps `image`. */
  selectedImage: ResourceStr | null = null;
  /** The title (iOS `textLabel.text`); null hides it. */
  text: string | null = null;
  /** The title shown while selected (CYLPlaceholderItemSelectedTitle); null keeps `text`. */
  selectedText: string | null = null;
  /** Whether the icon is tinted with the icon color (the bundled icons are black templates). */
  tintsIcon: boolean = true;
  /** The side of the icon in vp. */
  imageSide: number = CYLScenarioIconSide;
  buttonStyle: CYLPlaceholderButtonStyle = CYLPlaceholderButtonStyle.Filled;

  /** The badge text; null hides it, "" shows a dot, digits a number, anything else text. */
  private badgeValueStorage: string | null = null;
  badgeStyle: CYLPlaceholderBadgeStyle = CYLPlaceholderBadgeStyle.None;
  /** The text the badge shows (iOS `badgeLabel.text`). */
  badgeText: string = '';
  /** Moves the badge from the icon's top-right corner, in vp. */
  badgeCenterOffset: CYLOffset = new CYLOffset();

  selected: boolean = false;
  selectionIndicatorImage: ResourceStr | null = null;
  selectionIndicatorTintColor: ResourceColor | null = null;

  defaultTitleColor: ResourceColor = DEFAULT_TITLE_COLOR;
  defaultIconColor: ResourceColor = CYLPlaceholderAccentColor;
  defaultBackgroundColor: ResourceColor = Color.Transparent;
  /** The title's font size in fp (UIFont). */
  defaultTitleFont: number = 17;
  defaultTitlePositionAdjustment: CYLOffset = new CYLOffset();
  defaultSelectedTitleColor: ResourceColor | null = null;
  defaultSelectedIconColor: ResourceColor | null = null;
  defaultSelectedBackgroundColor: ResourceColor | null = null;
  defaultSelectedTitleFont: number = 0;
  defaultSelectionIndicatorImage: ResourceStr | null = null;
  defaultSelectionIndicatorTintColor: ResourceColor | null = null;

  /** Title decorations (CYLPlaceholderItemTitle* keys), used by buttons and raw items. */
  titleBackgroundColor: ResourceColor | null = null;
  titleBorderColor: ResourceColor | null = null;
  titleBorderWidth: number = 0;
  titleCornerRadius: number = 0;
  titleContentInsets: CYLEdgeInsets = new CYLEdgeInsets();
  titleMinimumWidth: number = 0;

  /** The item attributes the view was made from. */
  itemAttributes: Record<string, Object> = {};
  /** false (the default): the view fills its parent and centers its content; true: it is sized by its content. */
  reportsContentSize: boolean = false;
  /** The widest the content may be when reportsContentSize is true, padding included; 0 for no limit. */
  preferredMaxLayoutWidth: number = 0;
  /** The space between the view's edges and its content, in vp. */
  contentMargin: number = 16;

  tapHandler: CYLPlaceholderTapHandler | null = null;
  tapInteractionEnabled: boolean = true;
  tapHighlightStyle: CYLPlaceholderTapHighlightStyle = CYLPlaceholderTapHighlightStyle.Dim;
  /** Whether the view is pressed (read only for apps). */
  tapHighlighted: boolean = false;

  /**
   * How many times the animation plays each time it starts: 0 loops until stopped, N plays N times (iOS
   * `animationRepeatCount`). Defaults to 1, or to CYLPlaceholderItemAnimationRepeatCount. A change applies live to
   * the player that exists, so a playing animation starts or stops looping without a restart (examples' Loop switch).
   */
  get animationRepeatCount(): number {
    return this.animationRepeatCountValue;
  }

  set animationRepeatCount(value: number) {
    this.animationRepeatCountValue = Math.max(0, Math.floor(value));
    if (this.animationPlayer !== null) {
      this.animationPlayer.setAnimationRepeatCount(this.animationRepeatCountValue);
    }
  }

  private animationRepeatCountValue: number = 1;
  /**
   * The animation played in place of the image: a bundled name ("CYLPlaceholderEmpty.json"), a rawfile path or a
   * sandbox path. A factory registered for its extension plays it, else the animator registry; the image stays as
   * the fallback until the animation is ready, and for good when it cannot load.
   */
  animationFileName: string | null = null;
  /**
   * Color overrides of the animation (CYLPlaceholderItemAnimationColors, lottie-ios keypaths such as "**.Color"); null
   * keeps the file's own colors. Scenario components recolor the bundled line-art animations to
   * CYLScenarioLineIconColor (initWithComponent), as on iOS.
   */
  animationColors: CYLPlaceholderAnimationColors | null = null;
  /** The player of animationFileName once the view appeared, or null. */
  animationPlayer: CYLPlaceholderAnimationPlayer | null = null;
  /** true once the player has loaded: the animation replaces the image. */
  animationReady: boolean = false;
  /** true when animationFileName cannot be played: the image stays. */
  animationFailed: boolean = false;
  /**
   * Whether the image replaces a play-once animation when it ends (CYLAnimatedItemView `showsImageWhenAnimationEnds`,
   * CYLTabBarController b13b88f1): for an animation whose last frame is empty, such as the Success scenario's.
   */
  showsImageWhenAnimationEnds: boolean = false;
  /** true while the image shows in place of the ended animation (the icon is tinted again); false once it replays. */
  animationEndedShowsImage: boolean = false;
  /** Set by the item content: tells CYLAnimatedItemView that the animation ended (its context's `onEnded`). */
  cyl_animationEndHandler: (() => void) | null = null;
  /** Set by CYLPlaceholderView: replays through CYLAnimatedItemView, so it shows the animation again. */
  cyl_animationReplayHandler: (() => void) | null = null;
  private animationAttachedFileName: string | null = null;
  /** The key that finds this model from CYLAnimatedItemView's animation context (set while a view shows it). */
  cyl_animatedItemKey: string = '';
  /** What the view does with the animation once it is ready: 1 play, 2 last frame, 3 seek, 0 rest. */
  private animationCommand: number = 0;
  private animationRequestedProgress: number = 0;
  private animationRequestedSpeed: number = 0;
  private animationStopped: boolean = false;

  accessibilityIdentifier: string = '';
  accessibilityLabel: string | null = null;
  accessibilityHint: string | null = null;

  /** The badge text (iOS `badgeValue`); setting it shows the matching badge style. */
  get badgeValue(): string | null {
    return this.badgeValueStorage;
  }

  set badgeValue(value: string | null) {
    this.badgeValueStorage = value;
    let style = CYLPlaceholderBadgeStyle.Text;
    if (value === null) {
      style = CYLPlaceholderBadgeStyle.None;
    } else if (value.length === 0) {
      style = CYLPlaceholderBadgeStyle.Dot;
    } else if (new RegExp('^[0-9]+$').test(value)) {
      style = CYLPlaceholderBadgeStyle.Number;
    }
    this.showBadgeWithStyle(style, value);
  }

  /** Shows a badge of a style; None hides it. Returns false for a Number style with a non-numeric value. */
  showBadgeWithStyle(style: CYLPlaceholderBadgeStyle, value: string | null): boolean {
    if (style === CYLPlaceholderBadgeStyle.Number && (value === null || !new RegExp('^[0-9]+$').test(value))) {
      return false;
    }
    this.badgeStyle = style;
    this.badgeText = style === CYLPlaceholderBadgeStyle.Dot || style === CYLPlaceholderBadgeStyle.None || value === null ?
      '' : value;
    return true;
  }

  /** Whether a tap runs the handler: a handler is set and taps are enabled. */
  get tapInteractive(): boolean {
    return this.tapHandler !== null && this.tapInteractionEnabled;
  }

  /** Runs the tap handler as a tap would; false when the view is not tap-interactive. */
  performTap(): boolean {
    const handler = this.tapHandler;
    if (handler === null || !this.tapInteractionEnabled) {
      return false;
    }
    handler(this);
    return true;
  }

  /** The image to draw now (selected image when selected), resolved to a Resource for bundled icon names. */
  get currentImage(): ResourceStr | null {
    const image = this.selected && this.selectedImage !== null ? this.selectedImage : this.image;
    if (typeof image === 'string') {
      const bundled = CYLPlaceholderImageResource(image as string);
      return bundled !== null ? bundled : image;
    }
    return image;
  }

  get currentText(): string | null {
    return this.selected && this.selectedText !== null ? this.selectedText : this.text;
  }

  get currentTitleColor(): ResourceColor {
    return this.selected && this.defaultSelectedTitleColor !== null ? this.defaultSelectedTitleColor :
      this.defaultTitleColor;
  }

  get currentIconColor(): ResourceColor {
    return this.selected && this.defaultSelectedIconColor !== null ? this.defaultSelectedIconColor :
      this.defaultIconColor;
  }

  get currentBackgroundColor(): ResourceColor {
    return this.selected && this.defaultSelectedBackgroundColor !== null ? this.defaultSelectedBackgroundColor :
      this.defaultBackgroundColor;
  }

  get currentTitleFont(): number {
    return this.selected && this.defaultSelectedTitleFont > 0 ? this.defaultSelectedTitleFont : this.defaultTitleFont;
  }

  get currentSelectionIndicatorImage(): ResourceStr | null {
    if (!this.selected) {
      return null;
    }
    return this.selectionIndicatorImage !== null ? this.selectionIndicatorImage : this.defaultSelectionIndicatorImage;
  }

  get currentSelectionIndicatorTintColor(): ResourceColor | null {
    return this.selectionIndicatorTintColor !== null ? this.selectionIndicatorTintColor :
      this.defaultSelectionIndicatorTintColor;
  }

  // Animation playback (iOS -playPlaceholderAnimation and friends).

  /** Whether the animation is drawn (loading or ready); false shows only the image. */
  get animationVisible(): boolean {
    return this.animationPlayer !== null && !this.animationFailed;
  }

  /**
   * The animation file CYLAnimatedItemView is given: the rawfile path of a bundled animation, else animationFileName,
   * with this model's key in the fragment so the core's animation builder finds the player; '' without an animation.
   * CYLAnimatedItemView reads the type from the extension (the fragment is ignored).
   */
  get cyl_animatedItemURL(): string {
    const name = this.animationFileName;
    if (name === null || name.length === 0) {
      return '';
    }
    const bundled = CYLPlaceholderViewModel.pathForBundledAnimation(name);
    const path = bundled !== null ? bundled : name;
    if (this.cyl_animatedItemKey.length === 0) {
      return path;
    }
    return path + (path.indexOf('#') >= 0 ? '&' : '#') + CYL_ANIMATED_ITEM_KEY + '=' + this.cyl_animatedItemKey;
  }

  /**
   * Whether the view shows an icon: an image, or an animation file (CYLAnimatedItemView then shows the animation, the
   * image or its placeholder, in that order).
   */
  get cyl_showsIcon(): boolean {
    return this.currentImage !== null || (this.animationFileName !== null && this.animationFileName.length > 0);
  }

  /**
   * Makes the player of animationFileName (called when the view appears): the factory registered for the extension
   * first, then CYLPlaceholderAnimationViewModel through the animator registry. The image stays when neither plays it.
   */
  cyl_attachAnimation(): void {
    const name = this.animationFileName;
    if (name === null || name.length === 0) {
      this.cyl_releaseAnimation();
      return;
    }
    if (this.animationPlayer !== null && this.animationAttachedFileName === name) {
      return;
    }
    this.cyl_releaseAnimation();
    this.animationAttachedFileName = name;
    const bundled = CYLPlaceholderViewModel.pathForBundledAnimation(name);
    const path = bundled !== null ? bundled : name;
    const side = Math.max(1, this.imageSide);
    const factory = CYLPlaceholderAnimationFactoryForURL(path);
    let player: CYLPlaceholderAnimationPlayer | null = null;
    if (factory !== null) {
      player = factory(path, side, side, ImageFit.Contain, {});
    }
    if (player === null) {
      player = CYLPlaceholderAnimationViewModel.initWithFileURL(path, side, side, ImageFit.Contain, null);
    }
    if (player === null) {
      this.animationFailed = true;
      return;
    }
    const made: CYLPlaceholderAnimationPlayer = player;
    made.setAnimationRepeatCount(this.animationRepeatCount);
    if (this.animationColors !== null) {
      made.setAnimationColors(this.animationColors);
    }
    if (this.animationRequestedSpeed > 0) {
      made.setAnimationSpeed(this.animationRequestedSpeed);
    }
    made.errorHandler = (error: CYLPlaceholderAnimationError) => {
      if (this.animationPlayer === made) {
        this.animationFailed = true;
        this.animationReady = false;
      }
    };
    made.readyHandler = () => {
      if (this.animationPlayer === made) {
        this.animationReady = true;
        this.cyl_runAnimationCommand();
      }
    };
    if (made.view instanceof CYLPlaceholderPlayableContentView) {
      (made.view as CYLPlaceholderPlayableContentView).cyl_animationViewEndHandler = () => {
        if (this.animationPlayer !== made || this.animationRepeatCount === 0) {
          return;
        }
        if (this.showsImageWhenAnimationEnds) {
          this.animationEndedShowsImage = true;
        }
        const handler = this.cyl_animationEndHandler;
        if (handler !== null) {
          handler();
        }
      };
    }
    this.animationFailed = false;
    this.animationPlayer = made;
    if (made.ready) {
      this.animationReady = true;
    }
    this.cyl_runAnimationCommand();
  }

  /**
   * Shows the animation file at `path` (a sandbox path, or the name of a bundled animation) instead of the icon (iOS
   * `-setAnimationFile:`). false, with the icon kept, when the path is empty, the file is missing or no animator plays
   * it; true once a player exists. The same as Android's `CYLPlaceholderView.setAnimationFile(path)`.
   */
  setAnimationFile(path: string): boolean {
    if (path.length === 0) {
      return false;
    }
    const bundled = CYLPlaceholderViewModel.pathForBundledAnimation(path);
    if (!CYLPlaceholderAnimationFileExists(bundled !== null ? bundled : path)) {
      return false;
    }
    const previous = this.animationFileName;
    this.animationFileName = path;
    this.cyl_releaseAnimation();
    this.cyl_attachAnimation();
    if (this.animationPlayer === null) {
      // No animator plays it: keep the icon.
      this.animationFileName = previous;
      this.cyl_releaseAnimation();
      this.cyl_attachAnimation();
      return false;
    }
    return true;
  }

  /** Stops and drops the player (called when the view disappears; it is made again when it reappears). */
  cyl_releaseAnimation(): void {
    const player = this.animationPlayer;
    if (player !== null) {
      player.errorHandler = null;
      player.readyHandler = null;
      player.stop();
    }
    this.animationPlayer = null;
    this.animationReady = false;
    this.animationFailed = false;
    this.animationAttachedFileName = null;
  }

  private cyl_runAnimationCommand(): void {
    const player = this.animationPlayer;
    if (player === null) {
      return;
    }
    if (this.animationCommand === 1) {
      player.play();
    } else if (this.animationCommand === 2) {
      player.showLastFrame();
    } else if (this.animationCommand === 3) {
      player.setAnimationProgress(this.animationRequestedProgress);
    }
  }

  /** Plays when the view appears unless the app asked for a frame or a stop (iOS plays visible placeholders). */
  playPlaceholderAnimationIfIdle(): void {
    if (this.animationCommand === 0 && !this.animationStopped) {
      this.playPlaceholderAnimation();
    }
  }

  /** Replays the animation (iOS `-playPlaceholderAnimation`); a view still loading plays once ready. */
  playPlaceholderAnimation(): void {
    if (this.animationEndedShowsImage) {
      // The image replaced the ended animation: replay through CYLAnimatedItemView, which shows the animation again
      // and calls back here (then animationEndedShowsImage is false).
      this.animationEndedShowsImage = false;
      const replay = this.cyl_animationReplayHandler;
      if (replay !== null) {
        replay();
        return;
      }
    }
    this.animationCommand = 1;
    this.animationStopped = false;
    if (this.animationPlayer !== null) {
      this.animationPlayer.play();
    }
  }

  /** Stops and shows the resting frame until replayed (iOS `-stopPlaceholderAnimation`). */
  stopPlaceholderAnimation(): void {
    this.animationCommand = 0;
    this.animationStopped = true;
    if (this.animationPlayer !== null) {
      this.animationPlayer.stop();
    }
  }

  /** Stops and shows the last frame when supported (iOS `-showPlaceholderAnimationLastFrame`). */
  showPlaceholderAnimationLastFrame(): void {
    this.animationCommand = 2;
    if (this.animationPlayer !== null) {
      this.animationPlayer.showLastFrame();
    }
  }

  /**
   * Stops and seeks (iOS `-setPlaceholderAnimationProgress:`); false for values outside 0...1 or a player that cannot
   * seek. Before the player exists the progress is kept and applied when it is made.
   */
  setPlaceholderAnimationProgress(progress: number): boolean {
    if (!isFinite(progress) || progress < 0 || progress > 1) {
      return false;
    }
    this.animationCommand = 3;
    this.animationRequestedProgress = progress;
    return this.animationPlayer !== null ? this.animationPlayer.setAnimationProgress(progress) : true;
  }

  /** A positive finite speed (iOS `-setPlaceholderAnimationSpeed:`); false otherwise or when unsupported. */
  setPlaceholderAnimationSpeed(speed: number): boolean {
    if (!isFinite(speed) || speed <= 0) {
      return false;
    }
    this.animationRequestedSpeed = speed;
    return this.animationPlayer !== null ? this.animationPlayer.setAnimationSpeed(speed) : true;
  }

  // Initializers (iOS -initWith...).

  /** A bundled icon and a ready-made text (`-initWithStyle:message:`). */
  static initWithStyleMessage(style: CYLPlaceholderStyle, message: CYLPlaceholderMessage): CYLPlaceholderViewModel {
    return CYLPlaceholderViewModel.initWithStyleText(style, CYLPlaceholderLocalizedTextForMessage(message));
  }

  /** A bundled icon and a text (`-initWithStyle:text:`); the Empty illustration keeps its colors. */
  static initWithStyleText(style: CYLPlaceholderStyle, text: string | null): CYLPlaceholderViewModel {
    const m = CYLPlaceholderViewModel.initWithImageText(CYLPlaceholderIconNameForStyle(style), text);
    m.tintsIcon = style !== CYLPlaceholderStyle.Empty;
    return m;
  }

  /** An image (a bundled icon name, a Resource or a path) and a text (`-initWithImage:text:`). */
  static initWithImageText(image: ResourceStr | null, text: string | null): CYLPlaceholderViewModel {
    const m = new CYLPlaceholderViewModel();
    m.image = image;
    m.text = text;
    const attributes: Record<string, Object> = {};
    if (text !== null) {
      attributes[CYLPlaceholderItemTitle] = text;
    }
    if (image !== null) {
      attributes[CYLPlaceholderItemImage] = image;
    }
    m.itemAttributes = attributes;
    return m;
  }

  /**
   * A view from item attributes (`-initWithItemAttributes:imageBundle:error:`): the title, image, style, message,
   * colors, fonts, selected variants, title decorations, accessibility, interaction, tap highlight, repeat count and
   * animation file keys. null, with the reason passed to onError, when there is neither an image nor a title.
   * Image names are looked up in imageBundle (CYLPlaceholderImageBundle: another module's or HAR's media); null uses
   * the bundled icons, else the name is a path. A name the bundle does not have fails, as on iOS.
   */
  static initWithItemAttributes(attributes: Record<string, Object>, imageBundle: CYLPlaceholderImageBundle | null = null,
    onError: ((message: string) => void) | null = null): CYLPlaceholderViewModel | null {
    const imageValue: ResourceStr | null = readImage(attributes[CYLPlaceholderItemImage]);
    let image: ResourceStr | null = imageBundle !== null ? CYLPlaceholderResolveImage(imageValue, imageBundle) : imageValue;
    if (imageValue !== null && image === null) {
      if (onError !== null) {
        onError('Image \'' + (imageValue as string) + '\' was not found in the selected bundle.');
      }
      return null;
    }
    let tints = true;
    const style = readStyle(attributes[CYLPlaceholderItemStyle]);
    if (image === null && style !== null) {
      image = CYLPlaceholderIconNameForStyle(style);
      tints = style !== CYLPlaceholderStyle.Empty;
    }
    let text = readString(attributes[CYLPlaceholderItemTitle]);
    const message = readNumber(attributes[CYLPlaceholderItemMessage]);
    if (text === null && message !== null) {
      const index = Math.floor(message);
      text = index >= 0 && index < MESSAGE_VALUES.length ? CYLPlaceholderLocalizedTextForMessage(MESSAGE_VALUES[index]) : null;
    }
    if (image === null && text === null) {
      if (onError !== null) {
        onError('The item attributes need an image, a style, a title or a message.');
      }
      return null;
    }
    const m = CYLPlaceholderViewModel.initWithImageText(image, text);
    m.tintsIcon = tints;
    m.itemAttributes = attributes;
    const selectedValue: ResourceStr | null = readImage(attributes[CYLPlaceholderItemSelectedImage]);
    m.selectedImage = imageBundle !== null ? CYLPlaceholderResolveImage(selectedValue, imageBundle) : selectedValue;
    m.selectedText = readString(attributes[CYLPlaceholderItemSelectedTitle]);
    const titleColor = readColor(attributes[CYLPlaceholderItemTitleColor]);
    if (titleColor !== null) {
      m.defaultTitleColor = titleColor;
    }
    const iconColor = readColor(attributes[CYLPlaceholderItemIconColor]);
    if (iconColor !== null) {
      m.defaultIconColor = iconColor;
    }
    const background = readColor(attributes[CYLPlaceholderItemBackgroundColor]);
    if (background !== null) {
      m.defaultBackgroundColor = background;
    }
    const font = readNumber(attributes[CYLPlaceholderItemTitleFont]);
    if (font !== null) {
      m.defaultTitleFont = font;
    }
    m.defaultSelectedTitleColor = readColor(attributes[CYLPlaceholderItemSelectedTitleColor]);
    m.defaultSelectedIconColor = readColor(attributes[CYLPlaceholderItemSelectedIconColor]);
    m.defaultSelectedBackgroundColor = readColor(attributes[CYLPlaceholderItemSelectedBackgroundColor]);
    const selectedFont = readNumber(attributes[CYLPlaceholderItemSelectedTitleFont]);
    if (selectedFont !== null) {
      m.defaultSelectedTitleFont = selectedFont;
    }
    m.titleBackgroundColor = readColor(attributes[CYLPlaceholderItemTitleBackgroundColor]);
    m.titleBorderColor = readColor(attributes[CYLPlaceholderItemTitleBorderColor]);
    const borderWidth = readNumber(attributes[CYLPlaceholderItemTitleBorderWidth]);
    m.titleBorderWidth = borderWidth !== null ? borderWidth : 0;
    const radius = readNumber(attributes[CYLPlaceholderItemTitleCornerRadius]);
    m.titleCornerRadius = radius !== null ? radius : 0;
    const minWidth = readNumber(attributes[CYLPlaceholderItemTitleMinimumWidth]);
    m.titleMinimumWidth = minWidth !== null ? minWidth : 0;
    const identifier = readString(attributes[CYLPlaceholderItemAccessibilityIdentifier]);
    m.accessibilityIdentifier = identifier !== null ? identifier : '';
    m.accessibilityLabel = readString(attributes[CYLPlaceholderItemAccessibilityLabel]);
    m.accessibilityHint = readString(attributes[CYLPlaceholderItemAccessibilityHint]);
    const interaction: Object | undefined = attributes[CYLPlaceholderItemInteractionEnabled];
    if (typeof interaction === 'boolean') {
      m.tapInteractionEnabled = interaction as boolean;
    }
    const highlight = readNumber(attributes[CYLPlaceholderItemTapHighlightStyle]);
    if (highlight !== null) {
      m.tapHighlightStyle = highlight === 1 ? CYLPlaceholderTapHighlightStyle.Shrink :
        highlight === 2 ? CYLPlaceholderTapHighlightStyle.None : CYLPlaceholderTapHighlightStyle.Dim;
    }
    const repeat = readNumber(attributes[CYLPlaceholderItemAnimationRepeatCount]);
    if (repeat !== null) {
      m.animationRepeatCount = Math.max(0, Math.floor(repeat));
    }
    m.animationFileName = readString(attributes[CYLPlaceholderItemAnimationFilePath]);
    const colors: Object | undefined = attributes[CYLPlaceholderItemAnimationColors];
    if (colors !== undefined && colors !== null && typeof colors === 'object') {
      m.animationColors = colors as CYLPlaceholderAnimationColors;
    }
    return m;
  }

  /**
   * Reads the item attributes from a local ".json" or ".plist" file, a sandbox path or "file://" URI
   * (`-initWithItemContentsOfURL:imageBundle:error:`); null, with the reason, when it cannot be read or is invalid.
   */
  static initWithItemContentsOfURL(path: string, imageBundle: CYLPlaceholderImageBundle | null = null,
    onError: ((message: string) => void) | null = null): CYLPlaceholderViewModel | null {
    const attributes = CYLPlaceholderConfiguration.readFile(path, onError);
    return attributes === null ? null : CYLPlaceholderViewModel.initWithItemAttributes(attributes, imageBundle, onError);
  }

  /** The view of a stack component (what CYLPlaceholderStackView makes for each component). */
  static initWithComponent(component: CYLPlaceholderComponent): CYLPlaceholderViewModel {
    const image: ResourceStr | null = component.imageBundle !== null ?
      CYLPlaceholderResolveImage(component.image, component.imageBundle) : component.image;
    const m = CYLPlaceholderViewModel.initWithImageText(image, component.title);
    m.kind = component.kind;
    m.itemAttributes = component.attributes;
    m.tintsIcon = component.tinted;
    m.imageSide = component.imageSide > 0 ? component.imageSide : CYLScenarioIconSide;
    if (component.titleFont > 0) {
      m.defaultTitleFont = component.titleFont;
    }
    if (component.titleColor !== null) {
      m.defaultTitleColor = component.titleColor;
    } else if (component.kind === CYLPlaceholderComponentKind.Item && component.image === null) {
      m.defaultTitleColor = '#3C3C43';
    }
    if (component.buttonStyle !== null) {
      m.buttonStyle = component.buttonStyle;
    }
    m.tapInteractionEnabled = component.interactionEnabled;
    m.tapHighlightStyle = component.tapHighlightStyle;
    m.animationRepeatCount = component.animationRepeatCount;
    m.showsImageWhenAnimationEnds = component.showsImageWhenAnimationEnds;
    m.animationFileName = component.animationFileName;
    if (CYLScenarioIsLineIcon(component.animationFileName)) {
      // The black line art stays visible on dark backgrounds (iOS CYLPlaceholderScenario "**.Color").
      const gray: CYLPlaceholderAnimationColors = { '**.Color': CYLScenarioLineIconColor };
      m.animationColors = gray;
    }
    m.accessibilityIdentifier = component.accessibilityIdentifier !== null ? component.accessibilityIdentifier : '';
    m.reportsContentSize = true;
    m.contentMargin = 0;
    return m;
  }

  // Class methods (iOS +...).

  /** The bundled icon of a style, or null (`+imageForStyle:`). */
  static imageForStyle(style: CYLPlaceholderStyle): Resource | null {
    const name = CYLPlaceholderIconNameForStyle(style);
    return name !== null ? CYLPlaceholderImageResource(name) : null;
  }

  /** The iOS image name of a style ("CYLPlaceholderWifiOff") (`+imageNameForStyle:`). */
  static imageNameForStyle(style: CYLPlaceholderStyle): string | null {
    return CYLPlaceholderImageNameForStyle(style);
  }

  /** The localized text of a message (`+localizedTextForMessage:`). */
  static localizedTextForMessage(message: CYLPlaceholderMessage): string | null {
    return CYLPlaceholderLocalizedTextForMessage(message);
  }

  /**
   * Registers or, with null, removes a factory for a local file extension, without a leading dot, case-insensitive
   * (iOS `+registerAnimationFactory:forFileExtension:`). "gif" stays with the built-in decoder (false). Views keep
   * their player until they appear again.
   */
  static registerAnimationFactory(factory: CYLPlaceholderAnimationFactory | null, fileExtension: string): boolean {
    return CYLPlaceholderRegisterAnimationFactory(factory, fileExtension);
  }

  /** The animation files bundled in the HAR (`+bundledAnimationFileNames`). */
  static bundledAnimationFileNames(): string[] {
    return CYLPlaceholderBundledAnimationFileNames.slice();
  }

  /**
   * The rawfile path of a bundled animation ("cylplaceholder/animations/CYLPlaceholderEmpty.json"), for
   * resourceManager.getRawFileContent; null when it is not bundled (`+pathForBundledAnimation:`).
   */
  static pathForBundledAnimation(fileName: string): string | null {
    return CYLPlaceholderBundledAnimationFileNames.includes(fileName) ? 'cylplaceholder/animations/' + fileName : null;
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

function readImage(value: Object | undefined): ResourceStr | null {
  if (typeof value === 'string') {
    return value as string;
  }
  return value !== undefined && value !== null && typeof value === 'object' ? value as Resource : null;
}

function readColor(value: Object | undefined): ResourceColor | null {
  if (typeof value === 'string') {
    return value as string;
  }
  if (typeof value === 'number') {
    return value as number;
  }
  return value !== undefined && value !== null && typeof value === 'object' ? value as Resource : null;
}

function readStyle(value: Object | undefined): CYLPlaceholderStyle | null {
  if (typeof value === 'number') {
    const n = Math.floor(value as number);
    return n >= 0 && n < CYLPlaceholderStyle.Count ? CYLPlaceholderStyleValues[n] : null;
  }
  return typeof value === 'string' ? CYLPlaceholderStyleNamed(value as string) : null;
}

// The models shown by a CYLPlaceholderView, by key: CYLAnimatedItemView calls the core's global animation builder with
// a context only (no model), so the context's URL carries the key (cyl_animatedItemURL) and the builder looks it up.
const CYL_ANIMATED_ITEM_KEY: string = 'cylPlaceholderView';
const CYL_ANIMATED_ITEM_MODELS: Map<string, CYLPlaceholderViewModel> = new Map<string, CYLPlaceholderViewModel>();
const CYL_ANIMATED_ITEM_COUNTS: Map<string, number> = new Map<string, number>();
let cylNextAnimatedItemKey: number = 0;

function cylRetainAnimatedItemModel(model: CYLPlaceholderViewModel): void {
  if (model.cyl_animatedItemKey.length === 0) {
    cylNextAnimatedItemKey += 1;
    model.cyl_animatedItemKey = cylNextAnimatedItemKey.toString();
  }
  const key = model.cyl_animatedItemKey;
  CYL_ANIMATED_ITEM_MODELS.set(key, model);
  const count: number | undefined = CYL_ANIMATED_ITEM_COUNTS.get(key);
  CYL_ANIMATED_ITEM_COUNTS.set(key, count !== undefined ? count + 1 : 1);
}

function cylReleaseAnimatedItemModel(model: CYLPlaceholderViewModel): void {
  const key = model.cyl_animatedItemKey;
  const count: number | undefined = CYL_ANIMATED_ITEM_COUNTS.get(key);
  if (count === undefined || count <= 1) {
    CYL_ANIMATED_ITEM_COUNTS.delete(key);
    CYL_ANIMATED_ITEM_MODELS.delete(key);
  } else {
    CYL_ANIMATED_ITEM_COUNTS.set(key, count - 1);
  }
}

/** The model whose key the animation context's URL carries, or null. */
function cylAnimatedItemModelForURL(URL: string): CYLPlaceholderViewModel | null {
  const options = CYLPlaceholderAnimationOptionsOfURL(URL);
  const key: string | undefined = options[CYL_ANIMATED_ITEM_KEY];
  if (key === undefined) {
    return null;
  }
  const model: CYLPlaceholderViewModel | undefined = CYL_ANIMATED_ITEM_MODELS.get(key);
  return model !== undefined ? model : null;
}

/**
 * Draws a model's player inside CYLAnimatedItemView and tells it when the player is ready (`onLoaded`: the animation
 * replaces the image) or failed (`onFailed`: the image, or the placeholder, shows again).
 */
@Component
struct CYLPlaceholderAnimatedItemContent {
  @ObjectLink @Watch('cylReportAnimationState') model: CYLPlaceholderViewModel;
  animationContext: CYLAnimatedItemAnimationContext = new CYLAnimatedItemAnimationContext();
  /**
   * The item's playback (CYLTabBarController B22: animationSpeed, animationLoops, animationRestartToken and
   * CYLAnimatedItemController.restartAnimation(), handed in through the context). Applied to the model when they change
   * only, so a CYLPlaceholderView, whose item sets none of them, keeps its own speed and repeat count.
   */
  @Prop @Watch('cylApplySpeed') speed: number = 1;
  @Prop @Watch('cylApplyLoops') loops: boolean = false;
  @Prop @Watch('cylRestart') restartToken: number = 0;
  /** What was reported to the context: 0 nothing, 1 loaded, 2 failed. */
  private reported: number = 0;

  aboutToAppear(): void {
    this.model.cyl_animationEndHandler = () => {
      this.animationContext.onEnded();
    };
    this.cylReportAnimationState();
  }

  cylApplySpeed(): void {
    this.model.setPlaceholderAnimationSpeed(this.speed);
  }

  cylApplyLoops(): void {
    this.model.animationRepeatCount = this.loops ? 0 : 1;
  }

  cylRestart(): void {
    this.model.playPlaceholderAnimation();
  }

  cylReportAnimationState(): void {
    if (this.model.animationFailed || this.model.animationPlayer === null) {
      if (this.reported !== 2) {
        this.reported = 2;
        this.animationContext.onFailed();
      }
    } else if (this.model.animationReady && this.reported !== 1) {
      this.reported = 1;
      this.animationContext.onLoaded();
    }
  }

  build() {
    Stack() {
      if (this.model.animationPlayer !== null && !this.model.animationFailed) {
        CYLPlaceholderAnimationContent({ view: (this.model.animationPlayer as CYLPlaceholderAnimationPlayer).view })
      }
    }
    .width(this.animationContext.size)
    .height(this.animationContext.size)
  }
}

/**
 * The core's animationBuilder for CYLAnimatedItemView: the player of the model whose key the context's URL carries
 * (made by the animator the app registered); CYLAnimatedItemView calls it only for a registered type.
 */
@Builder
export function cylPlaceholderAnimatedItemBuilder(context: CYLAnimatedItemAnimationContext) {
  if (cylAnimatedItemModelForURL(context.url) !== null) {
    CYLPlaceholderAnimatedItemContent({
      model: cylAnimatedItemModelForURL(context.url) as CYLPlaceholderViewModel,
      animationContext: context,
      speed: context.speed,
      loops: context.loops,
      restartToken: context.restartToken
    })
  } else {
    CYLPlaceholderOwnAnimatedItemContent({
      animationContext: context,
      speed: context.speed,
      loops: context.loops,
      restartToken: context.restartToken
    })
  }
}

/**
 * A URL with no placeholder model behind it (an app's own CYLAnimatedItemView with `animationBuilder:
 * CYLPlaceholderAnimatedItemBuilder`): a model of its own plays the file through the animators the app registered,
 * sized to the item's icon, with the item's speed, loop and restarts.
 */
@Component
struct CYLPlaceholderOwnAnimatedItemContent {
  animationContext: CYLAnimatedItemAnimationContext = new CYLAnimatedItemAnimationContext();
  @Prop speed: number = 1;
  @Prop loops: boolean = false;
  @Prop restartToken: number = 0;
  @State model: CYLPlaceholderViewModel = new CYLPlaceholderViewModel();

  aboutToAppear(): void {
    const m = new CYLPlaceholderViewModel();
    m.animationFileName = this.animationContext.url;
    m.imageSide = Math.max(1, this.animationContext.size);
    m.animationRepeatCount = this.loops ? 0 : 1;
    if (this.speed !== 1) {
      m.setPlaceholderAnimationSpeed(this.speed);
    }
    this.model = m;
    CYLPlaceholderAnimatedItem.attach(m);
  }

  aboutToDisappear(): void {
    CYLPlaceholderAnimatedItem.detach(this.model);
  }

  build() {
    CYLPlaceholderAnimatedItemContent({
      model: this.model,
      animationContext: this.animationContext,
      speed: this.speed,
      loops: this.loops,
      restartToken: this.restartToken
    })
  }
}

/**
 * A placeholder model's animation in an app's own CYLAnimatedItemView, when the page drives playback through the model.
 * Without a model, the item alone does it: give it the file as `animationUrl`, `animationBuilder:
 * CYLPlaceholderAnimatedItemBuilder` and its own animationSpeed / animationLoops / controller (CYLTabBarController
 * B22). Either way it is for an icon with a title and nothing else, where
 * a CYLPlaceholderStackView (several components, buttons, hints, a long wrapping text) is more than the page needs.
 * Call attach(model) when the item appears and detach(model) when it goes; give the item animationURL(model) and
 * `animationBuilder: CYLPlaceholderAnimatedItemBuilder`. Playback stays on the model (playPlaceholderAnimation,
 * stopPlaceholderAnimation, setPlaceholderAnimationSpeed, animationRepeatCount), as with a CYLPlaceholderView.
 */
export class CYLPlaceholderAnimatedItem {
  /** Registers the model with the builder and makes its player (it plays unless the app asked for a frame or a stop). */
  static attach(model: CYLPlaceholderViewModel): void {
    cylRetainAnimatedItemModel(model);
    if (model.animationFileName !== null) {
      model.cyl_attachAnimation();
      model.playPlaceholderAnimationIfIdle();
    }
  }

  /** Stops and drops the player and the registration. */
  static detach(model: CYLPlaceholderViewModel): void {
    model.cyl_releaseAnimation();
    cylReleaseAnimatedItemModel(model);
  }

  /** The item's animationUrl (the file with the model's key; call after attach); '' without an animation. */
  static animationURL(model: CYLPlaceholderViewModel): string {
    return model.cyl_animatedItemURL;
  }
}

/** "#RGB", "#RRGGBB", "#AARRGGBB" or 0xAARRGGBB / 0xRRGGBB as a drawing color; null for Resources and names. */
export function CYLPlaceholderDrawingColor(color: ResourceColor | null): common2D.Color | null {
  let argb = -1;
  if (typeof color === 'number') {
    const n = color as number;
    argb = n > 0xFFFFFF ? n : (0xFF000000 + n);
  } else if (typeof color === 'string') {
    let hex = (color as string).trim();
    if (!hex.startsWith('#')) {
      return null;
    }
    hex = hex.substring(1);
    if (hex.length === 3) {
      hex = hex.charAt(0) + hex.charAt(0) + hex.charAt(1) + hex.charAt(1) + hex.charAt(2) + hex.charAt(2);
    }
    if (hex.length === 6) {
      hex = 'FF' + hex;
    }
    if (hex.length !== 8 || !new RegExp('^[0-9a-fA-F]+$').test(hex)) {
      return null;
    }
    argb = parseInt(hex, 16);
  }
  if (argb < 0) {
    return null;
  }
  const result: common2D.Color = {
    alpha: Math.floor(argb / 0x1000000) % 256,
    red: Math.floor(argb / 0x10000) % 256,
    green: Math.floor(argb / 0x100) % 256,
    blue: argb % 256
  };
  return result;
}

const IDENTITY: number[] = [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0];

/** A filter painting an image's opaque pixels with color (template tinting); identity when color is null. */
export function CYLPlaceholderTintFilter(color: ResourceColor | null): ColorFilter | drawing.ColorFilter {
  const c = CYLPlaceholderDrawingColor(color);
  if (c === null) {
    return new ColorFilter(IDENTITY);
  }
  return drawing.ColorFilter.createBlendModeColorFilter(c, drawing.BlendMode.SRC_IN);
}

/** Draws a CYLPlaceholderViewModel (iOS `CYLPlaceholderView`). */
@Component
export struct CYLPlaceholderView {
  @ObjectLink model: CYLPlaceholderViewModel;
  /** Replays the icon's item when the image replaced its ended animation (showsImageWhenAnimationEnds). */
  private iconController: CYLAnimatedItemController = new CYLAnimatedItemController();

  aboutToAppear(): void {
    this.model.cyl_animationReplayHandler = () => {
      this.iconController.restartAnimation();
    };
    CYLPlaceholderAnimatedItem.attach(this.model);
  }

  aboutToDisappear(): void {
    CYLPlaceholderAnimatedItem.detach(this.model);
  }

  @Builder
  badge() {
    if (this.model.badgeStyle !== CYLPlaceholderBadgeStyle.None) {
      Text(this.model.badgeText)
        .fontSize(CYLPlaceholderBadgeAppearance.sharedAppearance.font)
        .fontColor(CYLPlaceholderBadgeAppearance.sharedAppearance.textColor)
        .backgroundColor(CYLPlaceholderBadgeAppearance.sharedAppearance.backgroundColor)
        .borderRadius(CYLPlaceholderBadgeAppearance.sharedAppearance.cornerRadius < 0 ? 999 :
          CYLPlaceholderBadgeAppearance.sharedAppearance.cornerRadius)
        .padding(this.model.badgeStyle === CYLPlaceholderBadgeStyle.Dot ? 0 : {
          top: CYLPlaceholderBadgeAppearance.sharedAppearance.contentInsets.top,
          left: CYLPlaceholderBadgeAppearance.sharedAppearance.contentInsets.left,
          bottom: CYLPlaceholderBadgeAppearance.sharedAppearance.contentInsets.bottom,
          right: CYLPlaceholderBadgeAppearance.sharedAppearance.contentInsets.right
        })
        .constraintSize({ minWidth: this.model.badgeStyle === CYLPlaceholderBadgeStyle.Dot ? 8 : 18 })
        .width(this.model.badgeStyle === CYLPlaceholderBadgeStyle.Dot ? 8 : undefined)
        .height(this.model.badgeStyle === CYLPlaceholderBadgeStyle.Dot ? 8 : undefined)
        .textAlign(TextAlign.Center)
        .translate({ x: this.model.badgeCenterOffset.x, y: this.model.badgeCenterOffset.y })
        .animation({
          duration: CYLPlaceholderBadgeAppearance.sharedAppearance.animatesChanges ?
            CYLPlaceholderBadgeAppearance.sharedAppearance.animationDuration * 1000 : 0
        })
        .accessibilityLevel('no')
    }
  }

  /**
   * The icon: CYLTabBarController's CYLAnimatedItemView (the animation when a registered engine plays it, else the
   * static image, else its placeholder). Template icons are tinted with the icon color while the image shows: a layer
   * of that color drawn SRC_IN over the icon (CYLAnimatedItemView has no tint of its own). The title, badge and
   * accessibility stay this view's: the icon is hidden from accessibility and lets taps through to this view.
   */
  @Builder
  icon() {
    Stack() {
      CYLAnimatedItemView({
        image: this.model.currentImage !== null ? this.model.currentImage as ResourceStr : '',
        animationUrl: this.model.cyl_animatedItemURL,
        isItemSelected: this.model.selected,
        iconSize: this.model.imageSide,
        // Bare: no 4vp padding, exactly the icon's size, taps and accessibility left to this view. With the padding
        // the item's inner box was 8vp narrower than the icon in this imageSide Stack, and the icon overflowed to the
        // left only: 4vp off the title's center line (the Celebrate detail page, 2026-11-18).
        isBare: true,
        showsImageWhenAnimationEnds: this.model.showsImageWhenAnimationEnds,
        controller: this.iconController,
        animationBuilder: cylPlaceholderAnimatedItemBuilder
      })
      if (this.model.tintsIcon && (!(this.model.animationVisible && this.model.animationReady) ||
        this.model.animationEndedShowsImage)) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(this.model.currentIconColor)
          .blendMode(BlendMode.SRC_IN, BlendApplyType.OFFSCREEN)
      }
    }
    // The icon's own size: the tint overlay is 100% x 100% of this Stack, and a Stack with no size of its own took the
    // whole height of an unbounded parent (the HUD box stretched over the screen, its title pushed away; E14).
    .width(Math.max(1, this.model.imageSide))
    .height(Math.max(1, this.model.imageSide))
    .blendMode(BlendMode.SRC_OVER, BlendApplyType.OFFSCREEN)
    .hitTestBehavior(HitTestMode.None)
    .accessibilityLevel('no-hide-descendants')
    .id(this.cylPartId('icon'))
  }

  /**
   * The inspector id of a part ("icon", "title"): "<accessibilityIdentifier>-<part>", or "cyl-placeholder-<part>" without
   * an identifier. scripts/harmonyos-center-check.py finds the icon and the title by these ids in a uitest dumpLayout
   * and checks that they share one center line (E16).
   */
  private cylPartId(part: string): string {
    const base = this.model.accessibilityIdentifier.length > 0 ? this.model.accessibilityIdentifier : 'cyl-placeholder';
    return `${base}-${part}`;
  }

  @Builder
  item() {
    if (this.model.cyl_showsIcon) {
      Stack({ alignContent: Alignment.TopEnd }) {
        this.icon()
        this.badge()
      }
    }
    if (this.model.currentText !== null && (this.model.currentText as string).length > 0) {
      Text(this.model.currentText)
        .fontSize(this.model.currentTitleFont)
        .fontColor(this.model.currentTitleColor)
        .textAlign(TextAlign.Center)
        .backgroundColor(this.model.titleBackgroundColor !== null ? this.model.titleBackgroundColor : Color.Transparent)
        .border({
          width: this.model.titleBorderWidth,
          color: this.model.titleBorderColor !== null ? this.model.titleBorderColor : Color.Transparent,
          radius: this.model.titleCornerRadius
        })
        .padding({
          top: this.model.titleContentInsets.top, left: this.model.titleContentInsets.left,
          bottom: this.model.titleContentInsets.bottom, right: this.model.titleContentInsets.right
        })
        .constraintSize({ minWidth: this.model.titleMinimumWidth })
        .margin({ top: this.model.cyl_showsIcon ? 8 : 0 })
        .translate({ x: this.model.defaultTitlePositionAdjustment.x, y: this.model.defaultTitlePositionAdjustment.y })
        .id(this.cylPartId('title'))
    }
  }

  @Builder
  button() {
    Text(this.model.currentText !== null ? this.model.currentText : '')
      .fontSize(17)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.model.buttonStyle === CYLPlaceholderButtonStyle.Outlined ? CYLPlaceholderAccentColor : Color.White)
      .backgroundColor(this.model.buttonStyle === CYLPlaceholderButtonStyle.Outlined ? Color.Transparent :
        CYLPlaceholderAccentColor)
      .border({
        width: this.model.buttonStyle === CYLPlaceholderButtonStyle.Outlined ? 1 : 0,
        color: CYLPlaceholderAccentColor,
        radius: this.model.buttonStyle === CYLPlaceholderButtonStyle.Capsule ? 22 : 8
      })
      .padding({ top: 10, bottom: 10, left: 24, right: 24 })
      .constraintSize({ minWidth: 140, minHeight: 44 })
      .textAlign(TextAlign.Center)
      .opacity(this.model.tapInteractionEnabled ? 1 : 0.4)
      .accessibilityRole(AccessibilityRoleType.BUTTON)
  }

  @Builder
  separator() {
    Row({ space: 8 }) {
      Divider().width(40).color('#C7C7CC')
      Text(this.model.currentText !== null ? this.model.currentText : '').fontSize(14).fontColor(DEFAULT_TITLE_COLOR)
      Divider().width(40).color('#C7C7CC')
    }
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Stack() {
      if (this.model.currentSelectionIndicatorImage !== null) {
        Image(this.model.currentSelectionIndicatorImage)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Fill)
          .colorFilter(CYLPlaceholderTintFilter(this.model.currentSelectionIndicatorTintColor))
      }
      Column() {
        if (this.model.kind === CYLPlaceholderComponentKind.Hint) {
          Text(this.model.currentText !== null ? this.model.currentText : '')
            .fontSize(15)
            .fontColor(DEFAULT_TITLE_COLOR)
            .textAlign(TextAlign.Center)
        } else if (this.model.kind === CYLPlaceholderComponentKind.Button) {
          this.button()
        } else if (this.model.kind === CYLPlaceholderComponentKind.Separator) {
          this.separator()
        } else {
          this.item()
        }
      }
      .alignItems(HorizontalAlign.Center)
      .opacity(this.model.tapHighlighted && this.model.tapHighlightStyle === CYLPlaceholderTapHighlightStyle.Dim ?
        0.5 : 1)
      .scale(this.model.tapHighlighted && this.model.tapHighlightStyle === CYLPlaceholderTapHighlightStyle.Shrink ?
        { x: 0.95, y: 0.95 } : { x: 1, y: 1 })
      .animation({ duration: 120 })
    }
    .width(this.model.reportsContentSize ? undefined : '100%')
    .height(this.model.reportsContentSize ? undefined : '100%')
    .constraintSize({ maxWidth: this.model.reportsContentSize && this.model.preferredMaxLayoutWidth > 0 ?
      this.model.preferredMaxLayoutWidth : undefined })
    .padding(this.model.contentMargin)
    .backgroundColor(this.model.currentBackgroundColor)
    .id(this.model.accessibilityIdentifier)
    .accessibilityText(this.model.accessibilityLabel !== null ? this.model.accessibilityLabel :
      ((this.model.currentText !== null ? this.model.currentText : '') +
        (this.model.badgeText.length > 0 ? ', ' + this.model.badgeText : '')))
    .accessibilityDescription(this.model.accessibilityHint !== null ? this.model.accessibilityHint : '')
    .hitTestBehavior(this.model.tapInteractive ? HitTestMode.Default : HitTestMode.None)
    .onTouch((event: TouchEvent) => {
      if (!this.model.tapInteractive) {
        return;
      }
      if (event.type === TouchType.Down) {
        this.model.tapHighlighted = true;
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.model.tapHighlighted = false;
      }
    })
    .onClick(() => {
      this.model.performTap();
    })
  }
}
