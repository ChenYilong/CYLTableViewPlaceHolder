// Local (host) unit tests of the non-UI rules: HUD state and timing, configuration parsing, the network monitor's
// status rules, the status bar, the page status display and the list placeholder.
import { describe, expect, it } from '@ohos/hypium';
import {
  CYLPlaceholderHUD,
  CYLPlaceholderHUDDidAppearNotification,
  CYLPlaceholderHUDDidDisappearNotification,
  CYLPlaceholderHUDScheduler,
  CYLPlaceholderHUDState,
  CYLPlaceholderHUDStyle,
  CYLPlaceholderHUDWillAppearNotification
} from '../main/ets/hud/CYLPlaceholderHUD';
import { CYLPlaceholderConfiguration } from '../main/ets/CYLPlaceholderConfiguration';
import { CYLPlaceholderStackViewModel } from '../main/ets/CYLPlaceholderStackView';
import { CYLPlaceholderActions, CYLPlaceholderScenario } from '../main/ets/CYLPlaceholderScenario';
import { CYLPlaceholderLocalization } from '../main/ets/CYLPlaceholderLocalization';
import { CYLPlaceholderTapHighlightStyle } from '../main/ets/CYLPlaceholderViewTypes';
import { CYLPlaceholderNetworkMonitor, CYLPlaceholderNetworkStatus } from '../main/ets/CYLPlaceholderNetworkMonitor';
import { CYLPlaceholderStatusViewModel } from '../main/ets/CYLPlaceholderStatusView';
import { CYLPlaceholderStatusController, CYLPlaceholderStatusDisplay } from '../main/ets/CYLPlaceholderStatus';
import { CYLPlaceholderListController } from '../main/ets/CYLPlaceholderList';
import { CYLRefreshScrollViewModel } from '../main/ets/refresh/CYLRefreshComponent';
import {
  CYLRefreshAutoNormalFooterModel,
  CYLRefreshNormalHeaderModel,
  CYLRefreshNormalTrailerModel
} from '../main/ets/refresh/CYLRefreshClassics';

class FakeTask {
  id: number;
  due: number;
  callback: () => void;

  constructor(id: number, due: number, callback: () => void) {
    this.id = id;
    this.due = due;
    this.callback = callback;
  }
}

/** A manual clock for the HUD's timers. */
class FakeScheduler implements CYLPlaceholderHUDScheduler {
  now: number = 0;
  tasks: FakeTask[] = [];
  nextId: number = 1;
  schedule: (callback: () => void, milliseconds: number) => number = (callback: () => void, milliseconds: number) => {
    const id = this.nextId++;
    this.tasks.push(new FakeTask(id, this.now + milliseconds, callback));
    return id;
  };
  cancel: (id: number) => void = (id: number) => {
    this.tasks = this.tasks.filter((t: FakeTask) => t.id !== id);
  };

  advance(milliseconds: number): void {
    const end = this.now + milliseconds;
    for (;;) {
      let next: FakeTask | null = null;
      for (let i = 0; i < this.tasks.length; i++) {
        if (this.tasks[i].due <= end && (next === null || this.tasks[i].due < next.due)) {
          next = this.tasks[i];
        }
      }
      if (next === null) {
        break;
      }
      const task = next;
      this.tasks = this.tasks.filter((t: FakeTask) => t.id !== task.id);
      this.now = task.due;
      task.callback();
    }
    this.now = end;
  }
}

function makeHUD(): FakeScheduler {
  return new FakeScheduler();
}

