// Unit tests for the non-UI logic of the iOS public Swift API port (RiveSwift, LottieSwift).
import { describe, expect, it } from '@ohos/hypium';
import {
  CYLCompatibleLOTColorNodes,
  CYLCompatibleLOTDurationOfData,
  CYLCompatibleLOTLoopValue,
  CYLCompatibleLOTProgressOfFrame,
  CYLCompatibleLOTSetColor,
  CYLCompatibleLOTStaticColor
} from '../main/ets/CYLPlaceholderCompatibleLottieSupport';
import { CYLRiveColorInteger, CYLRiveUsesLegacyRuntime } from '../main/ets/CYLRiveOptions';
import { CYLRefreshRiveHeaderModel, CYLRefreshRiveStyle } from '../main/ets/refresh/drawn/CYLRefreshRiveHeader';
import { CYLPlaceholderAnimationFileExists, CYLPlaceholderAnimationReadFileSync } from '../main/ets/CYLPlaceholderAnimation';

const LOTTIE_JSON: string = '{"v":"5.7.0","fr":30,"ip":0,"op":60,"w":10,"h":10,' +
  '"assets":[{"id":"comp_0","layers":[{"nm":"Inner","ty":4,"shapes":[{"nm":"Fill 1","ty":"fl","c":{"a":0,"k":[0,0,0,1]}}]}]}],' +
  '"layers":[' +
  '{"nm":"Icon","ty":4,"shapes":[{"nm":"Group 1","ty":"gr","it":[' +
  '{"nm":"Fill 1","ty":"fl","c":{"a":0,"k":[0,0,0,1]}},{"nm":"Stroke 1","ty":"st","c":{"a":1,"k":[]}}]}]},' +
  '{"nm":"Badge","ty":4,"shapes":[{"nm":"Fill 1","ty":"fl","c":{"a":0,"k":[1,1,1,1]}}]},' +
  '{"nm":"Pre","ty":0,"refId":"comp_0"}]}';

function lottieData(): Object {
  return JSON.parse(LOTTIE_JSON) as Object;
}

export default function swiftAPITest() {
  describe('CYLSwiftAPI', () => {
    it('lottieLoopCount', 0, () => {
      expect(CYLCompatibleLOTLoopValue(-1)).assertEqual(true);
      expect(CYLCompatibleLOTLoopValue(0)).assertEqual(false);
      expect(CYLCompatibleLOTLoopValue(1)).assertEqual(false);
      expect(CYLCompatibleLOTLoopValue(3)).assertEqual(2);
      expect(CYLCompatibleLOTLoopValue(2.7)).assertEqual(1);
    });

    it('lottieDurationAndProgress', 0, () => {
      expect(CYLCompatibleLOTDurationOfData(lottieData())).assertEqual(2);
      expect(CYLCompatibleLOTDurationOfData(null)).assertEqual(0);
      expect(CYLCompatibleLOTProgressOfFrame(30, 61)).assertEqual(0.5);
      expect(CYLCompatibleLOTProgressOfFrame(5, 1)).assertEqual(0);
      expect(CYLCompatibleLOTProgressOfFrame(100, 61)).assertEqual(1);
    });

    it('lottieKeypaths', 0, () => {
      const data = lottieData();
      expect(CYLCompatibleLOTColorNodes(data, 'Icon.**.Color').length).assertEqual(2);
      expect(CYLCompatibleLOTColorNodes(data, 'Icon.Group 1.Fill 1.Color').length).assertEqual(1);
      expect(CYLCompatibleLOTColorNodes(data, '*.Fill 1.Color').length).assertEqual(1);
      expect(CYLCompatibleLOTColorNodes(data, '**.Fill 1.Color').length).assertEqual(3);
      expect(CYLCompatibleLOTColorNodes(data, 'Pre.Inner.Fill 1.Color').length).assertEqual(1);
      expect(CYLCompatibleLOTColorNodes(data, 'Missing.**.Color').length).assertEqual(0);
      expect(CYLCompatibleLOTColorNodes(data, '').length).assertEqual(0);
    });

    it('lottieSetColor', 0, () => {
      const data = lottieData();
      expect(CYLCompatibleLOTSetColor(data, 'Icon.**.Color', 1, 0, 0, 1)).assertEqual(2);
      const nodes = CYLCompatibleLOTColorNodes(data, 'Icon.**.Color');
      nodes.forEach((node: Record<string, Object>) => {
        const color = CYLCompatibleLOTStaticColor(node);
        expect(color !== null).assertTrue();
        expect((color as number[])[0]).assertEqual(1);
        expect((color as number[])[1]).assertEqual(0);
      });
      const badge = CYLCompatibleLOTColorNodes(data, 'Badge.**.Color')[0];
      expect((CYLCompatibleLOTStaticColor(badge) as number[])[1]).assertEqual(1);
    });

    it('riveOptionsAndColor', 0, () => {
      const options: Record<string, string> = {};
      expect(CYLRiveUsesLegacyRuntime(options)).assertFalse();
      options['animation'] = 'idle';
      expect(CYLRiveUsesLegacyRuntime(options)).assertTrue();
      expect(CYLRiveColorInteger(255, 0, 0, 255)).assertEqual(0xFFFF0000 | 0);
      expect(CYLRiveColorInteger(300, -5, 16, 128)).assertEqual(0x80FF0010 | 0);
    });

    it('riveStyleDefaults', 0, () => {
      const style = new CYLRefreshRiveStyle('missing.riv');
      expect(style.fileURL).assertEqual('missing.riv');
      expect(style.artboardName).assertNull();
      expect(style.stateMachineName).assertNull();
      expect(style.triggerOffset).assertEqual(180);
      expect(style.minimumHeight).assertEqual(0);
      expect(style.fitsWidth).assertFalse();
      expect(style.pullInputMinimum).assertEqual(0);
      expect(style.pullInputMaximum).assertEqual(100);
      expect(style.pullInputStart).assertEqual(0);
      expect(style.pullInputRefreshingValue).assertEqual(-1);
      expect(style.loadingNumberMaximum).assertEqual(99);
      expect(style.loadingNumberFinished).assertEqual(100);
      expect(style.loadingNumberDuration).assertEqual(2);
      expect(style.pullAnimation).assertNull();
      expect(style.idleAnimation).assertNull();
    });

    it('riveHeaderNullForMissingFile', 0, () => {
      const style = new CYLRefreshRiveStyle('/data/storage/el2/base/cyl-missing-file.riv');
      expect(CYLPlaceholderAnimationFileExists(style.fileURL)).assertFalse();
      expect(CYLPlaceholderAnimationReadFileSync(style.fileURL)).assertNull();
      expect(CYLRefreshRiveHeaderModel.initWithStyle(style)).assertNull();
      expect(CYLPlaceholderAnimationFileExists('')).assertFalse();
      const header = new CYLRefreshRiveHeaderModel(style);
      expect(header.riveStyle === style).assertTrue();
    });
  });
}
