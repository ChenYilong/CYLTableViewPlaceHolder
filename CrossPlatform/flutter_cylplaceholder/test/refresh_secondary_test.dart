import 'package:flutter/material.dart';
import 'package:flutter_cylplaceholder/flutter_cylplaceholder.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

const _floor = SizedBox(key: ValueKey('floor'));

void main() {
  group('second floor (header)', () {
    testWidgets('a release past secondaryTriggerOffset opens it instead of refreshing', (tester) async {
      var opened = 0;
      var refreshes = 0;
      final header = plainHeader(onRefresh: () => refreshes++)
        ..secondaryView = _floor
        ..secondaryTriggerOffset = 90
        ..secondaryOpenedBlock = () => opened++;
      await tester.pumpWidget(refresh(header: header));
      await pullDown(tester, 600, release: false);
      expect(header.isSecondaryArmed, isTrue);
      header.handleRelease();
      await frames(tester, 400);
      expect(header.isSecondaryOpen, isTrue);
      expect(opened, 1);
      expect(refreshes, 0);
      expect(header.holdsSpace, isTrue);
      expect(find.byKey(const ValueKey('floor')), findsOneWidget);
      expect(find.byKey(const ValueKey('header')), findsNothing, reason: 'the second floor replaces the indicator');
      header.dispose();
    });

    testWidgets('a pull between the two triggers refreshes as usual', (tester) async {
      var refreshes = 0;
      final header = plainHeader(onRefresh: () => refreshes++)
        ..secondaryView = _floor
        ..secondaryTriggerOffset = 5000;
      await tester.pumpWidget(refresh(header: header));
      await pullDown(tester, 300);
      await frames(tester, 200);
      expect(refreshes, 1);
      expect(header.isSecondaryOpen, isFalse);
      header.dispose();
    });

    testWidgets('openSecondary and closeSecondary work from code and call their blocks', (tester) async {
      var closed = 0;
      final header = plainHeader()
        ..secondaryView = _floor
        ..secondaryClosedBlock = () => closed++;
      await tester.pumpWidget(refresh(header: header));
      header.openSecondary();
      await frames(tester, 400);
      expect(find.byKey(const ValueKey('floor')), findsOneWidget);
      header.closeSecondary();
      await frames(tester, 600);
      expect(closed, 1);
      expect(header.isSecondaryOpen, isFalse);
      expect(find.byKey(const ValueKey('floor')), findsNothing);
      header.closeSecondary();
      expect(closed, 1, reason: 'closing twice is a no-op');
      header.dispose();
    });

    testWidgets('without a secondaryView openSecondary does nothing', (tester) async {
      final header = plainHeader();
      await tester.pumpWidget(refresh(header: header));
      header.openSecondary();
      expect(header.isSecondaryOpen, isFalse);
      header.dispose();
    });

    testWidgets('the open floor is secondaryDimension tall', (tester) async {
      final header = plainHeader()
        ..secondaryView = _floor
        ..secondaryDimension = 200;
      await tester.pumpWidget(refresh(header: header));
      header.openSecondary();
      await frames(tester, 600);
      expect(tester.getSize(find.byKey(const ValueKey('floor'))).height, 200);
      header.dispose();
    });
  });

  group('second floor (footer)', () {
    testWidgets('a back footer opens its second floor by code and reports it', (tester) async {
      var opened = 0;
      final footer = plainFooter()
        ..secondaryView = _floor
        ..secondaryOpenedBlock = () => opened++;
      await tester.pumpWidget(refresh(footer: footer));
      footer.openSecondary();
      await frames(tester, 400);
      expect(opened, 1);
      expect(footer.isSecondaryOpen, isTrue);
      expect(find.byKey(const ValueKey('floor')), findsOneWidget);
      footer.dispose();
    });
  });
}
