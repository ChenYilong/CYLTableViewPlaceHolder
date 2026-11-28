import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cylplaceholder_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> frames(WidgetTester tester, int ms) async {
  for (var t = 0; t < ms; t += 16) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

Future<void> open(WidgetTester tester, String title) async {
  await tester.pumpWidget(const ExampleApp());
  await tester.scrollUntilVisible(find.byKey(ValueKey(title)), 200, scrollable: find.byType(Scrollable).first);
  await tester.ensureVisible(find.byKey(ValueKey(title)));
  await tester.pump();
  await tester.tap(find.byKey(ValueKey(title)));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> pullDown(WidgetTester tester, [double dy = 350]) async {
  final gesture = await tester.startGesture(const Offset(400, 200));
  for (var i = 0; i < 10; i++) {
    await gesture.moveBy(Offset(0, dy / 10));
    await tester.pump(const Duration(milliseconds: 16));
  }
  await gesture.up();
  await tester.pump();
}

ScrollPosition position(WidgetTester tester) => tester.state<ScrollableState>(find.byType(Scrollable).first).position;

Future<void> pullUp(WidgetTester tester, [double dy = 350]) async {
  position(tester).jumpTo(position(tester).maxScrollExtent);
  await tester.pump();
  final gesture = await tester.startGesture(const Offset(400, 400));
  for (var i = 0; i < 10; i++) {
    await gesture.moveBy(Offset(0, -dy / 10));
    await tester.pump(const Duration(milliseconds: 16));
  }
  await gesture.up();
  await tester.pump();
}

void main() {
  testWidgets('the home page lists the ported pages', (tester) async {
    await tester.pumpWidget(const ExampleApp());
    final titles = ['Cupertino style', 'Rive styles', 'Refresh on start', 'Trigger mode', 'Listener header', 'Chat', 'User profile', 'Theme switch', 'Carousel', 'Page view', 'Tab bar view', 'Nested scrolling', 'Centre indicator'];
    for (final title in titles) {
      await tester.scrollUntilVisible(find.byKey(ValueKey(title)), 200, scrollable: find.byType(Scrollable).first);
      expect(find.byKey(ValueKey(title)), findsOneWidget, reason: title);
    }
  });

  testWidgets('Cupertino style: refresh keeps 10 rows, a load adds 5, no more data at 20', (tester) async {
    await open(tester, 'Cupertino style');
    expect(find.text('Test data 10'), findsOneWidget);
    await pullUp(tester);
    await frames(tester, 3200);
    position(tester).jumpTo(position(tester).maxScrollExtent);
    await tester.pump();
    expect(find.text('Test data 15'), findsOneWidget);
    await pullUp(tester);
    await frames(tester, 3200);
    position(tester).jumpTo(position(tester).maxScrollExtent);
    await frames(tester, 800);
    expect(find.text('Test data 20'), findsOneWidget);
    expect(find.text('No more data'), findsOneWidget);
    position(tester).jumpTo(0);
    await tester.pump();
    await pullDown(tester);
    await frames(tester, 2800);
    expect(find.text('Test data 11'), findsNothing, reason: 'a refresh goes back to 10 rows');
  });

  testWidgets('Trigger mode: the rows switch the header and the footer between anywhere and edge only', (tester) async {
    await open(tester, 'Trigger mode');
    expect(find.text('Header: anywhere'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('header-mode')));
    await tester.pump();
    expect(find.text('Header: edge only'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('footer-mode')));
    await tester.pump();
    expect(find.text('Footer: edge only'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('header-mode')));
    await tester.pump();
    await pullDown(tester);
    await frames(tester, 2500);
    expect(find.text('Refresh count: 1'), findsOneWidget);
  });

  testWidgets('Refresh on start: the first refresh runs by itself, then the regular header takes over', (tester) async {
    await open(tester, 'Refresh on start');
    await frames(tester, 2600);
    await pullDown(tester);
    await frames(tester, 300);
    expect(find.text('Refreshing...'), findsOneWidget, reason: 'the classic header after the first refresh');
    await frames(tester, 2400);
  });

  testWidgets('Listener header: the progress bar follows the pull', (tester) async {
    await open(tester, 'Listener header');
    final gesture = await tester.startGesture(const Offset(400, 200));
    for (var i = 0; i < 6; i++) {
      await gesture.moveBy(const Offset(0, 25));
      await tester.pump(const Duration(milliseconds: 16));
    }
    final bar = tester.widget<LinearProgressIndicator>(find.byKey(const ValueKey('pull-progress')));
    expect(bar.value, allOf(greaterThan(0), lessThanOrEqualTo(1)));
    await gesture.up();
    await frames(tester, 2800);
  });

  testWidgets('Chat: a pull loads five earlier messages at the top', (tester) async {
    await open(tester, 'Chat');
    expect(find.text('Message 1'), findsOneWidget);
    await pullDown(tester);
    await frames(tester, 2800);
    expect(find.text('Earlier message -5'), findsOneWidget);
  });

  testWidgets('User profile: the header stays behind the content', (tester) async {
    await open(tester, 'User profile');
    await pullDown(tester);
    await frames(tester, 600);
    expect(find.text('Refreshing...'), findsOneWidget);
    await frames(tester, 2600);
  });

  testWidgets('Theme switch: a row recolors the header', (tester) async {
    await open(tester, 'Theme switch');
    await tester.tap(find.byKey(const ValueKey('theme-Orange')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('theme-Default')));
    await tester.pump();
    expect(find.text('Tap to restore'), findsOneWidget);
  });

  for (final (title, second) in [('Carousel', 'Page 2'), ('Page view', 'Page 2'), ('Tab bar view', 'Page 2')]) {
    testWidgets('$title: each page has its own header', (tester) async {
      await open(tester, title);
      expect(find.text('Page 1, row 1'), findsOneWidget);
      if (title == 'Tab bar view') {
        await tester.tap(find.text('Two'));
      } else {
        await tester.fling(find.byType(PageView), const Offset(-500, 0), 2000);
      }
      await frames(tester, 800);
      expect(find.text('$second, row 1'), findsOneWidget);
      await pullDown(tester);
      await frames(tester, 400);
      expect(find.text('Refreshing...'), findsOneWidget);
      await frames(tester, 2600);
    });
  }

  testWidgets('Nested scrolling: the footer of the inner list loads five more rows', (tester) async {
    await open(tester, 'Nested scrolling');
    expect(find.text('Test data 1'), findsOneWidget);
    expect(find.text('Header area (outer scroll)'), findsOneWidget);
  });

  testWidgets('Centre indicator: the placeholder is tapped, the list appears', (tester) async {
    await open(tester, 'Centre indicator');
    expect(find.byKey(const ValueKey('emptyPlaceholder')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('emptyPlaceholder')));
    await frames(tester, 2800);
    expect(find.text('Test data 1'), findsOneWidget);
  });

  testWidgets('Rive styles: six pages, each with its header', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
    try {
      await open(tester, 'Rive styles');
      for (final name in ['Bow', 'Bubbles', 'Halloween', 'Skating', 'Space', 'Squats']) {
        expect(find.byKey(ValueKey('rive-$name')), findsOneWidget, reason: name);
      }
      await tester.tap(find.byKey(const ValueKey('rive-Space')));
      await tester.pump();
      await frames(tester, 600);
      for (var i = 0; i < 10 && find.text('Test data 1').evaluate().isEmpty; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
        await frames(tester, 100);
      }
      expect(find.text('Test data 1'), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
