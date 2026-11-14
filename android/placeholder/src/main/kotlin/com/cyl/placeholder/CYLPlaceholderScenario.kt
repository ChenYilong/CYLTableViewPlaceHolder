package com.cyl.placeholder

import android.content.Context
import androidx.annotation.DrawableRes
import androidx.annotation.StringRes

/**
 * The ready-made placeholder scenarios, in the iOS order (iOS `CYLPlaceholderScenario`); their components come from
 * [CYLPlaceholderScenarioCatalog.componentsForScenario].
 */
enum class CYLPlaceholderScenario {
    /**
     * The network seems slow.
     */
    NetworkUnavailable,

    /**
     * Nothing to show: the colored empty illustration and "Nothing here yet".
     */
    NoContent,

    /**
     * Network unavailable; tapping the screen reloads.
     */
    TapToReload,

    /**
     * Couldn't load the data, with a hint.
     */
    LoadFailedWithHint,

    /**
     * Not connected; tapping the screen reconnects.
     */
    TapToReconnect,

    /**
     * A filled "Retry" button.
     */
    RetryButton,

    /**
     * An outlined "Retry" button.
     */
    RetryOutlinedButton,

    /**
     * A hint and an outlined "Reload" button.
     */
    RetryWithHint,

    /**
     * "Retry", "or", "Contact support".
     */
    RetryOrContactSupport,

    /**
     * An illustration and a capsule "Tap to retry" button.
     */
    IllustrationRetry,

    /**
     * A refresh icon that retries.
     */
    RefreshIcon,

    /**
     * The title above an illustration.
     */
    TitleAboveIllustration,

    /**
     * Text only.
     */
    TextOnly,

    /**
     * "Tap me", an arrow and "Reload now…".
     */
    TapMeRetry,

    /**
     * Location access is off.
     */
    LocationPermissionDenied,

    /**
     * A search found nothing: an icon, "No matching results" and a hint.
     */
    NoSearchResults,

    /**
     * An empty cart: an illustration, a title and an outlined "Go shopping" button.
     */
    EmptyCart,

    /**
     * No orders: an icon, a title and a filled "Go shopping" button.
     */
    NoOrders,

    /**
     * No favorites: an illustration, a title and a hint.
     */
    NoFavorites,

    /**
     * No messages: an icon and a title.
     */
    NoMessages,

    /**
     * No notifications: an icon, a title and a hint.
     */
    NoNotifications,

    /**
     * A permission is missing (generic).
     */
    NoPermission,

    /**
     * Camera access is off.
     */
    CameraPermissionDenied,

    /**
     * Photo access is off.
     */
    PhotoLibraryPermissionDenied,

    /**
     * Microphone access is off.
     */
    MicrophonePermissionDenied,

    /**
     * Contacts access is off.
     */
    ContactsPermissionDenied,

    /**
     * Calendar access is off.
     */
    CalendarPermissionDenied,

    /**
     * Bluetooth access is off.
     */
    BluetoothPermissionDenied,

    /**
     * Notifications are off.
     */
    NotificationPermissionDenied,

    /**
     * The server is taking a break.
     */
    ServerError,

    /**
     * Sync failed.
     */
    SyncFailed,

    /**
     * Loading.
     */
    Loading,

    /**
     * Uploading.
     */
    Uploading,

    /**
     * Submitted, with "Done".
     */
    Success,

    /**
     * A loading HUD.
     */
    HUD,
}

/**
 * The group a scenario belongs to (iOS `CYLPlaceholderScenarioCategory`).
 */
enum class CYLPlaceholderScenarioCategory {
    /**
     * Loading failed.
     */
    LoadFailed,

    /**
     * Nothing to show.
     */
    Empty,

    /**
     * A permission is missing (not a network failure).
     */
    Permission,

    /**
     * Something is in progress.
     */
    Progress,

    /**
     * Something succeeded.
     */
    Success,
}

/**
 * The permission a scenario is about (iOS `CYLPlaceholderPermission`).
 */
enum class CYLPlaceholderPermission {
    /**
     * No particular permission.
     */
    None,

    /**
     * Location.
     */
    Location,

    /**
     * Camera.
     */
    Camera,

    /**
     * Photo library.
     */
    PhotoLibrary,

