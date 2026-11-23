import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cyltabbar/flutter_cyltabbar.dart';

import '../placeholder/cyl_placeholder_stack.dart';

/// The look of the HUD, like the iOS and Android `CYLPlaceholderHUDStyle`.
enum CYLPlaceholderHUDStyle {
  /// Follows the theme's brightness.
  automatic,

  /// A light HUD with dark content.
  light,

  /// A dark HUD with light content.
  dark,

  /// Uses [CYLPlaceholderHUD.foregroundColor] and [CYLPlaceholderHUD.backgroundColor].
  custom,
}

/// What lies behind the HUD, like the iOS and Android `CYLPlaceholderHUDMaskType`.
enum CYLPlaceholderHUDMaskType {
  /// Nothing: touches reach the content below.
  none,

  /// A transparent mask that blocks touches.
  clear,

  /// A black translucent mask.
  black,

  /// A radial gradient mask.
  gradient,

  /// Uses [CYLPlaceholderHUD.maskColor].
  custom,
}

/// What the HUD shows, like the iOS and Android `CYLPlaceholderHUDState`.
enum CYLPlaceholderHUDState {
  /// Not shown.
  hidden,

  /// A spinner.
  loading,

  /// A progress bar.
  progress,

  /// The success icon.
  success,

  /// The error icon.
  error,

  /// The info icon.
  info,

  /// A custom image.
  image,

  /// Your components.
  custom,
}

/// Called after the HUD hid.
typedef CYLPlaceholderHUDDismissCompletion = void Function();

/// The HUD, the Flutter form of the iOS and Android `CYLPlaceholderHUD` (the SVProgressHUD-style API): the model that holds
/// the configuration and the state. Draw it with a [CYLPlaceholderHUDHost] around your content, and call `dispose` with it.
class CYLPlaceholderHUD extends ChangeNotifier {
  /// Creates a hidden HUD.
  CYLPlaceholderHUD();

  /// The look.
  CYLPlaceholderHUDStyle style = CYLPlaceholderHUDStyle.automatic;

  /// What lies behind the HUD.
  CYLPlaceholderHUDMaskType maskType = CYLPlaceholderHUDMaskType.none;

  /// The mask color for [CYLPlaceholderHUDMaskType.custom].
  Color maskColor = const Color(0x66000000);

  /// The content color for [CYLPlaceholderHUDStyle.custom].
  Color foregroundColor = Colors.white;

  /// The HUD color for [CYLPlaceholderHUDStyle.custom].
  Color backgroundColor = const Color(0xDD000000);

  /// The text size.
  double fontSize = 15;

  /// The corner radius.
  double cornerRadius = 14;

  /// The smallest size of the HUD.
  Size minimumSize = const Size(100, 100);

  /// The side of the spinner, icon or animation.
  double animationSize = 56;

  /// The animation file shown while loading, or null for the spinner.
  String? loadingAnimationFileName;

  /// The animation file shown with progress, or null for the progress bar.
  String? progressAnimationFileName;

  /// The animation file shown on success, or null for the icon.
  String? successAnimationFileName;

  /// Replaces the success icon.
  Widget? successImage;

  /// Replaces the error icon.
  Widget? errorImage;

  /// Replaces the info icon.
  Widget? infoImage;

  /// How long [show] waits before the HUD appears, in seconds; a shorter task never shows it.
  double graceTimeInterval = 0;

  /// The shortest time a timed HUD stays, in seconds.
  double minimumDismissTimeInterval = 1.5;

  /// The longest time a timed HUD stays, in seconds.
  double maximumDismissTimeInterval = 5;

  /// The fade-in time, in seconds.
  double fadeInAnimationDuration = 0.15;

  /// The fade-out time, in seconds.
  double fadeOutAnimationDuration = 0.15;

  /// True: success and error vibrate.
  bool hapticsEnabled = false;

  CYLPlaceholderHUDState _state = CYLPlaceholderHUDState.hidden;
  String? _status;
  double _progress = 0;
  int _activityCount = 0;
  Widget? _image;
  List<CYLPlaceholderComponent> _components = const [];
  String? _animationFile;
  Timer? _graceTimer;
  Timer? _dismissTimer;
  bool _disposed = false;

  /// What the HUD shows.
  CYLPlaceholderHUDState get state => _state;

  /// The status text, or null.
  String? get status => _status;

  /// The progress, 0 to 1.
  double get progress => _progress;

  /// Whether the HUD is shown.
  bool get visible => _state != CYLPlaceholderHUDState.hidden;

  /// How many [show] calls are open; [popActivity] ends one.
  int get activityCount => _activityCount;

