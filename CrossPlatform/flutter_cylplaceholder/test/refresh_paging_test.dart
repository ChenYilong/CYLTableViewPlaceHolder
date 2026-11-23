import 'package:flutter_cylplaceholder/flutter_cylplaceholder.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  group('CYLRefreshPaging: items, page, total, isEmpty, isNoMore, start, itemsDidChange', () {
    CYLRefreshPaging<int> server({CYLRefreshHeader? header, CYLRefreshFooter? footer, int total = 25, int size = 10, bool failOnce = false}) {
      var failed = false;
      return CYLRefreshPaging<int>(
        header: header,
        footer: footer,
        loader: (page, done) {
          if (failOnce && !failed) {
            failed = true;
            done(null, error: StateError('offline'));
            return;
          }
          final start = (page - 1) * size;
          final items = start >= total ? <int>[] : [for (var i = start; i < start + size && i < total; i++) i + 1];
          done(items, total: total);
        },
      );
    }

    test('without a header or footer: start loads page 1, loadMore appends, the last page sets isNoMore', () {
      final paging = server();
      var changes = 0;
      paging.itemsDidChange = (_) => changes++;
      expect(paging.items, isNull);
      expect(paging.isEmpty, isFalse);
      paging.start();
      expect(paging.page, 1);
      expect(paging.count, 10);
      expect(paging.total, 25);
      expect(paging.isNoMore, isFalse);
      paging.loadMore();
      paging.loadMore();
      expect(paging.items!.length, 25);
      expect(paging.page, 3);
      expect(paging.isNoMore, isTrue);
      paging.loadMore();
      expect(paging.page, 3, reason: 'nothing after the last page');
      expect(changes, 3);
      paging.refresh();
      expect(paging.count, 10);
      expect(paging.isNoMore, isFalse);
    });

    test('an empty first page is empty; a failure keeps the page so a retry loads the same one', () {
      final empty = CYLRefreshPaging<int>(loader: (page, done) => done(<int>[]));
      empty.start();
      expect(empty.isEmpty, isTrue);
      expect(empty.isNoMore, isTrue);
      final paging = server(failOnce: true);
      paging.start();
      expect(paging.error, isA<StateError>());
      expect(paging.items, isNull);
      expect(paging.page, 0);
      paging.start();
      expect(paging.page, 1);
      expect(paging.error, isNull);
    });

    testWidgets('with a header and a footer: refresh ends the header, a load ends the footer with no more data', (tester) async {
      final header = plainHeader();
      final footer = plainFooter();
      final paging = server(header: header, footer: footer, total: 15);
      await tester.pumpWidget(refresh(header: header, footer: footer));
      paging.start();
      await frames(tester, 100);
      expect(paging.count, 10);
      expect(header.phase, CYLRefreshPhase.finishing);
      await settle(tester);
      footer.beginRefreshing(duration: Duration.zero, overOffset: 0);
      await frames(tester, 100);
      expect(paging.count, 15);
      expect(paging.isNoMore, isTrue);
      expect(footer.isNoMoreData, isTrue);
      paging.start();
      await settle(tester);
      expect(footer.isNoMoreData, isFalse, reason: 'resetsFooterAfterRefresh');
      expect(paging.count, 10);
      header.dispose();
      footer.dispose();
      paging.dispose();
    });
  });
}
