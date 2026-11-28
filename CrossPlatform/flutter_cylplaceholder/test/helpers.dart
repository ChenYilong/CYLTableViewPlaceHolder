import 'package:flutter/material.dart';
import 'package:flutter_cylplaceholder/flutter_cylplaceholder.dart';
import 'package:flutter_test/flutter_test.dart';

/// A list of [count] rows named "Item n".
Widget list([int count = 30]) => ListView.builder(itemCount: count, itemExtent: 50, itemBuilder: (_, i) => Text('Item $i'));

Widget host(Widget child, {Size size = const Size(400, 600)}) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: Scaffold(body: child),
      ),
    );

Widget refresh({
  CYLRefreshHeader? header,
  CYLRefreshFooter? footer,
  CYLRefreshHeader? startHeader,
  bool refreshOnStart = false,
  int count = 30,
  Widget Function(int count)? childOf,
  bool exclusive = true,
}) =>
    host(CYLRefresh(
      header: header,
      footer: footer,
      refreshOnStartHeader: startHeader,
      refreshOnStart: refreshOnStart,
      exclusiveWithOtherRefresh: exclusive,
      child: (childOf ?? list)(count),
    ));

/// Drags down by [dy] (finger travel), holds, and lets go when [release] is true.
Future<TestGesture> pullDown(WidgetTester tester, double dy, {bool release = true}) async {
  final gesture = await tester.startGesture(const Offset(200, 300));
  for (var i = 0; i < 10; i++) {
    await gesture.moveBy(Offset(0, dy / 10));
    await tester.pump(const Duration(milliseconds: 16));
  }
  if (release) {
    await gesture.up();
    await tester.pump();
  }
  return gesture;
}

/// Scrolls to the end, then drags up by [dy] past it.
Future<TestGesture> pullUp(WidgetTester tester, double dy, {bool release = true}) async {
  jumpToEnd(tester);
  await tester.pump();
  final gesture = await tester.startGesture(const Offset(200, 300));
  for (var i = 0; i < 10; i++) {
    await gesture.moveBy(Offset(0, -dy / 10));
    await tester.pump(const Duration(milliseconds: 16));
  }
  if (release) {
    await gesture.up();
    await tester.pump();
  }
  return gesture;
}

/// Pumps [ms] milliseconds in frames of 16 ms, so that chained animations run.
Future<void> frames(WidgetTester tester, int ms) async {
  for (var t = 0; t < ms; t += 16) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

Future<void> settle(WidgetTester tester) => frames(tester, 2500);

CYLRefreshHeader plainHeader({CYLRefreshHandler? onRefresh}) => CYLRefreshHeader(
      refreshingHandler: onRefresh,
      builder: (context, component) => const SizedBox(key: ValueKey('header'), height: 10),
    );

CYLRefreshFooter plainFooter({CYLRefreshHandler? onLoad}) => CYLRefreshBackFooter(
      refreshingHandler: onLoad,
      builder: (context, component) => const SizedBox(key: ValueKey('footer'), height: 10),
    );

/// Moves the list to its end without a drag.
void jumpToEnd(WidgetTester tester, [double back = 0]) {
  final position = tester.state<ScrollableState>(find.byType(Scrollable).first).position;
  position.jumpTo(position.maxScrollExtent - back);
}
