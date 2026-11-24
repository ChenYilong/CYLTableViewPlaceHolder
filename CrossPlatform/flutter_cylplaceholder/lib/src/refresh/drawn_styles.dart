import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'component.dart';
import 'native_refresh.dart';
import 'refresh_types.dart';

/// What a drawn style paints for one frame.
class CYLRefreshDrawnFrame {
  /// Creates a frame.
  const CYLRefreshDrawnFrame({
    required this.pull,
    required this.dragOffset,
    required this.phase,
    required this.loop,
    required this.isHeader,
    required this.noMoreData,
    required this.succeeded,
    required this.foreground,
    required this.background,
  });

  /// The pull as a fraction of the trigger offset: 1 means armed, more is overshoot.
  final double pull;

  /// The pull in logical pixels.
  final double dragOffset;

  /// The component's phase.
  final CYLRefreshPhase phase;

  /// The looping animation value, 0 to 1, running while refreshing.
  final double loop;

  /// True for a header (the area grows downwards from the top edge), false for a footer (upwards from the bottom edge).
  final bool isHeader;

  /// True when a footer has no more data.
  final bool noMoreData;

  /// Whether the last refresh succeeded.
  final bool succeeded;

  /// The drawing color.
  final Color foreground;

  /// The background color.
  final Color background;

  /// True while releasing, refreshing or finishing.
  bool get refreshing => phase == CYLRefreshPhase.releasing || phase == CYLRefreshPhase.refreshing;

  /// True while the result shows.
  bool get finishing => phase == CYLRefreshPhase.finishing;

  /// True when the pull is past the trigger.
  bool get armed => phase == CYLRefreshPhase.releaseToRefresh;
}

/// Paints a [CYLRefreshDrawnFrame]; a painter that has a direction (a curved edge) reads [CYLRefreshDrawnFrame.isHeader].
typedef CYLRefreshDrawnPaint = void Function(Canvas canvas, Size size, CYLRefreshDrawnFrame frame);

/// The widget behind every drawn style: a `CustomPaint` that repaints with the component and with a looping animation that
/// runs while the component refreshes. It is a decoration: the accessibility tree gets the `semanticsLabel` instead.
class CYLRefreshDrawnIndicator extends StatefulWidget {
  /// Creates an indicator that paints [paint] for [component].
  const CYLRefreshDrawnIndicator({
    super.key,
    required this.component,
    required this.paint,
    this.foreground = const Color(0xFFFFFFFF),
    this.background = const Color(0xFF2196F3),
    this.loopDuration = const Duration(milliseconds: 1200),
    this.semanticsLabel,
  });

  /// The component to draw.
  final CYLRefreshComponent component;

  /// The painter of the style.
  final CYLRefreshDrawnPaint paint;

  /// The drawing color.
  final Color foreground;

  /// The background color.
  final Color background;

  /// The length of one pass of the loop.
  final Duration loopDuration;

  /// What a screen reader says for the indicator, or null for nothing.
  final String? semanticsLabel;

  @override
  State<CYLRefreshDrawnIndicator> createState() => _CYLRefreshDrawnIndicatorState();
}

class _CYLRefreshDrawnIndicatorState extends State<CYLRefreshDrawnIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _loop = AnimationController(vsync: this, duration: widget.loopDuration);

  @override
  void initState() {
    super.initState();
    widget.component.addListener(_sync);
    _sync();
  }

  @override
  void dispose() {
    widget.component.removeListener(_sync);
    _loop.dispose();
    super.dispose();
  }

  void _sync() {
    final running = widget.component.isRefreshing || widget.component.phase == CYLRefreshPhase.releaseToRefresh;
    if (running && !_loop.isAnimating) {
      _loop.repeat();
    } else if (!running && _loop.isAnimating) {
      _loop.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final component = widget.component;
    Widget child = ListenableBuilder(
      listenable: Listenable.merge([component, _loop]),
      builder: (context, _) {
        final frame = CYLRefreshDrawnFrame(
          pull: component.pullingPercent,
          dragOffset: component.dragOffset,
          phase: component.phase,
          loop: _loop.value,
          isHeader: component.isHeader,
          noMoreData: component.isNoMoreData,
          succeeded: component.lastRefreshSucceeded,
          foreground: widget.foreground,
          background: widget.background,
        );
        return CustomPaint(
          size: Size.infinite,
          painter: _DrawnPainter(frame, widget.paint),
        );
      },
    );
    child = Semantics(label: widget.semanticsLabel, excludeSemantics: true, container: widget.semanticsLabel != null, child: child);
    return SizedBox.expand(child: child);
  }
}

