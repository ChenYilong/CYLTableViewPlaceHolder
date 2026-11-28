import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Maps how far past the edge the user has dragged (a fraction of the viewport, 0 for none) to the share of the
/// finger's movement the content follows. The default is `(1 - fraction)^2 * 0.52`, like iOS.
typedef CYLRefreshFrictionFactor = double Function(double overscrollFraction);

/// Builds the spring that pulls the content back (to the edge, or to the open indicator) after a release.
typedef CYLRefreshSpringBuilder = SpringDescription Function();

/// Bouncing scroll physics with the parameters a refresh needs: the friction of the pull on each axis and a limit of
/// how far each end may be pulled.
class CYLRefreshPhysics extends BouncingScrollPhysics {
  /// Creates the physics; [maxHeaderPull] and [maxFooterPull] of 0 mean no limit.
  const CYLRefreshPhysics({
    super.parent,
    this.frictionFactorOf,
    this.horizontalFrictionFactorOf,
    this.maxHeaderPull = 0,
    this.maxFooterPull = 0,
    this.readySpringBuilder,
    this.horizontalReadySpringBuilder,
    this.springRebound = true,
    this.springOverride,
  });

  /// The friction of a vertical pull, or null for the default.
  final CYLRefreshFrictionFactor? frictionFactorOf;

  /// The friction of a horizontal pull, or null for the default.
  final CYLRefreshFrictionFactor? horizontalFrictionFactorOf;

  /// The farthest the start of the content may be pulled, 0 for no limit.
  final double maxHeaderPull;

  /// The farthest the end of the content may be pulled, 0 for no limit.
  final double maxFooterPull;

  /// The vertical spring used after a release; null keeps the bouncing default.
  final CYLRefreshSpringBuilder? readySpringBuilder;

  /// The horizontal spring used after a release; null keeps the bouncing default.
  final CYLRefreshSpringBuilder? horizontalReadySpringBuilder;

  /// False: the content does not spring past the edge when a fling reaches it (no rebound).
  final bool springRebound;

  /// The spring a [createBallisticSimulation] of this axis chose; set on the copy only.
  final SpringDescription? springOverride;

  @override
  SpringDescription get spring => springOverride ?? super.spring;

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    if (springOverride == null) {
      final builder = position.axis == Axis.horizontal ? horizontalReadySpringBuilder : readySpringBuilder;
      if (builder != null) {
        return CYLRefreshPhysics(
          parent: parent,
          frictionFactorOf: frictionFactorOf,
          horizontalFrictionFactorOf: horizontalFrictionFactorOf,
          maxHeaderPull: maxHeaderPull,
          maxFooterPull: maxFooterPull,
          readySpringBuilder: readySpringBuilder,
          horizontalReadySpringBuilder: horizontalReadySpringBuilder,
          springRebound: springRebound,
          springOverride: builder(),
        ).createBallisticSimulation(position, velocity);
      }
    }
    if (!springRebound && !position.outOfRange) {
      // A fling stops at the edge instead of springing past it.
      if (velocity.abs() < toleranceFor(position).velocity) return null;
      return _ClampedSimulation(
        ClampingScrollSimulation(position: position.pixels, velocity: velocity, tolerance: toleranceFor(position)),
        position.minScrollExtent,
        position.maxScrollExtent,
      );
    }
    return super.createBallisticSimulation(position, velocity);
  }
  @override
  CYLRefreshPhysics applyTo(ScrollPhysics? ancestor) => CYLRefreshPhysics(
        parent: buildParent(ancestor),
        frictionFactorOf: frictionFactorOf,
        horizontalFrictionFactorOf: horizontalFrictionFactorOf,
        maxHeaderPull: maxHeaderPull,
        maxFooterPull: maxFooterPull,
        readySpringBuilder: readySpringBuilder,
        horizontalReadySpringBuilder: horizontalReadySpringBuilder,
        springRebound: springRebound,
        springOverride: springOverride,
      );

  double _friction(Axis axis, double fraction) {
    final custom = axis == Axis.horizontal ? horizontalFrictionFactorOf : frictionFactorOf;
    return custom != null ? custom(fraction) : frictionFactor(fraction);
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    if (!position.outOfRange) return offset;
    final pastStart = math.max(position.minScrollExtent - position.pixels, 0.0);
    final pastEnd = math.max(position.pixels - position.maxScrollExtent, 0.0);
    final past = math.max(pastStart, pastEnd);
    final easing = (pastStart > 0.0 && offset < 0.0) || (pastEnd > 0.0 && offset > 0.0);
    if (!easing) {
      if (pastStart > 0 && maxHeaderPull > 0 && pastStart >= maxHeaderPull) return 0;
      if (pastEnd > 0 && maxFooterPull > 0 && pastEnd >= maxFooterPull) return 0;
    }
    final friction = _friction(position.axis, (easing ? past - offset.abs() : past) / position.viewportDimension);
    final direction = offset.sign;
    var absDelta = offset.abs();
    var total = 0.0;
    if (past > 0) {
      final deltaToLimit = past / friction;
      if (absDelta < deltaToLimit) return direction * absDelta * friction;
      total += past;
      absDelta -= deltaToLimit;
    }
    return direction * (total + absDelta);
  }
}

/// Runs [inner] but never leaves `[min, max]`: it ends at the edge it reaches.
class _ClampedSimulation extends Simulation {
  _ClampedSimulation(this.inner, this.min, this.max) : super(tolerance: inner.tolerance);

  final Simulation inner;
  final double min;
  final double max;

  @override
  double x(double time) => inner.x(time).clamp(min, max);

  @override
  double dx(double time) {
    final raw = inner.x(time);
    return raw < min || raw > max ? 0 : inner.dx(time);
  }

  @override
  bool isDone(double time) {
    final raw = inner.x(time);
    return inner.isDone(time) || (raw <= min && inner.dx(time) < 0) || (raw >= max && inner.dx(time) > 0);
  }
}
