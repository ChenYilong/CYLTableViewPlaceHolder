import 'package:flutter/material.dart';
import 'package:flutter_cylplaceholder/flutter_cylplaceholder.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(CYLPlaceholderHUD hud, {VoidCallback? onTap}) => MaterialApp(
      home: Scaffold(
        body: CYLPlaceholderHUDHost(
          hud: hud,
          child: Align(alignment: Alignment.topCenter, child: ElevatedButton(onPressed: onTap ?? () {}, child: const Text('below'))),
        ),
      ),
    );

void main() {
  group('CYLPlaceholderHUD model', () {
    test('show / showWithStatus count activities; popActivity hides after the last one', () async {
      final hud = CYLPlaceholderHUD();
      hud.show();
      hud.showWithStatus('Loading');
      expect(hud.state, CYLPlaceholderHUDState.loading);
      expect(hud.status, 'Loading');
      expect(hud.activityCount, 2);
      hud.popActivity();
      expect(hud.visible, isTrue);
      hud.popActivity();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(hud.visible, isFalse);
      hud.dispose();
    });

    test('showProgress clamps to 0...1 and keeps the status; setStatus changes it in place', () {
      final hud = CYLPlaceholderHUD();
      hud.showProgress(1.7, 'Uploading');
      expect(hud.state, CYLPlaceholderHUDState.progress);
      expect(hud.progress, 1);
      hud.showProgress(-1);
      expect(hud.progress, 0);
      expect(hud.status, 'Uploading');
      hud.setStatus('Almost');
      expect(hud.status, 'Almost');
      hud.dispose();
    });

    test('displayDurationForString follows the text length between the minimum and the maximum', () {
      final hud = CYLPlaceholderHUD();
      expect(hud.displayDurationForString(null), 1.5);
      expect(hud.displayDurationForString('x' * 40), closeTo(2.9, 1e-9));
      expect(hud.displayDurationForString('x' * 400), 5);
      hud.dispose();
    });

    test('graceTimeInterval keeps a short task from ever showing the HUD', () async {
      final hud = CYLPlaceholderHUD()..graceTimeInterval = 0.05;
      hud.show();
      expect(hud.visible, isFalse);
      hud.popActivity();
      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(hud.visible, isFalse);
      hud.show();
      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(hud.visible, isTrue);
      hud.dispose();
    });

    test('a timed HUD hides by itself; dismissWithCompletion calls the completion', () async {
      final hud = CYLPlaceholderHUD()
        ..minimumDismissTimeInterval = 0.05
        ..maximumDismissTimeInterval = 0.05;
      hud.showSuccessWithStatus('Done');
      expect(hud.state, CYLPlaceholderHUDState.success);
      expect(hud.image, isA<Icon>());
      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(hud.visible, isFalse);
      var completed = 0;
      hud.showErrorWithStatus('Oops');
      expect(hud.state, CYLPlaceholderHUDState.error);
      hud.dismissWithCompletion(() => completed++);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(completed, 1);
      expect(hud.visible, isFalse);
      hud.dispose();
    });

    test('a custom image replaces the icon', () {
      final hud = CYLPlaceholderHUD();
      const mine = SizedBox(key: ValueKey('mine'));
      hud.showImage(mine, 'Hi');
      expect(hud.state, CYLPlaceholderHUDState.image);
      expect(hud.image, mine);
      hud.dispose();
    });
  });

  group('CYLPlaceholderHUDHost', () {
    testWidgets('draws the spinner and the status, and is a live accessibility region', (tester) async {
      final semantics = tester.ensureSemantics();
      final hud = CYLPlaceholderHUD();
      await tester.pumpWidget(_host(hud));
      expect(find.byType(CircularProgressIndicator), findsNothing);
      hud.showWithStatus('Please wait');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Please wait'), findsOneWidget);
      expect(find.bySemanticsLabel('Please wait'), findsOneWidget);
      expect(tester.getSemantics(find.bySemanticsLabel('Please wait')).getSemanticsData().flagsCollection.isLiveRegion, isTrue);
      hud.dismiss();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(CircularProgressIndicator), findsNothing);
      hud.dispose();
      semantics.dispose();
    });

    testWidgets('progress draws a bar at the progress', (tester) async {
      final hud = CYLPlaceholderHUD();
      await tester.pumpWidget(_host(hud));
      hud.showProgress(0.4, 'Uploading');
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator)).value, 0.4);
      hud.dismiss();
      await tester.pump(const Duration(milliseconds: 400));
      hud.dispose();
    });

    testWidgets('a mask blocks touches below; maskType none lets them through', (tester) async {
      var taps = 0;
      final hud = CYLPlaceholderHUD();
      await tester.pumpWidget(_host(hud, onTap: () => taps++));
      hud.show();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('below'), warnIfMissed: false);
      expect(taps, 1, reason: 'maskType none: the touch reaches the content');
      hud.maskType = CYLPlaceholderHUDMaskType.black;
      hud.show();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('below'), warnIfMissed: false);
      expect(taps, 1, reason: 'a mask blocks the touch');
      hud.dismiss();
      await tester.pump(const Duration(milliseconds: 400));
      hud.dispose();
    });

    testWidgets('showComponents draws the components of a stack', (tester) async {
      final hud = CYLPlaceholderHUD();
      await tester.pumpWidget(_host(hud));
      hud.showComponents([CYLPlaceholderComponent.hint('Custom hint'), CYLPlaceholderComponent.button('OK')]);
      await tester.pump(const Duration(milliseconds: 300));
      expect(hud.state, CYLPlaceholderHUDState.custom);
      expect(find.text('Custom hint'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
      hud.dismiss();
      await tester.pump(const Duration(milliseconds: 400));
      hud.dispose();
    });
  });
}
