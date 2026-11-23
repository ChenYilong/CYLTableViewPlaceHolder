import 'package:flutter/material.dart';

import 'cyl_placeholder_view.dart';
import 'native_backend.dart';
import 'native_stack.dart';

/// What a [CYLPlaceholderComponent] shows, like the iOS and Android component kinds.
enum CYLPlaceholderComponentKind {
  /// An icon or animation with an optional title and message (a [CYLPlaceholderView]).
  icon,

  /// A line of secondary text.
  hint,

  /// A button.
  button,

  /// A line with a text in the middle.
  separator,

  /// An icon-and-title item, like the first component of the iOS stack view.
  item,
}

/// How a button component is drawn.
enum CYLPlaceholderButtonStyle {
  /// A filled button.
  filled,

  /// An outlined button.
  outlined,

  /// A filled button with fully round ends.
  capsule,
}

/// One entry of a [CYLPlaceholderStackView], with the names of the iOS and Android `CYLPlaceholderComponent`.
class CYLPlaceholderComponent {
  /// Creates a component; the named constructors cover the usual kinds.
  CYLPlaceholderComponent({
    required this.kind,
    this.title,
    this.message,
    this.style = CYLPlaceholderStyle.empty,
    this.image,
    this.animationFile,
    this.animationOptions = const {},
    this.animationSize = const Size(120, 120),
    this.animationLoops = false,
    this.animationSpeed = 1,
    this.buttonStyle = CYLPlaceholderButtonStyle.filled,
    this.action,
    this.interactionEnabled = true,
    this.accessibilityIdentifier,
    double? spacingBefore,
  }) : spacingBefore = spacingBefore ?? _defaultSpacing(kind);

  /// An icon or animation with an optional title and message.
  factory CYLPlaceholderComponent.icon({
    CYLPlaceholderStyle style = CYLPlaceholderStyle.empty,
    String? title,
    String? message,
    Widget? image,
    String? animationFile,
    Map<String, Object> animationOptions = const {},
    Size animationSize = const Size(120, 120),
    bool animationLoops = false,
    double animationSpeed = 1,
    VoidCallback? action,
    double? spacingBefore,
  }) =>
      CYLPlaceholderComponent(
        kind: CYLPlaceholderComponentKind.icon,
        style: style,
        title: title,
        message: message,
        image: image,
        animationFile: animationFile,
        animationOptions: animationOptions,
        animationSize: animationSize,
        animationLoops: animationLoops,
        animationSpeed: animationSpeed,
        action: action,
        spacingBefore: spacingBefore,
      );

  /// A line of secondary text.
  factory CYLPlaceholderComponent.hint(String text, {double? spacingBefore}) =>
      CYLPlaceholderComponent(kind: CYLPlaceholderComponentKind.hint, title: text, spacingBefore: spacingBefore);

  /// A button; [action] runs when it is pressed.
  factory CYLPlaceholderComponent.button(String title, {VoidCallback? action, CYLPlaceholderButtonStyle style = CYLPlaceholderButtonStyle.filled, double? spacingBefore}) =>
      CYLPlaceholderComponent(kind: CYLPlaceholderComponentKind.button, title: title, action: action, buttonStyle: style, spacingBefore: spacingBefore);

  /// A line with [text] in the middle.
  factory CYLPlaceholderComponent.separator(String text, {double? spacingBefore}) =>
      CYLPlaceholderComponent(kind: CYLPlaceholderComponentKind.separator, title: text, spacingBefore: spacingBefore);

  static double _defaultSpacing(CYLPlaceholderComponentKind kind) => switch (kind) {
        CYLPlaceholderComponentKind.hint => 4,
        CYLPlaceholderComponentKind.button => 20,
        CYLPlaceholderComponentKind.separator => 14,
        CYLPlaceholderComponentKind.icon || CYLPlaceholderComponentKind.item => 12,
      };

  /// What the component shows.
  final CYLPlaceholderComponentKind kind;

  /// The title, or the text of a hint, button or separator.
  String? title;

  /// The message under an icon's title.
  String? message;

  /// The built-in icon, shown when there is no [image] and no animation.
  CYLPlaceholderStyle style;

  /// Replaces the style's icon.
  Widget? image;

  /// The animation file, a name in the app, a path or a URL.
  String? animationFile;

  /// The options of the animation file.
  Map<String, Object> animationOptions;

  /// The animation's size in logical pixels.
  Size animationSize;

  /// Whether the animation plays again after each pass.
  bool animationLoops;

  /// The playback rate of the animation, 1 is the file's own speed.
  double animationSpeed;

  /// How a button is drawn.
  CYLPlaceholderButtonStyle buttonStyle;

  /// Runs when a button is pressed or an icon is tapped.
  VoidCallback? action;

  /// False: the component is shown but inert (a disabled button).
  bool interactionEnabled;

  /// The identifier tests find the component by.
  String? accessibilityIdentifier;

  /// The space above the component in logical pixels.
  double spacingBefore;

