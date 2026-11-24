// Local (host) unit tests of animation playback logic: URL helpers, the animator registry and factory, the view
// animator, CYLPlaceholderAnimationViewModel's checks, repeat counts, fallbacks and the HUD's animation files. The
// engines' native libraries are not loaded here (fake animators stand in for them).
import { describe, expect, it } from '@ohos/hypium';
import { fileIo } from '@kit.CoreFileKit';
import {
  CYLPlaceholderAnimationBackend,
  CYLPlaceholderAnimationColors,
  CYLPlaceholderAnimationContentView,
  CYLPlaceholderAnimationError,
  CYLPlaceholderAnimationErrorCode,
  CYLPlaceholderAnimationExtensionOfURL,
  CYLPlaceholderAnimationFileOfURL,
  CYLPlaceholderAnimationOptionsOfURL,
  CYLPlaceholderAnimationPlayer,
  CYLPlaceholderAnimationURLWithOptions,
  CYLPlaceholderAnimationViewModel,
  CYLPlaceholderItemAnimationFactory,
  CYLPlaceholderItemAnimationPlayer,
  CYLPlaceholderItemAnimationViewProviding,
  CYLPlaceholderItemAnimator,
  CYLPlaceholderItemAnimatorPriorityDefault,
  CYLPlaceholderItemAnimatorPriorityFallback,
  CYLPlaceholderItemAnimatorRegistry,
  CYLPlaceholderItemViewAnimator,
  CYLPlaceholderPlayableContentView,
  CYLPlaceholderRegisterAnimatedItemType
} from '../main/ets/CYLPlaceholderAnimation';
import { CYLAnimatedItemEngines, cylAnimatedItemTypeOf } from 'cylanimateditem';
import { CYLAnimatedItemEnginePlaceholderAnimator, CYLAnimatedItemEngineContentView } from '../main/ets/CYLAnimatedItemEnginePlaceholderAnimator';
import { CYLAnimatedItemGIF } from 'cylanimateditem';
import { CYLPlaceholderViewModel, CYLScenarioIsLineIcon, CYLScenarioLineIconColor } from '../main/ets/CYLPlaceholderView';
import { CYLPlaceholderHUD, CYLPlaceholderHUDState } from '../main/ets/hud/CYLPlaceholderHUD';
import {
  CYLPlaceholderComponent,
  CYLPlaceholderAnimationLoopsByDefault,
  CYLPlaceholderComponentKind,
  CYLPlaceholderScenario,
  CYLPlaceholderScenarioCatalog
} from '../main/ets/CYLPlaceholderScenario';
import {
  CYLPlaceholderIconNameForStyle,
  CYLPlaceholderItemAnimationFilePath,
  CYLPlaceholderItemGIFFilePath,
  CYLPlaceholderStyle
} from '../main/ets/CYLPlaceholderViewTypes';

/** A playable view that records what it was asked and becomes ready on demand. */
class FakePlayableView extends CYLPlaceholderPlayableContentView {
  calls: string[] = [];

  constructor(fileURL: string, options: Record<string, string>) {
    super();
    this.fileURL = fileURL;
    this.options = options;
  }

  finishLoading(): void {
    this.didLoad();
  }

  failLoading(): void {
    this.didFail('Fake', null);
  }

  finishPlaying(): void {
    this.didEnd();
  }

  cyl_playAnimationView(): void {
    if (!this.cyl_isAnimationViewReady) {
      this.pendingCommand = 1;
      return;
    }
    this.calls.push('play');
  }

  cyl_showAnimationViewLastFrame(): void {
    this.calls.push('last');
  }

  cyl_stopAnimationView(): void {
    this.pendingCommand = 0;
    this.calls.push('stop');
  }

  cyl_setAnimationViewRepeatCount(repeatCount: number): boolean {
    this.repeatCount = repeatCount;
    this.calls.push('repeat' + repeatCount);
    return true;
  }

  cyl_applyAnimationViewColors(colors: CYLPlaceholderAnimationColors | null): void {
    this.calls.push(colors === null ? 'colors-' : 'colors+');
  }
}

