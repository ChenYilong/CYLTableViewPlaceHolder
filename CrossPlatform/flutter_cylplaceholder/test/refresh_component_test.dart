import 'package:flutter/services.dart';
import 'package:flutter_cylplaceholder/flutter_cylplaceholder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('component state (long-lived ChangeNotifier, phase, state, percent, offsets)', () {
    test('pulling walks idle -> pullToRefresh -> releaseToRefresh and reports the percent', () {
      final header = CYLRefreshHeader(expandHeight: 60, triggerRate: 1.5);
      final phases = <CYLRefreshPhase>[];
      header.addPhaseObserver((component, phase, old) => phases.add(phase));
      expect(header.triggerOffset, 90);
      header.handlePull(30, dragging: true);
      expect(header.phase, CYLRefreshPhase.pullToRefresh);
      expect(header.state, CYLRefreshState.pulling);
      expect(header.pullingPercent, closeTo(1 / 3, 1e-9));
      expect(header.dragOffset, 30);
      header.handlePull(95, dragging: true);
      expect(header.phase, CYLRefreshPhase.releaseToRefresh);
      header.handlePull(0, dragging: true);
      expect(header.phase, CYLRefreshPhase.idle);
      expect(phases, [CYLRefreshPhase.pullToRefresh, CYLRefreshPhase.releaseToRefresh, CYLRefreshPhase.idle]);
      header.dispose();
    });

    test('release starts refreshing once; endRefreshing records the result', () async {
      var calls = 0;
      final header = CYLRefreshHeader(refreshingHandler: () => calls++, finishDuration: const Duration(milliseconds: 10));
      header.handlePull(80, dragging: true);
      header.handleRelease();
      expect(header.phase, CYLRefreshPhase.refreshing);
      expect(header.isRefreshing, isTrue);
      expect(calls, 1);
      header.endRefreshing(success: false);
      expect(header.phase, CYLRefreshPhase.finishing);
      expect(header.lastRefreshSucceeded, isFalse);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(header.phase, CYLRefreshPhase.idle);
      expect(header.lastUpdatedTime, isNull);
      header.dispose();
    });

    test('the caller always ends refreshing: it stays refreshing until endRefreshing', () async {
      final header = CYLRefreshHeader(finishDuration: Duration.zero);
      header.handlePull(80, dragging: true);
      header.handleRelease();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(header.phase, CYLRefreshPhase.refreshing);
      header.dispose();
    });
  });

  group('trigger rules (refreshEnabled, triggerMode, triggersWhenReached, hapticFeedback, notifiesWhenHidden)', () {
    test('refreshEnabled = false never arms', () {
      final header = CYLRefreshHeader(refreshEnabled: false);
      header.handlePull(100, dragging: true);
      expect(header.phase, CYLRefreshPhase.idle);
      header.handleRelease();
      expect(header.isRefreshing, isFalse);
      header.dispose();
    });

    test('onEdge ignores a pull that did not start at the edge', () {
      final header = CYLRefreshHeader(triggerMode: CYLRefreshTriggerMode.onEdge);
      header.handlePull(100, dragging: true, startedAtEdge: false);
      expect(header.phase, CYLRefreshPhase.idle);
      header.handlePull(100, dragging: true, startedAtEdge: true);
      expect(header.phase, CYLRefreshPhase.releaseToRefresh);
      header.dispose();
    });

    test('triggersWhenReached refreshes without a release', () {
      final header = CYLRefreshHeader(triggersWhenReached: true);
      header.handlePull(70, dragging: true);
      expect(header.isRefreshing, isTrue);
      header.dispose();
    });

    test('hapticFeedback vibrates once when the pull is armed', () {
      final calls = <String>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'HapticFeedback.vibrate') calls.add('${call.arguments}');
        return null;
      });
      final header = CYLRefreshHeader(hapticFeedback: true);
      header.handlePull(70, dragging: true);
      header.handlePull(80, dragging: true);
      expect(calls, ['HapticFeedbackType.mediumImpact']);
      header.dispose();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null);
    });

    test('notifiesWhenHidden decides whether a hidden component notifies', () {
      var hidden = 0;
      var always = 0;
      final quiet = CYLRefreshHeader()..addListener(() => hidden++);
      final loud = CYLRefreshHeader(notifiesWhenHidden: true)..addListener(() => always++);
      quiet.handlePull(0, dragging: false);
      loud.handlePull(0, dragging: false);
      expect(hidden, 0);
      expect(always, 1);
      quiet.dispose();
      loud.dispose();
    });

    test('phase observers can be removed', () {
      final header = CYLRefreshHeader();
      var n = 0;
      void observer(CYLRefreshComponent c, CYLRefreshPhase p, CYLRefreshPhase o) => n++;
      header.addPhaseObserver(observer);
      header.handlePull(10, dragging: true);
      header.removePhaseObserver(observer);
      header.handlePull(0, dragging: true);
      expect(n, 1);
      header.dispose();
    });

    test('properties can be overridden on the instance (no wrapper class)', () {
      final header = CYLRefreshHeader();
      header
        ..expandHeight = 80
        ..colorAccent = const Color(0xFF112233);
      expect(header.expandHeight, 80);
      expect(header.colorAccent, const Color(0xFF112233));
      header.dispose();
    });
  });

  group('footer (no more data, loadsAfterNoMoreData)', () {
    test('endRefreshingWithNoMoreData stops loading until resetNoMoreData', () {
      final footer = CYLRefreshBackFooter();
      expect(footer.isNoMoreData, isFalse);
      footer.handlePull(80, dragging: true);
      footer.handleRelease();
      footer.endRefreshingWithNoMoreData();
      expect(footer.isNoMoreData, isTrue);
      expect(footer.state, CYLRefreshState.noMoreData);
      expect(footer.holdsSpace, isTrue);
      footer.handlePull(80, dragging: true);
      expect(footer.phase, CYLRefreshPhase.finishing);
      footer.resetNoMoreData();
      expect(footer.isNoMoreData, isFalse);
      footer.dispose();
    });

    test('loadsAfterNoMoreData lets a pull load again and clears the flag', () {
      final footer = CYLRefreshBackFooter(loadsAfterNoMoreData: true, finishDuration: Duration.zero);
      footer.noticeNoMoreData();
      footer.handlePull(80, dragging: true);
      expect(footer.phase, CYLRefreshPhase.releaseToRefresh);
      footer.handleRelease();
      expect(footer.isRefreshing, isTrue);
      expect(footer.isNoMoreData, isFalse);
      footer.dispose();
    });
  });
}
