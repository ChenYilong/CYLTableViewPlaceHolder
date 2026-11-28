import { useCallback, useEffect, useMemo, useRef, type ReactElement, type ReactNode } from 'react';
import {
  AccessibilityInfo,
  StyleSheet,
  Vibration,
  View,
  type LayoutChangeEvent,
  type NativeScrollEvent,
  type NativeSyntheticEvent,
  type StyleProp,
  type ViewStyle,
} from 'react-native';
import { CYLRefreshAutoFooter, CYLRefreshComponent, type CYLRefreshHost } from './component.ts';
import { CYLRefreshClassicIndicator } from './CYLRefreshClassicIndicator.tsx';
import { CYLRefreshPhase } from './refreshTypes.ts';
import { isCYLRefreshClassic } from './styles.ts';
import { useCYLRefreshComponent } from './useCYLRefreshComponent.ts';

/** The minimal `ScrollView` / `FlatList` handle `CYLRefresh` needs. */
export interface CYLRefreshScrollable {
  /** Scrolls to a vertical offset (a negative one shows the pulled-down area where the platform allows it). */
  scrollTo?(options: { x?: number; y?: number; animated?: boolean }): void;
  /** `FlatList` form of `scrollTo`. */
  scrollToOffset?(options: { offset: number; animated?: boolean }): void;
}

/** The props `CYLRefresh` hands to its child: spread them onto a `ScrollView`, `FlatList` or `SectionList`. */
export interface CYLRefreshScrollProps {
  /** The scrollable's ref. */
  ref: (instance: CYLRefreshScrollable | null) => void;
  /** Reads the pull. */
  onScroll: (event: NativeSyntheticEvent<NativeScrollEvent>) => void;
  /** Marks the start of a drag. */
  onScrollBeginDrag: (event: NativeSyntheticEvent<NativeScrollEvent>) => void;
  /** Releases an armed component. */
  onScrollEndDrag: (event: NativeSyntheticEvent<NativeScrollEvent>) => void;
  /** Always 16 ms, so the pull follows the finger. */
  scrollEventThrottle: number;
  /** Keeps the indicator's height open while it refreshes (iOS). */
  contentInset: { top: number; bottom: number; left: number; right: number };
}

/** The props of `CYLRefresh`. */
export interface CYLRefreshProps {
  /** The header, or undefined. */
  header?: CYLRefreshComponent;
  /** The footer, or undefined. */
  footer?: CYLRefreshComponent;
  /** A header used only for the first refresh (iOS `cyl_beginRefreshingWithStartHeader:`). */
  refreshOnStartHeader?: CYLRefreshComponent;
  /** True: refresh once after the first layout. */
  refreshOnStart?: boolean;
  /** True (default): a component does not start while another one is refreshing. */
  exclusiveWithOtherRefresh?: boolean;
  /** The style of the wrapper view. */
  style?: StyleProp<ViewStyle>;
  /** Renders the scrollable with the props to spread onto it (the Flutter `childBuilder`). */
  children: (scrollProps: CYLRefreshScrollProps) => ReactElement;
}

/** Draws a component's indicator: its `builder`, or the classic indicator, or nothing. */
function renderIndicator(component: CYLRefreshComponent): ReactNode {
  if (component.builder !== null) {
    return component.buildIndicator() as ReactNode;
  }
  return isCYLRefreshClassic(component) ? <CYLRefreshClassicIndicator component={component} /> : null;
}

function Indicator({ component, top }: { component: CYLRefreshComponent; top: boolean }) {
  useCYLRefreshComponent(component);
  const visible = component.dragOffset > 0 || component.holdsSpace;
  return (
    <View
      pointerEvents="none"
      style={[top ? styles.top : styles.bottom, { height: component.expandHeight, opacity: visible ? 1 : 0 }]}
    >
      {renderIndicator(component)}
    </View>
  );
}

/**
 * Wraps a scrollable with a header and a footer, like the Flutter package's `CYLRefresh`: the child is a render prop that
 * receives the scroll props. The pull is read from the scroll offset, so a pulled-down header and a pulled-up footer need a
 * platform whose scroll view reports offsets past its edges (iOS); the auto footer and `beginRefreshing` work everywhere.
 * Phase changes of classic components are announced to screen readers.
 */
