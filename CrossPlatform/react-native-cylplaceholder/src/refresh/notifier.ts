/** Called when a `CYLRefreshNotifier` changes. */
export type CYLRefreshListener = () => void;

/**
 * The small subscribe / notify base of the long-lived refresh objects (the Flutter package's `ChangeNotifier`). `version`
 * grows with every notification, so a React hook can read it as a snapshot (`useSyncExternalStore`).
 */
export class CYLRefreshNotifier {
  private listeners: Set<CYLRefreshListener> = new Set();
  private changeCount: number = 0;

  /** Grows by one with every notification. */
  get version(): number {
    return this.changeCount;
  }

  /** Calls `listener` on every change; the returned function stops it. */
  subscribe(listener: CYLRefreshListener): () => void {
    this.listeners.add(listener);
    return () => {
      this.listeners.delete(listener);
    };
  }

  /** Increments `version` and calls every listener. */
  protected notifyListeners(): void {
    this.changeCount += 1;
    for (const listener of [...this.listeners]) {
      listener();
    }
  }

  /** Drops every listener. */
  dispose(): void {
    this.listeners.clear();
  }
}
