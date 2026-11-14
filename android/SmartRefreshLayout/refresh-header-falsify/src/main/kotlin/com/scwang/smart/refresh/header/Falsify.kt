// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin; the JVM signatures match the Java version.
package com.scwang.smart.refresh.header

import android.content.Context
import android.util.AttributeSet
import com.scwang.smart.refresh.header.falsify.FalsifyAbstract
import com.scwang.smart.refresh.layout.api.RefreshFooter
import com.scwang.smart.refresh.layout.api.RefreshHeader
import com.scwang.smart.refresh.layout.api.RefreshKernel
import com.scwang.smart.refresh.layout.api.RefreshLayout

/**
 * An empty header: the content can be pulled down, nothing refreshes (`FalsifyHeader`).
 */
open class FalsifyHeader @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) :
    FalsifyAbstract(context, attrs, 0), RefreshHeader {

    override fun onReleased(refreshLayout: RefreshLayout, height: Int, maxDragHeight: Int) {
        if (mRefreshKernel != null) refreshLayout.closeHeaderOrFooter()
    }
}

/**
 * An empty footer: the content can be pulled up, nothing loads (`FalsifyFooter`).
 */
open class FalsifyFooter @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) :
    FalsifyAbstract(context, attrs, 0), RefreshFooter {

    override fun onInitialized(kernel: RefreshKernel, height: Int, maxDragHeight: Int) {
        mRefreshKernel = kernel
        kernel.refreshLayout.setEnableAutoLoadMore(false)
    }

    override fun onReleased(refreshLayout: RefreshLayout, height: Int, maxDragHeight: Int) {
        if (mRefreshKernel != null) refreshLayout.closeHeaderOrFooter()
    }
}
