// The HarmonyOS counterpart of iOS CYLPlaceholderResourceReporter and android/placeholder's
// CYLPlaceholderResourceMonitor (docs/Status-Bar.md, "资源缺失 / Missing resource"): an animation file that is missing is
// named in the page's red status bar. The animation engine swallows the error, so the core reports where it resolves
// the animation path (CYLPlaceholderViewModel.setAnimationFile / cyl_attachAnimation) and when a player fails.
//
// The shared contract of every platform:
//   - a resource is reported with its short name (the last path segment: "asset:Folder/home.pag" -> "home.pag") and a
//     short English reason ("file not found", "unreadable"; "no runtime" belongs to the engine) and counted once,
//     whoever reports it;
//   - the text is `Missing resource: x (reason)` for one resource, `Missing resources: first +N more` for several, so
//     a page has one bar however many files are missing (localized keys `resource_missing` / `resources_missing`);
//   - a resource that loads later, or a source (a view) that goes away, clears its reports.
// CYLPlaceholderStatusController.cyl_showsMissingResources shows the text in the bar, the network text first.
//
// A development aid: the guard `CYLPlaceholderResourceReporter.enabled` is `BuildProfile.DEBUG`, fixed when the app is
// built, so a release build neither reports nor checks files for it (iOS `#if DEBUG`, Android `BuildConfig.DEBUG`).
import BuildProfile from '../../../BuildProfile';
import { CYLPlaceholderLocalization } from './CYLPlaceholderLocalization';

/** Runs, in the main thread, for a resource that is reported for the first time (iOS `onResourceMissing`). */
export type CYLPlaceholderResourceMissingHandler = (resource: string, reason: string) => void;

/** Told that the list of missing resources changed (a resource was reported or cleared). */
export type CYLPlaceholderResourceObserver = (reporter: CYLPlaceholderResourceReporter) => void;

class CYLPlaceholderMissingResource {
  resource: string;
  reason: string;
  sources: Object[];

  constructor(resource: string, reason: string, source: Object) {
    this.resource = resource;
    this.reason = reason;
    this.sources = [source];
  }
}

export class CYLPlaceholderResourceReporter {
  private static sharedValue: CYLPlaceholderResourceReporter | null = null;
  private missing: CYLPlaceholderMissingResource[] = [];
  private observers: CYLPlaceholderResourceObserver[] = [];

  /**
   * Whether the red bar's logic runs: `BuildProfile.DEBUG`, decided at build time (false in a release build, where
   * report() does nothing and the core skips its file checks). Tests set it to check both states.
   */
  static enabled: boolean = BuildProfile.DEBUG;

  /** Told about every resource reported for the first time; null for none. */
  onResourceMissing: CYLPlaceholderResourceMissingHandler | null = null;

  /** The reporter the core reports to (tests make their own with `new CYLPlaceholderResourceReporter()`). */
  static get sharedReporter(): CYLPlaceholderResourceReporter {
    if (CYLPlaceholderResourceReporter.sharedValue === null) {
      CYLPlaceholderResourceReporter.sharedValue = new CYLPlaceholderResourceReporter();
    }
    return CYLPlaceholderResourceReporter.sharedValue;
  }

  /** The last path segment of a resource, without a query or fragment: "asset:Folder/home.pag#a=b" -> "home.pag". */
  static shortName(resource: string): string {
    let name = resource;
    const hash = name.indexOf('#');
    if (hash >= 0) {
      name = name.substring(0, hash);
    }
    const query = name.indexOf('?');
    if (query >= 0) {
      name = name.substring(0, query);
    }
    const slash = Math.max(name.lastIndexOf('/'), name.lastIndexOf('\\'));
    if (slash >= 0 && slash < name.length - 1) {
      name = name.substring(slash + 1);
    }
    const colon = name.indexOf(':');
    if (colon >= 0 && colon < name.length - 1) {
      name = name.substring(colon + 1);
    }
    return name;
  }

