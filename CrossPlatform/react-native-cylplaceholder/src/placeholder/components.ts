import type { CYLPlaceholderStyle } from './attributes.ts';

/** The kinds of a placeholder component, the `type` key of the configuration dictionary (`docs/Placeholder-Scenarios.md`). */
export type CYLPlaceholderComponentType = 'icon' | 'hint' | 'button' | 'separator' | 'item';

/** How a button is drawn. */
export type CYLPlaceholderButtonStyle = 'filled' | 'outlined' | 'capsule';

/**
 * One component of a placeholder stack or a HUD, as the configuration dictionary the native `CYLPlaceholderStackView` and
 * `CYLPlaceholderHUD` read (the same keys on iOS and Android). The names match the Flutter package's `CYLPlaceholderComponent`
 * (`title`, `style`, `animationLoops`, `animationSpeed`, `buttonStyle`, `interactionEnabled`, `spacingBefore`); `action` is an
 * action name that comes back through `onAction`, and `animation` names a bundled animation file.
 */
export interface CYLPlaceholderComponent {
  type: CYLPlaceholderComponentType;
  /** The title, or the text of a hint, button or separator. */
  title?: string;
  /** The built-in icon of an `icon` component. */
  style?: CYLPlaceholderStyle;
  /** A bundled animation file name; it plays over the style's icon. */
  animation?: string;
  /** The animation's size in points: `[width, height]`, or one number for a square. */
  size?: [number, number] | number;
  /** Whether the animation plays again after each pass. */
  animationLoops?: boolean;
  /** The playback rate; 1 is the file's own speed. */
  animationSpeed?: number;
  /** How a `button` is drawn. */
  buttonStyle?: CYLPlaceholderButtonStyle;
  /** The name `onAction` receives when a button or an icon is tapped. */
  action?: string;
  /** False: the component is shown but inert. */
  interactionEnabled?: boolean;
  /** The space above the component in points. */
  spacingBefore?: number;
  /** The identifier tests find the component by. */
  accessibilityIdentifier?: string;
}

type Extras<K extends keyof CYLPlaceholderComponent> = Omit<CYLPlaceholderComponent, 'type' | K>;

/**
 * Builders for the usual components, named as the Flutter package's `CYLPlaceholderComponent` constructors. They return the
 * dictionary; undefined values are left out so the native defaults apply.
 */
export const CYLPlaceholderComponent = {
  /** An icon or animation with an optional title. */
  icon(options: Extras<never> = {}): CYLPlaceholderComponent {
    return clean({ type: 'icon', ...options });
  },
  /** A line of secondary text. */
  hint(text: string, options: Pick<CYLPlaceholderComponent, 'spacingBefore'> = {}): CYLPlaceholderComponent {
    return clean({ type: 'hint', title: text, ...options });
  },
  /** A button; its `action` name comes back through `onAction`. */
  button(title: string, action: string, options: Extras<'title' | 'action'> = {}): CYLPlaceholderComponent {
    return clean({ type: 'button', title, action, ...options });
  },
  /** A line with `text` in the middle. */
  separator(text: string, options: Pick<CYLPlaceholderComponent, 'spacingBefore'> = {}): CYLPlaceholderComponent {
    return clean({ type: 'separator', title: text, ...options });
  },
};

function clean(component: CYLPlaceholderComponent): CYLPlaceholderComponent {
  const result: Record<string, unknown> = {};
  for (const [key, value] of Object.entries(component)) if (value !== undefined) result[key] = value;
  return result as unknown as CYLPlaceholderComponent;
}
