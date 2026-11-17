// The playback math of the PAG engine (iOS CYLPAGPlaceholderItemAnimator's driven play), kept in the core because it
// depends on no PAG library: the engine itself (@tencent/libpag) is the app's (the example's
// engines/CYLPAGPlaceholderItemAnimator.ets), and the host-run unit tests check this function.

/**
 * The next state of a driven PAG play.
 */
export interface CYLPAGDrivenStep {
  progress: number;
  plays: number;
  finished: boolean;
}

/**
 * Advances a driven play by `elapsed` ms at `speed` for a file of `duration` ms: past the end it wraps while plays
 * remain (repeatCount 0 loops forever, N plays N times), else it rests on the last frame and reports finished.
 */
export function CYLPAGDrivenProgress(progress: number, plays: number, elapsed: number, duration: number,
  speed: number, repeatCount: number): CYLPAGDrivenStep {
  if (!(duration > 0) || !(elapsed > 0)) {
    return { progress: progress, plays: plays, finished: false };
  }
  let next = progress + elapsed * speed / duration;
  let done = plays;
  while (next >= 1) {
    done += 1;
    if (repeatCount !== 0 && done >= repeatCount) {
      return { progress: 1, plays: done, finished: true };
    }
    next -= 1;
  }
  return { progress: next, plays: done, finished: false };
}