    /**
     * Microphone.
     */
    Microphone,

    /**
     * Contacts.
     */
    Contacts,

    /**
     * Calendar.
     */
    Calendar,

    /**
     * Bluetooth.
     */
    Bluetooth,

    /**
     * Notifications.
     */
    Notifications,
}

/**
 * The look of a button component (iOS `CYLPlaceholderButtonStyle`).
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

    /**
     * A filled, fully rounded button.
     */
    Capsule,
}

/**
 * The actions of the scenarios' buttons and taps (iOS `CYLPlaceholderAction`), with the iOS values.
 */
object CYLPlaceholderAction {
    /**
     * "Retry".
     */
    const val Retry = "CYLPlaceholderActionRetry"

    /**
     * "Contact support".
     */
    const val ContactSupport = "CYLPlaceholderActionContactSupport"

    /**
     * "Open Settings".
     */
    const val OpenSettings = "CYLPlaceholderActionOpenSettings"

    /**
     * "Go shopping" (EmptyCart, NoOrders).
     */
    const val GoShopping = "CYLPlaceholderActionGoShopping"

    /**
     * "Done".
     */
    const val Done = "CYLPlaceholderActionDone"

    /**
     * "Choose an address manually".
     */
    const val ChooseManually = "CYLPlaceholderActionChooseManually"
}

/**
 * Handles an action of a placeholder (iOS `CYLPlaceholderActionHandler`); it gets the action's name.
 */
typealias CYLPlaceholderActionHandler = (String) -> Unit

/**
 * The side of an icon in dp (iOS `CYLScenarioIconSide`).
 */
internal const val ICON_SIDE = 96f

/**
 * The side of an illustration in dp (iOS `CYLScenarioIllustrationSide`).
 */
internal const val ILLUSTRATION_SIDE = 160f

/**
 * The scenarios' components, names, categories and permissions (iOS `CYLPlaceholderScenarioCatalog`).
 */
object CYLPlaceholderScenarioCatalog {

    /**
     * Every scenario, in order (`allScenarios`).
     */
    @JvmStatic
    val allScenarios: List<CYLPlaceholderScenario> = CYLPlaceholderScenario.entries

    private val permissionScenarios = listOf(
        CYLPlaceholderScenario.NoPermission,
        CYLPlaceholderScenario.LocationPermissionDenied,
        CYLPlaceholderScenario.CameraPermissionDenied,
        CYLPlaceholderScenario.PhotoLibraryPermissionDenied,
        CYLPlaceholderScenario.MicrophonePermissionDenied,
        CYLPlaceholderScenario.ContactsPermissionDenied,
        CYLPlaceholderScenario.CalendarPermissionDenied,
        CYLPlaceholderScenario.BluetoothPermissionDenied,
        CYLPlaceholderScenario.NotificationPermissionDenied,
    )

    /**
     * The scenario's name without the prefix ("RetryButton") (`nameForScenario:`).
     */
    @JvmStatic
    fun nameForScenario(scenario: CYLPlaceholderScenario): String = scenario.name

    /**
     * The scenario called [name], with or without the "CYLPlaceholderScenario" prefix, in any case
     * (`scenarioNamed:`); null when there is none.
     */
    @JvmStatic
    fun scenarioNamed(name: String?): CYLPlaceholderScenario? {
        if (name.isNullOrEmpty()) return null
        val plain = name.lowercase().removePrefix("cylplaceholderscenario")
        return allScenarios.firstOrNull { it.name.lowercase() == plain }
    }

    /**
     * The action called [name] ("retry" or "CYLPlaceholderActionRetry", any case); an unknown name is returned as it
     * is (`actionNamed:`).
     */
    @JvmStatic
    fun actionNamed(name: String): String {
        val actions = mapOf(
            "retry" to CYLPlaceholderAction.Retry,
            "contactsupport" to CYLPlaceholderAction.ContactSupport,
            "opensettings" to CYLPlaceholderAction.OpenSettings,
            "goshopping" to CYLPlaceholderAction.GoShopping,
            "done" to CYLPlaceholderAction.Done,
            "choosemanually" to CYLPlaceholderAction.ChooseManually,
        )
        return actions[name.lowercase().removePrefix("cylplaceholderaction")] ?: name
    }