class FakeProvider implements CYLPlaceholderItemAnimationViewProviding {
  last: FakePlayableView | null = null;
  playable: boolean = true;

  cyl_animationViewWithFileURL(fileURL: string, options: Record<string, string>,
    contentMode: ImageFit): CYLPlaceholderAnimationContentView | null {
    if (!this.playable) {
      return new CYLPlaceholderAnimationContentView();
    }
    const view = new FakePlayableView(fileURL, options);
    this.last = view;
    return view;
  }
}

/** A minimal animator with a priority, for lookup order. */
class FakeAnimator implements CYLPlaceholderItemAnimator {
  readonly identifier: string;
  readonly priority: number;
  readonly fileExtensions: string[];
  readonly attributeKeys: Record<string, string>;

  constructor(identifier: string, priority: number, fileExtensions: string[], attributeKeys: Record<string, string>) {
    this.identifier = identifier;
    this.priority = priority;
    this.fileExtensions = fileExtensions;
    this.attributeKeys = attributeKeys;
  }

  canAnimateFileAtURL(URL: string): boolean {
    return this.fileExtensions.includes(CYLPlaceholderAnimationExtensionOfURL(URL));
  }

  animationViewWithURL(URL: string, width: number, height: number,
    contentMode: ImageFit): CYLPlaceholderAnimationContentView | null {
    return new CYLPlaceholderAnimationContentView();
  }

  playerForAnimationView(view: CYLPlaceholderAnimationContentView): CYLPlaceholderItemAnimationPlayer | null {
    return null;
  }
}

function keys(generic: string, library: string): Record<string, string> {
  const r: Record<string, string> = {};
  r[generic] = library;
  return r;
}

