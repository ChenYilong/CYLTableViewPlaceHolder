// Local (host) unit tests of the non-UI placeholder core: localization, scenarios, components and styles.
import { describe, expect, it } from '@ohos/hypium';
import { CYLPlaceholderLocalization } from '../main/ets/CYLPlaceholderLocalization';
import {
  CYLPlaceholderActions,
  CYLPlaceholderButtonStyle,
  CYLPlaceholderComponent,
  CYLPlaceholderComponentKind,
  CYLPlaceholderPermission,
  CYLPlaceholderScenario,
  CYLPlaceholderScenarioCatalog,
  CYLPlaceholderScenarioCategory
} from '../main/ets/CYLPlaceholderScenario';
import {
  CYLPlaceholderIconNameForStyle,
  CYLPlaceholderImageNameForStyle,
  CYLPlaceholderItemTitle,
  CYLPlaceholderLocalizedTextForMessage,
  CYLPlaceholderMessage,
  CYLPlaceholderStyle,
  CYLPlaceholderStyleNamed,
  CYLPlaceholderTapHighlightStyle
} from '../main/ets/CYLPlaceholderViewTypes';

export default function placeholderCoreTest() {
  describe('CYLPlaceholderCore', () => {
    it('resolvesLanguages', 0, () => {
      expect(CYLPlaceholderLocalization.resolveLanguage('zh_TW')).assertEqual('zh-Hant');
      expect(CYLPlaceholderLocalization.resolveLanguage('zh-Hant-CN')).assertEqual('zh-Hant');
      expect(CYLPlaceholderLocalization.resolveLanguage('zh-HK')).assertEqual('zh-Hant');
      expect(CYLPlaceholderLocalization.resolveLanguage('zh-Hans-CN')).assertEqual('zh-Hans');
      expect(CYLPlaceholderLocalization.resolveLanguage('ja-JP')).assertEqual('ja');
      expect(CYLPlaceholderLocalization.resolveLanguage('fr')).assertEqual('en');
      expect(CYLPlaceholderLocalization.resolveLanguage(null)).assertEqual('en');
      expect(CYLPlaceholderLocalization.supportedLanguages.length).assertEqual(7);
    });

    it('switchesLanguage', 0, () => {
      CYLPlaceholderLocalization.language = 'zh-CN';
      expect(CYLPlaceholderLocalization.effectiveLanguage).assertEqual('zh-Hans');
      const zh = CYLPlaceholderLocalization.localizedStringForKey('action_retry_title', null);
      CYLPlaceholderLocalization.language = 'en';
      const en = CYLPlaceholderLocalization.localizedStringForKey('cyl_placeholder_action_retry_title', null);
      expect(en).assertEqual('Retry');
      expect(zh === en).assertFalse();
      expect(CYLPlaceholderLocalization.localizedStringForKey('missing_key', 'fb')).assertEqual('fb');
      expect(CYLPlaceholderLocalization.localizedStringForKey('missing_key', null)).assertEqual('missing_key');
      CYLPlaceholderLocalization.language = null;
      expect(CYLPlaceholderLocalization.language === null).assertTrue();
    });

    it('catalogsScenarios', 0, () => {
      CYLPlaceholderLocalization.language = 'en';
      const all = CYLPlaceholderScenarioCatalog.allScenarios;
      expect(all.length).assertEqual(35);
      all.forEach((s: CYLPlaceholderScenario) => {
        expect(CYLPlaceholderScenarioCatalog.componentsForScenario(s).length > 0).assertTrue();
        expect(CYLPlaceholderScenarioCatalog.scenarioNamed(CYLPlaceholderScenarioCatalog.nameForScenario(s)))
          .assertEqual(s);
        expect(CYLPlaceholderScenarioCatalog.localizedNameForScenario(s).startsWith('scenario_')).assertFalse();
      });
      expect(CYLPlaceholderScenarioCatalog.scenarioNamed('CYLPlaceholderScenarioRetryButton'))
        .assertEqual(CYLPlaceholderScenario.RetryButton);
      expect(CYLPlaceholderScenarioCatalog.scenarioNamed('nope') === null).assertTrue();
      expect(CYLPlaceholderScenarioCatalog.actionNamed('retry')).assertEqual(CYLPlaceholderActions.Retry);
      expect(CYLPlaceholderScenarioCatalog.actionNamed('mine')).assertEqual('mine');
      expect(CYLPlaceholderScenarioCatalog.localizedTitleForAction(CYLPlaceholderActions.Retry)).assertEqual('Retry');
      expect(CYLPlaceholderScenarioCatalog.localizedTitleForAction('mine') === null).assertTrue();
      expect(CYLPlaceholderScenarioCatalog.backgroundActionForScenario(CYLPlaceholderScenario.TapToReload))
        .assertEqual(CYLPlaceholderActions.Retry);
      expect(CYLPlaceholderScenarioCatalog.backgroundActionForScenario(CYLPlaceholderScenario.RetryButton) === null)
        .assertTrue();
      expect(CYLPlaceholderScenarioCatalog.categoryForScenario(CYLPlaceholderScenario.CameraPermissionDenied))
        .assertEqual(CYLPlaceholderScenarioCategory.Permission);
      expect(CYLPlaceholderScenarioCatalog.categoryForScenario(CYLPlaceholderScenario.EmptyCart))
        .assertEqual(CYLPlaceholderScenarioCategory.Empty);
      expect(CYLPlaceholderScenarioCatalog.categoryForScenario(CYLPlaceholderScenario.HUD))
        .assertEqual(CYLPlaceholderScenarioCategory.Progress);
      expect(CYLPlaceholderScenarioCatalog.permissionForScenario(CYLPlaceholderScenario.CameraPermissionDenied))
        .assertEqual(CYLPlaceholderPermission.Camera);
      expect(CYLPlaceholderScenarioCatalog.permissionForScenario(CYLPlaceholderScenario.NoPermission))
        .assertEqual(CYLPlaceholderPermission.None);
      expect(CYLPlaceholderScenarioCatalog.scenarioForPermission(CYLPlaceholderPermission.Bluetooth))
        .assertEqual(CYLPlaceholderScenario.BluetoothPermissionDenied);
      expect(CYLPlaceholderScenarioCatalog.readmeScreenshotNumbersForScenario(CYLPlaceholderScenario.TapToReconnect)[0])
        .assertEqual(8);
      expect(CYLPlaceholderScenarioCatalog.animationFileNamesForScenario(CYLPlaceholderScenario.RefreshIcon).length)
        .assertEqual(3);
    });

    it('buildsComponents', 0, () => {
      CYLPlaceholderLocalization.language = 'en';
      const c = CYLPlaceholderScenarioCatalog.componentsForScenario(CYLPlaceholderScenario.RetryOrContactSupport);
      expect(c.length).assertEqual(4);
      expect(c[0].animationFileName).assertEqual('CYLPlaceholderServerError.json');
      expect(c[1].kind).assertEqual(CYLPlaceholderComponentKind.Button);
      expect(c[1].action).assertEqual(CYLPlaceholderActions.Retry);
      expect(c[2].kind).assertEqual(CYLPlaceholderComponentKind.Separator);
      expect(c[3].spacingBefore).assertEqual(14);
      const hint = CYLPlaceholderComponent.hintComponentWithText('h');
      expect(hint.spacingBefore).assertEqual(4);
      expect(hint.attributes[CYLPlaceholderItemTitle]).assertEqual('h');
      const d: Record<string, Object> = {
        'type': 'button',
        'title': 'Go',
        'buttonStyle': 'capsule',
        'action': 'retry',
        'highlightStyle': 'shrink',
        'spacingBefore': 30
      };
      const b = CYLPlaceholderComponent.componentWithDictionary(d);
      expect(b !== null).assertTrue();
      if (b !== null) {
        expect(b.buttonStyle).assertEqual(CYLPlaceholderButtonStyle.Capsule);
        expect(b.action).assertEqual(CYLPlaceholderActions.Retry);
        expect(b.tapHighlightStyle).assertEqual(CYLPlaceholderTapHighlightStyle.Shrink);
        expect(b.spacingBefore).assertEqual(30);
      }
      let error = '';
      const bad: Record<string, Object> = { 'type': 'nope' };
      const none = CYLPlaceholderComponent.componentWithDictionary(bad, (m: string) => {
        error = m;
      });
      expect(none === null).assertTrue();
      expect(error.length > 0).assertTrue();
    });

    it('mapsStyles', 0, () => {
      CYLPlaceholderLocalization.language = 'en';
      expect(CYLPlaceholderIconNameForStyle(CYLPlaceholderStyle.WifiOff)).assertEqual('wifi_off');
      expect(CYLPlaceholderIconNameForStyle(CYLPlaceholderStyle.NotificationsOff)).assertEqual('notifications_off');
      expect(CYLPlaceholderImageNameForStyle(CYLPlaceholderStyle.WifiOff)).assertEqual('CYLPlaceholderWifiOff');
      expect(CYLPlaceholderStyleNamed('CYLPlaceholderStyleCloudOff')).assertEqual(CYLPlaceholderStyle.CloudOff);
      expect(CYLPlaceholderStyleNamed('cloud_off')).assertEqual(CYLPlaceholderStyle.CloudOff);
      expect(CYLPlaceholderLocalizedTextForMessage(CYLPlaceholderMessage.NoInternet) !== null).assertTrue();
      expect(CYLPlaceholderLocalizedTextForMessage(CYLPlaceholderMessage.Count) === null).assertTrue();
    });
  });
}