    /**
     * The localized title of an action's button, or null for an unknown action (`localizedTitleForAction:`).
     */
    @JvmStatic
    fun localizedTitleForAction(context: Context, action: String): String? = localizedTitle(CYLPlaceholderLocalization.localizedContext(context), action)

    private fun localizedTitle(context: Context, action: String): String? = when (action) {
        CYLPlaceholderAction.Retry -> context.getString(R.string.cyl_placeholder_action_retry_title)
        CYLPlaceholderAction.ContactSupport -> context.getString(R.string.cyl_placeholder_action_contact_support_title)
        CYLPlaceholderAction.OpenSettings -> context.getString(R.string.cyl_placeholder_action_open_settings_title)
        CYLPlaceholderAction.GoShopping -> context.getString(R.string.cyl_placeholder_action_go_shopping_title)
        CYLPlaceholderAction.Done -> context.getString(R.string.cyl_placeholder_action_done_title)
        CYLPlaceholderAction.ChooseManually -> context.getString(R.string.cyl_placeholder_action_choose_manually_title)
        else -> null
    }

    /**
     * The scenario's localized name ("No search results"), for menus and accessibility (`localizedNameForScenario:`).
     */
    @JvmStatic
    fun localizedNameForScenario(context: Context, scenario: CYLPlaceholderScenario): String {
        // The resource names of scripts/import-ios-resources.py: "NoContent" -> no_content ("HUD" -> h_u_d).
        val key = "cyl_placeholder_scenario_" + scenario.name.replace(Regex("(?<!^)(?=[A-Z])"), "_").lowercase() + "_name"
        val id = context.resources.getIdentifier(key, "string", context.packageName)
        return if (id != 0) CYLPlaceholderLocalization.localizedContext(context).getString(id) else scenario.name
    }

    /**
     * The README screenshot numbers the scenario stands for (`readmeScreenshotNumbersForScenario:`).
     */
    @JvmStatic
    fun readmeScreenshotNumbersForScenario(scenario: CYLPlaceholderScenario): List<Int> = when (scenario) {
        CYLPlaceholderScenario.NetworkUnavailable -> listOf(4, 5, 6, 25, 36)
        CYLPlaceholderScenario.NoContent -> listOf(7, 9, 10)
        CYLPlaceholderScenario.TapToReload -> listOf(13, 14, 15, 24, 26, 28, 31, 32, 37, 42, 43)
        CYLPlaceholderScenario.LoadFailedWithHint -> listOf(21, 22, 27, 29)
        CYLPlaceholderScenario.TapToReconnect -> listOf(8)
        CYLPlaceholderScenario.RetryButton -> listOf(1, 2, 11, 19)
        CYLPlaceholderScenario.LocationPermissionDenied -> listOf(20)
        CYLPlaceholderScenario.RetryOutlinedButton -> listOf(33, 38, 39)
        CYLPlaceholderScenario.RetryWithHint -> listOf(16, 23, 40)
        CYLPlaceholderScenario.RetryOrContactSupport -> listOf(3)
        CYLPlaceholderScenario.IllustrationRetry -> listOf(18)
        CYLPlaceholderScenario.RefreshIcon -> listOf(12)
        CYLPlaceholderScenario.TitleAboveIllustration -> listOf(17)
        CYLPlaceholderScenario.TextOnly -> listOf(30, 41)
        CYLPlaceholderScenario.TapMeRetry -> listOf(34, 35)
        else -> emptyList()
    }

    /**
     * The action a tap anywhere on the placeholder runs, or null (`backgroundActionForScenario:`).
     */
    @JvmStatic
    fun backgroundActionForScenario(scenario: CYLPlaceholderScenario): String? = when (scenario) {
        CYLPlaceholderScenario.TapToReload, CYLPlaceholderScenario.TapToReconnect,
        CYLPlaceholderScenario.TitleAboveIllustration, CYLPlaceholderScenario.TextOnly -> CYLPlaceholderAction.Retry
        else -> null
    }

    /**
     * Every animation file name of every scenario, once.
     */
    internal fun allAnimationFileNames(): List<String> = CYLPlaceholderScenario.values().flatMap { animationFileNamesForScenario(it) }.distinct()

