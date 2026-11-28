// The core half of the Rive refresh header's view. The core depends on no animation library (CYLTabBarController's
// CYLAnimatedItem rule: an app registers the engines it plays), so the view that plays the .riv file with a Rive
// runtime (and implements CYLRefreshRiveDriver on it) is registered by the app as a builder:
//
//   CYLAnimatedItemEngines.register('Rive');
//   CYLRefreshRiveRegisterViewBuilder(wrapBuilder(cylRefreshRiveViewBuilder));   // the example's @ohos/rive view
//
// CYLRefreshComponentView draws that builder for a Rive header and for a drawn footer hosting one. Without a builder
// the header stays empty and debug builds log once which package to add (CYLAnimatedItemEngines.warnMissingEngine).
import { CYLAnimatedItemEngines } from 'cylanimateditem';
import { CYLRefreshComponentModel, CYLRefreshScrollViewModel } from '../CYLRefreshComponent';
import { cylRefreshDrawnStyle } from './CYLRefreshDrawnView';
import { CYLRefreshRiveHeaderModel, CYLRefreshRiveStyle } from './CYLRefreshRiveHeader';

/**
 * The Rive header a control shows: itself, or the style of a drawn footer; null for other controls.
 */
export function cylRefreshRiveHeader(c: CYLRefreshComponentModel | null): CYLRefreshRiveHeaderModel | null {
  const style = cylRefreshDrawnStyle(c);
  return style instanceof CYLRefreshRiveHeaderModel ? style as CYLRefreshRiveHeaderModel : null;
}

/**
 * Draws the Rive header of a scroll view model's header or footer: the scroll view model and the role ('header' or
 * 'footer'). The view it makes reads `cylRefreshRiveHeader` of that control and attaches a CYLRefreshRiveDriver.
 */
export type CYLRefreshRiveViewBuilderType = WrappedBuilder<[CYLRefreshScrollViewModel, string]>;

let cylRefreshRiveViewBuilderValue: CYLRefreshRiveViewBuilderType | null = null;

/**
 * Registers the builder that plays Rive refresh headers (`wrapBuilder` of a global @Builder taking the scroll view
 * model and the role); null removes it. Register the Rive engine with `CYLAnimatedItemEngines.register('Rive')` too.
 */
export function CYLRefreshRiveRegisterViewBuilder(builder: CYLRefreshRiveViewBuilderType | null): void {
  cylRefreshRiveViewBuilderValue = builder;
}

/**
 * The builder registered with CYLRefreshRiveRegisterViewBuilder, or null.
 */
export function CYLRefreshRiveViewBuilder(): CYLRefreshRiveViewBuilderType | null {
  return cylRefreshRiveViewBuilderValue;
}

/**
 * Whether a Rive header of `c` can be drawn: a builder is registered. Without one, debug builds log once which
 * package to add (CYLAnimatedItemEngines.warnMissingEngine), and the header stays empty.
 */
export function cylRefreshRiveCanDraw(c: CYLRefreshComponentModel | null): boolean {
  if (cylRefreshRiveViewBuilderValue !== null) {
    return true;
  }
  const header = cylRefreshRiveHeader(c);
  if (header !== null && header.riveStyle !== null) {
    CYLAnimatedItemEngines.warnMissingEngine((header.riveStyle as CYLRefreshRiveStyle).fileURL);
  }
  return false;
}
