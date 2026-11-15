// The HarmonyOS counterpart of iOS CYLPlaceholderStatusView (ported from CYLChatKit's LCCKStatusView; behavior from
// android/placeholder's CYLPlaceholderStatus.kt): a one-line bar, 44 vp high, with an icon left of a title, by default
// "Network unavailable, Check network" on a light red background. The state lives in the @Observed
// CYLPlaceholderStatusViewModel; the @Component CYLPlaceholderStatusView draws it:
//
//   @State bar: CYLPlaceholderStatusViewModel = CYLPlaceholderStatusViewModel.initWithFrame();
//   ...
//   CYLPlaceholderStatusView({ model: this.bar })
import { CYLPlaceholderTintFilter, CYLPlaceholderViewModel } from './CYLPlaceholderView';
import { CYLPlaceholderLocalization } from './CYLPlaceholderLocalization';
import { CYLPlaceholderImageNames } from './CYLPlaceholderImages';
import {
  CYLPlaceholderItemAccessibilityIdentifier,
  CYLPlaceholderItemBackgroundColor,
  CYLPlaceholderItemIconColor,
  CYLPlaceholderItemImage,
  CYLPlaceholderItemTitle,
  CYLPlaceholderItemTitleColor
} from './CYLPlaceholderViewTypes';
import { CYLPlaceholderConfiguration, CYLPlaceholderConfigurationErrorHandler } from './CYLPlaceholderConfiguration';
import { CYLPlaceholderDrawingColor } from './CYLPlaceholderView';

/** Receives taps on the bar (iOS `CYLPlaceholderStatusViewDelegate`). */
export interface CYLPlaceholderStatusViewDelegate {
  /** The bar was tapped; sender is the status view model (iOS `-statusViewClicked:`, optional). */
  statusViewClicked?: (sender: CYLPlaceholderStatusViewModel) => void;
}

/** Runs when the bar is tapped (iOS `CYLPlaceholderStatusViewTapHandler`). */
export type CYLPlaceholderStatusViewTapHandler = (statusView: CYLPlaceholderStatusViewModel) => void;

/** The bar's height, 44 vp, under CYLChatKit's spelling (iOS `CYLPlaceholderStatusViewHight`). */
export const CYLPlaceholderStatusViewHight: number = 44;
/** The same height, correctly spelled (iOS `CYLPlaceholderStatusViewHeight`). */
export const CYLPlaceholderStatusViewHeight: number = 44;

/** The default colors, as on iOS (light appearance). */
const STATUS_BACKGROUND_COLOR = '#FFC7C7';
const STATUS_TEXT_COLOR = '#555555';
const STATUS_ICON_SIDE = 20;
const STATUS_ICON_COLOR = '#FF3B30';

/** The state of a CYLPlaceholderStatusView (iOS `CYLPlaceholderStatusView`). */
@Observed
export class CYLPlaceholderStatusViewModel {
  /** Told about taps (iOS `delegate`). */
  delegate: CYLPlaceholderStatusViewDelegate | null = null;
  /** The icon and the title, drawn horizontally (iOS `placeholderView`). */
  placeholderView: CYLPlaceholderViewModel;
  /** Runs on a tap, after the delegate (iOS `tapHandler`). */
  tapHandler: CYLPlaceholderStatusViewTapHandler | null = null;
  /** The bar's background (iOS: the view's backgroundColor). */
  backgroundColor: ResourceColor = STATUS_BACKGROUND_COLOR;
  /** The component id ("accessibilityIdentifier"); "" for none. */
  accessibilityIdentifier: string = '';

  private constructor(placeholderView: CYLPlaceholderViewModel) {
    this.placeholderView = placeholderView;
  }

  /** The title shown; setting it updates the bar (iOS `text`). */
  get text(): string | null {
    return this.placeholderView.text;
  }

  set text(value: string | null) {
    this.placeholderView.text = value;
  }

  /** Whether a tap does something: a handler or a delegate is set (then the bar is a button for accessibility). */
  get tappable(): boolean {
    return this.tapHandler !== null || this.delegate !== null;
  }

