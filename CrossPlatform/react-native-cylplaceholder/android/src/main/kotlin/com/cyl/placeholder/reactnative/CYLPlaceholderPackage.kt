package com.cyl.placeholder.reactnative

import com.facebook.react.ReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.uimanager.ViewManager

/**
 * Registers [CYLRefreshContainerManager], [CYLPlaceholderStackManager] and [CYLPlaceholderHUDModule]; add it to the host app's
 * `getPackages()` (autolinking does it).
 */
class CYLPlaceholderPackage : ReactPackage {
    override fun createNativeModules(reactContext: ReactApplicationContext): List<NativeModule> =
        listOf(CYLPlaceholderHUDModule(reactContext))

    override fun createViewManagers(reactContext: ReactApplicationContext): List<ViewManager<*, *>> =
        listOf(CYLRefreshContainerManager(), CYLPlaceholderStackManager())
}
