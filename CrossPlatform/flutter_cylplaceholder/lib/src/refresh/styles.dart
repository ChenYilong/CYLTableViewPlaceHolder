import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../placeholder/native_backend.dart';
import 'component.dart';
import 'native_refresh.dart';
import 'refresh_types.dart';

/// Builds the title of a classic indicator from its default text.
typedef CYLRefreshTextBuilder = Widget Function(BuildContext context, CYLRefreshComponent component, String text);

/// The look and texts shared by the classic header and footers: an arrow or spinner, a title and, for a header, the
/// time of the last update.
mixin CYLRefreshClassicStyle on CYLRefreshComponent {
  final Map<CYLRefreshTitleState, String> _titles = {};

  /// The shown when no text was set for a state.
  Map<CYLRefreshTitleState, String> get defaultTitles;

  /// Sets the text shown in [state].
  void setTitle(String text, CYLRefreshTitleState state) {
    _titles[state] = text;
    notifyListeners();
  }

  /// The text shown in [state].
  String titleForState(CYLRefreshTitleState state) => _titles[state] ?? defaultTitles[state] ?? '';

  /// The title of the current state.
  String get currentTitle {
    if (isNoMoreData) return titleForState(CYLRefreshTitleState.noMoreData);
    switch (phase) {
      case CYLRefreshPhase.idle:
      case CYLRefreshPhase.pullToRefresh:
        return titleForState(CYLRefreshTitleState.pullToRefresh);
      case CYLRefreshPhase.releaseToRefresh:
        return titleForState(CYLRefreshTitleState.releaseToRefresh);
      case CYLRefreshPhase.releasing:
      case CYLRefreshPhase.refreshing:
        return titleForState(CYLRefreshTitleState.refreshing);
      case CYLRefreshPhase.finishing:
        return titleForState(lastRefreshSucceeded ? CYLRefreshTitleState.succeeded : CYLRefreshTitleState.failed);
    }
  }

  /// Shown instead of the spinner after a successful refresh.
  Widget? succeededImage;

  /// Shown instead of the spinner after a failed refresh.
  Widget? failedImage;

  /// Shown instead of the arrow when the footer has no more data.
  Widget? noMoreDataImage;

  /// True: the icon is on the right of the text.
  bool iconOnTrailingSide = false;

  /// The width and height of the icon.
  double iconSize = 20;

  /// The space between the icon and the text.
  double iconSpacing = 12;

  /// Draws the arrow shown while pulling instead of the default one.
  CYLRefreshIndicatorBuilder? pullIconBuilder;

  /// The style of the title.
  TextStyle? titleStyle;

  /// Draws the title instead of the default [Text].
  CYLRefreshTextBuilder? textBuilder;

  /// The second line (the last update time of a header), or null for none.
  String? messageText() => null;

  /// Draws the second line instead of the default [Text].
  CYLRefreshTextBuilder? messageBuilder;

  Widget _icon(BuildContext context) {
    final color = colorAccent ?? colorPrimary ?? DefaultTextStyle.of(context).style.color ?? const Color(0xFF666666);
    Widget icon;
    if (isNoMoreData) {
      icon = noMoreDataImage ?? const SizedBox.shrink();
    } else if (phase == CYLRefreshPhase.finishing) {
      icon = (lastRefreshSucceeded ? succeededImage : failedImage) ??
          Icon(lastRefreshSucceeded ? Icons.done : Icons.error_outline, size: iconSize, color: color);
    } else if (isRefreshing) {
      icon = CupertinoActivityIndicator(radius: iconSize / 2.5);
    } else {
      final armed = phase == CYLRefreshPhase.releaseToRefresh;
      final arrow = pullIconBuilder?.call(context, this) ?? Icon(isHeader ? Icons.arrow_downward : Icons.arrow_upward, size: iconSize, color: color);
      icon = AnimatedRotation(turns: armed ? 0.5 : 0, duration: const Duration(milliseconds: 200), child: arrow);
    }
    return SizedBox(width: iconSize, height: iconSize, child: Center(child: icon));
  }

  @override
  Widget buildIndicator(BuildContext context) {
    final title = currentTitle;
    final message = messageText();
    final style = titleStyle ?? DefaultTextStyle.of(context).style.copyWith(fontSize: 14);
    final texts = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        textBuilder?.call(context, this, title) ?? Text(title, style: style),
        if (message != null) messageBuilder?.call(context, this, message) ?? Text(message, style: style.copyWith(fontSize: 11)),
      ],
    );
    final children = [_icon(context), SizedBox(width: iconSpacing), texts];
    return Center(
      child: Row(mainAxisSize: MainAxisSize.min, children: iconOnTrailingSide ? children.reversed.toList() : children),
    );
  }
}

