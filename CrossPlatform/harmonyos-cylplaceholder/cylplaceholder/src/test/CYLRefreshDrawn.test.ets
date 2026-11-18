// Local (host) unit tests of the drawn CYLRefresh styles styles' logic: the value animator (timing, interpolators,
// repeats, points, delegate), the SVG path parser and vector image sizing, the StoreHouse letter table, the drawn
// header's status order and the game rules.
import { describe, expect, it } from '@ohos/hypium';
import { CYLPoint, CYLSize } from '../main/ets/refresh/CYLRefreshComponent';
import { CYLRefreshPhase } from '../main/ets/refresh/CYLRefreshConst';
import { CYLRefreshAffineTransform, CYLRefreshDrawnColor, CYLRefreshDrawnTween } from '../main/ets/refresh/drawn/CYLRefreshDrawnSupport';
import {
  CYLRefreshAnimatorInterpolator,
  CYLRefreshAnimatorRepeatMode,
  CYLRefreshValueAnimator,
  CYLRefreshValueAnimatorDelegate
} from '../main/ets/refresh/drawn/CYLRefreshValueAnimator';
import {
  CYLRefreshCurveType,
  CYLRefreshMutablePath,
  CYLRefreshScanner,
  CYLRefreshVectorPathsParser
} from '../main/ets/refresh/drawn/CYLRefreshVectorPathsParser';
import { CYLRefreshVectorImage, CYLRefreshVectorPathElement } from '../main/ets/refresh/drawn/CYLRefreshVector';
import {
  CYLRefreshStoreHouseLine,
  CYLRefreshStoreHousePath,
  cylRefreshStoreHouseSetRandom
} from '../main/ets/refresh/drawn/CYLRefreshStoreHouse';
import { CYLRefreshDrawnFooterModel, CYLRefreshDrawnHeaderModel } from '../main/ets/refresh/drawn/CYLRefreshDrawnHeader';
import {
  CYLRefreshBezierCircleHeaderModel,
  CYLRefreshMaterialHeaderModel,
  CYLRefreshOriginalHeaderModel,
  CYLRefreshWaveSwipeHeaderModel
} from '../main/ets/refresh/drawn/CYLRefreshDrawnShapes';
import { CYLRefreshPhoenixHeaderModel, CYLRefreshTaurusHeaderModel } from '../main/ets/refresh/drawn/CYLRefreshDrawnVectors';
import { CYLRefreshStoreHouseHeaderModel } from '../main/ets/refresh/drawn/CYLRefreshStoreHouseHeader';
import { CYLRefreshFlyHeaderModel } from '../main/ets/refresh/drawn/CYLRefreshFly';
import {
  CYLRefreshGameBattleCityHeaderModel,
  CYLRefreshGameBattleCityScene,
  CYLRefreshGameHitBlockHeaderModel,
  CYLRefreshGameHitBlockScene
} from '../main/ets/refresh/drawn/CYLRefreshGame';
import {
  CYLRefreshBezierRadarFooterModel,
  CYLRefreshDeliveryFooterModel,
  CYLRefreshMaterialFooterModel,
  CYLRefreshPhoenixFooterModel,
  CYLRefreshTaurusFooterModel
} from '../main/ets/refresh/drawn/CYLRefreshDrawnFooters';
import { CYLRefreshScrollMode } from '../main/ets/refresh/CYLRefreshConst';
import { CYLRefreshScrollViewModel } from '../main/ets/refresh/CYLRefreshComponent';

let fakeTime: number = 0;

function close(a: number, b: number): boolean {
  return Math.abs(a - b) < 1e-6;
}

