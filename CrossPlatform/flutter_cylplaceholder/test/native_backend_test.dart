import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cylplaceholder/flutter_cylplaceholder.dart';
import 'package:flutter_test/flutter_test.dart';

/// The contract of the Android half, tested on the Dart side with a mock method channel: the calls this package sends to the
/// native HUD, the creation parameters of the native placeholder view, and what comes back. The native behavior behind them
/// is tested by the Android Robolectric tests (`CYLPlaceholderBridgeTest`).
void main() {
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    CYLPlaceholderNative.override = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(CYLPlaceholderNative.hudChannel, (call) async {
      calls.add(call);
      return null;
    });
  });

  tearDown(() {
    CYLPlaceholderNative.override = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(CYLPlaceholderNative.hudChannel, null);
  });

  test('the native half is off in flutter test unless it is forced', () {
    CYLPlaceholderNative.override = null;
    expect(CYLPlaceholderNative.enabled, isFalse);
    CYLPlaceholderNative.override = true;
    expect(CYLPlaceholderNative.enabled, isTrue);
  });

  group('the HUD calls the native HUD by name', () {
    test('show, status, progress, timed messages and dismiss', () {
      final hud = CYLPlaceholderHUD();
      hud
        ..showWithStatus('Please wait')
        ..setStatus('Almost')
        ..showProgress(0.4, 'Uploading')
        ..showInfoWithStatus('Info')
        ..showSuccessWithStatus('Done')
        ..showErrorWithStatus('Oops')
        ..popActivity()
        ..dismissWithDelay(1.5);
      expect(calls.map((c) => c.method), [
        'showWithStatus', 'setStatus', 'showProgress', 'showInfoWithStatus', 'showSuccessWithStatus', 'showErrorWithStatus', 'popActivity', 'dismissWithDelay',
      ]);
      expect(calls[0].arguments, {'status': 'Please wait'});
      expect(calls[2].arguments, {'progress': 0.4, 'status': 'Uploading'});
      expect(calls.last.arguments, {'delay': 1.5});
      hud.dispose();
    });

    test('the Dart state stays in step, so visible, state and status mean the same with either half', () {
      final hud = CYLPlaceholderHUD();
      hud.showWithStatus('Loading');
      expect(hud.visible, isTrue);
      expect(hud.state, CYLPlaceholderHUDState.loading);
      expect(hud.status, 'Loading');
      hud.dispose();
    });

    test('showComponents sends the component maps with action names, and a native tap calls the Dart action', () async {
      final hud = CYLPlaceholderHUD();
      var retries = 0;
      hud.showComponents([
        CYLPlaceholderComponent.hint('Offline'),
        CYLPlaceholderComponent.button('Retry', action: () => retries++),
      ]);
      final sent = calls.single;
      expect(sent.method, 'showComponents');
      final components = (sent.arguments as Map)['components'] as List;
      expect(components[0], containsPair('type', 'hint'));
      expect(components[1], allOf(containsPair('type', 'button'), containsPair('title', 'Retry'), containsPair('action', 'component-1')));
      expect(components[0].containsKey('action'), isFalse, reason: 'a component without an action sends none');
      // The native HUD reports the tapped action by name.
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
        CYLPlaceholderNative.hudChannel.name,
        const StandardMethodCodec().encodeMethodCall(const MethodCall('onAction', 'component-1')),
        (_) {},
      );
      expect(retries, 1);
      hud.dispose();
    });

    testWidgets('the host draws nothing of its own: the native HUD draws over the activity', (tester) async {
      final hud = CYLPlaceholderHUD();
      await tester.pumpWidget(MaterialApp(home: CYLPlaceholderHUDHost(hud: hud, child: const Text('content'))));
      hud.showWithStatus('Please wait');
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('content'), findsOneWidget);
      expect(find.text('Please wait'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      hud.dispose();
    });
  });

  group('the native placeholder view', () {
    test('its creation parameters are the item map plus the loop, speed and tap flags', () {
      const view = CYLNativePlaceholderView(
        params: {'CYLTabBarItemTitle': 'Offline', 'CYLPlaceholderItemStyle': 'wifiOff'},
        animationLoops: true,
        animationSpeed: 2,
      );
      expect(view.creationParams, {
        'CYLTabBarItemTitle': 'Offline',
        'CYLPlaceholderItemStyle': 'wifiOff',
        'animationLoops': true,
        'animationSpeed': 2.0,
        'tappable': false,
      });
    });

    testWidgets('CYLPlaceholderView builds an AndroidView with the item map when the native half is on', (tester) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform_views, (call) async => call.method == 'create' ? 1 : null);
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform_views, null));
      await tester.pumpWidget(MaterialApp(
        home: SizedBox(
          width: 300,
          height: 300,
          child: CYLPlaceholderView(style: CYLPlaceholderStyle.cloudOff, title: 'Offline', message: 'Try again', animationLoops: true, animationSpeed: 1.5, tapHandler: () {}),
        ),
      ));
      final android = tester.widget<AndroidView>(find.byType(AndroidView));
      expect(android.viewType, CYLPlaceholderNative.viewType);
      final params = android.creationParams as Map<String, Object?>;
      expect(params[CYLPlaceholderItemKey.title], 'Offline');
      expect(params[CYLPlaceholderItemKey.style], 'cloudOff');
      expect(params['animationLoops'], true);
      expect(params['animationSpeed'], 1.5);
      expect(params['tappable'], true);
    });

    testWidgets('a Flutter image or title style keeps the Dart widget, which can draw them', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CYLPlaceholderView(image: SizedBox(key: ValueKey('mine'), width: 10, height: 10))));
      expect(find.byType(AndroidView), findsNothing);
      expect(find.byKey(const ValueKey('mine')), findsOneWidget);
    });
  });
}
