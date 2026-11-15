// The HarmonyOS counterpart of iOS CYLPlaceholderView: an icon (or illustration) with a title, a badge, selected
// colors, tap handling and highlight. The state lives in the @Observed CYLPlaceholderViewModel (the iOS view's
// properties and initializers); the @Component CYLPlaceholderView draws it:
//
//   @State placeholder: CYLPlaceholderViewModel = CYLPlaceholderViewModel.initWithStyleMessage(
//     CYLPlaceholderStyle.NoInternet, CYLPlaceholderMessage.NoInternet);
//   ...
//   CYLPlaceholderView({ model: this.placeholder })
import { drawing, common2D } from '@kit.ArkGraphics2D';
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
import { CYLPlaceholderBundledAnimationFileNames, CYLPlaceholderImageResource } from './CYLPlaceholderImages';
import { CYLPlaceholderConfiguration } from './CYLPlaceholderConfiguration';
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

  /** 0 loops, N plays N times; stored for the animation player. */
  animationRepeatCount: number = 0;
  /** The bundled animation file the view stands for, for the animation player; the static image is shown. */
  animationFileName: string | null = null;

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
   * imageBundle is not supported yet (image names are bundled icons, Resources or paths).
   */
  static initWithItemAttributes(attributes: Record<string, Object>, imageBundle: string | null = null,
    onError: ((message: string) => void) | null = null): CYLPlaceholderViewModel | null {
    let image: ResourceStr | null = readImage(attributes[CYLPlaceholderItemImage]);
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
    m.selectedImage = readImage(attributes[CYLPlaceholderItemSelectedImage]);
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
    return m;
  }

  /**
   * Reads the item attributes from a local ".json" or ".plist" file, a sandbox path or "file://" URI
   * (`-initWithItemContentsOfURL:imageBundle:error:`); null, with the reason, when it cannot be read or is invalid.
   */
  static initWithItemContentsOfURL(path: string, imageBundle: string | null = null,
    onError: ((message: string) => void) | null = null): CYLPlaceholderViewModel | null {
    const attributes = CYLPlaceholderConfiguration.readFile(path, onError);
    return attributes === null ? null : CYLPlaceholderViewModel.initWithItemAttributes(attributes, imageBundle, onError);
  }

  /** The view of a stack component (what CYLPlaceholderStackView makes for each component). */
  static initWithComponent(component: CYLPlaceholderComponent): CYLPlaceholderViewModel {
    const m = CYLPlaceholderViewModel.initWithImageText(component.image, component.title);
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
    m.animationFileName = component.animationFileName;
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

  @Builder
  item() {
    if (this.model.currentImage !== null) {
      Stack({ alignContent: Alignment.TopEnd }) {
        Image(this.model.currentImage)
          .width(this.model.imageSide)
          .height(this.model.imageSide)
          .objectFit(ImageFit.Contain)
          .colorFilter(CYLPlaceholderTintFilter(this.model.tintsIcon ? this.model.currentIconColor : null))
          .accessibilityLevel('no')
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
        .margin({ top: this.model.currentImage !== null ? 12 : 0 })
        .translate({ x: this.model.defaultTitlePositionAdjustment.x, y: this.model.defaultTitlePositionAdjustment.y })
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
