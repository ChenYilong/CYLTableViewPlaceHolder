package com.cyl.placeholder

import android.app.Activity
import android.app.Application
import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.ContextWrapper
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.View
import java.lang.ref.WeakReference
import java.util.WeakHashMap

/**
 * Says which animation resource is missing in the status bar at the top of the page (iOS key
 * `CYLPlaceholderResourceMissing`): "Missing resource: home.pag (file not found)", through the activity's
 * [cyl_statusView] (the red bar below the action bar).
 *
 * One bar per activity, however many resources are missing: with more than one it names the first and counts the rest,
 * "Missing resources: home.pag +5 more". A resource is listed once (a second report of it does nothing), leaves the
 * list on [clear] (or when the resource later loads), and the whole list goes when the activity is destroyed.
 *
 * Network wins: while the activity's offline bar is showing ([cyl_showsStatusViewWhenOffline] and no network) the bar
 * keeps its network text; the resources show again once the network is back.
 *
 * The engine (CYLTabBarController's CYLAnimatedItem module) reports a missing file through
 * `CYLAnimatedItemView.onResourceMissing` and `CYLAnimationEngines.resourceMissingListener`. This class does not name
 * them at compile time (a commit of the engine without them must still build), so [installEngineListener] and
 * [attach] find them by reflection and do nothing when they are absent. Once every commit that can be resolved has
 * them, a direct call replaces the reflection. Proguard / R8: keep `CYLAnimationEngines.setResourceMissingListener`
 * and `CYLAnimatedItemView.setOnResourceMissing` in a minified app.
 *
 * All calls may come from any thread; the work happens on the main thread.
 */
object CYLPlaceholderResourceMonitor {

    private const val TAG = "CYLPlaceholderResource"
    private const val ENGINES_CLASS = "com.cyl.animateditem.CYLAnimationEngines"

    private class State {
        val missing = LinkedHashMap<String, String>()
        /** The bar's text before this monitor replaced it. */
        var savedText: String? = null
        var overriding = false
        /** Whether this monitor turned the bar on (the activity's display did not ask for it). */
        var addedBar = false
    }

    private val states = WeakHashMap<Activity, State>()
    private var observed: WeakReference<Application>? = null
    private var resumed: WeakReference<Activity>? = null
    private val handler by lazy { Handler(Looper.getMainLooper()) }

    /**
     * The guard of the red bar's logic. null (the default): it runs only in a debuggable app ([ApplicationInfo.FLAG_DEBUGGABLE],
     * which the app's build type sets when it is built; a library's own BuildConfig.DEBUG is always false once an app uses
     * it), so a release build reports nothing. true / false force it (tests, or a host that wants the bar in a release build).
     */
    @JvmStatic
    var enabled: Boolean? = null

    private fun active(context: Context?): Boolean {
        enabled?.let { return it }
        val info = (context?.applicationContext ?: context)?.applicationInfo ?: return false
        return info.flags and ApplicationInfo.FLAG_DEBUGGABLE != 0
    }

    // The engine's class name; a test points it at a stand-in or at a class that does not exist.
    internal var enginesClassName = ENGINES_CLASS