export function CYLRefresh({
  header,
  footer,
  refreshOnStartHeader,
  refreshOnStart = false,
  exclusiveWithOtherRefresh = true,
  style,
  children,
}: CYLRefreshProps) {
  const headerModel = useCYLRefreshComponent(header);
  const footerModel = useCYLRefreshComponent(footer);
  const scrollable = useRef<CYLRefreshScrollable | null>(null);
  const dragging = useRef(false);
  const startedAtTop = useRef(true);
  const startedAtEnd = useRef(true);
  const scrolled = useRef({ y: 0, layout: 0, content: 0 });
  const components = useMemo(
    () => [header, footer, refreshOnStartHeader].filter((c): c is CYLRefreshComponent => c !== undefined),
    [header, footer, refreshOnStartHeader]
  );
  const host = useMemo<CYLRefreshHost>(
    () => ({
      isOtherRefreshing: (component) => exclusiveWithOtherRefresh && components.some((c) => c !== component && c.isRefreshing),
    }),
    [components, exclusiveWithOtherRefresh]
  );

  useEffect(() => {
    if (CYLRefreshComponent.hapticImpact === null) {
      CYLRefreshComponent.hapticImpact = () => Vibration.vibrate(10);
    }
    const announce = (component: CYLRefreshComponent, phase: string) => {
      if (isCYLRefreshClassic(component) && (phase === CYLRefreshPhase.refreshing || phase === CYLRefreshPhase.finishing)) {
        AccessibilityInfo.announceForAccessibility(component.currentTitle);
      }
    };
    const open = (component: CYLRefreshComponent, phase: string) => {
      if (phase === CYLRefreshPhase.refreshing && !dragging.current && component.isHeader) {
        scrollable.current?.scrollTo?.({ y: -component.expandHeight, animated: true });
        scrollable.current?.scrollToOffset?.({ offset: -component.expandHeight, animated: true });
      }
    };
    const observer = (component: CYLRefreshComponent, phase: string) => {
      announce(component, phase);
      open(component, phase);
    };
    for (const component of components) {
      component.attach(host);
      component.addPhaseObserver(observer);
    }
    if (refreshOnStart) {
      (refreshOnStartHeader ?? header)?.beginRefreshing();
    }
    return () => {
      for (const component of components) {
        component.removePhaseObserver(observer);
        component.detach(host);
      }
    };
    // refreshOnStart is read once, at mount.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [components, host]);

  const onScrollBeginDrag = useCallback((event: NativeSyntheticEvent<NativeScrollEvent>) => {
    const { contentOffset, layoutMeasurement, contentSize } = event.nativeEvent;
    dragging.current = true;
    startedAtTop.current = contentOffset.y <= 0;
    startedAtEnd.current = contentSize.height - (contentOffset.y + layoutMeasurement.height) <= 0;
  }, []);

  const onScroll = useCallback(
    (event: NativeSyntheticEvent<NativeScrollEvent>) => {
      const { contentOffset, layoutMeasurement, contentSize } = event.nativeEvent;
      const y = contentOffset.y;
      scrolled.current = { y, layout: layoutMeasurement.height, content: contentSize.height };
      headerModel?.handlePull(Math.max(0, -y), dragging.current, startedAtTop.current);
      if (footerModel !== undefined) {
        const maxScroll = Math.max(0, contentSize.height - layoutMeasurement.height);
        footerModel.handlePull(Math.max(0, y - maxScroll), dragging.current, startedAtEnd.current);
        if (footerModel instanceof CYLRefreshAutoFooter && contentSize.height > 0) {
          footerModel.handleDistanceToEnd(contentSize.height - (y + layoutMeasurement.height));
        }
      }
    },
    [headerModel, footerModel]
  );

  const onScrollEndDrag = useCallback(() => {
    dragging.current = false;
    headerModel?.handleRelease();
    footerModel?.handleRelease();
  }, [headerModel, footerModel]);

  const setRef = useCallback((instance: CYLRefreshScrollable | null) => {
    scrollable.current = instance;
  }, []);

  const scrollProps: CYLRefreshScrollProps = {
    ref: setRef,
    onScroll,
    onScrollBeginDrag,
    onScrollEndDrag,
    scrollEventThrottle: 16,
    contentInset: {
      top: headerModel?.holdsSpace === true ? headerModel.expandHeight : 0,
      bottom: footerModel?.holdsSpace === true && !(footerModel instanceof CYLRefreshAutoFooter) ? footerModel.expandHeight : 0,
      left: 0,
      right: 0,
    },
  };
  const onLayout = useCallback((_event: LayoutChangeEvent) => {}, []);
  return (
    <View style={[styles.fill, style]} onLayout={onLayout}>
      {header !== undefined ? <Indicator component={header} top /> : null}
      {footer !== undefined ? <Indicator component={footer} top={false} /> : null}
      {children(scrollProps)}
    </View>
  );
}

const styles = StyleSheet.create({
  fill: { flex: 1 },
  top: { position: 'absolute', top: 0, left: 0, right: 0 },
  bottom: { position: 'absolute', bottom: 0, left: 0, right: 0 },
});
