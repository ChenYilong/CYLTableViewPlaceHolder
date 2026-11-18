// The animation engines of the example. The cylplaceholder core depends on no animation library (CYLTabBarController's
// CYLAnimatedItem rule, docs/Animated-Item.md upstream): it ships only the GIF engine (system APIs), and an app adds the
// libraries it plays and registers them. The example plays Lottie (@ohos/lottie), PAG (@tencent/libpag) and Rive
// (@ohos/rive), so it depends on those packages (entry/oh-package.json5) and registers, at launch (EntryAbility):
//   1. each type with CYLAnimatedItemEngines, so CYLAnimatedItemView (the icon of every CYLPlaceholderView) plays it;
//   2. each engine's animator in the shared CYLPlaceholderItemAnimatorRegistry: it makes the animation views (each
//      carries the @Builder that draws it), which the core's animationBuilder draws inside CYLAnimatedItemView;
//   3. the Rive refresh header's view (CYLRefreshRiveView on @ohos/rive) with CYLRefreshRiveRegisterViewBuilder.
// A type left out shows the static image (or CYLAnimatedItemView's placeholder), and debug builds log once which
// package to add.
import { CYLAnimatedItemEngines } from 'cylanimateditem';
import { CYLPlaceholderItemAnimatorRegistry, CYLRefreshRiveRegisterViewBuilder } from 'cylplaceholder';
import { CYLLottiePlaceholderItemAnimator } from './CYLLottiePlaceholderItemAnimator';
import { CYLPAGPlaceholderItemAnimator } from './CYLPAGPlaceholderItemAnimator';
import { CYLSVGAPlaceholderItemAnimator } from './CYLSVGAPlaceholderItemAnimator';
import { CYLRivePlaceholderItemAnimator, cylRiveIsSupported } from './CYLRivePlaceholderItemAnimator';
import { cylRefreshRiveViewBuilder } from './CYLRefreshRiveView';

/**
 * Registers the example's Lottie, PAG, SVGA and Rive engines (types, animators and the Rive refresh header's view).
 * Registering again replaces them.
 */
export function ExampleRegisterAnimationEngines(): void {
  CYLAnimatedItemEngines.register('Lottie');
  CYLAnimatedItemEngines.register('PAG');
  // SVGA: CYLTabBarController's own decoder and renderer on a Canvas (no native library), so on every ABI.
  CYLAnimatedItemEngines.register('SVGA');
  // FIX: issue E15: Rive only where @ohos/rive has its native library (arm64-v8a); elsewhere Rive files show the
  // static image or the placeholder, as with a type that is left out.
  const riveSupported = cylRiveIsSupported();
  if (riveSupported) {
    CYLAnimatedItemEngines.register('Rive');
  }
  const registry = CYLPlaceholderItemAnimatorRegistry.sharedRegistry();
  registry.registerAnimator(new CYLPAGPlaceholderItemAnimator());
  registry.registerAnimator(new CYLSVGAPlaceholderItemAnimator());
  if (riveSupported) {
    registry.registerAnimator(CYLRivePlaceholderItemAnimator.animator);
  }
  // Lottie last, at the fallback priority (it also claims ".json").
  registry.registerAnimator(new CYLLottiePlaceholderItemAnimator());
  if (riveSupported) {
    CYLRefreshRiveRegisterViewBuilder(wrapBuilder(cylRefreshRiveViewBuilder));
  }
}
