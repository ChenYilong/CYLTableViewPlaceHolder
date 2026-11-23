import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cylplaceholder/flutter_cylplaceholder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CYLPlaceholderView: style, title, message, colors, tap, item attributes', () {
    testWidgets('shows the icon of the style, the title and the message', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: CYLPlaceholderView(style: CYLPlaceholderStyle.wifiOff, title: 'No connection', message: 'Check your network', iconColor: Colors.red),
      ));
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(tester.widget<Icon>(find.byIcon(Icons.wifi_off)).color, Colors.red);
      expect(find.text('No connection'), findsOneWidget);
      expect(find.text('Check your network'), findsOneWidget);
    });

    testWidgets('tapHandler runs on a tap unless tapInteractionEnabled is false', (tester) async {
      var taps = 0;
      Widget view(bool enabled) => MaterialApp(
            home: CYLPlaceholderView(title: 'Retry', tapHandler: () => taps++, tapInteractionEnabled: enabled),
          );
      await tester.pumpWidget(view(true));
      await tester.tap(find.text('Retry'));
      expect(taps, 1);
      await tester.pumpWidget(view(false));
      await tester.tap(find.text('Retry'));
      expect(taps, 1);
    });

    testWidgets('a custom image replaces the icon', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CYLPlaceholderView(image: SizedBox(key: ValueKey('mine'), width: 10, height: 10))));
      expect(find.byKey(const ValueKey('mine')), findsOneWidget);
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('an animation file is played by flutter_cyltabbar CYLAnimationView (no engine of its own)', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
      await tester.pumpWidget(const MaterialApp(
        home: CYLPlaceholderView(animationFile: 'error.riv', animationOptions: {'artboard': 'a'}, animationSize: Size(50, 40)),
      ));
      final view = tester.widget<CYLAnimationView>(find.byType(CYLAnimationView));
      expect(view.file, 'error.riv');
      expect(view.options['artboard'], 'a');
      expect(tester.getSize(find.byType(CYLAnimationView)), const Size(50, 40));
      debugDefaultTargetPlatformOverride = null;
    });

    test('fromItemAttributes reads the shared item keys and itemAttributes returns them', () {
      final view = CYLPlaceholderView.fromItemAttributes({
        CYLPlaceholderItemKey.title: 'Oops',
        CYLPlaceholderItemKey.message: 'Try again',
        CYLPlaceholderItemKey.style: 'cloudOff',
        CYLPlaceholderItemKey.titleColor: '#FF0000',
        CYLPlaceholderItemKey.animationURL: 'oops.riv',
        CYLPlaceholderItemKey.animationSize: [80, 60],
        'unknown': 1,
      });
      expect(view.title, 'Oops');
      expect(view.message, 'Try again');
      expect(view.style, CYLPlaceholderStyle.cloudOff);
      expect(view.titleColor, const Color(0xFFFF0000));
      expect(view.animationSize, const Size(80, 60));
      expect(view.itemAttributes[CYLPlaceholderItemKey.animationURL], 'oops.riv');
      expect(CYLPlaceholderView.fromItemAttributes({CYLPlaceholderItemKey.style: 2}).style, CYLPlaceholderStyle.error);
    });
  });
}
