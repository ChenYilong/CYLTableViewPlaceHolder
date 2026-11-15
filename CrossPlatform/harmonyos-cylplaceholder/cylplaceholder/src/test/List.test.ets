import placeholderCoreTest from './CYLPlaceholderCore.test';
import placeholderHUDStatusTest from './CYLPlaceholderHUDStatus.test';
import refreshCoreTest from './CYLRefreshCore.test';
import placeholderAnimationTest from './CYLPlaceholderAnimation.test';
import refreshDrawnTest from './CYLRefreshDrawn.test';
import refreshIconsTest from './CYLRefreshIcons.test';
import refreshRiveTest from './CYLRefreshRive.test';
import swiftAPITest from './CYLSwiftAPI.test';
import playbackControlsTest from './CYLPlaybackControls.test';

export default function testsuite() {
  placeholderCoreTest();
  placeholderHUDStatusTest();
  refreshCoreTest();
  placeholderAnimationTest();
  refreshDrawnTest();
  refreshIconsTest();
  refreshRiveTest();
  swiftAPITest();
  playbackControlsTest();
}
