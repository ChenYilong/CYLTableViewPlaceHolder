import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'component.dart';
import 'refresh_types.dart';

/// The native refresh header (the Android `CYLRefreshDrivenLayout` with a `CYLRefreshNormalHeader`) as the indicator of a
/// [CYLRefreshComponent]: a platform view that follows the component. Flutter keeps the scrolling and the phase machine
/// (the component stays the reference and the caller still ends refreshing with `endRefreshing`); this view feeds the native
/// header the pull over the method channel `flutter_cylplaceholder/CYLRefreshView/<id>`:
///
/// - Dart to native: "drive" (`offset` in logical pixels, `dragging`, `startedAtEdge`), "release" and "finishRefresh" (`success`).
/// - Native to Dart: "onPhase" (`phase` and `oldPhase`, the names of [CYLRefreshPhase]) and "onRefreshing".
class CYLNativeRefreshIndicator extends StatefulWidget {
  /// Creates a native indicator that follows [component].
  const CYLNativeRefreshIndicator({super.key, required this.component, this.onPhase, this.onRefreshing});

  /// The type of the platform view of the native refresh header.
  static const String viewType = 'flutter_cylplaceholder/CYLRefreshView';

  /// The header whose pull and result the native header shows.
  final CYLRefreshComponent component;

  /// Called with the phase name when the native header's phase changes.
  final void Function(String phase, String oldPhase)? onPhase;

  /// Called when the native header starts to refresh.
  final VoidCallback? onRefreshing;

  @override
  State<CYLNativeRefreshIndicator> createState() => _CYLNativeRefreshIndicatorState();
}

class _CYLNativeRefreshIndicatorState extends State<CYLNativeRefreshIndicator> {
  MethodChannel? _channel;
  // The native header starts at rest, so a pull of 0 is not sent.
  double? _offset = 0;
  bool _wasDragging = false;
  bool _released = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    widget.component.addListener(_sync);
  }

  @override
  void didUpdateWidget(CYLNativeRefreshIndicator old) {
    super.didUpdateWidget(old);
    if (old.component != widget.component) {
      old.component.removeListener(_sync);
      widget.component.addListener(_sync);
    }
  }

  @override
  void dispose() {
    widget.component.removeListener(_sync);
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  void _created(int id) {
    final channel = MethodChannel('${CYLNativeRefreshIndicator.viewType}/$id');
    channel.setMethodCallHandler((call) async {
      final arguments = call.arguments as Map<Object?, Object?>?;
      if (call.method == 'onPhase') widget.onPhase?.call(arguments!['phase'] as String, arguments['oldPhase'] as String);
      if (call.method == 'onRefreshing') widget.onRefreshing?.call();
    });
    _channel = channel;
    _sync();
  }

  void _drive(double offset, bool dragging) {
    if (offset == _offset && dragging == _wasDragging) return;
    _channel!.invokeMethod<void>('drive', {'offset': offset, 'dragging': dragging, 'startedAtEdge': true});
    _offset = offset;
  }

  /// Mirrors the component: the pull while it is pulled, the release when it starts to refresh (armed through the trigger
  /// offset, so a refresh begun without a pull still opens the native header), the result when it ends.
  void _sync() {
    final channel = _channel;
    if (channel == null) return;
    final c = widget.component;
    switch (c.phase) {
      case CYLRefreshPhase.releasing:
      case CYLRefreshPhase.refreshing:
        if (_released) return;
        _released = true;
        _drive(math.max(c.dragOffset, c.triggerOffset), true);
        channel.invokeMethod<void>('release');
        _wasDragging = false;
      case CYLRefreshPhase.finishing:
        if (_finished) return;
        _finished = true;
        channel.invokeMethod<void>('finishRefresh', {'success': c.lastRefreshSucceeded});
      case CYLRefreshPhase.idle:
      case CYLRefreshPhase.pullToRefresh:
      case CYLRefreshPhase.releaseToRefresh:
        _released = false;
        _finished = false;
        _drive(c.dragOffset, c.dragging);
        // The finger lifted short of the trigger: the native header cancels the pull.
        if (_wasDragging && !c.dragging && c.phase != CYLRefreshPhase.idle) channel.invokeMethod<void>('release');
        _wasDragging = c.dragging;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AndroidView(
      viewType: CYLNativeRefreshIndicator.viewType,
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: _created,
    );
  }
}