    /**
     * The iOS animation files of the scenario, its own icon first (`animationFileNamesForScenario:`). Android shows
     * the static icon of each component; the names are for apps that play the animations themselves.
     */
    @JvmStatic
    fun animationFileNamesForScenario(scenario: CYLPlaceholderScenario): List<String> {
        val own = iconFiles[scenario].orEmpty()
        val variants = when (scenario) {
            CYLPlaceholderScenario.NoContent -> listOf("CYLPlaceholderNoDrafts.json")
            CYLPlaceholderScenario.TapToReload -> listOf("CYLPlaceholderPullToRefresh.riv")
            CYLPlaceholderScenario.RetryOrContactSupport -> listOf("CYLPlaceholderContactSupport.json")
            CYLPlaceholderScenario.RefreshIcon -> listOf("CYLPlaceholderRefresh.json", "CYLPlaceholderPullToRefresh.riv")
            CYLPlaceholderScenario.TitleAboveIllustration -> listOf("CYLPlaceholderPullToRefresh.riv")
            CYLPlaceholderScenario.TapMeRetry -> listOf("CYLPlaceholderNoInternet.json")
            CYLPlaceholderScenario.LocationPermissionDenied -> listOf("CYLPlaceholderLocation.json")
            CYLPlaceholderScenario.NoFavorites -> listOf("CYLPlaceholderNoFavorites.gif", "CYLPlaceholderNoFavorites.json")
            CYLPlaceholderScenario.NoPermission -> listOf("CYLPlaceholderSettings.json")
            CYLPlaceholderScenario.SyncFailed -> listOf("CYLPlaceholderLoadingInfinity.json")
            CYLPlaceholderScenario.Loading -> listOf("CYLPlaceholderLoading.pag", "CYLPlaceholderLoading.riv", "CYLPlaceholderLoadingInfinity.json", "CYLPlaceholderProgress.pag")
            CYLPlaceholderScenario.Uploading -> listOf("CYLPlaceholderProgress.pag")
            CYLPlaceholderScenario.Success -> listOf("CYLPlaceholderSuccess.json", "CYLPlaceholderCelebrate.json")
            CYLPlaceholderScenario.HUD -> listOf("CYLRefreshMaterialSpinner.json", "CYLRefreshGradientSpinner.json", "CYLRefreshRing.gif", "CYLPlaceholderProgress.pag", "CYLRefreshIcon.riv")
            else -> emptyList()
        }
        return (own + variants).distinct()
    }