/// The classic header: an arrow that flips, a spinner, a title and the time of the last refresh.
class CYLRefreshClassicHeader extends CYLRefreshHeader with CYLRefreshClassicStyle {
  /// Creates a classic header; see [CYLRefreshComponent] for the shared arguments.
  CYLRefreshClassicHeader({
    super.refreshingHandler,
    super.refreshEnabled,
    super.expandHeight,
    super.triggerRate,
    super.finishDuration,
    super.scrollMode,
    super.triggerMode,
    super.triggersWhenReached,
    super.maxPullDistance,
    super.hapticFeedback,
    super.notifiesWhenHidden,
    super.exclusiveWithOtherRefresh,
    super.defaultOverOffset,
    super.colorAccent,
    super.colorPrimary,
    super.resetsFooterAfterRefresh,
    this.showsLastUpdatedTime = true,
    this.lastUpdatedTimeText,
    this.lastUpdatedTimeFormatter,
  });

  @override
  Map<CYLRefreshTitleState, String> get defaultTitles => const {
        CYLRefreshTitleState.pullToRefresh: 'Pull down to refresh',
        CYLRefreshTitleState.releaseToRefresh: 'Release to refresh',
        CYLRefreshTitleState.refreshing: 'Refreshing...',
        CYLRefreshTitleState.succeeded: 'Refresh complete',
        CYLRefreshTitleState.failed: 'Refresh failed',
      };

  /// False: no second line.
  bool showsLastUpdatedTime;

  /// Builds the whole second line from the time of the last refresh (null before the first).
  String Function(DateTime? time)? lastUpdatedTimeText;

  /// Formats the time of the second line; the default is `Last updated: HH:mm`.
  String Function(DateTime time)? lastUpdatedTimeFormatter;

  /// Whether the native header draws this one: the native half is on, and nothing asks for what only Flutter can draw (a
  /// custom builder, text, icon or image).
  bool get _usesNative =>
      CYLPlaceholderNative.enabled &&
      builder == null &&
      textBuilder == null &&
      messageBuilder == null &&
      pullIconBuilder == null &&
      succeededImage == null &&
      failedImage == null;

  @override
  Widget buildIndicator(BuildContext context) => _usesNative ? CYLNativeRefreshIndicator(component: this) : super.buildIndicator(context);

  @override
  String? messageText() {
    if (!showsLastUpdatedTime) return null;
    final time = lastUpdatedTime;
    if (lastUpdatedTimeText != null) return lastUpdatedTimeText!(time);
    if (time == null) return 'Not updated yet';
    if (lastUpdatedTimeFormatter != null) return lastUpdatedTimeFormatter!(time);
    String two(int v) => v.toString().padLeft(2, '0');
    return 'Last updated: ${two(time.hour)}:${two(time.minute)}';
  }
}

const Map<CYLRefreshTitleState, String> _footerTitles = {
  CYLRefreshTitleState.pullToRefresh: 'Pull up to load more',
  CYLRefreshTitleState.releaseToRefresh: 'Release to load more',
  CYLRefreshTitleState.refreshing: 'Loading...',
  CYLRefreshTitleState.succeeded: 'Load complete',
  CYLRefreshTitleState.failed: 'Load failed',
  CYLRefreshTitleState.noMoreData: 'No more data',
};

/// The classic footer, pulled up past the end: an arrow, a spinner and a title.
class CYLRefreshClassicFooter extends CYLRefreshBackFooter with CYLRefreshClassicStyle {
  /// Creates a classic footer; see [CYLRefreshComponent] for the shared arguments.
  CYLRefreshClassicFooter({
    super.refreshingHandler,
    super.refreshEnabled,
    super.expandHeight,
    super.triggerRate,
    super.finishDuration,
    super.scrollMode,
    super.triggerMode,
    super.triggersWhenReached,
    super.maxPullDistance,
    super.hapticFeedback,
    super.notifiesWhenHidden,
    super.exclusiveWithOtherRefresh,
    super.defaultOverOffset,
    super.colorAccent,
    super.colorPrimary,
    super.loadsAfterNoMoreData,
  });

  @override
  Map<CYLRefreshTitleState, String> get defaultTitles => _footerTitles;
}

/// The classic footer that loads by itself at the end of the content.
class CYLRefreshClassicAutoFooter extends CYLRefreshAutoFooter with CYLRefreshClassicStyle {
  /// Creates a classic auto footer; see [CYLRefreshAutoFooter].
  CYLRefreshClassicAutoFooter({
    super.refreshingHandler,
    super.refreshEnabled,
    super.expandHeight,
    super.triggerRate,
    super.finishDuration,
    super.scrollMode,
    super.hapticFeedback,
    super.notifiesWhenHidden,
    super.exclusiveWithOtherRefresh,
    super.colorAccent,
    super.colorPrimary,
    super.loadsAfterNoMoreData,
    super.automaticallyRefresh,
    super.triggerAutomaticallyRefreshPercent,
    super.autoTriggerTimes,
  });

