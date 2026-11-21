// Local (host) unit tests of the example Rive engine's end detection (CYLRivePlayOnceEndWatcher) with a manual clock.
import { describe, expect, it } from '@ohos/hypium';
import { CYL_RIVE_END_POLL_MS, CYLRivePlayOnceEndWatcher } from '../main/ets/engines/CYLRivePlayOnceEndWatcher';

class ManualClock {
  private nextId: number = 1;
  private tasks: Map<number, () => void> = new Map<number, () => void>();
  delays: number[] = [];

  schedule(callback: () => void, delayMs: number): number {
    const id = this.nextId++;
    this.tasks.set(id, callback);
    this.delays.push(delayMs);
    return id;
  }

  cancel(id: number): void {
    this.tasks.delete(id);
  }

  get pending(): number {
    return this.tasks.size;
  }

  /** Runs the callbacks due now (one poll interval). */
  tick(): void {
    const due = Array.from(this.tasks.entries());
    this.tasks.clear();
    due.forEach((entry: [number, () => void]) => entry[1]());
  }
}

class Fixture {
  clock: ManualClock = new ManualClock();
  playing: boolean = true;
  ends: number = 0;
  watcher: CYLRivePlayOnceEndWatcher = new CYLRivePlayOnceEndWatcher(() => this.playing, () => {
    this.ends++;
  }, (callback: () => void, delayMs: number) => this.clock.schedule(callback, delayMs),
    (id: number) => this.clock.cancel(id));
}

export default function riveEndWatcherTest() {
  describe('CYLRivePlayOnceEndWatcher', () => {
    it('reportsOnceWhenThePassStopsPlaying', 0, () => {
      const f = new Fixture();
      f.watcher.arm();
      expect(f.watcher.isArmed).assertTrue();
      f.clock.tick();
      f.clock.tick();
      expect(f.ends).assertEqual(0);
      f.playing = false;
      f.clock.tick();
      expect(f.ends).assertEqual(1);
      expect(f.watcher.isArmed).assertFalse();
      expect(f.clock.pending).assertEqual(0);
      f.clock.tick();
      expect(f.ends).assertEqual(1);
      expect(f.clock.delays.every((d: number) => d === CYL_RIVE_END_POLL_MS)).assertTrue();
    });

    it('checksOnlyAfterOnePollInterval', 0, () => {
      const f = new Fixture();
      f.playing = false;
      f.watcher.arm();
      expect(f.ends).assertEqual(0);
      f.clock.tick();
      expect(f.ends).assertEqual(1);
    });

    it('cancelReportsNothing', 0, () => {
      const f = new Fixture();
      f.watcher.arm();
      f.watcher.cancel();
      f.playing = false;
      f.clock.tick();
      expect(f.ends).assertEqual(0);
      expect(f.watcher.isArmed).assertFalse();
      expect(f.clock.pending).assertEqual(0);
    });

    it('armingAgainDropsThePreviousWait', 0, () => {
      const f = new Fixture();
      f.watcher.arm();
      f.watcher.arm();
      expect(f.clock.pending).assertEqual(1);
      f.playing = false;
      f.clock.tick();
      expect(f.ends).assertEqual(1);
    });

    it('aFileThatKeepsPlayingNeverEnds', 0, () => {
      const f = new Fixture();
      f.watcher.arm();
      for (let i = 0; i < 50; i++) {
        f.clock.tick();
      }
      expect(f.ends).assertEqual(0);
      expect(f.watcher.isArmed).assertTrue();
    });
  });
}
