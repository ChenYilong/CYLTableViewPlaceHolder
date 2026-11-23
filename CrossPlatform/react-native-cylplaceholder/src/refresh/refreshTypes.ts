/**
 * The detailed phase of a refresh component, like Android's `CYLRefreshPhase` and the Flutter package's enum of the same
 * name. A constant object plus a union type, so the file also runs where TypeScript enums are not available.
 */
export const CYLRefreshPhase = {
  /** At rest. */
  idle: 'idle',
  /** Pulled, not yet past the trigger offset. */
  pullToRefresh: 'pullToRefresh',
  /** Pulled past the trigger offset: releasing starts the refresh. */
  releaseToRefresh: 'releaseToRefresh',
  /** Released, opening to refresh. */
  releasing: 'releasing',
  /** Refreshing (or loading). */
  refreshing: 'refreshing',
  /** The refresh ended; the component holds its result, then closes. */
  finishing: 'finishing',
} as const;

/** One of the `CYLRefreshPhase` values. */
export type CYLRefreshPhase = (typeof CYLRefreshPhase)[keyof typeof CYLRefreshPhase];

/** The coarse state of a refresh component, like Android's `CYLRefreshState`. */
export const CYLRefreshState = {
  /** At rest. */
  idle: 'idle',
  /** Being pulled (before or past the trigger). */
  pulling: 'pulling',
  /** Refreshing (or loading). */
  refreshing: 'refreshing',
  /** A footer with no more data. */
  noMoreData: 'noMoreData',
} as const;

/** One of the `CYLRefreshState` values. */
export type CYLRefreshState = (typeof CYLRefreshState)[keyof typeof CYLRefreshState];

/** How an indicator moves with the pull, like Android's `CYLRefreshScrollMode`. */
export const CYLRefreshScrollMode = {
  /** The indicator grows with the pull and the content moves down: the default. */
  move: 'move',
  /** The indicator floats over the content, which does not move. */
  front: 'front',
  /** The indicator stays behind the content, which moves away and reveals it. */
  behind: 'behind',
} as const;

/** One of the `CYLRefreshScrollMode` values. */
export type CYLRefreshScrollMode = (typeof CYLRefreshScrollMode)[keyof typeof CYLRefreshScrollMode];

/** Where a pull may start, like Android's `CYLRefreshTriggerMode`. */
export const CYLRefreshTriggerMode = {
  /** Anywhere on the content. */
  anywhere: 'anywhere',
  /** Only when the content is at its edge when the drag starts. */
  onEdge: 'onEdge',
} as const;

/** One of the `CYLRefreshTriggerMode` values. */
export type CYLRefreshTriggerMode = (typeof CYLRefreshTriggerMode)[keyof typeof CYLRefreshTriggerMode];

/** The texts a classic component shows, one per state. */
export const CYLRefreshTitleState = {
  /** Pulled, not yet past the trigger. */
  pullToRefresh: 'pullToRefresh',
  /** Pulled past the trigger. */
  releaseToRefresh: 'releaseToRefresh',
  /** Refreshing (or loading). */
  refreshing: 'refreshing',
  /** The refresh succeeded. */
  succeeded: 'succeeded',
  /** The refresh failed. */
  failed: 'failed',
  /** A footer with no more data. */
  noMoreData: 'noMoreData',
} as const;

/** One of the `CYLRefreshTitleState` values. */
export type CYLRefreshTitleState = (typeof CYLRefreshTitleState)[keyof typeof CYLRefreshTitleState];
