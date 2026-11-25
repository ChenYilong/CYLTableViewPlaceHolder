/** The edge a second floor belongs to: the header's floor (opened by a pull down) or the footer's (opened by a pull up). */
export type CYLRefreshSecondaryEdge = 'header' | 'footer';

/**
 * The edge named in a native `onSecondaryOpen` / `onSecondaryClose` event. The native iOS container sends `{edge}` in the body (React Native
 * wraps it as `nativeEvent`); Android sends none and has no footer floor, so a missing or unknown edge is `'header'`.
 */
export function cylSecondaryEdge(event: unknown): CYLRefreshSecondaryEdge {
  const body = (event as { nativeEvent?: { edge?: unknown } } | null | undefined)?.nativeEvent;
  return body?.edge === 'footer' ? 'footer' : 'header';
}
