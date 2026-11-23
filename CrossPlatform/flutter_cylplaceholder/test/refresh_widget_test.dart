import 'package:flutter/material.dart';
import 'package:flutter_cylplaceholder/flutter_cylplaceholder.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  group('CYLRefresh header: pull, release, refreshingHandler, endRefreshing', () {
    testWidgets('a pull arms, a release refreshes, endRefreshing closes', (tester) async {
      var calls = 0;
      late CYLRefreshHeader header;
      header = plainHeader(onRefresh: () => calls++);
      await tester.pumpWidget(refresh(header: header));
      final gesture = await pullDown(tester, 300, release: false);
      expect(header.phase, CYLRefreshPhase.releaseToRefresh);
      expect(header.dragOffset, greaterThan(header.triggerOffset));
      await gesture.up();
      await frames(tester, 600);
      expect(calls, 1);
      expect(header.phase, CYLRefreshPhase.refreshing);
      // The indicator holds expandHeight: the first row sits expandHeight below the top.
      expect(tester.getTopLeft(find.text('Item 0')).dy - tester.getTopLeft(find.byType(CYLRefresh)).dy, closeTo(header.expandHeight, 1));
      header.endRefreshing();
      await tester.pump();
      expect(header.phase, CYLRefreshPhase.finishing);
      await settle(tester);
      expect(header.phase, CYLRefreshPhase.idle);
      expect(tester.getTopLeft(find.text('Item 0')).dy - tester.getTopLeft(find.byType(CYLRefresh)).dy, closeTo(0, 1));
      header.dispose();
    });

    testWidgets('a short pull springs back without refreshing', (tester) async {
      var calls = 0;
      final header = plainHeader(onRefresh: () => calls++);
      await tester.pumpWidget(refresh(header: header));
      await pullDown(tester, 40);
      await settle(tester);
      expect(calls, 0);
      expect(header.phase, CYLRefreshPhase.idle);
      header.dispose();
    });
  });

  group('beginRefreshing, refreshOnStart, refreshOnStartHeader', () {
    testWidgets('beginRefreshing(duration, overOffset) opens the header and calls the handler', (tester) async {
      var calls = 0;
      final header = plainHeader(onRefresh: () => calls++);
      await tester.pumpWidget(refresh(header: header));
      header.beginRefreshing(duration: const Duration(milliseconds: 100), overOffset: 30);
      await frames(tester, 100);
      expect(calls, 1);
      expect(header.isRefreshing, isTrue);
      await frames(tester, 400);
      expect(tester.getTopLeft(find.text('Item 0')).dy - tester.getTopLeft(find.byType(CYLRefresh)).dy, closeTo(header.expandHeight, 1));
      header.beginRefreshing();
      expect(calls, 1, reason: 'already refreshing');
      header.beginRefreshing(force: true);
      expect(calls, 2);
      header.endRefreshing();
      await settle(tester);
      header.dispose();
    });

    testWidgets('beginRefreshing respects refreshEnabled unless forced', (tester) async {
      var calls = 0;
      final header = plainHeader(onRefresh: () => calls++)..refreshEnabled = false;
      await tester.pumpWidget(refresh(header: header));
      header.beginRefreshing();
      expect(calls, 0);
      header.beginRefreshing(force: true);
      expect(calls, 1);
      header.endRefreshing();
      await settle(tester);
      header.dispose();
    });

    testWidgets('refreshOnStart refreshes after the first frame', (tester) async {
      var calls = 0;
      final header = plainHeader(onRefresh: () => calls++);
      await tester.pumpWidget(refresh(header: header, refreshOnStart: true));
      await tester.pump();
      expect(calls, 1);
      header.endRefreshing();
      await settle(tester);
      header.dispose();
    });

    testWidgets('refreshOnStartHeader does the first refresh, then the regular header takes over', (tester) async {
      var startCalls = 0;
      var calls = 0;
      final start = plainHeader(onRefresh: () => startCalls++);
      final header = plainHeader(onRefresh: () => calls++);
      await tester.pumpWidget(refresh(header: header, startHeader: start, refreshOnStart: true));
      await tester.pump();
      expect(startCalls, 1);
      expect(calls, 0);
      start.endRefreshing();
      await settle(tester);
      expect(header.attached, isTrue);
      expect(start.attached, isFalse);
      await pullDown(tester, 300);
      await frames(tester, 300);
      expect(calls, 1);
      header.endRefreshing();
      await settle(tester);
      start.dispose();
      header.dispose();
    });
  });

  group('CYLRefresh footer: pull up, load, no more data, reset', () {
    testWidgets('a pull up loads; endRefreshingWithNoMoreData keeps the footer; the header resets it', (tester) async {
      var loads = 0;
      var refreshes = 0;
      final footer = plainFooter(onLoad: () => loads++);
      final header = plainHeader(onRefresh: () => refreshes++)..resetsFooterAfterRefresh = true;
      await tester.pumpWidget(refresh(header: header, footer: footer));
      await pullUp(tester, 300);
      await frames(tester, 300);
      expect(loads, 1);
      expect(footer.phase, CYLRefreshPhase.refreshing);
      footer.endRefreshingWithNoMoreData();
      await settle(tester);
      expect(footer.isNoMoreData, isTrue);
      expect(find.byKey(const ValueKey('footer')), findsOneWidget);
      await pullUp(tester, 300);
      await frames(tester, 300);
      expect(loads, 1, reason: 'no more data: no load');
      tester.state<ScrollableState>(find.byType(Scrollable).first).position.jumpTo(0);
      await tester.pump();
      await pullDown(tester, 600);
      await frames(tester, 300);
      expect(refreshes, 1);
      header.endRefreshing();
      await settle(tester);
      expect(footer.isNoMoreData, isFalse);
      header.dispose();
      footer.dispose();
    });

    testWidgets('exclusiveWithOtherRefresh: the footer does not load during a refresh; false allows both', (tester) async {
      var loads = 0;
      final footer = plainFooter(onLoad: () => loads++);
      final header = plainHeader();
      await tester.pumpWidget(refresh(header: header, footer: footer));
      header.beginRefreshing();
      footer.beginRefreshing();
      expect(loads, 0);
      header.endRefreshing();
      await settle(tester);
      header.dispose();
      footer.dispose();

      final footer2 = plainFooter(onLoad: () => loads++);
      final header2 = plainHeader();
      await tester.pumpWidget(refresh(header: header2, footer: footer2, exclusive: false));
      header2.beginRefreshing();
      footer2.beginRefreshing();
      expect(loads, 1);
      header2.endRefreshing();
      footer2.endRefreshing();
      await settle(tester);
      header2.dispose();
      footer2.dispose();
    });
  });

  group('CYLRefreshAutoFooter: loads by itself at the end (autoTriggerTimes, percent)', () {
    testWidgets('scrolling to the end loads once; autoTriggerTimes limits repeats', (tester) async {
      var loads = 0;
      final footer = CYLRefreshAutoFooter(refreshingHandler: () => loads++, builder: (_, _) => const SizedBox(), finishDuration: Duration.zero);
      await tester.pumpWidget(refresh(header: null, footer: footer));
      jumpToEnd(tester);
      await tester.pump();
      expect(loads, 1);
      footer.endRefreshing();
      await frames(tester, 600);
      jumpToEnd(tester, 200);
      await tester.pump();
      jumpToEnd(tester);
      await tester.pump();
      expect(loads, 1, reason: 'autoTriggerTimes = 1 until a pull');
      footer.autoTriggerTimes = 0;
      jumpToEnd(tester, 200);
      await tester.pump();
      jumpToEnd(tester);
      await tester.pump();
      expect(loads, 2);
      footer.endRefreshing();
      await settle(tester);
      footer.dispose();
    });

    testWidgets('automaticallyRefresh = false never loads by itself', (tester) async {
      var loads = 0;
      final footer = CYLRefreshAutoFooter(refreshingHandler: () => loads++, automaticallyRefresh: false, builder: (_, _) => const SizedBox());
      await tester.pumpWidget(refresh(footer: footer));
      jumpToEnd(tester);
      await tester.pump();
      expect(loads, 0);
      footer.dispose();
    });
  });

  group('scroll modes, physics parameters and layout options', () {
    double firstRowTop(WidgetTester tester) => tester.getTopLeft(find.text('Item 0')).dy - tester.getTopLeft(find.byType(CYLRefresh)).dy;

    testWidgets('front: the content does not move while the header floats over it', (tester) async {
      final header = plainHeader()..scrollMode = CYLRefreshScrollMode.front;
      await tester.pumpWidget(refresh(header: header));
      header.beginRefreshing();
      await frames(tester, 500);
      expect(firstRowTop(tester), closeTo(0, 1));
      expect(tester.getTopLeft(find.byKey(const ValueKey('header'))).dy - tester.getTopLeft(find.byType(CYLRefresh)).dy, closeTo(0, 1));
      header.endRefreshing();
      await settle(tester);
      header.dispose();
    });

    testWidgets('behind: the content moves away and the header stays at the top', (tester) async {
      final header = plainHeader()..scrollMode = CYLRefreshScrollMode.behind;
      await tester.pumpWidget(refresh(header: header));
      header.beginRefreshing();
      await frames(tester, 500);
      expect(firstRowTop(tester), closeTo(header.expandHeight, 1));
      expect(tester.getTopLeft(find.byKey(const ValueKey('header'))).dy - tester.getTopLeft(find.byType(CYLRefresh)).dy, closeTo(0, 1));
      header.endRefreshing();
      await settle(tester);
      header.dispose();
    });

    testWidgets('maxPullDistance limits the pull', (tester) async {
      final header = plainHeader()..maxPullDistance = 50;
      await tester.pumpWidget(refresh(header: header));
      final gesture = await pullDown(tester, 600, release: false);
      expect(header.dragOffset, lessThan(70));
      await gesture.up();
      await settle(tester);
      header.endRefreshing();
      await settle(tester);
      header.dispose();
    });

    testWidgets('frictionFactor changes how far a pull goes', (tester) async {
      final header = plainHeader();
      await tester.pumpWidget(host(CYLRefresh(header: header, frictionFactor: (_) => 0.1, child: list())));
      final gesture = await pullDown(tester, 300, release: false);
      final slow = header.dragOffset;
      await gesture.up();
      await settle(tester);
      header.dispose();
      final header2 = plainHeader();
      await tester.pumpWidget(host(CYLRefresh(header: header2, child: list())));
      final gesture2 = await pullDown(tester, 300, release: false);
      expect(slow, lessThan(header2.dragOffset));
      await gesture2.up();
      await settle(tester);
      header2.endRefreshing();
      await settle(tester);
      header2.dispose();
    });

    testWidgets('childBuilder gets the physics; scrollBehaviorBuilder and fit and clipBehavior are passed on', (tester) async {
      final header = plainHeader();
      ScrollPhysics? seen;
      await tester.pumpWidget(host(CYLRefresh(
        header: header,
        clipBehavior: Clip.none,
        fit: StackFit.loose,
        child: const SizedBox(),
        childBuilder: (context, physics) {
          seen = physics;
          return ListView(physics: physics, children: const [Text('built')]);
        },
      )));
      expect(seen, isA<CYLRefreshPhysics>());
      expect(find.text('built'), findsOneWidget);
      expect(tester.widget<ClipRect>(find.byType(ClipRect).first).clipBehavior, Clip.none);
      var builderCalled = false;
      await tester.pumpWidget(host(CYLRefresh(
        header: header,
        scrollBehaviorBuilder: (behavior) {
          builderCalled = true;
          return behavior;
        },
        child: list(),
      )));
      expect(builderCalled, isTrue);
      header.dispose();
    });

    testWidgets('safeArea keeps the indicator out of the status bar', (tester) async {
      final header = CYLRefreshHeader(builder: (_, _) => const SizedBox(key: ValueKey('body'), height: 10, width: 10));
      await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(400, 600), padding: EdgeInsets.only(top: 44)),
          child: CYLRefresh(header: header, safeArea: true, child: list()),
        ),
      ));
      header.beginRefreshing();
      await frames(tester, 500);
      expect(tester.getTopLeft(find.byKey(const ValueKey('body'))).dy, greaterThanOrEqualTo(44));
      header.endRefreshing();
      await settle(tester);
      header.dispose();
    });
  });
}
