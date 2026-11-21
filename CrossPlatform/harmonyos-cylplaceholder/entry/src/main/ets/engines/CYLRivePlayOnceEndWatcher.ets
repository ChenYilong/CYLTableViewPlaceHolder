// The example's engine helper (no @ohos/rive import, so the local unit tests run it on the host).
// Decides when a play-once Rive pass has ended: @ohos/rive 1.0.4 reports no end the engine can rely on (its listener
// also fires for the engine's own stop and pause), so once the pass's last input change is made, the watcher polls
// RiveAnimationView.isPlaying(); false means a ONESHOT named animation stopped or the state machine settled. The Rive
// engine (CYLRiveAnimationContentView) then calls didEnd(), which drives CYLAnimatedItemView's
// showsImageWhenAnimationEnds (the Success scenario's check mark).

/**
 * How often the watcher asks whether the file still plays, in milliseconds.
 */
export const CYL_RIVE_END_POLL_MS: number = 100;

/**
 * Schedules a callback after a delay and returns an id for the canceller (setTimeout by default).
 */
export type CYLRiveEndScheduler = (callback: () => void, delayMs: number) => number;

/**
 * Cancels a callback scheduled by a CYLRiveEndScheduler (clearTimeout by default).
 */
export type CYLRiveEndCanceller = (id: number) => void;

/**
 * Reports once when a play-once Rive pass stops playing: arm() after the pass's last input change, cancel() when the
 * engine stops, shows the last frame, plays again, loops or detaches.
 */
export class CYLRivePlayOnceEndWatcher {
  private readonly isPlaying: () => boolean;
  private readonly onEnd: () => void;
  private readonly schedule: CYLRiveEndScheduler;
  private readonly cancelScheduled: CYLRiveEndCanceller;
  private timer: number = -1;
  private generation: number = 0;

  constructor(isPlaying: () => boolean, onEnd: () => void,
    schedule: CYLRiveEndScheduler = (callback: () => void, delayMs: number): number => setTimeout(callback, delayMs),
    cancelScheduled: CYLRiveEndCanceller = (id: number): void => clearTimeout(id)) {
    this.isPlaying = isPlaying;
    this.onEnd = onEnd;
    this.schedule = schedule;
    this.cancelScheduled = cancelScheduled;
  }

  /**
   * Whether an end is being waited for.
   */
  get isArmed(): boolean {
    return this.timer >= 0;
  }

  /**
   * Starts waiting for the end (a previous wait is dropped); the first check is one poll interval later, so the
   * renderer has advanced the pass at least once.
   */
  arm(): void {
    this.cancel();
    const generation = this.generation;
    this.poll(generation);
  }

  /**
   * Stops waiting: no end is reported for the current pass.
   */
  cancel(): void {
    this.generation++;
    if (this.timer >= 0) {
      this.cancelScheduled(this.timer);
      this.timer = -1;
    }
  }

  private poll(generation: number): void {
    this.timer = this.schedule(() => {
      if (generation !== this.generation) {
        return;
      }
      this.timer = -1;
      if (this.isPlaying()) {
        this.poll(generation);
        return;
      }
      this.generation++;
      this.onEnd();
    }, CYL_RIVE_END_POLL_MS);
  }
}
