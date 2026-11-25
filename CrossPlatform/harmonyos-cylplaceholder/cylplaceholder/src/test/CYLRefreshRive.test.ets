// Local (host) unit tests of the Rive refresh header's input mapping (pull → inputs / scrubbed time, release, finish,
// reset) through a recording driver, and of the auto footer's hidden rule.
import { describe, expect, it } from '@ohos/hypium';
import { CYLRefreshPhase } from '../main/ets/refresh/CYLRefreshConst';
import { CYLRefreshAutoNormalFooterModel } from '../main/ets/refresh/CYLRefreshClassics';
import { cylAutoFooterItemShown } from '../main/ets/refresh/CYLRefreshComponent';
import { CYLRefreshDrawnFooterModel } from '../main/ets/refresh/drawn/CYLRefreshDrawnHeader';
import {
  CYLRefreshRiveDrawnTable,
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
  describe('CYLRefreshRiveStyle finish rule', () => {
    it('holds finishTimeout when the style has an end part, finishDuration otherwise', 0, () => {
      const bow = bowStyle();
      expect(bow.finishTimeout).assertEqual(1.5);
      expect(bow.playsFinish).assertTrue();
      const header = driven(bow);
      expect(header.onRefreshFinishing(true)).assertEqual(1.5);
      bow.finishTimeout = 3;
      expect(header.onRefreshFinishing(true)).assertEqual(3);
      header.onStatus(CYLRefreshPhase.Finishing, CYLRefreshPhase.Idle);
      const plain = new CYLRefreshRiveStyle('Plain.riv');
      expect(plain.playsFinish).assertFalse();
      const plainHeader = driven(plain);
      plainHeader.finishDuration = 0.4;
      expect(plainHeader.onRefreshFinishing(true)).assertEqual(0.4);
      plainHeader.onStatus(CYLRefreshPhase.Finishing, CYLRefreshPhase.Idle);
    });

    it('hides the view for the collapse and shows it at the next pull', 0, () => {
      const header = driven(bowStyle());
      const seen: boolean[] = [];
      header.cyl_setHiddenListener((h: boolean) => seen.push(h));
      header.onStatus(CYLRefreshPhase.Refreshing, CYLRefreshPhase.Finishing);
      header.onRefreshFinishing(true);
      expect(header.cyl_collapseHidden).assertFalse();
      header.onStatus(CYLRefreshPhase.Finishing, CYLRefreshPhase.Idle);
      expect(header.cyl_collapseHidden).assertTrue();
      header.onStatus(CYLRefreshPhase.Idle, CYLRefreshPhase.PullToRefresh);
      expect(header.cyl_collapseHidden).assertFalse();
      expect(JSON.stringify(seen)).assertEqual('[true,false]');
    });
  });

  describe('CYLRefreshRiveDrawnTable', () => {
    const bow: number[][] = [[30, 0], [31.8, 0.14], [35.9, 0.43], [39.8, 0.66], [43.6, 0.82], [47.3, 0.94], [50, 1]];
    const near = (a: number | null, b: number): boolean => a !== null && Math.abs(a - b) < 1e-9;

    it('interpolates linearly and holds the end values', 0, () => {
      const table = CYLRefreshRiveDrawnTable.parse(bow);
      expect(table.isEmpty).assertFalse();
      expect(table.pairs.length).assertEqual(7);
      expect(near(table.fraction(0), 0)).assertTrue();
      expect(near(table.fraction(30), 0)).assertTrue();
      expect(near(table.fraction(31.8), 0.14)).assertTrue();
      expect(near(table.fraction(30.9), 0.07)).assertTrue();
      expect(near(table.fraction(37.85), (0.43 + 0.66) / 2)).assertTrue();
      expect(near(table.fraction(50), 1)).assertTrue();
      expect(near(table.fraction(80), 1)).assertTrue();
    });

    it('treats one pair as constant and no table as no clip', 0, () => {
      const one = CYLRefreshRiveDrawnTable.parse([[10, 0.5]]);
      expect(one.fraction(-5)).assertEqual(0.5);
      expect(one.fraction(99)).assertEqual(0.5);
      const bad: Object[] = [CYLRefreshRiveDrawnTable.parse(null), CYLRefreshRiveDrawnTable.parse(undefined),
        CYLRefreshRiveDrawnTable.parse([]), CYLRefreshRiveDrawnTable.parse('x'),
        CYLRefreshRiveDrawnTable.parse([['a', 1], [1]]), CYLRefreshRiveDrawnTable.EMPTY];
      for (const t of bad) {
        const table = t as CYLRefreshRiveDrawnTable;
        expect(table.isEmpty).assertTrue();
        expect(table.fraction(40)).assertEqual(null);
      }
    });

    it('ignores malformed pairs, sorts and clamps the fractions', 0, () => {
      const table = CYLRefreshRiveDrawnTable.parse([[50, 2], 'bad', [10], [10, 'x'], [NaN, 0.5], [20, Infinity],
        [30, -1], [40, 0.5, 9], null]);
      expect(JSON.stringify(table.pairs)).assertEqual('[[30,0],[40,0.5],[50,1]]');
      expect(near(table.fraction(35), 0.25)).assertTrue();
      expect(JSON.stringify(CYLRefreshRiveDrawnTable.of([[2, 0.4], [1, 0.2]]).pairs)).assertEqual('[[1,0.2],[2,0.4]]');
    });

    it('follows the pull input last sent, held through the refresh and 0 after the reset', 0, () => {
      const style = bowStyle();
      style.drawnTable = CYLRefreshRiveDrawnTable.parse(bow);
      const header = driven(style);
      const driver = new RecordingDriver();
      header.cyl_attachDriver(driver);
      const seen: Array<number | null> = [];
      header.cyl_setDrawnListener((f: number | null) => seen.push(f));
      header.onScrollingWithOffset(200, 1, true);
      expect(header.cyl_drawnFraction).assertEqual(1);
      header.onScrollingWithOffset(0, 0, true);
      expect(header.cyl_drawnFraction).assertEqual(0);
      expect(seen.length).assertEqual(2);
      expect(new CYLRefreshRiveHeaderModel(bowStyle()).cyl_drawnFraction).assertEqual(null);
    });
  });
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
