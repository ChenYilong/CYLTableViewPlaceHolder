// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin; the JVM signatures match the Java version.
package com.scwang.smart.refresh.layout.constant

/**
 * Where a size came from and whether the component was told (`DimensionStatus`); a later source replaces an earlier one.
 */
class DimensionStatus private constructor(
    /**
     * The rank of the source.
     */
    @JvmField val ordinal: Int,
    /**
     * True once the component was told.
     */
    @JvmField val notified: Boolean,
) {
    /**
     * The same source, not told yet.
     */
    fun unNotify(): DimensionStatus {
        if (notified) {
            val prev = values[ordinal - 1]
            return if (!prev.notified) prev else DefaultUnNotify
        }
        return this
    }

    /**
     * The same source, told.
     */
    fun notified(): DimensionStatus = if (!notified) values[ordinal + 1] else this

    /**
     * True when [status] may replace this one.
     */
    fun canReplaceWith(status: DimensionStatus): Boolean =
        ordinal < status.ordinal || ((!notified || CodeExact == this) && ordinal == status.ordinal)

    /**
     * The sources.
     */
    companion object {
        /**
         * The default, not told.
         */
        @JvmField val DefaultUnNotify = DimensionStatus(0, false)

        /**
         * The default.
         */
        @JvmField val Default = DimensionStatus(1, true)

        /**
         * Measured from wrap_content, not told.
         */
        @JvmField val XmlWrapUnNotify = DimensionStatus(2, false)

        /**
         * Measured from wrap_content.
         */
        @JvmField val XmlWrap = DimensionStatus(3, true)

        /**
         * The view's exact XML height, not told.
         */
        @JvmField val XmlExactUnNotify = DimensionStatus(4, false)

        /**
         * The view's exact XML height.
         */
        @JvmField val XmlExact = DimensionStatus(5, true)

        /**
         * The layout's XML attribute, not told.
         */
        @JvmField val XmlLayoutUnNotify = DimensionStatus(6, false)

        /**
         * The layout's XML attribute.
         */
        @JvmField val XmlLayout = DimensionStatus(7, true)

        /**
         * Set in code, not told.
         */
        @JvmField val CodeExactUnNotify = DimensionStatus(8, false)

        /**
         * Set in code.
         */
        @JvmField val CodeExact = DimensionStatus(9, true)

        /**
         * Locked, not told.
         */
        @JvmField val DeadLockUnNotify = DimensionStatus(10, false)

        /**
         * Locked.
         */
        @JvmField val DeadLock = DimensionStatus(10, true)

        /**
         * Every status, by rank.
         */
        @JvmField val values = arrayOf(
            DefaultUnNotify, Default, XmlWrapUnNotify, XmlWrap, XmlExactUnNotify, XmlExact,
            XmlLayoutUnNotify, XmlLayout, CodeExactUnNotify, CodeExact, DeadLockUnNotify, DeadLock,
        )
    }
}

/**
 * The refresh layout's state (`RefreshState`).
 */
enum class RefreshState(role: Int, dragging: Boolean, opening: Boolean, finishing: Boolean, twoLevel: Boolean, releaseToOpening: Boolean) {
    /**
     * Idle.
     */
    None(0, false, false, false, false, false),

    /**
     * Pulling the header.
     */
    PullDownToRefresh(1, true, false, false, false, false),

    /**
     * Pulling the footer.
     */
    PullUpToLoad(2, true, false, false, false, false),

    /**
     * A header pull was canceled.
     */
    PullDownCanceled(1, false, false, false, false, false),

    /**
     * A footer pull was canceled.
     */
    PullUpCanceled(2, false, false, false, false, false),

    /**
     * Past the refresh trigger.
     */
    ReleaseToRefresh(1, true, false, false, false, true),

    /**
     * Past the load-more trigger.
     */
    ReleaseToLoad(2, true, false, false, false, true),

    /**
     * Past the second-floor trigger.
     */
    ReleaseToTwoLevel(1, true, false, false, true, true),

    /**
     * Released into the second floor.
     */
    TwoLevelReleased(1, false, false, false, true, false),

    /**
     * Released into refreshing.
     */
    RefreshReleased(1, false, false, false, false, false),

    /**
     * Released into loading.
     */
    LoadReleased(2, false, false, false, false, false),

    /**
     * Refreshing.
     */
    Refreshing(1, false, true, false, false, false),

    /**
     * Loading more.
     */
    Loading(2, false, true, false, false, false),

    /**
     * On the second floor.
     */
    TwoLevel(1, false, true, false, true, false),

    /**
     * Refreshing finished; closing.
     */
    RefreshFinish(1, false, false, true, false, false),

    /**
     * Loading finished; closing.
     */
    LoadFinish(2, false, false, true, false, false),

    /**
     * The second floor finished; closing.
     */
    TwoLevelFinish(1, false, false, true, true, false);

    /**
     * A header state.
     */
    @JvmField val isHeader: Boolean = role == 1

    /**
     * A footer state.
     */
    @JvmField val isFooter: Boolean = role == 2

    /**
     * A second-floor state.
     */
    @JvmField val isTwoLevel: Boolean = twoLevel

    /**
     * A dragging state.
     */
    @JvmField val isDragging: Boolean = dragging

    /**
     * An open state: Refreshing, Loading, TwoLevel.
     */
    @JvmField val isOpening: Boolean = opening

    /**
     * A finishing state.
     */
    @JvmField val isFinishing: Boolean = finishing

    /**
     * A release-to-open state.
     */
    @JvmField val isReleaseToOpening: Boolean = releaseToOpening

    /**
     * The footer's counterpart of a header state.
     */
    fun toFooter(): RefreshState = if (isHeader && !isTwoLevel) entries[ordinal + 1] else this

    /**
     * The header's counterpart of a footer state.
     */
    fun toHeader(): RefreshState = if (isFooter && !isTwoLevel) entries[ordinal - 1] else this
}

/**
 * How a header or footer moves with the pull (`SpinnerStyle`).
 */
open class SpinnerStyle protected constructor(
    /**
     * The style's index.
     */
    @JvmField val ordinal: Int,
    /**
     * In front of the content.
     */
    @JvmField val front: Boolean,
    /**
     * Its height follows the pull.
     */
    @JvmField val scale: Boolean,
) {
    /**
     * The styles.
     */
    companion object {
        /**
         * Moves with the pull.
         */
        @JvmField val Translate = SpinnerStyle(0, true, false)

        /**
         * Stretches with the pull.
         */
        @Deprecated("Scale is kept for compatibility.")
        @JvmField val Scale = SpinnerStyle(1, true, true)

        /**
         * Stays behind the content.
         */
        @JvmField val FixedBehind = SpinnerStyle(2, false, false)

        /**
         * Stays in front of the content.
         */
        @JvmField val FixedFront = SpinnerStyle(3, true, false)

        /**
         * Fills the layout.
         */
        @JvmField val MatchLayout = SpinnerStyle(4, true, false)

        /**
         * Every style, by index.
         */
        @Suppress("DEPRECATION")
        @JvmField val values = arrayOf(Translate, Scale, FixedBehind, FixedFront, MatchLayout)
    }
}
