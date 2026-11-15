// CYLRefreshPaging: the HarmonyOS counterpart of iOS CYLRefreshPaging.h (easy_paging): a header refreshes the first
// page, a footer appends the next one; it ends the controls with success or failure and reports no more data.
import { CYLRefreshFooterModel, CYLRefreshHeaderModel } from './CYLRefreshComponent';

/** iOS NSNotFound: a count or a page that is unknown. */
export const CYLRefreshNotFound: number = -1;

/**
 * Reports one page: its items, the total item count or page count (CYLRefreshNotFound when unknown), or an error
 * (iOS `CYLRefreshPagingCompletion`). A request that reports an error changes nothing.
 */
export type CYLRefreshPagingCompletion = (items: Object[] | null, total: number, totalPage: number,
  error: Error | null) => void;

/** Requests page `page`; call `completion` exactly once (iOS `CYLRefreshPagingLoader`). */
export type CYLRefreshPagingLoader = (page: number, completion: CYLRefreshPagingCompletion) => void;

/** Called after the items changed (iOS `itemsDidChange`). */
export type CYLRefreshPagingItemsDidChange = (paging: CYLRefreshPaging) => void;

/** Pagination driven by a header and a footer (iOS `CYLRefreshPaging`). */
export class CYLRefreshPaging {
  /** Number of the first page, default 1 (`firstPage`). */
  firstPage: number = 1;
  /** Resets the footer's no-more-data state after a successful refresh, default true (`resetsFooterAfterRefresh`). */
  resetsFooterAfterRefresh: boolean = true;
  /** Called after the items changed; reload the list here (`itemsDidChange`). */
  itemsDidChange: CYLRefreshPagingItemsDidChange | null = null;
  private headerControl: CYLRefreshHeaderModel | null;
  private footerControl: CYLRefreshFooterModel | null;
  private loader: CYLRefreshPagingLoader;
  private loaded: Object[] | null = null;
  private lastPage: number = CYLRefreshNotFound;
  private totalCount: number = CYLRefreshNotFound;
  private totalPages: number = CYLRefreshNotFound;
  private generation: number = 0;

  /** Pagination with `header` and `footer` (either may be null); their callbacks are replaced (`-initWithHeader:footer:loader:`). */
  constructor(header: CYLRefreshHeaderModel | null, footer: CYLRefreshFooterModel | null,
    loader: CYLRefreshPagingLoader) {
    this.headerControl = header;
    this.footerControl = footer;
    this.loader = loader;
    if (header !== null) {
      header.refreshingBlock = () => this.request(this.firstPage, true);
    }
    if (footer !== null) {
      footer.refreshingBlock = () => this.request(this.nextPage(), false);
    }
  }

  /** `-initWithHeader:footer:loader:`. */
  static initWithHeader(header: CYLRefreshHeaderModel | null, footer: CYLRefreshFooterModel | null,
    loader: CYLRefreshPagingLoader): CYLRefreshPaging {
    return new CYLRefreshPaging(header, footer, loader);
  }

  /** The refresh header (`header`). */
  get header(): CYLRefreshHeaderModel | null {
    return this.headerControl;
  }

  /** The load-more footer (`footer`). */
  get footer(): CYLRefreshFooterModel | null {
    return this.footerControl;
  }

  /** All items loaded so far; null before the first successful request (`items`). */
  get items(): Object[] | null {
    return this.loaded !== null ? this.loaded.slice() : null;
  }

  /** Number of items (`count`). */
  get count(): number {
    return this.loaded !== null ? this.loaded.length : 0;
  }

  /** The last page loaded successfully; CYLRefreshNotFound before the first (`page`). */
  get page(): number {
    return this.lastPage;
  }

  /** Total item count from the last successful request, or CYLRefreshNotFound (`total`). */
  get total(): number {
    return this.totalCount;
  }

  /** Total page count from the last successful request, or CYLRefreshNotFound (`totalPage`). */
  get totalPage(): number {
    return this.totalPages;
  }

  /** True after a successful request that left no items (`isEmpty`). */
  get isEmpty(): boolean {
    return this.loaded !== null && this.loaded.length === 0;
  }

  /** True when every item is loaded: count >= total, else page >= totalPage; false when neither is known (`isNoMore`). */
  get isNoMore(): boolean {
    if (this.totalCount !== CYLRefreshNotFound) {
      return this.count >= this.totalCount;
    }
    if (this.totalPages !== CYLRefreshNotFound && this.lastPage !== CYLRefreshNotFound) {
      return this.lastPage >= this.totalPages;
    }
    return false;
  }

  /** Starts a refresh through the header, or requests the first page directly without one (`-start`). */
  start(): void {
    if (this.headerControl !== null && this.headerControl.attached) {
      this.headerControl.beginRefreshing();
    } else {
      this.refresh();
    }
  }

  /** Requests the first page; on success it replaces the items (`-refresh`). */
  refresh(): void {
    this.request(this.firstPage, true);
  }

  /** Requests the page after `page`; on success it appends the items (`-loadMore`). */
  loadMore(): void {
    this.request(this.nextPage(), false);
  }

  private nextPage(): number {
    return this.lastPage === CYLRefreshNotFound ? this.firstPage : this.lastPage + 1;
  }

  private request(page: number, refreshing: boolean): void {
    const generation = ++this.generation;
    let called = false;
    this.loader(page, (items: Object[] | null, total: number, totalPage: number, error: Error | null) => {
      if (called) {
        return;
      }
      called = true;
      this.finish(generation, page, refreshing, items, total, totalPage, error);
    });
  }

  private finish(generation: number, page: number, refreshing: boolean, items: Object[] | null, total: number,
    totalPage: number, error: Error | null): void {
    const header = this.headerControl;
    const footer = this.footerControl;
    if (error !== null || generation !== this.generation) {
      if (refreshing) {
        if (header !== null) {
          header.endRefreshingWithSuccess(false);
        }
      } else if (footer !== null) {
        footer.endRefreshingWithSuccess(false);
      }
      return;
    }
    const pageItems: Object[] = items !== null ? items : [];
    if (refreshing || this.loaded === null) {
      this.loaded = pageItems.slice();
    } else {
      this.loaded = this.loaded.concat(pageItems);
    }
    this.lastPage = page;
    this.totalCount = total;
    this.totalPages = totalPage;
    if (this.itemsDidChange !== null) {
      this.itemsDidChange(this);
    }
    const noMore = this.isNoMore;
    if (refreshing) {
      if (header !== null) {
        header.endRefreshingWithSuccess(true);
      }
      if (footer !== null) {
        if (footer.refreshing) {
          footer.endRefreshing();
        }
        if (noMore) {
          footer.endRefreshingWithNoMoreData();
        } else if (this.resetsFooterAfterRefresh) {
          footer.resetNoMoreData();
        }
      }
    } else if (footer !== null) {
      if (noMore) {
        footer.endRefreshingWithNoMoreData();
      } else {
        footer.endRefreshingWithSuccess(true);
      }
    }
  }
}
