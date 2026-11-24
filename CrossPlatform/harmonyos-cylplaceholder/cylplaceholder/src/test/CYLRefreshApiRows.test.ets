// Local (host) unit tests of the CYLRefresh / CYLPlaceholderStackView API rows written statically (not built, not run
// when written; docs/HarmonyOS.md "written, not built"): insetStart, clipsWhenBehind, disablesContentWhileRefreshing,
// pinnedView / translationView, the horizontal drag data path, the NoMoreDataImage footer methods, BallPulse, the
// Material size and colors, the WaveSwipe shadow and the stack view's accessors.
import { describe, expect, it } from '@ohos/hypium';
import {
  CYLRefreshBackFooterModel,
  CYLRefreshLabel,
  CYLRefreshScrollViewModel,
  CYLRefreshViewModel,
  CYLSize
} from '../main/ets/refresh/CYLRefreshComponent';
import {
  CYLRefreshConfig,
  CYLRefreshFooterYFor,
  CYLRefreshHeaderClipHeightFor,
  CYLRefreshHeaderYFor,
  CYLRefreshScrollMode,
  CYLRefreshState
} from '../main/ets/refresh/CYLRefreshConst';
import {
  CYLRefreshAutoNormalFooterModel,
  CYLRefreshNormalHeaderModel
} from '../main/ets/refresh/CYLRefreshClassics';
import {
  CYLRefreshBallPulseCenterX,
  CYLRefreshBallPulseFooterModel,
  CYLRefreshBallPulseRadius,
  CYLRefreshBallPulseScale
} from '../main/ets/refresh/drawn/CYLRefreshBallPulse';
import {
  CYLRefreshMaterialCircleSize,
  CYLRefreshMaterialHeaderModel,
  CYLRefreshMaterialSize,
  CYLRefreshWaveShadowBlur,
  CYLRefreshWaveShadowDefaultColor,
  CYLRefreshWaveShadowDefaultRadius,
  CYLRefreshWaveSwipeHeaderModel
} from '../main/ets/refresh/drawn/CYLRefreshDrawnShapes';
import { CYLRefreshFlyHeaderModel } from '../main/ets/refresh/drawn/CYLRefreshFly';
import { CYLPlaceholderButtonStyle, CYLPlaceholderComponent } from '../main/ets/CYLPlaceholderScenario';
import { CYLPlaceholderStackViewModel } from '../main/ets/CYLPlaceholderStackView';

class DragRecordingHeader extends CYLRefreshNormalHeaderModel {
  drags: number[] = [];

  didDragHorizontally(offset: number, percent: number): void {
    this.drags.push(offset);
  }
}

function makeScrollView(): CYLRefreshScrollViewModel {
  const sv = new CYLRefreshScrollViewModel();
  sv.cyl_reportScroll(0, 0, 400, 600, 400, 1000);
  sv.cyl_setWindow(true);
  return sv;
}