  /// The component as the configuration map the native stack and HUD read (`docs/Placeholder-Scenarios.md`), with the action
  /// named [actionName] when it has one.
  Map<String, Object?> toConfiguration({String? actionName}) => {
        'type': kind.name,
        'title': ?title,
        if (kind == CYLPlaceholderComponentKind.icon || kind == CYLPlaceholderComponentKind.item) ...{
          'style': style.name,
          'animation': ?animationFile,
          'size': [animationSize.width, animationSize.height],
          'animationLoops': animationLoops,
          'animationSpeed': animationSpeed,
        },
        if (kind == CYLPlaceholderComponentKind.button) 'buttonStyle': buttonStyle.name,
        'action': ?(action != null ? actionName : null),
        'interactionEnabled': interactionEnabled,
        'spacingBefore': spacingBefore,
        'accessibilityIdentifier': ?accessibilityIdentifier,
      };
}

/// Plays the animations of a [CYLPlaceholderStackView] again, like `restartAnimation()` of the iOS and Android stack views.
/// It bumps the `animationRestartToken` of every animation, so there is no engine logic here.
class CYLPlaceholderStackController extends ChangeNotifier {
  int _token = 0;

  /// Grows by one with every [restartAnimation].
  int get animationRestartToken => _token;

  /// Plays every animation of the stack from the start.
  void restartAnimation() {
    _token++;
    notifyListeners();
  }
}

/// A vertical stack of [CYLPlaceholderComponent]s centered in the available space: the Flutter form of the iOS and Android
/// `CYLPlaceholderStackView`. [backgroundAction] runs when the empty space is tapped.
class CYLPlaceholderStackView extends StatelessWidget {
  /// Creates a stack of [components].
  const CYLPlaceholderStackView({super.key, required this.components, this.controller, this.backgroundAction, this.padding = const EdgeInsets.all(24)});

  /// The components, from top to bottom.
  final List<CYLPlaceholderComponent> components;

  /// Restarts the animations of the stack.
  final CYLPlaceholderStackController? controller;

  /// Runs when the background is tapped.
  final VoidCallback? backgroundAction;

  /// The space around the stack.
  final EdgeInsets padding;

  /// Whether the native component draws the stack: the native half is on, and no component asks for what only Flutter can draw
  /// (a Flutter [CYLPlaceholderComponent.image]).
  bool get _usesNative => CYLPlaceholderNative.enabled && components.every((c) => c.image == null);

  @override
  Widget build(BuildContext context) {
    if (_usesNative) {
      return ListenableBuilder(
        listenable: Listenable.merge(<Listenable>[?controller]),
        builder: (context, _) => Padding(
          padding: padding,
          child: CYLNativePlaceholderStack(
            components: components,
            backgroundAction: backgroundAction,
            animationRestartToken: controller?.animationRestartToken ?? 0,
          ),
        ),
      );
    }
    final body = ListenableBuilder(
      listenable: Listenable.merge(<Listenable>[?controller]),
      builder: (context, _) {
        final token = controller?.animationRestartToken ?? 0;
        return Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final component in components) ...[
                SizedBox(height: component.spacingBefore),
                _build(context, component, token),
              ],
            ],
          ),
        );
      },
    );
    // Centered when it fits, scrollable when the components are taller than the space.
    final centered = LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.hasBoundedHeight ? constraints.maxHeight : 0),
          child: Center(child: body),
        ),
      ),
    );
    return backgroundAction == null ? centered : GestureDetector(behavior: HitTestBehavior.opaque, onTap: backgroundAction, child: centered);
  }

  Widget _build(BuildContext context, CYLPlaceholderComponent c, int token) {
    final theme = Theme.of(context);
    Widget child;
    switch (c.kind) {
      case CYLPlaceholderComponentKind.icon:
      case CYLPlaceholderComponentKind.item:
        child = CYLPlaceholderView(
          style: c.style,
          title: c.title,
          message: c.message,
          image: c.image,
          animationFile: c.animationFile,
          animationOptions: c.animationOptions,
          animationSize: c.animationSize,
          animationLoops: c.animationLoops,
          animationSpeed: c.animationSpeed,
          animationRestartToken: token,
          tapHandler: c.action,
          tapInteractionEnabled: c.interactionEnabled,
        );
      case CYLPlaceholderComponentKind.hint:
        child = Text(c.title ?? '', textAlign: TextAlign.center, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant));
      case CYLPlaceholderComponentKind.button:
        final onPressed = c.interactionEnabled ? c.action : null;
        final label = Text(c.title ?? '');
        child = switch (c.buttonStyle) {
          CYLPlaceholderButtonStyle.filled => FilledButton(onPressed: onPressed, child: label),
          CYLPlaceholderButtonStyle.outlined => OutlinedButton(onPressed: onPressed, child: label),
          CYLPlaceholderButtonStyle.capsule => FilledButton(onPressed: onPressed, style: FilledButton.styleFrom(shape: const StadiumBorder()), child: label),
        };
      case CYLPlaceholderComponentKind.separator:
        child = Row(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(width: 32, child: Divider()),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(c.title ?? '', style: theme.textTheme.bodySmall)),
          const SizedBox(width: 32, child: Divider()),
        ]);
    }
    final id = c.accessibilityIdentifier;
    return id == null ? child : Semantics(identifier: id, container: true, child: child);
  }
}
