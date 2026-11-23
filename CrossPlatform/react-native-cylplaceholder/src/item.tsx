import { StyleSheet, Text, View, type StyleProp, type TextStyle } from 'react-native';
import { CYLAnimationView, type CYLAnimationViewProps } from 'react-native-cyltabbar';

export { CYLAnimationView, animationURLWithOptions } from 'react-native-cyltabbar';
export type { CYLAnimationViewProps, CYLAnimationOptions, CYLAnimationViewHandle } from 'react-native-cyltabbar';

/**
 * The props of `CYLPlaceholderItem`: the props of upstream's `CYLAnimationView` (`file`, `options`, `playing`, `selected`,
 * `animationSpeed`, `animationLoops`, `animationRestartToken`, the `onAnimation*` callbacks and `ref`) plus the title.
 */
export type CYLPlaceholderItemProps = Omit<CYLAnimationViewProps, 'iconSize'> & {
  /** The text under the animation, also the accessibility label of the item. Comes from the host, so it can be localized there. */
  title: string;
  /** The side of the animation in points; 80 by default. */
  iconSize?: number;
  /** The style of the title. */
  titleStyle?: StyleProp<TextStyle>;
};

/**
 * A placeholder item: an animation (or the still image the engine falls back to) above a title.
 *
 * It only lays out upstream's `CYLAnimationView` and a `Text`; the playback props go to upstream's view under upstream's
 * names. Restart it by changing `animationRestartToken` or with the ref's `restart()` (the `restartAnimation` of the other
 * platforms). The whole item is one accessibility element labelled with `title`; the animation is a decoration.
 */
export function CYLPlaceholderItem({
  title,
  iconSize = 80,
  titleStyle,
  style,
  playing = true,
  ...animation
}: CYLPlaceholderItemProps) {
  return (
    <View accessible accessibilityLabel={title} style={[styles.item, style]}>
      <View
        accessibilityElementsHidden
        importantForAccessibility="no-hide-descendants"
        style={{ width: iconSize, height: iconSize }}
      >
        <CYLAnimationView {...animation} playing={playing} iconSize={iconSize} style={styles.fill} />
      </View>
      <Text style={[styles.title, titleStyle]}>{title}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  item: { alignItems: 'center' },
  fill: { width: '100%', height: '100%' },
  title: { marginTop: 8, textAlign: 'center' },
});

/**
 * A `renderAnimation` for `CYLPlaceholderView` (`react-native-cylplaceholder`): draws the animation file with upstream's
 * `CYLAnimationView`.
 */
export function renderCYLAnimation(animation: {
  file: string;
  options: Record<string, string | number>;
  size: { width: number; height: number };
  playing: boolean;
}) {
  return (
    <CYLAnimationView
      file={animation.file}
      options={animation.options}
      playing={animation.playing}
      iconSize={Math.min(animation.size.width, animation.size.height)}
      style={{ width: animation.size.width, height: animation.size.height }}
    />
  );
}