  /// The image of a timed HUD, or null.
  Widget? get image => _image;

  /// The components of a custom HUD.
  List<CYLPlaceholderComponent> get components => _components;

  /// The animation file in use, or null.
  String? get animationFile => _animationFile;

  /// Shows a spinner (`show`).
  void show() => showWithStatus(null);

  /// Shows a spinner with [status] (`showWithStatus`).
  void showWithStatus(String? status) {
    if (_disposed) return;
    _activityCount++;
    void start() {
      _graceTimer = null;
      _present(CYLPlaceholderHUDState.loading, status: status, animation: loadingAnimationFileName);
    }

    if (graceTimeInterval > 0 && !visible) {
      _graceTimer?.cancel();
      _graceTimer = Timer(Duration(milliseconds: (graceTimeInterval * 1000).round()), start);
    } else {
      start();
    }
  }

  /// Shows a progress bar at [progress], 0 to 1, with [status] (`showProgress`).
  void showProgress(double progress, [String? status]) {
    if (_disposed) return;
    _progress = progress.clamp(0.0, 1.0);
    _present(CYLPlaceholderHUDState.progress, status: status ?? _status, animation: progressAnimationFileName);
  }

  /// Changes the status text in place (`setStatus`).
  void setStatus(String? status) {
    _status = status;
    notifyListeners();
  }

  /// Shows the info icon with [status], then hides (`showInfoWithStatus`).
  void showInfoWithStatus(String? status) => _showTimed(CYLPlaceholderHUDState.info, infoImage ?? const Icon(Icons.info_outline), status);

  /// Shows the success icon with [status], then hides (`showSuccessWithStatus`).
  void showSuccessWithStatus(String? status) =>
      _showTimed(CYLPlaceholderHUDState.success, successImage ?? const Icon(Icons.check_circle_outline), status, animation: successAnimationFileName);

  /// Shows the error icon with [status], then hides (`showErrorWithStatus`).
  void showErrorWithStatus(String? status) => _showTimed(CYLPlaceholderHUDState.error, errorImage ?? const Icon(Icons.error_outline), status);

  /// Shows [image] with [status], then hides (`showImage`).
  void showImage(Widget? image, String? status) => _showTimed(CYLPlaceholderHUDState.image, image, status);

  /// Shows your [components] until [dismiss] (`showComponents`).
  void showComponents(List<CYLPlaceholderComponent> components) {
    if (_disposed) return;
    _components = components;
    _present(CYLPlaceholderHUDState.custom, status: null, animation: null);
  }

  /// Ends one [show]; the HUD hides once every one has ended (`popActivity`).
  void popActivity() {
    if (_activityCount > 0) _activityCount--;
    if (_activityCount == 0) dismiss();
  }

  /// Hides at once (`dismiss`).
  void dismiss() => dismissWithDelay(0);

  /// Hides, then calls [completion] (`dismissWithCompletion`).
  void dismissWithCompletion(CYLPlaceholderHUDDismissCompletion? completion) => dismissWithDelay(0, completion);

  /// Hides after [delay] seconds, then calls [completion] (`dismissWithDelay`).
  void dismissWithDelay(double delay, [CYLPlaceholderHUDDismissCompletion? completion]) {
    if (_disposed) return;
    _dismissTimer?.cancel();
    _graceTimer?.cancel();
    _graceTimer = null;
    _dismissTimer = Timer(Duration(milliseconds: (delay * 1000).round()), () {
      _dismissTimer = null;
      _activityCount = 0;
      _state = CYLPlaceholderHUDState.hidden;
      _image = null;
      notifyListeners();
      completion?.call();
    });
  }

  /// How long a timed HUD with [string] stays, in seconds (`displayDurationForString`).
  double displayDurationForString(String? string) =>
      math.min(math.max((string?.length ?? 0) * 0.06 + 0.5, minimumDismissTimeInterval), maximumDismissTimeInterval);

  void _present(CYLPlaceholderHUDState state, {required String? status, required String? animation}) {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _state = state;
    _status = status;
    _animationFile = animation;
    _image = null;
    notifyListeners();
  }

  void _showTimed(CYLPlaceholderHUDState state, Widget? image, String? status, {String? animation}) {
    if (_disposed) return;
    _activityCount = 0;
    _graceTimer?.cancel();
    _graceTimer = null;
    _present(state, status: status, animation: animation);
    _image = image;
    notifyListeners();
    if (hapticsEnabled && (state == CYLPlaceholderHUDState.success || state == CYLPlaceholderHUDState.error)) {
      HapticFeedback.mediumImpact();
    }
    _dismissTimer = Timer(Duration(milliseconds: (displayDurationForString(status) * 1000).round()), () => dismiss());
  }

