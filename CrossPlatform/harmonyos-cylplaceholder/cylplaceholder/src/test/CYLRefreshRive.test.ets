// Local (host) unit tests of the Rive refresh header's input mapping (pull → inputs / scrubbed time, release, finish,
// reset) through a recording driver, and of the auto footer's hidden rule.
import { describe, expect, it } from '@ohos/hypium';
import { CYLRefreshPhase } from '../main/ets/refresh/CYLRefreshConst';
import { CYLRefreshAutoNormalFooterModel } from '../main/ets/refresh/CYLRefreshClassics';
import { cylAutoFooterItemShown } from '../main/ets/refresh/CYLRefreshComponent';
import { CYLRefreshDrawnFooterModel } from '../main/ets/refresh/drawn/CYLRefreshDrawnHeader';
import {
  CYLRefreshRiveDriver,
  CYLRefreshRiveHeaderModel,
  CYLRefreshRiveStyle
} from '../main/ets/refresh/drawn/CYLRefreshRiveHeader';
import { CYLRefreshScrollMode } from '../main/ets/refresh/CYLRefreshConst';

class RecordingDriver implements CYLRefreshRiveDriver {
  calls: string[] = [];

  setNumber(input: string, value: number): void {
    this.calls.push('number ' + input + '=' + Math.round(value * 100) / 100);
  }

  setBoolean(input: string, value: boolean): void {
    this.calls.push('bool ' + input + '=' + value);
  }

  fire(trigger: string): void {
    this.calls.push('fire ' + trigger);
  }

  play(animation: string | null, loop: boolean): void {
    this.calls.push('play ' + (animation !== null ? animation : '-') + (loop ? ' loop' : ' once'));
  }

  scrub(animation: string, time: number): void {
    this.calls.push('scrub ' + animation + '@' + Math.round(time * 100) / 100);
  }

  duration(animation: string): number {
    return 1;
  }

  reset(): void {
    this.calls.push('reset');
  }
}

function bowStyle(): CYLRefreshRiveStyle {
  const style = new CYLRefreshRiveStyle('Bow.riv');
  style.stateMachineName = 'numberSimulation';
  style.triggerOffset = 200;
  style.pullInput = 'pull';
  style.pullInputMinimum = 10;
  style.releaseTrigger = 'advance';
  style.finishTrigger = 'advance';
  style.restartTrigger = 'restart';
  return style;
}

/** A header driven like a footer's style, so status and offset can be fed without a scroll view. */
function driven(style: CYLRefreshRiveStyle): CYLRefreshRiveHeaderModel {
  const header = new CYLRefreshRiveHeaderModel(style);
  header.cyl_beginDriven();
  return header;
}

