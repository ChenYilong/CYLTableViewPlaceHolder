import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'component.dart';
import 'physics.dart';
import 'refresh_types.dart';

/// Builds the scroll behavior of the child from the ambient one (which already carries [CYLRefreshPhysics]).
typedef CYLRefreshScrollBehaviorBuilder = ScrollBehavior Function(ScrollBehavior behavior);

/// Builds the child with the physics it must use, instead of a ready-made child.
typedef CYLRefreshChildBuilder = Widget Function(BuildContext context, ScrollPhysics physics);

/// Pull to refresh and load more around a scrollable [child], like iOS `cyl_header` / `cyl_footer`.
///
/// The [header] and [footer] are long-lived [CYLRefreshComponent]s: create them in `initState`, dispose them in
/// `dispose`, and end every refresh with `endRefreshing`.
class CYLRefresh extends StatefulWidget {
  /// Wraps [child] (a `ListView`, `GridView`, `CustomScrollView`, ...).
  const CYLRefresh({
    super.key,
    this.header,
    this.footer,
    this.refreshOnStartHeader,
    this.exclusiveWithOtherRefresh = true,
    this.refreshOnStart = false,
    required this.child,
    this.childBuilder,
    this.frictionFactor,
    this.horizontalFrictionFactor,
    this.scrollBehaviorBuilder,
    this.fit = StackFit.expand,
    this.clipBehavior = Clip.hardEdge,
    this.safeArea = false,
    this.scrollController,
    this.triggerAxis = Axis.vertical,
    this.readySpringBuilder,
    this.horizontalReadySpringBuilder,
    this.springRebound = true,
    this.isNested = false,
    this.nestedOuterController,
    this.nestedInnerController,
  });

  /// Pulled down at the top: refreshes.
  final CYLRefreshHeader? header;

  /// Pulled up at the bottom (or loading by itself at the end): loads more.
  final CYLRefreshFooter? footer;

  /// A header used only for the first refresh of [refreshOnStart] (iOS `cyl_beginRefreshingWithStartHeader:`); [header]
  /// takes over when that refresh has ended.
  final CYLRefreshHeader? refreshOnStartHeader;

  /// False: the header and the footer may refresh at the same time.
  final bool exclusiveWithOtherRefresh;

  /// True: refresh once after the first frame.
  final bool refreshOnStart;

  /// The scrollable.
  final Widget child;

  /// Builds the scrollable from the physics when it must be passed explicitly; replaces [child].
  final CYLRefreshChildBuilder? childBuilder;

  /// The friction of a vertical pull; see [CYLRefreshFrictionFactor].
  final CYLRefreshFrictionFactor? frictionFactor;

  /// The friction of a horizontal pull.
  final CYLRefreshFrictionFactor? horizontalFrictionFactor;

  /// Changes the scroll behavior given to [child].
  final CYLRefreshScrollBehaviorBuilder? scrollBehaviorBuilder;

  /// How the child fills the space.
  final StackFit fit;

  /// How the content and the indicators are clipped.
  final Clip clipBehavior;

  /// True: the indicators keep out of the system areas (status bar, home indicator).
  final bool safeArea;

  /// Handed to the child's scrollables as their primary controller (`PrimaryScrollController`), so the host can read or
  /// drive the position the pull comes from.
  final ScrollController? scrollController;

  /// The axis the pull is read on: [Axis.vertical] (the header is pulled down, the footer up) or [Axis.horizontal] (the
  /// header is pulled right, the footer or a [CYLRefreshTrailer] left, so it sits at the end).
  final Axis triggerAxis;

  /// The vertical spring after a release; null keeps the bouncing default.
  final CYLRefreshSpringBuilder? readySpringBuilder;

  /// The horizontal spring after a release; null keeps the bouncing default.
  final CYLRefreshSpringBuilder? horizontalReadySpringBuilder;

  /// False: a fling stops at the edge instead of springing past it.
  final bool springRebound;

  /// True: the header and the footer belong to different scrollables, a `NestedScrollView`'s outer and inner ones.
  final bool isNested;

