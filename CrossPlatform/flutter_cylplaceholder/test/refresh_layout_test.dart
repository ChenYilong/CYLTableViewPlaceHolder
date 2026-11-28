import 'package:flutter/material.dart';
import 'package:flutter_cylplaceholder/flutter_cylplaceholder.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

Widget horizontalList() => ListView.builder(scrollDirection: Axis.horizontal, itemCount: 30, itemExtent: 50, itemBuilder: (_, i) => Text('H$i'));

Future<void> dragBy(WidgetTester tester, Offset total, {bool release = true}) async {
  final gesture = await tester.startGesture(const Offset(200, 300));
  for (var i = 0; i < 10; i++) {
    await gesture.moveBy(total / 10);
    await tester.pump(const Duration(milliseconds: 16));
  }
  if (release) {
    await gesture.up();
    await frames(tester, 100);
  }
}

void main() {
  group('triggerAxis and CYLRefreshTrailer', () {
    testWidgets('a horizontal pull right arms the header (leading edge)', (tester) async {
      final header = plainHeader();
      await tester.pumpWidget(host(CYLRefresh(header: header, triggerAxis: Axis.horizontal, child: horizontalList())));
      await dragBy(tester, const Offset(400, 0), release: false);
      expect(header.phase, CYLRefreshPhase.releaseToRefresh);
      expect(find.byKey(const ValueKey('header')), findsOneWidget);
      header.dispose();
    });

    testWidgets('a vertical drag does not touch a horizontal CYLRefresh', (tester) async {
      final header = plainHeader();
      await tester.pumpWidget(host(CYLRefresh(header: header, triggerAxis: Axis.horizontal, child: horizontalList())));
      await dragBy(tester, const Offset(0, 300));
      expect(header.phase, CYLRefreshPhase.idle);
      header.dispose();
    });

    testWidgets('a trailer loads when the horizontal content is pulled past its end', (tester) async {
      var loads = 0;
      final trailer = CYLRefreshTrailer(refreshingHandler: () => loads++, builder: (context, component) => const SizedBox(key: ValueKey('trailer')));
      final controller = ScrollController();
      await tester.pumpWidget(host(CYLRefresh(footer: trailer, triggerAxis: Axis.horizontal, scrollController: controller, child: horizontalList())));
      controller.jumpTo(controller.position.maxScrollExtent);
      await tester.pump();
      await dragBy(tester, const Offset(-400, 0));
      expect(loads, 1);
      expect(trailer.isRefreshing, isTrue);
      trailer.dispose();
      controller.dispose();
    });
  });

  group('scrollController', () {
    testWidgets('is the primary controller of the child scrollables', (tester) async {
      final controller = ScrollController();
      await tester.pumpWidget(host(CYLRefresh(scrollController: controller, child: list())));
      expect(controller.hasClients, isTrue);
      controller.jumpTo(100);
      await tester.pump();
      expect(controller.offset, 100);
      controller.dispose();
    });
  });

  group('springs', () {
    testWidgets('readySpringBuilder is asked for the spring when a pulled list is released', (tester) async {
      var asked = 0;
      final header = plainHeader();
      await tester.pumpWidget(host(CYLRefresh(
        header: header,
        readySpringBuilder: () {
          asked++;
          return SpringDescription.withDampingRatio(mass: 0.5, stiffness: 100, ratio: 1.1);
        },
        child: list(),
      )));
      await pullDown(tester, 200);
      await frames(tester, 400);
      expect(asked, greaterThan(0));
      header.dispose();
    });

    test('springRebound = false stops a fling at the edge', () {
      final metrics = FixedScrollMetrics(minScrollExtent: 0, maxScrollExtent: 1000, pixels: 990, viewportDimension: 600, axisDirection: AxisDirection.down, devicePixelRatio: 1);
      final bouncing = const CYLRefreshPhysics().createBallisticSimulation(metrics, 3000)!;
      final clamped = const CYLRefreshPhysics(springRebound: false).createBallisticSimulation(metrics, 3000)!;
      double farthest(Simulation simulation) {
        var max = 0.0;
        for (var t = 0.0; t < 3.0; t += 0.02) {
          if (simulation.x(t) > max) max = simulation.x(t);
        }
        return max;
      }

      expect(farthest(bouncing), greaterThan(1000), reason: 'the default bounces past the end');
      expect(farthest(clamped), lessThanOrEqualTo(1000.001));
    });
  });

  group('locator', () {
    testWidgets('the header locator is as tall as the pull and draws the indicator', (tester) async {
      final header = CYLRefreshHeader(scrollMode: CYLRefreshScrollMode.locator, builder: (context, component) => const SizedBox(key: ValueKey('located')));
      await tester.pumpWidget(host(CYLRefresh(
        header: header,
        child: CustomScrollView(slivers: [
          const CYLRefreshHeaderLocator(),
          SliverList.builder(itemCount: 30, itemBuilder: (_, i) => SizedBox(height: 50, child: Text('Item $i'))),
        ]),
      )));
      expect(find.byKey(const ValueKey('located')), findsNothing, reason: 'closed: no pull yet');
      await pullDown(tester, 200, release: false);
      expect(find.byKey(const ValueKey('located')), findsOneWidget);
      header.dispose();
    });
  });

  group('nested scrollables', () {
    testWidgets('the footer reads the inner controller, the header the outer one', (tester) async {
      final outer = ScrollController();
      final inner = ScrollController();
      final header = plainHeader();
      final footer = plainFooter();
      await tester.pumpWidget(host(CYLRefresh(
        header: header,
        footer: footer,
        isNested: true,
        nestedOuterController: outer,
        nestedInnerController: inner,
        child: SingleChildScrollView(
          controller: outer,
          child: SizedBox(height: 400, child: ListView.builder(controller: inner, itemCount: 5, itemExtent: 50, itemBuilder: (_, i) => Text('I$i'))),
        ),
      )));
      inner.jumpTo(inner.position.maxScrollExtent);
      await tester.pump();
      await dragBy(tester, const Offset(0, -200), release: false);
      expect(footer.dragOffset, greaterThan(0));
      expect(header.dragOffset, 0);
      header.dispose();
      footer.dispose();
      outer.dispose();
      inner.dispose();
    });
  });
}
