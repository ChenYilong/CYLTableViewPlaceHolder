import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'cyl_placeholder_stack.dart';

/// The native `CYLPlaceholderStackView` as a widget: a platform view created from the configuration map of its components
/// (`CYLPlaceholderComponent.toConfiguration`, the "components" of `docs/Placeholder-Scenarios.md`), whose button and
/// background actions come back by name through a method channel. Used by [CYLPlaceholderStackView] on Android.
class CYLNativePlaceholderStack extends StatefulWidget {
  /// Creates a native placeholder stack for [components].
  const CYLNativePlaceholderStack({
    super.key,
    required this.components,
    this.backgroundAction,
    this.animationRestartToken = 0,
    this.height = 320,
  });

  /// The type of the platform view of the native `CYLPlaceholderStackView`.
  static const String viewType = 'flutter_cylplaceholder/CYLPlaceholderStackView';

  /// The name the native side reports for the action of the background.
  static const String backgroundName = 'background';

  /// The name the native side reports for the action of the component at [index].
  static String actionName(int index) => 'component-$index';

  /// The components, from top to bottom.
  final List<CYLPlaceholderComponent> components;

  /// Runs when the background is tapped.
  final VoidCallback? backgroundAction;

  /// Plays the animations again from the start when it changes.
  final int animationRestartToken;

  /// The height of the platform view when the parent does not bound it.
  final double height;

  /// The creation parameters the native side receives: the "components" list and, with a [backgroundAction], its name.
  Map<String, Object?> get creationParams => {
        'components': [for (var i = 0; i < components.length; i++) _configurationOf(i)],
        if (backgroundAction != null) 'backgroundAction': backgroundName,
      };

  /// The configuration map of the component at [index]. The native `icon` component only checks its "animation" name and shows
  /// the still icon, while an `item` component plays the animation file of its attributes (an Android asset, which the example
  /// copies into its `android/` project), so a component with an animation file is sent as an `item`.
  Map<String, Object?> _configurationOf(int index) {
    final component = components[index];
    final map = component.toConfiguration(actionName: actionName(index));
    final file = component.animationFile;
    if (file == null || (component.kind != CYLPlaceholderComponentKind.icon && component.kind != CYLPlaceholderComponentKind.item)) return map;
    return {
      ...map,
      'type': 'item',
      'attributes': {
        'CYLPlaceholderItemStyle': component.style.name,
        'CYLPlaceholderItemAnimationFilePath': 'asset:$file',
      },
    }..remove('animation')..remove('style')..remove('size');
  }

  @override
  State<CYLNativePlaceholderStack> createState() => _CYLNativePlaceholderStackState();
}

class _CYLNativePlaceholderStackState extends State<CYLNativePlaceholderStack> {
  MethodChannel? _channel;

  void _created(int id) {
    final channel = MethodChannel('${CYLNativePlaceholderStack.viewType}/$id');
    channel.setMethodCallHandler((call) async {
      if (call.method != 'onAction') return;
      final name = call.arguments as String;
      if (name == CYLNativePlaceholderStack.backgroundName) return widget.backgroundAction?.call();
      for (var i = 0; i < widget.components.length; i++) {
        if (CYLNativePlaceholderStack.actionName(i) == name) return widget.components[i].action?.call();
      }
    });
    _channel = channel;
  }

  @override
  void didUpdateWidget(CYLNativePlaceholderStack old) {
    super.didUpdateWidget(old);
    if (widget.animationRestartToken != old.animationRestartToken) {
      _channel?.invokeMethod<void>('update', {'name': 'restartAnimation', 'value': widget.animationRestartToken});
    }
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
        child: AndroidView(
          viewType: CYLNativePlaceholderStack.viewType,
          creationParams: widget.creationParams,
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: _created,
        ),
      ),
    );
  }
}
