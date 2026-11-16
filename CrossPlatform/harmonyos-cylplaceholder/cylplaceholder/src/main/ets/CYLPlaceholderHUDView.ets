// Draws a CYLPlaceholderHUD in a global overlay: a ComponentContent added to the containerView UIContext's
// OverlayManager, so the class methods work from anywhere once the shared HUD has its UIContext. The box centers in
// the window (moved by offsetFromCenter) over the mask of maskType; the built-in states show the icon (or animation:
// loadingAnimationFileName, progressAnimationFileName, successAnimationFileName) and status of contentView, and the
// Custom state the CYLPlaceholderStackView of placeholderView.
import { ComponentContent } from '@kit.ArkUI';
import { vibrator } from '@kit.SensorServiceKit';
import { resourceManager } from '@kit.LocalizationKit';
import {
  CYLPlaceholderHUD,
  CYLPlaceholderHUDSetPresenter,
  CYLPlaceholderHUDMaskType,
  CYLPlaceholderHUDPresenter,
  CYLPlaceholderHUDState
} from './CYLPlaceholderHUD';
import { CYLPlaceholderView } from './CYLPlaceholderView';
import { CYLPlaceholderStackView } from './CYLPlaceholderStackView';

/** The box and its mask. */
@Component
export struct CYLPlaceholderHUDView {
  @ObjectLink hud: CYLPlaceholderHUD;

  @Builder
  box() {
    Column({ space: 12 }) {
      if (this.hud.state === CYLPlaceholderHUDState.Custom && this.hud.placeholderView !== null) {
        Column() {
          CYLPlaceholderStackView({ model: this.hud.placeholderView })
        }
        .constraintSize({ maxWidth: 300, maxHeight: 480 })
      } else if (this.hud.contentView !== null) {
        CYLPlaceholderView({ model: this.hud.contentView })
      }
    }
    .padding(16)
    .constraintSize({
      minWidth: this.hud.minimumSize.width,
      minHeight: this.hud.minimumSize.height,
      maxWidth: 300
    })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(this.hud.boxColor)
    .borderRadius(this.hud.cornerRadius)
    .shadow({ radius: 16, color: '#33000000' })
    .translate({ x: this.hud.offsetFromCenter.horizontal, y: this.hud.offsetFromCenter.vertical })
    .accessibilityGroup(true)
    .accessibilityText(this.hud.status !== null ? this.hud.status : '')
    .onClick(() => {
      this.hud.receiveTouch(true);
    })
  }

  build() {
    Stack() {
      this.box()
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Center)
    .backgroundColor(this.hud.maskType === CYLPlaceholderHUDMaskType.Black ? '#66000000' :
      this.hud.maskType === CYLPlaceholderHUDMaskType.Custom ? this.hud.backgroundLayerColor : Color.Transparent)
    .radialGradient(this.hud.maskType === CYLPlaceholderHUDMaskType.Gradient ? {
      center: ['50%', '50%'],
      radius: '75%',
      colors: [['#00000000', 0], ['#99000000', 1]]
    } : { center: ['50%', '50%'], radius: 0, colors: [['#00000000', 0], ['#00000000', 1]] })
    .hitTestBehavior(this.hud.blocksTouches ? HitTestMode.Default : HitTestMode.Transparent)
    .onClick(() => {
      if (this.hud.blocksTouches) {
        this.hud.receiveTouch(false);
      }
    })
    .opacity(this.hud.opacity)
    .animation({
      duration: (this.hud.opacity > 0 ? this.hud.fadeInAnimationDuration : this.hud.fadeOutAnimationDuration) * 1000
    })
  }
}

class CYLPlaceholderHUDParams {
  hud: CYLPlaceholderHUD;

  constructor(hud: CYLPlaceholderHUD) {
    this.hud = hud;
  }
}

@Builder
function hudBuilder(params: CYLPlaceholderHUDParams) {
  CYLPlaceholderHUDView({ hud: params.hud })
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
    const content = new ComponentContent<CYLPlaceholderHUDParams>(context, wrapBuilder(hudBuilder),
      new CYLPlaceholderHUDParams(hud));
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
