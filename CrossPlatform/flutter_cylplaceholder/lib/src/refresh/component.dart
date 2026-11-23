import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'refresh_types.dart';

/// Called when a component starts refreshing; the caller ends it with [CYLRefreshComponent.endRefreshing].
typedef CYLRefreshHandler = void Function();

/// Called when a component's phase changes.
typedef CYLRefreshPhaseObserver = void Function(CYLRefreshComponent component, CYLRefreshPhase phase, CYLRefreshPhase oldPhase);

/// Draws an indicator for a component, which notifies its listeners on every change.
typedef CYLRefreshIndicatorBuilder = Widget Function(BuildContext context, CYLRefreshComponent component);

/// What a [CYLRefreshComponent] needs to know about the widget that owns it.
abstract interface class CYLRefreshHost {
  /// Whether a component other than [component] is refreshing.
  bool isOtherRefreshing(CYLRefreshComponent component);
}

/// The base of every header and footer: a long-lived [ChangeNotifier] that holds the configuration and the state,
/// like the iOS and Android components. Create it in `initState`, pass it to `CYLRefresh` and call `dispose`.
///
/// The caller always ends refreshing with [endRefreshing] (there is no switch for it, as on iOS); the component
/// stays in [CYLRefreshPhase.refreshing] until then.
abstract class CYLRefreshComponent extends ChangeNotifier {
  /// Creates a component; every named argument sets the property of the same name.
  CYLRefreshComponent({
    this.refreshingHandler,
    this.builder,
    this.refreshEnabled = true,
    this.expandHeight = 60,
    this.triggerRate = 1,
    this.finishDuration = const Duration(milliseconds: 600),
    this.scrollMode = CYLRefreshScrollMode.move,
    this.triggerMode = CYLRefreshTriggerMode.anywhere,
    this.triggersWhenReached = false,
    this.maxPullDistance = 0,
    this.hapticFeedback = false,
    this.notifiesWhenHidden = false,
    this.exclusiveWithOtherRefresh = true,
    this.defaultOverOffset = 20,
    this.colorAccent,
    this.colorPrimary,
  });

  /// Whether this is the header (pulled down at the top); false for a footer (pulled up at the bottom).
  bool get isHeader;

  /// Called when the component starts refreshing; call [endRefreshing] when the work is done.
  CYLRefreshHandler? refreshingHandler;

  /// Draws the indicator; subclasses override [buildIndicator] instead.
  CYLRefreshIndicatorBuilder? builder;

  /// False: the component never refreshes (`NotRefreshHeader` / `NotLoadFooter`).
  bool refreshEnabled;

  /// The height the indicator holds while refreshing.
  double expandHeight;

  /// The pull needed to arm the refresh is [expandHeight] times this rate.
  double triggerRate;

  /// How long the result stays visible after [endRefreshing].
  Duration finishDuration;

  /// How the indicator moves with the pull.
  CYLRefreshScrollMode scrollMode;

  /// Where a pull may start.
  CYLRefreshTriggerMode triggerMode;

  /// True: refresh as soon as the trigger offset is reached, without waiting for the release.
  bool triggersWhenReached;

  /// The farthest the content may be pulled, 0 for no limit.
  double maxPullDistance;

  /// Vibrate when the pull passes the trigger offset.
  bool hapticFeedback;

  /// True: notify the listeners on every scroll update, even while the indicator is hidden (lets a drawing-free
  /// component follow the scroll position). False (the default here): only while it is visible.
  bool notifiesWhenHidden;

  /// True: do not start while another component of the same `CYLRefresh` is refreshing.
  bool exclusiveWithOtherRefresh;

  /// The over-offset [beginRefreshing] uses when none is passed.
  double defaultOverOffset;

  /// The second floor: a view opened by pulling past [secondaryTriggerOffset] and releasing, instead of refreshing. null
  /// (the default) means no second floor.
  Widget? secondaryView;

  /// The pull, in logical pixels, past which a release opens the second floor; larger than [triggerOffset].
  double secondaryTriggerOffset = 120;

  /// The extent of the open second floor along the pull axis, or 0 for the whole viewport.
  double secondaryDimension = 0;

