import placeholderCoreTest from './CYLPlaceholderCore.test';
import placeholderHUDStatusTest from './CYLPlaceholderHUDStatus.test';
import refreshCoreTest from './CYLRefreshCore.test';
import placeholderAnimationTest from './CYLPlaceholderAnimation.test';
import refreshDrawnTest from './CYLRefreshDrawn.test';

export default function testsuite() {
  placeholderCoreTest();
  placeholderHUDStatusTest();
  refreshCoreTest();
  placeholderAnimationTest();
  refreshDrawnTest();
}
