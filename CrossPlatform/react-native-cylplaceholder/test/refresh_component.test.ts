import assert from 'node:assert/strict';
import { test } from 'node:test';
import {
  CYLRefreshBackFooter,
  CYLRefreshComponent,
  CYLRefreshHeader,
  CYLRefreshPhase,
  CYLRefreshState,
  CYLRefreshTriggerMode,
} from '../src/refresh/index.ts';

const delay = (ms: number) => new Promise<void>((resolve) => setTimeout(resolve, ms));

test('pulling walks idle -> pullToRefresh -> releaseToRefresh and reports the percent', () => {
  const header = new CYLRefreshHeader({ expandHeight: 60, triggerRate: 1.5 });
  const phases: string[] = [];
  header.addPhaseObserver((_component, phase) => phases.push(phase));
  assert.equal(header.triggerOffset, 90);
  header.handlePull(30, true);
  assert.equal(header.phase, CYLRefreshPhase.pullToRefresh);
  assert.equal(header.state, CYLRefreshState.pulling);
  assert.ok(Math.abs(header.pullingPercent - 1 / 3) < 1e-9);
  assert.equal(header.dragOffset, 30);
  header.handlePull(95, true);
  assert.equal(header.phase, CYLRefreshPhase.releaseToRefresh);
  header.handlePull(0, true);
  assert.equal(header.phase, CYLRefreshPhase.idle);
  assert.deepEqual(phases, ['pullToRefresh', 'releaseToRefresh', 'idle']);
  header.dispose();
});

test('release starts refreshing once; endRefreshing records the result', async () => {
  let calls = 0;
  const header = new CYLRefreshHeader({ refreshingHandler: () => (calls += 1), finishDuration: 10 });
  header.handlePull(80, true);
  header.handleRelease();
  assert.equal(header.phase, CYLRefreshPhase.refreshing);
  assert.equal(header.isRefreshing, true);
  assert.equal(calls, 1);
  header.endRefreshing(false);
  assert.equal(header.phase, CYLRefreshPhase.finishing);
  assert.equal(header.lastRefreshSucceeded, false);
  await delay(30);
  assert.equal(header.phase, CYLRefreshPhase.idle);
  assert.equal(header.lastUpdatedTime, null);
  header.dispose();
});

test('a successful end records lastUpdatedTime', async () => {
  const header = new CYLRefreshHeader({ finishDuration: 0 });
  header.handlePull(80, true);
  header.handleRelease();
  header.endRefreshing();
  assert.ok(header.lastUpdatedTime instanceof Date);
  await delay(10);
  header.dispose();
});

test('the caller always ends refreshing: it stays refreshing until endRefreshing', async () => {
  const header = new CYLRefreshHeader({ finishDuration: 0 });
  header.handlePull(80, true);
  header.handleRelease();
  await delay(50);
  assert.equal(header.phase, CYLRefreshPhase.refreshing);
  header.dispose();
});

test('refreshEnabled = false never arms', () => {
  const header = new CYLRefreshHeader({ refreshEnabled: false });
  header.handlePull(100, true);
  assert.equal(header.phase, CYLRefreshPhase.idle);
  header.handleRelease();
  assert.equal(header.isRefreshing, false);
  header.dispose();
});

test('onEdge ignores a pull that did not start at the edge', () => {
  const header = new CYLRefreshHeader({ triggerMode: CYLRefreshTriggerMode.onEdge });
  header.handlePull(100, true, false);
  assert.equal(header.phase, CYLRefreshPhase.idle);
  header.handlePull(100, true, true);
  assert.equal(header.phase, CYLRefreshPhase.releaseToRefresh);
  header.dispose();
});

test('triggersWhenReached refreshes without a release', () => {
  const header = new CYLRefreshHeader({ triggersWhenReached: true });
  header.handlePull(70, true);
  // Not attached to a view yet: a pull still starts it (only beginRefreshing waits for an owner).
  assert.equal(header.isRefreshing, true);
  header.dispose();
});

test('hapticFeedback vibrates once when the pull is armed', () => {
  let impacts = 0;
  CYLRefreshComponent.hapticImpact = () => (impacts += 1);
  const header = new CYLRefreshHeader({ hapticFeedback: true });
  header.handlePull(70, true);
  header.handlePull(80, true);
  assert.equal(impacts, 1);
  header.dispose();
  CYLRefreshComponent.hapticImpact = null;
});

test('notifiesWhenHidden decides whether a hidden component notifies', () => {
  let hidden = 0;
  let always = 0;
  const quiet = new CYLRefreshHeader();
  quiet.subscribe(() => (hidden += 1));
  const loud = new CYLRefreshHeader({ notifiesWhenHidden: true });
  loud.subscribe(() => (always += 1));
  quiet.handlePull(0, false);
  loud.handlePull(0, false);
  assert.equal(hidden, 0);
  assert.equal(always, 1);
  quiet.dispose();
  loud.dispose();
});

test('every notification grows the version, and unsubscribe stops the listener', () => {
  const header = new CYLRefreshHeader();
  let n = 0;
  const stop = header.subscribe(() => (n += 1));
  const before = header.version;
  header.handlePull(10, true);
  assert.ok(header.version > before);
  stop();
  const seen = n;
  header.handlePull(20, true);
  assert.equal(n, seen);
  header.dispose();
});

test('phase observers can be removed', () => {
  const header = new CYLRefreshHeader();
  let n = 0;
  const observer = () => (n += 1);
  header.addPhaseObserver(observer);
  header.handlePull(10, true);
  header.removePhaseObserver(observer);
  header.handlePull(0, true);
  assert.equal(n, 1);
  header.dispose();
});

test('properties can be overridden on the instance (no wrapper class)', () => {
  const header = new CYLRefreshHeader();
  header.expandHeight = 80;
  header.colorAccent = '#112233';
  assert.equal(header.expandHeight, 80);
  assert.equal(header.colorAccent, '#112233');
  header.dispose();
});

test('endRefreshingWithNoMoreData stops loading until resetNoMoreData', () => {
  const footer = new CYLRefreshBackFooter();
  assert.equal(footer.isNoMoreData, false);
  footer.handlePull(80, true);
  footer.handleRelease();
  footer.endRefreshingWithNoMoreData();
  assert.equal(footer.isNoMoreData, true);
  assert.equal(footer.state, CYLRefreshState.noMoreData);
  assert.equal(footer.holdsSpace, true);
  footer.handlePull(80, true);
  assert.equal(footer.phase, CYLRefreshPhase.finishing);
  footer.resetNoMoreData();
  assert.equal(footer.isNoMoreData, false);
  footer.dispose();
});

test('loadsAfterNoMoreData lets a pull load again and clears the flag', () => {
  const footer = new CYLRefreshBackFooter({ loadsAfterNoMoreData: true, finishDuration: 0 });
  footer.noticeNoMoreData();
  footer.handlePull(80, true);
  assert.equal(footer.phase, CYLRefreshPhase.releaseToRefresh);
  footer.handleRelease();
  assert.equal(footer.isRefreshing, true);
  assert.equal(footer.isNoMoreData, false);
  footer.dispose();
});
