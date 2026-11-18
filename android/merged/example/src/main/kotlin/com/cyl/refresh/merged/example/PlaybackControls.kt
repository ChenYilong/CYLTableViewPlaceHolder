package com.cyl.refresh.merged.example

import android.content.Context
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.LinearLayout
import android.widget.SeekBar
import android.widget.Switch
import android.widget.TextView

/**
 * The example's playback controls (docs/Example-Animation-Playback.md): "Play all" from the first frame, a speed
 * slider of 12 steps of 0.25x (0.25x to 3x, 1x at the start) and a loop switch (on: for ever; off: once). The page
 * applies them through the core: [onPlayAll] restarts, [onSpeed] gets the new rate, [onLoop] the new loop setting.
 */
internal fun playbackControls(
    context: Context,
    onPlayAll: () -> Unit,
    onSpeed: (Float) -> Unit,
    onLoop: (Boolean) -> Unit,
): View {
    val density = context.resources.displayMetrics.density
    val padding = (16 * density).toInt()
    val column = LinearLayout(context).apply { orientation = LinearLayout.VERTICAL; setPadding(padding, 0, padding, 0) }
    column.addView(Button(context).apply {
        text = context.t(R.string.merged_playback_play_all)
        tag = "playback-play-all"
        setOnClickListener { onPlayAll() }
    })
    val speedValue = TextView(context).apply { minWidth = (48 * density).toInt(); gravity = Gravity.END }
    val speedLabel = context.t(R.string.merged_playback_speed)
    fun showSpeed(speed: Float) {
        speedValue.text = "${if (speed % 1f == 0f) speed.toInt().toString() else speed.toString()}×"
        column.findViewWithTag<SeekBar>("playback-speed")?.contentDescription = "$speedLabel ${speedValue.text}"
    }
    column.addView(LinearLayout(context).apply {
        gravity = Gravity.CENTER_VERTICAL
        addView(TextView(context).apply { text = speedLabel; importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO })
        addView(SeekBar(context).apply {
            tag = "playback-speed"
            max = PLAYBACK_SPEED_STEPS - 1
            progress = PLAYBACK_SPEED_ONE
            setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
                override fun onProgressChanged(bar: SeekBar, value: Int, fromUser: Boolean) {
                    val speed = (value + 1) * PLAYBACK_SPEED_STEP
                    onSpeed(speed)
                    showSpeed(speed)
                }
                override fun onStartTrackingTouch(bar: SeekBar) = Unit
                override fun onStopTrackingTouch(bar: SeekBar) = Unit
            })
        }, LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f))
        addView(speedValue)
    })
    showSpeed(1f)
    column.addView(Switch(context).apply {
        text = context.t(R.string.merged_playback_loop)
        tag = "playback-loop"
        isChecked = true
        setOnCheckedChangeListener { _, loops -> onLoop(loops) }
    })
    return column
}

/** The speed slider: 12 steps of 0.25x (0.25x to 3x); step 3 is 1x. */
private const val PLAYBACK_SPEED_STEP = 0.25f
private const val PLAYBACK_SPEED_STEPS = 12
private const val PLAYBACK_SPEED_ONE = 3