  /// While the second floor is open, scrolling the content back by this many logical pixels closes it.
  double secondaryCloseTriggerOffset = 60;

  /// Called after the second floor opened.
  VoidCallback? secondaryOpenedBlock;

  /// Called after the second floor closed.
  VoidCallback? secondaryClosedBlock;

  /// The accent color of the indicator, or null for the theme's.
  Color? colorAccent;

  /// The primary color of the indicator, or null for the theme's.
  Color? colorPrimary;

  /// The pull, in logical pixels, that arms the refresh: [expandHeight] times [triggerRate].
  double get triggerOffset => expandHeight * triggerRate;

  CYLRefreshPhase _phase = CYLRefreshPhase.idle;
  double _pullingPercent = 0;
  double _dragOffset = 0;
  bool _lastRefreshSucceeded = true;
  bool _noMoreData = false;
  bool _disposed = false;
  bool _wantsBegin = false;
  bool _secondaryOpen = false;
  bool _secondaryArmed = false;
  Timer? _finishTimer;
  CYLRefreshHost? _host;
  final List<CYLRefreshPhaseObserver> _observers = [];

  /// The detailed phase.
  CYLRefreshPhase get phase => _phase;

  /// The coarse state.
  CYLRefreshState get state {
    if (_noMoreData) return CYLRefreshState.noMoreData;
    switch (_phase) {
      case CYLRefreshPhase.idle:
        return CYLRefreshState.idle;
      case CYLRefreshPhase.pullToRefresh:
      case CYLRefreshPhase.releaseToRefresh:
        return CYLRefreshState.pulling;
      case CYLRefreshPhase.releasing:
      case CYLRefreshPhase.refreshing:
      case CYLRefreshPhase.finishing:
        return CYLRefreshState.refreshing;
    }
  }

  /// How far the pull is past the trigger offset: 1 means armed.
  double get pullingPercent => _pullingPercent;

  /// The current pull in logical pixels.
  double get dragOffset => _dragOffset;

  /// Whether the last refresh succeeded.
  bool get lastRefreshSucceeded => _lastRefreshSucceeded;

  /// Whether a refresh is under way (released, or refreshing).
  bool get isRefreshing => _phase == CYLRefreshPhase.releasing || _phase == CYLRefreshPhase.refreshing;

  /// Whether the footer reported that there is no more data; always false for a header.
  bool get isNoMoreData => _noMoreData;

  /// Whether the indicator keeps its [expandHeight] open: while refreshing, finishing, and (footer) with no more data.
  bool get holdsSpace => isRefreshing || _phase == CYLRefreshPhase.finishing || _noMoreData || _secondaryOpen;

  /// Whether the second floor is open.
  bool get isSecondaryOpen => _secondaryOpen;

  /// Whether the pull is past [secondaryTriggerOffset]: releasing opens the second floor.
  bool get isSecondaryArmed => _secondaryArmed;

  /// Opens the second floor ([secondaryView] must be set). Does nothing while it is open.
  void openSecondary() {
    if (_disposed || secondaryView == null || _secondaryOpen) return;
    _finishTimer?.cancel();
    _finishTimer = null;
    _secondaryArmed = false;
    _secondaryOpen = true;
    _dragOffset = 0;
    _pullingPercent = 0;
    if (_phase != CYLRefreshPhase.idle) {
      _setPhase(CYLRefreshPhase.idle);
    } else {
      notifyListeners();
    }
    secondaryOpenedBlock?.call();
  }

  /// Closes the second floor. Does nothing unless it is open.
  void closeSecondary() {
    if (_disposed || !_secondaryOpen) return;
    _secondaryOpen = false;
    notifyListeners();
    secondaryClosedBlock?.call();
  }

  /// The duration the next opening animation takes, or null for the default; read by `CYLRefresh`.
  Duration? openDuration;

  /// The distance the next opening animation overshoots by; read by `CYLRefresh`.
  double openOverOffset = 0;

  /// Whether a [beginRefreshing] is waiting for the component to be attached to a `CYLRefresh` (refresh on start).
  bool get wantsBegin => _wantsBegin;

  /// Whether a `CYLRefresh` shows this component.
  bool get attached => _host != null;