    private val iconFiles: Map<CYLPlaceholderScenario, List<String>> = mapOf(
        CYLPlaceholderScenario.NetworkUnavailable to listOf("CYLPlaceholderNoInternet.json"),
        CYLPlaceholderScenario.NoContent to listOf("CYLPlaceholderEmpty.json"),
        CYLPlaceholderScenario.TapToReload to listOf("CYLPlaceholderRefresh.json"),
        CYLPlaceholderScenario.LoadFailedWithHint to listOf("CYLPlaceholderLoadFailed.json"),
        CYLPlaceholderScenario.TapToReconnect to listOf("CYLPlaceholderNoInternet.json"),
        CYLPlaceholderScenario.RetryButton to listOf("CYLPlaceholderSad.json"),
        CYLPlaceholderScenario.RetryOutlinedButton to listOf("CYLPlaceholderLoadFailed.json"),
        CYLPlaceholderScenario.RetryWithHint to listOf("CYLPlaceholderNoInternet.json"),
        CYLPlaceholderScenario.RetryOrContactSupport to listOf("CYLPlaceholderServerError.json"),
        CYLPlaceholderScenario.IllustrationRetry to listOf("CYLPlaceholderCloudOff.json"),
        CYLPlaceholderScenario.RefreshIcon to listOf("CYLPlaceholderSad.json", "CYLPlaceholderRefresh.json"),
        CYLPlaceholderScenario.TitleAboveIllustration to listOf("CYLPlaceholderPullHint.pag"),
        CYLPlaceholderScenario.TapMeRetry to listOf("CYLPlaceholderTapHint.json", "CYLPlaceholderCloudOff.json"),
        CYLPlaceholderScenario.NoSearchResults to listOf("CYLPlaceholderNoResults.json"),
        CYLPlaceholderScenario.EmptyCart to listOf("CYLPlaceholderEmptyCart.json"),
        CYLPlaceholderScenario.NoOrders to listOf("CYLPlaceholderNoOrders.json"),
        CYLPlaceholderScenario.NoFavorites to listOf("CYLPlaceholderNoFavorites.pag"),
        CYLPlaceholderScenario.NoMessages to listOf("CYLPlaceholderNoMessages.json"),
        CYLPlaceholderScenario.NoNotifications to listOf("CYLPlaceholderNoNotifications.json"),
        CYLPlaceholderScenario.NoPermission to listOf("CYLPlaceholderNoPermission.json"),
        CYLPlaceholderScenario.LocationPermissionDenied to listOf("CYLPlaceholderLocationPermission.json"),
        CYLPlaceholderScenario.CameraPermissionDenied to listOf("CYLPlaceholderCameraPermission.json"),
        CYLPlaceholderScenario.PhotoLibraryPermissionDenied to listOf("CYLPlaceholderPhotoLibraryPermission.json"),
        CYLPlaceholderScenario.MicrophonePermissionDenied to listOf("CYLPlaceholderMicrophonePermission.json"),
        CYLPlaceholderScenario.ContactsPermissionDenied to listOf("CYLPlaceholderContactsPermission.json"),
        CYLPlaceholderScenario.CalendarPermissionDenied to listOf("CYLPlaceholderCalendarPermission.json"),
        CYLPlaceholderScenario.BluetoothPermissionDenied to listOf("CYLPlaceholderBluetoothPermission.json"),
        CYLPlaceholderScenario.NotificationPermissionDenied to listOf("CYLPlaceholderNotificationPermission.json"),
        CYLPlaceholderScenario.ServerError to listOf("CYLPlaceholderServerError.json"),
        CYLPlaceholderScenario.SyncFailed to listOf("CYLPlaceholderCloudOff.json"),
        CYLPlaceholderScenario.Loading to listOf("CYLPlaceholderLoading.json"),
        CYLPlaceholderScenario.Uploading to listOf("CYLPlaceholderUploading.gif"),
        CYLPlaceholderScenario.Success to listOf("CYLPlaceholderSuccess.riv"),
        CYLPlaceholderScenario.HUD to listOf("CYLRefreshActivity.gif"),
    )

    /**
     * The scenario's group (`categoryForScenario:`).
     */
    @JvmStatic
    fun categoryForScenario(scenario: CYLPlaceholderScenario): CYLPlaceholderScenarioCategory = when {
        scenario == CYLPlaceholderScenario.NoPermission || permissionForScenario(scenario) != CYLPlaceholderPermission.None ->
            CYLPlaceholderScenarioCategory.Permission
        scenario in setOf(
            CYLPlaceholderScenario.NoContent, CYLPlaceholderScenario.NoSearchResults, CYLPlaceholderScenario.EmptyCart,
            CYLPlaceholderScenario.NoOrders, CYLPlaceholderScenario.NoFavorites, CYLPlaceholderScenario.NoMessages,
            CYLPlaceholderScenario.NoNotifications,
        ) -> CYLPlaceholderScenarioCategory.Empty
        scenario == CYLPlaceholderScenario.Loading || scenario == CYLPlaceholderScenario.Uploading || scenario == CYLPlaceholderScenario.HUD ->
            CYLPlaceholderScenarioCategory.Progress
        scenario == CYLPlaceholderScenario.Success -> CYLPlaceholderScenarioCategory.Success
        else -> CYLPlaceholderScenarioCategory.LoadFailed
    }

    /**
     * The permission the scenario is about (`permissionForScenario:`).
     */
    @JvmStatic
    fun permissionForScenario(scenario: CYLPlaceholderScenario): CYLPlaceholderPermission {
        val index = permissionScenarios.indexOf(scenario)
        return if (index <= 0) CYLPlaceholderPermission.None else CYLPlaceholderPermission.entries[index]
    }

    /**
     * The scenario of a missing [permission]; None gives the generic NoPermission (`scenarioForPermission:`).
     */
    @JvmStatic
    fun scenarioForPermission(permission: CYLPlaceholderPermission): CYLPlaceholderScenario = permissionScenarios[permission.ordinal]