class _DrawnPainter extends CustomPainter {
  _DrawnPainter(this.frame, this.paintFrame);

  final CYLRefreshDrawnFrame frame;
  final CYLRefreshDrawnPaint paintFrame;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    paintFrame(canvas, size, frame);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_DrawnPainter old) =>
      old.frame.pull != frame.pull || old.frame.phase != frame.phase || old.frame.loop != frame.loop || old.frame.noMoreData != frame.noMoreData || old.frame.succeeded != frame.succeeded;
}

/// The curved background shared by the Bezier styles: a band whose lower edge bulges with the pull and flattens while
/// refreshing.
void cylRefreshPaintBezierBackground(Canvas canvas, Size size, CYLRefreshDrawnFrame frame) {
  final depth = frame.refreshing || frame.finishing ? 0.0 : math.min(36.0, size.height * 0.28);
  final bottom = size.height - depth;
  final path = Path()
    ..moveTo(0, 0)
    ..lineTo(size.width, 0)
    ..lineTo(size.width, bottom)
    ..quadraticBezierTo(size.width / 2, size.height + depth * 0.4, 0, bottom)
    ..close();
  canvas.save();
  if (!frame.isHeader) {
    // A footer's curve bulges upwards from the bottom edge.
    canvas.translate(0, size.height);
    canvas.scale(1, -1);
  }
  canvas.drawPath(path, Paint()..color = frame.background);
  canvas.restore();
}

/// Seven balls that fan out with the pull and fade as it is armed (the radar of the Bezier header).
void cylRefreshPaintRadarBalls(Canvas canvas, Size size, CYLRefreshDrawnFrame frame) {
  if (frame.refreshing || frame.finishing || frame.noMoreData) return;
  final scale = frame.pull.clamp(0.0, 1.0);
  final radius = math.min(6.0, frame.dragOffset / 2);
  final area = math.min(400.0, size.width);
  final center = Offset(size.width / 2, size.height / 2);
  for (var i = 0; i < 7; i++) {
    final opacity = (1 - (0.8 / 3) * (i - 3).abs()) * scale * (frame.armed ? 0.6 + 0.4 * math.sin(frame.loop * math.pi * 2) : 1);
    canvas.drawCircle(
      center.translate(area / 8 * scale * (i - 3), 0),
      radius,
      Paint()..color = frame.foreground.withValues(alpha: opacity.clamp(0.0, 1.0)),
    );
  }
}

/// An hourglass that turns while refreshing, drawn with two triangles.
void cylRefreshPaintHourGlass(Canvas canvas, Size size, CYLRefreshDrawnFrame frame, {double side = 28}) {
  final center = Offset(size.width / 2, size.height / 2);
  canvas.save();
  canvas.translate(center.dx, center.dy);
  canvas.rotate(math.pi * (frame.loop < 0.5 ? frame.loop * 2 : 1) );
  final half = side / 2;
  final paint = Paint()..color = frame.foreground;
  canvas.drawPath(Path()..moveTo(-half, -half)..lineTo(half, -half)..lineTo(0, 0)..close(), paint);
  final filled = frame.loop < 0.5 ? 1 - frame.loop * 2 : 0.0;
  canvas.drawPath(
    Path()
      ..moveTo(-half * (1 - filled), half)
      ..lineTo(half * (1 - filled), half)
      ..lineTo(0, 0)
      ..close(),
    paint,
  );
  canvas.restore();
}

