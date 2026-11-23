/// The detailed phase of a refresh component, like Android's `CYLRefreshPhase`.
enum CYLRefreshPhase {
  /// At rest.
  idle,

  /// Pulled, not yet past the trigger offset.
  pullToRefresh,

  /// Pulled past the trigger offset: releasing starts the refresh.
  releaseToRefresh,

  /// Released, opening to refresh.
  releasing,

  /// Refreshing (or loading).
  refreshing,

  /// The refresh ended; the component holds its result, then closes.
  finishing,
}

/// The coarse state of a refresh component, like Android's `CYLRefreshState`.
enum CYLRefreshState {
  /// At rest.
  idle,

  /// Being pulled (before or past the trigger).
  pulling,

  /// Refreshing (or loading).
  refreshing,

  /// A footer with no more data.
  noMoreData,
}

/// How an indicator moves with the pull, like Android's `CYLRefreshScrollMode`.
enum CYLRefreshScrollMode {
  /// The indicator grows with the pull and the content moves down: the default.
  move,

  /// The indicator floats over the content, which does not move.
  front,

  /// The indicator stays behind the content, which moves away and reveals it.
  behind,
}

/// Where a pull may start, like Android's `CYLRefreshTriggerMode`.
enum CYLRefreshTriggerMode {
  /// Anywhere on the content.
  anywhere,

  /// Only when the content is at its edge when the drag starts.
  onEdge,
}

/// The texts a classic component shows, one per state.
enum CYLRefreshTitleState {
  /// Pulled, not yet past the trigger.
  pullToRefresh,

  /// Pulled past the trigger.
  releaseToRefresh,

  /// Refreshing (or loading).
  refreshing,

  /// The refresh succeeded.
  succeeded,

  /// The refresh failed.
  failed,

  /// A footer with no more data.
  noMoreData,
}
