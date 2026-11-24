// Local (host) unit tests of the CYLRefresh state machine: texts, last update time, header / back footer / auto
// footer / trailer states driven by a scroll view model, exclusivity, phases, scroll metrics and paging.
import { describe, expect, it } from '@ohos/hypium';
import { CYLPlaceholderLocalization } from '../main/ets/CYLPlaceholderLocalization';
import {
  CYLRefreshConfig,
  CYLRefreshHeaderIdleText,
  CYLRefreshI18nBundle,
  CYLRefreshLastUpdatedTimeText,
  CYLRefreshLocalizedString,
  CYLRefreshPhase,
  CYLRefreshState,
  CYLScrollDirection
} from '../main/ets/refresh/CYLRefreshConst';
import {
  CYLRefreshComponentModel,
  CYLRefreshHeaderModel,
  CYLRefreshScrollViewModel
} from '../main/ets/refresh/CYLRefreshComponent';
import {
  CYLRefreshAutoNormalFooterModel,
  CYLRefreshBackNormalFooterModel,
  CYLRefreshNormalHeaderModel,
  CYLRefreshNormalTrailerModel
} from '../main/ets/refresh/CYLRefreshClassics';
import { CYLRefreshPaging, CYLRefreshPagingCompletion, CYLRefreshNotFound } from '../main/ets/refresh/CYLRefreshPaging';

function makeScrollView(scrollerY: number): CYLRefreshScrollViewModel {
  const sv = new CYLRefreshScrollViewModel();
  sv.cyl_reportScroll(0, scrollerY, 400, 600, 400, 1000);
  sv.cyl_setWindow(true);
  return sv;
}

