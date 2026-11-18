package com.cyl.refresh.merged.example

import android.content.Context
import android.graphics.Color
import android.graphics.Typeface
import android.text.format.Formatter
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import com.cyl.placeholder.CYLPlaceholderStackView
import com.cyl.animateditem.CYLAnimatedItemAxis
import com.cyl.animateditem.CYLAnimatedItemView
import com.cyl.animateditem.CYLSize

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
     * One file in the middle of the page, with its name below (iOS `CYLAnimationDetailViewController`), and the
     * playback controls of `docs/Example-Animation-Playback.md` under it: "Play all" restarts from frame 0, the speed
     * slider sets 0.25x to 3x live, the loop switch plays for ever or once. The icon and the title are one plain
     * [CYLAnimatedItemView] (instructions.md, "Icon and title: CYLAnimatedItemView"); all three controls are its own
     * properties ([CYLAnimatedItemView.animationSpeed], [CYLAnimatedItemView.animationLoops],
     * [CYLAnimatedItemView.restartAnimation]). GIF follows them too since CYLTabBarController ad385a5a (B24).
     */
    private fun detail(folder: String, name: String): View {
        val context = requireContext()
        val side = 180f
        val title = name.substringBeforeLast('.').replace("CYLPlaceholder", "").replace("CYLScenarioExample", "")
        val url = "file:///android_asset/$folder/$name" + (RIVE_OPTIONS[name]?.let { "#$it" } ?: "")
        // CYLTabBarController's animated icon + title view: it plays the file through the CYLAnimatedItem engine, which
        // finds this app's Lottie, libpag and rive-android by reflection (GIF is decoded by the platform).
        val item = CYLAnimatedItemView(context).apply {
            axis = CYLAnimatedItemAxis.Vertical
            iconSizeDp = CYLSize(side, side)
            spacingDp = 16f
            animationLoops = true
            this.title = title
            titleView.maxLines = Int.MAX_VALUE
            titleView.setTextSize(android.util.TypedValue.COMPLEX_UNIT_SP, 17f)
            titleView.typeface = Typeface.create("sans-serif-medium", Typeface.NORMAL)
            tag = "animation-view"
            animationURL = url
        }
        if (name in DARK_BACKDROP_FILES) {
            // White artwork made for the file's black composition background, which PAGView does not draw (libpag has
            // no background API): the item shows it on a black backdrop with a white title (docs/Task-Log.md, the
            // Moonlight.pag dark backdrop task; the same on iOS, HarmonyOS and the mini program).
            item.setBackgroundColor(Color.BLACK)
            item.titleView.setTextColor(Color.WHITE)
            val inset = context.dp(16f)
            item.setPadding(inset, inset, inset, inset)
        }
        val playable = item.isAnimationReady
        if (!playable) item.title = "$title\n(no animator for .${name.substringAfterLast('.')})"
        val playFromStart = { item.stopAnimation(); item.restartAnimation() }
        val content = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            addView(item, LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT))
            if (playable) addView(playbackControls(context, onPlayAll = playFromStart, onSpeed = { item.animationSpeed = it },
                onLoop = { item.animationLoops = it; playFromStart() }), LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT).apply { topMargin = context.dp(24f) })
            addOnAttachStateChangeListener(object : View.OnAttachStateChangeListener {
                override fun onViewAttachedToWindow(v: View) { if (playable) playFromStart() }
                override fun onViewDetachedFromWindow(v: View) { item.stopAnimation() }
            })
        }
        val replayButton = Button(context).apply {
            text = context.t(R.string.merged_action_replay)
            setOnClickListener { playFromStart() }
        }
        return page(context, bar(context, name, replayButton), content)
    }

    private companion object {
        const val EXAMPLE_FOLDER = "Animations"

        /** Files whose white artwork needs a black backdrop: their black composition background is not drawn. */
        val DARK_BACKDROP_FILES = setOf("CYLScenarioExampleMoonlight.pag")

        /**
         * The engines in the order of the iOS page.
         */
        val ENGINES = linkedMapOf(
            "json" to "Lottie · lottie-android",
            "pag" to "PAG · libpag",
            "riv" to "Rive · rive-android",
            "svga" to "SVGA · SVGAPlayer-Android",
            "gif" to "GIF · CYLAnimatedItem",
        )

        /**
         * The options some bundled Rive files need (iOS `CYLScenarioAnimationOptions`), after '#' in the file URL.
         */
        val RIVE_OPTIONS = mapOf(
            "CYLPlaceholderSuccess.riv" to "stateMachine=State%20Machine%201",
            "CYLRefreshIcon.riv" to "artboard=refresh&animation=active",
        )
    }
}