/// The Bezier radar style: the curved band, the balls while pulling, the hourglass while refreshing.
void cylRefreshPaintBezierRadar(Canvas canvas, Size size, CYLRefreshDrawnFrame frame) {
  cylRefreshPaintBezierBackground(canvas, size, frame);
  cylRefreshPaintRadarBalls(canvas, size, frame);
  if (frame.refreshing || frame.armed) {
    cylRefreshPaintHourGlass(canvas, size, frame);
  } else if (frame.finishing) {
    _paintMark(canvas, size, frame);
  } else if (frame.noMoreData) {
    _paintDash(canvas, size, frame);
  }
}

/// The Bezier circle style: the curved band with a drop that grows into a circle and a ring that sweeps while refreshing.
void cylRefreshPaintBezierCircle(Canvas canvas, Size size, CYLRefreshDrawnFrame frame) {
  cylRefreshPaintBezierBackground(canvas, size, frame);
  final center = Offset(size.width / 2, size.height / 2);
  final grow = frame.pull.clamp(0.0, 1.0);
  final radius = 6 + 12 * grow;
  final paint = Paint()
    ..color = frame.foreground
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..strokeCap = StrokeCap.round;
  if (frame.refreshing) {
    canvas.drawArc(Rect.fromCircle(center: center, radius: 16), frame.loop * math.pi * 2, math.pi * 1.5, false, paint);
  } else if (frame.finishing) {
    _paintMark(canvas, size, frame);
  } else {
    canvas.drawCircle(center, radius, Paint()..color = frame.foreground.withValues(alpha: 0.3 + 0.7 * grow));
  }
}

/// The Delivery style: a parcel truck that drives in with the pull and keeps driving, with speed lines, while refreshing.
void cylRefreshPaintDelivery(Canvas canvas, Size size, CYLRefreshDrawnFrame frame) {
  canvas.drawRect(Offset.zero & size, Paint()..color = frame.background);
  final ground = size.height * 0.78;
  canvas.drawLine(Offset(0, ground), Offset(size.width, ground), Paint()..color = frame.foreground.withValues(alpha: 0.5)..strokeWidth = 2);
  final travel = frame.refreshing ? (frame.loop * 2 - 1).abs() : frame.pull.clamp(0.0, 1.0);
  final x = 16 + (size.width - 96) * travel;
  final paint = Paint()..color = frame.foreground;
  final h = math.min(size.height * 0.45, 34.0);
  canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, ground - h - 6, 48, h), const Radius.circular(3)), paint);
  canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x + 50, ground - h * 0.7 - 6, 22, h * 0.7), const Radius.circular(3)), paint);
  final wheel = Paint()..color = frame.background;
  for (final dx in [12.0, 36.0, 62.0]) {
    canvas.drawCircle(Offset(x + dx, ground - 4), 6, paint);
    canvas.drawCircle(Offset(x + dx, ground - 4), 3, wheel);
  }
  if (frame.refreshing) {
    for (var i = 0; i < 3; i++) {
      final y = ground - h - 4 + i * 10;
      canvas.drawLine(Offset(x - 6 - i * 4, y), Offset(x - 22 - i * 6 - 8 * frame.loop, y), Paint()..color = frame.foreground.withValues(alpha: 0.5)..strokeWidth = 2);
    }
  }
  if (frame.finishing) _paintMark(canvas, size, frame);
}

/// The Phoenix style: a sun that rises with the pull and a bird whose wings flap while refreshing.
void cylRefreshPaintPhoenix(Canvas canvas, Size size, CYLRefreshDrawnFrame frame) {
  canvas.drawRect(
    Offset.zero & size,
    Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [frame.background, Color.lerp(frame.background, const Color(0xFFFFB74D), 0.6)!]).createShader(Offset.zero & size),
  );
  final rise = frame.refreshing || frame.finishing ? 1.0 : frame.pull.clamp(0.0, 1.0);
  final sun = Offset(size.width * 0.72, size.height * (1.05 - 0.55 * rise));
  canvas.drawCircle(sun, 14, Paint()..color = const Color(0xFFFFE082));
  final center = Offset(size.width / 2, size.height / 2);
  final flap = frame.refreshing ? math.sin(frame.loop * math.pi * 2) : (frame.pull.clamp(0.0, 1.0) * 0.6);
  final wing = 18.0 + 6 * flap;
  final lift = (frame.refreshing ? -4 * flap : 0.0);
  final stroke = Paint()
    ..color = frame.foreground
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..strokeCap = StrokeCap.round;
  final bird = Path()
    ..moveTo(center.dx - wing, center.dy + lift - 6 * flap)
    ..quadraticBezierTo(center.dx - wing / 2, center.dy + lift - 12 * (0.4 + flap), center.dx, center.dy + lift)
    ..quadraticBezierTo(center.dx + wing / 2, center.dy + lift - 12 * (0.4 + flap), center.dx + wing, center.dy + lift - 6 * flap);
  canvas.drawPath(bird, stroke);
  if (frame.finishing) _paintMark(canvas, size, frame);
}

