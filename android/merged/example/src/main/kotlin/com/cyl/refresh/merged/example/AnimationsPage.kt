package com.cyl.refresh.merged.example

import android.content.Context
import android.graphics.Color
import android.graphics.Typeface
import android.os.Handler
import android.os.Looper
import android.text.format.Formatter
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import com.cyl.placeholder.CYLPlaceholderAnimationView
import com.cyl.placeholder.CYLPlaceholderStackView

private fun Context.dp(value: Float) = (value * resources.displayMetrics.density).toInt()

/**
 * The Animations tab (iOS `CYLAnimationListViewController`): every animation of the core's assets folder
 * ([CYLPlaceholderStackView.ANIMATION_FOLDER]) grouped by engine, then the example's own `assets/Animations`. A row
 * plays its file; "Sources" shows the core's NOTICE.animations.
 */
class AnimationsPage : StackPage() {

    private class Section(val title: String, val folder: String, val fileNames: List<String>)

    private fun sections(context: Context): List<Section> {
        val core = CYLPlaceholderStackView.ANIMATION_FOLDER
        val names = context.assets.list(core).orEmpty().sorted()
        val sections = ENGINES.mapNotNull { (extension, title) ->
            names.filter { it.substringAfterLast('.') == extension }.takeIf { it.isNotEmpty() }?.let { Section(title, core, it) }
        }.toMutableList()
        // The example's own animations: no placeholder meaning (a mascot, a scene, widget demos, refresh styles).
        val own = context.assets.list(EXAMPLE_FOLDER).orEmpty().filter { it.substringAfterLast('.') in ENGINES.keys }.sorted()
        if (own.isNotEmpty()) sections += Section("assets/$EXAMPLE_FOLDER", EXAMPLE_FOLDER, own)
        return sections
    }

    override fun root(): View {
        val context = requireContext()
        val column = LinearLayout(context).apply { orientation = LinearLayout.VERTICAL }
        column.addView(LinearLayout(context).apply {
            gravity = Gravity.END
            addView(Button(context).apply {
                text = context.t(R.string.merged_action_sources)
                tag = "animation-sources"
                setOnClickListener { push(notice()) }
            })
        })
        val sections = sections(context)
        if (sections.isEmpty()) column.addView(header(context, context.t(R.string.merged_text_no_animations)))
        for (section in sections) {
            column.addView(header(context, section.title))
            for (name in section.fileNames) {
                val path = "${section.folder}/$name"
                val bytes = runCatching { context.assets.openFd(path).use { it.length } }
                    .getOrElse { context.assets.open(path).use { it.available().toLong() } }
                column.addView(row(context, name, Formatter.formatShortFileSize(context, bytes), "animation-$name") {
                    push(detail(section.folder, name))
                })
            }
        }
        return ScrollView(context).apply { setBackgroundColor(Color.WHITE); addView(column) }
    }

    private fun notice(): View {
        val context = requireContext()
        val text = runCatching {
            context.assets.open("${CYLPlaceholderStackView.ANIMATION_FOLDER}/NOTICE.animations").bufferedReader().use { it.readText() }
        }.getOrElse { context.t(R.string.merged_text_notice_missing) }
        val body = TextView(context).apply {
            this.text = text
            typeface = Typeface.MONOSPACE
            textSize = 11f
            setTextIsSelectable(true)
            setPadding(context.dp(12f), context.dp(8f), context.dp(12f), context.dp(8f))
        }
        return page(context, bar(context, "NOTICE.animations"), ScrollView(context).apply { addView(body) })
    }

    /**
     * One file in the middle of the page, with its name below; it replays every 4 seconds and on "Replay"
     * (iOS `CYLAnimationDetailViewController`).
     */
    private fun detail(folder: String, name: String): View {
        val context = requireContext()
        val side = context.dp(180f)
        val title = name.substringBeforeLast('.').replace("CYLPlaceholder", "").replace("CYLScenarioExample", "")
        val url = "asset:$folder/$name" + (RIVE_OPTIONS[name]?.let { "?$it" } ?: "")
        val animation = CYLPlaceholderAnimationView.withFileURL(context, url, side, side)?.apply {
            setAnimationRepeatCount(0)
            tag = "animation-view"
        }
        val handler = Handler(Looper.getMainLooper())
        val replay = object : Runnable {
            override fun run() {
                animation?.stop()
                animation?.play()
                handler.postDelayed(this, REPLAY_INTERVAL_MS)
            }
        }
        val content = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            if (animation != null) addView(animation, LinearLayout.LayoutParams(side, side))
            addView(TextView(context).apply {
                text = if (animation != null) title else "$title\n(no animator for .${name.substringAfterLast('.')})"
                textSize = 17f
                gravity = Gravity.CENTER
                setPadding(0, context.dp(12f), 0, 0)
            }, LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT))
            addOnAttachStateChangeListener(object : View.OnAttachStateChangeListener {
                override fun onViewAttachedToWindow(v: View) { handler.post(replay) }
                override fun onViewDetachedFromWindow(v: View) { handler.removeCallbacks(replay); animation?.stop() }
            })
        }
        val replayButton = Button(context).apply {
            text = context.t(R.string.merged_action_replay)
            setOnClickListener { animation?.stop(); animation?.play() }
        }
        return page(context, bar(context, name, replayButton), content)
    }

    private companion object {
        const val EXAMPLE_FOLDER = "Animations"
        const val REPLAY_INTERVAL_MS = 4000L

        /**
         * The engines in the order of the iOS page.
         */
        val ENGINES = linkedMapOf(
            "json" to "Lottie · placeholder-lottie",
            "pag" to "PAG · placeholder-pag",
            "riv" to "Rive · placeholder-rive",
            "gif" to "GIF · Core",
        )

        /**
         * The options some bundled Rive files need (iOS `CYLScenarioAnimationOptions`), as the Rive animator's query.
         */
        val RIVE_OPTIONS = mapOf(
            "CYLPlaceholderSuccess.riv" to "stateMachine=State%20Machine%201",
            "CYLRefreshIcon.riv" to "artboard=refresh&animation=active",
        )
    }
}
