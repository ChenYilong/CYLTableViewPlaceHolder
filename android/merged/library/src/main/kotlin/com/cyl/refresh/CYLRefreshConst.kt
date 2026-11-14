package com.cyl.refresh

/**
 * The iOS constants of `CYLRefreshConst.h`, with the same names and values (docs/Android-API-Map.md). Sizes are in dp
 * and durations in seconds, as on iOS; the text constants are the keys of the localized texts.
 */
object CYLRefreshConst {
    /**
     * The gap between the state label and the arrow, in dp.
     */
    const val CYLRefreshLabelLeftInset = 25f

    /**
     * The header's height, in dp.
     */
    const val CYLRefreshHeaderHeight = 54f

    /**
     * The footer's height, in dp.
     */
    const val CYLRefreshFooterHeight = 44f

    /**
     * The trailer's width, in dp.
     */
    const val CYLRefreshTrailWidth = 60f

    /**
     * The fast animation's duration, in seconds.
     */
    const val CYLRefreshFastAnimationDuration = 0.25

    /**
     * The slow animation's duration, in seconds.
     */
    const val CYLRefreshSlowAnimationDuration = 0.4

    /**
     * The key path of a scroll view's content offset (an iOS key-value observing name, kept for portable code).
     */
    const val CYLRefreshKeyPathContentOffset = "contentOffset"

    /**
     * The key path of a scroll view's content inset.
     */
    const val CYLRefreshKeyPathContentInset = "contentInset"

    /**
     * The key path of a scroll view's content size.
     */
    const val CYLRefreshKeyPathContentSize = "contentSize"

    /**
     * The key path of a pan gesture's state.
     */
    const val CYLRefreshKeyPathPanState = "state"

    /**
     * The default key under which a header stores its last update time.
     */
    const val CYLRefreshHeaderLastUpdatedTimeKey = "CYLRefreshHeaderLastUpdatedTimeKey"

    /**
     * Text key: the header at rest.
     */
    const val CYLRefreshHeaderIdleText = "CYLRefreshHeaderIdleText"

    /**
     * Text key: the header pulled past the trigger.
     */
    const val CYLRefreshHeaderPullingText = "CYLRefreshHeaderPullingText"

    /**
     * Text key: the header refreshing.
     */
    const val CYLRefreshHeaderRefreshingText = "CYLRefreshHeaderRefreshingText"

    /**
     * Text key: the trailer at rest.
     */
    const val CYLRefreshTrailerIdleText = "CYLRefreshTrailerIdleText"

    /**
     * Text key: the trailer pulled past the trigger.
     */
    const val CYLRefreshTrailerPullingText = "CYLRefreshTrailerPullingText"

    /**
     * Text key: the automatic footer at rest.
     */
    const val CYLRefreshAutoFooterIdleText = "CYLRefreshAutoFooterIdleText"

    /**
     * Text key: the automatic footer loading.
     */
    const val CYLRefreshAutoFooterRefreshingText = "CYLRefreshAutoFooterRefreshingText"

    /**
     * Text key: the automatic footer with no more data.
     */
    const val CYLRefreshAutoFooterNoMoreDataText = "CYLRefreshAutoFooterNoMoreDataText"

    /**
     * Text key: the back footer at rest.
     */
    const val CYLRefreshBackFooterIdleText = "CYLRefreshBackFooterIdleText"

    /**
     * Text key: the back footer pulled past the trigger.
     */
    const val CYLRefreshBackFooterPullingText = "CYLRefreshBackFooterPullingText"

    /**
     * Text key: the back footer loading.
     */
    const val CYLRefreshBackFooterRefreshingText = "CYLRefreshBackFooterRefreshingText"

    /**
     * Text key: the back footer with no more data.
     */
    const val CYLRefreshBackFooterNoMoreDataText = "CYLRefreshBackFooterNoMoreDataText"

    /**
     * Text key: the header after a successful refresh.
     */
    const val CYLRefreshHeaderFinishedText = "CYLRefreshHeaderFinishedText"

    /**
     * Text key: the header after a failed refresh.
     */
    const val CYLRefreshHeaderFailedText = "CYLRefreshHeaderFailedText"