export default function refreshApiRowsTest() {
  describe('CYLRefreshApiRows', () => {
    it('movesTheHeaderIntoTheContentByInsetStart', 0, () => {
      expect(CYLRefreshHeaderYFor(CYLRefreshScrollMode.Move, 20, 54, 0, 10)).assertEqual(-24);
      expect(CYLRefreshHeaderYFor(CYLRefreshScrollMode.Move, 20, 54, 0)).assertEqual(-34);
      // Stretch ignores insetStart; Front and Behind sit at insetStart.
      expect(CYLRefreshHeaderYFor(CYLRefreshScrollMode.Stretch, 20, 54, 0, 10)).assertEqual(0);
      expect(CYLRefreshHeaderYFor(CYLRefreshScrollMode.Front, 20, 54, 0, 10)).assertEqual(10);
      expect(CYLRefreshHeaderYFor(CYLRefreshScrollMode.Behind, 20, 54, 0, 10)).assertEqual(10);
      expect(CYLRefreshFooterYFor(600, 25, 8)).assertEqual(567);
      expect(CYLRefreshFooterYFor(600, 25)).assertEqual(575);
    });

    it('placesTheModelsAtInsetStart', 0, () => {
      const sv = makeScrollView();
      const header = new CYLRefreshNormalHeaderModel();
      sv.cyl_header = header;
      header.insetStart = 10;
      header.placeSubviews();
      expect(header.cyl_y).assertEqual(-header.cyl_h + 10);
      const footer = new CYLRefreshBackFooterModel();
      sv.cyl_footer = footer;
      footer.scrollViewContentSizeDidChange();
      const before = footer.cyl_y;
      footer.insetStart = 8;
      footer.scrollViewContentSizeDidChange();
      expect(footer.cyl_y).assertEqual(before - 8);
    });

    it('clipsABehindHeaderToTheRevealedPart', 0, () => {
      expect(new CYLRefreshNormalHeaderModel().clipsWhenBehind).assertFalse();
      expect(CYLRefreshHeaderClipHeightFor(CYLRefreshScrollMode.Behind, true, 20, 54)).assertEqual(20);
      expect(CYLRefreshHeaderClipHeightFor(CYLRefreshScrollMode.Behind, true, 80, 54)).assertEqual(54);
      expect(CYLRefreshHeaderClipHeightFor(CYLRefreshScrollMode.Behind, true, -5, 54)).assertEqual(0);
      expect(CYLRefreshHeaderClipHeightFor(CYLRefreshScrollMode.Behind, false, 20, 54)).assertEqual(54);
      expect(CYLRefreshHeaderClipHeightFor(CYLRefreshScrollMode.Front, true, 20, 54)).assertEqual(54);
    });

    it('turnsTheContentTouchesOffWhileRefreshing', 0, () => {
      const sv = makeScrollView();
      const header = new CYLRefreshNormalHeaderModel();
      sv.cyl_header = header;
      expect(header.disablesContentWhileRefreshing).assertFalse();
      header.beginRefreshing();
      expect(sv.interactionEnabled).assertTrue();
      header.endRefreshing();

      header.disablesContentWhileRefreshing = true;
      header.beginRefreshing();
      expect(header.state).assertEqual(CYLRefreshState.Refreshing);
      expect(sv.interactionEnabled).assertFalse();
      header.endRefreshing();
      expect(sv.interactionEnabled).assertTrue();
    });

    it('givesTheTouchesBackWhenTheFlagIsClearedOrTheHeaderDetaches', 0, () => {
      const sv = makeScrollView();
      const header = new CYLRefreshNormalHeaderModel();
      header.disablesContentWhileRefreshing = true;
      sv.cyl_header = header;
      header.beginRefreshing();
      expect(sv.interactionEnabled).assertFalse();
      header.disablesContentWhileRefreshing = false;
      expect(sv.interactionEnabled).assertTrue();
      header.disablesContentWhileRefreshing = true;
      expect(sv.interactionEnabled).assertFalse();
      sv.cyl_header = null;
      expect(sv.interactionEnabled).assertTrue();
    });

    it('translatesThePinnedAndTheTranslationViewWithThePull', 0, () => {
      const sv = makeScrollView();
      const header = new CYLRefreshNormalHeaderModel();
      const pinned = new CYLRefreshViewModel();
      const moving = new CYLRefreshViewModel();
      header.pinnedView = pinned;
      header.translationView = moving;
      sv.cyl_header = header;
      sv.cyl_panBegan();
      sv.cyl_panChanged(30, 0, 0);
      expect(header.cyl_pulledDistance()).assertEqual(30);
      expect(pinned.cyl_translateY).assertEqual(-30);
      expect(moving.cyl_translateY).assertEqual(30);
      sv.cyl_panChanged(10, 0, 0);
      expect(pinned.cyl_translateY).assertEqual(-10);
    });

    it('pullsAFooterTheOtherWay', 0, () => {
      const sv = new CYLRefreshScrollViewModel();
      sv.cyl_reportScroll(0, 400, 400, 600, 400, 1000);
      sv.cyl_setWindow(true);
      const footer = new CYLRefreshAutoNormalFooterModel();
      const pinned = new CYLRefreshViewModel();
      footer.pinnedView = pinned;
      sv.cyl_footer = footer;
      sv.cyl_offsetY = 425;
      expect(footer.cyl_pulledDistance()).assertEqual(25);
      footer.cyl_followPull();
      expect(pinned.cyl_translateY).assertEqual(25);
    });

    it('reportsTheHorizontalDragOnlyWhenAsked', 0, () => {
      const asked = makeScrollView();
      const header = new DragRecordingHeader();
      header.supportsHorizontalDrag = true;
      asked.cyl_header = header;
      asked.cyl_panBegan();
      asked.panTranslationX = 12;
      asked.cyl_panChanged(40, 0, 0);
      expect(header.drags.length > 0).assertTrue();
      expect(header.drags[header.drags.length - 1]).assertEqual(12);

      const off = makeScrollView();
      const quiet = new DragRecordingHeader();
      off.cyl_header = quiet;
      off.cyl_panBegan();
      off.panTranslationX = 12;
      off.cyl_panChanged(40, 0, 0);
      expect(quiet.drags.length).assertEqual(0);
    });

    it('showsTheNoMoreDataImageOnlyWithNoMoreData', 0, () => {
      const sv = makeScrollView();
      const footer = new CYLRefreshAutoNormalFooterModel();
      sv.cyl_footer = footer;
      footer.cyl_updateNoMoreDataImage('done.png');
      expect(footer.cyl_noMoreDataImageView === null).assertTrue();
      footer.endRefreshingWithNoMoreData();
      footer.cyl_updateNoMoreDataImage('done.png');
      const view = footer.cyl_noMoreDataImageView;
      expect(view !== null).assertTrue();
      expect((view as CYLRefreshViewModel).hidden).assertFalse();
      footer.cyl_updateNoMoreDataImage(null);
      expect((view as CYLRefreshViewModel).hidden).assertTrue();
    });

    it('placesTheNoMoreDataImageBesideTheLabel', 0, () => {
      const sv = makeScrollView();
      const footer = new CYLRefreshAutoNormalFooterModel();
      sv.cyl_footer = footer;
      footer.endRefreshingWithNoMoreData();
      footer.cyl_w = 300;
      footer.cyl_h = 60;
      footer.cyl_updateNoMoreDataImage('done.png');
      const label = CYLRefreshLabel.cyl_label();
      label.text = 'No more data';
      footer.cyl_placeNoMoreDataImageBesideLabel(label, 6, new CYLSize(20, 10));
      const view = footer.cyl_noMoreDataImageView as CYLRefreshViewModel;
      expect(view.cyl_w).assertEqual(20);
      expect(view.cyl_h).assertEqual(10);
      expect(view.cyl_x).assertEqual(150 - (6 + label.cyl_textWidth() / 2) - 10);
      expect(view.cyl_y).assertEqual(25);
      label.hidden = true;
      footer.cyl_placeNoMoreDataImageBesideLabel(label, 6, new CYLSize(20, 10));
      expect(view.cyl_x).assertEqual(140);
      // A zero size is the documented fallback: 0 x 0.
      footer.cyl_placeNoMoreDataImageBesideLabel(null, 6, new CYLSize(0, 0));
      expect(view.cyl_w).assertEqual(0);
    });

    it('laysTheBallPulseBallsOut', 0, () => {
      const radius = CYLRefreshBallPulseRadius(100, 60);
      expect(radius).assertEqual(52 / 6);
      expect(CYLRefreshBallPulseCenterX(100, radius, 1)).assertEqual(50);
      expect(CYLRefreshBallPulseCenterX(100, radius, 1) - CYLRefreshBallPulseCenterX(100, radius, 0))
        .assertEqual(radius * 2 + 4);
      expect(CYLRefreshBallPulseCenterX(100, radius, 2) - 50).assertEqual(50 - CYLRefreshBallPulseCenterX(100, radius, 0));
    });

    it('pulsesTheBallsInTurn', 0, () => {
      for (let i = 0; i < 3; i++) {
        // A ball waits its turn at full size, then stays within 0.3..1.
        expect(CYLRefreshBallPulseScale(0, i)).assertEqual(1);
        for (let t = 0; t < 3; t += 0.05) {
          const scale = CYLRefreshBallPulseScale(t, i);
          expect(scale >= 0.3 - 1e-9 && scale <= 1 + 1e-9).assertTrue();
        }
      }
      // The second ball is the first one 0.12 s later.
      expect(Math.abs(CYLRefreshBallPulseScale(0.5, 1) - CYLRefreshBallPulseScale(0.38, 0)) < 1e-9).assertTrue();
    });

    it('colorsTheBallPulseFooterByState', 0, () => {
      CYLRefreshConfig.defaultConfig.languageCode = 'en';
      const sv = makeScrollView();
      const footer = new CYLRefreshBallPulseFooterModel();
      sv.cyl_footer = footer;
      expect(footer.cyl_h).assertEqual(60);
      expect(footer.normalColor).assertEqual('#EEEEEE');
      expect(footer.animatingColor).assertEqual('#E75946');
      expect(footer.cyl_ballColor).assertEqual('#EEEEEE');
      expect(footer.cyl_accessibilityLabel === null).assertTrue();
      footer.normalColor = '#111111';
      footer.animatingColor = '#222222';
      footer.state = CYLRefreshState.Refreshing;
      expect(footer.cyl_ballColor).assertEqual('#222222');
      expect(footer.cyl_pulsing).assertTrue();
      expect(footer.cyl_accessibilityLabel !== null && (footer.cyl_accessibilityLabel as string).length > 0)
        .assertTrue();
      footer.state = CYLRefreshState.Idle;
      expect(footer.cyl_ballColor).assertEqual('#111111');
      footer.endRefreshingWithNoMoreData();
      expect(footer.cyl_ballsHidden).assertTrue();
    });

    it('sizesTheMaterialSpinner', 0, () => {
      expect(CYLRefreshMaterialCircleSize(CYLRefreshMaterialSize.Default)).assertEqual(40);
      expect(CYLRefreshMaterialCircleSize(CYLRefreshMaterialSize.Large)).assertEqual(56);
      const header = new CYLRefreshMaterialHeaderModel();
      expect(header.progressSize).assertEqual(CYLRefreshMaterialSize.Default);
      expect(header.cyl_h).assertEqual(80);
      header.progressSize = CYLRefreshMaterialSize.Large;
      expect(header.cyl_h).assertEqual(112);
      header.progressSize = CYLRefreshMaterialSize.Default;
      expect(header.cyl_h).assertEqual(80);
    });

    it('takesTheMaterialSchemeColorsAndIgnoresAnEmptyList', 0, () => {
      const header = new CYLRefreshMaterialHeaderModel();
      expect(header.colorSchemeColors.length).assertEqual(5);
      expect(header.colorSchemeColors[0]).assertEqual('#0099cc');
      header.colorSchemeColors = [];
      expect(header.colorSchemeColors.length).assertEqual(5);
      header.colorSchemeColors = ['#111111', '#222222'];
      expect(header.colorSchemeColors.length).assertEqual(2);
      expect(header.colorSchemeColors[1]).assertEqual('#222222');
    });

    it('keepsTheWaveShadowDefaultsOfTheOldDrawing', 0, () => {
      const header = new CYLRefreshWaveSwipeHeaderModel();
      expect(header.waveShadowRadius).assertEqual(1.5);
      expect(header.waveShadowColor).assertEqual('rgba(0,0,0,0.3)');
      // The old drawing used a blur of 3 and rgba(0,0,0,0.3).
      expect(CYLRefreshWaveShadowBlur(CYLRefreshWaveShadowDefaultRadius)).assertEqual(3);
      expect(CYLRefreshWaveShadowDefaultColor).assertEqual('rgba(0,0,0,0.3)');
      expect(CYLRefreshWaveShadowBlur(-1)).assertEqual(0);
      header.waveShadowRadius = 4;
      header.waveShadowColor = 'rgba(255,0,0,0.5)';
      expect(CYLRefreshWaveShadowBlur(header.waveShadowRadius)).assertEqual(8);
      expect(header.waveShadowColor).assertEqual('rgba(255,0,0,0.5)');
    });

    it('exposesTheFlyHeaderFloatView', 0, () => {
      const header = new CYLRefreshFlyHeaderModel();
      expect(header.floatView.size).assertEqual(50);
      expect(header.floatView.centerX()).assertEqual(37.5);
      expect(header.floatView.hidden).assertFalse();
      expect(header.floatView.alpha).assertEqual(1);
      expect(header.floatView.color === null).assertTrue();
    });

    it('findsTheStackViewsImageTitleHintAndButton', 0, () => {
      const stack = CYLPlaceholderStackViewModel.initWithComponents([
        CYLPlaceholderComponent.iconComponent('wifi_off', 'Offline'),
        CYLPlaceholderComponent.hintComponentWithText('Check the network'),
        CYLPlaceholderComponent.buttonComponentWithTitle('Retry', CYLPlaceholderButtonStyle.Filled, null)
      ]);
      expect(stack.imageView === stack.entries[0].view).assertTrue();
      expect(stack.titleLabel.text).assertEqual('Offline');
      expect(stack.hintLabel !== null && stack.hintLabel.text === 'Check the network').assertTrue();
      expect(stack.button !== null && stack.button.text === 'Retry').assertTrue();
    });

    it('fallsBackToTheReservedComponentWithoutAnImageOrExtras', 0, () => {
      const stack = CYLPlaceholderStackViewModel.initWithComponents([
        CYLPlaceholderComponent.textComponent('Only a title')
      ]);
      expect(stack.imageView === stack.placeholderView).assertTrue();
      expect(stack.titleLabel.text).assertEqual('Only a title');
      expect(stack.hintLabel === null).assertTrue();
      expect(stack.button === null).assertTrue();
    });
  });
}
