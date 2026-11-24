import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cylplaceholder/flutter_cylplaceholder.dart';

import 'demo_pages.dart';

/// The six Rive styles of flutter_easy_refresh (easy_refresh_bow, bubbles, halloween, skating, space, squats), with the
/// settings of the iOS demo (`CYLRefreshStylesDemoViewController.riveStyle`). Credits: assets/animations/NOTICE.animations.
const riveStyleNames = ['Bow', 'Bubbles', 'Halloween', 'Skating', 'Space', 'Squats'];

/// Makes the style of [name] for the Rive file at [path].
CYLRefreshRiveStyle riveStyle(String name, String path) {
  final style = CYLRefreshRiveStyle(fileURL: path);
  switch (name) {
    case 'Bow':
      style
        ..stateMachineName = 'numberSimulation'
        ..triggerOffset = 200
        ..fitsWidth = true
        ..pullInput = 'pull'
        ..pullInputMinimum = 50
        ..releaseTrigger = 'advance'
        ..finishTrigger = 'advance'
        ..restartTrigger = 'restart';
    case 'Bubbles':
      style
        ..stateMachineName = 'Motion'
        ..pullInput = 'numDrag'
        ..pullInputStart = 4.0 / 7.0
        ..pullInputMaximum = 99
        ..pullInputRefreshingValue = 100
        ..loadingNumber = 'numLoad';
    case 'Halloween':
      style
        ..triggerOffset = 200
        ..pullAnimation = 'Pull'
        ..triggerAnimation = 'Trigger'
        ..loadingAnimation = 'Loading';
    case 'Skating':
      style
        ..stateMachineName = 'Reload'
        ..minimumHeight = 140
        ..pullInput = 'pullAmount'
        ..releaseTrigger = 'pullRelease'
        ..finishTrigger = 'loadFinished';
    case 'Space':
      style
        ..stateMachineName = 'Reload'
        ..pullInput = 'Pull Amount'
        ..loadingBoolean = 'Start';
    default:
      style
        ..triggerOffset = 190
        ..fitsWidth = true
        ..idleAnimation = 'Idle'
        ..loadingAnimation = 'Demo';
  }
  return style;
}

/// Writes the bundled Rive file to a temporary file and returns its path: `CYLAnimationView` takes a path or a URL, and
/// finds a bare name only in the native bundle.
Future<String> riveFilePath(String name) async {
  final data = await rootBundle.load('assets/animations/CYLScenarioExampleRefresh$name.riv');
  final file = File('${Directory.systemTemp.path}/CYLScenarioExampleRefresh$name.riv');
  await file.writeAsBytes(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes), flush: true);
  return file.path;
}

/// The list of the Rive styles.
class RiveListPage extends StatelessWidget {
  /// Creates the page.
  const RiveListPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Rive styles')),
        body: ListView(children: [
          for (final name in riveStyleNames)
            ListTile(
              key: ValueKey('rive-$name'),
              title: Text('Rive: $name'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => RivePage(name: name))),
            ),
        ]),
      );
}

/// One Rive style: pull down to refresh; the Space style also has a Rive footer.
class RivePage extends StatefulWidget {
  /// Creates the page for the style [name].
  const RivePage({super.key, required this.name});

  /// One of [riveStyleNames].
  final String name;

  @override
  State<RivePage> createState() => _RivePageState();
}

class _RivePageState extends State<RivePage> {
  CYLRefreshRiveHeader? _header;
  CYLRefreshDrawnFooter? _footer;
  int _count = 12;

  @override
  void initState() {
    super.initState();
    riveFilePath(widget.name).then((path) {
      if (!mounted) return;
      setState(() {
        _header = CYLRefreshRiveHeader(
          style: riveStyle(widget.name, path),
          refreshingHandler: () async {
            await Future<void>.delayed(const Duration(seconds: 3));
            if (mounted) _header?.endRefreshing();
          },
        );
        if (widget.name == 'Space') {
          _footer = CYLRefreshDrawnFooter(
            style: riveStyle(widget.name, path),
            refreshingHandler: () async {
              await Future<void>.delayed(const Duration(seconds: 3));
              if (!mounted) return;
              setState(() => _count += 5);
              _footer?.endRefreshing();
            },
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _header?.dispose();
    _footer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Rive: ${widget.name}')),
        body: _header == null ? const SizedBox() : CYLRefresh(header: _header, footer: _footer, child: dataList(_count)),
      );
}