  /// Connects the component to its owner; called by `CYLRefresh`.
  void attach(CYLRefreshHost host) {
    _host = host;
    if (_wantsBegin) {
      _wantsBegin = false;
      beginRefreshing();
    }
  }

  /// Disconnects the component from its owner; called by `CYLRefresh`.
  void detach(CYLRefreshHost host) {
    if (identical(_host, host)) _host = null;
  }

  /// Calls [observer] on every phase change.
  void addPhaseObserver(CYLRefreshPhaseObserver observer) => _observers.add(observer);

  /// Stops calling [observer].
  void removePhaseObserver(CYLRefreshPhaseObserver observer) => _observers.remove(observer);

  /// Starts refreshing as if the user had pulled and released. Before the component is attached, it starts once it
  /// is (refresh on start). [duration] is the opening animation's length, [overOffset] how far it overshoots
  /// (default [defaultOverOffset]); [force] ignores [refreshEnabled], a refresh under way and the exclusivity.
  void beginRefreshing({Duration? duration, double? overOffset, bool force = false}) {
    if (_disposed) return;
    if (!force && (!refreshEnabled || isRefreshing)) return;
    if (_host == null) {
      _wantsBegin = true;
      return;
    }
    if (!force && exclusiveWithOtherRefresh && _host!.isOtherRefreshing(this)) return;
    openDuration = duration;
    openOverOffset = overOffset ?? defaultOverOffset;
    _start();
  }

  /// Ends refreshing; [success] picks the result shown for [finishDuration]. Does nothing unless refreshing.
  void endRefreshing({bool success = true}) {
    if (_disposed || !isRefreshing) return;
    _lastRefreshSucceeded = success;
    _finishTimer?.cancel();
    _setPhase(CYLRefreshPhase.finishing);
    didEndRefreshing(success);
    _finishTimer = Timer(finishDuration, _close);
  }

  /// Called after [endRefreshing]; subclasses record the result.
  @protected
  void didEndRefreshing(bool success) {}

  void _close() {
    _finishTimer = null;
    if (_disposed) return;
    _dragOffset = 0;
    _pullingPercent = 0;
    _setPhase(CYLRefreshPhase.idle);
  }

  /// Starts refreshing and calls [refreshingHandler].
  @protected
  void startRefreshing() => _start();

  void _start() {
    _finishTimer?.cancel();
    _finishTimer = null;
    _lastRefreshSucceeded = true;
    if (_noMoreData) {
      _noMoreData = false;
      willLeaveNoMoreData();
    }
    _setPhase(CYLRefreshPhase.releasing);
    _setPhase(CYLRefreshPhase.refreshing);
    refreshingHandler?.call();
  }

  /// Called when a load starts after the footer had no more data.
  @protected
  void willLeaveNoMoreData() {}

  /// Called by `CYLRefresh` while the content is pulled by [offset] logical pixels past this component's edge.
  /// [dragging] says whether a finger holds the content; [startedAtEdge] whether the drag began at the edge.
  void handlePull(double offset, {required bool dragging, bool startedAtEdge = true}) {
    if (_disposed) return;
    final visible = offset > 0 || _dragOffset > 0;
    if (!visible && !notifiesWhenHidden) return;
    final changed = offset != _dragOffset;
    _dragOffset = offset < 0 ? 0 : offset;
    final wasSecondaryArmed = _secondaryArmed;
    _secondaryArmed = secondaryView != null && refreshEnabled && !_secondaryOpen && dragging && !isRefreshing && _dragOffset >= secondaryTriggerOffset;
    if (_secondaryArmed != wasSecondaryArmed) notifyListeners();
    _pullingPercent = triggerOffset > 0 ? _dragOffset / triggerOffset : 0;
    final armed = refreshEnabled && !(_noMoreData && !canLoadAfterNoMore) && !(triggerMode == CYLRefreshTriggerMode.onEdge && !startedAtEdge);
    if (dragging && !isRefreshing && _phase != CYLRefreshPhase.finishing) {
      if (!armed || _dragOffset <= 0) {
        if (_phase != CYLRefreshPhase.idle) _setPhase(CYLRefreshPhase.idle);
      } else if (_dragOffset >= triggerOffset) {
        if (_phase != CYLRefreshPhase.releaseToRefresh) {
          _setPhase(CYLRefreshPhase.releaseToRefresh);
          if (hapticFeedback) HapticFeedback.mediumImpact();
        }
        if (triggersWhenReached && (!exclusiveWithOtherRefresh || !(_host?.isOtherRefreshing(this) ?? false))) {
          _start();
          return;
        }
      } else if (_phase != CYLRefreshPhase.pullToRefresh) {
        _setPhase(CYLRefreshPhase.pullToRefresh);
      }
    }
    if (changed || notifiesWhenHidden) notifyListeners();
  }

