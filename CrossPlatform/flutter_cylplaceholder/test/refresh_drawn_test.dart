import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_cylplaceholder/flutter_cylplaceholder.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

/// Every drawn header and footer, with its name.
List<(String, CYLRefreshComponent Function())> styles() => [
      ('bezier-radar-header', () => CYLRefreshBezierRadarHeader()),
      ('bezier-radar-footer', () => CYLRefreshBezierRadarFooter()),
      ('bezier-circle-header', () => CYLRefreshBezierCircleHeader()),
      ('delivery-header', () => CYLRefreshDeliveryHeader()),
      ('delivery-footer', () => CYLRefreshDeliveryFooter()),
      ('phoenix-header', () => CYLRefreshPhoenixHeader()),
      ('phoenix-footer', () => CYLRefreshPhoenixFooter()),
      ('taurus-header', () => CYLRefreshTaurusHeader()),
      ('taurus-footer', () => CYLRefreshTaurusFooter()),
    ];

Future<void> shot(WidgetTester tester, GlobalKey key, String name) async {
  final dir = Platform.environment['CYL_DRAWN_SHOTS'];
  if (dir == null) return;
  await tester.runAsync(() async {
    final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$dir/$name.png').writeAsBytesSync(data!.buffer.asUint8List());
  });
}

void main() {
  group('CYLRefreshDrawnFrame', () {
    test('the flags follow the phase', () {
      CYLRefreshDrawnFrame frame(CYLRefreshPhase phase) => CYLRefreshDrawnFrame(
          pull: 1, dragOffset: 60, phase: phase, loop: 0, isHeader: true, noMoreData: false, succeeded: true, foreground: Colors.white, background: Colors.blue);
      expect(frame(CYLRefreshPhase.refreshing).refreshing, isTrue);
      expect(frame(CYLRefreshPhase.releasing).refreshing, isTrue);
      expect(frame(CYLRefreshPhase.finishing).finishing, isTrue);
      expect(frame(CYLRefreshPhase.releaseToRefresh).armed, isTrue);
      expect(frame(CYLRefreshPhase.idle).refreshing, isFalse);
    });
  });

  for (final (name, make) in styles()) {
    group('drawn style $name', () {
      testWidgets('paints while pulled, armed, refreshing, finishing and with no more data, without errors', (tester) async {
        final component = make();
        final key = GlobalKey();
        final isHeader = component.isHeader;
        await tester.pumpWidget(host(RepaintBoundary(
          key: key,
          child: CYLRefresh(
            header: isHeader ? component as CYLRefreshHeader : null,
            footer: isHeader ? null : component as CYLRefreshFooter,
            child: list(),
          ),
        )));
        final pullFn = isHeader ? pullDown : pullUp;
        final gesture = await pullFn(tester, 40, release: false);
        expect(component.phase, CYLRefreshPhase.pullToRefresh);
        await shot(tester, key, '$name-1-pull');
        await gesture.moveBy(Offset(0, isHeader ? 300 : -300));
        await tester.pump(const Duration(milliseconds: 16));
        expect(component.phase, CYLRefreshPhase.releaseToRefresh);
        await shot(tester, key, '$name-2-armed');
        await gesture.up();
        await frames(tester, 400);
        expect(component.isRefreshing, isTrue);
        await frames(tester, 300);
        await shot(tester, key, '$name-3-refreshing');
        component.endRefreshing();
        await frames(tester, 100);
        await shot(tester, key, '$name-4-finishing');
        expect(find.byType(CustomPaint), findsWidgets);
        await settle(tester);
        if (component is CYLRefreshFooter) {
          component.noticeNoMoreData();
          await frames(tester, 300);
          await shot(tester, key, '$name-5-nomore');
        }
        component.dispose();
      });

      testWidgets('the loop animation runs only while refreshing', (tester) async {
        final component = make();
        final isHeader = component.isHeader;
        await tester.pumpWidget(refresh(header: isHeader ? component as CYLRefreshHeader : null, footer: isHeader ? null : component as CYLRefreshFooter));
        await tester.pump();
        expect(tester.binding.hasScheduledFrame, isFalse, reason: 'idle: nothing animates');
        component.beginRefreshing(duration: Duration.zero, overOffset: 0);
        await frames(tester, 100);
        expect(tester.binding.hasScheduledFrame, isTrue, reason: 'refreshing: the loop runs');
        component.endRefreshing();
        await settle(tester);
        await tester.pump();
        expect(tester.binding.hasScheduledFrame, isFalse);
        component.dispose();
      });
    });
  }
}
