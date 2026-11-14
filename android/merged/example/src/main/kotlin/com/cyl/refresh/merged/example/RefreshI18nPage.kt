package com.cyl.refresh.merged.example

import android.app.AlertDialog
import android.view.View
import android.widget.LinearLayout
import android.widget.ScrollView
import com.cyl.refresh.CYLRefreshAutoNormalFooter
import com.cyl.refresh.CYLRefreshConfig
import com.cyl.refresh.CYLRefreshNormalHeader
import com.cyl.refresh.cyl_footer
import com.cyl.refresh.cyl_header
import com.scwang.smart.refresh.layout.SmartRefreshLayout
import java.util.Locale

/**
 * The refresh texts' languages (iOS `CYLRefreshI18NExampleViewController`): a row sets
 * [CYLRefreshConfig.languageCode], and the page's header and footer are made again, so the next pull shows the new
 * language. Leaving the page gives the other pages their default texts back. The iOS page's second section (a custom
 * strings table) has no Android counterpart: the Android texts are string resources.
 */
internal fun RefreshExamplesPage.i18nPage(title: String): View {
    val context = requireContext()
    val languages = listOf("zh-Hans", "zh-Hant", "en", "ru", "ko", "uk", "ja")
    val layout = SmartRefreshLayout(context)

    // The header and footer read their texts when they are made.
    fun makeComponents() {
        val header = CYLRefreshNormalHeader(context)
        header.refreshingBlock = { later(2000) { header.endRefreshing() } }
        header.automaticallyChangeAlpha = true
        layout.cyl_header = header
        val footer = CYLRefreshAutoNormalFooter(context)
        footer.refreshingBlock = { later(2000) { footer.endRefreshing() } }
        layout.cyl_footer = footer
    }

    val column = LinearLayout(context).apply { orientation = LinearLayout.VERTICAL; tag = "refreshI18n" }
    for (code in languages) {
        val name = Locale.forLanguageTag(code).getDisplayName(Locale.getDefault())
        column.addView(row(context, code, name, "i18n-$code") {
            CYLRefreshConfig.defaultConfig.languageCode = code
            makeComponents()
            AlertDialog.Builder(context)
                .setMessage(context.t(R.string.merged_mj_language_changed, code))
                .setPositiveButton(android.R.string.ok, null)
                .show()
        })
    }
    layout.setRefreshContent(ScrollView(context).apply { addView(column) })
    makeComponents()
    // The configuration is shared by the whole app.
    layout.addOnAttachStateChangeListener(object : View.OnAttachStateChangeListener {
        override fun onViewAttachedToWindow(v: View) = Unit

        override fun onViewDetachedFromWindow(v: View) {
            CYLRefreshConfig.defaultConfig.languageCode = null
        }
    })
    return page(context, bar(context, title), layout)
}
