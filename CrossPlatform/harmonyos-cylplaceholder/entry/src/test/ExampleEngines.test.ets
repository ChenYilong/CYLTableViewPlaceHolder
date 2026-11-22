// Local (host) unit tests of the example's engine set: every animation file the example bundles has a type that
// CYLTabBarController's engine registry knows (cylanimateditem: GIF, SVGA; the modules: Lottie, PAG, Rive).
import { describe, expect, it } from '@ohos/hypium';
import { cylAnimatedItemTypeOf } from 'cylanimateditem';

export default function exampleEnginesTest() {
  describe('ExampleEngines', () => {
    it('bundledExtensionsHaveEngineTypes', 0, () => {
      expect(cylAnimatedItemTypeOf('Animations/CYLPlaceholderLoading.json')).assertEqual('Lottie');
      expect(cylAnimatedItemTypeOf('Animations/CYLPlaceholderNoFavorites.pag')).assertEqual('PAG');
      expect(cylAnimatedItemTypeOf('Animations/CYLPlaceholderSuccess.riv#artboard=Main')).assertEqual('Rive');
      expect(cylAnimatedItemTypeOf('Animations/CYLScenarioExampleRefresh.svga')).assertEqual('SVGA');
      expect(cylAnimatedItemTypeOf('Animations/CYLRefreshRing.gif')).assertEqual('GIF');
    });
  });
}
