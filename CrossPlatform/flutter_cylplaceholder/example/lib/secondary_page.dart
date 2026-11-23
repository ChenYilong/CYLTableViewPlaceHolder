import 'package:flutter/material.dart';
import 'package:flutter_cylplaceholder/flutter_cylplaceholder.dart';

/// The second floor: pull the header far down and release to open it, tap the button or scroll back to close it.
class SecondaryPage extends StatefulWidget {
  /// Creates the page.
  const SecondaryPage({super.key});

  @override
  State<SecondaryPage> createState() => _SecondaryPageState();
}

class _SecondaryPageState extends State<SecondaryPage> {
  late final CYLRefreshClassicHeader _header;
  String _log = 'Pull down past the trigger, then further, and release.';

  @override
  void initState() {
    super.initState();
    _header = CYLRefreshClassicHeader(refreshingHandler: () async {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (mounted) _header.endRefreshing();
    })
      ..secondaryTriggerOffset = 140
      ..secondaryOpenedBlock = (() => setState(() => _log = 'Second floor opened'))
      ..secondaryClosedBlock = (() => setState(() => _log = 'Second floor closed'))
      ..secondaryView = Material(
        color: Colors.indigo,
        child: Center(
          child: FilledButton.tonal(key: const ValueKey('close-second-floor'), onPressed: () => _header.closeSecondary(), child: const Text('Close the second floor')),
        ),
      );
  }

  @override
  void dispose() {
    _header.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Second floor'), actions: [
        TextButton(key: const ValueKey('open-second-floor'), onPressed: () => _header.openSecondary(), child: const Text('Open')),
      ]),
      body: CYLRefresh(
        header: _header,
        child: ListView(children: [
          ListTile(title: Text(_log, key: const ValueKey('second-floor-log'))),
          for (var i = 0; i < 20; i++) ListTile(title: Text('Row ${i + 1}')),
        ]),
      ),
    );
  }
}