  /** Runs the delegate, then the tap handler, as a tap does. */
  performTap(): void {
    const delegate = this.delegate;
    if (delegate !== null && delegate.statusViewClicked !== undefined) {
      delegate.statusViewClicked(this);
    }
    const handler = this.tapHandler;
    if (handler !== null) {
      handler(this);
    }
  }

  /** The network bar of CYLChatKit: the failure icon and the localized network message (iOS `-initWithFrame:`). */
  static initWithFrame(): CYLPlaceholderStatusViewModel {
    const m = CYLPlaceholderStatusViewModel.initWithItemAttributes(
      CYLPlaceholderStatusViewModel.networkUnavailableItemAttributes);
    return m as CYLPlaceholderStatusViewModel;
  }

  /** The item attributes of the network bar, to start a custom one from (iOS `networkUnavailableItemAttributes`). */
  static get networkUnavailableItemAttributes(): Record<string, Object> {
    const attributes: Record<string, Object> = {};
    attributes[CYLPlaceholderItemTitle] =
      CYLPlaceholderLocalization.localizedStringForKey('status_network_unavailable', null);
    attributes[CYLPlaceholderItemImage] = 'status_fail';
    attributes[CYLPlaceholderItemTitleColor] = STATUS_TEXT_COLOR;
    attributes[CYLPlaceholderItemBackgroundColor] = STATUS_BACKGROUND_COLOR;
    return attributes;
  }

  /**
   * A bar with its own icon and title from item attributes (CYLPlaceholderItemTitle, CYLPlaceholderItemImage,
   * CYLPlaceholderItemTitleColor, CYLPlaceholderItemBackgroundColor for the bar); missing keys take the network bar's
   * values (iOS `-initWithItemAttributes:error:`). null, with the reason, when they are invalid.
   */
  static initWithItemAttributes(attributes: Record<string, Object>,
    onError: CYLPlaceholderConfigurationErrorHandler | null = null): CYLPlaceholderStatusViewModel | null {
    const defaults = CYLPlaceholderStatusViewModel.networkUnavailableItemAttributes;
    const merged: Record<string, Object> = {};
    Object.keys(defaults).forEach((k: string) => {
      merged[k] = defaults[k];
    });
    Object.keys(attributes).forEach((k: string) => {
      merged[k] = attributes[k];
    });
    const background: Object | undefined = merged[CYLPlaceholderItemBackgroundColor];
    const content: Record<string, Object> = {};
    Object.keys(merged).forEach((k: string) => {
      if (k !== CYLPlaceholderItemBackgroundColor) {
        content[k] = merged[k];
      }
    });
    const view = CYLPlaceholderViewModel.initWithItemAttributes(content, null, onError);
    if (view === null) {
      return null;
    }
    view.imageSide = STATUS_ICON_SIDE;
    view.defaultTitleFont = 15;
    view.contentMargin = 0;
    if (merged[CYLPlaceholderItemIconColor] === undefined) {
      view.defaultIconColor = STATUS_ICON_COLOR;
    }
    view.reportsContentSize = true;
    const m = new CYLPlaceholderStatusViewModel(view);
    if (typeof background === 'string' || typeof background === 'number') {
      m.backgroundColor = background as ResourceColor;
    } else if (background !== undefined && background !== null && typeof background === 'object') {
      m.backgroundColor = background as Resource;
    }
    const identifier: Object | undefined = merged[CYLPlaceholderItemAccessibilityIdentifier];
    if (typeof identifier === 'string') {
      m.accessibilityIdentifier = identifier as string;
    }
    return m;
  }