  @override
  Map<CYLRefreshTitleState, String> get defaultTitles => _footerTitles;
}

Widget _cupertino(CYLRefreshComponent c, BuildContext context) {
  final radius = 12.0;
  if (c.isRefreshing || c.phase == CYLRefreshPhase.finishing) {
    return Center(child: CupertinoActivityIndicator(radius: radius, color: c.colorPrimary));
  }
  return Center(child: CupertinoActivityIndicator.partiallyRevealed(radius: radius, progress: math.min(1, c.pullingPercent), color: c.colorPrimary));
}

/// A header with the iOS activity indicator that reveals as you pull.
class CYLRefreshCupertinoHeader extends CYLRefreshHeader {
  /// Creates a Cupertino header; see [CYLRefreshComponent] for the shared arguments.
  CYLRefreshCupertinoHeader({
    super.refreshingHandler,
    super.refreshEnabled,
    super.expandHeight = 50,
    super.triggerRate,
    super.finishDuration,
    super.scrollMode,
    super.triggerMode,
    super.triggersWhenReached,
    super.maxPullDistance,
    super.hapticFeedback,
    super.notifiesWhenHidden,
    super.exclusiveWithOtherRefresh,
    super.defaultOverOffset,
    super.colorAccent,
    super.colorPrimary,
    super.resetsFooterAfterRefresh,
  });

  @override
  Widget buildIndicator(BuildContext context) => _cupertino(this, context);
}

/// A footer with the iOS activity indicator that reveals as you pull.
class CYLRefreshCupertinoFooter extends CYLRefreshBackFooter {
  /// Creates a Cupertino footer; see [CYLRefreshComponent] for the shared arguments.
  CYLRefreshCupertinoFooter({
    super.refreshingHandler,
    super.refreshEnabled,
    super.expandHeight = 50,
    super.triggerRate,
    super.finishDuration,
    super.scrollMode,
    super.triggerMode,
    super.triggersWhenReached,
    super.maxPullDistance,
    super.hapticFeedback,
    super.notifiesWhenHidden,
    super.exclusiveWithOtherRefresh,
    super.defaultOverOffset,
    super.colorAccent,
    super.colorPrimary,
    super.loadsAfterNoMoreData,
  });

  @override
  Widget buildIndicator(BuildContext context) =>
      isNoMoreData ? const Center(child: Text('No more data', style: TextStyle(fontSize: 13))) : _cupertino(this, context);
}

Widget _material(CYLRefreshComponent c, BuildContext context) {
  final busy = c.isRefreshing || c.phase == CYLRefreshPhase.finishing;
  final color = c.colorPrimary ?? Theme.of(context).colorScheme.primary;
  return Center(
    child: Material(
      type: MaterialType.circle,
      elevation: 2,
      color: c.colorAccent ?? Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5, color: color, value: busy ? null : math.min(1, c.pullingPercent)),
        ),
      ),
    ),
  );
}

/// A header with a Material circular progress indicator.
class CYLRefreshMaterialHeader extends CYLRefreshHeader {
  /// Creates a Material header; see [CYLRefreshComponent] for the shared arguments.
  CYLRefreshMaterialHeader({
    super.refreshingHandler,
    super.refreshEnabled,
    super.expandHeight = 56,
    super.triggerRate,
    super.finishDuration,
    super.scrollMode,
    super.triggerMode,
    super.triggersWhenReached,
    super.maxPullDistance,
    super.hapticFeedback,
    super.notifiesWhenHidden,
    super.exclusiveWithOtherRefresh,
    super.defaultOverOffset,
    super.colorAccent,
    super.colorPrimary,
    super.resetsFooterAfterRefresh,
  });

  @override
  Widget buildIndicator(BuildContext context) => _material(this, context);
}

/// A footer with a Material circular progress indicator.
class CYLRefreshMaterialFooter extends CYLRefreshBackFooter {
  /// Creates a Material footer; see [CYLRefreshComponent] for the shared arguments.
  CYLRefreshMaterialFooter({
    super.refreshingHandler,
    super.refreshEnabled,
    super.expandHeight = 56,
    super.triggerRate,
    super.finishDuration,
    super.scrollMode,
    super.triggerMode,
    super.triggersWhenReached,
    super.maxPullDistance,
    super.hapticFeedback,
    super.notifiesWhenHidden,
    super.exclusiveWithOtherRefresh,
    super.defaultOverOffset,
    super.colorAccent,
    super.colorPrimary,
    super.loadsAfterNoMoreData,
  });

  @override
  Widget buildIndicator(BuildContext context) =>
      isNoMoreData ? const Center(child: Text('No more data', style: TextStyle(fontSize: 13))) : _material(this, context);
}
