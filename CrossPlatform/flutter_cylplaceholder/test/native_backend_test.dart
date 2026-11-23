import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cylplaceholder/flutter_cylplaceholder.dart';
import 'package:flutter_test/flutter_test.dart';

class _NoOtherRefresh implements CYLRefreshHost {
  @override
  bool isOtherRefreshing(CYLRefreshComponent component) => false;
}

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

  group('the native refresh header', () {
    int? viewId;
    final sent = <MethodCall>[];

    // Records what Dart sends to the native header and lets the test play the native side back.
    Future<void> pumpHeader(WidgetTester tester, CYLRefreshClassicHeader header, {void Function(String, String)? onPhase, VoidCallback? onRefreshing}) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform_views, (call) async {
        if (call.method != 'create') return null;
        viewId = (call.arguments as Map)['id'] as int;
        return viewId;
      });
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox());
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform_views, null);
      });
      sent.clear();
      await tester.pumpWidget(MaterialApp(home: SizedBox(width: 300, height: 60, child: CYLNativeRefreshIndicator(component: header, onPhase: onPhase, onRefreshing: onRefreshing))));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
      // Dart listens on the channel now (for the events); stand in for the native side to record the calls.
      final channel = MethodChannel('${CYLNativeRefreshIndicator.viewType}/$viewId');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
        sent.add(call);
        return null;
      });
    }

    testWidgets('the pull is driven with logical pixels and the finger state, a short release cancels, a long one releases', (tester) async {
      final header = CYLRefreshClassicHeader();
      addTearDown(header.dispose);
      await pumpHeader(tester, header);
      header.handlePull(20, dragging: true);
      header.handlePull(80, dragging: true);
      expect(sent.map((c) => c.method), ['drive', 'drive']);
      expect(sent[0].arguments, {'offset': 20.0, 'dragging': true, 'startedAtEdge': true});
      expect(sent[1].arguments, containsPair('offset', 80.0));
      expect(header.phase, CYLRefreshPhase.releaseToRefresh);
      sent.clear();
      header.handleRelease();
      expect(sent.map((c) => c.method), ['release'], reason: 'an armed release opens the native header once, at the offset it was driven to');
      // A short pull: the finger lifts below the trigger, the native header cancels it.
      final short = CYLRefreshClassicHeader();
      addTearDown(short.dispose);
      await pumpHeader(tester, short);
      short.handlePull(30, dragging: true);
      sent.clear();
      short.handlePull(30, dragging: false);
      short.handleRelease();
      expect(sent.map((c) => c.method), ['drive', 'release']);
      expect(sent[0].arguments, containsPair('dragging', false));
    });

    testWidgets('endRefreshing calls finishRefresh once with the result; a refresh begun without a pull arms the native header first', (tester) async {
      final header = CYLRefreshClassicHeader(finishDuration: const Duration(milliseconds: 10));
      addTearDown(header.dispose);
      await pumpHeader(tester, header);
      header.attach(_NoOtherRefresh());
      header.beginRefreshing(force: true);
      expect(sent.map((c) => c.method), ['drive', 'release']);
      expect(sent[0].arguments, allOf(containsPair('offset', header.triggerOffset), containsPair('dragging', true)));
      sent.clear();
      header.endRefreshing(success: false);
      expect(sent.map((c) => c.method), ['finishRefresh']);
      expect(sent.single.arguments, {'success': false});
      await tester.pump(const Duration(milliseconds: 20));
      expect(header.phase, CYLRefreshPhase.idle);
      expect(sent.map((c) => c.method), ['finishRefresh', 'drive'], reason: 'back to rest: drive 0, not dragging');
    });

    testWidgets('onPhase and onRefreshing come back from the native header', (tester) async {
      final phases = <String>[];
      var refreshing = 0;
      final header = CYLRefreshClassicHeader();
      addTearDown(header.dispose);
      await pumpHeader(tester, header, onPhase: (phase, old) => phases.add('$old>$phase'), onRefreshing: () => refreshing++);
      // The Dart listener replaced the recorder when the view was created; deliver as the native side would.
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(MethodChannel('${CYLNativeRefreshIndicator.viewType}/$viewId'), null);
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
        '${CYLNativeRefreshIndicator.viewType}/$viewId',
        const StandardMethodCodec().encodeMethodCall(const MethodCall('onPhase', {'phase': 'refreshing', 'oldPhase': 'releasing'})),
        (_) {},
      );
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
        '${CYLNativeRefreshIndicator.viewType}/$viewId',
        const StandardMethodCodec().encodeMethodCall(const MethodCall('onRefreshing')),
        (_) {},
      );
      expect(phases, ['releasing>refreshing']);
      expect(refreshing, 1);
    });

    testWidgets('the classic header draws the native indicator when the native half is on, and Dart when a builder asks for it', (tester) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform_views, (call) async => call.method == 'create' ? 1 : null);
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform_views, null));
      final plain = CYLRefreshClassicHeader();
      final custom = CYLRefreshClassicHeader()..textBuilder = (context, component, text) => Text('mine $text');
      addTearDown(plain.dispose);
      addTearDown(custom.dispose);
      await tester.pumpWidget(MaterialApp(home: SizedBox(height: 60, child: Builder(builder: plain.buildIndicator))));
      expect(find.byType(AndroidView), findsOneWidget);
      await tester.pumpWidget(MaterialApp(home: SizedBox(height: 60, child: OverflowBox(maxWidth: 3000, child: Builder(builder: custom.buildIndicator)))));
      expect(find.byType(AndroidView), findsNothing);
      expect(find.textContaining('mine'), findsOneWidget);
    });
  });

  group('the native placeholder stack', () {
    // The id the engine gave the created platform view: the channel of the native stack ends with it.
    int? viewId;

    Future<void> platformMessage(MethodCall call) => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
          '${CYLNativePlaceholderStack.viewType}/$viewId',
          const StandardMethodCodec().encodeMethodCall(call),
          (_) {},
        );

    void mockPlatformViews(WidgetTester tester) {
      viewId = null;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform_views, (call) async {
        if (call.method != 'create') return null;
        viewId = (call.arguments as Map)['id'] as int;
        return viewId;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform_views, null));
    }

    testWidgets('CYLPlaceholderStackView builds an AndroidView whose creation parameters are the component maps with action names', (tester) async {
      mockPlatformViews(tester);
      var retries = 0;
      var background = 0;
      await tester.pumpWidget(MaterialApp(
        home: SizedBox(
          width: 300,
          height: 500,
          child: CYLPlaceholderStackView(
            backgroundAction: () => background++,
            components: [
              CYLPlaceholderComponent.icon(style: CYLPlaceholderStyle.cloudOff, title: 'Offline', animationFile: 'CYLPlaceholderLoadFailed.json', animationLoops: true, animationSpeed: 2),
              CYLPlaceholderComponent.hint('Try again'),
              CYLPlaceholderComponent.button('Retry', action: () => retries++),
            ],
          ),
        ),
      ));
      final android = tester.widget<AndroidView>(find.byType(AndroidView));
      expect(android.viewType, CYLNativePlaceholderStack.viewType);
      final params = android.creationParams as Map<String, Object?>;
      expect(params['backgroundAction'], 'background');
      final components = params['components'] as List;
      // An animated icon is an item component whose attributes name the animation asset (the native icon component would show its still).
      expect(components[0], allOf(containsPair('type', 'item'), containsPair('title', 'Offline'), containsPair('animationLoops', true), containsPair('animationSpeed', 2.0)));
      expect((components[0] as Map)['attributes'], {'CYLPlaceholderItemStyle': 'cloudOff', 'CYLPlaceholderItemAnimationFilePath': 'asset:CYLPlaceholderLoadFailed.json'});
      expect((components[0] as Map).containsKey('animation'), isFalse);
      expect(components[2], allOf(containsPair('type', 'button'), containsPair('action', 'component-2')));
      expect((components[1] as Map).containsKey('action'), isFalse);

      // The native stack reports the tapped action by name.
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await platformMessage(const MethodCall('onAction', 'component-2'));
      await platformMessage(const MethodCall('onAction', 'background'));
      expect(retries, 1);
      expect(background, 1);
    });

    testWidgets('a controller restart reaches the native stack as an update', (tester) async {
      mockPlatformViews(tester);
      final controller = CYLPlaceholderStackController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(MaterialApp(
        home: SizedBox(width: 300, height: 500, child: CYLPlaceholderStackView(controller: controller, components: [CYLPlaceholderComponent.hint('Hi')])),
      ));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
      // The view's creation made Dart listen on the channel (for the actions); stand in for the native side again to record.
      final updates = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(MethodChannel('${CYLNativePlaceholderStack.viewType}/$viewId'), (call) async {
        updates.add(call);
        return null;
      });
      controller.restartAnimation();
      await tester.pump();
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      expect(updates.single.method, 'update');
      expect(updates.single.arguments, {'name': 'restartAnimation', 'value': 1});
    });

    testWidgets('a component with a Flutter image keeps the Dart stack', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CYLPlaceholderStackView(components: [CYLPlaceholderComponent.icon(image: const SizedBox(key: ValueKey('mine'), width: 10, height: 10))]),
      ));
      expect(find.byType(AndroidView), findsNothing);
      expect(find.byKey(const ValueKey('mine')), findsOneWidget);
    });
  });
}
