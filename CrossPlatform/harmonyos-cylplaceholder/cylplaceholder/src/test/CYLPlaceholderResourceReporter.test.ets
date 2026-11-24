// Local (host) unit tests of the missing-resource red bar (docs/Status-Bar.md "资源缺失 / Missing resource"): the
// reporter's counting, short names and texts, and the status controller showing the text in the bar.
import { describe, expect, it } from '@ohos/hypium';
import { CYLPlaceholderResourceReporter } from '../main/ets/CYLPlaceholderResourceReporter';
import { CYLPlaceholderLocalization } from '../main/ets/CYLPlaceholderLocalization';
import { CYLPlaceholderNetworkMonitor } from '../main/ets/CYLPlaceholderNetworkMonitor';
import { CYLPlaceholderStatusController, CYLPlaceholderStatusDisplay } from '../main/ets/CYLPlaceholderStatus';

class Source {
  name: string;

  constructor(name: string) {
    this.name = name;
  }
}

export default function placeholderResourceReporterTest() {
  describe('CYLPlaceholderResourceReporter', () => {
    it('shortNameKeepsTheLastSegment', 0, () => {
      expect(CYLPlaceholderResourceReporter.shortName('asset:Folder/home.pag')).assertEqual('home.pag');
      expect(CYLPlaceholderResourceReporter.shortName('/data/storage/el2/base/x/Missing.riv#artboard=A'))
        .assertEqual('Missing.riv');
      expect(CYLPlaceholderResourceReporter.shortName('home.json?x=1')).assertEqual('home.json');
      expect(CYLPlaceholderResourceReporter.shortName('C:\\a\\b.svga')).assertEqual('b.svga');
      expect(CYLPlaceholderResourceReporter.shortName('')).assertEqual('');
    });

    it('formatFillsJavaStylePlaceholders', 0, () => {
      expect(CYLPlaceholderResourceReporter.format('Missing resource: %1$s (%2$s)', ['a.pag', 'file not found']))
        .assertEqual('Missing resource: a.pag (file not found)');
      expect(CYLPlaceholderResourceReporter.format('Missing resource: %s (%s)', ['a.pag', 'unreadable']))
        .assertEqual('Missing resource: a.pag (unreadable)');
      expect(CYLPlaceholderResourceReporter.format('%1$s +%2$d more', ['a.pag', '5'])).assertEqual('a.pag +5 more');
    });

    it('aResourceIsCountedOnceAndTheHandlerRunsOnce', 0, () => {
      CYLPlaceholderLocalization.language = 'en';
      const reporter = new CYLPlaceholderResourceReporter();
      let calls = 0;
      let last = '';
      reporter.onResourceMissing = (resource: string, reason: string) => {
        calls++;
        last = resource + '|' + reason;
      };
      const a = new Source('a');
      const b = new Source('b');
      expect(reporter.text === null).assertTrue();
      expect(reporter.report('asset:Folder/home.pag', 'file not found', a)).assertTrue();
      expect(reporter.report('/other/dir/home.pag', 'file not found', b)).assertFalse();
      expect(calls).assertEqual(1);
      expect(last).assertEqual('home.pag|file not found');
      expect(reporter.missingResourceNames.length).assertEqual(1);
      expect(reporter.text).assertEqual('Missing resource: home.pag (file not found)');
      CYLPlaceholderLocalization.language = null;
    });

    it('severalResourcesReadFirstPlusCount', 0, () => {
      CYLPlaceholderLocalization.language = 'en';
      const reporter = new CYLPlaceholderResourceReporter();
      const source = new Source('page');
      for (let i = 0; i < 6; i++) {
        reporter.report('f' + i + '.pag', 'file not found', source);
      }
      expect(reporter.text).assertEqual('Missing resources: f0.pag +5 more');
      CYLPlaceholderLocalization.language = null;
    });

    it('resolveAndRemoveSourceClearTheReports', 0, () => {
      const reporter = new CYLPlaceholderResourceReporter();
      const a = new Source('a');
      const b = new Source('b');
      let changes = 0;
      reporter.addObserver((r: CYLPlaceholderResourceReporter) => {
        changes++;
      });
      reporter.report('x.pag', 'file not found', a);
      reporter.report('x.pag', 'file not found', b);
      reporter.report('y.riv', 'unreadable', a);
      expect(changes).assertEqual(2);
      reporter.resolve('x.pag', a);
      expect(reporter.missingResourceNames.length).assertEqual(2);
      reporter.resolve('x.pag', b);
      expect(reporter.missingResourceNames.length).assertEqual(1);
      reporter.removeSource(a);
      expect(reporter.text === null).assertTrue();
      expect(changes).assertEqual(4);
      reporter.report('z.json', 'file not found', a);
      reporter.reset();
      expect(reporter.missingResourceNames.length).assertEqual(0);
    });

    it('theBarShowsTheTextAndGivesItBack', 0, () => {
      CYLPlaceholderLocalization.language = 'en';
      const reporter = new CYLPlaceholderResourceReporter();
      const page = new CYLPlaceholderStatusController();
      page.resourceReporter = reporter;
      const own = page.cyl_statusView.text;
      expect(page.statusBarVisible).assertFalse();
      // Off by default: nothing shows.
      reporter.report('Missing.pag', 'file not found', new Source('v'));
      expect(page.statusBarVisible).assertFalse();
      page.cyl_showsMissingResources = true;
      expect(page.statusBarVisible).assertTrue();
      expect(page.cyl_statusView.text).assertEqual('Missing resource: Missing.pag (file not found)');
      expect(page.statusBarAnimated).assertTrue();
      reporter.report('Other.riv', 'unreadable', new Source('w'));
      expect(page.cyl_statusView.text).assertEqual('Missing resources: Missing.pag +1 more');
      reporter.reset();
      // The bar the resources opened is closed again, and the bar has its own text back.
      expect(page.statusBarVisible).assertFalse();
      expect(page.cyl_statusView.text).assertEqual(own);
      page.cyl_showsMissingResources = false;
      CYLPlaceholderLocalization.language = null;
    });

    it('aBarThePageOpenedStaysOpen', 0, () => {
      CYLPlaceholderLocalization.language = 'en';
      const reporter = new CYLPlaceholderResourceReporter();
      const page = new CYLPlaceholderStatusController();
      page.resourceReporter = reporter;
      page.cyl_statusDisplay = CYLPlaceholderStatusDisplay.All;
      const own = page.cyl_statusView.text;
      page.cyl_showsMissingResources = true;
      const source = new Source('v');
      reporter.report('Missing.pag', 'file not found', source);
      expect(page.cyl_statusView.text).assertEqual('Missing resource: Missing.pag (file not found)');
      reporter.resolve('Missing.pag', source);
      expect(page.statusBarVisible).assertTrue();
      expect(page.cyl_statusView.text).assertEqual(own);
      page.cyl_showsMissingResources = false;
      CYLPlaceholderLocalization.language = null;
    });

    it('theNetworkTextWinsWhileOffline', 0, () => {
      CYLPlaceholderLocalization.language = 'en';
      const reporter = new CYLPlaceholderResourceReporter();
      const page = new CYLPlaceholderStatusController();
      const monitor = new CYLPlaceholderNetworkMonitor();
      page.networkMonitor = monitor;
      page.resourceReporter = reporter;
      const network = page.cyl_statusView.text;
      monitor.beginManualMonitoringForTesting();
      page.cyl_showsStatusViewWhenOffline = true;
      page.cyl_showsMissingResources = true;
      reporter.report('Missing.pag', 'file not found', new Source('v'));
      expect(page.cyl_statusView.text).assertEqual('Missing resource: Missing.pag (file not found)');
      monitor.applyCapabilities(null, null);
      expect(page.cyl_statusView.text).assertEqual(network);
      expect(page.statusBarVisible).assertTrue();
      monitor.applyCapabilities([1], [11, 12]);
      expect(page.statusBarVisible).assertTrue();
      expect(page.cyl_statusView.text).assertEqual('Missing resource: Missing.pag (file not found)');
      page.cyl_showsStatusViewWhenOffline = false;
      page.cyl_showsMissingResources = false;
      monitor.stopMonitoring();
      CYLPlaceholderLocalization.language = null;
    });
  });
}
