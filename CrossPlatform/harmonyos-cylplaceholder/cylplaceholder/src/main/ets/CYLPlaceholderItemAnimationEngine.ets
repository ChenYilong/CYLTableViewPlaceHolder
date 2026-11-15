// iOS CYLPlaceholderItemAnimationEngine (internal) and the engines' +load: importing this module (Index.ets does)
// registers the GIF, PAG and Rive animators and the Lottie animator (fallback priority) in the shared registry. It is
// kept out of CYLPlaceholderView so the core files load without the engines' native libraries (host-run unit tests).
import { CYLPlaceholderItemAnimatorRegistering, CYLPlaceholderItemAnimatorRegistry } from './CYLPlaceholderAnimation';
import { CYLGIFPlaceholderItemAnimator } from './CYLGIFPlaceholderItemAnimator';
import { CYLLottiePlaceholderItemAnimator } from './CYLLottiePlaceholderItemAnimator';
import { CYLPAGPlaceholderItemAnimator } from './CYLPAGPlaceholderItemAnimator';
import { CYLRivePlaceholderItemAnimator } from './CYLRivePlaceholderItemAnimator';

export class CYLPlaceholderItemAnimationEngine {
  /** Registers the bundled engines in registry (the shared registry by default); registering again replaces them. */
  static registerDefaultAnimators(registry: CYLPlaceholderItemAnimatorRegistering | null = null): void {
    const target: CYLPlaceholderItemAnimatorRegistering = registry !== null ? registry :
      CYLPlaceholderItemAnimatorRegistry.sharedRegistry();
    target.registerAnimator(CYLGIFPlaceholderItemAnimator.animator);
    target.registerAnimator(new CYLPAGPlaceholderItemAnimator());
    target.registerAnimator(CYLRivePlaceholderItemAnimator.animator);
    target.registerAnimator(new CYLLottiePlaceholderItemAnimator());
  }
}

CYLPlaceholderItemAnimationEngine.registerDefaultAnimators();
