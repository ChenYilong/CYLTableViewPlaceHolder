import type { CYLRefreshComponent, CYLRefreshHost } from './component.ts';
import type { CYLRefreshPaging } from './paging.ts';

/** The props of the native `CYLRefreshContainer` that a `CYLRefreshPaging` decides (see `CYLRefreshContainerProps`). */
export interface CYLRefreshPagingContainerState {
  /** True while the paging's header is refreshing. */
  refreshing: boolean;
  /** False when the header's `refreshEnabled` is false. */
  enabled: boolean;
  /** True when the paging has a footer whose `refreshEnabled` is true. */
  loadMoreEnabled: boolean;
  /** True while the paging's footer is loading. */
  loadingMore: boolean;
  /** True while the footer shows "no more data". */
  noMoreData: boolean;
  /** The native header was pulled: loads the first page through the header (or directly, with no header). */
  onRefresh: () => void;
  /** The native footer started to load: loads the next page through the footer. */
  onLoadMore: () => void;
}

/**
 * Maps the state of `paging` to the props of the native container. Pure: call it on every render (the paging, its header
 * and footer notify on every change, see `useCYLRefreshComponent`). The container only shows `refreshing` / `loadingMore` /
 * `noMoreData`; the phase machine stays the JavaScript header's and footer's, so `CYLRefreshPaging` keeps ending them as it
 * always does.
 */
export function cylRefreshPagingContainerProps<T>(paging: CYLRefreshPaging<T>): CYLRefreshPagingContainerState {
  const { header, footer } = paging;
  return {
    refreshing: header?.isRefreshing ?? false,
    enabled: header?.refreshEnabled ?? true,
    loadMoreEnabled: footer !== undefined && footer.refreshEnabled,
    loadingMore: footer?.isRefreshing ?? false,
    noMoreData: footer?.isNoMoreData ?? false,
    onRefresh: () => paging.refresh(),
    onLoadMore: () => paging.loadMore(),
  };
}

/**
 * A `CYLRefresh` owns its header and footer; with the native container nothing does, and `beginRefreshing` waits for an
 * owner. This gives the paging's header and footer one, so `paging.start()`, `refresh()` and `loadMore()` run at once.
 * Returns the function that detaches them again.
 */
export function attachCYLRefreshPagingHost<T>(paging: CYLRefreshPaging<T>): () => void {
  const host: CYLRefreshHost = {
    isOtherRefreshing: (component: CYLRefreshComponent) =>
      [paging.header, paging.footer].some((c) => c !== undefined && c !== component && c.isRefreshing),
  };
  paging.header?.attach(host);
  paging.footer?.attach(host);
  return () => {
    paging.header?.detach(host);
    paging.footer?.detach(host);
  };
}
