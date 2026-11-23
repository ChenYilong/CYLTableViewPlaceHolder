import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_cyltabbar/flutter_cyltabbar.dart';

import 'component.dart';
import 'refresh_types.dart';

/// Describes a Rive file that draws a refresh indicator, with the names of the iOS and Android `CYLRefreshRiveStyle`.
///
/// The file is played by CYLTabBarController's `CYLAnimationView` (no Rive library here), so only what its contract can
/// express is applied: the file, [artboardName], [stateMachineName], [loadingBoolean] (as the `input` option) and
/// [releaseTrigger] (as `triggerInput`), plus scrubbing the file with the pull. The other inputs are kept as data and need
/// an upstream request (see docs/Refresh-Library-Parity.md).
class CYLRefreshRiveStyle {
  /// Creates a style for the Rive file [fileURL] (a file name in the app, a path or a URL).
  CYLRefreshRiveStyle({
    required this.fileURL,
    this.artboardName,
    this.stateMachineName,
    this.triggerOffset = 180,
    this.minimumHeight = 0,
    this.fitsWidth = false,
    this.pullInput,
    this.pullInputMinimum = 0,
    this.pullInputMaximum = 100,
    this.pullInputStart = 0,
    this.pullInputRefreshingValue = -1,
    this.releaseTrigger,
    this.finishTrigger,
    this.restartTrigger,
    this.loadingBoolean,
    this.loadingNumber,
    this.loadingNumberMaximum = 99,
    this.loadingNumberFinished = 100,
    this.loadingNumberDuration = 2,
    this.pullAnimation,
    this.triggerAnimation,
    this.loadingAnimation,
    this.idleAnimation,
  });

  /// The Rive file.
  final String fileURL;

  /// The artboard to draw, or null for the file's default.
  String? artboardName;

  /// The state machine to play, or null.
  String? stateMachineName;

  /// The pull, in logical pixels, that arms the refresh.
  double triggerOffset;

  /// The smallest height of the indicator.
  double minimumHeight;

  /// True: the artboard fits the width instead of covering the area (kept as data: upstream's view covers).
  bool fitsWidth;

  /// The number input the pull is written to (kept as data: needs an upstream request).
  String? pullInput;

  /// The pull input's value at no pull.
  double pullInputMinimum;

  /// The pull input's value at the full pull.
  double pullInputMaximum;

  /// The pull input's first value.
  double pullInputStart;

  /// The pull input's value while refreshing, -1 to keep the last.
  double pullInputRefreshingValue;

  /// The trigger fired on release; passed as the `triggerInput` option.
  String? releaseTrigger;

  /// The trigger fired when refreshing ends (kept as data).
  String? finishTrigger;

  /// The trigger fired to start over (kept as data).
  String? restartTrigger;

  /// The boolean set while loading; passed as the `input` option.
  String? loadingBoolean;

  /// The number input that counts while loading (kept as data).
  String? loadingNumber;

  /// The loading number's value before the end (kept as data).
  double loadingNumberMaximum;

  /// The loading number's value at the end (kept as data).
  double loadingNumberFinished;

  /// How long the loading number counts, in seconds (kept as data).
  double loadingNumberDuration;

  /// The options of `CYLAnimationView` this style asks for.
  /// The linear animation scrubbed with the pull (for a file without a state machine).
  String? pullAnimation;

  /// The linear animation that plays when the pull passes the trigger offset.
  String? triggerAnimation;

  /// The linear animation that plays while refreshing.
  String? loadingAnimation;

  /// The linear animation shown at rest (and scrubbed with the pull when there is no [pullAnimation]).
  String? idleAnimation;

  /// The options of the file for `CYLAnimationView` at rest; see [animationOptionsFor] while refreshing.
  Map<String, Object> get animationOptions => animationOptionsFor(refreshing: false);

