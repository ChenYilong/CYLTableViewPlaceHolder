import 'package:flutter/material.dart';
import 'package:flutter_cylplaceholder/flutter_cylplaceholder.dart';

/// The pages of flutter_easy_refresh's example app (`example/lib/page`, dcdbb81), written with the CYLRefresh API and the
/// data of the iOS demo `CYLEasyRefreshDemoViewController`: 2 seconds per request, rows named "Test data N".

/// A list of "Test data" rows.
Widget dataList(int count, {ScrollController? controller, bool reverse = false}) => ListView.builder(
      controller: controller,
      reverse: reverse,
      itemCount: count,
      itemBuilder: (context, index) => ListTile(title: Text('Test data ${index + 1}')),
    );

Future<void> _wait() => Future<void>.delayed(const Duration(seconds: 2));

/// A page with a counted list: refresh back to 10 rows, load 5 more (or [loadStep]), no more data at [limit].
class CountedPage extends StatefulWidget {
  /// Creates the page; [header] and [footer] make the components, [onStart] marks `refreshOnStart`.
  const CountedPage({
    super.key,
    required this.title,
    required this.header,
    required this.footer,
    this.loadStep = 5,
    this.limit = 20,
    this.refreshOnStart = false,
    this.startHeader,
    this.extraRows,
    this.onRefreshed,
    this.onLoaded,
    this.configure,
  });

  /// The app bar title.
  final String title;

  /// Makes the header with its refresh callback.
  final CYLRefreshHeader Function(VoidCallback onRefresh) header;

  /// Makes the footer with its load callback.
  final CYLRefreshFooter Function(VoidCallback onLoad) footer;

  /// How many rows a load adds.
  final int loadStep;

  /// The row count at which the footer shows "no more data".
  final int limit;

  /// Refresh once after the first frame.
  final bool refreshOnStart;

  /// Makes a header used only for the first refresh.
  final CYLRefreshHeader Function(VoidCallback onRefresh)? startHeader;

  /// Rows shown above the data (the counts of the trigger mode page).
  final List<Widget> Function(CountedPageState state)? extraRows;

  /// Called when a refresh ends.
  final void Function(CountedPageState state)? onRefreshed;

  /// Called when a load ends.
  final void Function(CountedPageState state)? onLoaded;

  /// Called once the components exist, to tune them.
  final void Function(CYLRefreshHeader header, CYLRefreshFooter footer)? configure;

  @override
  State<CountedPage> createState() => CountedPageState();
}

/// The state of a [CountedPage]: the components and the counts.
class CountedPageState extends State<CountedPage> {
  late final CYLRefreshHeader header;
  late final CYLRefreshFooter footer;
  CYLRefreshHeader? startHeader;
  int count = 10;
  int refreshCount = 0;
  int loadCount = 0;

  @override
  void initState() {
    super.initState();
    header = widget.header(_refresh);
    footer = widget.footer(_load);
    startHeader = widget.startHeader?.call(_refresh);
    widget.configure?.call(header, footer);
  }

  @override
  void dispose() {
    header.dispose();
    footer.dispose();
    startHeader?.dispose();
    super.dispose();
  }

  /// Rebuilds the page after [change].
  void update(VoidCallback change) => setState(change);

  CYLRefreshHeader get _current => startHeader != null && startHeader!.isRefreshing ? startHeader! : header;

  Future<void> _refresh() async {
    await _wait();
    if (!mounted) return;
    setState(() {
      count = 10;
      refreshCount++;
    });
    widget.onRefreshed?.call(this);
    _current.endRefreshing();
    footer.resetNoMoreData();
  }

  Future<void> _load() async {
    await _wait();
    if (!mounted) return;
    setState(() {
      count += widget.loadStep;
      loadCount++;
    });
    widget.onLoaded?.call(this);
    if (count >= widget.limit) {
      footer.endRefreshingWithNoMoreData();
    } else {
      footer.endRefreshing();
    }
  }

