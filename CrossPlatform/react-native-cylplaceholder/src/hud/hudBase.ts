import type { CYLPlaceholderComponent } from '../placeholder/components.ts';

/** The native half of the HUD: a method name with its argument map, and the tapped action names coming back. */
export interface CYLPlaceholderHUDBackend {
  /** Runs one `CYLPlaceholderHUDBridge` method of the native HUD. */
  call(method: string, args?: Record<string, unknown>): void;
  /** Listens to the action names of tapped HUD buttons; returns the function that stops listening. */
  onAction(listener: (action: string) => void): () => void;
}

/** A HUD component whose `action` is a function, as the Flutter package's `showComponents` takes it. */
export type CYLPlaceholderHUDComponent = Omit<CYLPlaceholderComponent, 'action'> & { action?: () => void };

/**
 * The platform-independent half of `CYLPlaceholderHUD`: the method names and arguments of the Flutter package's
 * `CYLPlaceholderHUD`, forwarded to a backend (the native HUD). It keeps no state of its own; the native HUD is the HUD. The
 * exported `CYLPlaceholderHUD` (from `react-native-cylplaceholder`) is this class with the React Native backend.
 */
export class CYLPlaceholderHUDBase {
  private readonly backend: CYLPlaceholderHUDBackend;
  private actions = new Map<string, () => void>();
  private stopListening: (() => void) | undefined;

  constructor(backend: CYLPlaceholderHUDBackend) {
    this.backend = backend;
  }

  /** Shows a spinner (`show`). */
  show(): void {
    this.backend.call('show');
  }

  /** Shows a spinner with `status` (`showWithStatus`). */
  showWithStatus(status?: string): void {
    this.backend.call('showWithStatus', { status });
  }

  /** Shows a progress bar at `progress`, 0 to 1, with `status` (`showProgress`). */
  showProgress(progress: number, status?: string): void {
    this.backend.call('showProgress', { progress, status });
  }

  /** Changes the status text in place (`setStatus`). */
  setStatus(status?: string): void {
    this.backend.call('setStatus', { status });
  }

  /** Shows the info icon with `status`, then hides (`showInfoWithStatus`). */
  showInfoWithStatus(status?: string): void {
    this.backend.call('showInfoWithStatus', { status });
  }

  /** Shows the success icon with `status`, then hides (`showSuccessWithStatus`). */
  showSuccessWithStatus(status?: string): void {
    this.backend.call('showSuccessWithStatus', { status });
  }

  /** Shows the error icon with `status`, then hides (`showErrorWithStatus`). */
  showErrorWithStatus(status?: string): void {
    this.backend.call('showErrorWithStatus', { status });
  }

  /** Shows your components until `dismiss`; a component's `action` runs when its button is tapped (`showComponents`). */
  showComponents(components: CYLPlaceholderHUDComponent[]): void {
    this.actions.clear();
    this.stopListening ??= this.backend.onAction((name) => this.actions.get(name)?.());
    const maps = components.map((component, index) => {
      const { action, ...rest } = component;
      if (action === undefined) return rest;
      const name = `component-${index}`;
      this.actions.set(name, action);
      return { ...rest, action: name };
    });
    this.backend.call('showComponents', { components: maps });
  }

  /** Ends one `show`; the HUD hides once every one has ended (`popActivity`). */
  popActivity(): void {
    this.backend.call('popActivity');
  }

  /** Hides at once (`dismiss`). */
  dismiss(): void {
    this.backend.call('dismiss');
  }

  /** Hides, then calls `completion` (`dismissWithCompletion`). */
  dismissWithCompletion(completion?: () => void): void {
    this.dismissWithDelay(0, completion);
  }

  /** Hides after `delay` seconds, then calls `completion` (`dismissWithDelay`). */
  dismissWithDelay(delay: number, completion?: () => void): void {
    this.backend.call('dismissWithDelay', { delay });
    if (completion !== undefined) setTimeout(completion, Math.max(0, delay) * 1000);
  }

  /** Stops listening to the native HUD's actions; call it when the HUD is no longer used. */
  dispose(): void {
    this.stopListening?.();
    this.stopListening = undefined;
    this.actions.clear();
  }
}
