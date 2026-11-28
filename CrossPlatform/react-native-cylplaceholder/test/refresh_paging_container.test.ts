import assert from 'node:assert/strict';
import { test } from 'node:test';
import {
  CYLRefreshBackFooter,
  CYLRefreshHeader,
  CYLRefreshPaging,
  attachCYLRefreshPagingHost,
  cylRefreshPagingContainerProps,
} from '../src/refresh/index.ts';

// A pager over 25 items in pages of 10; `pending` holds the completion of a load so a test can see the loading state.
function pager(options: { header?: boolean; footer?: boolean; hold?: boolean } = {}) {
  const header = options.header === false ? undefined : new CYLRefreshHeader({ finishDuration: 0 });
  const footer = options.footer === false ? undefined : new CYLRefreshBackFooter({ finishDuration: 0 });
  const pending: Array<() => void> = [];
  const paging = new CYLRefreshPaging<number>({
    header,
    footer,
    loader: (page, done) => {
      const finish = () => {
        const start = (page - 1) * 10;
        done(Array.from({ length: Math.max(0, Math.min(10, 25 - start)) }, (_, i) => start + i + 1), { total: 25 });
      };
      if (options.hold === true) pending.push(finish);
      else finish();
    },
  });
  return { paging, header, footer, pending };
}

test('the props mirror the header and footer: refreshing, loadingMore, noMoreData, enabled', () => {
  const { paging, header, footer, pending } = pager({ hold: true });
  const detach = attachCYLRefreshPagingHost(paging);
  assert.deepEqual(
    { ...cylRefreshPagingContainerProps(paging), onRefresh: undefined, onLoadMore: undefined },
    { refreshing: false, enabled: true, loadMoreEnabled: true, loadingMore: false, noMoreData: false, loadsAfterNoMoreData: false, onRefresh: undefined, onLoadMore: undefined }
  );
  paging.start();
  assert.equal(cylRefreshPagingContainerProps(paging).refreshing, true);
  pending.shift()!();
  assert.equal(cylRefreshPagingContainerProps(paging).refreshing, false, 'the page arrived: the header ends');
  paging.loadMore();
  assert.equal(cylRefreshPagingContainerProps(paging).loadingMore, true);
  pending.shift()!();
  assert.equal(cylRefreshPagingContainerProps(paging).loadingMore, false);
  header!.refreshEnabled = false;
  footer!.refreshEnabled = false;
  const props = cylRefreshPagingContainerProps(paging);
  assert.equal(props.enabled, false);
  assert.equal(props.loadMoreEnabled, false);
  detach();
});

test('loadsAfterNoMoreData of the footer is a prop of the container, false without a footer', () => {
  const { paging, footer } = pager();
  assert.equal(cylRefreshPagingContainerProps(paging).loadsAfterNoMoreData, false);
  footer!.loadsAfterNoMoreData = true;
  assert.equal(cylRefreshPagingContainerProps(paging).loadsAfterNoMoreData, true);
});

test('a native pull and a native load more call the pager through its header and footer, and the last page sets noMoreData', () => {
  const { paging, footer } = pager();
  const detach = attachCYLRefreshPagingHost(paging);
  cylRefreshPagingContainerProps(paging).onRefresh();
  assert.equal(paging.page, 1);
  cylRefreshPagingContainerProps(paging).onLoadMore();
  cylRefreshPagingContainerProps(paging).onLoadMore();
  assert.equal(paging.count, 25);
  assert.equal(paging.isNoMore, true);
  assert.equal(cylRefreshPagingContainerProps(paging).noMoreData, true);
  assert.equal(footer!.isNoMoreData, true);
  cylRefreshPagingContainerProps(paging).onLoadMore();
  assert.equal(paging.page, 3, 'no more data: the native footer cannot load another page');
  // A refresh resets "no more data" (resetsFooterAfterRefresh), so the container turns it off.
  cylRefreshPagingContainerProps(paging).onRefresh();
  assert.equal(paging.count, 10);
  assert.equal(cylRefreshPagingContainerProps(paging).noMoreData, false);
  detach();
});

test('without the host, begin waits for an owner; with it, start() loads at once, and detach restores the wait', () => {
  const waiting = pager();
  waiting.paging.start();
  assert.equal(waiting.paging.page, 0, 'no owner: refresh on start waits');
  const detach = attachCYLRefreshPagingHost(waiting.paging);
  assert.equal(waiting.paging.page, 1, 'attach runs the pending begin');
  detach();
  assert.equal(waiting.header!.attached, false);
  assert.equal(waiting.footer!.attached, false);
});

test('a failed load ends the header with failure and leaves the container idle', () => {
  const header = new CYLRefreshHeader({ finishDuration: 0 });
  const paging = new CYLRefreshPaging<number>({ header, loader: (_page, done) => done(null, { error: new Error('offline') }) });
  const detach = attachCYLRefreshPagingHost(paging);
  cylRefreshPagingContainerProps(paging).onRefresh();
  assert.equal(header.lastRefreshSucceeded, false);
  assert.equal(cylRefreshPagingContainerProps(paging).refreshing, false);
  assert.equal(cylRefreshPagingContainerProps(paging).loadMoreEnabled, false, 'no footer: load more is off');
  detach();
  paging.dispose();
});

test('with no header, the native pull loads the first page directly', () => {
  const { paging } = pager({ header: false, footer: false });
  cylRefreshPagingContainerProps(paging).onRefresh();
  assert.equal(paging.page, 1);
  assert.equal(cylRefreshPagingContainerProps(paging).refreshing, false);
});
