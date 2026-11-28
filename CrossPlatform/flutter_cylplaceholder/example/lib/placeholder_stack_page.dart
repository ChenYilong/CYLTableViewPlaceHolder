import 'package:flutter/material.dart';
import 'package:flutter_cylplaceholder/flutter_cylplaceholder.dart';

/// The placeholder stack and the HUD, with the playback controls every animation page has: "Play all" restarts the
/// animations from the start, a speed slider and a loop switch apply live.
class PlaceholderStackPage extends StatefulWidget {
  /// Creates the page.
  const PlaceholderStackPage({super.key});

  @override
  State<PlaceholderStackPage> createState() => _PlaceholderStackPageState();
}

class _PlaceholderStackPageState extends State<PlaceholderStackPage> {
  final CYLPlaceholderStackController _controller = CYLPlaceholderStackController();
  final CYLPlaceholderHUD _hud = CYLPlaceholderHUD();
  double _speed = 1;
  bool _loops = false;

  @override
  void dispose() {
    _controller.dispose();
    _hud.dispose();
    super.dispose();
  }

  List<CYLPlaceholderComponent> _components() => [
        CYLPlaceholderComponent.icon(
          style: CYLPlaceholderStyle.cloudOff,
          title: 'Something went wrong',
          message: 'Check your connection and try again',
          animationFile: 'CYLPlaceholderLoadFailed.json',
          animationLoops: _loops,
          animationSpeed: _speed,
        ),
        CYLPlaceholderComponent.hint('Pull down on a list to refresh it'),
        CYLPlaceholderComponent.button('Retry', action: () => _hud.showSuccessWithStatus('Loaded')),
        CYLPlaceholderComponent.separator('or'),
        CYLPlaceholderComponent.button('Show progress', style: CYLPlaceholderButtonStyle.outlined, action: _progress),
        CYLPlaceholderComponent.button('HUD error', style: CYLPlaceholderButtonStyle.outlined, action: () => _hud.showErrorWithStatus('Failed')),
        CYLPlaceholderComponent.button('HUD info', style: CYLPlaceholderButtonStyle.outlined, action: () => _hud.showInfoWithStatus('Note')),
      ];

  Future<void> _progress() async {
    for (var i = 0; i <= 10; i++) {
      _hud.showProgress(i / 10, 'Uploading');
      await Future<void>.delayed(const Duration(milliseconds: 150));
    }
    _hud.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Placeholder stack and HUD')),
      body: CYLPlaceholderHUDHost(
        hud: _hud,
        child: Column(
          children: [
            Expanded(child: CYLPlaceholderStackView(controller: _controller, components: _components())),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                FilledButton(key: const ValueKey('play-all'), onPressed: _controller.restartAnimation, child: const Text('Play all')),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(key: const ValueKey('speed'), min: 0.5, max: 2, divisions: 6, value: _speed, label: '${_speed}x', onChanged: (v) => setState(() => _speed = v)),
                ),
                const Text('Loop'),
                Switch(key: const ValueKey('loop'), value: _loops, onChanged: (v) => setState(() => _loops = v)),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