  @override
  void dispose() {
    _disposed = true;
    _graceTimer?.cancel();
    _dismissTimer?.cancel();
    super.dispose();
  }
}

/// Draws a [CYLPlaceholderHUD] over [child]: the mask, then the HUD centered, faded in and out. The HUD is one
/// accessibility element read as its status and announced politely when it appears.
class CYLPlaceholderHUDHost extends StatelessWidget {
  /// Creates a host for [hud] around [child].
  const CYLPlaceholderHUDHost({super.key, required this.hud, required this.child});

  /// The HUD to draw.
  final CYLPlaceholderHUD hud;

  /// The content below the HUD.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        child,
        ListenableBuilder(
          listenable: hud,
          builder: (context, _) => _layer(context),
        ),
      ],
    );
  }

  Widget _layer(BuildContext context) {
    final visible = hud.visible;
    final dark = switch (hud.style) {
      CYLPlaceholderHUDStyle.dark => true,
      CYLPlaceholderHUDStyle.light => false,
      CYLPlaceholderHUDStyle.custom => false,
      CYLPlaceholderHUDStyle.automatic => Theme.of(context).brightness == Brightness.light,
    };
    final background = hud.style == CYLPlaceholderHUDStyle.custom ? hud.backgroundColor : (dark ? const Color(0xDD000000) : const Color(0xEEF2F2F7));
    final foreground = hud.style == CYLPlaceholderHUDStyle.custom ? hud.foregroundColor : (dark ? Colors.white : Colors.black87);
    final blocks = hud.maskType != CYLPlaceholderHUDMaskType.none;
    final fade = Duration(milliseconds: ((visible ? hud.fadeInAnimationDuration : hud.fadeOutAnimationDuration) * 1000).round());
    // The mask is the only layer that blocks touches, and only for a mask type other than none; the HUD itself stays in
    // the accessibility tree while it is shown.
    return Positioned.fill(
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: fade,
        child: Stack(
          fit: StackFit.expand,
          children: [
            IgnorePointer(ignoring: !visible || !blocks, child: DecoratedBox(decoration: _mask())),
            if (visible)
              Center(
                child: Semantics(
                  liveRegion: true,
                  container: true,
                  excludeSemantics: true,
                  label: hud.status,
                  value: hud.state == CYLPlaceholderHUDState.progress ? '${(hud.progress * 100).round()}%' : null,
                  child: _hud(context, background, foreground),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Decoration _mask() => switch (hud.maskType) {
        CYLPlaceholderHUDMaskType.none || CYLPlaceholderHUDMaskType.clear => const BoxDecoration(),
        CYLPlaceholderHUDMaskType.black => const BoxDecoration(color: Color(0x66000000)),
        CYLPlaceholderHUDMaskType.gradient => const BoxDecoration(gradient: RadialGradient(colors: [Color(0x00000000), Color(0x99000000)], radius: 1)),
        CYLPlaceholderHUDMaskType.custom => BoxDecoration(color: hud.maskColor),
      };

  Widget _hud(BuildContext context, Color background, Color foreground) {
    if (hud.state == CYLPlaceholderHUDState.custom) {
      return Material(
        color: background,
        borderRadius: BorderRadius.circular(hud.cornerRadius),
        child: CYLPlaceholderStackView(components: hud.components),
      );
    }
    final side = hud.animationSize;
    Widget picture;
    final file = hud.animationFile;
    if (file != null) {
      picture = SizedBox(width: side, height: side, child: CYLAnimationView(file: file, playing: true, animationLoops: hud.state == CYLPlaceholderHUDState.loading));
    } else {
      picture = switch (hud.state) {
        CYLPlaceholderHUDState.loading => SizedBox(width: side * 0.6, height: side * 0.6, child: CircularProgressIndicator(color: foreground, strokeWidth: 3)),
        CYLPlaceholderHUDState.progress => SizedBox(width: side * 1.6, child: LinearProgressIndicator(value: hud.progress, color: foreground, backgroundColor: foreground.withValues(alpha: 0.25))),
        _ => IconTheme(data: IconThemeData(size: side * 0.8, color: foreground), child: hud.image ?? const SizedBox.shrink()),
      };
    }
    return Container(
      constraints: BoxConstraints(minWidth: hud.minimumSize.width, minHeight: hud.minimumSize.height, maxWidth: 280),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(hud.cornerRadius)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          picture,
          if (hud.status != null && hud.status!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(hud.status!, textAlign: TextAlign.center, style: TextStyle(color: foreground, fontSize: hud.fontSize, decoration: TextDecoration.none)),
          ],
        ],
      ),
    );
  }
}
