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
import { cylRefreshSceneViewBuilder, cylRefreshSetRiveRuns } from './CYLRefreshSVGASceneView';

/**
 * Registers the example's Lottie, PAG, SVGA and Rive engines (types, animators and the Rive refresh header's view).
 * Registering again replaces them. `context` lets a debug build installed with CYLTabBarController's x86_64 debug engine
 * kit (`cylanimateditem/tools/cyl_hap_x86_64.py install`) play Rive on the x86_64 emulator.
 */
export function ExampleRegisterAnimationEngines(context?: Context): void {
  // Owner's Plan 1 (instructions.md, "Rive and PAG: tests that only run on arm64"): debug builds only, behind
  // CYLTabBarController's debug guard; release builds and HAPs without the kit change nothing.
  CYLAnimatedItemEngines.loadX86_64DebugEngines(context);
  CYLAnimatedItemEngines.register('Lottie');
  CYLAnimatedItemEngines.register('PAG');
  // SVGA: CYLTabBarController's own decoder and renderer on a Canvas (no native library), so on every ABI.
  CYLAnimatedItemEngines.register('SVGA');
  // FIX: issue E15: Rive only where @ohos/rive has its native library (arm64-v8a, or x86_64 with the debug engine kit);
  // elsewhere Rive files show the static image or the placeholder, as with a type that is left out.
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
  // The scene headers' view: SVGA files on every ABI (CYLRefreshSVGASceneView), Rive files where Rive runs.
  cylRefreshSetRiveRuns(riveSupported);
  CYLRefreshRiveRegisterViewBuilder(wrapBuilder(cylRefreshSceneViewBuilder));
}
