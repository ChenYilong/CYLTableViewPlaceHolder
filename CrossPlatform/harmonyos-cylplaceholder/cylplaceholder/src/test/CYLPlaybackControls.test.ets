// Unit tests for the playback controls the examples use (docs/Example-Animation-Playback.md): the PAG speed driver,
// GIF frame durations at a speed, and the placeholder's live repeat count.
import { describe, expect, it } from '@ohos/hypium';
import { CYLGIFCacheFileName, CYLGIFDrawMode, CYLGIFHasTrailer, CYLGIFScaledDuration } from '../main/ets/CYLGIFPlaceholderItemAnimator';
import { CYLPAGDrivenProgress } from '../main/ets/CYLPAGPlayback';
import { CYLPlaceholderViewModel } from '../main/ets/CYLPlaceholderView';
import { CYLRefreshIconViewModel } from '../main/ets/refresh/CYLRefreshIconView';
import { CYLRefreshFrameDuration } from '../main/ets/refresh/CYLRefreshView';

export default function playbackControlsTest() {
  describe('CYLPlaybackControls', () => {
    it('pagDrivenProgressAdvancesBySpeed', 0, () => {
      // 1000 ms file, 100 ms at 2x: a fifth of the way.
      const step = CYLPAGDrivenProgress(0, 0, 100, 1000, 2, 1);
      expect(Math.abs(step.progress - 0.2) < 1e-9).assertTrue();
      expect(step.finished).assertFalse();
      const slow = CYLPAGDrivenProgress(0, 0, 100, 1000, 0.5, 1);
      expect(Math.abs(slow.progress - 0.05) < 1e-9).assertTrue();
    });

    it('pagDrivenProgressStopsOnLastFrameWhenNotLooping', 0, () => {
      const step = CYLPAGDrivenProgress(0.9, 0, 300, 1000, 1, 1);
      expect(step.progress).assertEqual(1);
      expect(step.finished).assertTrue();
      expect(step.plays).assertEqual(1);
    });

    it('pagDrivenProgressWrapsWhileLoopingOrPlaysRemain', 0, () => {
      const loop = CYLPAGDrivenProgress(0.9, 0, 300, 1000, 1, 0);
      expect(Math.abs(loop.progress - 0.2) < 1e-9).assertTrue();
      expect(loop.finished).assertFalse();
      const twice = CYLPAGDrivenProgress(0.9, 0, 300, 1000, 1, 2);
      expect(twice.finished).assertFalse();
      expect(twice.plays).assertEqual(1);
      const done = CYLPAGDrivenProgress(0.9, 1, 300, 1000, 1, 2);
      expect(done.finished).assertTrue();
    });

    it('pagDrivenProgressIgnoresUnknownDuration', 0, () => {
      const step = CYLPAGDrivenProgress(0.3, 0, 100, 0, 1, 1);
      expect(step.progress).assertEqual(0.3);
      expect(step.finished).assertFalse();
    });

    it('gifFrameDurationsScaleWithSpeed', 0, () => {
      expect(CYLGIFScaledDuration(100, 1)).assertEqual(100);
      expect(CYLGIFScaledDuration(100, 2)).assertEqual(50);
      expect(CYLGIFScaledDuration(100, 0.25)).assertEqual(400);
      expect(CYLGIFScaledDuration(1, 3)).assertEqual(1);
      expect(CYLGIFScaledDuration(100, 0)).assertEqual(100);
    });

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

    it('gifFallbackCacheNameIsStableAndModesOrdered', 0, () => {
      const a = CYLGIFCacheFileName('cylplaceholder/animations/CYLPlaceholderNoFavorites.gif', 52969);
      expect(a).assertEqual(CYLGIFCacheFileName('cylplaceholder/animations/CYLPlaceholderNoFavorites.gif', 52969));
      expect(a.startsWith('cyl-gif-')).assertTrue();
      expect(a.endsWith('-52969.gif')).assertTrue();
      expect(a === CYLGIFCacheFileName('cylplaceholder/animations/Other.gif', 52969)).assertFalse();
      expect(CYLGIFDrawMode.Frames < CYLGIFDrawMode.FirstFrame).assertTrue();
      expect(CYLGIFDrawMode.FirstFrame < CYLGIFDrawMode.System).assertTrue();
      expect(CYLGIFDrawMode.System < CYLGIFDrawMode.Failed).assertTrue();
    });
    it('gifTrailerMarksAFileCutShort', 0, () => {
      // E12: a GIF without its trailer (0x3B) was cut short; its last decoded frame is a fragment.
      expect(CYLGIFHasTrailer(new Uint8Array([0x47, 0x49, 0x46, 0x3B]))).assertTrue();
      expect(CYLGIFHasTrailer(new Uint8Array([0x47, 0x49, 0x46, 0x2C]))).assertFalse();
      expect(CYLGIFHasTrailer(new Uint8Array([]))).assertFalse();
    });
  });
}
