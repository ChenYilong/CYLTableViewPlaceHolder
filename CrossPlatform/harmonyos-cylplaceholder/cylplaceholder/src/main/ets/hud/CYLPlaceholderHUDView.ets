// Draws a CYLPlaceholderHUD in a global overlay: a ComponentContent added to the containerView UIContext's
// OverlayManager, so the class methods work from anywhere once the shared HUD has its UIContext. The box centers in
// the window (moved by offsetFromCenter) over the mask of maskType; the built-in states show the icon (or animation:
// loadingAnimationFileName, progressAnimationFileName, successAnimationFileName) and status of contentView, and the
// Custom state the CYLPlaceholderStackView of placeholderView.
import { ComponentContent, display } from '@kit.ArkUI';
import { vibrator } from '@kit.SensorServiceKit';
import { resourceManager } from '@kit.LocalizationKit';
import {
  CYLPlaceholderHUD,
  CYLPlaceholderHUDSetPresenter,
  CYLPlaceholderHUDMaskType,
  CYLPlaceholderHUDPresenter,
  CYLPlaceholderHUDState
} from './CYLPlaceholderHUD';
import { CYLPlaceholderView, CYLPlaceholderViewModel } from '../CYLPlaceholderView';
import { CYLPlaceholderStackView, CYLPlaceholderStackViewModel } from '../CYLPlaceholderStackView';

/** The box and its mask. */
@Component
export struct CYLPlaceholderHUDView {
  @ObjectLink hud: CYLPlaceholderHUD;
  @State private cylTick: number = 0;

  /**
   * The model, read together with cylTick: ArkUI re-renders only the parts of build() that read the changed state,
   * so every read goes through here and every attribute updates when the model notifies (cylChangeListener).
   */
  private model(): CYLPlaceholderHUD {
    return this.cylTick >= 0 ? this.hud : this.hud;
  }
  /** The overlay's size in vp (the display): `100%` in an OverlayManager ComponentContent can resolve to 0 x 0. */
  overlayWidth: number = 0;
  overlayHeight: number = 0;

  /** This view's own listener: a HUD shown again while the previous overlay fades out gets a new view first, so the
   * old view may only clear the listener while it is still its own. */
  private ownListener: (() => void) | null = null;

  aboutToAppear(): void {
    this.ownListener = () => {
      this.cylTick++;
    };
    this.hud.cylChangeListener = this.ownListener;
  }

  aboutToDisappear(): void {
    if (this.hud.cylChangeListener === this.ownListener) {
      this.hud.cylChangeListener = null;
    }
    this.ownListener = null;
  }

  @Builder
  box() {
    Column({ space: 12 }) {
      if (this.model().state === CYLPlaceholderHUDState.Custom && this.model().placeholderView !== null) {
        Column() {
          CYLPlaceholderStackView({ model: this.model().placeholderView as CYLPlaceholderStackViewModel })
        }
        .constraintSize({ maxWidth: 300, maxHeight: 480 })
      } else if (this.model().contentView !== null) {
        CYLPlaceholderView({ model: this.model().contentView as CYLPlaceholderViewModel })
      }
    }
    .padding(16)
    .constraintSize({
      minWidth: this.model().minimumSize.width,
      minHeight: this.model().minimumSize.height,
      maxWidth: 300
    })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(this.model().boxColor)
    .borderRadius(this.model().cornerRadius)
    .shadow({ radius: 16, color: '#33000000' })
    .translate({ x: this.model().offsetFromCenter.horizontal, y: this.model().offsetFromCenter.vertical })
    .accessibilityGroup(true)
    .accessibilityText(this.model().status !== null ? this.model().status : '')
    .onClick(() => {
      this.model().receiveTouch(true);
    })
  }

