package com.cyl.placeholder

import android.app.Activity
import android.content.Context
import android.content.res.Configuration
import android.graphics.Color
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.os.Handler
import android.os.Looper
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.LinearLayout
import java.util.Locale

/**
 * The language of the built-in texts (iOS `CYLPlaceholderLocalization`): the system's by default, or one you set.
 */
object CYLPlaceholderLocalization {
    /**
     * The languages the built-in texts come in (`supportedLanguages`).
     */
    @JvmStatic
    val supportedLanguages: List<String> = listOf("en", "zh-Hans", "zh-Hant", "ja", "ko", "ru", "uk")

    /**
     * The language to use, or null for the system's (`language`).
     */
    @JvmStatic
    var language: String? = null

    /**
     * The language now used: [language], else the system's when supported, else "en" (`effectiveLanguage`).
     */
    @JvmStatic
    val effectiveLanguage: String
        get() {
            language?.let { return it }
            val locale = Locale.getDefault()
            val tag = when {
                locale.language == "zh" && (locale.script == "Hant" || locale.country in setOf("TW", "HK", "MO")) -> "zh-Hant"
                locale.language == "zh" -> "zh-Hans"
                else -> locale.language
            }
            return if (tag in supportedLanguages) tag else "en"
        }

    /**
     * [context] in [language] (itself when none is set); the built-in texts are read through it.
     */
    @JvmStatic
    fun localizedContext(context: Context): Context {
        val tag = language ?: return context
        val configuration = Configuration(context.resources.configuration)
        configuration.setLocale(Locale.forLanguageTag(tag))
        return context.createConfigurationContext(configuration)
    }

    /**
     * The text of the iOS [key] ("CYLPlaceholderEmptyText"), or [fallback] (`localizedStringForKey:fallback:`).
     */
    @JvmStatic
    fun localizedStringForKey(context: Context, key: String, fallback: String?): String? {
        val name = key.removePrefix("CYLPlaceholder").replace(Regex("(?<!^)(?=[A-Z])"), "_").lowercase()
        val id = context.resources.getIdentifier("cyl_placeholder_$name", "string", context.packageName)
        return if (id != 0) localizedContext(context).getString(id) else fallback
    }
}

/**
 * How the device reaches the network (iOS `CYLPlaceholderNetworkStatus`).
 */
enum class CYLPlaceholderNetworkStatus {
    /** Not known yet. */
    Unknown,
    /** No network. */
    NotReachable,
    /** Cellular. */
    ReachableViaWWAN,
    /** Wi-Fi. */
    ReachableViaWiFi,
    /** Wired Ethernet. */
    ReachableViaWiredEthernet,
    /** Another transport (VPN, Bluetooth…). */
    ReachableViaOther,
}

/**
 * Called when the network status changes (iOS `CYLPlaceholderNetworkStatusBlock`).
 */
typealias CYLPlaceholderNetworkStatusBlock = (CYLPlaceholderNetworkStatus) -> Unit

/**
 * Watches the network (iOS `CYLPlaceholderNetworkMonitor`); the app needs the ACCESS_NETWORK_STATE permission, which
 * this library's manifest declares.
 */
class CYLPlaceholderNetworkMonitor private constructor(private val context: Context) {

    private val handler = Handler(Looper.getMainLooper())
    private var block: CYLPlaceholderNetworkStatusBlock? = null
    private var callback: ConnectivityManager.NetworkCallback? = null

    /** How the device reaches the network (`networkStatus`). */
    var networkStatus: CYLPlaceholderNetworkStatus = CYLPlaceholderNetworkStatus.Unknown
        private set

    /** Whether there is a network (`reachable`). */
    val reachable: Boolean
        get() = networkStatus != CYLPlaceholderNetworkStatus.NotReachable && networkStatus != CYLPlaceholderNetworkStatus.Unknown

    /** Whether Data Saver restricts the network (`constrained`). */
    var constrained: Boolean = false
        private set

    /** Whether the network is metered (`expensive`). */
    var expensive: Boolean = false
        private set

    /** Whether the monitor is watching (`monitoring`). */
    val monitoring: Boolean
        get() = callback != null

    private fun connectivity() = context.getSystemService(Context.CONNECTIVITY_SERVICE) as? ConnectivityManager

