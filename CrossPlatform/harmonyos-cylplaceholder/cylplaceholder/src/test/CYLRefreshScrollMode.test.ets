// Local (host) unit tests of the header scroll modes (Move, Stretch, Front, Behind): the mode names shared with the mini
// program's `scrollMode`, the header geometry per mode and what refreshing does to the content in each mode.
import { describe, expect, it } from '@ohos/hypium';
import {
  CYLRefreshConfig,
  CYLRefreshHeaderHeightFor,
  CYLRefreshHeaderYFor,
  CYLRefreshScrollMode,
  CYLRefreshScrollModeFor,
  CYLRefreshState
} from '../main/ets/refresh/CYLRefreshConst';
import { CYLRefreshScrollViewModel } from '../main/ets/refresh/CYLRefreshComponent';
import { CYLRefreshNormalHeaderModel } from '../main/ets/refresh/CYLRefreshClassics';

/** Pulls a header with `mode` past its trigger, releases it and returns the scroll view. */
function pullAndRelease(header: CYLRefreshNormalHeaderModel, mode: CYLRefreshScrollMode): CYLRefreshScrollViewModel {
  const sv = new CYLRefreshScrollViewModel();
  sv.cyl_reportScroll(0, 0, 400, 600, 400, 1000);
  sv.cyl_setWindow(true);
  header.scrollMode = mode;
  sv.cyl_header = header;
  sv.cyl_panBegan();
  sv.cyl_panChanged(70, 0, 0);
  sv.cyl_panEnded(0, 0);
  return sv;
}

export default function refreshScrollModeTest() {
  describe('CYLRefreshScrollMode', () => {
    it('defaultsToMove', 0, () => {
      CYLRefreshConfig.defaultConfig.languageCode = 'en';
      expect(new CYLRefreshNormalHeaderModel().scrollMode).assertEqual(CYLRefreshScrollMode.Move);
    });

    it('mapsTheMiniProgramNames', 0, () => {
      expect(CYLRefreshScrollModeFor('move')).assertEqual(CYLRefreshScrollMode.Move);
      expect(CYLRefreshScrollModeFor('stretch')).assertEqual(CYLRefreshScrollMode.Stretch);
      expect(CYLRefreshScrollModeFor('front')).assertEqual(CYLRefreshScrollMode.Front);
      expect(CYLRefreshScrollModeFor('behind')).assertEqual(CYLRefreshScrollMode.Behind);
      expect(CYLRefreshScrollModeFor('unknown')).assertEqual(CYLRefreshScrollMode.Move);
      expect(CYLRefreshScrollModeFor(null)).assertEqual(CYLRefreshScrollMode.Move);
      // The older behind flag wins over the name, as in the mini program.
      expect(CYLRefreshScrollModeFor('front', true)).assertEqual(CYLRefreshScrollMode.Behind);
    });

    it('placesTheHeaderPerMode', 0, () => {
      // Move rides above the content: its bottom edge is the revealed area.
      expect(CYLRefreshHeaderHeightFor(CYLRefreshScrollMode.Move, 20, 54)).assertEqual(54);
      expect(CYLRefreshHeaderYFor(CYLRefreshScrollMode.Move, 20, 54, 0)).assertEqual(-34);
      expect(CYLRefreshHeaderYFor(CYLRefreshScrollMode.Move, 20, 54, 10)).assertEqual(-44);
      // Stretch is exactly the revealed area, from 0 when idle.
      expect(CYLRefreshHeaderHeightFor(CYLRefreshScrollMode.Stretch, 20, 54)).assertEqual(20);
      expect(CYLRefreshHeaderHeightFor(CYLRefreshScrollMode.Stretch, -5, 54)).assertEqual(0);
      expect(CYLRefreshHeaderYFor(CYLRefreshScrollMode.Stretch, 20, 54, 0)).assertEqual(0);
      // Front and Behind keep their height and sit at the visible top.
      expect(CYLRefreshHeaderHeightFor(CYLRefreshScrollMode.Front, 20, 54)).assertEqual(54);
      expect(CYLRefreshHeaderYFor(CYLRefreshScrollMode.Front, 20, 54, 0)).assertEqual(0);
      expect(CYLRefreshHeaderHeightFor(CYLRefreshScrollMode.Behind, 20, 54)).assertEqual(54);
      expect(CYLRefreshHeaderYFor(CYLRefreshScrollMode.Behind, 20, 54, 0)).assertEqual(0);
    });

    it('movesTheContentWhileRefreshingExceptInFront', 0, () => {
      const header = new CYLRefreshNormalHeaderModel();
      header.scrollMode = CYLRefreshScrollMode.Move;
      expect(header.cyl_movesContentWhileRefreshing).assertTrue();
      header.scrollMode = CYLRefreshScrollMode.Stretch;
      expect(header.cyl_movesContentWhileRefreshing).assertTrue();
      header.scrollMode = CYLRefreshScrollMode.Behind;
      expect(header.cyl_movesContentWhileRefreshing).assertTrue();
      header.scrollMode = CYLRefreshScrollMode.Front;
      expect(header.cyl_movesContentWhileRefreshing).assertFalse();
      header.scrollMode = CYLRefreshScrollMode.Move;
      header.addsRefreshingInset = false;
      expect(header.cyl_movesContentWhileRefreshing).assertFalse();
    });

    it('refreshesWithoutAnInsetInFront', 0, () => {
      const move = new CYLRefreshNormalHeaderModel();
      const moveView = pullAndRelease(move, CYLRefreshScrollMode.Move);
      expect(move.state).assertEqual(CYLRefreshState.Refreshing);
      expect(moveView.cyl_insetT).assertEqual(54);

      const front = new CYLRefreshNormalHeaderModel();
      const frontView = pullAndRelease(front, CYLRefreshScrollMode.Front);
      expect(front.state).assertEqual(CYLRefreshState.Refreshing);
      expect(frontView.cyl_insetT).assertEqual(0);
    });
  });
}
