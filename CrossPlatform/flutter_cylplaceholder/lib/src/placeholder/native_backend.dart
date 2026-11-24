import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Where the placeholder and the HUD come from: the native components of the host platform (`CYLPlaceholderView`,
/// `CYLPlaceholderStackView` and `CYLPlaceholderHUD` on Android and iOS, through this package's plugins) or the Dart
/// implementation.
///
/// The Dart implementation is the fallback for the platforms that have no native half (web, desktop) and for
/// `flutter test`. The native half is used on Android and iOS, unless [override] says otherwise. The native refresh header
/// exists on Android only ([refreshEnabled]).
abstract final class CYLPlaceholderNative {
  /// The type of the platform view of the native `CYLPlaceholderView`.
  static const String viewType = 'flutter_cylplaceholder/CYLPlaceholderView';

  /// The method channel of the native HUD.
  static const MethodChannel hudChannel = MethodChannel('flutter_cylplaceholder/hud');

  /// true or false forces the native half on or off (tests use it); null decides by platform.
  static bool? override;

  /// Whether the native components are used now: Android or iOS, outside `flutter test`, unless [override] says otherwise.
  static bool get enabled {
    final forced = override;
    if (forced != null) return forced;
    if (kIsWeb || (defaultTargetPlatform != TargetPlatform.android && defaultTargetPlatform != TargetPlatform.iOS)) return false;
    return !Platform.environment.containsKey('FLUTTER_TEST');
  }

  /// Whether the native refresh header and footer are used: [enabled] on Android and on iOS (the driven `CYLRefreshDrivenLayout` of each).
  static bool get refreshEnabled => enabled;

  /// The platform view of [viewType] for the host platform: a `UiKitView` on iOS, an `AndroidView` elsewhere, both created
  /// from [creationParams] with the standard codec.
  static Widget platformView({
    required String viewType,
    required Map<String, Object?> creationParams,
    required PlatformViewCreatedCallback onPlatformViewCreated,
  }) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: viewType,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: onPlatformViewCreated,
      );
    }
    return AndroidView(
      viewType: viewType,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: onPlatformViewCreated,
    );
  }
}

/// The native `CYLPlaceholderView` as a widget: a platform view created from the item map (the keys of
/// `CYLPlaceholderItemKey` plus "animationLoops" and "animationSpeed"), updated live through a method channel.
class CYLNativePlaceholderView extends StatefulWidget {
  /// Creates a native placeholder view for [params].
  const CYLNativePlaceholderView({
    super.key,
    required this.params,
    this.animationLoops = false,
    this.animationSpeed = 1,
    this.animationRestartToken = 0,
    this.onTap,
    this.height = 240,
  });

  /// The item map: the keys of `CYLPlaceholderItemKey`.
  final Map<String, Object?> params;

  /// Whether the animation plays again after each pass.
  final bool animationLoops;

  /// The playback rate, 1 is the file's own speed.
  final double animationSpeed;

  /// Plays again from the start when it changes.
  final int animationRestartToken;

  /// Called when the placeholder is tapped; null means it is not a button.
  final VoidCallback? onTap;

  /// The height of the platform view when the parent does not bound it.
  final double height;

  /// The creation parameters the native side receives.
  Map<String, Object?> get creationParams => {
        ...params,
        'animationLoops': animationLoops,
        'animationSpeed': animationSpeed,
        'tappable': onTap != null,
      };

  @override
  State<CYLNativePlaceholderView> createState() => _CYLNativePlaceholderViewState();
}

class _CYLNativePlaceholderViewState extends State<CYLNativePlaceholderView> {
  MethodChannel? _channel;

  void _created(int id) {
    final channel = MethodChannel('${CYLPlaceholderNative.viewType}/$id');
    channel.setMethodCallHandler((call) async {
      if (call.method == 'onTap') widget.onTap?.call();
    });
    _channel = channel;
  }

  @override
  void didUpdateWidget(CYLNativePlaceholderView old) {
    super.didUpdateWidget(old);
    final channel = _channel;
    if (channel == null) return;
    void update(String name, Object? value) => channel.invokeMethod<void>('update', {'name': name, 'value': value});
    if (widget.animationLoops != old.animationLoops) update('animationLoops', widget.animationLoops);
    if (widget.animationSpeed != old.animationSpeed) update('animationSpeed', widget.animationSpeed);
    if (widget.animationRestartToken != old.animationRestartToken) update('restartAnimation', widget.animationRestartToken);
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        width: constraints.hasBoundedWidth ? constraints.maxWidth : null,
        height: constraints.hasBoundedHeight ? constraints.maxHeight : widget.height,
        child: CYLPlaceholderNative.platformView(
          viewType: CYLPlaceholderNative.viewType,
          creationParams: widget.creationParams,
          onPlatformViewCreated: _created,
        ),
      ),
    );
  }
}