    /** Starts watching (`startMonitoring`). */
    fun startMonitoring() {
        if (callback != null) return
        val manager = connectivity() ?: return
        val made = object : ConnectivityManager.NetworkCallback() {
            override fun onCapabilitiesChanged(network: Network, capabilities: NetworkCapabilities) = update(capabilities)

            override fun onLost(network: Network) = update(null)
        }
        callback = made
        update(manager.getNetworkCapabilities(manager.activeNetwork))
        runCatching { manager.registerNetworkCallback(NetworkRequest.Builder().addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET).build(), made) }
    }

    /** Stops watching (`stopMonitoring`). */
    fun stopMonitoring() {
        val made = callback ?: return
        callback = null
        runCatching { connectivity()?.unregisterNetworkCallback(made) }
    }

    /** Calls [block] on the main thread when the status changes (`setNetworkStatusChangeBlock:`). */
    fun setNetworkStatusChangeBlock(block: CYLPlaceholderNetworkStatusBlock?) {
        this.block = block
    }

    internal fun update(capabilities: NetworkCapabilities?) {
        val status = when {
            capabilities == null -> CYLPlaceholderNetworkStatus.NotReachable
            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) -> CYLPlaceholderNetworkStatus.ReachableViaWiFi
            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) -> CYLPlaceholderNetworkStatus.ReachableViaWWAN
            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET) -> CYLPlaceholderNetworkStatus.ReachableViaWiredEthernet
            else -> CYLPlaceholderNetworkStatus.ReachableViaOther
        }
        expensive = capabilities != null && !capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_NOT_METERED)
        constrained = runCatching {
            android.os.Build.VERSION.SDK_INT >= 24 && connectivity()?.restrictBackgroundStatus == ConnectivityManager.RESTRICT_BACKGROUND_STATUS_ENABLED
        }.getOrDefault(false)
        if (status == networkStatus) return
        networkStatus = status
        handler.post { block?.invoke(status) }
    }

    /**
     * The shared monitor and the status names.
     */
    companion object {
        private var shared: CYLPlaceholderNetworkMonitor? = null

        /**
         * The shared monitor (`sharedMonitor`).
         */
        @JvmStatic
        fun sharedMonitor(context: Context): CYLPlaceholderNetworkMonitor =
            shared ?: CYLPlaceholderNetworkMonitor(context.applicationContext).also { shared = it }

        /**
         * A status's name for logs, as on iOS (`nameForStatus:`).
         */
        @JvmStatic
        fun nameForStatus(status: CYLPlaceholderNetworkStatus): String = when (status) {
            CYLPlaceholderNetworkStatus.Unknown -> "unknown"
            CYLPlaceholderNetworkStatus.NotReachable -> "not reachable"
            CYLPlaceholderNetworkStatus.ReachableViaWWAN -> "cellular"
            CYLPlaceholderNetworkStatus.ReachableViaWiFi -> "Wi-Fi"
            CYLPlaceholderNetworkStatus.ReachableViaWiredEthernet -> "wired Ethernet"
            CYLPlaceholderNetworkStatus.ReachableViaOther -> "other"
        }
    }
}

/**
 * Hears taps on a status view (iOS `CYLPlaceholderStatusViewDelegate`).
 */
interface CYLPlaceholderStatusViewDelegate {
    /** The status view was tapped (`statusViewClicked:`). */
    fun statusViewClicked(sender: CYLPlaceholderStatusView)
}

/**
 * Called when a status view is tapped (iOS `CYLPlaceholderStatusViewTapHandler`).
 */
typealias CYLPlaceholderStatusViewTapHandler = (CYLPlaceholderStatusView) -> Unit

/**
 * A banner with an icon and a text, by default "Network unavailable" (iOS `CYLPlaceholderStatusView`).
 */
class CYLPlaceholderStatusView @JvmOverloads constructor(context: Context, attributes: Map<String, Any>? = null) : FrameLayout(context) {

    /** Hears taps (`delegate`). */
    var delegate: CYLPlaceholderStatusViewDelegate? = null

    /** The icon and text (`placeholderView`). */
    val placeholderView: CYLPlaceholderView

    /** The text (`text`). */
    var text: String?
        get() = placeholderView.textLabel.text?.toString()
        set(value) {
            placeholderView.textLabel.text = value
            contentDescription = value
        }

    /** Called when the banner is tapped (`tapHandler`). */
    var tapHandler: CYLPlaceholderStatusViewTapHandler? = null

    init {
        val used = attributes ?: networkUnavailableItemAttributes(context)
        val density = resources.displayMetrics.density
        val image = (used["CYLPlaceholderItemImage"] as? Int)?.let { androidx.core.content.ContextCompat.getDrawable(context, it) }
        placeholderView = CYLPlaceholderView(context, image, used["CYLPlaceholderItemTitle"] as? CharSequence).apply {
            contentMargin = 8f
            defaultTitleFont = 15f
            defaultTitleColor = (used["CYLPlaceholderItemTitleColor"] as? Int) ?: Color.rgb(0x66, 0x66, 0x66)
            defaultIconColor = Color.rgb(0xFF, 0x3B, 0x30)
            imageView.layoutParams = imageView.layoutParams.apply { width = (20 * density).toInt(); height = (20 * density).toInt() }
            // A banner: the icon sits left of the text.
            ((imageView.parent as View).parent as LinearLayout).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER_VERTICAL
            }
            (textLabel.layoutParams as LinearLayout.LayoutParams).apply { topMargin = 0; leftMargin = (8 * density).toInt() }
        }
        setBackgroundColor(Color.rgb(0xFF, 0xF4, 0xE5))
        addView(placeholderView, LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT, Gravity.CENTER))
        contentDescription = text
        accessibilityLiveRegion = ACCESSIBILITY_LIVE_REGION_POLITE
        setOnClickListener {
            tapHandler?.invoke(this)
            delegate?.statusViewClicked(this)
        }
    }

    /**
     * The default banner's description.
     */
    companion object {
        /**
         * The attributes of the "Network unavailable" banner, with the iOS keys (`networkUnavailableItemAttributes`).
         */
        @JvmStatic
        fun networkUnavailableItemAttributes(context: Context): Map<String, Any> = mapOf(
            "CYLPlaceholderItemTitle" to CYLPlaceholderLocalization.localizedContext(context).getString(R.string.cyl_placeholder_status_network_unavailable),
            "CYLPlaceholderItemImage" to R.drawable.cyl_placeholder_status_fail,
            "CYLPlaceholderItemTitleColor" to Color.rgb(0x66, 0x66, 0x66),
        )
    }
}