export default function refreshDrawnTest() {
  describe('CYLRefreshValueAnimator', () => {
    it('interpolatesFromToOverTheDuration', 0, () => {
      CYLRefreshValueAnimator.clock = () => fakeTime;
      fakeTime = 10;
      const a = CYLRefreshValueAnimator.newWithFrom(0, 100);
      expect(a.value).assertEqual(0);
      a.duration = 2;
      a.start();
      expect(a.isRunning).assertTrue();
      fakeTime = 11;
      a.cyl_step();
      expect(close(a.value, 50)).assertTrue();
      expect(close(a.percent, 0.5)).assertTrue();
      fakeTime = 12.5;
      a.cyl_step();
      expect(close(a.value, 100)).assertTrue();
      expect(a.isRunning).assertFalse();
    });

    it('interpolatorsMatchIOS', 0, () => {
      expect(close(CYLRefreshValueAnimator.interpolate(
        CYLRefreshAnimatorInterpolator.AnimatorInterpolatorAccelerate, 0.5), 0.25)).assertTrue();
      expect(close(CYLRefreshValueAnimator.interpolate(
        CYLRefreshAnimatorInterpolator.AnimatorInterpolatorDecelerate, 0.5), 0.75)).assertTrue();
      expect(Math.abs(CYLRefreshValueAnimator.interpolate(
        CYLRefreshAnimatorInterpolator.AnimatorInterpolatorAccelerateDecelerate, 0.5) - 0.5) < 1e-4).assertTrue();
      expect(Math.abs(CYLRefreshValueAnimator.interpolate(
        CYLRefreshAnimatorInterpolator.AnimatorInterpolatorBounce, 1) - 1) < 0.01).assertTrue();
      const a = CYLRefreshValueAnimator.newWithFrom(0, 1);
      a.interpolatorBlock = (v: number) => v * 3;
      expect(close(a.interpolation(0.25), 0.75)).assertTrue();
    });

    it('repeatsReversingAndCallsTheDelegateAndTarget', 0, () => {
      CYLRefreshValueAnimator.clock = () => fakeTime;
      fakeTime = 0;
      let starts = 0;
      let repeats = 0;
      let ends = 0;
      let steps = 0;
      const delegate: CYLRefreshValueAnimatorDelegate = {
        onAnimationStart: (x: CYLRefreshValueAnimator) => {
          starts++;
        },
        onAnimationRepeat: (x: CYLRefreshValueAnimator) => {
          repeats++;
        },
        onAnimationEnd: (x: CYLRefreshValueAnimator) => {
          ends++;
        }
      };
      const a = CYLRefreshValueAnimator.newWithTarget(delegate, (x: CYLRefreshValueAnimator) => {
        steps++;
      });
      a.setFrom(0, 10);
      a.duration = 1;
      a.repeatCount = 2;
      a.repeatMode = CYLRefreshAnimatorRepeatMode.AnimatorRepeatModeReverse;
      a.delegate = delegate;
      a.start();
      expect(starts).assertEqual(1);
      fakeTime = 1;
      a.cyl_step();
      expect(repeats).assertEqual(1);
      fakeTime = 1.25;
      a.cyl_step();
      expect(close(a.value, 7.5)).assertTrue();
      fakeTime = 2;
      a.cyl_step();
      expect(close(a.value, 0)).assertTrue();
      expect(ends).assertEqual(1);
      expect(steps).assertEqual(3);
      expect(a.isRunning).assertFalse();
    });

    it('goesThroughPoints', 0, () => {
      CYLRefreshValueAnimator.clock = () => fakeTime;
      fakeTime = 0;
      const a = new CYLRefreshValueAnimator();
      a.setFromToPoints([10, 0, -6, 0]);
      expect(a.value).assertEqual(10);
      a.start();
      fakeTime = 0.125;
      a.cyl_step();
      expect(close(a.value, 5)).assertTrue();
      fakeTime = 0.375;
      a.cyl_step();
      expect(close(a.value, -3)).assertTrue();
      a.stop();
      expect(a.isRunning).assertFalse();
    });

    it('tweenRepeatsAndReverses', 0, () => {
      const t = CYLRefreshDrawnTween.repeating(0, 1, 1, (x: number) => x, 1000, true);
      expect(close(t.value(1500), 0.5)).assertTrue();
      expect(close(t.value(2250), 0.75)).assertTrue();
      expect(t.done(100000)).assertFalse();
      const once = new CYLRefreshDrawnTween(2, 4, 0.5, (x: number) => x, 0);
      expect(close(once.value(250), 3)).assertTrue();
      expect(once.done(500)).assertTrue();
    });
  });

  describe('CYLRefreshVectorPathsParser', () => {
    it('readsMovesAndRelativeLines', 0, () => {
      const path = new CYLRefreshMutablePath();
      const curve = CYLRefreshVectorPathsParser.readMovetoDrawToCmdGroups(CYLRefreshScanner.scannerWithString(
        'm10,20 5,0 0,5'), path, new CYLPoint(1, 1), true);
      expect(path.commands.length).assertEqual(3);
      expect(path.commands[0].op).assertEqual('M');
      expect(path.commands[0].values[0]).assertEqual(11);
      expect(path.commands[2].values[0]).assertEqual(16);
      expect(path.commands[2].values[1]).assertEqual(26);
      expect(curve.type).assertEqual(CYLRefreshCurveType.CurveTypePoint);
    });

    it('parsesAPathElementWithCurvesAndClose', 0, () => {
      const e = CYLRefreshVectorPathElement.newWith('M0,0 L10,0 C10,5 5,10 0,10 Z h4 v-2');
      const ops = e.pathForShape.commands.map((c) => c.op).join('');
      expect(ops).assertEqual('MLCZLL');
      expect(e.viewport.width).assertEqual(10);
      expect(e.viewport.height).assertEqual(12);
      const last = e.pathForShape.commands[5].values;
      expect(last[0]).assertEqual(4);
      expect(last[1]).assertEqual(-2);
    });

    it('parsesSmoothCurvesAndQuadratics', 0, () => {
      const e = CYLRefreshVectorPathElement.newWith('M0 0C0 10 10 10 10 0S20 -10 20 0Q25 5 30 0T40 0');
      const c = e.pathForShape.commands;
      expect(c[2].op).assertEqual('C');
      expect(c[2].values[0]).assertEqual(10);
      expect(c[2].values[1]).assertEqual(-10);
      expect(c[4].op).assertEqual('Q');
      expect(c[4].values[0]).assertEqual(35);
      expect(c[4].values[1]).assertEqual(-5);
    });

    it('parsesArcsIntoCubics', 0, () => {
      const e = CYLRefreshVectorPathElement.newWith('M0,10 A10,10 0 0 1 20,10');
      const c = e.pathForShape.commands;
      const end = c[c.length - 1].values;
      expect(c[c.length - 1].op).assertEqual('C');
      expect(Math.abs(end[4] - 20) < 1e-6).assertTrue();
      expect(Math.abs(end[5] - 10) < 1e-6).assertTrue();
      expect(e.viewport.y < 1).assertTrue();
    });

    it('vectorImageSizesFromTheViewport', 0, () => {
      const img = CYLRefreshVectorImage.newWithPaths(['M10,10h20v10h-20z'], ['#ff0000']);
      expect(img.viewport.x).assertEqual(0);
      expect(img.size.width).assertEqual(30);
      img.setGeometricWidth(60);
      expect(img.size.height).assertEqual(40);
      img.moveTo(new CYLPoint(5, 6));
      expect(img.frame.x).assertEqual(5);
      expect(img.frame.width).assertEqual(60);
      img.scaleToFitInside(new CYLSize(30, 10));
      expect(img.size.width).assertEqual(15);
      expect(img.elements[0].fill).assertEqual('#ff0000');
    });

    it('transformsAndColors', 0, () => {
      const t = CYLRefreshAffineTransform.makeTranslation(10, 0).scale(2, 2);
      const p = t.apply(1, 1);
      expect(p.x).assertEqual(12);
      expect(p.y).assertEqual(2);
      expect(CYLRefreshDrawnColor.alpha('#ff0000', 0.5)).assertEqual('rgba(255,0,0,0.5)');
      expect(CYLRefreshDrawnColor.isClear('transparent')).assertTrue();
      expect(CYLRefreshDrawnColor.parse('#80112233')[0]).assertEqual(0x11);
    });
  });

  describe('CYLRefreshStoreHouse', () => {
    it('makesLinesFromAString', 0, () => {
      cylRefreshStoreHouseSetRandom(() => 0.5);
      const lines: CYLRefreshStoreHouseLine[] = CYLRefreshStoreHousePath.linesFrom('T1', 1, 10);
      expect(lines.length).assertEqual(3);
      expect(lines[0].end.x).assertEqual(47 * 0.25);
      expect(lines[2].start.x).assertEqual((67 + 24) * 0.25);
      expect(lines[2].index).assertEqual(2);
      expect(lines[1].middle.y).assertEqual(36 * 0.25);
      expect(lines[0].offset).assertEqual(0.5);
      expect(CYLRefreshStoreHousePath.linesFrom('a?A', 1, 0).length).assertEqual(10);
    });

    it('makesLinesFromPointStrings', 0, () => {
      const lines = CYLRefreshStoreHousePath.linesFromArray(CYLRefreshStoreHousePath.arrayAkta());
      expect(lines.length).assertEqual(16);
      expect(lines[0].start.x).assertEqual(22);
      expect(lines[0].end.y).assertEqual(30);
      expect(CYLRefreshStoreHousePath.linesFromArray(CYLRefreshStoreHousePath.arrayStoreHouse()).length).assertEqual(14);
    });
  });

  describe('CYLRefreshDrawnHeader', () => {
    it('passesThroughReleasingAndFinishing', 0, () => {
      const footer = CYLRefreshDrawnFooterModel.initWithStyle(new CYLRefreshDrawnHeaderModel());
      const style = footer.style as CYLRefreshDrawnHeaderModel;
      expect(style.cyl_driven).assertTrue();
      footer.phaseDidChangeFrom(CYLRefreshPhase.Idle, CYLRefreshPhase.Refreshing);
      expect(style.status).assertEqual(CYLRefreshPhase.Refreshing);
      expect(style.cyl_isRefreshing()).assertTrue();
      footer.refreshDidFinishWithSuccess(false);
      expect(style.status).assertEqual(CYLRefreshPhase.Finishing);
      expect(style.isSuccess).assertFalse();
      footer.phaseDidChangeFrom(CYLRefreshPhase.Finishing, CYLRefreshPhase.Idle);
      expect(style.status).assertEqual(CYLRefreshPhase.Idle);
      expect(style.inStatus(CYLRefreshPhase.Refreshing, CYLRefreshPhase.Idle)).assertTrue();
      style.height = 80;
      expect(style.expandHeight).assertEqual(80);
      expect(style.durationNormal).assertEqual(0.25);
    });
  });

  describe('CYLRefreshDrawnStyles', () => {
    it('stylesKeepTheIOSSizesAndModes', 0, () => {
      expect(new CYLRefreshBezierCircleHeaderModel().expandHeight).assertEqual(100);
      expect(new CYLRefreshBezierCircleHeaderModel().scrollMode).assertEqual(CYLRefreshScrollMode.Stretch);
      expect(new CYLRefreshMaterialHeaderModel().scrollMode).assertEqual(CYLRefreshScrollMode.Front);
      expect(new CYLRefreshWaveSwipeHeaderModel().expandHeight).assertEqual(120);
      expect(new CYLRefreshOriginalHeaderModel().expandHeight).assertEqual(64);
      expect(new CYLRefreshOriginalHeaderModel().enableAutoRefresh).assertTrue();
      expect(new CYLRefreshTaurusHeaderModel().finishDuration).assertEqual(0.3);
      expect(new CYLRefreshPhoenixHeaderModel().colorPrimary).assertEqual('#38adc1');
      expect(new CYLRefreshGameHitBlockHeaderModel().scrollMode).assertEqual(CYLRefreshScrollMode.Move);
      expect(new CYLRefreshDeliveryFooterModel().expandHeight).assertEqual(150);
      expect(new CYLRefreshBezierRadarFooterModel().style !== null).assertTrue();
      expect(new CYLRefreshMaterialFooterModel().expandHeight).assertEqual(80);
      expect(new CYLRefreshPhoenixFooterModel().style !== null).assertTrue();
      expect(new CYLRefreshTaurusFooterModel().style !== null).assertTrue();
    });

    it('storeHouseHeaderSizesToItsText', 0, () => {
      const header = new CYLRefreshStoreHouseHeaderModel();
      expect(header.lines.length > 0).assertTrue();
      expect(header.expandHeight).assertEqual(18 * 1.5 * 2 + 18);
      expect(header.finishDuration).assertEqual(0.5);
      header.enableFadeAnimation = false;
      expect(header.finishDuration).assertEqual(0);
      const big = CYLRefreshStoreHouseHeaderModel.newWithString('AB', 2, 10);
      expect(big.expandHeight).assertEqual(10 * 2 + 36);
      big.initLinesWithArray(CYLRefreshStoreHousePath.arrayStoreHouse());
      expect(big.lines.length).assertEqual(14);
      big.updateLinesWithProgress(1);
      expect(big.lines[0].alpha).assertEqual(0.4);
      expect(big.lines[0].transform.isIdentity()).assertTrue();
    });

    it('flyHeaderStaysOpen', 0, () => {
      const sv = new CYLRefreshScrollViewModel();
      const fly = new CYLRefreshFlyHeaderModel();
      sv.cyl_header = fly;
      expect(sv.cyl_insetT).assertEqual(150);
      expect(fly.addsRefreshingInset).assertFalse();
      sv.cyl_header = null;
      expect(sv.cyl_insetT).assertEqual(0);
    });

    it('hitBlockRules', 0, () => {
      CYLRefreshGameHitBlockScene.random = () => 0;
      const scene = new CYLRefreshGameHitBlockScene();
      scene.width = 300;
      scene.height = 100;
      scene.reset();
      expect(scene.blocks.length).assertEqual(15);
      expect(scene.title).assertEqual('None');
      scene.moveHandle(1);
      expect(scene.paddle.y).assertEqual(85);
      scene.moveHandle(0);
      expect(scene.paddle.y).assertEqual(15);
      scene.start();
      expect(scene.ball.vx < 0).assertTrue();
      for (let i = 0; i < 200 && scene.blocks.length === 15; i++) {
        scene.update(0.016);
      }
      expect(scene.blocks.length).assertEqual(14);
      expect(scene.ball.vx > 0).assertTrue();
      for (let i = 0; i < 400 && !scene.ballHidden; i++) {
        scene.update(0.016);
      }
      expect(scene.title).assertEqual('Game Over');
      scene.reset();
      scene.blocks = [];
      scene.start();
      scene.update(0.016);
      expect(scene.title).assertEqual('Game Win');
    });

    it('battleCityRules', 0, () => {
      CYLRefreshGameBattleCityScene.randomRow = () => 0;
      const scene = new CYLRefreshGameBattleCityScene();
      scene.width = 300;
      scene.height = 90;
      scene.reset();
      scene.moveHandle(1);
      expect(scene.player.y).assertEqual(75);
      scene.start();
      scene.update(0.016);
      expect(scene.enemies.length).assertEqual(1);
      expect(scene.bullets.length).assertEqual(1);
      for (let i = 0; i < 600 && scene.isGameRunning; i++) {
        scene.update(0.016);
      }
      expect(scene.isGameRunning).assertTrue();
      scene.moveHandle(0);
      for (let i = 0; i < 600 && scene.isGameRunning; i++) {
        scene.update(0.016);
      }
      expect(scene.title === 'Game Over' || scene.isGameRunning).assertTrue();
      scene.finishWithSuccess(true);
      expect(scene.title).assertEqual('Loading Finished');
      expect(new CYLRefreshGameBattleCityHeaderModel().scenePlaying instanceof CYLRefreshGameBattleCityScene).assertTrue();
    });
  });
}
