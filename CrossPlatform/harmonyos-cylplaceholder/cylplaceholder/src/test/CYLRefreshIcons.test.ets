// Local (host) unit tests of the refresh icon engines and playback policy, the right-to-left flips of the
// controls, the image bundle lookup of components and the Rive view-model options.
import { describe, expect, it } from '@ohos/hypium';
import {
  CYLPlaceholderAnimationContentView,
  CYLPlaceholderItemAnimationViewProviding,
  CYLPlaceholderItemAnimatorRegistry,
  CYLPlaceholderItemViewAnimator
} from '../main/ets/CYLPlaceholderAnimation';
import { CYLRefreshState } from '../main/ets/refresh/CYLRefreshConst';
import { CYLRefreshScrollViewModel } from '../main/ets/refresh/CYLRefreshComponent';
import {
  CYLRefreshAnimationHeaderModel,
  CYLRefreshBackNormalFooterModel,
  CYLRefreshNormalHeaderModel
} from '../main/ets/refresh/CYLRefreshClassics';
import {
  CYLRefreshIconAttributes,
  CYLRefreshIconEngine,
  CYLRefreshIconPlayback,
  CYLRefreshIconPlaybackFor
} from '../main/ets/refresh/CYLRefreshIconView';
import {
  CYLPlaceholderImageBundle,
  CYLPlaceholderImageResourceManager,
  CYLPlaceholderResolveImage
} from '../main/ets/CYLPlaceholderImages';
import { CYLPlaceholderViewModel } from '../main/ets/CYLPlaceholderView';
import { CYLPlaceholderItemImage, CYLPlaceholderItemTitle } from '../main/ets/CYLPlaceholderViewTypes';
import {
  CYLRiveActivePropertyPath,
  CYLRiveColorValue,
  CYLRiveNextNumber,
  CYLRiveTriggerPropertyPath,
  CYLRiveUsesLegacyRuntime
} from '../main/ets/CYLRiveOptions';

class NoViewProvider implements CYLPlaceholderItemAnimationViewProviding {
  cyl_animationViewWithFileURL(fileURL: string, options: Record<string, string>,
    contentMode: ImageFit): CYLPlaceholderAnimationContentView | null {
    return null;
  }
}

class FakeManager implements CYLPlaceholderImageResourceManager {
  getMediaBase64ByNameSync(resName: string): string {
    if (resName === 'feature_empty') {
      return 'data:image/png;base64,AAAA';
    }
    throw new Error('not found');
  }
}

function attributes(filePath: string): CYLRefreshIconAttributes {
  const a = new CYLRefreshIconAttributes();
  a.filePath = filePath;
  return a;
}

