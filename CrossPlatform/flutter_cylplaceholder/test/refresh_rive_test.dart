import 'package:flutter/foundation.dart';
import 'package:flutter_cylplaceholder/flutter_cylplaceholder.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  group('Rive styles through upstream CYLAnimationView', () {
    test('the progress follows the pull up to the trigger offset', () {
      final style = CYLRefreshRiveStyle(fileURL: 'a.riv', triggerOffset: 200);
      expect(cylRefreshRiveProgress(style, 0), 0);
      expect(cylRefreshRiveProgress(style, 50), 0.25);
      expect(cylRefreshRiveProgress(style, 999), 1);
      expect(cylRefreshRiveProgress(style, -5), 0);
    });

    test('the style asks upstream for its artboard, state machine, loading boolean and release trigger', () {
      final style = CYLRefreshRiveStyle(fileURL: 'a.riv', artboardName: 'Bow', stateMachineName: 'Pull', loadingBoolean: 'loading', releaseTrigger: 'go');
      expect(style.animationOptions, {'artboard': 'Bow', 'stateMachine': 'Pull', 'input': 'loading', 'triggerInput': 'go'});
      expect(CYLRefreshRiveStyle(fileURL: 'b.riv').animationOptions, isEmpty);
    });

    testWidgets('the header draws upstream CYLAnimationView driven by hand, as tall as the trigger offset', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
      try {
        final header = CYLRefreshRiveHeader(style: CYLRefreshRiveStyle(fileURL: 'bow.riv', artboardName: 'Bow', triggerOffset: 120));
        expect(header.expandHeight, 120);
        await tester.pumpWidget(refresh(header: header));
        header.beginRefreshing(duration: Duration.zero, overOffset: 0);
        await frames(tester, 300);
        final view = tester.widget<CYLAnimationView>(find.byType(CYLAnimationView));
        expect(view.file, 'bow.riv');
        expect(view.options['artboard'], 'Bow');
        expect(view.drivesAnimationPlayback, isFalse);
        expect(view.controller, isNotNull);
        header.dispose();
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('the drawn footer is a back footer with the style\'s height', (tester) async {
      final footer = CYLRefreshDrawnFooter(style: CYLRefreshRiveStyle(fileURL: 'f.riv', triggerOffset: 90));
      expect(footer, isA<CYLRefreshBackFooter>());
      expect(footer.expandHeight, 90);
      footer.dispose();
    });
  });
}