    private val callbacks = object : Application.ActivityLifecycleCallbacks {
        override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {}
        override fun onActivityStarted(activity: Activity) { resumed = WeakReference(activity) }
        override fun onActivityResumed(activity: Activity) { resumed = WeakReference(activity) }
        override fun onActivityPaused(activity: Activity) {}
        override fun onActivityStopped(activity: Activity) {}
        override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}
        override fun onActivityDestroyed(activity: Activity) {
            states.remove(activity)
            if (resumed?.get() === activity) resumed = null
        }
    }

    /**
     * Lists [resource] (a file or asset name, "asset:Folder/home.pag" becomes "home.pag") as missing for [reason] ("file
     * not found", "unreadable", "no runtime") and shows it in [activity]'s status bar; a resource already listed is
     * ignored. A null [activity] means the activity in front.
     */
    @JvmStatic
    fun report(activity: Activity?, resource: String, reason: String) = onMain {
        val target = activity ?: resumed?.get()
        if (!active(target)) return@onMain
        val name = nameOf(resource)
        if (target == null) {
            Log.d(TAG, "Missing resource: $name ($reason), no activity to show it in")
            return@onMain
        }
        observe(target)
        val state = states.getOrPut(target) { State() }
        if (name in state.missing) return@onMain
        state.missing[name] = reason
        render(target, state)
    }

    /**
     * Takes [resource] off the list (it loaded, or is no longer wanted) and hides the bar when the list is empty. A
     * null [activity] means the activity in front.
     */
    @JvmStatic
    fun clear(activity: Activity?, resource: String) = onMain {
        val target = activity ?: resumed?.get() ?: return@onMain
        if (!active(target)) return@onMain
        val state = states[target] ?: return@onMain
        if (state.missing.remove(nameOf(resource)) != null) render(target, state)
    }

    /**
     * The names now listed as missing for [activity], first reported first.
     */
    @JvmStatic
    fun missingResources(activity: Activity): List<String> = states[activity]?.missing?.keys?.toList().orEmpty()

    /**
     * Sets the engine's global `CYLAnimationEngines.resourceMissingListener` so every missing resource of the engine
     * reaches [report], for the activity in front. [context] (when it is, or wraps, an activity or the application) starts
     * tracking the activity in front now rather than at the first report. False when the engine has no such listener
     * (an older commit, or no engine class): nothing is changed and one debug line is logged.
     */
    @JvmStatic
    @JvmOverloads
    fun installEngineListener(context: Context? = null): Boolean {
        if (context != null && !active(context)) return false
        context?.let { observe(it) }
        return try {
            val type = Class.forName(enginesClassName)
            val setter = type.methods.firstOrNull { it.name == "setResourceMissingListener" && it.parameterTypes.size == 1 }
            if (setter == null) {
                Log.d(TAG, "$enginesClassName has no resourceMissingListener; the engine is older than the hook")
                return false
            }
            val instance = runCatching { type.getField("INSTANCE").get(null) }.getOrNull()
            val listener: (String, String) -> Unit = { resource, reason -> report(null, resource, reason) }
            setter.invoke(instance, listener)
            true
        } catch (error: Throwable) {
            Log.d(TAG, "No engine hook for missing resources: $error")
            false
        }
    }

    /**
     * Sets `onResourceMissing` of [view] (a CYLAnimatedItemView, such as a CYLPlaceholderView) so what it reports is
     * listed for the activity of its context. False when [view] has no such property (an older engine, or another
     * view): nothing is changed.
     */
    @JvmStatic
    fun attach(view: View): Boolean {
        if (!active(view.context)) return false
        val setter = view.javaClass.methods.firstOrNull { it.name == "setOnResourceMissing" && it.parameterTypes.size == 1 }
        if (setter == null) {
            Log.d(TAG, "${view.javaClass.name} has no onResourceMissing; the engine is older than the hook")
            return false
        }
        val listener: (String, String) -> Unit = { resource, reason -> report(activityOf(view.context), resource, reason) }
        return try {
            setter.invoke(view, listener)
            true
        } catch (error: Throwable) {
            Log.d(TAG, "Could not set onResourceMissing: $error")
            false
        }
    }

    // After the network bar changed: its text wins while offline, the resources come back after.
    internal fun refresh(activity: Activity) = onMain {
        states[activity]?.let { render(activity, it) }
    }

    internal fun resetForTests() {
        states.clear()
        resumed = null
        observed = null
        enabled = null
        enginesClassName = ENGINES_CLASS
    }

    internal fun activityOf(context: Context?): Activity? {
        var current = context
        while (current is ContextWrapper) {
            if (current is Activity) return current
            current = current.baseContext
        }
        return null
    }

    private fun nameOf(resource: String): String {
        val name = resource.substringBefore('#').substringBefore('?').substringAfterLast('/').substringAfterLast(':')
        return name.ifEmpty { resource }
    }

    private fun onMain(block: () -> Unit) {
        if (Looper.myLooper() == Looper.getMainLooper()) block() else handler.post(block)
    }

    private fun observe(context: Context) {
        activityOf(context)?.let { if (resumed?.get() == null) resumed = WeakReference(it) }
        val app = context.applicationContext as? Application ?: return
        if (observed?.get() === app) return
        app.registerActivityLifecycleCallbacks(callbacks)
        observed = WeakReference(app)
    }

    private fun offlineBarShowing(activity: Activity): Boolean =
        activity.cyl_showsStatusViewWhenOffline &&
            CYLPlaceholderNetworkMonitor.sharedMonitor(activity).networkStatus == CYLPlaceholderNetworkStatus.NotReachable

    private fun render(activity: Activity, state: State) {
        val banner = activity.cyl_statusView
        val offline = offlineBarShowing(activity)
        if (state.missing.isEmpty() || offline) {
            if (state.overriding) {
                banner.text = state.savedText
                state.overriding = false
            }
            // Offline, the bar belongs to the network handler now; with nothing missing it goes if this monitor turned it on.
            if (offline) state.addedBar = false
            if (state.missing.isEmpty() && state.addedBar) {
                state.addedBar = false
                activity.cyl_statusDisplay = activity.cyl_statusDisplay and CYLPlaceholderStatusDisplay.StatusBar.inv()
            }
            return
        }
        if (!state.overriding) {
            state.savedText = banner.text
            state.overriding = true
        }
        banner.text = messageOf(activity, state.missing)
        if (activity.cyl_statusDisplay and CYLPlaceholderStatusDisplay.StatusBar == 0) {
            state.addedBar = true
            activity.cyl_setStatusDisplay(activity.cyl_statusDisplay or CYLPlaceholderStatusDisplay.StatusBar, false)
        }
    }

    private fun messageOf(activity: Activity, missing: Map<String, String>): String {
        val context = CYLPlaceholderLocalization.localizedContext(activity)
        val first = missing.entries.first()
        return if (missing.size == 1) context.getString(R.string.cyl_placeholder_resource_missing, first.key, first.value)
        else context.getString(R.string.cyl_placeholder_resources_missing, first.key, missing.size - 1)
    }
}
