import { ActivityIndicator, StyleSheet, Text, View } from 'react-native';
import type { CYLRefreshComponent } from './component.ts';
import { CYLRefreshPhase } from './refreshTypes.ts';
import { useCYLRefreshComponent } from './useCYLRefreshComponent.ts';
import type { CYLRefreshClassic } from './styles.ts';

/** The props of `CYLRefreshClassicIndicator`. */
export interface CYLRefreshClassicIndicatorProps {
  /** A classic header or footer (`CYLRefreshClassicHeader`, `CYLRefreshClassicFooter`, `CYLRefreshClassicAutoFooter`). */
  component: CYLRefreshComponent & CYLRefreshClassic;
}

/**
 * The classic indicator: an arrow that turns when armed, a spinner while refreshing, a mark for the result, the text of the
 * current state and, for a header, the last update. It is one accessibility element whose label is the text and which
 * announces changes politely.
 */
export function CYLRefreshClassicIndicator({ component }: CYLRefreshClassicIndicatorProps) {
  useCYLRefreshComponent(component);
  const title = component.currentTitle;
  const message = component.messageText();
  const color = component.colorAccent ?? component.colorPrimary ?? '#666666';
  const size = component.iconSize;
  let icon: string;
  if (component.isNoMoreData) {
    icon = '';
  } else if (component.phase === CYLRefreshPhase.finishing) {
    icon = component.lastRefreshSucceeded ? '✓' : '!';
  } else {
    icon = component.isHeader ? '↓' : '↑';
  }
  const armed = component.phase === CYLRefreshPhase.releaseToRefresh;
  const spinning = component.isRefreshing;
  const iconNode = (
    <View style={{ width: size, height: size, alignItems: 'center', justifyContent: 'center' }}>
      {spinning ? (
        <ActivityIndicator size="small" color={color} />
      ) : (
        <Text style={{ fontSize: size, color, transform: [{ rotate: armed ? '180deg' : '0deg' }] }}>{icon}</Text>
      )}
    </View>
  );
  const texts = (
    <View style={styles.texts}>
      <Text style={[styles.title, { color }]}>{title}</Text>
      {message !== null ? <Text style={[styles.message, { color }]}>{message}</Text> : null}
    </View>
  );
  const spacer = <View style={{ width: component.iconSpacing }} />;
  return (
    <View
      accessible
      accessibilityLabel={message !== null ? `${title}, ${message}` : title}
      accessibilityLiveRegion="polite"
      style={styles.row}
    >
      {component.iconOnTrailingSide ? [texts, spacer, iconNode] : [iconNode, spacer, texts]}
    </View>
  );
}

const styles = StyleSheet.create({
  row: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', flex: 1 },
  texts: { alignItems: 'center' },
  title: { fontSize: 14 },
  message: { fontSize: 11 },
});