  /**
   * Fills `%s`, `%1$s` and `%2$d` style placeholders in order, as the generated string tables spell them (Java style).
   */
  static format(template: string, args: string[]): string {
    let next = 0;
    return template.replace(/%(?:(\d+)\$)?[sd]/g, (match: string, index: string | undefined): string => {
      const position = index !== undefined && index.length > 0 ? parseInt(index) - 1 : next++;
      return position >= 0 && position < args.length ? args[position] : '';
    });
  }

  /**
   * Reports a missing resource, with `source` the view or object that found it. true when it is new: a resource is
   * counted once, whoever reports it (a second report only adds its source).
   */
  report(resource: string, reason: string, source: Object): boolean {
    if (!CYLPlaceholderResourceReporter.enabled) {
      return false;
    }
    const name = CYLPlaceholderResourceReporter.shortName(resource);
    if (name.length === 0) {
      return false;
    }
    for (const entry of this.missing) {
      if (entry.resource === name) {
        if (entry.sources.indexOf(source) < 0) {
          entry.sources.push(source);
        }
        return false;
      }
    }
    this.missing.push(new CYLPlaceholderMissingResource(name, reason, source));
    const handler = this.onResourceMissing;
    if (handler !== null) {
      handler(name, reason);
    }
    this.notify();
    return true;
  }

  /** The resource loads (or is no longer used) from `source`: its report from that source is cleared. */
  resolve(resource: string, source: Object): void {
    const name = CYLPlaceholderResourceReporter.shortName(resource);
    let changed = false;
    this.missing = this.missing.filter((entry: CYLPlaceholderMissingResource): boolean => {
      if (entry.resource !== name) {
        return true;
      }
      const index = entry.sources.indexOf(source);
      if (index < 0) {
        return true;
      }
      entry.sources.splice(index, 1);
      if (entry.sources.length === 0) {
        changed = true;
        return false;
      }
      return true;
    });
    if (changed) {
      this.notify();
    }
  }

  /** The source goes away (its page or view is gone): every report only it made is cleared. */
  removeSource(source: Object): void {
    let changed = false;
    this.missing = this.missing.filter((entry: CYLPlaceholderMissingResource): boolean => {
      const index = entry.sources.indexOf(source);
      if (index >= 0) {
        entry.sources.splice(index, 1);
      }
      if (entry.sources.length === 0) {
        changed = true;
        return false;
      }
      return true;
    });
    if (changed) {
      this.notify();
    }
  }

  /** Clears every report. */
  reset(): void {
    if (this.missing.length === 0) {
      return;
    }
    this.missing = [];
    this.notify();
  }

  /** The short names of the missing resources, in the order they were reported. */
  get missingResourceNames(): string[] {
    return this.missing.map((entry: CYLPlaceholderMissingResource): string => entry.resource);
  }

  /**
   * The red bar's text, localized: `Missing resource: x (reason)` for one resource, `Missing resources: first +N more`
   * for several; null when nothing is missing.
   */
  get text(): string | null {
    if (this.missing.length === 0) {
      return null;
    }
    const first = this.missing[0];
    if (this.missing.length === 1) {
      const template = CYLPlaceholderLocalization.localizedStringForKey('resource_missing', null);
      return CYLPlaceholderResourceReporter.format(template, [first.resource, first.reason]);
    }
    const template = CYLPlaceholderLocalization.localizedStringForKey('resources_missing', null);
    return CYLPlaceholderResourceReporter.format(template, [first.resource, String(this.missing.length - 1)]);
  }

  addObserver(observer: CYLPlaceholderResourceObserver): void {
    if (this.observers.indexOf(observer) < 0) {
      this.observers.push(observer);
    }
  }

  removeObserver(observer: CYLPlaceholderResourceObserver): void {
    const index = this.observers.indexOf(observer);
    if (index >= 0) {
      this.observers.splice(index, 1);
    }
  }

  private notify(): void {
    this.observers.slice().forEach((observer: CYLPlaceholderResourceObserver): void => {
      observer(this);
    });
  }
}
