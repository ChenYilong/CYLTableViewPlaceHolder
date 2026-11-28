import 'package:flutter/material.dart';
import 'package:flutter_cylplaceholder/flutter_cylplaceholder.dart';

/// Pull to refresh, load more and no more data: 10 rows, a refresh returns to 10 rows after 2 seconds, a load adds 5,
/// and the footer shows "no more data" at 20 (the counts of `CYLEasyRefreshDemoViewController`).
class RefreshPage extends StatefulWidget {
  /// Creates the page.
  const RefreshPage({super.key});

  @override
  State<RefreshPage> createState() => _RefreshPageState();
}

class _RefreshPageState extends State<RefreshPage> {
  late final CYLRefreshClassicHeader _header;
  late final CYLRefreshClassicFooter _footer;
  int _count = 10;

  @override
  void initState() {
    super.initState();
    _header = CYLRefreshClassicHeader(refreshingHandler: _refresh, resetsFooterAfterRefresh: true);
    _footer = CYLRefreshClassicFooter(refreshingHandler: _load);
  }

  @override
  void dispose() {
    _header.dispose();
    _footer.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _count = 10);
    _header.endRefreshing();
  }

  Future<void> _load() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _count += 5);
    if (_count >= 20) {
      _footer.endRefreshingWithNoMoreData();
    } else {
      _footer.endRefreshing();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Refresh')),
        body: CYLRefresh(
          header: _header,
          footer: _footer,
          child: ListView.builder(
            itemCount: _count,
            itemBuilder: (context, index) => ListTile(title: Text('Test data ${index + 1}')),
          ),
        ),
      );
}
