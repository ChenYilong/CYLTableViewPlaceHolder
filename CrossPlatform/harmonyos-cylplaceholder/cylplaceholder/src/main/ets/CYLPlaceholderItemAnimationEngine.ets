// iOS CYLPlaceholderItemAnimationEngine (internal) and the engines' +load. Importing this module (Index.ets does)
// registers the one engine the core ships, GIF, which plays with the system's ImageKit and ImageAnimator and needs
// no animation library. The core depends on no animation library (CYLTabBarController's CYLAnimatedItem rule): Lottie,
// PAG and Rive are the app's engines, which it registers itself, as the example does in
// entry/src/main/ets/engines/ExampleAnimationEngines.ets:
//
//   CYLAnimatedItemEngines.register('Lottie');
//   CYLPlaceholderItemAnimatorRegistry.registerAnimator(new CYLLottiePlaceholderItemAnimator());
//
// A file whose engine nobody registered shows the static image, else CYLAnimatedItemView's placeholder, and debug
// builds log once which package to add. Kept out of CYLPlaceholderView so the core files load without engines
// (host-run unit tests).
import { CYLAnimatedItemEngines } from 'cylanimateditem';
import { CYLPlaceholderItemAnimatorRegistering, CYLPlaceholderItemAnimatorRegistry } from './CYLPlaceholderAnimation';
import { CYLGIFPlaceholderItemAnimator } from './CYLGIFPlaceholderItemAnimator';

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
    CYLAnimatedItemEngines.register('GIF');
    target.registerAnimator(CYLGIFPlaceholderItemAnimator.animator);
  }
}

CYLPlaceholderItemAnimationEngine.registerDefaultAnimators();