  /// The options of the file: the linear animation to play (`animation`, upstream's Rive option) for the phase.
  Map<String, Object> animationOptionsFor({required bool refreshing}) => {
        'animation': ?(refreshing ? (loadingAnimation ?? idleAnimation ?? pullAnimation) : (idleAnimation ?? pullAnimation)),
        ..._stateMachineOptions,
      };

  Map<String, Object> get _stateMachineOptions => {
        'artboard': ?artboardName,
        'stateMachine': ?stateMachineName,
        'input': ?loadingBoolean,
        'triggerInput': ?releaseTrigger,
      };
}

/// The progress of the file for a pull: 0 at rest, 1 when the pull reaches the style's trigger offset.
double cylRefreshRiveProgress(CYLRefreshRiveStyle style, double dragOffset) =>
    style.triggerOffset <= 0 ? 0 : math.min(1, math.max(0, dragOffset / style.triggerOffset));

/// Draws a Rive style for a component: the file is scrubbed with the pull, then plays while refreshing.
class CYLRefreshRiveIndicator extends StatefulWidget {
  /// Creates an indicator for [component] with [style].
  const CYLRefreshRiveIndicator({super.key, required this.component, required this.style});

  /// The component the indicator draws for.
  final CYLRefreshComponent component;

  /// The Rive file and its inputs.
  final CYLRefreshRiveStyle style;

  @override
  State<CYLRefreshRiveIndicator> createState() => _CYLRefreshRiveIndicatorState();
}

class _CYLRefreshRiveIndicatorState extends State<CYLRefreshRiveIndicator> {
  final CYLAnimationController _controller = CYLAnimationController();
  CYLRefreshPhase? _lastPhase;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    widget.component.addListener(_changed);
  }

  @override
  void dispose() {
    widget.component.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    final component = widget.component;
    final phase = component.phase;
    final refreshing = component.isRefreshing;
    if (refreshing != _refreshing && widget.style.loadingAnimation != null && mounted) {
      setState(() => _refreshing = refreshing);
    }
    if (phase == CYLRefreshPhase.refreshing && _lastPhase != CYLRefreshPhase.refreshing) {
      _controller.play();
    } else if (component.state == CYLRefreshState.pulling || phase == CYLRefreshPhase.idle) {
      _controller.stopAtProgress(cylRefreshRiveProgress(widget.style, component.dragOffset));
    }
    _lastPhase = phase;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      excludeSemantics: true,
      child: SizedBox(
        height: math.max(widget.style.minimumHeight, widget.component.expandHeight),
        child: CYLAnimationView(
          file: widget.style.fileURL,
          options: widget.style.animationOptionsFor(refreshing: _refreshing),
          drivesAnimationPlayback: false,
          controller: _controller,
        ),
      ),
    );
  }
}

/// A header drawn by a Rive file (`CYLRefreshRiveHeader`).
class CYLRefreshRiveHeader extends CYLRefreshHeader {
  /// Creates a header for [style]; its [CYLRefreshRiveStyle.triggerOffset] is the expand height.
  CYLRefreshRiveHeader({required this.style, super.refreshingHandler, super.finishDuration, super.scrollMode, super.triggersWhenReached})
      : super(expandHeight: style.triggerOffset);

  /// The Rive file and its inputs.
  final CYLRefreshRiveStyle style;

  @override
  Widget buildIndicator(BuildContext context) => CYLRefreshRiveIndicator(component: this, style: style);
}

/// A footer drawn by a Rive file (`CYLRefreshDrawnFooter`).
class CYLRefreshDrawnFooter extends CYLRefreshBackFooter {
  /// Creates a footer for [style]; its [CYLRefreshRiveStyle.triggerOffset] is the expand height.
  CYLRefreshDrawnFooter({required this.style, super.refreshingHandler, super.finishDuration, super.scrollMode, super.loadsAfterNoMoreData})
      : super(expandHeight: style.triggerOffset);

  /// The Rive file and its inputs.
  final CYLRefreshRiveStyle style;

  @override
  Widget buildIndicator(BuildContext context) => CYLRefreshRiveIndicator(component: this, style: style);
}
