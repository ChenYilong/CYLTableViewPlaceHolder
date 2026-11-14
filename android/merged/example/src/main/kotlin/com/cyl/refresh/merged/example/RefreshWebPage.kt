package com.cyl.refresh.merged.example

import android.graphics.Color
import android.graphics.Bitmap
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.webkit.WebResourceError
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.Button
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import com.cyl.refresh.cyl_header
import com.scwang.smart.refresh.layout.SmartRefreshLayout

/*
 * MJWKWebViewController and MJWebViewViewController of MJRefresh's example layer (MIT; originally created by MJ Lee,
 * Copyright (c) 2015 小码哥), translated from the iOS example's Swift (`CYLRefreshWebViewController.swift`) to Kotlin
 * on this project's Android API.
 */

/**
 * Pull down to reload a web page (iOS example40 and example41, which are the same since UIWebView is gone): the
 * animated-images header fades automatically and ends when the page finishes or fails.
 */
internal fun RefreshExamplesPage.webPage(): View {
    val context = requireContext()
    val density = context.resources.displayMetrics.density
    val layout = SmartRefreshLayout(context)
    val header = ExampleImagesHeader(context)
    val web = WebView(context).apply {
        tag = "refreshWeb"
        @Suppress("SetJavaScriptEnabled")
        settings.javaScriptEnabled = true
        webViewClient = object : WebViewClient() {
            override fun onPageStarted(view: WebView, url: String?, favicon: Bitmap?) = Unit

            override fun onPageFinished(view: WebView, url: String?) = header.endRefreshing()

            override fun onReceivedError(view: WebView, request: WebResourceRequest, error: WebResourceError) {
                if (request.isForMainFrame) header.endRefreshing()
            }
        }
    }
    layout.setRefreshContent(web)
    header.refreshingBlock = { web.reload() }
    header.automaticallyChangeAlpha = true
    layout.cyl_header = header

    // The warning and the Back button over the page's bottom right corner.
    val frame = FrameLayout(context)
    frame.addView(layout, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
    val width = (200 * density).toInt()
    val corner = LinearLayout(context).apply {
        orientation = LinearLayout.VERTICAL
        addView(TextView(context).apply {
            text = context.t(R.string.merged_mj_web_warning)
            setBackgroundColor(0x4D8E8E93)
            setPadding((8 * density).toInt(), (6 * density).toInt(), (8 * density).toInt(), (6 * density).toInt())
        }, LinearLayout.LayoutParams(width, ViewGroup.LayoutParams.WRAP_CONTENT))
        addView(Button(context).apply {
            text = context.t(R.string.merged_mj_web_back)
            setTextColor(Color.WHITE)
            setBackgroundColor(0xFFFF3B30.toInt())
            setOnClickListener { pop() }
        }, LinearLayout.LayoutParams(width, (50 * density).toInt()).apply { topMargin = (10 * density).toInt() })
    }
    frame.addView(corner, FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT,
        Gravity.END or Gravity.BOTTOM).apply { setMargins(0, 0, (10 * density).toInt(), (50 * density).toInt()) })

    web.loadUrl("https://github.com/CoderMJLee/MJRefresh")
    header.beginRefreshing()
    // iOS hides the navigation bar here; the Back button returns.
    return frame
}
