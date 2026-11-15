import placeholderCoreTest from './CYLPlaceholderCore.test';
import placeholderHUDStatusTest from './CYLPlaceholderHUDStatus.test';
import refreshCoreTest from './CYLRefreshCore.test';
import refreshDrawnTest from './CYLRefreshDrawn.test';
import refreshIconsTest from './CYLRefreshIcons.test';
import refreshRiveTest from './CYLRefreshRive.test';

export default function testsuite() {
  placeholderCoreTest();
  placeholderHUDStatusTest();
  refreshCoreTest();
  refreshDrawnTest();
  refreshIconsTest();
  refreshRiveTest();
}