export default function refreshCoreTest() {
  describe('CYLRefreshCore', () => {
    it('localizesTexts', 0, () => {
      CYLRefreshConfig.defaultConfig.languageCode = 'en';
      expect(CYLRefreshLocalizedString(CYLRefreshHeaderIdleText)).assertEqual('Pull down to refresh');
      CYLRefreshConfig.defaultConfig.languageCode = 'zh-CN';
      expect(CYLRefreshConfig.defaultConfig.effectiveLanguage).assertEqual('zh-Hans');
      expect(CYLRefreshLocalizedString(CYLRefreshHeaderIdleText) === 'Pull down to refresh').assertFalse();
      const bundle: CYLRefreshI18nBundle = new Map();
      const custom: Record<string, string> = { 'CYLRefreshHeaderIdleText': 'Custom' };
      bundle.set('zh-Hans', custom);
      CYLRefreshConfig.defaultConfig.i18nBundle = bundle;
      expect(CYLRefreshLocalizedString(CYLRefreshHeaderIdleText)).assertEqual('Custom');
      CYLRefreshConfig.defaultConfig.i18nBundle = null;
      expect(CYLRefreshLocalizedString('missing', 'fb')).assertEqual('fb');
      CYLRefreshConfig.defaultConfig.languageCode = 'en';
    });

    it('formatsLastUpdatedTime', 0, () => {
      CYLRefreshConfig.defaultConfig.languageCode = 'en';
      const now = new Date(2026, 10, 16, 12, 0);
      expect(CYLRefreshLastUpdatedTimeText(null, now)).assertEqual('Last update: No record');
      expect(CYLRefreshLastUpdatedTimeText(new Date(2026, 10, 16, 9, 5), now)).assertEqual('Last update: Today 09:05');
      expect(CYLRefreshLastUpdatedTimeText(new Date(2026, 1, 3, 9, 41), now)).assertEqual('Last update: 02-03 09:41');
      expect(CYLRefreshLastUpdatedTimeText(new Date(2025, 10, 14, 9, 41), now))
        .assertEqual('Last update: 2025-11-14 09:41');
      expect(CYLRefreshLastUpdatedTimeText(new Date(2025, 0, 1), now, (d: Date) => 'X')).assertEqual('Last update: X');
    });

    it('pullsHeaderToRefresh', 0, () => {
      CYLRefreshConfig.defaultConfig.languageCode = 'en';
      const sv = makeScrollView(0);
      let calls = 0;
      const header = CYLRefreshNormalHeaderModel.headerWithRefreshingBlock(() => {
        calls++;
      });
      header.lastUpdatedTimeKey = 'test.header';
      header.lastUpdatedTime = null;
      sv.cyl_header = header;
      expect(header.stateLabel.text).assertEqual('Pull down to refresh');
      expect(header.lastUpdatedTimeString).assertEqual('Last update: No record');
      sv.cyl_panBegan();
      sv.cyl_panChanged(27, 0, 0);
      expect(header.state).assertEqual(CYLRefreshState.Idle);
      expect(Math.abs(header.pullingPercent - 0.5) < 0.001).assertTrue();
      expect(header.phase).assertEqual(CYLRefreshPhase.PullToRefresh);
      sv.cyl_panChanged(60, 0, 0);
      expect(header.state).assertEqual(CYLRefreshState.Pulling);
      expect(header.phase).assertEqual(CYLRefreshPhase.ReleaseToRefresh);
      expect(header.stateLabel.text).assertEqual('Release to refresh');
      expect(header.arrowView.rotation).assertEqual(180);
      sv.cyl_panChanged(40, 0, 0);
      expect(header.state).assertEqual(CYLRefreshState.Idle);
      sv.cyl_panChanged(70, 0, 0);
      sv.cyl_panEnded(0, 0);
      expect(header.state).assertEqual(CYLRefreshState.Refreshing);
      expect(header.refreshing).assertTrue();
      expect(calls).assertEqual(1);
      expect(sv.cyl_insetT).assertEqual(54);
      expect(sv.revealTop).assertEqual(54);
      expect(sv.cyl_offsetY).assertEqual(-54);
      expect(header.loadingView.animating).assertTrue();
      let ended = 0;
      header.endRefreshingWithCompletionBlock(() => {
        ended++;
      });
      expect(header.state).assertEqual(CYLRefreshState.Idle);
      expect(ended).assertEqual(1);
      expect(sv.cyl_insetT).assertEqual(0);
      expect(sv.revealTop).assertEqual(0);
      expect(header.lastUpdatedTime !== null).assertTrue();
      expect((header.lastUpdatedTimeString as string).indexOf('Today') > 0).assertTrue();
    });

    it('waitsForWindowAndHonorsMaxPull', 0, () => {
      const sv = new CYLRefreshScrollViewModel();
      sv.cyl_reportScroll(0, 0, 400, 600, 400, 1000);
      const header = new CYLRefreshHeaderModel();
      sv.cyl_header = header;
      header.beginRefreshing();
      expect(header.state).assertEqual(CYLRefreshState.WillRefresh);
      sv.cyl_setWindow(true);
      expect(header.state).assertEqual(CYLRefreshState.Refreshing);
      header.endRefreshing();
      header.maxPullDistance = 80;
      sv.cyl_panBegan();
      sv.cyl_panChanged(200, 0, 0);
      expect(sv.revealTop).assertEqual(80);
      sv.cyl_panEnded(0, 0, true);
    });

    it('pullsBackFooterAndNoMoreData', 0, () => {
      CYLRefreshConfig.defaultConfig.languageCode = 'en';
      const sv = makeScrollView(400);
      let loads = 0;
      const footer = CYLRefreshBackNormalFooterModel.footerWithRefreshingBlock(() => {
        loads++;
      });
      sv.cyl_footer = footer;
      expect(footer.cyl_happenOffsetY()).assertEqual(400);
      sv.cyl_panBegan();
      sv.cyl_panChanged(0, 30, 0);
      expect(footer.state).assertEqual(CYLRefreshState.Idle);
      sv.cyl_panChanged(0, 50, 0);
      expect(footer.state).assertEqual(CYLRefreshState.Pulling);
      expect(footer.stateLabel.text).assertEqual('Release to load more');
      sv.cyl_panEnded(0, 0);
      expect(footer.state).assertEqual(CYLRefreshState.Refreshing);
      expect(loads).assertEqual(1);
      expect(sv.revealBottom).assertEqual(44);
      footer.endRefreshingWithNoMoreData();
      expect(footer.noMoreData).assertTrue();
      expect(footer.stateLabel.text).assertEqual('No more data');
      expect(sv.revealBottom).assertEqual(0);
      footer.resetNoMoreData();
      expect(footer.state).assertEqual(CYLRefreshState.Idle);
    });

    it('followsContentWhenNoMoreData', 0, () => {
      const sv = makeScrollView(400);
      const footer = CYLRefreshBackNormalFooterModel.footerWithRefreshingBlock(() => {
      });
      expect(footer.followsContentWhenNoMoreData).assertFalse();
      footer.followsContentWhenNoMoreData = true;
      sv.cyl_footer = footer;
      sv.cyl_panBegan();
      sv.cyl_panChanged(0, 50, 0);
      sv.cyl_panEnded(0, 0);
      expect(footer.state).assertEqual(CYLRefreshState.Refreshing);
      expect(sv.revealBottom).assertEqual(44);
      footer.endRefreshingWithNoMoreData();
      expect(footer.noMoreData).assertTrue();
      // Held after the content until the state changes (without the flag it is 0 here).
      expect(sv.revealBottom).assertEqual(44);
      footer.resetNoMoreData();
      expect(footer.state).assertEqual(CYLRefreshState.Idle);
      expect(sv.revealBottom).assertEqual(0);
    });

    it('scrollsContentAfterLoading', 0, () => {
      const offsets: number[] = [];
      for (const scrolls of [true, false]) {
        const sv = makeScrollView(400);
        let rows = 10;
        sv.dataCountProvider = () => rows;
        const footer = CYLRefreshBackNormalFooterModel.footerWithRefreshingBlock(() => {
        });
        expect(footer.scrollsContentAfterLoading).assertTrue();
        footer.scrollsContentAfterLoading = scrolls;
        sv.cyl_footer = footer;
        sv.cyl_panBegan();
        sv.cyl_panChanged(0, 50, 0);
        sv.cyl_panEnded(0, 0);
        expect(footer.state).assertEqual(CYLRefreshState.Refreshing);
        // New rows arrive and the content grows, the offset moved on by 50.
        rows = 20;
        sv.cyl_reportScroll(0, 450, 400, 600, 400, 1400);
        footer.endRefreshing();
        offsets.push(sv.cyl_offsetY);
      }
      expect(offsets[0]).assertEqual(450);
      // NO keeps the old end of the content (the offset the footer began to show at) in place.
      expect(offsets[1]).assertEqual(400);
    });

    it('countsAutoFooterTriggers', 0, () => {
      const sv = makeScrollView(0);
      let loads = 0;
      const footer = CYLRefreshAutoNormalFooterModel.footerWithRefreshingBlock(() => {
        loads++;
      });
      sv.cyl_footer = footer;
      sv.cyl_panBegan();
      footer.cyl_visibleRatioDidChange(0.5);
      expect(loads).assertEqual(0);
      footer.cyl_visibleRatioDidChange(1);
      expect(loads).assertEqual(1);
      expect(footer.loadingView.animating).assertTrue();
      footer.endRefreshing();
      expect(footer.cyl_leftTriggerTimes).assertEqual(0);
      footer.cyl_visibleRatioDidChange(0);
      footer.cyl_visibleRatioDidChange(1);
      expect(loads).assertEqual(1);
      sv.cyl_panEnded(0, 0);
      sv.cyl_panBegan();
      footer.cyl_visibleRatioDidChange(0);
      footer.cyl_visibleRatioDidChange(1);
      expect(loads).assertEqual(2);
      footer.endRefreshing();
      footer.autoTriggerTimes = -1;
      footer.cyl_visibleRatioDidChange(0);
      footer.cyl_visibleRatioDidChange(1);
      footer.endRefreshing();
      footer.cyl_visibleRatioDidChange(0);
      footer.cyl_visibleRatioDidChange(1);
      expect(loads).assertEqual(4);
      footer.endRefreshing();
      footer.triggerAutomaticallyRefreshPercent = 0.5;
      footer.automaticallyRefresh = false;
      footer.cyl_visibleRatioDidChange(0);
      footer.cyl_visibleRatioDidChange(1);
      expect(loads).assertEqual(4);
      footer.stateLabelClick();
      expect(loads).assertEqual(5);
      sv.cyl_panEnded(0, 0);
    });

    it('excludesOtherRefresh', 0, () => {
      const sv = makeScrollView(0);
      const header = CYLRefreshNormalHeaderModel.headerWithRefreshingBlock(() => {
      });
      const footer = CYLRefreshBackNormalFooterModel.footerWithRefreshingBlock(() => {
      });
      sv.cyl_header = header;
      sv.cyl_footer = footer;
      let blocked = 0;
      footer.blockedByOtherRefreshBlock = () => {
        blocked++;
      };
      header.beginRefreshing();
      footer.beginRefreshing();
      expect(footer.state).assertEqual(CYLRefreshState.Idle);
      expect(blocked).assertEqual(1);
      footer.beginRefreshingWithDuration(0, 0, true);
      expect(footer.state).assertEqual(CYLRefreshState.Refreshing);
    });

    it('reportsPhasesAndMetrics', 0, () => {
      const sv = makeScrollView(0);
      const header = new CYLRefreshHeaderModel();
      sv.cyl_header = header;
      const phases: CYLRefreshPhase[] = [];
      const token = header.addPhaseObserver((c: CYLRefreshComponentModel, o: CYLRefreshPhase, p: CYLRefreshPhase) => {
        phases.push(p);
      });
      header.beginRefreshing();
      header.endRefreshing();
      header.removePhaseObserver(token);
      header.beginRefreshing();
      expect(phases.length).assertEqual(2);
      expect(phases[0]).assertEqual(CYLRefreshPhase.Refreshing);
      expect(header.isInPhases(CYLRefreshPhase.Idle, CYLRefreshPhase.Refreshing)).assertTrue();
      expect(header.isInAnyPhase([CYLRefreshPhase.Idle])).assertFalse();
      header.endRefreshing();
      sv.cyl_updateScrollMetrics();
      expect(sv.cyl_scrollDirection).assertEqual(CYLScrollDirection.None);
      sv.cyl_reportScroll(0, 120, 400, 600, 400, 1000);
      sv.cyl_updateScrollMetrics();
      expect(sv.cyl_scrollDistance).assertEqual(120);
      expect(sv.cyl_scrollDirection).assertEqual(CYLScrollDirection.Down);
      sv.cyl_autoHideRefresh = true;
      expect(sv.cyl_autoHideRefreshHeader).assertTrue();
      expect(header.cyl_autoHidden).assertTrue();
    });

    it('pullsTrailer', 0, () => {
      const sv = new CYLRefreshScrollViewModel();
      sv.cyl_reportScroll(600, 0, 400, 300, 1000, 300);
      sv.cyl_setWindow(true);
      let calls = 0;
      const trailer = CYLRefreshNormalTrailerModel.trailerWithRefreshingBlock(() => {
        calls++;
      });
      sv.cyl_trailer = trailer;
      sv.cyl_panBegan();
      sv.cyl_panChanged(0, 0, 70);
      expect(trailer.state).assertEqual(CYLRefreshState.Pulling);
      sv.cyl_panEnded(0, 0);
      expect(trailer.state).assertEqual(CYLRefreshState.Refreshing);
      expect(calls).assertEqual(1);
      expect(sv.revealRight).assertEqual(60);
      trailer.endRefreshing();
      expect(sv.revealRight).assertEqual(0);
    });

    it('pagesThroughHeaderAndFooter', 0, () => {
      const sv = makeScrollView(0);
      const header = new CYLRefreshNormalHeaderModel();
      const footer = new CYLRefreshAutoNormalFooterModel();
      sv.cyl_header = header;
      sv.cyl_footer = footer;
      let changes = 0;
      const paging = new CYLRefreshPaging(header, footer, (page: number, completion: CYLRefreshPagingCompletion) => {
        const items: Object[] = [page * 10 + 1, page * 10 + 2];
        completion(items, 5, CYLRefreshNotFound, null);
      });
      paging.itemsDidChange = (p: CYLRefreshPaging) => {
        changes++;
      };
      expect(paging.page).assertEqual(CYLRefreshNotFound);
      paging.start();
      expect(paging.count).assertEqual(2);
      expect(paging.page).assertEqual(1);
      expect(header.state).assertEqual(CYLRefreshState.Idle);
      footer.beginRefreshing();
      expect(paging.count).assertEqual(4);
      expect(paging.isNoMore).assertFalse();
      footer.beginRefreshing();
      expect(paging.count).assertEqual(6);
      expect(paging.isNoMore).assertTrue();
      expect(footer.state).assertEqual(CYLRefreshState.NoMoreData);
      paging.refresh();
      expect(paging.count).assertEqual(2);
      expect(footer.state).assertEqual(CYLRefreshState.Idle);
      expect(changes).assertEqual(4);
      const failing = new CYLRefreshPaging(null, null, (page: number, completion: CYLRefreshPagingCompletion) => {
        completion(null, 0, 0, new Error('x'));
      });
      failing.refresh();
      expect(failing.items === null).assertTrue();
      expect(failing.isEmpty).assertFalse();
      CYLPlaceholderLocalization.language = null;
    });
  });
}