    /**
     * The scenario's components, in order, with its localized texts (`componentsForScenario:`); each icon is the static
     * fallback image of the iOS animation.
     */
    @JvmStatic
    fun componentsForScenario(context: Context, scenario: CYLPlaceholderScenario): List<CYLPlaceholderComponent> {
        // The texts follow CYLPlaceholderLocalization.language when one is set.
        val localized = CYLPlaceholderLocalization.localizedContext(context)
        fun t(@StringRes id: Int) = localized.getString(id)
        fun icon(@DrawableRes image: Int, @StringRes title: Int?, side: Float = ICON_SIDE, tinted: Boolean = true) =
            CYLPlaceholderComponent.icon(image, title?.let { t(it) }, side, tinted)
        fun hint(@StringRes id: Int) = CYLPlaceholderComponent.hintComponentWithText(t(id))
        fun button(action: String, style: CYLPlaceholderButtonStyle) =
            CYLPlaceholderComponent.buttonComponentWithTitle(localizedTitleForAction(context, action).orEmpty(), style, action)
        fun permission(@DrawableRes image: Int, @StringRes title: Int, @StringRes hintText: Int) =
            listOf(icon(image, title), hint(hintText), button(CYLPlaceholderAction.OpenSettings, CYLPlaceholderButtonStyle.Filled))
        return when (scenario) {
            CYLPlaceholderScenario.NetworkUnavailable -> listOf(icon(R.drawable.cyl_placeholder_wifi_off, R.string.cyl_placeholder_scenario_network_unavailable_title))
            CYLPlaceholderScenario.NoContent -> listOf(icon(R.drawable.cyl_placeholder_empty, R.string.cyl_placeholder_scenario_no_content_title, ILLUSTRATION_SIDE, tinted = false))
            CYLPlaceholderScenario.TapToReload -> listOf(icon(R.drawable.cyl_placeholder_refresh, R.string.cyl_placeholder_scenario_tap_to_reload_title))
            CYLPlaceholderScenario.LoadFailedWithHint -> listOf(
                icon(R.drawable.cyl_placeholder_error_outline, R.string.cyl_placeholder_scenario_load_failed_with_hint_title),
                hint(R.string.cyl_placeholder_scenario_load_failed_with_hint_hint),
            )
            CYLPlaceholderScenario.TapToReconnect -> listOf(
                icon(R.drawable.cyl_placeholder_signal_wifi_off, R.string.cyl_placeholder_scenario_tap_to_reconnect_title),
                hint(R.string.cyl_placeholder_scenario_tap_to_reconnect_hint),
            )
            CYLPlaceholderScenario.RetryButton -> listOf(
                icon(R.drawable.cyl_placeholder_no_internet, R.string.cyl_placeholder_scenario_retry_button_title),
                button(CYLPlaceholderAction.Retry, CYLPlaceholderButtonStyle.Filled),
            )
            CYLPlaceholderScenario.RetryOutlinedButton -> listOf(
                icon(R.drawable.cyl_placeholder_report_problem, R.string.cyl_placeholder_scenario_retry_outlined_button_title),
                button(CYLPlaceholderAction.Retry, CYLPlaceholderButtonStyle.Outlined),
            )
            CYLPlaceholderScenario.RetryWithHint -> listOf(
                icon(R.drawable.cyl_placeholder_wifi_off, R.string.cyl_placeholder_scenario_retry_with_hint_title),
                hint(R.string.cyl_placeholder_scenario_retry_with_hint_hint),
                CYLPlaceholderComponent.buttonComponentWithTitle(t(R.string.cyl_placeholder_scenario_reload_title), CYLPlaceholderButtonStyle.Outlined, CYLPlaceholderAction.Retry),
            )
            CYLPlaceholderScenario.RetryOrContactSupport -> listOf(
                icon(R.drawable.cyl_placeholder_cloud_off, R.string.cyl_placeholder_scenario_retry_or_contact_support_title),
                button(CYLPlaceholderAction.Retry, CYLPlaceholderButtonStyle.Filled),
                CYLPlaceholderComponent.separatorComponentWithText(t(R.string.cyl_placeholder_scenario_or_separator)),
                button(CYLPlaceholderAction.ContactSupport, CYLPlaceholderButtonStyle.Outlined).apply { spacingBefore = 14f },
            )
            CYLPlaceholderScenario.IllustrationRetry -> listOf(
                icon(R.drawable.cyl_placeholder_cloud_off, null, ILLUSTRATION_SIDE),
                CYLPlaceholderComponent.buttonComponentWithTitle(t(R.string.cyl_placeholder_scenario_tap_to_retry_title), CYLPlaceholderButtonStyle.Capsule, CYLPlaceholderAction.Retry),
            )
            CYLPlaceholderScenario.RefreshIcon -> listOf(
                icon(R.drawable.cyl_placeholder_help, R.string.cyl_placeholder_scenario_refresh_icon_title),
                CYLPlaceholderComponent.icon(R.drawable.cyl_placeholder_refresh, null, 44f, true, CYLPlaceholderAction.Retry).apply { spacingBefore = 28f },
            )
            CYLPlaceholderScenario.TitleAboveIllustration -> listOf(
                CYLPlaceholderComponent.text(t(R.string.cyl_placeholder_scenario_title_above_illustration_title)),
                icon(R.drawable.cyl_placeholder_refresh, null, ILLUSTRATION_SIDE),
            )
            CYLPlaceholderScenario.TextOnly -> listOf(
                CYLPlaceholderComponent.text(t(R.string.cyl_placeholder_scenario_text_only_title), sizeSp = 20f),
                hint(R.string.cyl_placeholder_scenario_text_only_hint),
            )
            CYLPlaceholderScenario.TapMeRetry -> listOf(
                CYLPlaceholderComponent.text(t(R.string.cyl_placeholder_scenario_tap_me_title), color = ACCENT),
                icon(R.drawable.cyl_placeholder_info, null, 36f).apply { spacingBefore = 4f },
                CYLPlaceholderComponent.buttonComponentWithTitle(t(R.string.cyl_placeholder_scenario_reload_now_title), CYLPlaceholderButtonStyle.Filled, CYLPlaceholderAction.Retry).apply { spacingBefore = 4f },
                icon(R.drawable.cyl_placeholder_cloud_off, null, 96f).apply { spacingBefore = 12f },
            )
            CYLPlaceholderScenario.NoSearchResults -> listOf(
                icon(R.drawable.cyl_placeholder_search_off, R.string.cyl_placeholder_scenario_no_search_results_title),
                hint(R.string.cyl_placeholder_scenario_no_search_results_hint),
            )
            CYLPlaceholderScenario.EmptyCart -> listOf(
                icon(R.drawable.cyl_placeholder_empty_cart, R.string.cyl_placeholder_scenario_empty_cart_title, ILLUSTRATION_SIDE),
                button(CYLPlaceholderAction.GoShopping, CYLPlaceholderButtonStyle.Outlined),
            )
            CYLPlaceholderScenario.NoOrders -> listOf(
                icon(R.drawable.cyl_placeholder_archive, R.string.cyl_placeholder_scenario_no_orders_title),
                button(CYLPlaceholderAction.GoShopping, CYLPlaceholderButtonStyle.Filled),
            )
            CYLPlaceholderScenario.NoFavorites -> listOf(
                icon(R.drawable.cyl_placeholder_favorite, R.string.cyl_placeholder_scenario_no_favorites_title, ILLUSTRATION_SIDE),
                hint(R.string.cyl_placeholder_scenario_no_favorites_hint),
            )
            CYLPlaceholderScenario.NoMessages -> listOf(icon(R.drawable.cyl_placeholder_inbox, R.string.cyl_placeholder_scenario_no_messages_title))
            CYLPlaceholderScenario.NoNotifications -> listOf(
                icon(R.drawable.cyl_placeholder_notifications_off, R.string.cyl_placeholder_scenario_no_notifications_title),
                hint(R.string.cyl_placeholder_scenario_no_notifications_hint),
            )
            CYLPlaceholderScenario.NoPermission -> listOf(
                icon(R.drawable.cyl_placeholder_locked, R.string.cyl_placeholder_scenario_no_permission_title),
                hint(R.string.cyl_placeholder_scenario_no_permission_hint),
                button(CYLPlaceholderAction.OpenSettings, CYLPlaceholderButtonStyle.Filled),
            )
            CYLPlaceholderScenario.LocationPermissionDenied -> permission(
                R.drawable.cyl_placeholder_location_off, R.string.cyl_placeholder_scenario_location_permission_denied_title,
                R.string.cyl_placeholder_scenario_location_permission_denied_hint,
            ) + CYLPlaceholderComponent.buttonComponentWithTitle(t(R.string.cyl_placeholder_scenario_choose_address_title), CYLPlaceholderButtonStyle.Outlined, CYLPlaceholderAction.ChooseManually).apply { spacingBefore = 12f }
            CYLPlaceholderScenario.CameraPermissionDenied -> permission(R.drawable.cyl_placeholder_video_off, R.string.cyl_placeholder_scenario_camera_permission_denied_title, R.string.cyl_placeholder_scenario_camera_permission_denied_hint)
            CYLPlaceholderScenario.PhotoLibraryPermissionDenied -> permission(R.drawable.cyl_placeholder_photo_library, R.string.cyl_placeholder_scenario_photo_library_permission_denied_title, R.string.cyl_placeholder_scenario_photo_library_permission_denied_hint)
            CYLPlaceholderScenario.MicrophonePermissionDenied -> permission(R.drawable.cyl_placeholder_music_off, R.string.cyl_placeholder_scenario_microphone_permission_denied_title, R.string.cyl_placeholder_scenario_microphone_permission_denied_hint)
            CYLPlaceholderScenario.ContactsPermissionDenied -> permission(R.drawable.cyl_placeholder_group_off, R.string.cyl_placeholder_scenario_contacts_permission_denied_title, R.string.cyl_placeholder_scenario_contacts_permission_denied_hint)
            CYLPlaceholderScenario.CalendarPermissionDenied -> permission(R.drawable.cyl_placeholder_event_busy, R.string.cyl_placeholder_scenario_calendar_permission_denied_title, R.string.cyl_placeholder_scenario_calendar_permission_denied_hint)
            CYLPlaceholderScenario.BluetoothPermissionDenied -> permission(R.drawable.cyl_placeholder_bluetooth_disabled, R.string.cyl_placeholder_scenario_bluetooth_permission_denied_title, R.string.cyl_placeholder_scenario_bluetooth_permission_denied_hint)
            CYLPlaceholderScenario.NotificationPermissionDenied -> permission(R.drawable.cyl_placeholder_notifications_off, R.string.cyl_placeholder_scenario_notification_permission_denied_title, R.string.cyl_placeholder_scenario_notification_permission_denied_hint)
            CYLPlaceholderScenario.ServerError -> listOf(
                icon(R.drawable.cyl_placeholder_cloud_off, R.string.cyl_placeholder_scenario_server_error_title),
                hint(R.string.cyl_placeholder_scenario_server_error_hint),
                button(CYLPlaceholderAction.Retry, CYLPlaceholderButtonStyle.Filled),
            )
            CYLPlaceholderScenario.SyncFailed -> listOf(
                icon(R.drawable.cyl_placeholder_sync_problem, R.string.cyl_placeholder_scenario_sync_failed_title),
                button(CYLPlaceholderAction.Retry, CYLPlaceholderButtonStyle.Outlined),
            )
            CYLPlaceholderScenario.Loading -> listOf(icon(R.drawable.cyl_placeholder_hourglass, R.string.cyl_placeholder_scenario_loading_title, ILLUSTRATION_SIDE))
            CYLPlaceholderScenario.Uploading -> listOf(icon(R.drawable.cyl_placeholder_upload_off, R.string.cyl_placeholder_scenario_uploading_title, ILLUSTRATION_SIDE))
            CYLPlaceholderScenario.Success -> listOf(
                icon(R.drawable.cyl_placeholder_info, R.string.cyl_placeholder_scenario_success_title, ILLUSTRATION_SIDE),
                button(CYLPlaceholderAction.Done, CYLPlaceholderButtonStyle.Filled),
            )
            CYLPlaceholderScenario.HUD -> listOf(icon(R.drawable.cyl_placeholder_hourglass, R.string.cyl_placeholder_scenario_h_u_d_title, 56f))
        }
    }
}