  @override
  Widget build(BuildContext context) {
    final extra = widget.extraRows?.call(this) ?? const <Widget>[];
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: CYLRefresh(
        header: header,
        footer: footer,
        refreshOnStartHeader: startHeader,
        refreshOnStart: widget.refreshOnStart,
        child: ListView(children: [
          ...extra,
          for (var i = 0; i < count; i++) ListTile(title: Text('Test data ${i + 1}')),
        ]),
      ),
    );
  }
}

/// cupertino_page.dart: the iOS style header and footer.
Widget cupertinoPage() => CountedPage(
      title: 'Cupertino style',
      header: (r) => CYLRefreshCupertinoHeader(refreshingHandler: r),
      footer: (l) => CYLRefreshCupertinoFooter(refreshingHandler: l),
    );

/// refresh_on_start_page.dart: the first refresh uses a Cupertino header, later pulls the classic one; loads add 10 rows
/// and end at 30.
Widget refreshOnStartPage() => CountedPage(
      title: 'Refresh on start',
      refreshOnStart: true,
      loadStep: 10,
      limit: 30,
      header: (r) => CYLRefreshClassicHeader(refreshingHandler: r),
      startHeader: (r) => CYLRefreshCupertinoHeader(refreshingHandler: r),
      footer: (l) => CYLRefreshClassicFooter(refreshingHandler: l),
    );

/// trigger_mode_page.dart: tap the two rows to switch the header and the footer between "anywhere" and "edge only".
Widget triggerModePage() => CountedPage(
      title: 'Trigger mode',
      header: (r) => CYLRefreshClassicHeader(refreshingHandler: r),
      footer: (l) => CYLRefreshClassicFooter(refreshingHandler: l),
      extraRows: (state) => [
        ListTile(key: const ValueKey('refresh-count'), title: Text('Refresh count: ${state.refreshCount}')),
        ListTile(key: const ValueKey('load-count'), title: Text('Load count: ${state.loadCount}')),
        ListTile(
          key: const ValueKey('header-mode'),
          title: Text(state.header.triggerMode == CYLRefreshTriggerMode.onEdge ? 'Header: edge only' : 'Header: anywhere'),
          onTap: () => state.update(() => state.header.triggerMode =
              state.header.triggerMode == CYLRefreshTriggerMode.onEdge ? CYLRefreshTriggerMode.anywhere : CYLRefreshTriggerMode.onEdge),
        ),
        ListTile(
          key: const ValueKey('footer-mode'),
          title: Text(state.footer.triggerMode == CYLRefreshTriggerMode.onEdge ? 'Footer: edge only' : 'Footer: anywhere'),
          onTap: () => state.update(() => state.footer.triggerMode =
              state.footer.triggerMode == CYLRefreshTriggerMode.onEdge ? CYLRefreshTriggerMode.anywhere : CYLRefreshTriggerMode.onEdge),
        ),
      ],
    );

/// theme_switch_page.dart: tap a row to recolor the Material header and footer.
class ThemeSwitchPage extends StatefulWidget {
  /// Creates the page.
  const ThemeSwitchPage({super.key});

  @override
  State<ThemeSwitchPage> createState() => _ThemeSwitchPageState();
}

class _ThemeSwitchPageState extends State<ThemeSwitchPage> {
  late final CYLRefreshMaterialHeader _header = CYLRefreshMaterialHeader(refreshingHandler: () async {
    await _wait();
    if (mounted) _header.endRefreshing();
  });

  @override
  void dispose() {
    _header.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themes = <(String, Color?, Color?)>[
      ('Default', null, null),
      ('Orange', Colors.orange, Colors.white),
      ('Red', Colors.red, Colors.white),
      ('Green', Colors.green, Colors.white),
      ('Blue', Colors.blue, Colors.white),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Theme switch')),
      body: CYLRefresh(
        header: _header,
        child: ListView(children: [
          for (final (name, primary, accent) in themes)
            ListTile(
              key: ValueKey('theme-$name'),
              title: Text(name),
              subtitle: Text(primary == null ? 'Tap to restore' : 'Tap to switch'),
              onTap: () => setState(() {
                _header.colorPrimary = primary;
                _header.colorAccent = accent;
                _header.refreshIndicator();
              }),
            ),
          for (var i = 0; i < 10; i++) ListTile(title: Text('Test data ${i + 1}')),
        ]),
      ),
    );
  }
}

