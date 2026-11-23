import 'package:flutter/material.dart';
import 'package:flutter_cylplaceholder/flutter_cylplaceholder.dart';

/// A failed load shows a [CYLPlaceholderView]; tapping it (retry) refreshes again, and the second request succeeds.
class ErrorPlaceholderPage extends StatefulWidget {
  /// Creates the page.
  const ErrorPlaceholderPage({super.key});

  @override
  State<ErrorPlaceholderPage> createState() => _ErrorPlaceholderPageState();
}

class _ErrorPlaceholderPageState extends State<ErrorPlaceholderPage> {
  late final CYLRefreshClassicHeader _header;
  List<int>? _items;
  bool _failed = false;
  int _requests = 0;

  @override
  void initState() {
    super.initState();
    _header = CYLRefreshClassicHeader(refreshingHandler: _load);
  }

  @override
  void dispose() {
    _header.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final success = ++_requests > 1;
    setState(() {
      _failed = !success;
      if (success) _items = List.generate(10, (i) => i + 1);
    });
    _header.endRefreshing(success: success);
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    return Scaffold(
      appBar: AppBar(title: const Text('Error placeholder')),
      body: CYLRefresh(
        header: _header,
        refreshOnStart: true,
        child: items != null
            ? ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) => ListTile(title: Text('Test data ${items[index]}')),
              )
            : ListView(
                children: [
                  if (_failed)
                    SizedBox(
                      height: 420,
                      child: CYLPlaceholderView(
                        key: const ValueKey('errorPlaceholder'),
                        style: CYLPlaceholderStyle.wifiOff,
                        title: 'Load failed',
                        message: 'Tap to retry',
                        tapHandler: () => _header.beginRefreshing(),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
