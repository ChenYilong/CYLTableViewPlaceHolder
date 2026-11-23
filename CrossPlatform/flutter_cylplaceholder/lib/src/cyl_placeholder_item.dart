import 'package:flutter/widgets.dart';
import 'package:flutter_cyltabbar/flutter_cyltabbar.dart';

/// A placeholder item: an animation (or the still image the engine falls back to) above a title, the Flutter form of
/// the icon-and-title placeholder.
///
/// It only lays out a [CYLAnimationView] and a [Text]; every playback property is passed to upstream's view under
/// upstream's name. Restart it by changing [animationRestartToken] or with [controller]'s `restart()` (the
/// `restartAnimation` of the other platforms). The whole item is one accessibility element labelled with [title]; the
/// animation is a decoration. The [title] comes from the host, so it can be localized there.
class CYLPlaceholderItem extends StatelessWidget {
  /// Creates an item that plays [file] above [title].
  const CYLPlaceholderItem({
    super.key,
    required this.file,
    required this.title,
    this.options = const {},
    this.iconSize = 80,
    this.titleStyle,
    this.playing = true,
    this.selected = false,
    this.animationSpeed = 1,
    this.animationLoops = false,
    this.animationRestartToken = 0,
    this.controller,
    this.onAnimationLoaded,
    this.onAnimationFailed,
    this.onAnimationEnd,
  });

  /// The animation file: a file name in the app, a path or a URL.
  final String file;

  /// The text under the animation, also the accessibility label of the item.
  final String title;

  /// Options of the file, e.g. Rive's `artboard` and `stateMachine`.
  final Map<String, Object> options;

  /// The side of the animation in logical pixels.
  final double iconSize;

  /// The style of the title, or null for the ambient text style.
  final TextStyle? titleStyle;

  /// Whether the animation plays (true by default, as a placeholder animates).
  final bool playing;

  /// Whether the item is selected (upstream's `selected`).
  final bool selected;

  /// The playback rate, 1 is the file's own speed.
  final double animationSpeed;

  /// Whether the animation plays again after each pass.
  final bool animationLoops;

  /// Plays again from the start when it changes.
  final int animationRestartToken;

  /// Upstream's commands (`play`, `stopAtProgress`, `restart`), or null.
  final CYLAnimationController? controller;

  /// The animation is in place.
  final VoidCallback? onAnimationLoaded;

  /// The animation cannot play; upstream shows its still image.
  final VoidCallback? onAnimationFailed;

  /// A play-once pass ended.
  final VoidCallback? onAnimationEnd;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: title,
      container: true,
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: CYLAnimationView(
              file: file,
              options: options,
              playing: playing,
              selected: selected,
              animationSpeed: animationSpeed,
              animationLoops: animationLoops,
              animationRestartToken: animationRestartToken,
              iconSize: iconSize,
              controller: controller,
              onAnimationLoaded: onAnimationLoaded,
              onAnimationFailed: onAnimationFailed,
              onAnimationEnd: onAnimationEnd,
            ),
          ),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: titleStyle),
        ],
      ),
    );
  }
}