    /**
     * Text key: the footer after a successful load.
     */
    const val CYLRefreshFooterFinishedText = "CYLRefreshFooterFinishedText"

    /**
     * Text key: the footer after a failed load.
     */
    const val CYLRefreshFooterFailedText = "CYLRefreshFooterFailedText"

    /**
     * Text key: the "last update" prefix.
     */
    const val CYLRefreshHeaderLastTimeText = "CYLRefreshHeaderLastTimeText"

    /**
     * Text key: "today" in the last update time.
     */
    const val CYLRefreshHeaderDateTodayText = "CYLRefreshHeaderDateTodayText"

    /**
     * Text key: no last update yet.
     */
    const val CYLRefreshHeaderNoneLastDateText = "CYLRefreshHeaderNoneLastDateText"

    /**
     * The name of the notice sent when the refresh texts' language changes.
     */
    const val CYLRefreshDidChangeLanguageNotification = "CYLRefreshDidChangeLanguageNotification"
}

/**
 * A refresh component's state (`CYLRefreshState`).
 */
enum class CYLRefreshState {
    /**
     * At rest.
     */
    Idle,

    /**
     * Pulled past the trigger: releasing refreshes.
     */
    Pulling,

    /**
     * Refreshing (or loading).
     */
    Refreshing,

    /**
     * Asked to refresh before it is on screen: it refreshes once shown.
     */
    WillRefresh,

    /**
     * A footer with no more data.
     */
    NoMoreData,
}

/**
 * How the component moves with the pull (`CYLRefreshScrollMode`); on Android, SmartRefreshLayout's spinner style.
 */
enum class CYLRefreshScrollMode {
    /**
     * Moves with the content (SpinnerStyle.Translate).
     */
    Move,

    /**
     * Stretches with the pull (SpinnerStyle.Scale).
     */
    Stretch,

    /**
     * Stays above the content (SpinnerStyle.FixedFront).
     */
    Front,

    /**
     * Stays behind the content (SpinnerStyle.FixedBehind).
     */
    Behind,
}

/**
 * Where a pull may start (`CYLRefreshTriggerMode`).
 */
enum class CYLRefreshTriggerMode {
    /**
     * Anywhere on the content.
     */
    Anywhere,

    /**
     * Only once the content is at its edge.
     */
    OnEdge,
}

/**
 * A refresh component's detailed phase (`CYLRefreshPhase`).
 */
enum class CYLRefreshPhase {
    /**
     * At rest.
     */
    Idle,

    /**
     * Pulled, not yet past the trigger.
     */
    PullToRefresh,

    /**
     * Pulled past the trigger.
     */
    ReleaseToRefresh,

    /**
     * Asked to refresh before it is on screen.
     */
    WillRefresh,

    /**
     * Released, opening to refresh.
     */
    Releasing,

    /**
     * Refreshing (or loading).
     */
    Refreshing,

    /**
     * The refresh ended; closing.
     */
    Finishing,

    /**
     * A footer with no more data.
     */
    NoMoreData,

    /**
     * Pulled past the second floor's trigger.
     */
    SecondaryArmed,

    /**
     * The second floor is open.
     */
    SecondaryOpen,

    /**
     * The second floor is closing.
     */
    SecondaryClosing,
}

/**
 * Called when a component starts refreshing (`CYLRefreshComponentRefreshingBlock`).
 */
typealias CYLRefreshComponentRefreshingBlock = () -> Unit

/**
 * Called once a refresh has begun (`CYLRefreshComponentBeginRefreshingCompletionBlock`).
 */
typealias CYLRefreshComponentBeginRefreshingCompletionBlock = () -> Unit

/**
 * Called once a refresh has ended and closed (`CYLRefreshComponentEndRefreshingCompletionBlock`).
 */
typealias CYLRefreshComponentEndRefreshingCompletionBlock = () -> Unit

/**
 * A plain action (`CYLRefreshComponentAction`).
 */
typealias CYLRefreshComponentAction = () -> Unit

/**
 * A handler given the component (`CYLRefreshComponentHandler`).
 */
typealias CYLRefreshComponentHandler = (CYLRefreshComponent) -> Unit