  /// With [isNested]: the controller of the scrollable that carries the header.
  final ScrollController? nestedOuterController;

  /// With [isNested]: the controller of the scrollable that carries the footer.
  final ScrollController? nestedInnerController;

  @override
  State<CYLRefresh> createState() => _CYLRefreshState();
}

class _Slot {
  _Slot(TickerProvider vsync) : controller = AnimationController.unbounded(vsync: vsync);

  final AnimationController controller;
  CYLRefreshComponent? component;
  VoidCallback? listener;
  bool open = false;
  bool secondary = false;
  int generation = 0;

  double get hold => controller.value;
}

class _CYLRefreshState extends State<CYLRefresh> with TickerProviderStateMixin implements CYLRefreshHost {
  late final _Slot _header = _Slot(this);
  late final _Slot _footer = _Slot(this);
  final ValueNotifier<(double, double)> _pull = ValueNotifier((0, 0));
  bool _dragging = false;
  bool _startedAtTop = true;
  bool _startedAtBottom = true;
  late bool _startActive = widget.refreshOnStartHeader != null;
  bool _startRefreshed = false;
  Size _viewport = Size.zero;

  CYLRefreshHeader? get _activeHeader => _startActive ? widget.refreshOnStartHeader : widget.header;

  @override
  void initState() {
    super.initState();
    _bind();
    if (widget.refreshOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _activeHeader?.beginRefreshing();
      });
    }
  }

  @override
  void didUpdateWidget(CYLRefresh oldWidget) {
    super.didUpdateWidget(oldWidget);
    _bind();
  }

  @override
  void dispose() {
    _unbind(_header);
    _unbind(_footer);
    _header.controller.dispose();
    _footer.controller.dispose();
    _pull.dispose();
    super.dispose();
  }

  @override
  bool isOtherRefreshing(CYLRefreshComponent component) {
    if (!widget.exclusiveWithOtherRefresh) return false;
    final other = component.isHeader ? _footer.component : _header.component;
    return other?.isRefreshing ?? false;
  }

  void _bind() {
    _bindSlot(_header, _activeHeader);
    _bindSlot(_footer, widget.footer);
  }

  void _unbind(_Slot slot) {
    final old = slot.component;
    if (old == null) return;
    old.removeListener(slot.listener!);
    old.detach(this);
    slot.component = null;
  }

  void _bindSlot(_Slot slot, CYLRefreshComponent? component) {
    if (identical(slot.component, component)) return;
    _unbind(slot);
    if (component == null) {
      slot.open = false;
      slot.controller.value = 0;
      return;
    }
    slot.component = component;
    slot.listener = () => _componentChanged(slot);
    component.addListener(slot.listener!);
    slot.open = component.holdsSpace;
    slot.secondary = component.isSecondaryOpen;
    slot.controller.value = slot.open ? _extentOf(component) : 0;
    component.attach(this);
  }

  void _componentChanged(_Slot slot) {
    final component = slot.component!;
    if (component == widget.refreshOnStartHeader && _startActive) {
      if (component.isRefreshing) _startRefreshed = true;
      if (_startRefreshed && component.phase == CYLRefreshPhase.idle) {
        setState(() {
          _startActive = false;
          _bind();
        });
        return;
      }
    }
    if (component is CYLRefreshHeader && component.phase == CYLRefreshPhase.finishing && component.lastRefreshSucceeded && component.resetsFooterAfterRefresh) {
      widget.footer?.resetNoMoreData();
    }
    final open = component.holdsSpace;
    final secondary = component.isSecondaryOpen;
    if (open == slot.open && secondary == slot.secondary) return;
    slot.open = open;
    slot.secondary = secondary;
    final generation = ++slot.generation;
    final controller = slot.controller;
    if (open) {
      final over = component.openOverOffset;
      final duration = component.openDuration ?? const Duration(milliseconds: 200);
      final target = _extentOf(component);
      if (over > 0) {
        controller.animateTo(target + over, duration: duration, curve: Curves.easeOut).whenComplete(() {
          if (mounted && slot.generation == generation) controller.animateTo(target, duration: const Duration(milliseconds: 150));
        });
      } else if (duration == Duration.zero) {
        controller.value = target;
      } else {
        controller.animateTo(target, duration: duration, curve: Curves.easeOut);
      }
    } else {
      controller.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  bool _onScroll(ScrollNotification notification) {
    if ((!widget.isNested && notification.depth != 0) || notification.metrics.axis != widget.triggerAxis) return false;
    final metrics = notification.metrics;
    final position = notification.context == null ? null : Scrollable.maybeOf(notification.context!)?.position;
    final isOuter = !widget.isNested || (position != null && (widget.nestedOuterController?.positions.contains(position) ?? false));
    final isInner = !widget.isNested || (position != null && (widget.nestedInnerController?.positions.contains(position) ?? false));
    if (!isOuter && !isInner) return false;
    final header = _header.component;
    final footer = _footer.component;
    if (notification is ScrollStartNotification) {
      _dragging = notification.dragDetails != null;
      _startedAtTop = metrics.pixels <= metrics.minScrollExtent + 0.5;
      _startedAtBottom = metrics.pixels >= metrics.maxScrollExtent - 0.5;
    } else if (notification is ScrollUpdateNotification) {
      if (notification.dragDetails != null) {
        _dragging = true;
      } else if (_dragging) {
        _release();
      }
    }
    final headerPull = isOuter ? math.max(0.0, metrics.minScrollExtent - metrics.pixels) : _pull.value.$1;
    final footerPull = isInner ? math.max(0.0, metrics.pixels - metrics.maxScrollExtent) : _pull.value.$2;
    if (_pull.value != (headerPull, footerPull)) _pull.value = (headerPull, footerPull);
    if (isOuter) header?.handlePull(headerPull, dragging: _dragging, startedAtEdge: _startedAtTop);
    if (isInner) {
      footer?.handlePull(footerPull, dragging: _dragging, startedAtEdge: _startedAtBottom);
      if (footer is CYLRefreshAutoFooter) footer.handleDistanceToEnd(metrics.maxScrollExtent - metrics.pixels);
    }
    if (_dragging && header != null && header.isSecondaryOpen && metrics.pixels - metrics.minScrollExtent >= header.secondaryCloseTriggerOffset) {
      header.closeSecondary();
    }
    if (_dragging && footer != null && footer.isSecondaryOpen && metrics.maxScrollExtent - metrics.pixels >= footer.secondaryCloseTriggerOffset) {
      footer.closeSecondary();
    }
    if (notification is ScrollEndNotification && _dragging) _release();
    return false;
  }

  /// The extent the indicator holds along the pull axis: [CYLRefreshComponent.expandHeight], or the second floor's.
  double _extentOf(CYLRefreshComponent component) {
    if (!component.isSecondaryOpen) return component.expandHeight;
    if (component.secondaryDimension > 0) return component.secondaryDimension;
    final extent = widget.triggerAxis == Axis.horizontal ? _viewport.width : _viewport.height;
    return extent.isFinite && extent > 0 ? extent : component.expandHeight;
  }

  void _release() {
    _dragging = false;
    _header.component?.handleRelease();
    _footer.component?.handleRelease();
  }

  @override
  Widget build(BuildContext context) {
    final header = _header.component;
    final footer = _footer.component;
    final physics = CYLRefreshPhysics(
      parent: const AlwaysScrollableScrollPhysics(),
      frictionFactorOf: widget.frictionFactor,
      horizontalFrictionFactorOf: widget.horizontalFrictionFactor,
      maxHeaderPull: header?.maxPullDistance ?? 0,
      maxFooterPull: footer?.maxPullDistance ?? 0,
      readySpringBuilder: widget.readySpringBuilder,
      horizontalReadySpringBuilder: widget.horizontalReadySpringBuilder,
      springRebound: widget.springRebound,
    );
    Widget child;
    if (widget.childBuilder != null) {
      child = widget.childBuilder!(context, physics);
    } else {
      var behavior = ScrollConfiguration.of(context).copyWith(physics: physics);
      if (widget.scrollBehaviorBuilder != null) behavior = widget.scrollBehaviorBuilder!(behavior);
      child = ScrollConfiguration(behavior: behavior, child: widget.child);
    }
    if (widget.scrollController != null) {
      child = PrimaryScrollController(controller: widget.scrollController!, scrollDirection: widget.triggerAxis, child: child);
    }
    child = NotificationListener<ScrollNotification>(onNotification: _onScroll, child: child);
    return LayoutBuilder(builder: (context, constraints) {
      _viewport = constraints.biggest;
      return _body(child);
    });
  }

  Widget _body(Widget child) {
    final header = _header.component;
    final footer = _footer.component;
    return ClipRect(
      clipBehavior: widget.clipBehavior,
      child: ListenableBuilder(
        listenable: Listenable.merge([_pull, _header.controller, _footer.controller]),
        builder: (context, _) {
          final (headerPull, footerPull) = _pull.value;
          final headerTotal = math.max(_header.hold, headerPull);
          final footerTotal = math.max(_footer.hold, footerPull);
          double extra(_Slot slot, double pull) {
            final mode = slot.component?.scrollMode ?? CYLRefreshScrollMode.move;
            return mode == CYLRefreshScrollMode.front ? 0 : math.max(0.0, slot.hold - pull);
          }

          final shift = extra(_header, headerPull) - extra(_footer, footerPull);
          final horizontal = widget.triggerAxis == Axis.horizontal;
          return _CYLRefreshScope(
            header: _header.controller,
            footer: _footer.controller,
            pull: _pull,
            headerComponent: header,
            footerComponent: footer,
            child: Stack(
            fit: widget.fit,
            clipBehavior: Clip.none,
            children: [
              if (header != null && header.scrollMode == CYLRefreshScrollMode.behind) _indicator(header, headerTotal),
              if (footer != null && footer.scrollMode == CYLRefreshScrollMode.behind) _indicator(footer, footerTotal),
              Transform.translate(offset: horizontal ? Offset(shift, 0) : Offset(0, shift), child: child),
              if (header != null && header.scrollMode != CYLRefreshScrollMode.behind) _indicator(header, headerTotal),
              if (footer != null && footer.scrollMode != CYLRefreshScrollMode.behind) _indicator(footer, footerTotal),
            ],
          ));
        },
      ),
    );
  }

  Widget _indicator(CYLRefreshComponent component, double total) {
    final expand = _extentOf(component);
    final isHeader = component.isHeader;
    final horizontal = widget.triggerAxis == Axis.horizontal;
    Widget body = horizontal
        ? SizedBox(width: expand, child: _IndicatorBody(component: component))
        : SizedBox(height: expand, child: _IndicatorBody(component: component));
    if (widget.safeArea && !horizontal) {
      body = SafeArea(top: isHeader, bottom: !isHeader, left: false, right: false, child: body);
    }
    if (component.scrollMode == CYLRefreshScrollMode.locator) return const SizedBox.shrink();
    final visible = total > 0 || component.holdsSpace;
    if (!visible) return const SizedBox.shrink();
    // The near edge of the axis: top / left for the header, bottom / right for the footer.
    Positioned place({required double offset, required double extent, required Widget child}) => horizontal
        ? Positioned(top: 0, bottom: 0, left: isHeader ? offset : null, right: isHeader ? null : offset, width: extent, child: child)
        : Positioned(left: 0, right: 0, top: isHeader ? offset : null, bottom: isHeader ? null : offset, height: extent, child: child);
    switch (component.scrollMode) {
      case CYLRefreshScrollMode.front:
        return place(offset: math.min(total, expand) - expand, extent: expand, child: body);
      case CYLRefreshScrollMode.behind:
        return place(offset: 0, extent: expand, child: body);
      case CYLRefreshScrollMode.move:
        if (component.stretchIndicator) {
          final stretched = horizontal
              ? SizedBox(width: total, child: _IndicatorBody(component: component))
              : SizedBox(height: total, child: _IndicatorBody(component: component));
          return place(offset: 0, extent: total, child: ClipRect(child: stretched));
        }
        return place(
          offset: 0,
          extent: total,
          child: ClipRect(
            child: OverflowBox(
              minWidth: horizontal ? expand : null,
              maxWidth: horizontal ? expand : null,
              minHeight: horizontal ? null : expand,
              maxHeight: horizontal ? null : expand,
              alignment: horizontal ? (isHeader ? Alignment.centerRight : Alignment.centerLeft) : (isHeader ? Alignment.bottomCenter : Alignment.topCenter),
              child: body,
            ),
          ),
        );
      case CYLRefreshScrollMode.locator:
        return const SizedBox.shrink();
    }
  }
}

/// What the locators read from the `CYLRefresh` above them.
class _CYLRefreshScope extends InheritedWidget {
  const _CYLRefreshScope({
    required this.header,
    required this.footer,
    required this.pull,
    required this.headerComponent,
    required this.footerComponent,
    required super.child,
  });

  final AnimationController header;
  final AnimationController footer;
  final ValueNotifier<(double, double)> pull;
  final CYLRefreshComponent? headerComponent;
  final CYLRefreshComponent? footerComponent;

  static _CYLRefreshScope? maybeOf(BuildContext context) => context.dependOnInheritedWidgetOfExactType<_CYLRefreshScope>();

  @override
  bool updateShouldNotify(_CYLRefreshScope old) => headerComponent != old.headerComponent || footerComponent != old.footerComponent;
}

/// Places the header's indicator inside the content's slivers (use it as the first sliver of a `CustomScrollView`, with
/// the header's `scrollMode` set to [CYLRefreshScrollMode.locator]): it is as tall as the pull and the open indicator, and
/// draws the indicator.
class CYLRefreshHeaderLocator extends StatelessWidget {
  /// Creates a header locator.
  const CYLRefreshHeaderLocator({super.key});

  @override
  Widget build(BuildContext context) => const _CYLRefreshLocator(isHeader: true);
}

/// Places the footer's indicator inside the content's slivers (the last sliver of a `CustomScrollView`, with the footer's
/// `scrollMode` set to [CYLRefreshScrollMode.locator]).
class CYLRefreshFooterLocator extends StatelessWidget {
  /// Creates a footer locator.
  const CYLRefreshFooterLocator({super.key});

  @override
  Widget build(BuildContext context) => const _CYLRefreshLocator(isHeader: false);
}

class _CYLRefreshLocator extends StatelessWidget {
  const _CYLRefreshLocator({required this.isHeader});

  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    final scope = _CYLRefreshScope.maybeOf(context);
    final component = isHeader ? scope?.headerComponent : scope?.footerComponent;
    if (scope == null || component == null || component.scrollMode != CYLRefreshScrollMode.locator) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    final slot = isHeader ? scope.header : scope.footer;
    return SliverToBoxAdapter(
      child: ListenableBuilder(
        listenable: Listenable.merge([scope.pull, slot]),
        builder: (context, _) {
          final pull = isHeader ? scope.pull.value.$1 : scope.pull.value.$2;
          final total = math.max(slot.value, pull);
          return SizedBox(
            height: total,
            child: ClipRect(
              child: OverflowBox(
                minHeight: component.expandHeight,
                maxHeight: component.expandHeight,
                alignment: isHeader ? Alignment.bottomCenter : Alignment.topCenter,
                child: SizedBox(height: component.expandHeight, child: _IndicatorBody(component: component)),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _IndicatorBody extends StatelessWidget {
  const _IndicatorBody({required this.component});

  final CYLRefreshComponent component;

  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: component,
        builder: (context, _) => component.isSecondaryOpen && component.secondaryView != null ? component.secondaryView! : component.buildIndicator(context),
      );
}
