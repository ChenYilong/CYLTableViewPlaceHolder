import type { ReactNode } from 'react';
import { Pressable, StyleSheet, Text, View, type StyleProp, type TextStyle } from 'react-native';
import {
  CYLPlaceholderStyle,
  CYLPlaceholderStyleGlyphs,
  cylPlaceholderItemAttributes,
  cylPlaceholderValuesFromAttributes,
} from './attributes.ts';

/** The props of `CYLPlaceholderView`. */
export interface CYLPlaceholderViewProps {
  /** The built-in icon, shown when there is no `image` and no animation. */
  style?: CYLPlaceholderStyle;
  /** The title. Comes from the host, so it can be localized there. */
  title?: string;
  /** The message under the title. */
  message?: string;
  /** Replaces the style's icon. */
  image?: ReactNode;
  /** An animation file (a name in the app, a path or a URL), drawn by `renderAnimation`. */
  animationFile?: string;
  /** The options of the animation file (Rive's `artboard`, `stateMachine`, ...). */
  animationOptions?: Record<string, string | number>;
  /** The animation's size in points; 120 x 120 by default. */
  animationSize?: { width: number; height: number };
  /** Whether the animation plays; true by default. */
  animationPlaying?: boolean;
  /**
   * Draws `animationFile`. This package does not import CYLTabBarController's `CYLAnimationView` itself (an optional peer
   * dependency); pass `renderCYLAnimation` from `react-native-cylplaceholder/item`, or your own. Without it the style's icon
   * shows.
   */
  renderAnimation?: (animation: {
    file: string;
    options: Record<string, string | number>;
    size: { width: number; height: number };
    playing: boolean;
  }) => ReactNode;
  /** The title color. */
  titleColor?: string;
  /** The icon color. */
  iconColor?: string;
  /** The background color. */
  backgroundColor?: string;
  /** Replaces the title's style. */
  titleStyle?: StyleProp<TextStyle>;
  /** The icon's size in points; 96 by default. */
  imageSize?: number;
  /** Called when the placeholder is tapped (for example to retry); the placeholder is a button then. */
  tapHandler?: () => void;
  /** False: the tap does nothing and the placeholder is not a button. */
  tapInteractionEnabled?: boolean;
}

/**
 * The error / empty placeholder: an animation or an icon, a title and a message, one accessibility element labelled with the
 * title and the message (a button when `tapHandler` is set and `tapInteractionEnabled`). The same names as the Flutter
 * package's `CYLPlaceholderView`.
 */
export function CYLPlaceholderView({
  style = CYLPlaceholderStyle.empty,
  title,
  message,
  image,
  animationFile,
  animationOptions = {},
  animationSize = { width: 120, height: 120 },
  animationPlaying = true,
  renderAnimation,
  titleColor,
  iconColor,
  backgroundColor,
  titleStyle,
  imageSize = 96,
  tapHandler,
  tapInteractionEnabled = true,
}: CYLPlaceholderViewProps) {
  const textColor = titleColor ?? '#6B6B70';
  let picture: ReactNode;
  if (animationFile !== undefined && renderAnimation !== undefined) {
    picture = (
      <View style={{ width: animationSize.width, height: animationSize.height }}>
        {renderAnimation({ file: animationFile, options: animationOptions, size: animationSize, playing: animationPlaying })}
      </View>
    );
  } else {
    picture = image ?? <Text style={{ fontSize: imageSize * 0.75, color: iconColor }}>{CYLPlaceholderStyleGlyphs[style]}</Text>;
  }
  const label = [title, message].filter((part): part is string => part !== undefined).join(', ');
  const tappable = tapHandler !== undefined && tapInteractionEnabled;
  const content = (
    <View
      accessible
      accessibilityLabel={label.length > 0 ? label : undefined}
      accessibilityRole={tappable ? 'button' : undefined}
      style={styles.content}
    >
      <View accessibilityElementsHidden importantForAccessibility="no-hide-descendants">
        {picture}
      </View>
      {title !== undefined ? <Text style={[styles.title, { color: textColor }, titleStyle]}>{title}</Text> : null}
      {message !== undefined ? <Text style={[styles.message, { color: textColor }]}>{message}</Text> : null}
    </View>
  );
  return (
    <View style={[styles.container, backgroundColor !== undefined ? { backgroundColor } : null]}>
      {tappable ? <Pressable onPress={tapHandler}>{content}</Pressable> : content}
    </View>
  );
}

/** A `CYLPlaceholderView` described by an item dictionary with the iOS keys (`CYLPlaceholderItemKey`). */
CYLPlaceholderView.fromItemAttributes = function fromItemAttributes(
  attributes: Record<string, unknown>,
  tapHandler?: () => void
): CYLPlaceholderViewProps {
  const values = cylPlaceholderValuesFromAttributes(attributes);
  return {
    style: values.style,
    title: values.title,
    message: values.message,
    animationFile: values.animationFile,
    animationSize: values.animationSize,
    titleColor: values.titleColor,
    iconColor: values.iconColor,
    backgroundColor: values.backgroundColor,
    tapHandler,
  };
};

/** The item description of a placeholder's props, with the iOS keys (`itemAttributes`). */
export function cylPlaceholderViewAttributes(props: Pick<CYLPlaceholderViewProps, 'style' | 'title' | 'message' | 'animationFile'>) {
  return cylPlaceholderItemAttributes({ style: props.style ?? CYLPlaceholderStyle.empty, title: props.title, message: props.message, animationFile: props.animationFile });
}

const styles = StyleSheet.create({
  container: { alignItems: 'center', justifyContent: 'center', padding: 24 },
  content: { alignItems: 'center' },
  title: { marginTop: 16, fontSize: 17, fontWeight: '600', textAlign: 'center' },
  message: { marginTop: 8, fontSize: 14, textAlign: 'center' },
});
