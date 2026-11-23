import 'package:flutter/material.dart';
import 'package:flutter_cyltabbar/flutter_cyltabbar.dart';

/// The built-in icon styles of a placeholder, in the order of iOS `CYLPlaceholderStyle` (the first twenty).
enum CYLPlaceholderStyle {
  /// An empty tray: nothing here yet.
  empty(Icons.inbox_outlined),

  /// A struck magnifier: a search without results.
  noResults(Icons.search_off),

  /// An exclamation mark in a circle: a general error.
  error(Icons.error_outline),

  /// A crossed Wi-Fi symbol.
  wifiOff(Icons.wifi_off),

  /// A crossed signal symbol.
  signalWifiOff(Icons.signal_wifi_off),

  /// No Internet connection.
  noInternet(Icons.signal_wifi_connected_no_internet_4),

  /// A crossed cloud.
  cloudOff(Icons.cloud_off),

  /// A sync problem.
  syncProblem(Icons.sync_problem),

  /// Sync turned off.
  syncDisabled(Icons.sync_disabled),

  /// A locked network.
  networkLocked(Icons.network_locked),

  /// Bluetooth turned off.
  bluetoothDisabled(Icons.bluetooth_disabled),

  /// Location turned off.
  locationOff(Icons.location_off),

  /// A crossed globe.
  publicOff(Icons.public_off),

  /// An exclamation mark in a circle, outline.
  errorOutline(Icons.error_outline),

  /// A warning triangle.
  warning(Icons.warning_amber),

  /// A report-problem triangle.
  reportProblem(Icons.report_problem_outlined),

  /// A blocked sign.
  blocked(Icons.block),

  /// A question mark.
  help(Icons.help_outline),

  /// An hourglass.
  hourglass(Icons.hourglass_empty),

  /// A padlock.
  locked(Icons.lock_outline);

  const CYLPlaceholderStyle(this.icon);

  /// The icon drawn for this style.
  final IconData icon;
}

/// The item keys shared with the iOS and Android placeholder (the values of the `CYLPlaceholderItem...` constants).
abstract final class CYLPlaceholderItemKey {
  /// The title (`CYLPlaceholderItemTitle`).
  static const String title = 'CYLTabBarItemTitle';

  /// The message below the title (`CYLPlaceholderItemMessage`).
  static const String message = 'CYLPlaceholderItemMessage';

  /// The icon style, by index or by name (`CYLPlaceholderItemStyle`).
  static const String style = 'CYLPlaceholderItemStyle';

  /// The animation file (`CYLPlaceholderItemAnimationURL`).
  static const String animationURL = 'CYLTabBarAnimationURL';

  /// The animation's width and height (`CYLPlaceholderItemAnimationSize`).
  static const String animationSize = 'CYLTabBarAnimationSize';

  /// The title color, `#RRGGBB` or `#AARRGGBB` (`CYLPlaceholderItemTitleColor`).
  static const String titleColor = 'CYLTabBarItemTitleColor';

  /// The icon color, `#RRGGBB` or `#AARRGGBB` (`CYLPlaceholderItemIconColor`).
  static const String iconColor = 'CYLTabBarItemIconColor';

  /// The background color, `#RRGGBB` or `#AARRGGBB` (`CYLPlaceholderItemBackgroundColor`).
  static const String backgroundColor = 'CYLTabBarItemBackgroundColor';
}

/// An error or empty placeholder: an icon (or an animation played by CYLTabBarController's `CYLAnimationView`), a
/// title and a message, with an optional tap, like iOS and Android `CYLPlaceholderView`.
class CYLPlaceholderView extends StatelessWidget {
  /// Creates a placeholder of an icon [style] and a [title] / [message]. An [animationFile] replaces the icon.
  const CYLPlaceholderView({
    super.key,
    this.style = CYLPlaceholderStyle.empty,
    this.title,
    this.message,
    this.image,
    this.animationFile,
    this.animationOptions = const {},
    this.animationSize = const Size(120, 120),
    this.animationPlaying = true,
    this.titleColor,
    this.iconColor,
    this.backgroundColor,
    this.titleStyle,
    this.imageSize = 96,
    this.tapHandler,
    this.tapInteractionEnabled = true,
  });

