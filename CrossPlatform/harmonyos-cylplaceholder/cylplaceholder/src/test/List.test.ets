import placeholderCoreTest from './CYLPlaceholderCore.test';
import placeholderHUDStatusTest from './CYLPlaceholderHUDStatus.test';
import refreshCoreTest from './CYLRefreshCore.test';
import refreshDrawnTest from './CYLRefreshDrawn.test';
import refreshIconsTest from './CYLRefreshIcons.test';
import refreshRiveTest from './CYLRefreshRive.test';
import swiftAPITest from './CYLSwiftAPI.test';
import playbackControlsTest from './CYLPlaybackControls.test';
import binaryPropertyListTest from './CYLBinaryPropertyList.test';

export default function testsuite() {
  placeholderCoreTest();
  placeholderHUDStatusTest();
  refreshCoreTest();
  refreshDrawnTest();
  refreshIconsTest();
  refreshRiveTest();
  swiftAPITest();
  playbackControlsTest();
  binaryPropertyListTest();
}