  /// Called by `CYLRefresh` when the finger lifts: an armed component starts refreshing.
  void handleRelease() {
    if (_disposed) return;
    if (_secondaryArmed) {
      _secondaryArmed = false;
      if (_phase != CYLRefreshPhase.idle) _setPhase(CYLRefreshPhase.idle);
      openSecondary();
      return;
    }
    if (_phase == CYLRefreshPhase.releaseToRefresh) {
      if (exclusiveWithOtherRefresh && (_host?.isOtherRefreshing(this) ?? false)) {
        _setPhase(CYLRefreshPhase.idle);
        return;
      }
      openDuration = null;
      openOverOffset = 0;
      _start();
    } else if (_phase == CYLRefreshPhase.pullToRefresh) {
      _setPhase(CYLRefreshPhase.idle);
    }
  }

  /// Whether a pull may start a load after "no more data"; only a footer can say yes.
  @protected
  bool get canLoadAfterNoMore => false;

  void _setPhase(CYLRefreshPhase phase) {
    if (phase == _phase) return;
    final old = _phase;
    _phase = phase;
    for (final observer in List.of(_observers)) {
      observer(this, phase, old);
    }
    notifyListeners();
  }

  /// Sets "no more data" for subclasses; notifies the listeners.
  @protected
  void setNoMoreData(bool value) {
    if (_noMoreData == value) return;
    _noMoreData = value;
    notifyListeners();
  }

  /// Draws the indicator inside the space the pull opens; the default calls [builder].
  Widget buildIndicator(BuildContext context) => builder?.call(context, this) ?? const SizedBox.shrink();

  @override
  void dispose() {
    _disposed = true;
    _finishTimer?.cancel();
    _observers.clear();
    super.dispose();
  }
}

/// The header: pulled down at the top of the content; refreshes.
class CYLRefreshHeader extends CYLRefreshComponent {
  /// Creates a header; see [CYLRefreshComponent] for the shared arguments.
  CYLRefreshHeader({
    super.refreshingHandler,
    super.builder,
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
    this.resetsFooterAfterRefresh = false,
  });

  @override
  bool get isHeader => true;

  /// True: a successful refresh clears the footer's "no more data".
  bool resetsFooterAfterRefresh;

  /// When the last refresh succeeded, or null.
  DateTime? lastUpdatedTime;

  @override
  void didEndRefreshing(bool success) {
    if (success) lastUpdatedTime = DateTime.now();
  }
}

/// The footer: pulled up at the bottom of the content; loads more. Ends with [endRefreshing] or
/// [endRefreshingWithNoMoreData].
class CYLRefreshFooter extends CYLRefreshComponent {
  /// Creates a footer; see [CYLRefreshComponent] for the shared arguments.
  CYLRefreshFooter({
    super.refreshingHandler,
    super.builder,
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
    this.loadsAfterNoMoreData = false,
  });

  @override
  bool get isHeader => false;

  /// True: a pull or [beginRefreshing] loads again after "no more data".
  bool loadsAfterNoMoreData;

  @override
  bool get canLoadAfterNoMore => loadsAfterNoMoreData;

  @override
  void beginRefreshing({Duration? duration, double? overOffset, bool force = false}) {
    if (!force && isNoMoreData && !loadsAfterNoMoreData) return;
    super.beginRefreshing(duration: duration, overOffset: overOffset, force: force);
  }

