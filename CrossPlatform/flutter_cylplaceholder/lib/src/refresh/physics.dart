import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Maps how far past the edge the user has dragged (a fraction of the viewport, 0 for none) to the share of the
/// finger's movement the content follows. The default is `(1 - fraction)^2 * 0.52`, like iOS.
typedef CYLRefreshFrictionFactor = double Function(double overscrollFraction);

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
  });

  /// The friction of a vertical pull, or null for the default.
  final CYLRefreshFrictionFactor? frictionFactorOf;

  /// The friction of a horizontal pull, or null for the default.
  final CYLRefreshFrictionFactor? horizontalFrictionFactorOf;

  /// The farthest the start of the content may be pulled, 0 for no limit.
  final double maxHeaderPull;

  /// The farthest the end of the content may be pulled, 0 for no limit.
  final double maxFooterPull;

  @override
  CYLRefreshPhysics applyTo(ScrollPhysics? ancestor) => CYLRefreshPhysics(
        parent: buildParent(ancestor),
        frictionFactorOf: frictionFactorOf,
        horizontalFrictionFactorOf: horizontalFrictionFactorOf,
        maxHeaderPull: maxHeaderPull,
        maxFooterPull: maxFooterPull,
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
