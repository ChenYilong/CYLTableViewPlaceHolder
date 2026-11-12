package com.cyl.placeholder

import androidx.annotation.DrawableRes
import androidx.annotation.StringRes

/**
 * A ready-made placeholder (iOS `CYLPlaceholderScenario`). This first Android increment has the scenarios of the
 * "empty" category (iOS `CYLPlaceholderScenarioCategoryEmpty`); the other categories are `TODO` in docs/Android-Port.md.
 */
enum class CYLPlaceholderScenario(
    @DrawableRes internal val image: Int,
    internal val tinted: Boolean,
    internal val imageSide: Float,
    @StringRes internal val title: Int,
    @StringRes internal val hint: Int?,
    internal val button: CYLPlaceholderButtonStyle?,
    @StringRes internal val localizedName: Int,
) {
    /**
     * Nothing to show: the colored empty illustration and "Nothing here yet".
     */
    NoContent(R.drawable.cyl_placeholder_empty, false, ILLUSTRATION_SIDE, R.string.cyl_placeholder_scenario_no_content_title, null, null,
        R.string.cyl_placeholder_scenario_no_content_name),

    /**
     * A search found nothing: an icon, "No matching results" and a hint.
     */
    NoSearchResults(R.drawable.cyl_placeholder_search_off, true, ICON_SIDE, R.string.cyl_placeholder_scenario_no_search_results_title,
        R.string.cyl_placeholder_scenario_no_search_results_hint, null, R.string.cyl_placeholder_scenario_no_search_results_name),

    /**
     * An empty cart: an illustration, a title and an outlined "Go shopping" button.
     */
    EmptyCart(R.drawable.cyl_placeholder_empty_cart, true, ILLUSTRATION_SIDE, R.string.cyl_placeholder_scenario_empty_cart_title, null,
        CYLPlaceholderButtonStyle.Outlined, R.string.cyl_placeholder_scenario_empty_cart_name),

    /**
     * No orders: an icon, a title and a filled "Go shopping" button.
     */
    NoOrders(R.drawable.cyl_placeholder_archive, true, ICON_SIDE, R.string.cyl_placeholder_scenario_no_orders_title, null,
        CYLPlaceholderButtonStyle.Filled, R.string.cyl_placeholder_scenario_no_orders_name),

    /**
     * No favorites: an illustration, a title and a hint.
     */
    NoFavorites(R.drawable.cyl_placeholder_favorite, true, ILLUSTRATION_SIDE, R.string.cyl_placeholder_scenario_no_favorites_title,
        R.string.cyl_placeholder_scenario_no_favorites_hint, null, R.string.cyl_placeholder_scenario_no_favorites_name),

    /**
     * No messages: an icon and a title.
     */
    NoMessages(R.drawable.cyl_placeholder_inbox, true, ICON_SIDE, R.string.cyl_placeholder_scenario_no_messages_title, null, null,
        R.string.cyl_placeholder_scenario_no_messages_name),

    /**
     * No notifications: an icon, a title and a hint.
     */
    NoNotifications(R.drawable.cyl_placeholder_notifications_off, true, ICON_SIDE, R.string.cyl_placeholder_scenario_no_notifications_title,
        R.string.cyl_placeholder_scenario_no_notifications_hint, null, R.string.cyl_placeholder_scenario_no_notifications_name),
}

/**
 * The look of a scenario's button (iOS `CYLPlaceholderButtonStyle`).
 */
enum class CYLPlaceholderButtonStyle {
    /**
     * A filled button.
     */
    Filled,

    /**
     * A button with an outline.
     */
    Outlined,
}

/**
 * The actions of the scenarios' buttons (iOS `CYLPlaceholderAction`).
 */
object CYLPlaceholderAction {
    /**
     * "Go shopping" (EmptyCart, NoOrders).
     */
    const val GoShopping = "CYLPlaceholderActionGoShopping"
}

/**
 * The side of an icon in dp (iOS `CYLScenarioIconSide`).
 */
internal const val ICON_SIDE = 96f

/**
 * The side of an illustration in dp (iOS `CYLScenarioIllustrationSide`).
 */
internal const val ILLUSTRATION_SIDE = 160f
