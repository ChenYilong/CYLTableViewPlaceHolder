import 'package:flutter/material.dart';
import 'package:flutter_cylplaceholder/flutter_cylplaceholder.dart';

import 'rive_page.dart' show riveStyle;

/// The Bow file of flutter_easy_refresh, an app asset on every platform (Flutter assets are shared: `flutter_assets/` inside the Android APK and
/// the iOS app), found by its Flutter asset key by the native `rive` style.
const _riveBowAsset = 'assets/animations/CYLScenarioExampleRefreshBow.riv';

/// One refresh style: a name and a way to make its header and footer.
class _Style {
  const _Style(this.name, this.header, this.footer);

  final String name;
  final CYLRefreshHeader Function(void Function() onRefresh) header;
  final CYLRefreshFooter Function(void Function() onLoad) footer;
}

/// Every refresh style of the package on the same list: pick one, pull down to refresh, pull up to load more. The
/// counterpart of the iOS / Android "Refresh styles" demo page.
class StylesPage extends StatefulWidget {
  /// Creates the page.
  const StylesPage({super.key});

  @override
  State<StylesPage> createState() => _StylesPageState();
}

class _StylesPageState extends State<StylesPage> {
  static final _styles = <_Style>[
    _Style('Classic', (r) => CYLRefreshClassicHeader(refreshingHandler: r), (l) => CYLRefreshClassicFooter(refreshingHandler: l)),
    _Style('Cupertino', (r) => CYLRefreshCupertinoHeader(refreshingHandler: r), (l) => CYLRefreshCupertinoFooter(refreshingHandler: l)),
    _Style('Material', (r) => CYLRefreshMaterialHeader(refreshingHandler: r), (l) => CYLRefreshMaterialFooter(refreshingHandler: l)),
    _Style('Bezier radar', (r) => CYLRefreshBezierRadarHeader(refreshingHandler: r), (l) => CYLRefreshBezierRadarFooter(refreshingHandler: l)),
    _Style('Bezier circle', (r) => CYLRefreshBezierCircleHeader(refreshingHandler: r), (l) => CYLRefreshBezierRadarFooter(refreshingHandler: l)),
    _Style('Delivery', (r) => CYLRefreshDeliveryHeader(refreshingHandler: r), (l) => CYLRefreshDeliveryFooter(refreshingHandler: l)),
    _Style('Phoenix', (r) => CYLRefreshPhoenixHeader(refreshingHandler: r), (l) => CYLRefreshPhoenixFooter(refreshingHandler: l)),
    _Style('Taurus', (r) => CYLRefreshTaurusHeader(refreshingHandler: r), (l) => CYLRefreshTaurusFooter(refreshingHandler: l)),
    // The native `rive` style (docs/Refresh-Library-Parity.md): needs the Rive runtime in the app (iOS `Rive` subspec, Android `:merged-rive`); without it the
    // native view is classic and logs one line.
    _Style('Rive', (r) => CYLRefreshRiveNativeHeader(style: riveStyle('Bow', _riveBowAsset), refreshingHandler: r), (l) => CYLRefreshRiveNativeFooter(style: riveStyle('Bow', _riveBowAsset), refreshingHandler: l)),
  ];

  late CYLRefreshHeader _header;
  late CYLRefreshFooter _footer;
  int _selected = 0;
  int _count = 12;

  @override
  void initState() {
    super.initState();
    _make();
  }

  void _make() {
    _header = _styles[_selected].header(_refresh);
    _footer = _styles[_selected].footer(_load);
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
    setState(() => _count = 12);
    _header.endRefreshing();
  }

  Future<void> _load() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _count += 6);
    if (_count >= 30) {
      _footer.endRefreshingWithNoMoreData();
    } else {
      _footer.endRefreshing();
    }
  }

  void _select(int index) {
    final oldHeader = _header;
    final oldFooter = _footer;
    setState(() {
      _selected = index;
      _count = 12;
      _make();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      oldHeader.dispose();
      oldFooter.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Refresh styles')),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                for (var i = 0; i < _styles.length; i++)
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: ChoiceChip(
                      key: ValueKey('style-${_styles[i].name}'),
                      label: Text(_styles[i].name),
                      selected: _selected == i,
                      onSelected: (_) => _select(i),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: CYLRefresh(
              key: ValueKey('refresh-$_selected'),
              header: _header,
              footer: _footer,
              child: ListView.builder(itemCount: _count, itemBuilder: (_, i) => ListTile(title: Text('Row ${i + 1}'))),
            ),
          ),
        ],
      ),
    );
  }
}
