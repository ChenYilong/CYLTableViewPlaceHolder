// UI tests of the example on a device or emulator (the emulator rows of docs/HarmonyOS.md "Full-marks standard"):
// the app launches (Q9), every tab opens (Q10), a scenario page shows its placeholder (Q11), the animation detail page
// shows the playback controls (Q8 / Q13), the plus button opens the Publish page. Each step saves a screenshot to the
// app's files directory (/data/app/el2/100/base/com.cyl.placeholder.harmonyos/haps/entry/files on the device;
// `hdc file recv` copies them to docs/assets).
import { abilityDelegatorRegistry, Driver, ON } from '@kit.TestKit';
import { describe, expect, it } from '@ohos/hypium';
import { Want } from '@kit.AbilityKit';

const BUNDLE: string = 'com.cyl.placeholder.harmonyos';
const TABS: string[] = ['scenarios', 'animations', 'flows', 'feed', 'refresh'];

function filesDir(): string {
  return abilityDelegatorRegistry.getAbilityDelegator().getAppContext().filesDir;
}

async function shot(driver: Driver, name: string): Promise<void> {
  await driver.screenCap(filesDir() + '/harmonyos-' + name + '.png');
}

async function back(driver: Driver): Promise<void> {
  await driver.pressBack();
  await driver.delayMs(800);
}

export default function exampleUiTest() {
  describe('ExampleUi', () => {
    it('launches', 0, async () => {
      const delegator = abilityDelegatorRegistry.getAbilityDelegator();
      const want: Want = { bundleName: BUNDLE, abilityName: 'EntryAbility' };
      await delegator.startAbility(want);
      const driver = Driver.create();
      await driver.delayMs(2500);
      expect(await driver.findComponent(ON.id('tab-scenarios')) !== null).assertTrue();
      await shot(driver, 'launch');
    });

    it('opensEveryTab', 0, async () => {
      const driver = Driver.create();
      for (const tab of TABS) {
        const item = await driver.findComponent(ON.id('tab-' + tab));
        expect(item !== null).assertTrue();
        await item.click();
        await driver.delayMs(1200);
        await shot(driver, 'tab-' + tab);
      }
    });

    it('opensAScenario', 0, async () => {
      const driver = Driver.create();
      await (await driver.findComponent(ON.id('tab-scenarios'))).click();
      await driver.delayMs(800);
      // The first row of the scenario list.
      const list = await driver.findComponent(ON.type('List'));
      expect(list !== null).assertTrue();
      const rows = await driver.findComponents(ON.type('ListItem'));
      expect(rows.length > 1).assertTrue();
      await rows[1].click();
      await driver.delayMs(1500);
      await shot(driver, 'scenario');
      await back(driver);
    });

    it('showsPlaybackControls', 0, async () => {
      const driver = Driver.create();
      await (await driver.findComponent(ON.id('tab-animations'))).click();
      await driver.delayMs(800);
      const rows = await driver.findComponents(ON.type('ListItem'));
      expect(rows.length > 1).assertTrue();
      await rows[1].click();
      await driver.delayMs(1500);
      expect(await driver.findComponent(ON.type('Slider')) !== null).assertTrue();
      expect(await driver.findComponent(ON.type('Toggle')) !== null).assertTrue();
      await shot(driver, 'animation-controls');
      await back(driver);
    });

    it('opensPublish', 0, async () => {
      const driver = Driver.create();
      const plus = await driver.findComponent(ON.id('plusButton'));
      expect(plus !== null).assertTrue();
      await plus.click();
      await driver.delayMs(1200);
      await shot(driver, 'publish');
      await back(driver);
    });
  });
}