/// listener_header_page.dart: the header draws nothing; the bar above the list shows how far it is pulled.
class ListenerHeaderPage extends StatefulWidget {
  /// Creates the page.
  const ListenerHeaderPage({super.key});

  @override
  State<ListenerHeaderPage> createState() => _ListenerHeaderPageState();
}

class _ListenerHeaderPageState extends State<ListenerHeaderPage> {
  late final CYLRefreshListenerHeader _header = CYLRefreshListenerHeader(refreshingHandler: () async {
    await _wait();
    if (mounted) _header.endRefreshing();
  });

  @override
  void dispose() {
    _header.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Listener header')),
        body: Column(children: [
          ListenableBuilder(
            listenable: _header,
            builder: (context, _) => LinearProgressIndicator(
              key: const ValueKey('pull-progress'),
              value: _header.isRefreshing ? null : _header.pullingPercent.clamp(0, 1).toDouble(),
              semanticsLabel: 'Pull progress',
              semanticsValue: '${(_header.pullingPercent.clamp(0, 1) * 100).round()}%',
            ),
          ),
          Expanded(child: CYLRefresh(header: _header, child: dataList(20))),
        ]),
      );
}

/// chat_page.dart: the header loads earlier messages at the top.
class ChatPage extends StatefulWidget {
  /// Creates the page.
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final CYLRefreshClassicHeader _header = CYLRefreshClassicHeader(refreshingHandler: _earlier)
    ..setTitle('Pull down for earlier messages', CYLRefreshTitleState.pullToRefresh)
    ..showsLastUpdatedTime = false;
  final List<String> _messages = [for (var i = 1; i <= 8; i++) 'Message $i'];
  int _oldest = 0;

  @override
  void dispose() {
    _header.dispose();
    super.dispose();
  }

  Future<void> _earlier() async {
    await _wait();
    if (!mounted) return;
    setState(() {
      for (var i = 0; i < 5; i++) {
        _messages.insert(0, 'Earlier message ${--_oldest}');
      }
    });
    _header.endRefreshing();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: CYLRefresh(
          header: _header,
          child: ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index) => Align(
              alignment: index.isEven ? Alignment.centerLeft : Alignment.centerRight,
              child: Card(child: Padding(padding: const EdgeInsets.all(12), child: Text(_messages[index]))),
            ),
          ),
        ),
      );
}

/// user_profile_page.dart: the indicator stays behind the content, which moves away to reveal it.
class UserProfilePage extends StatefulWidget {
  /// Creates the page.
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late final CYLRefreshClassicHeader _header = CYLRefreshClassicHeader(
    scrollMode: CYLRefreshScrollMode.behind,
    expandHeight: 80,
    refreshingHandler: () async {
      await _wait();
      if (mounted) _header.endRefreshing();
    },
  );

  @override
  void dispose() {
    _header.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('User profile')),
        body: Container(
          color: Colors.indigo.shade100,
          child: CYLRefresh(
            header: _header,
            child: ListView(children: [
              Container(
                color: Theme.of(context).colorScheme.surface,
                padding: const EdgeInsets.all(24),
                child: const Row(children: [CircleAvatar(radius: 32, child: Icon(Icons.person)), SizedBox(width: 16), Text('Yilong', style: TextStyle(fontSize: 22))]),
              ),
              for (var i = 0; i < 12; i++) Container(color: Theme.of(context).colorScheme.surface, child: ListTile(title: Text('Post ${i + 1}'))),
            ]),
          ),
        ),
      );
}

/// carousel_page.dart, page_view_page.dart and tab_bar_view_page.dart: every page of a horizontal pager has its own
/// header, so the pull belongs to the page that is shown.
class PagerPage extends StatelessWidget {
  /// Creates the page; [tabs] shows a `TabBarView` with tabs instead of a bare `PageView`.
  const PagerPage({super.key, required this.title, this.tabs = false, this.carousel = false});

  /// The app bar title.
  final String title;

  /// A `TabBarView` with a tab bar.
  final bool tabs;

