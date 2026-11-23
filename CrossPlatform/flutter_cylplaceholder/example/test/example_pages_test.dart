import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cylplaceholder/flutter_cylplaceholder.dart';
import 'package:flutter_cylplaceholder_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps in frames of 16 ms, so the animations of the refresh view run.
Future<void> frames(WidgetTester tester, int ms) async {
  for (var t = 0; t < ms; t += 16) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

Future<void> open(WidgetTester tester, String title) async {
  await tester.pumpWidget(const ExampleApp());
  await tester.tap(find.byKey(ValueKey(title)));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the home page lists every example page', (tester) async {
    await tester.pumpWidget(const ExampleApp());
    for (final title in ['Refresh', 'Paging', 'Refresh styles', 'Second floor', 'Error placeholder', 'Placeholder stack and HUD']) {
      expect(find.byKey(ValueKey(title)), findsOneWidget, reason: title);
    }
  });

  testWidgets('Refresh styles: every style can be chosen and draws its header', (tester) async {
    await open(tester, 'Refresh styles');
    for (final name in ['Classic', 'Cupertino', 'Material', 'Bezier radar', 'Bezier circle', 'Delivery', 'Phoenix', 'Taurus']) {
      await tester.ensureVisible(find.byKey(ValueKey('style-$name')));
      await tester.tap(find.byKey(ValueKey('style-$name')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Row 1'), findsOneWidget, reason: name);
    }
  });

  testWidgets('Second floor: open and close from the buttons', (tester) async {
    await open(tester, 'Second floor');
    await tester.tap(find.byKey(const ValueKey('open-second-floor')));
    await frames(tester, 600);
    expect(find.text('Second floor opened'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('close-second-floor')));
    await frames(tester, 600);
    expect(find.text('Second floor closed'), findsOneWidget);
  });

  testWidgets('Placeholder stack and HUD: Play all, the speed slider and the loop switch apply live', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
    try {
      await open(tester, 'Placeholder stack and HUD');
      CYLAnimationView view() => tester.widget<CYLAnimationView>(find.byType(CYLAnimationView));
      expect((view().animationLoops, view().animationSpeed, view().animationRestartToken), (false, 1.0, 0));
      await tester.tap(find.byKey(const ValueKey('play-all')));
      await tester.pump();
      expect(view().animationRestartToken, 1);
      await tester.tap(find.byKey(const ValueKey('loop')));
      await tester.pump();
      expect(view().animationLoops, isTrue);
      await tester.drag(find.byKey(const ValueKey('speed')), const Offset(400, 0));
      await tester.pump();
      expect(view().animationSpeed, 2.0);
      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Loaded'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
