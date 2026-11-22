// The animation engines of the example. The cylplaceholder core depends on no animation library (CYLTabBarController's
// CYLAnimatedItem rule, docs/Animated-Item.md upstream); the engines that play the files are CYLTabBarController's
// (cylanimateditem: GIF and SVGA; the modules cylanimateditem_lottie, cylanimateditem_pag and cylanimateditemrive: Lottie,
// PAG and Rive, the libraries the example adds in entry/oh-package.json5), shared by every app that shows
// CYLAnimatedItemView, so their fixes reach every app. At launch (EntryAbility) the example registers:
//   1. each engine (`CYLAnimatedItemLottie.register()`, ...), so CYLAnimatedItemView plays the type;
//   2. each type's placeholder animator (`CYLAnimatedItemEnginePlaceholderAnimator.registerForType`), which hosts the
//      engine view in CYLPlaceholderView's animation slot and maps its player (play, last frame, progress, speed, repeat
//      counts, end, colors);
//   3. the scene headers' view (CYLRefreshSVGASceneView: SVGA on every ABI, Rive where Rive runs).
// A type left out shows the static image (or CYLAnimatedItemView's placeholder).
import { CYLAnimatedItemEngines, CYLAnimatedItemGIF, CYLAnimatedItemSVGA } from 'cylanimateditem';
import { CYLAnimatedItemLottie } from 'cylanimateditem_lottie';
import { CYLAnimatedItemPAG } from 'cylanimateditem_pag';
import { CYLAnimatedItemRive, cylRiveIsSupported } from 'cylanimateditemrive';
import { CYLAnimatedItemEnginePlaceholderAnimator, CYLRefreshRiveRegisterViewBuilder } from 'cylplaceholder';
import { cylRefreshSceneViewBuilder, cylRefreshSetRiveRuns } from './CYLRefreshSVGASceneView';

/**
 * Registers CYLTabBarController's Lottie, PAG, SVGA, GIF and Rive engines with their placeholder animators, and the scene
 * headers' view. Registering again replaces them. `context` lets a debug build installed with CYLTabBarController's
 * x86_64 debug engine kit (`cylanimateditem/tools/cyl_hap_x86_64.py install`) play Rive and PAG on the x86_64 emulator.
 */
export function ExampleRegisterAnimationEngines(context?: Context): void {
  // Owner's Plan 1 (instructions.md, "Rive and PAG: tests that only run on arm64"): debug builds only, behind
  // CYLTabBarController's debug guard; release builds and HAPs without the kit change nothing.
  CYLAnimatedItemEngines.loadX86_64DebugEngines(context);
  CYLAnimatedItemGIF.register();
  CYLAnimatedItemSVGA.register();
  CYLAnimatedItemPAG.register();
  // Rive and PAG declare their native ABI (arm64-v8a): the placeholder animator claims their files only where the library
  // runs (FIX: issue E15), elsewhere they show the static image.
  CYLAnimatedItemRive.register();
  CYLAnimatedItemLottie.register();
  ['GIF', 'SVGA', 'PAG', 'Rive', 'Lottie'].forEach((type: string) => {
    CYLAnimatedItemEnginePlaceholderAnimator.registerForType(type);
  });
  cylRefreshSetRiveRuns(cylRiveIsSupported());
  CYLRefreshRiveRegisterViewBuilder(wrapBuilder(cylRefreshSceneViewBuilder));
}