/// The Taurus style: a bull that runs across scrolling clouds while refreshing, drawn from blocks.
void cylRefreshPaintTaurus(Canvas canvas, Size size, CYLRefreshDrawnFrame frame) {
  canvas.drawRect(Offset.zero & size, Paint()..color = frame.background);
  final ground = size.height * 0.8;
  final cloud = Paint()..color = frame.foreground.withValues(alpha: 0.35);
  final shift = frame.refreshing ? frame.loop * size.width : frame.pull.clamp(0.0, 1.0) * 40;
  for (var i = 0; i < 3; i++) {
    final x = ((i * size.width / 2.2 - shift) % (size.width + 60)) - 30;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, size.height * (0.2 + 0.12 * (i % 2)), 44, 12), const Radius.circular(6)), cloud);
  }
  canvas.drawLine(Offset(0, ground), Offset(size.width, ground), Paint()..color = frame.foreground..strokeWidth = 2);
  final step = frame.refreshing ? math.sin(frame.loop * math.pi * 8) : 0.0;
  final x = size.width / 2 - 24;
  final paint = Paint()..color = frame.foreground;
  final scale = (0.6 + 0.4 * frame.pull.clamp(0.0, 1.0));
  canvas.save();
  canvas.translate(x, ground);
  canvas.scale(scale);
  canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0, -26, 40, 18), const Radius.circular(5)), paint);
  canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(34, -32, 16, 14), const Radius.circular(4)), paint);
  canvas.drawPath(Path()..moveTo(36, -30)..lineTo(30, -40)..lineTo(40, -33)..close(), paint);
  canvas.drawPath(Path()..moveTo(48, -30)..lineTo(54, -40)..lineTo(46, -33)..close(), paint);
  canvas.drawLine(Offset(6, -8), Offset(6 + 5 * step, 0), Paint()..color = frame.foreground..strokeWidth = 4);
  canvas.drawLine(Offset(32, -8), Offset(32 - 5 * step, 0), Paint()..color = frame.foreground..strokeWidth = 4);
  canvas.restore();
  if (frame.finishing) _paintMark(canvas, size, frame);
}

void _paintMark(Canvas canvas, Size size, CYLRefreshDrawnFrame frame) {
  final c = Offset(size.width / 2, size.height / 2);
  final paint = Paint()
    ..color = frame.foreground
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..strokeCap = StrokeCap.round;
  if (frame.succeeded) {
    canvas.drawPath(Path()..moveTo(c.dx - 9, c.dy)..lineTo(c.dx - 3, c.dy + 7)..lineTo(c.dx + 9, c.dy - 7), paint);
  } else {
    canvas.drawLine(c.translate(-7, -7), c.translate(7, 7), paint);
    canvas.drawLine(c.translate(-7, 7), c.translate(7, -7), paint);
  }
}

void _paintDash(Canvas canvas, Size size, CYLRefreshDrawnFrame frame) {
  final c = Offset(size.width / 2, size.height / 2);
  canvas.drawLine(c.translate(-10, 0), c.translate(10, 0), Paint()..color = frame.foreground..strokeWidth = 3..strokeCap = StrokeCap.round);
}

Widget _indicator(CYLRefreshComponent c, CYLRefreshDrawnPaint paint, Color foreground, Color background, String? label, {Duration loop = const Duration(milliseconds: 1200)}) =>
    CYLRefreshDrawnIndicator(component: c, paint: paint, foreground: foreground, background: background, loopDuration: loop, semanticsLabel: label);