export default function placeholderAnimationTest() {
  describe('CYLPlaceholderAnimation', () => {
    it('splitsURLs', 0, () => {
      expect(CYLPlaceholderAnimationExtensionOfURL('cylplaceholder/animations/A.JSON')).assertEqual('json');
      expect(CYLPlaceholderAnimationExtensionOfURL('/data/x.riv#artboard=Main&duration=1')).assertEqual('riv');
      expect(CYLPlaceholderAnimationExtensionOfURL('file:///a.b/c?x=1')).assertEqual('');
      expect(CYLPlaceholderAnimationFileOfURL('a.riv?x=1#y=2')).assertEqual('a.riv');
      const url = CYLPlaceholderAnimationURLWithOptions('a.riv', { 'stateMachine': 'State 1', 'artboard': 'Main' });
      expect(url).assertEqual('a.riv#artboard=Main&stateMachine=State%201');
      const options = CYLPlaceholderAnimationOptionsOfURL(url);
      expect(options['stateMachine']).assertEqual('State 1');
      expect(options['artboard']).assertEqual('Main');
      expect(CYLPlaceholderAnimationURLWithOptions('a.gif', {})).assertEqual('a.gif');
    });

    it('registryLooksUpByPriorityExtensionBindingAndKeys', 0, () => {
      const registry = new CYLPlaceholderItemAnimatorRegistry();
      const fallback = new FakeAnimator('Lottie', CYLPlaceholderItemAnimatorPriorityFallback, ['json', 'lottie'],
        keys(CYLPlaceholderItemAnimationFilePath, 'L'));
      const first = new FakeAnimator('A', CYLPlaceholderItemAnimatorPriorityDefault, ['json', 'a'],
        keys(CYLPlaceholderItemAnimationFilePath, 'AKey'));
      const second = new FakeAnimator('B', CYLPlaceholderItemAnimatorPriorityDefault, ['B'], {});
      registry.registerAnimator(fallback);
      registry.registerAnimator(first);
      registry.registerAnimator(second);
      expect(registry.animators().map((a: CYLPlaceholderItemAnimator) => a.identifier).join(',')).assertEqual('A,B,Lottie');
      expect(registry.animatorForURL('x.JSON')?.identifier).assertEqual('A');
      expect(registry.animatorForURL('x.lottie#k=v')?.identifier).assertEqual('Lottie');
      expect(registry.animatorForURL('x.mp4')).assertNull();
      expect(registry.animatorForURL(null)).assertNull();
      registry.bindURL('x.mp4', second);
      expect(registry.animatorForURL('x.mp4')?.identifier).assertEqual('B');
      registry.bindURL('x.mp4', null);
      expect(registry.animatorForURL('x.mp4')).assertNull();
      // Registering the same identifier replaces the animator in place.
      const replaced = new FakeAnimator('A', CYLPlaceholderItemAnimatorPriorityDefault, ['a'], {});
      registry.registerAnimator(replaced);
      expect(registry.animatorWithIdentifier('A') === replaced).assertTrue();
      expect(registry.animatorForURL('x.json')?.identifier).assertEqual('Lottie');
      expect(registry.fileExtensions().join(',')).assertEqual('a,b,json,lottie');
      registry.registerAnimator(first);
      const attributes: Record<string, Object> = { 'L': 'x.json' };
      expect(registry.animatorForAttributes(attributes)?.identifier).assertEqual('Lottie');
      expect(registry.attributeKeyForGenericKey(CYLPlaceholderItemAnimationFilePath, attributes)).assertEqual('L');
      expect(registry.animatorForAttributes({ 'other': 1 })).assertNull();
      expect(registry.attributeKeysForGenericKey(CYLPlaceholderItemAnimationFilePath).join(',')).assertEqual('AKey,L');
      registry.unregisterAnimatorWithIdentifier('A');
      expect(registry.animatorWithIdentifier('A')).assertNull();
    });

    it('viewAnimatorMatchesAndPlaysThroughTheView', 0, () => {
      const provider = new FakeProvider();
      const animator = new CYLPlaceholderItemViewAnimator('Fake', ['.FAKE', 'fake'], null, provider);
      expect(animator.fileExtensions.join(',')).assertEqual('fake');
      expect(animator.priority).assertEqual(CYLPlaceholderItemAnimatorPriorityDefault);
      expect(animator.canAnimateFileAtURL('a/b.Fake#x=1')).assertTrue();
      const view = animator.animationViewWithURL('a/b.fake#artboard=Main', 30, 40, ImageFit.Contain);
      expect(view !== null && view.width === 30 && view.height === 40).assertTrue();
      expect(provider.last !== null && provider.last.options['artboard'] === 'Main').assertTrue();
      const player = animator.playerForAnimationView(view as CYLPlaceholderAnimationContentView);
      expect(player !== null).assertTrue();
      const fake = provider.last as FakePlayableView;
      fake.finishLoading();
      player?.play();
      player?.stop();
      player?.showLastFrame();
      expect(player?.setAnimationRepeatCount(0)).assertTrue();
      player?.applyDarkColors({ 'a': '#FF0000' }, true);
      player?.applyDarkColors({ 'a': '#FF0000' }, true);
      player?.applyDarkColors({ 'a': '#FF0000' }, false);
      expect(fake.calls.join(',')).assertEqual('play,stop,last,repeat0,colors+,colors-');
      expect(player?.supportsProgress).assertFalse();
      // A view that cannot play itself is refused; a null provider goes back to the default one.
      provider.playable = false;
      expect(animator.animationViewWithURL('b.fake', 10, 10, ImageFit.Contain)).assertNull();
      provider.playable = true;
      animator.viewProvider = null;
      expect(animator.viewProvider === provider).assertTrue();
    });

    it('factoryTagsViewsAndAttachesPlayers', 0, () => {
      const registry = new CYLPlaceholderItemAnimatorRegistry();
      registry.registerAnimator(new CYLPlaceholderItemViewAnimator('Fake', ['fake'], null, new FakeProvider()));
      const factory = CYLPlaceholderItemAnimationFactory.initWithRegistry(registry);
      expect(factory.animationViewWithURL('x.gif', 10, 10, ImageFit.Contain)).assertNull();
      const view = factory.animationViewWithURL('x.fake', 12, 12, ImageFit.Cover);
      expect(factory.isAnimationView(view)).assertTrue();
      expect(view?.cyl_animatorIdentifier).assertEqual('Fake');
      expect(view?.contentMode).assertEqual(ImageFit.Cover);
      expect(factory.playerForView(view) !== null).assertTrue();
      expect(factory.playerForView(view) === factory.playerForView(view)).assertTrue();
      expect(factory.isAnimationView(new CYLPlaceholderAnimationContentView())).assertFalse();
      expect(factory.playerForView(null)).assertNull();
      expect(CYLPlaceholderItemAnimationFactory.sharedFactory() === CYLPlaceholderItemAnimationFactory.sharedFactory())
        .assertTrue();
    });

    it('animationViewChecksItsArguments', 0, () => {
      const errors: CYLPlaceholderAnimationErrorCode[] = [];
      const record = (e: CYLPlaceholderAnimationError) => {
        errors.push(e.code);
      };
      CYLPlaceholderItemAnimatorRegistry.registerAnimator(
        new CYLPlaceholderItemViewAnimator('FakeShared', ['fakeshared'], null, new FakeProvider()));
      expect(CYLPlaceholderAnimationViewModel.initWithFileURL('', 10, 10, ImageFit.Contain, record)).assertNull();
      expect(CYLPlaceholderAnimationViewModel.initWithFileURL('a.fakeshared', 0, 10, ImageFit.Contain, record)).assertNull();
      expect(CYLPlaceholderAnimationViewModel.initWithFileURL('a.fakeshared', 10, 1001, ImageFit.Contain, record)).assertNull();
      const bad: Record<string, Object> = { 'x': [1] };
      expect(CYLPlaceholderAnimationViewModel.initWithFileURLOptions('a.fakeshared', 10, 10, ImageFit.Contain, bad,
        record)).assertNull();
      expect(CYLPlaceholderAnimationViewModel.initWithFileURLOptions('a.riv', 10, 10, ImageFit.Contain,
        { 'duration': '61' }, record)).assertNull();
      expect(CYLPlaceholderAnimationViewModel.initWithFileURL('a.xyz', 10, 10, ImageFit.Contain, record)).assertNull();
      expect(errors.join(',')).assertEqual([CYLPlaceholderAnimationErrorCode.InvalidURL,
        CYLPlaceholderAnimationErrorCode.InvalidSize, CYLPlaceholderAnimationErrorCode.InvalidSize,
        CYLPlaceholderAnimationErrorCode.InvalidOptions, CYLPlaceholderAnimationErrorCode.InvalidOptions,
        CYLPlaceholderAnimationErrorCode.UnsupportedFormat].join(','));

      const model = CYLPlaceholderAnimationViewModel.initWithFileURLOptions('a.fakeshared', 20, 20, ImageFit.Contain,
        { 'artboard': 'Main', 'duration': 2 }, record);
      expect(model !== null).assertTrue();
      const m = model as CYLPlaceholderAnimationViewModel;
      expect(m.backend).assertEqual(CYLPlaceholderAnimationBackend.Custom);
      expect(m.animatorIdentifier).assertEqual('FakeShared');
      const fake = m.animationView as FakePlayableView;
      expect(fake.options['duration']).assertEqual('2');
      expect(m.ready).assertFalse();
      let readyCalls = 0;
      m.readyHandler = () => {
        readyCalls++;
      };
      m.play();
      expect(m.playing).assertTrue();
      fake.finishLoading();
      expect(readyCalls).assertEqual(1);
      expect(m.ready).assertTrue();
      expect(fake.calls.join(',')).assertEqual('play');
      expect(m.setAnimationProgress(0.5)).assertFalse();
      expect(m.setAnimationSpeed(2)).assertFalse();
      expect(m.setAnimationRepeatCount(-1)).assertFalse();
      expect(m.setAnimationRepeatCount(3)).assertTrue();
      m.stop();
      expect(m.playing).assertFalse();
      CYLPlaceholderItemAnimatorRegistry.unregisterAnimatorWithIdentifier('FakeShared');
    });

    it('showsItsIconThroughCYLAnimatedItemView', 0, () => {
      // CYLAnimatedItemView plays only registered types; the extension (not the fragment) names the type.
      expect(CYLPlaceholderRegisterAnimatedItemType('xyz')).assertFalse();
      expect(CYLPlaceholderRegisterAnimatedItemType('')).assertFalse();
      expect(CYLPlaceholderRegisterAnimatedItemType('.SVGA')).assertTrue();
      expect(CYLAnimatedItemEngines.isRegistered('SVGA')).assertTrue();
      const m = CYLPlaceholderViewModel.initWithImageText(null, 'x');
      expect(m.cyl_showsIcon).assertFalse();
      expect(m.cyl_animatedItemURL).assertEqual('');
      m.animationFileName = 'CYLPlaceholderLoading.pag';
      expect(m.cyl_showsIcon).assertTrue();
      expect(m.cyl_animatedItemURL).assertEqual('cylplaceholder/animations/CYLPlaceholderLoading.pag');
      m.cyl_animatedItemKey = '7';
      expect(m.cyl_animatedItemURL).assertEqual('cylplaceholder/animations/CYLPlaceholderLoading.pag#cylPlaceholderView=7');
      expect(cylAnimatedItemTypeOf(m.cyl_animatedItemURL)).assertEqual('PAG');
      m.animationFileName = '/data/x.riv#artboard=Main';
      expect(m.cyl_animatedItemURL).assertEqual('/data/x.riv#artboard=Main&cylPlaceholderView=7');
      expect(cylAnimatedItemTypeOf(m.cyl_animatedItemURL)).assertEqual('Rive');
      expect(CYLPlaceholderViewModel.initWithImageText('info', null).cyl_showsIcon).assertTrue();
    });

    it('engineAnimatorMatchesRegisteredEnginesAndMapsRepeatCounts', 0, () => {
      // The core registers CYLTabBarController's GIF engine at import (CYLPlaceholderItemAnimationEngine, through Index.ets);
      // this test imports the files directly, so it registers it itself.
      CYLAnimatedItemGIF.register();
      const gif = new CYLAnimatedItemEnginePlaceholderAnimator('GIF');
      expect(gif.fileExtensions.join(',')).assertEqual('gif');
      expect(gif.canAnimateFileAtURL('Animations/a.gif')).assertTrue();
      expect(gif.canAnimateFileAtURL('Animations/a.png')).assertFalse();
      // No engine view registered for the type: the file is not claimed (it shows the static image).
      expect(new CYLAnimatedItemEnginePlaceholderAnimator('APNG', ['apng']).canAnimateFileAtURL('a.apng')).assertFalse();
      expect(new CYLAnimatedItemEnginePlaceholderAnimator('Lottie').priority < gif.priority).assertTrue();
      const view = gif.animationViewWithURL('Animations/a.gif#loop=1', 40, 30, ImageFit.Contain);
      expect(view instanceof CYLAnimatedItemEngineContentView).assertTrue();
      const content = view as CYLAnimatedItemEngineContentView;
      expect(content.engineState.width).assertEqual(40);
      expect(content.engineState.drivesPlayback).assertFalse();
      expect(content.cyl_setAnimationViewRepeatCount(0)).assertTrue();
      expect(content.repeatCount).assertEqual(0);
      expect(content.cyl_setAnimationViewRepeatCount(-1)).assertFalse();
      // Before the engine has loaded, a play waits.
      content.cyl_playAnimationView();
      expect(content.pendingCommand).assertEqual(1);
      expect(gif.playerForAnimationView(content) !== null).assertTrue();
    });

    it('fileURLKeepsItsFragmentOptions', 0, () => {
      // A placeholder's animationFileName carries the Rive options in its fragment; making the player kept only the
      // explicit options before (the HarmonyOS Rive inputs page played without numberInput, 2026-11-18).
      const URL = CYLPlaceholderAnimationURLWithOptions('example/animations/house.riv',
        { 'stateMachine': 'State Machine 1', 'numberInput': 'Rooms', 'values': '3,4,5,6', 'duration': '99' });
      let failure = '';
      CYLPlaceholderAnimationViewModel.initWithFileURLOptions(URL, 10, 10, ImageFit.Contain, {},
        (e: CYLPlaceholderAnimationError) => { failure = e.message; });
      // The fragment's out-of-range duration is now seen (it was dropped with the other fragment options before).
      expect(failure).assertEqual('Rive duration must be between 0 and 60 seconds.');
      // An explicit option replaces the fragment's one of the same name.
      failure = '';
      CYLPlaceholderAnimationViewModel.initWithFileURLOptions(URL, 10, 10, ImageFit.Contain, { 'duration': 1 },
        (e: CYLPlaceholderAnimationError) => { failure = e.message; });
      expect(failure === 'Rive duration must be between 0 and 60 seconds.').assertFalse();
    });

    it('scenarioLineIconsAreGrayForDarkMode', 0, () => {
      // iOS CYLPlaceholderScenario recolors the black line art ("**.Color", white 0.6) so it reads in dark mode.
      expect(CYLScenarioLineIconColor).assertEqual('#999999');
      expect(CYLScenarioIsLineIcon('CYLPlaceholderNoInternet.json')).assertTrue();
      expect(CYLScenarioIsLineIcon('/data/x/CYLRefreshDoneCircle.json')).assertTrue();
      expect(CYLScenarioIsLineIcon('CYLPlaceholderEmpty.json')).assertFalse();
      expect(CYLScenarioIsLineIcon(null)).assertFalse();
      const icons = CYLPlaceholderScenarioCatalog.componentsForScenario(CYLPlaceholderScenario.NetworkUnavailable)
        .filter((c: CYLPlaceholderComponent) => c.kind === CYLPlaceholderComponentKind.Item && c.animationFileName !== null);
      const line = CYLPlaceholderViewModel.initWithComponent(icons[0]);
      expect(line.animationColors !== null && line.animationColors['**.Color'] === CYLScenarioLineIconColor).assertTrue();
      const empty = CYLPlaceholderViewModel.initWithComponent(CYLPlaceholderComponent.componentWithBundledAnimation(
        'CYLPlaceholderEmpty.json', CYLPlaceholderStyle.Empty, null, 0, null));
      expect(empty.animationColors === null).assertTrue();
    });

    it('placeholderPlaysWithFactoriesAndFallsBack', 0, () => {
      expect(new CYLPlaceholderViewModel().animationRepeatCount).assertEqual(1);
      // iOS e8e9eb6: bundled animations play once by default, spinners loop.
      expect(CYLPlaceholderComponent.componentWithBundledAnimation('CYLPlaceholderEmpty.json', CYLPlaceholderStyle.Empty,
        null, 0, null).animationRepeatCount).assertEqual(1);
      expect(CYLPlaceholderComponent.componentWithBundledAnimation('CYLPlaceholderLoading.pag', CYLPlaceholderStyle.Empty,
        null, 0, null).animationRepeatCount).assertEqual(0);
      const icons = CYLPlaceholderScenarioCatalog.componentsForScenario(CYLPlaceholderScenario.NetworkUnavailable)
        .filter((c: CYLPlaceholderComponent) => c.kind === CYLPlaceholderComponentKind.Item && c.animationFileName !== null);
      expect(icons.length > 0 && icons[0].animationRepeatCount ===
        (CYLPlaceholderAnimationLoopsByDefault(icons[0].animationFileName as string) ? 0 : 1)).assertTrue();
      expect(CYLPlaceholderViewModel.registerAnimationFactory(null, 'GIF')).assertFalse();

      // No engine plays the file: the image stays.
      const plain = CYLPlaceholderViewModel.initWithImageText('info', 'x');
      plain.animationFileName = 'missing.xyz';
      plain.cyl_attachAnimation();
      expect(plain.animationFailed).assertTrue();
      expect(plain.animationVisible).assertFalse();

      // A factory registered for the extension plays it; the image shows until it is ready.
      let made: CYLPlaceholderAnimationViewModel | null = null;
      expect(CYLPlaceholderViewModel.registerAnimationFactory((fileURL: string, width: number, height: number,
        contentMode: ImageFit, options: Record<string, Object>): CYLPlaceholderAnimationPlayer | null => {
        CYLPlaceholderItemAnimatorRegistry.registerAnimator(
          new CYLPlaceholderItemViewAnimator('FakeFactory', ['fakefactory'], null, new FakeProvider()));
        made = CYLPlaceholderAnimationViewModel.initWithFileURL(fileURL, width, height, contentMode, null);
        return made;
      }, '.FakeFactory')).assertTrue();
      const view = CYLPlaceholderViewModel.initWithImageText('info', 'x');
      view.animationFileName = 'a.fakefactory';
      view.animationRepeatCount = 0;
      view.cyl_attachAnimation();
      view.playPlaceholderAnimationIfIdle();
      expect(made !== null).assertTrue();
      expect(view.animationVisible).assertTrue();
      expect(view.animationReady).assertFalse();
      const fake = (made as CYLPlaceholderAnimationViewModel | null)?.animationView as FakePlayableView;
      fake.finishLoading();
      expect(view.animationReady).assertTrue();
      expect(fake.calls.join(',')).assertEqual('repeat0,play,play');
      view.stopPlaceholderAnimation();
      expect(fake.calls[fake.calls.length - 1]).assertEqual('stop');
      expect(view.setPlaceholderAnimationProgress(2)).assertFalse();
      expect(view.setPlaceholderAnimationSpeed(0)).assertFalse();

      // A load error after creation falls back to the image.
      const failing = CYLPlaceholderViewModel.initWithImageText('info', 'x');
      failing.animationFileName = 'b.fakefactory';
      failing.cyl_attachAnimation();
      const failingView = (made as CYLPlaceholderAnimationViewModel | null)?.animationView as FakePlayableView;
      failingView.failLoading();
      expect(failing.animationFailed).assertTrue();
      expect(failing.animationVisible).assertFalse();
      failing.cyl_releaseAnimation();

      // showsImageWhenAnimationEnds (CYLTabBarController b13b88f1): the end of a play-once pass reaches the item and
      // the image (tinted again) replaces the animation; a replay goes through the item, which shows the animation.
      const success = CYLPlaceholderScenarioCatalog.componentsForScenario(CYLPlaceholderScenario.Success)
        .filter((c: CYLPlaceholderComponent) => c.kind === CYLPlaceholderComponentKind.Item)[0];
      expect(success.image).assertEqual('check_circle');
      expect(success.showsImageWhenAnimationEnds).assertTrue();
      expect(CYLPlaceholderScenarioCatalog.componentsForScenario(CYLPlaceholderScenario.NoContent)
        .some((c: CYLPlaceholderComponent) => c.showsImageWhenAnimationEnds)).assertFalse();
      const once = CYLPlaceholderViewModel.initWithImageText('check_circle', 'Done');
      once.showsImageWhenAnimationEnds = true;
      once.animationFileName = 'c.fakefactory';
      let ends = 0;
      let replays = 0;
      once.cyl_animationEndHandler = () => {
        ends++;
      };
      once.cyl_animationReplayHandler = () => {
        replays++;
      };
      once.cyl_attachAnimation();
      const onceView = (made as CYLPlaceholderAnimationViewModel | null)?.animationView as FakePlayableView;
      onceView.finishLoading();
      onceView.finishPlaying();
      expect(ends).assertEqual(1);
      expect(once.animationEndedShowsImage).assertTrue();
      once.playPlaceholderAnimation();
      expect(replays).assertEqual(1);
      expect(once.animationEndedShowsImage).assertFalse();
      once.animationRepeatCount = 0;
      onceView.finishPlaying();
      expect(ends).assertEqual(1);
      once.cyl_releaseAnimation();
      CYLPlaceholderViewModel.registerAnimationFactory(null, 'fakefactory');
      CYLPlaceholderItemAnimatorRegistry.unregisterAnimatorWithIdentifier('FakeFactory');
    });

    it('setAnimationFileChecksTheFileAndTheAnimator', 0, () => {
      const view = CYLPlaceholderViewModel.initWithImageText('info', 'x');
      // Empty path, or a file that does not exist: false, the icon stays.
      expect(view.setAnimationFile('')).assertFalse();
      expect(view.setAnimationFile('/data/storage/el2/base/missing-cyl.fakefile')).assertFalse();
      expect(view.animationFileName).assertNull();
      expect(view.animationPlayer === null).assertTrue();
      // A file that does not exist is refused even though an animator plays its extension.
      CYLPlaceholderItemAnimatorRegistry.registerAnimator(
        new CYLPlaceholderItemViewAnimator('FakeFile', ['fakefile'], null, new FakeProvider()));
      expect(view.setAnimationFile('/data/storage/el2/base/missing-cyl.fakefile')).assertFalse();
      expect(view.animationFileName).assertNull();
      // An existing file that an animator plays: true, the animation replaces the icon.
      const path = '/tmp/cylSetAnimationFile.fakefile';
      fileIo.closeSync(fileIo.openSync(path, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE));
      expect(view.setAnimationFile(path)).assertTrue();
      expect(view.animationFileName).assertEqual(path);
      expect(view.animationPlayer !== null).assertTrue();
      // An existing file no animator plays: false, the previous animation stays.
      const other = '/tmp/cylSetAnimationFile.nobody';
      fileIo.closeSync(fileIo.openSync(other, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE));
      expect(view.setAnimationFile(other)).assertFalse();
      expect(view.animationFileName).assertEqual(path);
      view.cyl_releaseAnimation();
      fileIo.unlinkSync(path);
      fileIo.unlinkSync(other);
      CYLPlaceholderItemAnimatorRegistry.unregisterAnimatorWithIdentifier('FakeFile');
    });

    it('hudUsesItsAnimationFiles', 0, () => {
      const hud = new CYLPlaceholderHUD(null);
      expect(hud.loadingAnimationFileName).assertEqual('CYLRefreshActivity.gif');
      expect(hud.successAnimationFileName).assertEqual('CYLRefreshDoneCircle.json');
      expect(hud.progressAnimationFileName).assertNull();
      hud.loadingAnimationFileName = 'CYLPlaceholderLoading.json';
      expect(hud.loadingAnimationFileName).assertEqual('CYLPlaceholderLoading.json');
      hud.loadingAnimationFileName = null;
      expect(hud.loadingAnimationFileName).assertEqual('CYLRefreshActivity.gif');
      hud.showWithStatus('Loading');
      expect(hud.state).assertEqual(CYLPlaceholderHUDState.Loading);
      expect(hud.contentView?.animationFileName).assertEqual('CYLRefreshActivity.gif');
      expect(hud.contentView?.animationRepeatCount).assertEqual(0);
      expect(hud.contentView?.image).assertEqual(CYLPlaceholderIconNameForStyle(CYLPlaceholderStyle.Hourglass));
      hud.showProgressStatus(0.25, 'Uploading');
      expect(hud.contentView?.text).assertEqual('Uploading 25%');
      expect(hud.contentView?.animationFileName).assertEqual('CYLRefreshActivity.gif');
      hud.showProgress(0.5);
      expect(hud.contentView?.text).assertEqual('Uploading 50%');
      hud.dismiss();
      const scrubbing = new CYLPlaceholderHUD(null);
      scrubbing.progressAnimationFileName = 'CYLPlaceholderProgress.pag';
      scrubbing.showProgressStatus(0.4, 'Uploading');
      expect(scrubbing.contentView?.text).assertEqual('Uploading');
      expect(scrubbing.contentView?.animationFileName).assertEqual('CYLPlaceholderProgress.pag');
      scrubbing.showSuccessWithStatus('Done');
      expect(scrubbing.contentView?.animationFileName).assertEqual('CYLRefreshDoneCircle.json');
      expect(scrubbing.contentView?.animationRepeatCount).assertEqual(1);
      scrubbing.showErrorWithStatus('No');
      expect(scrubbing.contentView?.animationFileName).assertNull();
    });
  });
}