  /// Reads the item keys of [CYLPlaceholderItemKey] from [attributes]; unknown keys are ignored.
  factory CYLPlaceholderView.fromItemAttributes(
    Map<String, Object?> attributes, {
    VoidCallback? tapHandler,
  }) {
    Color? color(String key) {
      final value = attributes[key];
      if (value is int) return Color(value);
      if (value is String) {
        final hex = value.replaceFirst('#', '');
        final parsed = int.tryParse(hex, radix: 16);
        if (parsed == null) return null;
        return Color(hex.length <= 6 ? 0xFF000000 | parsed : parsed);
      }
      return null;
    }

    final rawStyle = attributes[CYLPlaceholderItemKey.style];
    var style = CYLPlaceholderStyle.empty;
    if (rawStyle is int && rawStyle >= 0 && rawStyle < CYLPlaceholderStyle.values.length) {
      style = CYLPlaceholderStyle.values[rawStyle];
    } else if (rawStyle is String) {
      style = CYLPlaceholderStyle.values.where((value) => value.name == rawStyle).firstOrNull ?? style;
    }
    final rawSize = attributes[CYLPlaceholderItemKey.animationSize];
    var size = const Size(120, 120);
    if (rawSize is List && rawSize.length == 2) size = Size((rawSize[0] as num).toDouble(), (rawSize[1] as num).toDouble());
    return CYLPlaceholderView(
      style: style,
      title: attributes[CYLPlaceholderItemKey.title] as String?,
      message: attributes[CYLPlaceholderItemKey.message] as String?,
      animationFile: attributes[CYLPlaceholderItemKey.animationURL] as String?,
      animationSize: size,
      titleColor: color(CYLPlaceholderItemKey.titleColor),
      iconColor: color(CYLPlaceholderItemKey.iconColor),
      backgroundColor: color(CYLPlaceholderItemKey.backgroundColor),
      tapHandler: tapHandler,
    );
  }

  /// The built-in icon, used when [image] and [animationFile] are null.
  final CYLPlaceholderStyle style;

  /// The title, or null for none.
  final String? title;

  /// The message below the title, or null for none.
  final String? message;

  /// Replaces the icon.
  final Widget? image;

  /// An animation file played by `CYLAnimationView` (Rive, Lottie, PAG, GIF, SVGA); replaces the icon.
  final String? animationFile;

  /// The options of [animationFile], e.g. Rive's `artboard`, `stateMachine`, `input`.
  final Map<String, Object> animationOptions;

  /// The size of the animation.
  final Size animationSize;

  /// Whether the animation plays.
  final bool animationPlaying;

  /// The color of the title and the message, or null for the theme's.
  final Color? titleColor;

  /// The color of the built-in icon, or null for the theme's.
  final Color? iconColor;

  /// The background color, or null for none.
  final Color? backgroundColor;

  /// The style of the title.
  final TextStyle? titleStyle;

  /// The size of the built-in icon.
  final double imageSize;

  /// Called when the placeholder is tapped (retry).
  final VoidCallback? tapHandler;

  /// False: [tapHandler] is ignored.
  final bool tapInteractionEnabled;

  /// The item keys this placeholder was made from, like `itemAttributes` on iOS and Android.
  Map<String, Object> get itemAttributes => {
        CYLPlaceholderItemKey.style: style.name,
        CYLPlaceholderItemKey.title: ?title,
        CYLPlaceholderItemKey.message: ?message,
        CYLPlaceholderItemKey.animationURL: ?animationFile,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = titleColor ?? theme.colorScheme.onSurfaceVariant;
    Widget picture;
    if (animationFile != null) {
      picture = SizedBox(
        width: animationSize.width,
        height: animationSize.height,
        child: CYLAnimationView(file: animationFile!, options: animationOptions, playing: animationPlaying),
      );
    } else {
      picture = image ?? Icon(style.icon, size: imageSize, color: iconColor ?? theme.colorScheme.outline);
    }
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        picture,
        if (title != null) ...[
          const SizedBox(height: 16),
          Text(title!, textAlign: TextAlign.center, style: titleStyle ?? theme.textTheme.titleMedium?.copyWith(color: textColor)),
        ],
        if (message != null) ...[
          const SizedBox(height: 8),
          Text(message!, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: textColor)),
        ],
      ],
    );
    if (tapHandler != null && tapInteractionEnabled) {
      content = GestureDetector(behavior: HitTestBehavior.opaque, onTap: tapHandler, child: content);
    }
    return Container(
      color: backgroundColor,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: content,
    );
  }
}
