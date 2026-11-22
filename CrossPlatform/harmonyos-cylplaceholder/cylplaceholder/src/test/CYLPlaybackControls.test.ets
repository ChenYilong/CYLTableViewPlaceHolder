// Unit tests for the playback controls the examples use (docs/Example-Animation-Playback.md): the PAG speed driver,
// GIF frame durations at a speed, and the placeholder's live repeat count.
import { describe, expect, it } from '@ohos/hypium';
import { CYLPlaceholderViewModel } from '../main/ets/CYLPlaceholderView';
import { CYLRefreshIconViewModel } from '../main/ets/refresh/CYLRefreshIconView';
import { CYLRefreshFrameDuration } from '../main/ets/refresh/CYLRefreshView';

export default function playbackControlsTest() {
  describe('CYLPlaybackControls', () => {
    it('placeholderRepeatCountIsClampedAndKept', 0, () => {
      const m = new CYLPlaceholderViewModel();
      expect(m.animationRepeatCount).assertEqual(1);
      m.animationRepeatCount = 0;
      expect(m.animationRepeatCount).assertEqual(0);
      m.animationRepeatCount = -3;
      expect(m.animationRepeatCount).assertEqual(0);
      m.animationRepeatCount = 2.7;
      expect(m.animationRepeatCount).assertEqual(2);
    });

    it('refreshIconSpeedAndLoopDefaultsAndValidation', 0, () => {
      const icon = new CYLRefreshIconViewModel();
      expect(icon.animationSpeed).assertEqual(1);
      expect(icon.loopsWhilePlaying).assertTrue();
      icon.animationSpeed = 2.5;
      expect(icon.animationSpeed).assertEqual(2.5);
      icon.animationSpeed = 0;
      icon.animationSpeed = -1;
      expect(icon.animationSpeed).assertEqual(2.5);
      icon.loopsWhilePlaying = false;
      expect(icon.loopsWhilePlaying).assertFalse();
      icon.replayAnimation();
    });

    it('refreshFrameDurationFollowsUIImageView', 0, () => {
      expect(CYLRefreshFrameDuration(1, 10)).assertEqual(100);
      expect(Math.abs(CYLRefreshFrameDuration(0, 12) - 1000 / 30) < 1e-9).assertTrue();
      expect(CYLRefreshFrameDuration(0.1, 100)).assertEqual(16);
      expect(CYLRefreshFrameDuration(1, 0)).assertEqual(100);
    });

  });
}
