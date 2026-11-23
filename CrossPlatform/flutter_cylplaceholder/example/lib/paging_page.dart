import 'package:flutter/material.dart';
import 'package:flutter_cylplaceholder/flutter_cylplaceholder.dart';

/// paging_page.dart of the upstream demo: a server of 45 items, 10 per page, 2 seconds per request; refresh on start.
class PagingPage extends StatefulWidget {
  /// Creates the page.
  const PagingPage({super.key});

  @override
  State<PagingPage> createState() => _PagingPageState();
}

class _PagingPageState extends State<PagingPage> {
  late final CYLRefreshClassicHeader _header = CYLRefreshClassicHeader();
  late final CYLRefreshClassicFooter _footer = CYLRefreshClassicFooter();
  late final CYLRefreshPaging<int> _paging;

  @override
  void initState() {
    super.initState();
    _paging = CYLRefreshPaging<int>(
      header: _header,
      footer: _footer,
      loader: (page, done) => Future<void>.delayed(const Duration(seconds: 2), () {
        const total = 45, size = 10;
        final start = (page - 1) * size;
        done(start >= total ? <int>[] : [for (var i = start; i < start + size && i < total; i++) i + 1], total: total);
      }),
    )..itemsDidChange = (_) => setState(() {});
  }

  @override
  void dispose() {
    _paging.dispose();
    _header.dispose();
    _footer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _paging.items ?? const <int>[];
    return Scaffold(
      appBar: AppBar(title: const Text('Paging')),
      body: CYLRefresh(
        header: _header,
        footer: _footer,
        refreshOnStart: true,
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) => ListTile(title: Text('Test data ${items[index]}')),
        ),
      ),
    );
  }
}
