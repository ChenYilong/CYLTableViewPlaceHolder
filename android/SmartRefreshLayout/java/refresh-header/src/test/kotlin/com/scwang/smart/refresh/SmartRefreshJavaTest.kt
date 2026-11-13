package com.scwang.smart.refresh

import android.app.Activity
import android.os.Looper
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import android.widget.ScrollView
import com.scwang.smart.refresh.footer.ClassicsFooter
import com.scwang.smart.refresh.header.ClassicsHeader
import com.scwang.smart.refresh.header.MaterialHeader
import com.scwang.smart.refresh.layout.SmartRefreshLayout
import com.scwang.smart.refresh.layout.constant.RefreshState
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config
import java.time.Duration

/**
 * SmartRefreshLayout's Java source with the taken pull requests and the issue fixes (docs/Android-Port.md); each test
 * names its pull requests and issues.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class SmartRefreshJavaTest {

    private val activity: Activity = Robolectric.buildActivity(Activity::class.java).setup().get()

    private fun idle(millis: Long = 2000) = shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(millis))

    private fun content(height: Int) = ScrollView(activity).apply {
        addView(LinearLayout(activity).apply { addView(View(activity), LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, height)) })
    }

    private var refreshes = 0
    private var loads = 0

    private fun layout(contentHeight: Int = 3000): SmartRefreshLayout {
        val layout = SmartRefreshLayout(activity)
        layout.setRefreshContent(content(contentHeight))
        layout.setRefreshHeader(ClassicsHeader(activity))
        layout.setRefreshFooter(ClassicsFooter(activity))
        // A listener that keeps refreshing until the test finishes it (without one the layout finishes after 3 s).
        layout.setOnRefreshListener { refreshes++ }
        layout.setOnLoadMoreListener { loads++ }
        activity.setContentView(layout)
        idle(100)
        return layout
    }

    private fun translationContent(layout: SmartRefreshLayout): Boolean {
        val f = SmartRefreshLayout::class.java.getDeclaredField("mEnableHeaderTranslationContent")
        f.isAccessible = true
        return f.getBoolean(layout)
    }

    @Test
    fun autoRefreshIsToldToTheHeader() {
        // Pull request #1095; #1268: an auto refresh is told apart from a drag.
        val layout = layout()
        val header = layout.refreshHeader as ClassicsHeader
        assertFalse(header.isAutoRefresh)
        layout.autoRefresh()
        idle()
        assertEquals(RefreshState.Refreshing, layout.state)
        assertTrue(header.isAutoRefresh)
        layout.finishRefresh(0)
        idle()
        assertEquals(RefreshState.None, layout.state)
        assertFalse(header.isAutoRefresh)
    }

    @Test
    fun aHeadersTranslationDefaultDoesNotStayForTheNextHeader() {
        // Pull request #1095; #1075, #1396: after a MaterialHeader, a ClassicsHeader moves the content again.
        val layout = layout()
        val material = MaterialHeader(activity)
        material.setProgressAlpha(128)
        layout.setRefreshHeader(material)
        idle(100)
        assertFalse("the MaterialHeader keeps the content in place", translationContent(layout))
        layout.setRefreshHeader(ClassicsHeader(activity))
        idle(100)
        assertTrue("the next header moves the content again", translationContent(layout))
        layout.setEnableHeaderTranslationContent(false)
        layout.setRefreshHeader(ClassicsHeader(activity))
        idle(100)
        assertFalse("the app's own setting stays", translationContent(layout))
    }
}
