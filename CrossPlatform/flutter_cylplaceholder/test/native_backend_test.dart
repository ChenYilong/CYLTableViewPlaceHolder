import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cylplaceholder/flutter_cylplaceholder.dart';
import 'package:flutter_test/flutter_test.dart';

class _NoOtherRefresh implements CYLRefreshHost {
  @override
  bool isOtherRefreshing(CYLRefreshComponent component) => false;
}

/// The contract of the native halves, tested on the Dart side with a mock method channel: the calls this package sends to the
/// native HUD, the creation parameters of the native placeholder view and stack, and what comes back. The same tests run for
/// Android and iOS (they differ only in the platform view class: `AndroidView` or `UiKitView`; the channel names, method names
/// and keys are one contract). The native behavior behind them is tested by the Android Robolectric tests
/// (`CYLPlaceholderBridgeTest`) and the iOS XCTest `CYLPlaceholderBridgeTests`.
const _bothPlatforms = TargetPlatformVariant({TargetPlatform.android, TargetPlatform.iOS});

/// The platform view class the platform under test uses.
Type get _platformViewType => debugDefaultTargetPlatformOverride == TargetPlatform.iOS ? UiKitView : AndroidView;

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

  test('the native refresh header and footer are on for Android and iOS, and off for the other platforms (the Dart indicator is the fallback)', () {
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      debugDefaultTargetPlatformOverride = platform;
      expect(CYLPlaceholderNative.refreshEnabled, isTrue, reason: '$platform');
    }
    CYLPlaceholderNative.override = null;
    expect(CYLPlaceholderNative.refreshEnabled, isFalse, reason: 'flutter test without the override');
  });

  group('the HUD calls the native HUD by name', () {
    testWidgets('show, status, progress, timed messages and dismiss', variant: _bothPlatforms, (tester) async {
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

    testWidgets('showComponents sends the component maps with action names, and a native tap calls the Dart action', variant: _bothPlatforms, (tester) async {
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
      await tester.runAsync(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
            CYLPlaceholderNative.hudChannel.name,
            const StandardMethodCodec().encodeMethodCall(const MethodCall('onAction', 'component-1')),
            (_) {},
          ));
      expect(retries, 1);
      hud.dispose();
    });

    testWidgets('the host draws nothing of its own: the native HUD draws over the activity or the key window', variant: _bothPlatforms, (tester) async {
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

    testWidgets('CYLPlaceholderView builds the platform view with the item map when the native half is on', variant: _bothPlatforms, (tester) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform_views, (call) async => call.method == 'create' ? 1 : null);
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform_views, null));
      await tester.pumpWidget(MaterialApp(
        home: SizedBox(
          width: 300,
          height: 300,
          child: CYLPlaceholderView(style: CYLPlaceholderStyle.cloudOff, title: 'Offline', message: 'Try again', animationLoops: true, animationSpeed: 1.5, tapHandler: () {}),
        ),
      ));
      final dynamic platformView = tester.widget<Widget>(find.byType(_platformViewType));
      expect(platformView.viewType, CYLPlaceholderNative.viewType);
      final params = platformView.creationParams as Map<String, Object?>;
      expect(params[CYLPlaceholderItemKey.title], 'Offline');
      expect(params[CYLPlaceholderItemKey.style], 'cloudOff');
      expect(params['animationLoops'], true);
      expect(params['animationSpeed'], 1.5);
      expect(params['tappable'], true);
    });

    testWidgets('a Flutter image or title style keeps the Dart widget, which can draw them', variant: _bothPlatforms, (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CYLPlaceholderView(image: SizedBox(key: ValueKey('mine'), width: 10, height: 10))));
      expect(find.byType(_platformViewType), findsNothing);
      expect(find.byKey(const ValueKey('mine')), findsOneWidget);
    });
  });

  group('the native refresh header', () {
    int? viewId;
    final sent = <MethodCall>[];
    Map<Object?, Object?>? creationParams;

    // Records what Dart sends to the native header and lets the test play the native side back.
    Future<void> pumpHeader(WidgetTester tester, CYLRefreshComponent header, {void Function(String, String)? onPhase, VoidCallback? onRefreshing, Widget Function(CYLRefreshComponent)? indicator}) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform_views, (call) async {
        if (call.method != 'create') return null;
        viewId = (call.arguments as Map)['id'] as int;
        final params = (call.arguments as Map)['params'];
        final bytes = params is Uint8List ? ByteData.sublistView(params) : params is ByteData ? params : null;
        creationParams = bytes == null ? null : const StandardMessageCodec().decodeMessage(bytes) as Map<Object?, Object?>?;
        return viewId;
      });
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox());
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform_views, null);
      });
      sent.clear();
      await tester.pumpWidget(MaterialApp(home: SizedBox(width: 300, height: 60, child: indicator?.call(header) ?? CYLNativeRefreshIndicator(component: header, onPhase: onPhase, onRefreshing: onRefreshing))));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
      // Dart listens on the channel now (for the events); stand in for the native side to record the calls.
      final channel = MethodChannel('${CYLNativeRefreshIndicator.viewType}/$viewId');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
        sent.add(call);
        return null;
      });
    }

    testWidgets('the pull is driven with logical pixels and the finger state, a short release cancels, a long one releases', variant: _bothPlatforms, (tester) async {
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

    testWidgets('endRefreshing calls finishRefresh once with the result; a refresh begun without a pull arms the native header first', variant: _bothPlatforms, (tester) async {
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

    testWidgets('onPhase and onRefreshing come back from the native header', variant: _bothPlatforms, (tester) async {
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

    testWidgets('the classic header draws the native indicator when the native half is on, and Dart when a builder asks for it', variant: _bothPlatforms, (tester) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform_views, (call) async => call.method == 'create' ? 1 : null);
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform_views, null));
      final plain = CYLRefreshClassicHeader();
      final custom = CYLRefreshClassicHeader()..textBuilder = (context, component, text) => Text('mine $text');
      addTearDown(plain.dispose);
      addTearDown(custom.dispose);
      await tester.pumpWidget(MaterialApp(home: SizedBox(height: 60, child: Builder(builder: plain.buildIndicator))));
      expect(find.byType(_platformViewType), findsOneWidget);
      await tester.pumpWidget(MaterialApp(home: SizedBox(height: 60, child: OverflowBox(maxWidth: 3000, child: Builder(builder: custom.buildIndicator)))));
      expect(find.byType(_platformViewType), findsNothing);
      expect(find.textContaining('mine'), findsOneWidget);
    });

    testWidgets('a footer asks for the native footer and drives the pull up as a negative offset', variant: _bothPlatforms, (tester) async {
      final footer = CYLRefreshClassicFooter();
      addTearDown(footer.dispose);
      await pumpHeader(tester, footer);
      expect(creationParams, {'style': 'classic', 'footer': true, 'loadsAfterNoMoreData': false});
      footer.handlePull(20, dragging: true);
      expect(sent.map((c) => c.method), ['drive']);
      expect(sent[0].arguments, {'offset': -20.0, 'dragging': true, 'startedAtEdge': true});
      footer.handlePull(footer.triggerOffset + 10, dragging: true);
      expect(footer.phase, CYLRefreshPhase.releaseToRefresh);
      expect(sent[1].arguments, containsPair('offset', -(footer.triggerOffset + 10)));
      sent.clear();
      footer.handleRelease();
      expect(sent.map((c) => c.method), ['release']);
      // A short pull: the finger lifts below the trigger, the native footer cancels it.
      final short = CYLRefreshClassicFooter();
      addTearDown(short.dispose);
      await pumpHeader(tester, short);
      short.handlePull(30, dragging: true);
      sent.clear();
      short.handlePull(30, dragging: false);
      short.handleRelease();
      expect(sent.map((c) => c.method), ['drive', 'release']);
      expect(sent[0].arguments, {'offset': -30.0, 'dragging': false, 'startedAtEdge': true});
    });

    testWidgets('a footer ends a load with the result or with no more data, and shows or clears no more data without a load', variant: _bothPlatforms, (tester) async {
      final footer = CYLRefreshClassicFooter(finishDuration: const Duration(milliseconds: 10));
      addTearDown(footer.dispose);
      await pumpHeader(tester, footer);
      footer.attach(_NoOtherRefresh());
      footer.beginRefreshing(force: true);
      expect(sent.map((c) => c.method), ['drive', 'release']);
      expect(sent[0].arguments, containsPair('offset', -footer.triggerOffset));
      sent.clear();
      footer.endRefreshingWithNoMoreData();
      expect(sent.map((c) => c.method), ['finishRefresh'], reason: 'one call: the native footer ends the load and shows no more data');
      expect(sent.single.arguments, {'success': true, 'noMoreData': true});
      sent.clear();
      await tester.pump(const Duration(milliseconds: 20));
      expect(footer.phase, CYLRefreshPhase.idle);
      expect(sent.map((c) => c.method), ['drive'], reason: 'back to rest; no second noMoreData call');
      expect(sent.single.arguments, containsPair('offset', 0.0));
      sent.clear();
      footer.resetNoMoreData();
      expect(sent.map((c) => c.method), ['noMoreData']);
      expect(sent.single.arguments, {'value': false});
      sent.clear();
      footer.noticeNoMoreData();
      expect(sent.single.arguments, {'value': true});
      // A plain load ends with the result alone.
      final plain = CYLRefreshClassicFooter(finishDuration: const Duration(milliseconds: 10));
      addTearDown(plain.dispose);
      await pumpHeader(tester, plain);
      plain.attach(_NoOtherRefresh());
      plain.beginRefreshing(force: true);
      sent.clear();
      plain.endRefreshing(success: false);
      expect(sent.single.arguments, {'success': false, 'noMoreData': false});
      await tester.pump(const Duration(milliseconds: 20));
    });

    testWidgets('a pull up after no more data keeps driving the native footer (it must keep showing the label) and never clears it or loads', variant: _bothPlatforms, (tester) async {
      final footer = CYLRefreshClassicFooter(finishDuration: const Duration(milliseconds: 10));
      addTearDown(footer.dispose);
      await pumpHeader(tester, footer);
      footer.attach(_NoOtherRefresh());
      footer.beginRefreshing(force: true);
      footer.endRefreshingWithNoMoreData();
      await tester.pump(const Duration(milliseconds: 20));
      expect(footer.isNoMoreData, isTrue);
      sent.clear();
      footer.handlePull(40, dragging: true);
      expect(sent.map((c) => c.method), ['drive'], reason: 'the native footer is still told the pull, and no noMoreData call clears the label');
      expect(sent.single.arguments, {'offset': -40.0, 'dragging': true, 'startedAtEdge': true});
      footer.handlePull(footer.triggerOffset + 10, dragging: true);
      footer.handleRelease();
      expect(sent.map((c) => c.method), ['drive', 'drive'], reason: 'no release: the footer is not armed after no more data');
      expect(footer.isRefreshing, isFalse);
      expect(footer.isNoMoreData, isTrue);
    });

    testWidgets('loadsAfterNoMoreData reaches the native footer and a load after no more data clears it first', variant: _bothPlatforms, (tester) async {
      final footer = CYLRefreshClassicFooter(loadsAfterNoMoreData: true);
      addTearDown(footer.dispose);
      await pumpHeader(tester, footer);
      expect(creationParams, containsPair('loadsAfterNoMoreData', true));
      footer.noticeNoMoreData();
      expect(sent.single.arguments, {'value': true});
      sent.clear();
      footer.attach(_NoOtherRefresh());
      footer.beginRefreshing();
      expect(sent.map((c) => c.method), ['noMoreData', 'drive', 'release']);
      expect(sent[0].arguments, {'value': false});
    });

    testWidgets('only the behind scroll mode asks the native slot to anchor at the far edge', variant: _bothPlatforms, (tester) async {
      for (final mode in [CYLRefreshScrollMode.move, CYLRefreshScrollMode.front, CYLRefreshScrollMode.behind]) {
        final header = CYLRefreshClassicHeader()..scrollMode = mode;
        addTearDown(header.dispose);
        await pumpHeader(tester, header);
        expect(creationParams, {'style': 'classic', 'footer': false, if (mode == CYLRefreshScrollMode.behind) 'behind': true}, reason: mode.name);
      }
    });

    testWidgets('a header with a second floor sends its creation parameters and opens and closes the native floor', variant: _bothPlatforms, (tester) async {
      final header = CYLRefreshClassicHeader()
        ..secondaryView = const SizedBox()
        ..secondaryTriggerOffset = 130
        ..secondaryDimension = 300
        ..secondaryCloseTriggerOffset = 70;
      addTearDown(header.dispose);
      await pumpHeader(tester, header);
      expect(creationParams, {'style': 'classic', 'footer': false, 'secondaryTriggerOffset': 130.0, 'secondaryDimension': 300.0, 'secondaryCloseTriggerOffset': 70.0});
      header.openSecondary();
      expect(sent.map((c) => c.method), contains('openSecondary'));
      sent.clear();
      header.closeSecondary();
      expect(sent.map((c) => c.method), ['closeSecondary']);
      sent.clear();
      header.closeSecondary();
      expect(sent, isEmpty, reason: 'a closed floor sends nothing again');
    });

    testWidgets('a header without a second floor sends no second floor parameters', variant: _bothPlatforms, (tester) async {
      final header = CYLRefreshClassicHeader();
      addTearDown(header.dispose);
      await pumpHeader(tester, header);
      expect(creationParams!.keys.where((k) => (k as String).startsWith('secondary')), isEmpty);
    });

    testWidgets('a header sends no footer parameters or no-more-data calls',variant: _bothPlatforms, (tester) async {
      final header = CYLRefreshClassicHeader(finishDuration: const Duration(milliseconds: 10));
      addTearDown(header.dispose);
      await pumpHeader(tester, header);
      expect(creationParams, {'style': 'classic', 'footer': false});
      header.attach(_NoOtherRefresh());
      header.beginRefreshing(force: true);
      sent.clear();
      header.endRefreshing();
      expect(sent.single.arguments, {'success': true});
      await tester.pump(const Duration(milliseconds: 20));
    });

    testWidgets('the classic footers draw the native indicator, a custom builder keeps them Dart', variant: _bothPlatforms, (tester) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform_views, (call) async => call.method == 'create' ? 1 : null);
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform_views, null));
      final footers = <CYLRefreshComponent>[CYLRefreshClassicFooter(), CYLRefreshClassicAutoFooter()];
      for (final footer in footers) {
        addTearDown(footer.dispose);
        await tester.pumpWidget(MaterialApp(home: SizedBox(height: 60, child: Builder(builder: footer.buildIndicator))));
        expect(find.byType(_platformViewType), findsOneWidget, reason: '${footer.runtimeType}');
      }
      final custom = CYLRefreshClassicFooter()..textBuilder = (context, component, text) => Text('mine $text');
      addTearDown(custom.dispose);
      await tester.pumpWidget(MaterialApp(home: SizedBox(height: 60, child: OverflowBox(maxWidth: 3000, child: Builder(builder: custom.buildIndicator)))));
      expect(find.byType(_platformViewType), findsNothing);
    });

    // Every style class of the Dart API, with the `style` value its native view gets (lower camel case, the same on Android and iOS).
    final styled = <(String, CYLRefreshComponent Function(), CYLRefreshComponent Function()?)>[
      ('classic', () => CYLRefreshClassicHeader(), () => CYLRefreshClassicFooter()),
      ('cupertino', () => CYLRefreshCupertinoHeader(), () => CYLRefreshCupertinoFooter()),
      ('material', () => CYLRefreshMaterialHeader(), () => CYLRefreshMaterialFooter()),
      ('bezierRadar', () => CYLRefreshBezierRadarHeader(), () => CYLRefreshBezierRadarFooter()),
      ('bezierCircle', () => CYLRefreshBezierCircleHeader(), null),
      ('delivery', () => CYLRefreshDeliveryHeader(), () => CYLRefreshDeliveryFooter()),
      ('phoenix', () => CYLRefreshPhoenixHeader(), () => CYLRefreshPhoenixFooter()),
      ('taurus', () => CYLRefreshTaurusHeader(), () => CYLRefreshTaurusFooter()),
    ];

    for (final (style, header, footer) in styled) {
      for (final (kind, make) in [('header', header), if (footer != null) ('footer', footer)]) {
        testWidgets('the $style $kind passes the creation parameter style: $style', variant: _bothPlatforms, (tester) async {
          final component = make();
          addTearDown(component.dispose);
          // Through the style class itself: it builds the native indicator with its style.
          await pumpHeader(tester, component, indicator: (c) => Builder(builder: c.buildIndicator));
          expect(creationParams, containsPair('style', style));
          expect(creationParams, containsPair('footer', kind == 'footer'));
        });
      }
    }

    // Written, not run (docs/Task-Log.md, "Batch hand-off W1b"): the drawn styles' Dart colors are creation parameters `foregroundColor`
    // and `backgroundColor`, ARGB integers.
    testWidgets('the drawn styles send their foregroundColor and backgroundColor as ARGB integers, header and footer', variant: _bothPlatforms, (tester) async {
      const foreground = Color(0xFF112233);
      const background = Color(0x80445566);
      final components = <CYLRefreshComponent Function()>[
        () => CYLRefreshBezierRadarHeader(foregroundColor: foreground, backgroundColor: background),
        () => CYLRefreshBezierRadarFooter(foregroundColor: foreground, backgroundColor: background),
        () => CYLRefreshBezierCircleHeader(foregroundColor: foreground, backgroundColor: background),
        () => CYLRefreshDeliveryHeader(foregroundColor: foreground, backgroundColor: background),
        () => CYLRefreshDeliveryFooter(foregroundColor: foreground, backgroundColor: background),
        () => CYLRefreshPhoenixHeader(foregroundColor: foreground, backgroundColor: background),
        () => CYLRefreshPhoenixFooter(foregroundColor: foreground, backgroundColor: background),
        () => CYLRefreshTaurusHeader(foregroundColor: foreground, backgroundColor: background),
        () => CYLRefreshTaurusFooter(foregroundColor: foreground, backgroundColor: background),
      ];
      for (final make in components) {
        final component = make();
        addTearDown(component.dispose);
        await pumpHeader(tester, component, indicator: (c) => Builder(builder: c.buildIndicator));
        expect(creationParams, containsPair('foregroundColor', 0xFF112233), reason: '${component.runtimeType}');
        expect(creationParams, containsPair('backgroundColor', 0x80445566), reason: '${component.runtimeType}');
      }
    });

    // Its own test: a second pump in one testWidgets keeps the first platform view's creation parameters.
    testWidgets('a drawn style without colors sends the Dart style own colors', variant: _bothPlatforms, (tester) async {
      final defaults = CYLRefreshTaurusHeader();
      addTearDown(defaults.dispose);
      await pumpHeader(tester, defaults, indicator: (c) => Builder(builder: c.buildIndicator));
      expect(creationParams, containsPair('foregroundColor', 0xFF263238));
      expect(creationParams, containsPair('backgroundColor', 0xFF81D4FA));
    });

    testWidgets('the classic, Cupertino and Material styles send no color keys', variant: _bothPlatforms, (tester) async {
      for (final make in <CYLRefreshComponent Function()>[() => CYLRefreshClassicHeader(), () => CYLRefreshCupertinoHeader(), () => CYLRefreshMaterialHeader(), () => CYLRefreshClassicFooter()]) {
        final component = make();
        addTearDown(component.dispose);
        await pumpHeader(tester, component, indicator: (c) => Builder(builder: c.buildIndicator));
        expect(creationParams!.containsKey('foregroundColor'), isFalse, reason: '${component.runtimeType}');
        expect(creationParams!.containsKey('backgroundColor'), isFalse, reason: '${component.runtimeType}');
      }
    });

    testWidgets('the style classes route to CYLNativeRefreshIndicator with their style only when the native switch is on and no Flutter-only builder is set', variant: _bothPlatforms, (tester) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform_views, (call) async => call.method == 'create' ? 1 : null);
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform_views, null));
      Future<void> show(WidgetTester tester, CYLRefreshComponent c) =>
          tester.pumpWidget(MaterialApp(home: SizedBox(height: 120, child: OverflowBox(maxWidth: 3000, child: Builder(builder: c.buildIndicator)))));
      for (final (style, header, footer) in styled) {
        for (final component in [header(), if (footer != null) footer()]) {
          addTearDown(component.dispose);
          await show(tester, component);
          expect(find.byType(_platformViewType), findsOneWidget, reason: '${component.runtimeType}');
          expect(tester.widget<CYLNativeRefreshIndicator>(find.byType(CYLNativeRefreshIndicator)).style, style, reason: '${component.runtimeType}');
        }
      }
      // The Dart indicator is the fallback: native switch off, or a Flutter-only builder.
      CYLPlaceholderNative.override = null;
      for (final (_, header, footer) in styled) {
        for (final component in [header(), if (footer != null) footer()]) {
          addTearDown(component.dispose);
          await show(tester, component);
          expect(find.byType(CYLNativeRefreshIndicator), findsNothing, reason: '${component.runtimeType} with the native switch off');
        }
      }
      CYLPlaceholderNative.override = true;
      final withBuilder = CYLRefreshTaurusHeader()..builder = (context, component) => const Text('mine');
      addTearDown(withBuilder.dispose);
      await show(tester, withBuilder);
      expect(find.byType(CYLNativeRefreshIndicator), findsNothing);
      final custom = CYLRefreshClassicHeader()..textBuilder = (context, component, text) => Text('mine $text');
      addTearDown(custom.dispose);
      await show(tester, custom);
      expect(find.byType(CYLNativeRefreshIndicator), findsNothing);
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

    testWidgets('CYLPlaceholderStackView builds the platform view whose creation parameters are the component maps with action names', variant: _bothPlatforms, (tester) async {
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
      final dynamic platformView = tester.widget<Widget>(find.byType(_platformViewType));
      expect(platformView.viewType, CYLNativePlaceholderStack.viewType);
      final params = platformView.creationParams as Map<String, Object?>;
      expect(params['backgroundAction'], 'background');
      final components = params['components'] as List;
      // An animated icon is an icon component whose "animation" names the bundled file; the native core plays it.
      expect(components[0], allOf(containsPair('type', 'icon'), containsPair('title', 'Offline'), containsPair('style', 'cloudOff'), containsPair('animation', 'CYLPlaceholderLoadFailed.json'), containsPair('animationLoops', true), containsPair('animationSpeed', 2.0)));
      expect((components[0] as Map).containsKey('attributes'), isFalse);
      expect(components[2], allOf(containsPair('type', 'button'), containsPair('action', 'component-2')));
      expect((components[1] as Map).containsKey('action'), isFalse);

      // The native stack reports the tapped action by name.
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await platformMessage(const MethodCall('onAction', 'component-2'));
      await platformMessage(const MethodCall('onAction', 'background'));
      expect(retries, 1);
      expect(background, 1);
    });

    testWidgets('a controller restart reaches the native stack as an update', variant: _bothPlatforms, (tester) async {
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

    testWidgets('a component with a Flutter image keeps the Dart stack', variant: _bothPlatforms, (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CYLPlaceholderStackView(components: [CYLPlaceholderComponent.icon(image: const SizedBox(key: ValueKey('mine'), width: 10, height: 10))]),
      ));
      expect(find.byType(_platformViewType), findsNothing);
      expect(find.byKey(const ValueKey('mine')), findsOneWidget);
    });
  });
}
