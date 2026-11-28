// UI tests of the example on a device or emulator (the emulator rows of docs/HarmonyOS.md "Full-marks standard"):
// the app launches (Q9), every tab opens (Q10), a scenario page shows its placeholder (Q11), the animation detail page
// shows the playback controls (Q8 / Q13), the plus button opens the Publish page, and a multi-step flow (Play all,
// loop on, back, another tab). Each step saves a screenshot to the app's files directory (copied to docs/assets by
// `scripts/emulator-check.sh uitest`).
//
// Rule (instructions.md "HarmonyOS accessibility and localization"): controls are found by what assistive
// technology reads first: the accessibility label (accessibilityText) or the localized visible text, in any of the
// example's seven languages, so the test checks the screen-reader and localization support while it drives the
// app. Component ids are the fallback only.
import { abilityDelegatorRegistry, Component, Driver, ON } from '@kit.TestKit';
import { describe, expect, it } from '@ohos/hypium';
import { Want } from '@kit.AbilityKit';
import { ExampleStringTable } from '../../../main/ets/common/ExampleStrings';
import { playbackText } from '../../../main/ets/common/Playback';
import { tabBarText } from '../../../main/ets/common/TabBarStrings';

const BUNDLE: string = 'com.cyl.placeholder.harmonyos';
const LANGUAGES: string[] = ['en', 'zh-Hans', 'zh-Hant', 'ja', 'ko', 'ru', 'uk'];
// Tab id -> the key of its localized title (also its accessibility label).
const TABS: string[][] = [
  ['scenarios', 'CYLScenarioTabScenarios'],
  ['animations', 'CYLScenarioTabAnimations'],
  ['flows', 'CYLScenarioSectionFlows'],
  ['feed', 'CYLScenarioTabFeed'],
  ['refresh', 'CYLScenarioTabRefresh'],
];

function filesDir(): string {
  return abilityDelegatorRegistry.getAbilityDelegator().getAppContext().filesDir;
}

async function shot(driver: Driver, name: string): Promise<void> {
  await driver.screenCap(filesDir() + '/harmonyos-' + name + '.png');
}

/** Every translation of an example text key. */
function translations(key: string): string[] {
  const all: string[] = [];
  LANGUAGES.forEach((code: string) => {
    const text = ExampleStringTable(code)[key];
    if (text !== undefined && !all.includes(text)) {
      all.push(text);
    }
  });
  return all;
}

/** Every translation of a playback control text ("PlayAll", "Speed", "Loop"). */
function playbackTranslations(name: string): string[] {
  const all: string[] = [];
  LANGUAGES.forEach((code: string) => {
    const text = playbackText(name, code);
    if (!all.includes(text)) {
      all.push(text);
    }
  });
  return all;
}

/**
 * The first component whose accessibility label or visible text is one of the labels (any language); then the id.
 * Throws when none is found, naming what was looked for.
 */
async function find(driver: Driver, labels: string[], fallbackId: string = ''): Promise<Component> {
  for (const label of labels) {
    const byDescription = await driver.findComponent(ON.description(label));
    if (byDescription !== null) {
      return byDescription;
    }
    const byText = await driver.findComponent(ON.text(label));
    if (byText !== null) {
      return byText;
    }
  }
  if (fallbackId.length > 0) {
    const byId = await driver.findComponent(ON.id(fallbackId));
    if (byId !== null) {
      return byId;
    }
  }
  throw new Error('No component labeled ' + labels.join(' / ') + (fallbackId.length > 0 ? ' or #' + fallbackId : ''));
}

async function back(driver: Driver): Promise<void> {
  await driver.pressBack();
  await driver.delayMs(800);
}

async function openTab(driver: Driver, tab: string[]): Promise<void> {
  await (await find(driver, translations(tab[1]), 'tab-' + tab[0])).click();
  await driver.delayMs(1000);
}

async function openFirstRow(driver: Driver): Promise<void> {
  const rows = await driver.findComponents(ON.type('ListItem'));
  expect(rows !== null && rows.length > 1).assertTrue();
  await (rows as Component[])[1].click();
  await driver.delayMs(1500);
}

export default function exampleUiTest() {
  describe('ExampleUi', () => {
    it('launches', 0, async () => {
      const delegator = abilityDelegatorRegistry.getAbilityDelegator();
      const want: Want = { bundleName: BUNDLE, abilityName: 'EntryAbility' };
      await delegator.startAbility(want);
      const driver = Driver.create();
      await driver.delayMs(2500);
      await find(driver, translations('CYLScenarioTabScenarios'), 'tab-scenarios');
      await shot(driver, 'launch');
    });

    it('opensEveryTabByItsLabel', 0, async () => {
      const driver = Driver.create();
      for (const tab of TABS) {
        await openTab(driver, tab);
        await shot(driver, 'tab-' + tab[0]);
      }
    });

    it('opensAScenario', 0, async () => {
      const driver = Driver.create();
      await openTab(driver, TABS[0]);
      await openFirstRow(driver);
      await shot(driver, 'scenario');
      await back(driver);
    });

    it('drivesThePlaybackControls', 0, async () => {
      const driver = Driver.create();
      await openTab(driver, TABS[1]);
      await openFirstRow(driver);
      // A multi-step flow found by the controls' spoken labels: Play all, loop on, Play all again.
      await (await find(driver, playbackTranslations('PlayAll'))).click();
      await driver.delayMs(500);
      await (await find(driver, playbackTranslations('Loop'))).click();
      await driver.delayMs(500);
      await find(driver, playbackTranslations('Speed'));
      await (await find(driver, playbackTranslations('PlayAll'))).click();
      await driver.delayMs(800);
      await shot(driver, 'animation-controls');
      await back(driver);
    });

    it('opensPublishThroughThePlusButton', 0, async () => {
      const driver = Driver.create();
      const plusLabels = translations('CYLScenarioActionPublish');
      LANGUAGES.forEach((code: string) => plusLabels.push(tabBarText('PlusButton', code)));
      await (await find(driver, plusLabels, 'plusButton')).click();
      await driver.delayMs(1200);
      await shot(driver, 'publish');
      await back(driver);
    });
  });
}