  /// A `PageView` showing part of the next page.
  final bool carousel;

  @override
  Widget build(BuildContext context) {
    Widget page(int i) => _PagerList(label: 'Page ${i + 1}');
    if (tabs) {
      return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(title: Text(title), bottom: const TabBar(tabs: [Tab(text: 'One'), Tab(text: 'Two'), Tab(text: 'Three')])),
          body: TabBarView(children: [for (var i = 0; i < 3; i++) page(i)]),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PageView(controller: PageController(viewportFraction: carousel ? 0.85 : 1), children: [for (var i = 0; i < 3; i++) page(i)]),
    );
  }
}

class _PagerList extends StatefulWidget {
  const _PagerList({required this.label});

  final String label;

  @override
  State<_PagerList> createState() => _PagerListState();
}

class _PagerListState extends State<_PagerList> {
  late final CYLRefreshClassicHeader _header = CYLRefreshClassicHeader(refreshingHandler: () async {
    await _wait();
    if (mounted) _header.endRefreshing();
  });

  @override
  void dispose() {
    _header.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CYLRefresh(
        header: _header,
        child: ListView.builder(itemCount: 12, itemBuilder: (context, i) => ListTile(title: Text('${widget.label}, row ${i + 1}'))),
      );
}

/// nested_scroll_view.dart: the header belongs to the outer scrollable and the footer to the inner list.
class NestedPage extends StatefulWidget {
  /// Creates the page.
  const NestedPage({super.key});

  @override
  State<NestedPage> createState() => _NestedPageState();
}

class _NestedPageState extends State<NestedPage> {
  final ScrollController _outer = ScrollController();
  final ScrollController _inner = ScrollController();
  late final CYLRefreshClassicHeader _header = CYLRefreshClassicHeader(refreshingHandler: () async {
    await _wait();
    if (!mounted) return;
    setState(() => _count = 10);
    _header.endRefreshing();
  });
  late final CYLRefreshClassicFooter _footer = CYLRefreshClassicFooter(refreshingHandler: () async {
    await _wait();
    if (!mounted) return;
    setState(() => _count += 5);
    _footer.endRefreshing();
  });
  int _count = 10;

  @override
  void dispose() {
    _header.dispose();
    _footer.dispose();
    _outer.dispose();
    _inner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Nested scrolling')),
        body: CYLRefresh(
          header: _header,
          footer: _footer,
          isNested: true,
          nestedOuterController: _outer,
          nestedInnerController: _inner,
          child: SingleChildScrollView(
            controller: _outer,
            child: Column(children: [
              Container(height: 120, color: Colors.indigo.shade100, alignment: Alignment.center, child: const Text('Header area (outer scroll)')),
              SizedBox(height: 480, child: ListView.builder(controller: _inner, itemCount: _count, itemBuilder: (context, i) => ListTile(title: Text('Test data ${i + 1}')))),
            ]),
          ),
        ),
      );
}

/// center_refresh_page.dart: an empty list shows the placeholder in the centre and still refreshes.
class CenterRefreshPage extends StatefulWidget {
  /// Creates the page.
  const CenterRefreshPage({super.key});

  @override
  State<CenterRefreshPage> createState() => _CenterRefreshPageState();
}

class _CenterRefreshPageState extends State<CenterRefreshPage> {
  late final CYLRefreshClassicHeader _header = CYLRefreshClassicHeader(refreshingHandler: () async {
    await _wait();
    if (!mounted) return;
    setState(() => _items = _items == 0 ? 10 : 0);
    _header.endRefreshing();
  });
  int _items = 0;

  @override
  void dispose() {
    _header.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Centre indicator')),
        body: CYLRefresh(
          header: _header,
          child: _items == 0
              ? ListView(children: [
                  SizedBox(
                    height: 420,
                    child: CYLPlaceholderView(
                      key: const ValueKey('emptyPlaceholder'),
                      style: CYLPlaceholderStyle.empty,
                      title: 'No data',
                      message: 'Pull down to fill the list',
                      tapHandler: () => _header.beginRefreshing(),
                    ),
                  ),
                ])
              : dataList(_items),
        ),
      );
}
