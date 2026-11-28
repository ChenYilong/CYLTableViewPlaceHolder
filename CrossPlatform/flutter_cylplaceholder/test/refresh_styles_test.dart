import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/material.dart';
import 'package:flutter_cylplaceholder/flutter_cylplaceholder.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  group('classic header and footer: texts, last updated, icons, builders', () {
    testWidgets('setTitle and the per-state texts; the default texts follow the phase', (tester) async {
      final header = CYLRefreshClassicHeader(finishDuration: const Duration(milliseconds: 100));
      expect(header.titleForState(CYLRefreshTitleState.pullToRefresh), 'Pull down to refresh');
      header.setTitle('Drag me', CYLRefreshTitleState.pullToRefresh);
      header.setTitle('Done!', CYLRefreshTitleState.succeeded);
      header.setTitle('Oops', CYLRefreshTitleState.failed);
      await tester.pumpWidget(refresh(header: header));
      final gesture = await pullDown(tester, 200, release: false);
      await tester.pump();
      expect(find.text('Drag me'), findsNothing, reason: 'armed by now');
      expect(find.text('Release to refresh'), findsOneWidget);
      await gesture.up();
      await frames(tester, 300);
      expect(find.text('Refreshing...'), findsOneWidget);
      header.endRefreshing(success: false);
      await tester.pump();
      expect(find.text('Oops'), findsOneWidget);
      await settle(tester);
      header.dispose();
    });

    testWidgets('the last update time: default text, formatter and builder', (tester) async {
      final header = CYLRefreshClassicHeader(finishDuration: const Duration(milliseconds: 10));
      await tester.pumpWidget(refresh(header: header));
      header.beginRefreshing(duration: Duration.zero, overOffset: 0);
      await frames(tester, 100);
      expect(find.text('Not updated yet'), findsOneWidget);
      header.endRefreshing();
      await settle(tester);
      expect(header.lastUpdatedTime, isNotNull);
      expect(header.messageText(), startsWith('Last updated: '));
      header.lastUpdatedTimeFormatter = (time) => 'at ${time.year}';
      expect(header.messageText(), 'at ${header.lastUpdatedTime!.year}');
      header.lastUpdatedTimeText = (time) => time == null ? 'never' : 'custom';
      expect(header.messageText(), 'custom');
      header.showsLastUpdatedTime = false;
      expect(header.messageText(), isNull);
      header.dispose();
    });

    testWidgets('icons and builders: succeededImage, iconOnTrailingSide, iconSize, textBuilder, messageBuilder', (tester) async {
      final header = CYLRefreshClassicHeader(finishDuration: const Duration(seconds: 5))
        ..succeededImage = const SizedBox(key: ValueKey('ok'), width: 7, height: 7)
        ..iconOnTrailingSide = true
        ..iconSize = 30
        ..iconSpacing = 20
        ..textBuilder = ((context, component, text) => Text('T:$text', key: const ValueKey('title')))
        ..messageBuilder = ((context, component, text) => Text('M:$text', key: const ValueKey('message')));
      await tester.pumpWidget(refresh(header: header));
      header.beginRefreshing(duration: Duration.zero, overOffset: 0);
      await frames(tester, 100);
      expect(find.byKey(const ValueKey('title')), findsOneWidget);
      expect(find.textContaining('M:'), findsOneWidget);
      header.endRefreshing();
      await frames(tester, 100);
      expect(find.byKey(const ValueKey('ok')), findsOneWidget);
      final okRight = tester.getTopLeft(find.byKey(const ValueKey('ok'))).dx;
      expect(okRight, greaterThan(tester.getTopLeft(find.byKey(const ValueKey('title'))).dx), reason: 'icon on the trailing side');
      await frames(tester, 5100);
      header.dispose();
    });

    testWidgets('pullIconBuilder replaces the arrow', (tester) async {
      final header = CYLRefreshClassicHeader()..pullIconBuilder = ((context, component) => const SizedBox(key: ValueKey('arrow'), width: 9, height: 9));
      await tester.pumpWidget(refresh(header: header));
      final gesture = await pullDown(tester, 120, release: false);
      expect(find.byKey(const ValueKey('arrow')), findsOneWidget);
      await gesture.up();
      await settle(tester);
      header.dispose();
    });

    testWidgets('the classic footer shows its no-more-data text and noMoreDataImage', (tester) async {
      final footer = CYLRefreshClassicFooter(finishDuration: Duration.zero)..noMoreDataImage = const SizedBox(key: ValueKey('end'), width: 5, height: 5);
      await tester.pumpWidget(refresh(footer: footer));
      footer.beginRefreshing(duration: Duration.zero, overOffset: 0);
      await frames(tester, 100);
      expect(find.text('Loading...'), findsOneWidget);
      footer.endRefreshingWithNoMoreData();
      await frames(tester, 300);
      expect(find.text('No more data'), findsOneWidget);
      expect(find.byKey(const ValueKey('end')), findsOneWidget);
      footer.dispose();
    });

    testWidgets('CYLRefreshClassicAutoFooter loads at the end by itself', (tester) async {
      var loads = 0;
      final footer = CYLRefreshClassicAutoFooter(refreshingHandler: () => loads++);
      await tester.pumpWidget(refresh(footer: footer));
      jumpToEnd(tester);
      await tester.pump();
      expect(loads, 1);
      footer.endRefreshing();
      await settle(tester);
      footer.dispose();
    });
  });

  group('styles: Cupertino and Material', () {
    testWidgets('the Cupertino header and footer draw an activity indicator', (tester) async {
      final header = CYLRefreshCupertinoHeader();
      final footer = CYLRefreshCupertinoFooter();
      await tester.pumpWidget(refresh(header: header, footer: footer));
      header.beginRefreshing(duration: Duration.zero, overOffset: 0);
      await frames(tester, 100);
      expect(find.byType(CupertinoActivityIndicator), findsWidgets);
      header.endRefreshing();
      await settle(tester);
      header.dispose();
      footer.dispose();
    });

    testWidgets('the Material header and footer draw a circular progress indicator', (tester) async {
      final header = CYLRefreshMaterialHeader(colorPrimary: Colors.red);
      final footer = CYLRefreshMaterialFooter();
      await tester.pumpWidget(refresh(header: header, footer: footer));
      header.beginRefreshing(duration: Duration.zero, overOffset: 0);
      await frames(tester, 100);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      header.endRefreshing();
      await settle(tester);
      header.dispose();
      footer.dispose();
    });
  });

  group('ListenerHeader / ListenerFooter: no drawing, observers only', () {
    testWidgets('a listener header draws nothing and still reports the pull', (tester) async {
      final seen = <double>[];
      final header = CYLRefreshListenerHeader()..addListener(() {});
      header.addPhaseObserver((component, phase, old) => seen.add(component.pullingPercent));
      await tester.pumpWidget(refresh(header: header));
      await pullDown(tester, 200, release: false);
      expect(seen, isNotEmpty);
      expect(header.buildIndicator(tester.element(find.byType(CYLRefresh))), isA<SizedBox>());
      await tester.pumpAndSettle();
      header.dispose();
    });

    test('a listener footer is a footer without drawing', () {
      final footer = CYLRefreshListenerFooter();
      expect(footer.isHeader, isFalse);
      footer.dispose();
    });
  });
}