  /// Ends loading and shows "no more data": the footer keeps its space and stops loading until [resetNoMoreData]
  /// (or, with [loadsAfterNoMoreData], the next pull).
  void endRefreshingWithNoMoreData() {
    if (!isRefreshing) return;
    setNoMoreData(true);
    endRefreshing(success: true);
  }

  /// Shows "no more data" without a load under way (the first page was the last one).
  void noticeNoMoreData() => setNoMoreData(true);

  /// Clears "no more data": the footer loads again.
  void resetNoMoreData() {
    if (!isNoMoreData) return;
    setNoMoreData(false);
  }
}

/// A footer that loads by itself when the content scrolls to the end, with no pull (infinite scroll).
class CYLRefreshAutoFooter extends CYLRefreshFooter {
  /// Creates an auto footer; see [CYLRefreshComponent] for the shared arguments.
  CYLRefreshAutoFooter({
    super.refreshingHandler,
    super.builder,
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
    this.automaticallyRefresh = true,
    this.triggerAutomaticallyRefreshPercent = 1,
    this.autoTriggerTimes = 1,
  });

  /// False: the footer only loads on a pull.
  bool automaticallyRefresh;

  /// The share of the footer that must be in view to load by itself: 1 loads when the end is reached, 0 loads one
  /// footer height early.
  double triggerAutomaticallyRefreshPercent;

  /// How many automatic loads may follow one another before a pull is needed; 0 for no limit.
  int autoTriggerTimes;

  int _autoTriggered = 0;

  /// How many automatic loads started since the last pull or reset.
  int get autoTriggeredCount => _autoTriggered;

  /// Called by `CYLRefresh` while scrolling: [distanceToEnd] is the scroll distance left to the end of the content.
  void handleDistanceToEnd(double distanceToEnd) {
    if (!automaticallyRefresh || !refreshEnabled || isRefreshing || phase == CYLRefreshPhase.finishing) return;
    if (isNoMoreData && !loadsAfterNoMoreData) return;
    if (autoTriggerTimes > 0 && _autoTriggered >= autoTriggerTimes) return;
    if (distanceToEnd > (1 - triggerAutomaticallyRefreshPercent) * expandHeight) return;
    final before = phase;
    beginRefreshing(duration: Duration.zero, overOffset: 0);
    if (before != phase && isRefreshing) _autoTriggered++;
  }

  @override
  void handleRelease() {
    final wasArmed = phase == CYLRefreshPhase.releaseToRefresh;
    super.handleRelease();
    if (wasArmed) _autoTriggered = 0;
  }

  @override
  void resetNoMoreData() {
    super.resetNoMoreData();
    _autoTriggered = 0;
  }
}

/// A footer pulled up past the end of the content and released, like iOS `CYLRefreshBackFooter`.
class CYLRefreshBackFooter extends CYLRefreshFooter {
  /// Creates a back footer; see [CYLRefreshComponent] for the shared arguments.
  CYLRefreshBackFooter({
    super.refreshingHandler,
    super.builder,
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
}

/// A header that draws nothing: follow it with [CYLRefreshComponent.addPhaseObserver] or its listeners.
class CYLRefreshListenerHeader extends CYLRefreshHeader {
  /// Creates a drawing-free header.
  CYLRefreshListenerHeader({super.refreshingHandler, super.notifiesWhenHidden, super.expandHeight, super.scrollMode});
}

/// A footer that draws nothing: follow it with [CYLRefreshComponent.addPhaseObserver] or its listeners.
class CYLRefreshListenerFooter extends CYLRefreshFooter {
  /// Creates a drawing-free footer.
  CYLRefreshListenerFooter({super.refreshingHandler, super.notifiesWhenHidden, super.expandHeight, super.scrollMode});
}

/// A footer for the horizontal axis (`CYLRefresh.triggerAxis` = [Axis.horizontal]): pulled left at the end of the
/// content, like the iOS `cyl_trailer`. It behaves as a back footer; `expandHeight` is its width.
class CYLRefreshTrailer extends CYLRefreshBackFooter {
  /// Creates a trailer; see [CYLRefreshComponent] for the shared arguments.
  CYLRefreshTrailer({
    super.refreshingHandler,
    super.builder,
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
}
