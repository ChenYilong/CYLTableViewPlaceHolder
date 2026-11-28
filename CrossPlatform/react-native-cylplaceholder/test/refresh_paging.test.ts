import assert from 'node:assert/strict';
import { test } from 'node:test';
import {
  CYLRefreshBackFooter,
  CYLRefreshHeader,
  CYLRefreshPaging,
  type CYLRefreshFooter,
} from '../src/refresh/index.ts';

function server(options: { header?: CYLRefreshHeader; footer?: CYLRefreshFooter; total?: number; size?: number; failOnce?: boolean } = {}) {
  const total = options.total ?? 25;
  const size = options.size ?? 10;
  let failed = false;
  return new CYLRefreshPaging<number>({
    header: options.header,
    footer: options.footer,
    loader: (page, done) => {
      if (options.failOnce === true && !failed) {
        failed = true;
        done(null, { error: new Error('offline') });
        return;
      }
      const start = (page - 1) * size;
      const items: number[] = [];
      for (let i = start; start < total && i < start + size && i < total; i += 1) {
        items.push(i + 1);
      }
      done(items, { total });
    },
  });
}

test('without a header or footer: start loads page 1, loadMore appends, the last page sets isNoMore', () => {
  const paging = server();
  let changes = 0;
  paging.itemsDidChange = () => (changes += 1);
  const before: number[] | null = paging.items;
  assert.equal(before, null);
  assert.equal(paging.isEmpty, false);
  paging.start();
  assert.equal(paging.page, 1);
  assert.equal(paging.count, 10);
  assert.equal(paging.total, 25);
  assert.equal(paging.isNoMore, false);
  paging.loadMore();
  paging.loadMore();
  assert.equal(paging.items?.length, 25);
  assert.equal(paging.page, 3);
  assert.equal(paging.isNoMore, true);
  paging.loadMore();
  assert.equal(paging.page, 3, 'nothing after the last page');
  assert.equal(changes, 3);
  paging.refresh();
  assert.equal(paging.count, 10);
  assert.equal(paging.isNoMore, false);
});

test('an empty first page is empty; a failure keeps the page so a retry loads the same one', () => {
  const empty = new CYLRefreshPaging<number>({ loader: (_page, done) => done([]) });
  empty.start();
  assert.equal(empty.isEmpty, true);
  assert.equal(empty.isNoMore, true);
  const paging = server({ failOnce: true });
  paging.start();
  assert.ok(paging.error instanceof Error);
  assert.equal(paging.items, null);
  assert.equal(paging.page, 0);
  paging.start();
  assert.equal(paging.page, 1);
  assert.equal(paging.error, null);
});

test('with a header and a footer: refresh ends the header, a load ends the footer with no more data', () => {
  const header = new CYLRefreshHeader({ finishDuration: 0 });
  const footer = new CYLRefreshBackFooter({ finishDuration: 0 });
  const host = { isOtherRefreshing: () => false };
  header.attach(host);
  footer.attach(host);
  const paging = server({ header, footer, total: 15 });
  paging.start();
  assert.equal(paging.count, 10);
  assert.equal(header.phase, 'finishing');
  footer.beginRefreshing({ duration: 0, overOffset: 0 });
  assert.equal(paging.count, 15);
  assert.equal(paging.isNoMore, true);
  assert.equal(footer.isNoMoreData, true);
  paging.start();
  assert.equal(footer.isNoMoreData, false, 'resetsFooterAfterRefresh');
  assert.equal(paging.count, 10);
  header.dispose();
  footer.dispose();
  paging.dispose();
});