export default function placeholderHUDStatusTest() {
  describe('CYLPlaceholderHUDStatus', () => {
    it('hudCountsActivities', 0, () => {
      const clock = makeHUD();
      const hud = new CYLPlaceholderHUD(null);
      hud.scheduler = clock;
      hud.show();
      hud.showWithStatus('Loading');
      expect(hud.state).assertEqual(CYLPlaceholderHUDState.Loading);
      expect(hud.status).assertEqual('Loading');
      expect(hud.activityCount).assertEqual(2);
      expect(hud.visible).assertTrue();
      hud.popActivity();
      expect(hud.visible).assertTrue();
      hud.popActivity();
      clock.advance(1000);
      expect(hud.visible).assertFalse();
      expect(hud.state).assertEqual(CYLPlaceholderHUDState.Hidden);
      expect(hud.activityCount).assertEqual(0);
    });

    it('hudTimedStatesUseDisplayDuration', 0, () => {
      const clock = makeHUD();
      const hud = new CYLPlaceholderHUD(null);
      hud.scheduler = clock;
      expect(hud.displayDurationForString(null)).assertEqual(1.5);
      expect(hud.displayDurationForString('x'.repeat(50))).assertClose(3.5, 0.0001);
      expect(hud.displayDurationForString('x'.repeat(500))).assertEqual(5);
      hud.show();
      hud.showSuccessWithStatus('Saved');
      expect(hud.state).assertEqual(CYLPlaceholderHUDState.Success);
      expect(hud.activityCount).assertEqual(0);
      expect(hud.contentView !== null).assertTrue();
      clock.advance(1400);
      expect(hud.visible).assertTrue();
      clock.advance(300);
      expect(hud.visible).assertFalse();
      hud.showErrorWithStatus('x'.repeat(50));
      clock.advance(3400);
      expect(hud.state).assertEqual(CYLPlaceholderHUDState.Error);
      clock.advance(300);
      expect(hud.state).assertEqual(CYLPlaceholderHUDState.Hidden);
    });

    it('hudGraceAndProgress', 0, () => {
      const clock = makeHUD();
      const hud = new CYLPlaceholderHUD(null);
      hud.scheduler = clock;
      hud.graceTimeInterval = 0.5;
      hud.showWithStatus('Wait');
      expect(hud.visible).assertFalse();
      hud.popActivity();
      clock.advance(1000);
      expect(hud.visible).assertFalse();
      hud.graceTimeInterval = 0;
      hud.showProgressStatus(1.7, 'Uploading');
      expect(hud.state).assertEqual(CYLPlaceholderHUDState.Progress);
      expect(hud.progress).assertEqual(1);
      expect(hud.activityCount).assertEqual(1);
      hud.showProgress(0.25);
      expect(hud.progress).assertEqual(0.25);
      expect(hud.status).assertEqual('Uploading');
      expect(hud.activityCount).assertEqual(1);
      hud.showProgressStatus(-1, 'Working');
      expect(hud.state).assertEqual(CYLPlaceholderHUDState.Loading);
      hud.setStatus('Almost');
      expect(hud.contentView !== null && hud.contentView.text === 'Almost').assertTrue();
    });

    it('hudDismissDelayCompletionAndNotifications', 0, () => {
      const clock = makeHUD();
      const hud = new CYLPlaceholderHUD(null);
      hud.scheduler = clock;
      const names: string[] = [];
      const observer = (name: string, h: CYLPlaceholderHUD, status: string | null) => {
        if (h === hud) {
          names.push(name);
        }
      };
      CYLPlaceholderHUD.addObserver(observer);
      let completed = 0;
      hud.showScenarioActions(CYLPlaceholderScenario.RetryButton, null);
      expect(hud.state).assertEqual(CYLPlaceholderHUDState.Custom);
      expect(hud.placeholderView !== null).assertTrue();
      clock.advance(200);
      hud.dismissWithDelayCompletion(1, () => {
        completed++;
      });
      clock.advance(900);
      expect(hud.visible).assertTrue();
      clock.advance(300);
      expect(hud.visible).assertFalse();
      expect(completed).assertEqual(1);
      CYLPlaceholderHUD.removeObserver(observer);
      expect(names[0]).assertEqual(CYLPlaceholderHUDWillAppearNotification);
      expect(names[1]).assertEqual(CYLPlaceholderHUDDidAppearNotification);
      expect(names[names.length - 1]).assertEqual(CYLPlaceholderHUDDidDisappearNotification);
    });

    it('hudColorsSelectCustomStyle', 0, () => {
      const hud = new CYLPlaceholderHUD(null);
      expect(hud.style).assertEqual(CYLPlaceholderHUDStyle.Automatic);
      hud.foregroundColor = '#FF0000';
      expect(hud.style).assertEqual(CYLPlaceholderHUDStyle.Custom);
      expect(hud.contentColor).assertEqual('#FF0000');
      hud.font = null;
      expect(hud.font).assertEqual(15);
      hud.style = CYLPlaceholderHUDStyle.Dark;
      expect(hud.isDark).assertTrue();
      expect(CYLPlaceholderHUD.sharedHUD === CYLPlaceholderHUD.sharedHUD).assertTrue();
    });

    it('parsesConfigurations', 0, () => {
      CYLPlaceholderLocalization.language = 'en';
      const json = CYLPlaceholderConfiguration.parseJSON('{"scenario":"retryButton","overrides":[{"index":1,' +
        '"highlightStyle":"shrink","spacingBefore":12}],"backgroundAction":"","accessibilityIdentifier":"p"}');
      expect(json !== null).assertTrue();
      let error = '';
      const m = CYLPlaceholderStackViewModel.initWithConfiguration(json, null, (e: string) => {
        error = e;
      });
      expect(m !== null).assertTrue();
      if (m !== null) {
        expect(m.scenario).assertEqual(CYLPlaceholderScenario.RetryButton);
        expect(m.backgroundAction === null).assertTrue();
        expect(m.accessibilityIdentifier).assertEqual('p');
        expect(m.entries[1].spacingBefore).assertEqual(12);
        expect(m.entries[1].view.tapHighlightStyle).assertEqual(CYLPlaceholderTapHighlightStyle.Shrink);
        expect(m.componentViewForAction(CYLPlaceholderActions.Retry) !== null).assertTrue();
      }
      const bad = CYLPlaceholderConfiguration.parseJSON('{"overrides":[]}');
      expect(CYLPlaceholderStackViewModel.initWithConfiguration(bad, null, (e: string) => {
        error = e;
      }) === null).assertTrue();
      expect(error).assertEqual('The configuration needs a "scenario" or "components".');
      expect(CYLPlaceholderConfiguration.parseJSON('[1]') === null).assertTrue();
      const plist = CYLPlaceholderConfiguration.parseText('<?xml version="1.0"?><plist version="1.0"><dict>' +
        '<key>components</key><array><dict><key>type</key><string>hint</string><key>text</key>' +
        '<string>A &amp; B</string></dict></array><key>n</key><integer>3</integer><key>t</key><true/></dict></plist>',
        'a.plist');
      expect(plist !== null).assertTrue();
      if (plist !== null) {
        expect(plist['n'] as number).assertEqual(3);
        expect(plist['t'] as boolean).assertTrue();
        const fromPlist = CYLPlaceholderStackViewModel.initWithConfiguration(plist);
        expect(fromPlist !== null && fromPlist.entries[0].view.text === 'A & B').assertTrue();
      }
      expect(CYLPlaceholderConfiguration.parsePropertyList('bplist00') === null).assertTrue();
      const text: Record<string, Object> = { 'textKey': 'CYLPlaceholderStatusNetworkUnavailable', 'text': 'x' };
      expect(CYLPlaceholderConfiguration.configuredText(text, 'text', 'textKey'))
        .assertEqual('Network unavailable, Check network');
      expect(CYLPlaceholderStackViewModel.initWithContentsOfURL('/nonexistent/a.json') === null).assertTrue();
    });

    it('networkMonitorRules', 0, () => {
      const monitor = new CYLPlaceholderNetworkMonitor();
      expect(monitor.networkStatus).assertEqual(CYLPlaceholderNetworkStatus.Unknown);
      expect(monitor.reachable).assertTrue();
      expect(CYLPlaceholderNetworkMonitor.statusForBearerTypes([1])).assertEqual(
        CYLPlaceholderNetworkStatus.ReachableViaWiFi);
      expect(CYLPlaceholderNetworkMonitor.statusForBearerTypes([0])).assertEqual(
        CYLPlaceholderNetworkStatus.ReachableViaWWAN);
      expect(CYLPlaceholderNetworkMonitor.statusForBearerTypes([3])).assertEqual(
        CYLPlaceholderNetworkStatus.ReachableViaWiredEthernet);
      expect(CYLPlaceholderNetworkMonitor.statusForBearerTypes([4])).assertEqual(
        CYLPlaceholderNetworkStatus.ReachableViaOther);
      expect(CYLPlaceholderNetworkMonitor.nameForStatus(CYLPlaceholderNetworkStatus.NotReachable))
        .assertEqual('not reachable');
      const seen: CYLPlaceholderNetworkStatus[] = [];
      monitor.setNetworkStatusChangeBlock((s: CYLPlaceholderNetworkStatus) => {
        seen.push(s);
      });
      monitor.applyCapabilities(null, null);
      expect(seen.length).assertEqual(0);
      monitor.beginManualMonitoringForTesting();
      expect(monitor.monitoring).assertTrue();
      monitor.applyCapabilities([0], [12]);
      expect(monitor.expensive).assertTrue();
      monitor.applyCapabilities([0], [12]);
      monitor.applyCapabilities(null, null);
      expect(monitor.reachable).assertFalse();
      expect(seen.length).assertEqual(2);
    });

    it('statusBarAndPageDisplay', 0, () => {
      CYLPlaceholderLocalization.language = 'en';
      const bar = CYLPlaceholderStatusViewModel.initWithFrame();
      expect(bar.text).assertEqual('Network unavailable, Check network');
      const order: string[] = [];
      bar.delegate = {
        statusViewClicked: (sender: CYLPlaceholderStatusViewModel) => {
          order.push('delegate');
        }
      };
      bar.tapHandler = (v: CYLPlaceholderStatusViewModel) => {
        order.push('handler');
      };
      bar.performTap();
      expect(order.join(',')).assertEqual('delegate,handler');
      let error = '';
      const config: Record<string, Object> = { 'text': 'Offline', 'backgroundColor': '#FFC7C7' };
      const custom = CYLPlaceholderStatusViewModel.initWithConfiguration(config);
      expect(custom !== null && custom.text === 'Offline').assertTrue();
      const wrong: Record<string, Object> = { 'titleColor': 'red-ish' };
      expect(CYLPlaceholderStatusViewModel.initWithConfiguration(wrong, (e: string) => {
        error = e;
      }) === null).assertTrue();
      expect(error).assertEqual('"titleColor" is not a color.');

      let items = 0;
      const list = new CYLPlaceholderListController(() => items);
      list.cyl_placeholderViewBlock((t: CYLPlaceholderListController) =>
      CYLPlaceholderStackViewModel.initWithScenario(CYLPlaceholderScenario.NoContent));
      const page = new CYLPlaceholderStatusController();
      const monitor = new CYLPlaceholderNetworkMonitor();
      page.networkMonitor = monitor;
      page.cyl_placeholderScrollView = list;
      expect(page.cyl_statusDisplay).assertEqual(CYLPlaceholderStatusDisplay.Placeholder);
      expect(list.placeholder !== null).assertTrue();
      page.cyl_statusDisplay = CYLPlaceholderStatusDisplay.StatusBar;
      expect(page.statusBarVisible).assertTrue();
      expect(list.cyl_placeholderHidden).assertTrue();
      expect(list.placeholder === null).assertTrue();
      const applied: Record<string, Object> = { 'display': 'none' };
      expect(page.cyl_applyStatusConfiguration(applied)).assertTrue();
      expect(page.statusBarVisible).assertFalse();
      const barOnly: Record<string, Object> = { 'statusBar': true };
      expect(page.cyl_applyStatusConfiguration(barOnly)).assertTrue();
      expect(page.cyl_statusDisplay).assertEqual(CYLPlaceholderStatusDisplay.All);
      const invalid: Record<string, Object> = { 'display': 'sometimes' };
      expect(page.cyl_applyStatusConfiguration(invalid)).assertFalse();
      expect(page.cyl_statusDisplay).assertEqual(CYLPlaceholderStatusDisplay.All);

      page.cyl_statusDisplay = CYLPlaceholderStatusDisplay.Placeholder;
      monitor.beginManualMonitoringForTesting();
      page.cyl_showsStatusViewWhenOffline = true;
      monitor.applyCapabilities(null, null);
      expect(page.cyl_statusDisplay).assertEqual(CYLPlaceholderStatusDisplay.All);
      expect(page.statusBarAnimated).assertTrue();
      monitor.applyCapabilities([1], [11, 12]);
      expect(page.cyl_statusDisplay).assertEqual(CYLPlaceholderStatusDisplay.Placeholder);
      page.cyl_showsStatusViewWhenOffline = false;
      monitor.stopMonitoring();
    });

    it('listPlaceholderHidesLoadMore', 0, () => {
      // An empty list has nothing more to load: its footer and trailer hide while the placeholder shows (the header
      // stays) and show again with the data; a footer the app hid itself stays hidden (iOS bbd1190).
      let items = 0;
      const list = new CYLPlaceholderListController(() => items);
      const scrollView = new CYLRefreshScrollViewModel();
      const header = new CYLRefreshNormalHeaderModel();
      const footer = new CYLRefreshAutoNormalFooterModel();
      const trailer = new CYLRefreshNormalTrailerModel();
      scrollView.cyl_header = header;
      scrollView.cyl_footer = footer;
      scrollView.cyl_trailer = trailer;
      list.refreshScrollView = scrollView;
      list.cyl_placeholderViewBlock((t: CYLPlaceholderListController) =>
      CYLPlaceholderStackViewModel.initWithScenario(CYLPlaceholderScenario.RetryButton));
      expect(list.placeholder !== null).assertTrue();
      expect(footer.hidden).assertTrue();
      expect(trailer.hidden).assertTrue();
      expect(header.hidden).assertFalse();
      items = 3;
      list.cyl_reloadData();
      expect(list.placeholder === null).assertTrue();
      expect(footer.hidden).assertFalse();
      expect(trailer.hidden).assertFalse();
      footer.hidden = true;
      items = 0;
      list.cyl_reloadData();
      items = 3;
      list.cyl_reloadData();
      expect(footer.hidden).assertTrue();
    });

    it('listPlaceholderRules', 0, () => {
      let items = 0;
      let made = 0;
      let normal = 0;
      const list = new CYLPlaceholderListController(() => items);
      list.cyl_placeholderViewBlockBackToNormalBlock((t: CYLPlaceholderListController) => {
        made++;
        return CYLPlaceholderStackViewModel.initWithScenario(CYLPlaceholderScenario.NoContent);
      }, (t: CYLPlaceholderListController) => {
        normal++;
      });
      expect(made).assertEqual(1);
      list.reloadData();
      expect(made).assertEqual(1);
      list.cyl_reloadData();
      expect(made).assertEqual(2);
      items = 3;
      list.cyl_reloadData();
      expect(list.placeholder === null).assertTrue();
      expect(normal).assertEqual(1);
      items = 0;
      list.cyl_placeholderHidden = true;
      list.cyl_reloadData();
      expect(list.placeholder === null).assertTrue();
      list.cyl_placeholderHidden = false;
      expect(list.placeholder !== null).assertTrue();
      list.cyl_placeholderViewBlock(null);
      expect(list.placeholder === null).assertTrue();
    });
  });
}
