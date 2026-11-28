// Local (host) unit tests of the CYLRefresh base API rows added to docs/HarmonyOS.md: starting and ending in code,
// autoRefresh, scroll observers, canTrigger, dragRate, the second floor's veto and duration, state titles, animation
// images, the placeholder shown for a list, the default creators / initializer of CYLRefreshConfig and the footer's loadsWhenContentNotFull.
import { describe, expect, it } from '@ohos/hypium';
import {
  CYLRefreshComponentModel,
  CYLRefreshHeaderModel,
  CYLRefreshScrollViewModel
} from '../main/ets/refresh/CYLRefreshComponent';
import { CYLRefreshConfig, CYLRefreshState } from '../main/ets/refresh/CYLRefreshConst';
import { CYLRefreshImage } from '../main/ets/refresh/CYLRefreshImage';
import { CYLPlaceholderListController } from '../main/ets/CYLPlaceholderList';
import { CYLPlaceholderScenario } from '../main/ets/CYLPlaceholderScenario';
import { CYLPlaceholderStackViewModel } from '../main/ets/CYLPlaceholderStackView';
import {
  CYLRefreshAutoNormalFooterModel,
  CYLRefreshNormalHeaderModel,
  CYLRefreshNormalTrailerModel
} from '../main/ets/refresh/CYLRefreshClassics';

class RecordingHeader extends CYLRefreshNormalHeaderModel {
  autoChanges: boolean[] = [];

  autoRefreshDidChange(autoRefresh: boolean): void {
    this.autoChanges.push(autoRefresh);
  }
}

function makeScrollView(contentH: number = 1000): CYLRefreshScrollViewModel {
  const sv = new CYLRefreshScrollViewModel();
  sv.cyl_reportScroll(0, 0, 400, 600, 400, contentH);
  sv.cyl_setWindow(true);
  return sv;
}