  build() {
    Stack() {
      this.box()
    }
    .width(this.overlayWidth > 0 ? this.overlayWidth : '100%')
    .height(this.overlayHeight > 0 ? this.overlayHeight : '100%')
    .alignContent(Alignment.Center)
    .backgroundColor(this.model().maskType === CYLPlaceholderHUDMaskType.Black ? '#66000000' :
      this.model().maskType === CYLPlaceholderHUDMaskType.Custom ? this.model().backgroundLayerColor : Color.Transparent)
    .radialGradient(this.model().maskType === CYLPlaceholderHUDMaskType.Gradient ? {
      center: ['50%', '50%'],
      radius: '75%',
      colors: [['#00000000', 0], ['#99000000', 1]]
    } : { center: ['50%', '50%'], radius: 0, colors: [['#00000000', 0], ['#00000000', 1]] })
    .hitTestBehavior(this.model().blocksTouches ? HitTestMode.Default : HitTestMode.Transparent)
    .onClick(() => {
      if (this.model().blocksTouches) {
        this.model().receiveTouch(false);
      }
    })
    .opacity(this.model().opacity)
    .animation({
      duration: (this.model().opacity > 0 ? this.model().fadeInAnimationDuration : this.model().fadeOutAnimationDuration) * 1000
    })
  }
}

class CYLPlaceholderHUDParams {
  hud: CYLPlaceholderHUD;
  width: number;
  height: number;

  constructor(hud: CYLPlaceholderHUD, width: number, height: number) {
    this.hud = hud;
    this.width = width;
    this.height = height;
  }
}

@Builder
function hudBuilder(params: CYLPlaceholderHUDParams) {
  CYLPlaceholderHUDView({ hud: params.hud, overlayWidth: params.width, overlayHeight: params.height })
}

/** Presents HUDs in the OverlayManager of their containerView. */
class CYLPlaceholderHUDOverlayPresenter implements CYLPlaceholderHUDPresenter {
  present: (hud: CYLPlaceholderHUD) => void = (hud: CYLPlaceholderHUD) => {
    const context = hud.containerView;
    if (context === null) {
      console.warn('CYLPlaceholderHUD: set containerView (a UIContext) first, e.g. ' +
        'CYLPlaceholderSharedHUD().containerView = this.getUIContext()');
      return;
    }
    try {
      const host = context.getHostContext();
      hud.systemDark = host !== undefined &&
        host.resourceManager.getConfigurationSync().colorMode === resourceManager.ColorMode.DARK;
    } catch (e) {
      hud.systemDark = false;
    }
    if (hud.contentView !== null) {
      hud.contentView.defaultTitleColor = hud.contentColor;
      hud.contentView.defaultIconColor = hud.contentColor;
    }
    // The overlay covers the display; sized explicitly, as `100%` inside an OverlayManager ComponentContent drew
    // nothing on the emulator (2026-11-16: the overlay was added and removed, but no HUD showed).
    let overlayWidth = 0;
    let overlayHeight = 0;
    try {
      const screen = display.getDefaultDisplaySync();
      overlayWidth = context.px2vp(screen.width);
      overlayHeight = context.px2vp(screen.height);
    } catch (e) {
      overlayWidth = 0;
      overlayHeight = 0;
    }
    const content = new ComponentContent<CYLPlaceholderHUDParams>(context, wrapBuilder(hudBuilder),
      new CYLPlaceholderHUDParams(hud, overlayWidth, overlayHeight));
    context.getOverlayManager().addComponentContent(content);
    hud.hudView = content;
  };
  remove: (hud: CYLPlaceholderHUD) => void = (hud: CYLPlaceholderHUD) => {
    const content = hud.hudView;
    const context = hud.containerView;
    hud.hudView = null;
    if (content === null || context === null) {
      return;
    }
    const node = content as ComponentContent<CYLPlaceholderHUDParams>;
    try {
      context.getOverlayManager().removeComponentContent(node);
      node.dispose();
    } catch (e) {
      console.warn('CYLPlaceholderHUD: ' + JSON.stringify(e));
    }
  };
  haptic: (hud: CYLPlaceholderHUD, state: CYLPlaceholderHUDState) => void =
    (hud: CYLPlaceholderHUD, state: CYLPlaceholderHUDState) => {
      try {
        vibrator.startVibration({ type: 'time', duration: state === CYLPlaceholderHUDState.Error ? 60 : 30 },
          { id: 0, usage: 'notification' }).catch(() => {
        });
      } catch (e) {
        // No vibrator.
      }
    };
}

/** Installs the overlay presenter (done when this module loads; call it again after replacing the presenter). */
export function CYLPlaceholderHUDInstallOverlayPresenter(): void {
  CYLPlaceholderHUDSetPresenter(new CYLPlaceholderHUDOverlayPresenter());
}

CYLPlaceholderHUDInstallOverlayPresenter();
