import type { CYLRefreshFooter, CYLRefreshHeader } from './component.ts';
import { CYLRefreshNotifier } from './notifier.ts';

/** What a page load reports besides its items. */
export interface CYLRefreshPagingResult {
  /** The total number of items, when the server says it. */
  total?: number;
  /** The total number of pages, when the server says it. */
  totalPage?: number;
  /** A failure: the page is not applied and the component ends with failure. */
  error?: unknown;
}

/** Reports a loaded page: `items` is null on failure. */
export type CYLRefreshPagingCompletion<T> = (items: T[] | null, result?: CYLRefreshPagingResult) => void;

/** Loads page number `page`; call `completion` exactly once. */
export type CYLRefreshPagingLoader<T> = (page: number, completion: CYLRefreshPagingCompletion<T>) => void;

/**
 * Pages a list through a header and a footer, like the Flutter package's `CYLRefreshPaging`: the header loads the first
 * page, the footer the next one, and both are ended for you. Hand `items` to the list and rebuild on change.
 */
export class CYLRefreshPaging<T> extends CYLRefreshNotifier {
  /** The header that loads the first page, or undefined. */
  readonly header: CYLRefreshHeader | undefined;
  /** The footer that loads the next page, or undefined. */
  readonly footer: CYLRefreshFooter | undefined;
  /** Loads a page. */
  readonly loader: CYLRefreshPagingLoader<T>;
  /** The number of the first page, 1 by default. */
  firstPage: number = 1;
  /** True: refreshing the first page resets the footer's "no more data". */
  resetsFooterAfterRefresh: boolean = true;
  /** Called after a page was applied. */
  itemsDidChange: ((paging: CYLRefreshPaging<T>) => void) | null = null;

  private currentItems: T[] | null = null;
  private currentPage: number = 0;
  private currentTotal: number = 0;
  private currentTotalPage: number = 0;
  private noMore: boolean = false;
  private loading: boolean = false;
  private currentError: unknown = null;

  /** Creates a pager; the header's and footer's `refreshingHandler` are set to load pages. */
  constructor(options: { header?: CYLRefreshHeader; footer?: CYLRefreshFooter; loader: CYLRefreshPagingLoader<T> }) {
    super();
    this.header = options.header;
    this.footer = options.footer;
    this.loader = options.loader;
    if (this.header !== undefined) {
      this.header.refreshingHandler = () => this.load(this.firstPage);
    }
    if (this.footer !== undefined) {
      this.footer.refreshingHandler = () => this.load(this.currentPage + 1);
    }
  }

  /** The loaded items, or null before the first page arrived. */
  get items(): T[] | null {
    return this.currentItems;
  }

  /** The number of loaded items. */
  get count(): number {
    return this.currentItems?.length ?? 0;
  }

  /** The last loaded page number, 0 before the first. */
  get page(): number {
    return this.currentPage;
  }

  /** The total number of items the server reported, or 0. */
  get total(): number {
    return this.currentTotal;
  }

  /** The total number of pages the server reported, or 0. */
  get totalPage(): number {
    return this.currentTotalPage;
  }

  /** True when the first page arrived and it was empty. */
  get isEmpty(): boolean {
    return this.currentItems !== null && this.count === 0;
  }

  /** True when there is no next page. */
  get isNoMore(): boolean {
    return this.noMore;
  }

  /** The last failure, or null. */
  get error(): unknown {
    return this.currentError;
  }

  /** Loads the first page (through the header, when there is one, so it shows). */
  start(): void {
    this.refresh();
  }

  /** Loads the first page again. */
  refresh(): void {
    if (this.header !== undefined) {
      this.header.beginRefreshing();
    } else {
      this.load(this.firstPage);
    }
  }

  /** Loads the next page, unless there is none. */
  loadMore(): void {
    if (this.noMore) {
      return;
    }
    if (this.footer !== undefined) {
      this.footer.beginRefreshing();
    } else {
      this.load(this.currentPage + 1);
    }
  }

  private load(requested: number): void {
    if (this.loading) {
      return;
    }
    this.loading = true;
    const refreshing = requested === this.firstPage;
    this.loader(requested, (loaded, result = {}) => {
      this.loading = false;
      this.currentError = result.error ?? null;
      const failed = result.error !== undefined && result.error !== null;
      if (!failed) {
        const total = result.total ?? 0;
        const totalPage = result.totalPage ?? 0;
        this.currentPage = requested;
        this.currentTotal = total;
        this.currentTotalPage = totalPage;
        this.currentItems = refreshing ? [...(loaded ?? [])] : [...(this.currentItems ?? []), ...(loaded ?? [])];
        if (totalPage > 0) {
          this.noMore = this.currentPage >= this.firstPage + totalPage - 1;
        } else if (total > 0) {
          this.noMore = this.count >= total;
        } else {
          this.noMore = loaded === null || loaded.length === 0;
        }
        this.itemsDidChange?.(this);
      }
      this.notifyListeners();
      if (refreshing) {
        this.header?.endRefreshing(!failed);
        if (!failed) {
          if (this.noMore) {
            this.footer?.noticeNoMoreData();
          } else if (this.resetsFooterAfterRefresh) {
            this.footer?.resetNoMoreData();
          }
        }
      } else if (!failed && this.noMore) {
        this.footer?.endRefreshingWithNoMoreData();
      } else {
        this.footer?.endRefreshing(!failed);
      }
    });
  }
}