export default function refreshIconsTest() {
  describe('CYLRefreshIcons', () => {
    it('selectsIconEngines', 0, () => {
      const registry = new CYLPlaceholderItemAnimatorRegistry();
      registry.registerAnimator(new CYLPlaceholderItemViewAnimator('FakeLottie', ['json'], null, new NoViewProvider()));
      expect(new CYLRefreshIconAttributes().engine(registry)).assertEqual(CYLRefreshIconEngine.None);
      const frames = new CYLRefreshIconAttributes();
      frames.images = ['a.png', 'b.png'];
      expect(frames.engine(registry)).assertEqual(CYLRefreshIconEngine.Frames);
      expect(attributes('x/CYLRefreshArc.json').engine(registry)).assertEqual(CYLRefreshIconEngine.Animator);
      // No GIF animator in this registry: ArkUI Image draws it.
      expect(attributes('x/CYLRefreshRing.gif').engine(registry)).assertEqual(CYLRefreshIconEngine.Image);
      expect(attributes('x/CYLRefreshIcon.riv').engine(registry)).assertEqual(CYLRefreshIconEngine.None);
      registry.registerAnimator(new CYLPlaceholderItemViewAnimator('FakeGIF', ['gif'], null, new NoViewProvider()));
      expect(attributes('x/CYLRefreshRing.gif').engine(registry)).assertEqual(CYLRefreshIconEngine.Animator);
      const rive = attributes('x/CYLRefreshIcon.riv');
      rive.options = { 'artboard': 'refresh' };
      expect((rive.animationURL as string).indexOf('artboard=refresh') >= 0).assertTrue();
    });

    it('followsThePlaybackPolicy', 0, () => {
      expect(CYLRefreshIconPlaybackFor(CYLRefreshState.Idle, 0, true, true)).assertEqual(CYLRefreshIconPlayback.Stop);
      expect(CYLRefreshIconPlaybackFor(CYLRefreshState.Idle, 0.4, true, true)).assertEqual(CYLRefreshIconPlayback.Scrub);
      expect(CYLRefreshIconPlaybackFor(CYLRefreshState.Idle, 0.4, true, false)).assertEqual(CYLRefreshIconPlayback.Play);
      expect(CYLRefreshIconPlaybackFor(CYLRefreshState.Idle, 0.4, false, true)).assertEqual(CYLRefreshIconPlayback.Play);
      expect(CYLRefreshIconPlaybackFor(CYLRefreshState.Pulling, 1, true, true)).assertEqual(CYLRefreshIconPlayback.Play);
      expect(CYLRefreshIconPlaybackFor(CYLRefreshState.Refreshing, 0, true, true)).assertEqual(CYLRefreshIconPlayback.Play);
      expect(CYLRefreshIconPlaybackFor(CYLRefreshState.WillRefresh, 0, true, true)).assertEqual(CYLRefreshIconPlayback.Play);
      expect(CYLRefreshIconPlaybackFor(CYLRefreshState.NoMoreData, 1, true, true)).assertEqual(CYLRefreshIconPlayback.Stop);
    });

    it('flipsViewsInAMirroredLayout', 0, () => {
      const sv = new CYLRefreshScrollViewModel();
      sv.cyl_reportScroll(0, 0, 400, 600, 400, 1000);
      const header = new CYLRefreshNormalHeaderModel();
      sv.cyl_header = header;
      expect(header.flipsHorizontallyInOppositeLayoutDirectionViews.length).assertEqual(3);
      expect(header.cyl_flipScaleX(header.stateLabel)).assertEqual(1);
      sv.flipsHorizontallyInOppositeLayoutDirection = true;
      expect(header.cyl_flipScaleX(header.stateLabel)).assertEqual(-1);
      expect(header.cyl_flipScaleX(header.lastUpdatedTimeLabel)).assertEqual(-1);
      expect(header.cyl_flipScaleX(header.arrowView)).assertEqual(-1);
      expect(header.cyl_flipScaleX(header.loadingView)).assertEqual(1);
      header.additionalFlipsViews = [header.loadingView];
      expect(header.cyl_flipScaleX(header.loadingView)).assertEqual(-1);
      const animated = new CYLRefreshAnimationHeaderModel();
      expect(animated.flipsHorizontallyInOppositeLayoutDirectionViews.includes(animated.animationView)).assertTrue();
      // Not attached to a scroll view: nothing flips.
      expect(animated.cyl_flipScaleX(animated.animationView)).assertEqual(1);
      const back = new CYLRefreshBackNormalFooterModel();
      expect(back.flipsHorizontallyInOppositeLayoutDirectionViews.length).assertEqual(2);
    });

    it('looksUpImagesInTheImageBundle', 0, () => {
      const bundle = CYLPlaceholderImageBundle.bundleWithResourceManager(new FakeManager());
      expect(bundle.imageNamed('feature_empty')).assertEqual('data:image/png;base64,AAAA');
      expect(bundle.imageNamed('missing')).assertNull();
      expect(CYLPlaceholderResolveImage('feature_empty', bundle)).assertEqual('data:image/png;base64,AAAA');
      expect(CYLPlaceholderResolveImage('/data/x.png', null)).assertEqual('/data/x.png');
      expect(CYLPlaceholderResolveImage('wifi_off', null) !== 'wifi_off').assertTrue();
      const found: Record<string, Object> = {};
      found[CYLPlaceholderItemImage] = 'feature_empty';
      found[CYLPlaceholderItemTitle] = 'Nothing here';
      const view = CYLPlaceholderViewModel.initWithItemAttributes(found, bundle);
      expect(view !== null).assertTrue();
      expect((view as CYLPlaceholderViewModel).currentImage).assertEqual('data:image/png;base64,AAAA');
      let error = '';
      const missing: Record<string, Object> = {};
      missing[CYLPlaceholderItemImage] = 'missing';
      const none = CYLPlaceholderViewModel.initWithItemAttributes(missing,
        CYLPlaceholderImageBundle.bundleWithLookup((name: string) => null), (m: string) => {
          error = m;
        });
      expect(none).assertNull();
      expect(error.indexOf('missing') >= 0).assertTrue();
    });

    // CYLTabBarController 6a9ede85: each play sets numberInput to the next of `values`, cycling.
    it('stepsRiveNumberInputValues', 0, () => {
      expect(CYLRiveNextNumber('3,4,5,6', undefined)).assertEqual(3);
      expect(CYLRiveNextNumber('3,4,5,6', 3)).assertEqual(4);
      expect(CYLRiveNextNumber('3, 4, 5, 6', 6)).assertEqual(3);
      expect(CYLRiveNextNumber('3,4,5,6', 9)).assertEqual(3);
      expect(CYLRiveNextNumber(undefined, 2)).assertEqual(3);
      expect(CYLRiveNextNumber('x,', undefined)).assertEqual(1);
    });

    it('readsRiveViewModelOptions', 0, () => {
      expect(CYLRiveUsesLegacyRuntime({})).assertFalse();
      expect(CYLRiveUsesLegacyRuntime({ 'legacy': '1' })).assertTrue();
      expect(CYLRiveUsesLegacyRuntime({ 'legacy': '0' })).assertFalse();
      expect(CYLRiveUsesLegacyRuntime({ 'animation': 'idle' })).assertTrue();
      expect(CYLRiveUsesLegacyRuntime({ 'input': 'on' })).assertTrue();
      expect(CYLRiveUsesLegacyRuntime({ 'triggerInput': 'go' })).assertTrue();
      expect(CYLRiveUsesLegacyRuntime({ 'numberInput': 'Rooms' })).assertTrue();
      expect(CYLRiveActivePropertyPath({})).assertEqual('active');
      expect(CYLRiveActivePropertyPath({ 'active': 'isOn' })).assertEqual('isOn');
      expect(CYLRiveTriggerPropertyPath({})).assertNull();
      expect(CYLRiveTriggerPropertyPath({ 'trigger': 'fire' })).assertEqual('fire');
      expect(CYLRiveColorValue({})).assertNull();
      expect(CYLRiveColorValue({ 'color': '#FF0000' })).assertEqual(0xFFFF0000);
      expect(CYLRiveColorValue({ 'color': '00FF0080' })).assertEqual(0x8000FF00);
      expect(CYLRiveColorValue({ 'color': '#12345' })).assertNull();
      expect(CYLRiveColorValue({ 'color': 'zzzzzz' })).assertNull();
    });
  });
}