export default function refreshApiTest() {
  describe('CYLRefreshApi', () => {
    it('beginsAndEndsWithoutDelay', 0, () => {
      const sv = makeScrollView();
      const header = new CYLRefreshNormalHeaderModel();
      sv.cyl_header = header;
      header.beginRefreshingAfterDelay(0);
      expect(header.state).assertEqual(CYLRefreshState.Refreshing);
      header.endRefreshingAfterDelay(0, true);
      expect(header.state).assertEqual(CYLRefreshState.Idle);
      // A pending delay changes nothing yet.
      header.beginRefreshingAfterDelay(30);
      expect(header.state).assertEqual(CYLRefreshState.Idle);
    });

    it('animationOnlySkipsTheCallbacksOnce', 0, () => {
      const sv = makeScrollView();
      let calls = 0;
      const header = CYLRefreshNormalHeaderModel.headerWithRefreshingBlock(() => {
        calls++;
      });
      sv.cyl_header = header;
      header.beginRefreshingAnimationOnly();
      expect(header.state).assertEqual(CYLRefreshState.Refreshing);
      expect(calls).assertEqual(0);
      header.endRefreshing();
      expect(header.state).assertEqual(CYLRefreshState.Idle);
      header.beginRefreshing();
      expect(calls).assertEqual(1);
    });

    it('tellsAnAutoRefreshFromAPull', 0, () => {
      const sv = makeScrollView();
      const header = new RecordingHeader();
      sv.cyl_header = header;
      expect(header.autoRefresh).assertFalse();
      header.beginRefreshing();
      expect(header.autoRefresh).assertTrue();
      expect(header.autoChanges.length).assertEqual(1);
      header.endRefreshing();
      expect(header.autoRefresh).assertFalse();
      expect(header.autoChanges[1]).assertFalse();

      const pulled = new RecordingHeader();
      const pullView = makeScrollView();
      pullView.cyl_header = pulled;
      pullView.cyl_panBegan();
      pullView.cyl_panChanged(70, 0, 0);
      pullView.cyl_panEnded(0, 0);
      expect(pulled.state).assertEqual(CYLRefreshState.Refreshing);
      expect(pulled.autoRefresh).assertFalse();
      expect(pulled.autoChanges.length).assertEqual(0);
    });

    it('reportsMovesToScrollObservers', 0, () => {
      const sv = makeScrollView();
      const header = new CYLRefreshNormalHeaderModel();
      sv.cyl_header = header;
      let moves = 0;
      let lastDragging = false;
      const token = header.addScrollObserver((c: CYLRefreshComponentModel, offset: number, percent: number,
        dragging: boolean) => {
        moves++;
        lastDragging = dragging;
      });
      sv.cyl_panBegan();
      sv.cyl_panChanged(30, 0, 0);
      expect(moves > 0).assertTrue();
      expect(lastDragging).assertTrue();
      header.removeScrollObserver(token);
      const seen = moves;
      sv.cyl_panChanged(40, 0, 0);
      expect(moves).assertEqual(seen);
    });

    it('asksCanTriggerBeforeArming', 0, () => {
      const blocked = new CYLRefreshNormalHeaderModel();
      const blockedView = makeScrollView();
      blockedView.cyl_header = blocked;
      blocked.canTriggerBlock = (c: CYLRefreshComponentModel) => false;
      expect(blocked.canTrigger()).assertFalse();
      blockedView.cyl_panBegan();
      blockedView.cyl_panChanged(70, 0, 0);
      expect(blocked.state).assertEqual(CYLRefreshState.Idle);

      const open = new CYLRefreshNormalHeaderModel();
      const openView = makeScrollView();
      openView.cyl_header = open;
      expect(open.canTrigger()).assertTrue();
      openView.cyl_panBegan();
      openView.cyl_panChanged(70, 0, 0);
      expect(open.state).assertEqual(CYLRefreshState.Pulling);
    });

    it('appliesDragRate', 0, () => {
      const header = new CYLRefreshNormalHeaderModel();
      const sv = makeScrollView();
      sv.cyl_header = header;
      sv.cyl_panBegan();
      sv.cyl_panChanged(100, 0, 0);
      expect(sv.revealTop).assertEqual(100);
      header.dragRate = 0.5;
      sv.cyl_panChanged(100, 0, 0);
      expect(sv.revealTop).assertEqual(50);
      header.dragRate = 1;
      sv.cyl_panChanged(100, 0, 0);
      expect(sv.revealTop).assertEqual(100);
    });

    it('vetoesAndTimesTheSecondFloor', 0, () => {
      const sv = makeScrollView();
      const header = new CYLRefreshNormalHeaderModel();
      sv.cyl_header = header;
      expect(header.cyl_secondaryDuration).assertEqual(header.slowAnimationDuration);
      header.secondaryAnimationDuration = 0.7;
      expect(header.cyl_secondaryDuration).assertEqual(0.7);
      header.secondaryShouldOpenBlock = (h: CYLRefreshHeaderModel) => false;
      header.openSecondary();
      expect(header.secondaryOpen).assertFalse();
      header.secondaryShouldOpenBlock = (h: CYLRefreshHeaderModel) => true;
      header.openSecondary();
      expect(header.secondaryOpen).assertTrue();
    });

    it('keepsStateTitles', 0, () => {
      CYLRefreshConfig.defaultConfig.languageCode = 'en';
      const header = new CYLRefreshNormalHeaderModel();
      expect(header.cyl_stateTitleForState(CYLRefreshState.Idle) === null).assertTrue();
      header.cyl_setStateTitle('Mine', CYLRefreshState.Idle);
      header.cyl_setStateTitle(null, CYLRefreshState.Idle);
      expect(header.cyl_stateTitleForState(CYLRefreshState.Idle)).assertEqual('Mine');
      header.setTitle('Custom', CYLRefreshState.Pulling);
      expect(header.titleForState(CYLRefreshState.Pulling)).assertEqual('Custom');
      const trailer = new CYLRefreshNormalTrailerModel();
      trailer.setTitle('Side', CYLRefreshState.Idle);
      expect(trailer.titleForState(CYLRefreshState.Idle)).assertEqual('Side');
    });

    it('keepsAnimationImages', 0, () => {
      const header = new CYLRefreshNormalHeaderModel();
      expect(header.cyl_animationImagesForState(CYLRefreshState.Idle) === null).assertTrue();
      header.cyl_setAnimationImages(['a.png', 'b.png'], 0.2, CYLRefreshState.Idle);
      const images = header.cyl_animationImagesForState(CYLRefreshState.Idle);
      expect(images !== null).assertTrue();
      expect((images as CYLRefreshImage[]).length).assertEqual(2);
      header.cyl_showIdleAnimationFrame();
    });

    it('installsDefaultControlsAndRunsTheInitializerOnce', 0, () => {
      const config = CYLRefreshConfig.defaultConfig;
      let initialized = 0;
      config.defaultHeaderCreator = (scrollView: CYLRefreshScrollViewModel) => new CYLRefreshNormalHeaderModel();
      config.defaultInitializer = (component: CYLRefreshComponentModel) => {
        initialized++;
      };
      const sv = makeScrollView();
      sv.cyl_installDefaultRefreshControls();
      expect(sv.cyl_header !== null).assertTrue();
      expect(sv.cyl_footer === null).assertTrue();
      expect(initialized).assertEqual(1);
      const header = sv.cyl_header as CYLRefreshHeaderModel;
      sv.cyl_header = null;
      sv.cyl_header = header;
      expect(initialized).assertEqual(1);
      config.defaultHeaderCreator = null;
      config.defaultFooterCreator = null;
      config.defaultInitializer = null;
    });

    it('endsTheHeaderAndSetsNoMoreDataAfterADelay', 0, () => {
      const sv = makeScrollView();
      const header = new CYLRefreshNormalHeaderModel();
      const footer = new CYLRefreshAutoNormalFooterModel();
      sv.cyl_header = header;
      sv.cyl_footer = footer;
      header.beginRefreshing();
      sv.cyl_endRefreshingAfterDelay(0, true, true);
      expect(header.state).assertEqual(CYLRefreshState.Idle);
      expect(footer.noMoreData).assertTrue();
      sv.cyl_endRefreshingAfterDelay(0, true, false);
      expect(footer.noMoreData).assertFalse();
      sv.cyl_endLoadingMoreAfterDelay(0, true, true);
      expect(footer.noMoreData).assertTrue();
    });

    it('loadsWhenTheContentDoesNotFillOnlyIfAsked', 0, () => {
      const loads = makeScrollView(300);
      const footer = new CYLRefreshAutoNormalFooterModel();
      loads.cyl_footer = footer;
      loads.cyl_panBegan();
      loads.cyl_panEnded(0, 0);
      expect(footer.state).assertEqual(CYLRefreshState.Refreshing);

      const waits = makeScrollView(300);
      const patient = new CYLRefreshAutoNormalFooterModel();
      patient.loadsWhenContentNotFull = false;
      waits.cyl_footer = patient;
      waits.cyl_panBegan();
      waits.cyl_panEnded(0, 0);
      expect(patient.state).assertEqual(CYLRefreshState.Idle);
    });

    it('exposesThePlaceholderShownForTheList', 0, () => {
      let items = 0;
      const list = new CYLPlaceholderListController(() => items);
      expect(list.cyl_placeholderView === null).assertTrue();
      list.cyl_placeholderViewBlock((t: CYLPlaceholderListController) =>
      CYLPlaceholderStackViewModel.initWithScenario(CYLPlaceholderScenario.NoContent));
      expect(list.cyl_placeholderView !== null).assertTrue();
      items = 3;
      list.reloadData();
      expect(list.cyl_placeholderView === null).assertTrue();
    });
  });
}
