// iOS CYLPlaceholderItemAnimationEngine (internal) and the engines' +load. Importing this module (Index.ets does)
// registers the one engine the core ships, GIF: CYLTabBarController's CYLAnimatedItemGIF (cylanimateditem, system
// ImageKit, no animation library), played through CYLAnimatedItemEnginePlaceholderAnimator. The core depends on no animation library (CYLTabBarController's CYLAnimatedItem rule): Lottie,
// PAG and Rive are the app's engines, which it registers itself, as the example does in
// entry/src/main/ets/engines/ExampleAnimationEngines.ets:
//
//   CYLAnimatedItemLottie.register();                                     // cylanimateditem_lottie
//   CYLAnimatedItemEnginePlaceholderAnimator.registerForType('Lottie');
//
// A file whose engine nobody registered shows the static image, else CYLAnimatedItemView's placeholder, and debug
// builds log once which package to add. Kept out of CYLPlaceholderView so the core files load without engines
// (host-run unit tests).
import { CYLAnimatedItemGIF } from 'cylanimateditem';
import { CYLPlaceholderItemAnimatorRegistering, CYLPlaceholderItemAnimatorRegistry } from './CYLPlaceholderAnimation';
import { CYLAnimatedItemEnginePlaceholderAnimator } from './CYLAnimatedItemEnginePlaceholderAnimator';

/**
 * Registers the engines the core ships (GIF only; Lottie, PAG and Rive are the app's).
 */
export class CYLPlaceholderItemAnimationEngine {
  /**
   * Registers the bundled engines in registry (the shared registry by default) and their types with
   * CYLAnimatedItemEngines; registering again replaces them.
   */
  static registerDefaultAnimators(registry: CYLPlaceholderItemAnimatorRegistering | null = null): void {
    const target: CYLPlaceholderItemAnimatorRegistering = registry !== null ? registry :
      CYLPlaceholderItemAnimatorRegistry.sharedRegistry();
    CYLAnimatedItemGIF.register();
    CYLAnimatedItemEnginePlaceholderAnimator.registerForType('GIF', target);
  }
}

CYLPlaceholderItemAnimationEngine.registerDefaultAnimators();