export default function refreshRiveTest() {
  describe('CYLRefreshRiveStyle', () => {
    it('maps the pull to the pull input', 0, () => {
      const bow = bowStyle();
      expect(bow.pullValue(0)).assertEqual(0);
      expect(bow.pullValue(100)).assertEqual(55);
      expect(bow.pullValue(200)).assertEqual(100);
      expect(bow.pullValue(400)).assertEqual(100);
      const bubbles = new CYLRefreshRiveStyle('Bubbles.riv');
      bubbles.pullInputStart = 4.0 / 7.0;
      bubbles.pullInputMaximum = 99;
      bubbles.pullInputRefreshingValue = 100;
      expect(bubbles.pullValue(100)).assertEqual(0);
      expect(bubbles.pullValue(180)).assertEqual(99);
      expect(bubbles.refreshingPullValue).assertEqual(100);
      expect(bow.refreshingPullValue).assertEqual(100);
    });

    it('scrubs the pull animation, lays out and counts the loading number', 0, () => {
      const style = new CYLRefreshRiveStyle('Halloween.riv');
      style.triggerOffset = 200;
      expect(style.pullAnimationTime(50)).assertEqual(0.25);
      expect(style.pullAnimationTime(300)).assertEqual(1);
      expect(style.layoutHeight(60)).assertEqual(200);
      style.minimumHeight = 140;
      expect(style.layoutHeight(60)).assertEqual(140);
      expect(style.layoutHeight(250)).assertEqual(250);
      expect(style.loadingNumberValue(1)).assertEqual(49.5);
      expect(style.loadingNumberValue(5)).assertEqual(99);
    });
  });

  describe('CYLRefreshRiveHeader', () => {
    it('stretches and opens at the trigger offset', 0, () => {
      const header = new CYLRefreshRiveHeaderModel(bowStyle());
      expect(header.scrollMode).assertEqual(CYLRefreshScrollMode.Stretch);
      expect(header.expandHeight).assertEqual(200);
    });

    it('drives state machine inputs through pull, release, finish and idle', 0, () => {
      const header = driven(bowStyle());
      const driver = new RecordingDriver();
      header.cyl_attachDriver(driver);
      driver.calls = [];
      header.cyl_driveOffset(100, true);
      expect(driver.calls.join('|')).assertEqual('number pull=55');
      driver.calls = [];
      header.cyl_driveStatus(CYLRefreshPhase.Releasing);
      expect(driver.calls.join('|')).assertEqual('number pull=100|fire advance');
      expect(header.cyl_rivePlaysRefresh).assertTrue();
      driver.calls = [];
      header.cyl_driveOffset(150, false);
      expect(driver.calls.length).assertEqual(0);
      header.cyl_driveStatus(CYLRefreshPhase.Refreshing);
      header.cyl_driveStatus(CYLRefreshPhase.Finishing);
      expect(driver.calls.join('|')).assertEqual('fire advance');
      driver.calls = [];
      header.cyl_driveStatus(CYLRefreshPhase.Idle);
      expect(driver.calls.join('|')).assertEqual('reset|number pull=0|fire restart|play - once');
      expect(header.cyl_rivePlaysRefresh).assertFalse();
    });

    it('drives linear animations and the loading boolean', 0, () => {
      const halloween = new CYLRefreshRiveStyle('Halloween.riv');
      halloween.pullAnimation = 'Pull';
      halloween.loadingAnimation = 'Loading';
      const header = driven(halloween);
      const driver = new RecordingDriver();
      header.cyl_attachDriver(driver);
      driver.calls = [];
      header.cyl_driveOffset(90, true);
      expect(driver.calls.join('|')).assertEqual('scrub Pull@0.5');
      driver.calls = [];
      header.cyl_driveStatus(CYLRefreshPhase.Releasing);
      expect(driver.calls.join('|')).assertEqual('play Loading loop');
      header.cyl_driveStatus(CYLRefreshPhase.Finishing);
      driver.calls = [];
      header.cyl_driveStatus(CYLRefreshPhase.Idle);
      expect(driver.calls.join('|')).assertEqual('reset|scrub Pull@0');

      const space = new CYLRefreshRiveStyle('Space.riv');
      space.stateMachineName = 'Reload';
      space.pullInput = 'Pull Amount';
      space.loadingBoolean = 'Start';
      const spaceHeader = driven(space);
      const spaceDriver = new RecordingDriver();
      spaceHeader.cyl_attachDriver(spaceDriver);
      spaceDriver.calls = [];
      spaceHeader.cyl_driveStatus(CYLRefreshPhase.Releasing);
      expect(spaceDriver.calls.join('|')).assertEqual('number Pull Amount=100|bool Start=true');
      spaceHeader.cyl_driveStatus(CYLRefreshPhase.Finishing);
      spaceDriver.calls = [];
      spaceHeader.cyl_driveStatus(CYLRefreshPhase.Idle);
      expect(spaceDriver.calls.join('|')).assertEqual('reset|bool Start=false|number Pull Amount=0|play - once');
    });

    it('replays the release for a player attached during a refresh', 0, () => {
      const header = driven(bowStyle());
      header.cyl_driveStatus(CYLRefreshPhase.Releasing);
      const driver = new RecordingDriver();
      header.cyl_attachDriver(driver);
      expect(driver.calls.join('|')).assertEqual('number pull=100|fire advance');
      header.cyl_detachDriver(driver);
      driver.calls = [];
      header.cyl_driveStatus(CYLRefreshPhase.Finishing);
      expect(driver.calls.length).assertEqual(0);
    });

    it('is hosted by a drawn footer', 0, () => {
      const style = bowStyle();
      const footer = CYLRefreshDrawnFooterModel.initWithStyle(new CYLRefreshRiveHeaderModel(style));
      expect(footer.style instanceof CYLRefreshRiveHeaderModel).assertTrue();
      expect(footer.cyl_h).assertEqual(200);
    });
  });

  describe('CYLRefreshAutoFooterHidden', () => {
    it('lays the auto footer item out only while not hidden, and tells its view', 0, () => {
      const footer = new CYLRefreshAutoNormalFooterModel();
      let changes = 0;
      footer.addChangeListener(() => changes++);
      expect(cylAutoFooterItemShown(footer)).assertTrue();
      footer.hidden = true;
      expect(cylAutoFooterItemShown(footer)).assertFalse();
      expect(changes).assertEqual(1);
      footer.hidden = true;
      expect(changes).assertEqual(1);
      footer.hidden = false;
      expect(cylAutoFooterItemShown(footer)).assertTrue();
      expect(changes).assertEqual(2);
      expect(cylAutoFooterItemShown(null)).assertFalse();
    });
  });
}
