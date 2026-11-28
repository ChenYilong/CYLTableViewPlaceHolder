import { CYLRefreshAutoFooter, CYLRefreshBackFooter, CYLRefreshHeader, type CYLRefreshComponent, type CYLRefreshComponentOptions } from './component.ts';
import { CYLRefreshPhase, CYLRefreshTitleState } from './refreshTypes.ts';

/** The texts of a classic component, one per `CYLRefreshTitleState`. */
export type CYLRefreshTitles = Partial<Record<CYLRefreshTitleState, string>>;

/** The classic header's default texts. */
export const CYLRefreshClassicHeaderTitles: CYLRefreshTitles = {
  pullToRefresh: 'Pull down to refresh',
  releaseToRefresh: 'Release to refresh',
  refreshing: 'Refreshing...',
  succeeded: 'Refresh complete',
  failed: 'Refresh failed',
};

/** The classic footers' default texts. */
export const CYLRefreshClassicFooterTitles: CYLRefreshTitles = {
  pullToRefresh: 'Pull up to load more',
  releaseToRefresh: 'Release to load more',
  refreshing: 'Loading...',
  succeeded: 'Load complete',
  failed: 'Load failed',
  noMoreData: 'No more data',
};

/** What the classic indicator shows for a component, shared by the three classic classes. */
export interface CYLRefreshClassic {
  /** Sets the text of `state`. */
  setTitle(text: string, state: CYLRefreshTitleState): void;
  /** The text of `state`: the one set, else the default, else an empty string. */
  titleForState(state: CYLRefreshTitleState): string;
  /** The text for the component's current phase. */
  readonly currentTitle: string;
  /** The second line (the last update time for a header), or null. */
  messageText(): string | null;
  /** The side length of the icon in points. */
  iconSize: number;
  /** The gap between the icon and the texts in points. */
  iconSpacing: number;
  /** True: the icon comes after the texts. */
  iconOnTrailingSide: boolean;
}

function titleFor(component: CYLRefreshComponent, own: CYLRefreshTitles, defaults: CYLRefreshTitles, state: CYLRefreshTitleState): string {
  return own[state] ?? defaults[state] ?? '';
}

function currentTitleFor(component: CYLRefreshComponent, lookup: (state: CYLRefreshTitleState) => string): string {
  if (component.isNoMoreData) {
    return lookup(CYLRefreshTitleState.noMoreData);
  }
  switch (component.phase) {
    case CYLRefreshPhase.idle:
    case CYLRefreshPhase.pullToRefresh:
      return lookup(CYLRefreshTitleState.pullToRefresh);
    case CYLRefreshPhase.releaseToRefresh:
      return lookup(CYLRefreshTitleState.releaseToRefresh);
    case CYLRefreshPhase.releasing:
    case CYLRefreshPhase.refreshing:
      return lookup(CYLRefreshTitleState.refreshing);
    default:
      return lookup(component.lastRefreshSucceeded ? CYLRefreshTitleState.succeeded : CYLRefreshTitleState.failed);
  }
}

/** The classic header: an arrow or spinner, a text per state and the last update time. */
export class CYLRefreshClassicHeader extends CYLRefreshHeader implements CYLRefreshClassic {
  /** The side length of the icon in points. */
  iconSize: number = 20;
  /** The gap between the icon and the texts in points. */
  iconSpacing: number = 12;
  /** True: the icon comes after the texts. */
  iconOnTrailingSide: boolean = false;
  /** False: no second line. */
  showsLastUpdatedTime: boolean;
  /** Replaces the second line's text; receives the last update time or null. */
  lastUpdatedTimeText: ((time: Date | null) => string) | null;
  /** Formats the last update time of the second line. */
  lastUpdatedTimeFormatter: ((time: Date) => string) | null;
  private titles: CYLRefreshTitles = {};

  /** Creates a classic header. */
  constructor(
    options: CYLRefreshComponentOptions & {
      resetsFooterAfterRefresh?: boolean;
      showsLastUpdatedTime?: boolean;
      lastUpdatedTimeText?: (time: Date | null) => string;
      lastUpdatedTimeFormatter?: (time: Date) => string;
    } = {}
  ) {
    super(options);
    this.showsLastUpdatedTime = options.showsLastUpdatedTime ?? true;
    this.lastUpdatedTimeText = options.lastUpdatedTimeText ?? null;
    this.lastUpdatedTimeFormatter = options.lastUpdatedTimeFormatter ?? null;
  }

  setTitle(text: string, state: CYLRefreshTitleState): void {
    this.titles[state] = text;
    this.notifyListeners();
  }

  titleForState(state: CYLRefreshTitleState): string {
    return titleFor(this, this.titles, CYLRefreshClassicHeaderTitles, state);
  }

  get currentTitle(): string {
    return currentTitleFor(this, (state) => this.titleForState(state));
  }

  messageText(): string | null {
    if (!this.showsLastUpdatedTime) {
      return null;
    }
    const time = this.lastUpdatedTime;
    if (this.lastUpdatedTimeText !== null) {
      return this.lastUpdatedTimeText(time);
    }
    if (time === null) {
      return 'Not updated yet';
    }
    if (this.lastUpdatedTimeFormatter !== null) {
      return this.lastUpdatedTimeFormatter(time);
    }
    const two = (value: number) => String(value).padStart(2, '0');
    return `Last updated: ${two(time.getHours())}:${two(time.getMinutes())}`;
  }
}

/** The classic footer: pulled up past the end of the content. */
export class CYLRefreshClassicFooter extends CYLRefreshBackFooter implements CYLRefreshClassic {
  /** The side length of the icon in points. */
  iconSize: number = 20;
  /** The gap between the icon and the texts in points. */
  iconSpacing: number = 12;
  /** True: the icon comes after the texts. */
  iconOnTrailingSide: boolean = false;
  private titles: CYLRefreshTitles = {};

  setTitle(text: string, state: CYLRefreshTitleState): void {
    this.titles[state] = text;
    this.notifyListeners();
  }

  titleForState(state: CYLRefreshTitleState): string {
    return titleFor(this, this.titles, CYLRefreshClassicFooterTitles, state);
  }

  get currentTitle(): string {
    return currentTitleFor(this, (state) => this.titleForState(state));
  }

  messageText(): string | null {
    return null;
  }
}

/** The classic auto footer: loads when the content scrolls near its end. */
export class CYLRefreshClassicAutoFooter extends CYLRefreshAutoFooter implements CYLRefreshClassic {
  /** The side length of the icon in points. */
  iconSize: number = 20;
  /** The gap between the icon and the texts in points. */
  iconSpacing: number = 12;
  /** True: the icon comes after the texts. */
  iconOnTrailingSide: boolean = false;
  private titles: CYLRefreshTitles = {};

  setTitle(text: string, state: CYLRefreshTitleState): void {
    this.titles[state] = text;
    this.notifyListeners();
  }

  titleForState(state: CYLRefreshTitleState): string {
    return titleFor(this, this.titles, CYLRefreshClassicFooterTitles, state);
  }

  get currentTitle(): string {
    return currentTitleFor(this, (state) => this.titleForState(state));
  }

  messageText(): string | null {
    return null;
  }
}

/** Whether `component` is one of the classic classes. */
export function isCYLRefreshClassic(component: CYLRefreshComponent): component is CYLRefreshComponent & CYLRefreshClassic {
  return (
    component instanceof CYLRefreshClassicHeader ||
    component instanceof CYLRefreshClassicFooter ||
    component instanceof CYLRefreshClassicAutoFooter
  );
}