/// The Bezier radar header.
class CYLRefreshBezierRadarHeader extends CYLRefreshHeader {
  /// Creates a header; [foregroundColor] and [backgroundColor] default to white on blue.
  CYLRefreshBezierRadarHeader({super.refreshingHandler, super.expandHeight = 100, super.finishDuration, super.scrollMode, this.foregroundColor = const Color(0xFFFFFFFF), this.backgroundColor = const Color(0xFF2196F3)}) {
    stretchIndicator = true;
  }

  /// The drawing color.
  final Color foregroundColor;

  /// The background color.
  final Color backgroundColor;

  @override
  Widget buildIndicator(BuildContext context) =>
      CYLNativeRefreshIndicator.supports(this) ? CYLNativeRefreshIndicator(component: this, style: 'bezierRadar') : _indicator(this, cylRefreshPaintBezierRadar, foregroundColor, backgroundColor, null);
}

/// The Bezier radar footer.
class CYLRefreshBezierRadarFooter extends CYLRefreshBackFooter {
  /// Creates a footer; [foregroundColor] and [backgroundColor] default to white on blue.
  CYLRefreshBezierRadarFooter({super.refreshingHandler, super.expandHeight = 100, super.finishDuration, super.scrollMode, super.loadsAfterNoMoreData, this.foregroundColor = const Color(0xFFFFFFFF), this.backgroundColor = const Color(0xFF2196F3)}) {
    stretchIndicator = true;
  }

  /// The drawing color.
  final Color foregroundColor;

  /// The background color.
  final Color backgroundColor;

  @override
  Widget buildIndicator(BuildContext context) =>
      CYLNativeRefreshIndicator.supports(this) ? CYLNativeRefreshIndicator(component: this, style: 'bezierRadar') : _indicator(this, cylRefreshPaintBezierRadar, foregroundColor, backgroundColor, null);
}

/// The Bezier circle header.
class CYLRefreshBezierCircleHeader extends CYLRefreshHeader {
  /// Creates a header; [foregroundColor] and [backgroundColor] default to white on blue.
  CYLRefreshBezierCircleHeader({super.refreshingHandler, super.expandHeight = 100, super.finishDuration, super.scrollMode, this.foregroundColor = const Color(0xFFFFFFFF), this.backgroundColor = const Color(0xFF2196F3)}) {
    stretchIndicator = true;
  }

  /// The drawing color.
  final Color foregroundColor;

  /// The background color.
  final Color backgroundColor;

  @override
  Widget buildIndicator(BuildContext context) =>
      CYLNativeRefreshIndicator.supports(this) ? CYLNativeRefreshIndicator(component: this, style: 'bezierCircle') : _indicator(this, cylRefreshPaintBezierCircle, foregroundColor, backgroundColor, null);
}

/// The Delivery header.
class CYLRefreshDeliveryHeader extends CYLRefreshHeader {
  /// Creates a header; [foregroundColor] and [backgroundColor] default to white on teal.
  CYLRefreshDeliveryHeader({super.refreshingHandler, super.expandHeight = 100, super.finishDuration, super.scrollMode, this.foregroundColor = const Color(0xFFFFFFFF), this.backgroundColor = const Color(0xFF26A69A)}) {
    stretchIndicator = true;
  }

  /// The drawing color.
  final Color foregroundColor;

  /// The background color.
  final Color backgroundColor;

  @override
  Widget buildIndicator(BuildContext context) =>
      CYLNativeRefreshIndicator.supports(this) ? CYLNativeRefreshIndicator(component: this, style: 'delivery') : _indicator(this, cylRefreshPaintDelivery, foregroundColor, backgroundColor, null);
}

/// The Delivery footer.
class CYLRefreshDeliveryFooter extends CYLRefreshBackFooter {
  /// Creates a footer; [foregroundColor] and [backgroundColor] default to white on teal.
  CYLRefreshDeliveryFooter({super.refreshingHandler, super.expandHeight = 100, super.finishDuration, super.scrollMode, super.loadsAfterNoMoreData, this.foregroundColor = const Color(0xFFFFFFFF), this.backgroundColor = const Color(0xFF26A69A)}) {
    stretchIndicator = true;
  }

  /// The drawing color.
  final Color foregroundColor;

