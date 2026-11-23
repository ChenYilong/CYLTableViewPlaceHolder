import 'package:flutter/material.dart';

import 'error_placeholder_page.dart';
import 'paging_page.dart';
import 'refresh_page.dart';

void main() => runApp(const ExampleApp());

/// The example app: the pages mirror the iOS Swift demo in Examples/Example-Scenarios (`CYLEasyRefreshDemoViewController`).
class ExampleApp extends StatelessWidget {
  /// Creates the app.
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'flutter_cylplaceholder',
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
        home: const HomePage(),
      );
}

/// The list of the example pages.
class HomePage extends StatelessWidget {
  /// Creates the page.
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = <(String, Widget)>[
      ('Refresh', const RefreshPage()),
      ('Paging', const PagingPage()),
      ('Error placeholder', const ErrorPlaceholderPage()),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('CYLRefresh')),
      body: ListView(
        children: [
          for (final (title, page) in pages)
            ListTile(
              key: ValueKey(title),
              title: Text(title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page)),
            ),
        ],
      ),
    );
  }
}
