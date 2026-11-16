// CYLRefreshRiveView: the ArkUI half of CYLRefreshRiveHeader (iOS CYLRefreshRiveHeader's RiveView): plays the style's
// .riv file with @ohos/rive's RiveAnimationView, laid out bottom-aligned in at least the style's minimum height, and
// attaches itself to the header model as its CYLRefreshRiveDriver. CYLRefreshComponentView shows it for a Rive header
// and for a drawn footer hosting one.
import { Alignment as RiveAlignment, Fit, Loop, RiveAnimationView } from '@ohos/rive';
import { CYLPlaceholderAnimationArrayBuffer, CYLPlaceholderAnimationReadFile } from '../../CYLPlaceholderAnimation';
import { cylEnsureRiveInitialized, cylRiveRendererType } from '../../CYLRivePlaceholderItemAnimator';
import { CYLRefreshComponentModel, CYLRefreshScrollViewModel } from '../CYLRefreshComponent';
import { cylRefreshDrawnStyle } from './CYLRefreshDrawnView';
import { CYLRefreshRiveDriver, CYLRefreshRiveHeaderModel, CYLRefreshRiveStyle } from './CYLRefreshRiveHeader';

/** The Rive header a control shows: itself, or the style of a drawn footer; null for other controls. */
export function cylRefreshRiveHeader(c: CYLRefreshComponentModel | null): CYLRefreshRiveHeaderModel | null {
  const style = cylRefreshDrawnStyle(c);
  return style instanceof CYLRefreshRiveHeaderModel ? style as CYLRefreshRiveHeaderModel : null;
}

/** A RiveAnimationView as the header's driver (iOS RiveViewModel). */
class CYLRefreshRiveViewDriver implements CYLRefreshRiveDriver {
  private view: RiveAnimationView;
  private style: CYLRefreshRiveStyle;

  constructor(view: RiveAnimationView, style: CYLRefreshRiveStyle) {
    this.view = view;
    this.style = style;
  }

  setNumber(input: string, value: number): void {
    const machine = this.style.stateMachineName;
    if (machine !== null) {
      try {
        this.view.setNumberState(machine, input, value);
      } catch (e) {
        // No such input: skipped, as iOS.
      }
    }
  }

  setBoolean(input: string, value: boolean): void {
    const machine = this.style.stateMachineName;
    if (machine !== null) {
      try {
        this.view.setBooleanState(machine, input, value);
      } catch (e) {
        // No such input.
      }
    }
  }

  fire(trigger: string): void {
    const machine = this.style.stateMachineName;
    if (machine !== null) {
      try {
        this.view.fireState(machine, trigger);
      } catch (e) {
        // No such trigger.
      }
    }
  }

  play(animation: string | null, loop: boolean): void {
    try {
      if (animation === null) {
        this.view.play();
      } else {
        this.view.play(animation, loop ? Loop.LOOP : Loop.ONESHOT);
      }
    } catch (e) {
      // No such animation.
    }
  }

  scrub(animation: string, time: number): void {
    try {
      let instance = this.view.getAnimations().find((a) => a.name === animation);
      if (instance === undefined) {
        this.view.play(animation, Loop.ONESHOT);
        instance = this.view.getAnimations().find((a) => a.name === animation);
      }
      this.view.pause();
      if (instance !== undefined) {
        instance.settime(time);
        instance.apply();
      }
      const controller = this.view.controller;
      if (controller !== null) {
        controller.advance(0);
      }
    } catch (e) {
      // No such animation.
    }
  }

  duration(animation: string): number {
    try {
      const instance = this.view.getAnimations().find((a) => a.name === animation);
      return instance !== undefined ? instance.geteffectiveDurationInSeconds() : -1;
    } catch (e) {
      return -1;
    }
  }

  reset(): void {
    try {
      this.view.reset();
    } catch (e) {
      // Nothing loaded.
    }
  }
}

/** Plays the Rive header of a scroll view model's header or footer (`role`: 'header' or 'footer'). */
@Component
export struct CYLRefreshRiveView {
  scrollView: CYLRefreshScrollViewModel = new CYLRefreshScrollViewModel();
  role: string = 'header';
  @State private viewH: number = 0;
  private header: CYLRefreshRiveHeaderModel | null = null;
  private riveView: RiveAnimationView | null = null;
  private bytes: ArrayBuffer | null = null;
  private driver: CYLRefreshRiveViewDriver | null = null;

  aboutToAppear(): void {
    const c = this.role === 'footer' ? this.scrollView.cyl_footer : this.scrollView.cyl_header;
    this.header = cylRefreshRiveHeader(c);
    const header = this.header;
    if (header === null || header.riveStyle === null) {
      return;
    }
    try {
      cylEnsureRiveInitialized();
    } catch (e) {
      return;
    }
    const style = header.riveStyle as CYLRefreshRiveStyle;
    CYLPlaceholderAnimationReadFile(style.fileURL, this.getUIContext().getHostContext() as Context)
      .then((bytes: Uint8Array) => {
        this.bytes = CYLPlaceholderAnimationArrayBuffer(bytes);
        this.loadIfPossible();
      })
      .catch(() => {
        // Unreadable file: the header stays empty (iOS returns nil and the example falls back).
      });
  }

  aboutToDisappear(): void {
    if (this.header !== null && this.driver !== null) {
      this.header.cyl_detachDriver(this.driver);
    }
    this.driver = null;
    this.riveView = null;
  }

  private loadIfPossible(): void {
    const view = this.riveView;
    const header = this.header;
    if (view === null || header === null || header.riveStyle === null || this.bytes === null || this.driver !== null) {
      return;
    }
    const style = header.riveStyle as CYLRefreshRiveStyle;
    const machine = style.stateMachineName;
    const animation = machine === null ? (style.idleAnimation !== null ? style.idleAnimation : style.pullAnimation) : null;
    const autoplay = machine !== null || style.idleAnimation !== null;
    try {
      view.setRiveBytes(this.bytes as ArrayBuffer, style.artboardName !== null ? style.artboardName : undefined,
        animation !== null ? animation : undefined, machine !== null ? machine : undefined, autoplay, false,
        style.fitsWidth ? Fit.FIT_WIDTH : Fit.COVER, RiveAlignment.CENTER,
        style.idleAnimation !== null ? Loop.LOOP : Loop.ONESHOT);
    } catch (e) {
      return;
    }
    const driver = new CYLRefreshRiveViewDriver(view, style);
    this.driver = driver;
    header.cyl_attachDriver(driver);
  }

  private layoutHeight(): number {
    const header = this.header;
    return header !== null && header.riveStyle !== null ?
      (header.riveStyle as CYLRefreshRiveStyle).layoutHeight(this.viewH) : this.viewH;
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      RiveAnimationView({
        riveAutoPlay: false,
        touchPassThrough: true,
        rendererType: cylRiveRendererType(),
        onReady: (riveView: RiveAnimationView) => {
          this.riveView = riveView;
          this.loadIfPossible();
        }
      })
        .width('100%')
        .height(this.layoutHeight())
        .hitTestBehavior(HitTestMode.None)
    }
    .width('100%')
    .height('100%')
    .clip(true)
    .accessibilityLevel('no-hide-descendants')
    .onAreaChange((oldValue: Area, newValue: Area) => {
      this.viewH = Number(newValue.height);
    })
  }
}
