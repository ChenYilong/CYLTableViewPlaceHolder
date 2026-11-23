import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'component.dart';
import 'refresh_types.dart';

/// The native refresh header or footer (the Android `CYLRefreshDrivenLayout` with a `CYLRefreshNormalHeader` or `CYLRefreshBackNormalFooter`) as the indicator of a
/// [CYLRefreshComponent]: a platform view that follows the component. Flutter keeps the scrolling and the phase machine
/// (the component stays the reference and the caller still ends refreshing with `endRefreshing`); this view feeds the native
/// header the pull over the method channel `flutter_cylplaceholder/CYLRefreshView/<id>`:
///
/// - Creation parameters: `footer` (true: the native footer, pulled up) and `loadsAfterNoMoreData`.
/// - Dart to native: "drive" (`offset` in logical pixels, positive for a header and negative for a footer; `dragging`, `startedAtEdge`), "release",
///   "finishRefresh" (`success`; a footer adds `noMoreData`: end the load and show "no more data") and, for a footer, "noMoreData" (`value`:
///   show or clear it without a load).
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
  // Whether the native footer was told "no more data" (footers only).
  bool _noMoreData = false;

  bool get _isFooter => !widget.component.isHeader;

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
    // A footer is pulled up: the native layout takes the pull as a negative offset.
    _channel!.invokeMethod<void>('drive', {'offset': _isFooter && offset != 0 ? -offset : offset, 'dragging': dragging, 'startedAtEdge': true});
    _offset = offset;
  }

  void _setNoMoreData(bool value) {
    _noMoreData = value;
    _channel!.invokeMethod<void>('noMoreData', {'value': value});
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
        // A load begun after "no more data" (loadsAfterNoMoreData) clears it first, as the Dart footer does.
        if (_isFooter && _noMoreData) _setNoMoreData(false);
        _drive(math.max(c.dragOffset, c.triggerOffset), true);
        channel.invokeMethod<void>('release');
        _wasDragging = false;
      case CYLRefreshPhase.finishing:
        if (_finished) return;
        _finished = true;
        // A footer may end with "no more data": the native footer ends the load and shows it in one call.
        final noMore = _isFooter && c.isNoMoreData;
        channel.invokeMethod<void>('finishRefresh', {'success': c.lastRefreshSucceeded, if (_isFooter) 'noMoreData': noMore});
        _noMoreData = noMore;
      case CYLRefreshPhase.idle:
      case CYLRefreshPhase.pullToRefresh:
      case CYLRefreshPhase.releaseToRefresh:
        _released = false;
        _finished = false;
        if (_isFooter && c.isNoMoreData != _noMoreData) _setNoMoreData(c.isNoMoreData);
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
      // A footer asks for the native footer (a pull up); loadsAfterNoMoreData lets a pull load again after "no more data".
      creationParams: <String, Object?>{
        'footer': _isFooter,
        if (widget.component case final CYLRefreshFooter footer) 'loadsAfterNoMoreData': footer.loadsAfterNoMoreData,
      },
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: _created,
    );
  }
}
