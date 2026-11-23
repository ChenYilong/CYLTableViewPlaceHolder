import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cylplaceholder/flutter_cylplaceholder.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child) => MaterialApp(home: Scaffold(body: child));

/// A widget test on a platform that has no native animation view, so `CYLAnimationView` builds its placeholder.
void testStack(String name, Future<void> Function(WidgetTester tester) body) {
  testWidgets(name, (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
    try {
      await body(tester);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}

void main() {
  group('CYLPlaceholderStackView: components in order, spacing, buttons, separators', () {
    testStack('draws every kind from top to bottom with the default spacing', (tester) async {
      await tester.pumpWidget(_app(CYLPlaceholderStackView(components: [
        CYLPlaceholderComponent.icon(style: CYLPlaceholderStyle.cloudOff, title: 'Offline'),
        CYLPlaceholderComponent.hint('Check your connection'),
        CYLPlaceholderComponent.button('Retry'),
        CYLPlaceholderComponent.separator('or'),
      ])));
      expect(find.text('Offline'), findsOneWidget);
      final offline = tester.getTopLeft(find.text('Offline')).dy;
      final hint = tester.getTopLeft(find.text('Check your connection')).dy;
      final button = tester.getTopLeft(find.byType(FilledButton)).dy;
      final separator = tester.getTopLeft(find.text('or')).dy;
      expect(offline < hint && hint < button && button < separator, isTrue);
      expect(CYLPlaceholderComponent.hint('x').spacingBefore, 4);
      expect(CYLPlaceholderComponent.button('x').spacingBefore, 20);
      expect(CYLPlaceholderComponent.separator('x').spacingBefore, 14);
      expect(CYLPlaceholderComponent.icon().spacingBefore, 12);
    });

    testStack('a button runs its action, unless the component is not interactive; styles pick the widget', (tester) async {
      var taps = 0;
      final enabled = CYLPlaceholderComponent.button('Go', action: () => taps++);
      await tester.pumpWidget(_app(CYLPlaceholderStackView(components: [enabled])));
      await tester.tap(find.text('Go'));
      expect(taps, 1);
      enabled.interactionEnabled = false;
      await tester.pumpWidget(_app(CYLPlaceholderStackView(components: [enabled])));
      await tester.tap(find.text('Go'));
      expect(taps, 1);
      await tester.pumpWidget(_app(CYLPlaceholderStackView(components: [CYLPlaceholderComponent.button('A', style: CYLPlaceholderButtonStyle.outlined)])));
      expect(find.byType(OutlinedButton), findsOneWidget);
      await tester.pumpWidget(_app(CYLPlaceholderStackView(components: [CYLPlaceholderComponent.button('B', style: CYLPlaceholderButtonStyle.capsule)])));
      expect(tester.widget<FilledButton>(find.byType(FilledButton)).style?.shape?.resolve({}), isA<StadiumBorder>());
    });

    testStack('backgroundAction runs when the empty space is tapped', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_app(CYLPlaceholderStackView(components: [CYLPlaceholderComponent.hint('x')], backgroundAction: () => taps++)));
      await tester.tapAt(const Offset(5, 5));
      expect(taps, 1);
    });

    testStack('the accessibility identifier is on the component', (tester) async {
      await tester.pumpWidget(_app(CYLPlaceholderStackView(components: [
        CYLPlaceholderComponent.hint('x')..accessibilityIdentifier = 'hint-1',
      ])));
      expect(find.bySemanticsIdentifier('hint-1'), findsOneWidget);
    });
  });

  group('animations: animationLoops, animationSpeed and restartAnimation()', () {
    testStack('a component hands loops and speed to upstream CYLAnimationView', (tester) async {
      await tester.pumpWidget(_app(CYLPlaceholderStackView(components: [
        CYLPlaceholderComponent.icon(animationFile: 'a.riv', animationLoops: true, animationSpeed: 2),
      ])));
      final view = tester.widget<CYLAnimationView>(find.byType(CYLAnimationView));
      expect(view.animationLoops, isTrue);
      expect(view.animationSpeed, 2);
      expect(view.animationRestartToken, 0);
    });

    testStack('restartAnimation() grows the restart token of every animation', (tester) async {
      final controller = CYLPlaceholderStackController();
      await tester.pumpWidget(_app(CYLPlaceholderStackView(controller: controller, components: [
        CYLPlaceholderComponent.icon(animationFile: 'a.riv'),
        CYLPlaceholderComponent.icon(animationFile: 'b.riv'),
      ])));
      expect(tester.widgetList<CYLAnimationView>(find.byType(CYLAnimationView)).map((v) => v.animationRestartToken), [0, 0]);
      controller.restartAnimation();
      await tester.pump();
      expect(tester.widgetList<CYLAnimationView>(find.byType(CYLAnimationView)).map((v) => v.animationRestartToken), [1, 1]);
      controller.restartAnimation();
      await tester.pump();
      expect(controller.animationRestartToken, 2);
    });

    testStack('CYLPlaceholderView passes loops, speed and token on', (tester) async {
      await tester.pumpWidget(_app(const CYLPlaceholderView(animationFile: 'a.riv', animationLoops: true, animationSpeed: 0.5, animationRestartToken: 3)));
      final view = tester.widget<CYLAnimationView>(find.byType(CYLAnimationView));
      expect((view.animationLoops, view.animationSpeed, view.animationRestartToken), (true, 0.5, 3));
    });
  });
}