  /// The background color.
  final Color backgroundColor;

  @override
  Widget buildIndicator(BuildContext context) =>
      CYLNativeRefreshIndicator.supports(this) ? CYLNativeRefreshIndicator(component: this, style: 'delivery') : _indicator(this, cylRefreshPaintDelivery, foregroundColor, backgroundColor, null);
}

/// The Phoenix header.
class CYLRefreshPhoenixHeader extends CYLRefreshHeader {
  /// Creates a header; [foregroundColor] and [backgroundColor] default to white on indigo.
  CYLRefreshPhoenixHeader({super.refreshingHandler, super.expandHeight = 100, super.finishDuration, super.scrollMode, this.foregroundColor = const Color(0xFFFFFFFF), this.backgroundColor = const Color(0xFF3949AB)}) {
    stretchIndicator = true;
  }

  /// The drawing color.
  final Color foregroundColor;

  /// The background color.
  final Color backgroundColor;

  @override
  Widget buildIndicator(BuildContext context) =>
      CYLNativeRefreshIndicator.supports(this) ? CYLNativeRefreshIndicator(component: this, style: 'phoenix') : _indicator(this, cylRefreshPaintPhoenix, foregroundColor, backgroundColor, null, loop: const Duration(milliseconds: 700));
}

/// The Phoenix footer.
class CYLRefreshPhoenixFooter extends CYLRefreshBackFooter {
  /// Creates a footer; [foregroundColor] and [backgroundColor] default to white on indigo.
  CYLRefreshPhoenixFooter({super.refreshingHandler, super.expandHeight = 100, super.finishDuration, super.scrollMode, super.loadsAfterNoMoreData, this.foregroundColor = const Color(0xFFFFFFFF), this.backgroundColor = const Color(0xFF3949AB)}) {
    stretchIndicator = true;
  }

  /// The drawing color.
  final Color foregroundColor;

  /// The background color.
  final Color backgroundColor;

  @override
  Widget buildIndicator(BuildContext context) =>
      CYLNativeRefreshIndicator.supports(this) ? CYLNativeRefreshIndicator(component: this, style: 'phoenix') : _indicator(this, cylRefreshPaintPhoenix, foregroundColor, backgroundColor, null, loop: const Duration(milliseconds: 700));
}

/// The Taurus header.
class CYLRefreshTaurusHeader extends CYLRefreshHeader {
  /// Creates a header; [foregroundColor] and [backgroundColor] default to dark on sky.
  CYLRefreshTaurusHeader({super.refreshingHandler, super.expandHeight = 100, super.finishDuration, super.scrollMode, this.foregroundColor = const Color(0xFF263238), this.backgroundColor = const Color(0xFF81D4FA)}) {
    stretchIndicator = true;
  }

  /// The drawing color.
  final Color foregroundColor;

  /// The background color.
  final Color backgroundColor;

  @override
  Widget buildIndicator(BuildContext context) =>
      CYLNativeRefreshIndicator.supports(this) ? CYLNativeRefreshIndicator(component: this, style: 'taurus') : _indicator(this, cylRefreshPaintTaurus, foregroundColor, backgroundColor, null, loop: const Duration(milliseconds: 1600));
}

/// The Taurus footer.
class CYLRefreshTaurusFooter extends CYLRefreshBackFooter {
  /// Creates a footer; [foregroundColor] and [backgroundColor] default to dark on sky.
  CYLRefreshTaurusFooter({super.refreshingHandler, super.expandHeight = 100, super.finishDuration, super.scrollMode, super.loadsAfterNoMoreData, this.foregroundColor = const Color(0xFF263238), this.backgroundColor = const Color(0xFF81D4FA)}) {
    stretchIndicator = true;
  }

  /// The drawing color.
  final Color foregroundColor;

  /// The background color.
  final Color backgroundColor;

  @override
  Widget buildIndicator(BuildContext context) =>
      CYLNativeRefreshIndicator.supports(this) ? CYLNativeRefreshIndicator(component: this, style: 'taurus') : _indicator(this, cylRefreshPaintTaurus, foregroundColor, backgroundColor, null, loop: const Duration(milliseconds: 1600));
}