  /**
   * A bar from a configuration dictionary (iOS `-initWithConfiguration:error:`): "text", "textKey" (a core string
   * key, "text" being its fallback), "image" (a bundled icon name, "status_fail"), "titleColor" and "backgroundColor"
   * (color strings such as "#FFC7C7"), "accessibilityIdentifier"; missing keys keep the network bar's values. null,
   * with the reason, when a value is invalid.
   */
  static initWithConfiguration(configuration: Record<string, Object> | null,
    onError: CYLPlaceholderConfigurationErrorHandler | null = null): CYLPlaceholderStatusViewModel | null {
    if (configuration === null || !CYLPlaceholderConfiguration.isDictionary(configuration)) {
      return CYLPlaceholderConfiguration.fail(onError, 'The status bar configuration must be a dictionary.');
    }
    const keys = ['text', 'textKey', 'image', 'titleColor', 'backgroundColor', 'accessibilityIdentifier'];
    for (let i = 0; i < keys.length; i++) {
      const v: Object | undefined = configuration[keys[i]];
      if (v !== undefined && v !== null && typeof v !== 'string') {
        return CYLPlaceholderConfiguration.fail(onError, '"' + keys[i] + '" must be a string.');
      }
    }
    const attributes: Record<string, Object> = {};
    const image: Object | undefined = configuration['image'];
    if (typeof image === 'string') {
      const name = image as string;
      if (name.startsWith('system:')) {
        return CYLPlaceholderConfiguration.fail(onError, 'An SF Symbol is an iOS image; name a bundled icon.');
      }
      if (CYLPlaceholderImageNames.indexOf(name) < 0) {
        return CYLPlaceholderConfiguration.fail(onError, 'The image ' + name + ' was not found.');
      }
      attributes[CYLPlaceholderItemImage] = name;
    }
    const titleColor: Object | undefined = configuration['titleColor'];
    if (typeof titleColor === 'string') {
      if (CYLPlaceholderDrawingColor(titleColor as string) === null) {
        return CYLPlaceholderConfiguration.fail(onError, '"titleColor" is not a color.');
      }
      attributes[CYLPlaceholderItemTitleColor] = titleColor as string;
    }
    const background: Object | undefined = configuration['backgroundColor'];
    if (typeof background === 'string') {
      if (CYLPlaceholderDrawingColor(background as string) === null) {
        return CYLPlaceholderConfiguration.fail(onError, '"backgroundColor" is not a color.');
      }
      attributes[CYLPlaceholderItemBackgroundColor] = background as string;
    }
    const text = CYLPlaceholderConfiguration.configuredText(configuration, 'text', 'textKey');
    if (text !== null) {
      attributes[CYLPlaceholderItemTitle] = text;
    }
    const identifier: Object | undefined = configuration['accessibilityIdentifier'];
    if (typeof identifier === 'string') {
      attributes[CYLPlaceholderItemAccessibilityIdentifier] = identifier as string;
    }
    return CYLPlaceholderStatusViewModel.initWithItemAttributes(attributes, onError);
  }
}

/** Draws a CYLPlaceholderStatusViewModel (iOS `CYLPlaceholderStatusView`): the icon left of the title, centered. */
@Component
export struct CYLPlaceholderStatusView {
  @ObjectLink model: CYLPlaceholderStatusViewModel;

  build() {
    Row({ space: 8 }) {
      if (this.model.placeholderView.currentImage !== null) {
        Image(this.model.placeholderView.currentImage)
          .width(this.model.placeholderView.imageSide)
          .height(this.model.placeholderView.imageSide)
          .objectFit(ImageFit.Contain)
          .colorFilter(CYLPlaceholderTintFilter(this.model.placeholderView.tintsIcon ?
            this.model.placeholderView.currentIconColor : null))
          .accessibilityLevel('no')
      }
      Text(this.model.text !== null ? this.model.text : '')
        .fontSize(this.model.placeholderView.currentTitleFont)
        .fontColor(this.model.placeholderView.currentTitleColor)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .flexShrink(1)
    }
    .width('100%')
    .constraintSize({ minHeight: CYLPlaceholderStatusViewHeight })
    .padding({ left: 16, right: 16, top: 4, bottom: 4 })
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .backgroundColor(this.model.backgroundColor)
    .id(this.model.accessibilityIdentifier)
    .accessibilityGroup(true)
    .accessibilityText(this.model.text !== null ? this.model.text : '')
    .accessibilityRole(this.model.tappable ? AccessibilityRoleType.BUTTON : AccessibilityRoleType.TEXT)
    .onClick(() => {
      this.model.performTap();
    })
  }
}