/**
 * What an activity shows for its status (iOS `CYLPlaceholderStatusDisplay`); the values combine with `or`.
 */
object CYLPlaceholderStatusDisplay {
    /** Nothing. */
    const val None = 0

    /** The banner at the top. */
    const val StatusBar = 1

    /** The placeholder over the content. */
    const val Placeholder = 2

    /** Both. */
    const val All = StatusBar or Placeholder
}

private class ActivityStatus(val activity: Activity) {
    var statusView: CYLPlaceholderStatusView? = null
    var placeholder: View? = null
    var display = CYLPlaceholderStatusDisplay.None
    var showsWhenOffline = false
    var scrollView: View? = null
    var hidden = false
}

private fun Activity.status(): ActivityStatus {
    val root = window.decorView
    (root.getTag(R.id.cyl_placeholder_state) as? ActivityStatus)?.let { return it }
    return ActivityStatus(this).also { root.setTag(R.id.cyl_placeholder_state, it) }
}

/**
 * The activity's status banner (iOS `UIViewController.cyl_statusView`); the default one is made on first use, and
 * setting null goes back to it.
 */
var Activity.cyl_statusView: CYLPlaceholderStatusView
    get() = status().statusView ?: CYLPlaceholderStatusView(this).also { status().statusView = it }
    set(value) {
        val state = status()
        state.statusView?.let { (it.parent as? ViewGroup)?.removeView(it) }
        state.statusView = value
        cyl_setStatusDisplay(state.display, false)
    }

/**
 * The scrolling view the placeholder covers, or null for the whole content (`cyl_placeholderScrollView`).
 */
var Activity.cyl_placeholderScrollView: View?
    get() = status().scrollView
    set(value) { status().scrollView = value }

/**
 * What the activity shows now (`cyl_statusDisplay`).
 */
var Activity.cyl_statusDisplay: Int
    get() = status().display
    set(value) = cyl_setStatusDisplay(value, false)

/**
 * Shows the banner and / or the placeholder (`cyl_setStatusDisplay:animated:`).
 */
fun Activity.cyl_setStatusDisplay(display: Int, animated: Boolean) {
    val state = status()
    state.display = display
    val content = findViewById<ViewGroup>(android.R.id.content) ?: return
    val showPlaceholder = display and CYLPlaceholderStatusDisplay.Placeholder != 0 && !state.hidden
    if (showPlaceholder && state.placeholder == null) {
        val view = CYLPlaceholderStackView(this, CYLPlaceholderScenario.NetworkUnavailable).apply { setBackgroundColor(Color.WHITE) }
        state.placeholder = view
        content.addView(view, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
    } else if (!showPlaceholder) {
        state.placeholder?.let { content.removeView(it) }
        state.placeholder = null
    }
    val banner = cyl_statusView
    if (display and CYLPlaceholderStatusDisplay.StatusBar != 0) {
        if (banner.parent == null) {
            content.addView(banner, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT, Gravity.TOP))
            if (animated) {
                banner.alpha = 0f
                banner.animate().alpha(1f).setDuration(200).start()
            }
        }
        banner.bringToFront()
    } else {
        (banner.parent as? ViewGroup)?.removeView(banner)
    }
}

/**
 * Whether the banner shows by itself while the device is offline (`cyl_showsStatusViewWhenOffline`); it starts the
 * shared network monitor.
 */
var Activity.cyl_showsStatusViewWhenOffline: Boolean
    get() = status().showsWhenOffline
    set(value) {
        status().showsWhenOffline = value
        val monitor = CYLPlaceholderNetworkMonitor.sharedMonitor(this)
        if (!value) return
        monitor.setNetworkStatusChangeBlock { networkStatus ->
            if (!isFinishing && status().showsWhenOffline) {
                val offline = networkStatus == CYLPlaceholderNetworkStatus.NotReachable
                cyl_setStatusDisplay(if (offline) cyl_statusDisplay or CYLPlaceholderStatusDisplay.StatusBar else cyl_statusDisplay and CYLPlaceholderStatusDisplay.StatusBar.inv(), true)
            }
        }
        monitor.startMonitoring()
    }

/**
 * Hides the activity's placeholder even while its display asks for it (`cyl_placeholderHidden`).
 */
var Activity.cyl_placeholderHidden: Boolean
    get() = status().hidden
    set(value) {
        status().hidden = value
        cyl_setStatusDisplay(status().display, false)
    }
