package com.cyl.placeholder

import android.app.Activity
import android.content.Context
import android.graphics.Color
import android.graphics.drawable.Drawable
import androidx.core.content.ContextCompat
import org.json.JSONArray
import org.json.JSONObject
import java.io.File

/**
 * Why a configuration was refused (iOS `CYLPlaceholderConfigurationError`).
 */
class CYLPlaceholderConfigurationError(message: String) : Exception(message)

/**
 * Called with the reason when a configuration is refused (the iOS `error:` out parameter).
 */
typealias CYLPlaceholderConfigurationErrorHandler = (CYLPlaceholderConfigurationError) -> Unit

private fun CYLPlaceholderConfigurationErrorHandler?.fail(message: String): Nothing? {
    this?.invoke(CYLPlaceholderConfigurationError(message))
    return null
}

private fun CYLPlaceholderConfigurationErrorHandler?.failed(message: String): Boolean {
    this?.invoke(CYLPlaceholderConfigurationError(message))
    return false
}

private fun snake(name: String) = name.replace(Regex("(?<=[a-z0-9])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])"), "_").lowercase()

private fun drawableId(context: Context, name: String): Int =
    context.resources.getIdentifier(name, "drawable", context.packageName).takeIf { it != 0 }
        ?: context.resources.getIdentifier(snake(name), "drawable", context.packageName)

private fun color(value: String): Int? = runCatching { Color.parseColor(value) }.getOrNull()

private fun string(value: Any?): String? = value as? String

/**
 * A text from a configuration: the core string of the key `keyName` when there is one, else the literal (iOS
 * `CYLScenarioConfiguredText`). A key is the iOS name, "CYLPlaceholderStatusNetworkUnavailable", found as the string
 * resource "cyl_placeholder_status_network_unavailable".
 */
internal fun configuredText(context: Context, map: Map<String, Any?>, literalName: String, keyName: String): String? {
    val literal = string(map[literalName])
    val key = string(map[keyName])
    if (!key.isNullOrEmpty()) {
        val localized = CYLPlaceholderLocalization.localizedContext(context)
        val id = localized.resources.getIdentifier(snake(key), "string", context.packageName)
        return if (id != 0) localized.getString(id) else literal ?: key
    }
    return literal
}

/**
 * A JSON object as a map, an array as a list: the shapes a configuration has.
 */
fun CYLPlaceholderConfiguration_fromJSON(text: String): Any? = runCatching { unwrap(JSONObject(text)) }.getOrElse { runCatching { unwrap(JSONArray(text)) }.getOrNull() }

private fun unwrap(value: Any?): Any? = when (value) {
    is JSONObject -> value.keys().asSequence().associateWith { unwrap(value.get(it)) }
    is JSONArray -> (0 until value.length()).map { unwrap(value.get(it)) }
    JSONObject.NULL -> null
    else -> value
}

/**
 * An XML property list (the iOS `.plist` format): dict, array, string, integer, real, true, false and date (as text);
 * data is skipped. Null when the text is not a property list.
 */
fun CYLPlaceholderConfiguration_fromPropertyList(text: String): Any? = runCatching {
    val parser = android.util.Xml.newPullParser()
    parser.setInput(java.io.StringReader(text))
    fun next(): Int { var event = parser.next(); while (event == org.xmlpull.v1.XmlPullParser.TEXT && parser.isWhitespace) event = parser.next(); return event }
    fun value(): Any? {
        val name = parser.name
        return when (name) {
            "dict" -> {
                val map = LinkedHashMap<String, Any?>()
                while (next() == org.xmlpull.v1.XmlPullParser.START_TAG) {
                    require(parser.name == "key")
                    val key = parser.nextText()
                    next()
                    map[key] = value()
                }
                map
            }
            "array" -> {
                val list = ArrayList<Any?>()
                while (next() == org.xmlpull.v1.XmlPullParser.START_TAG) list += value()
                list
            }
            "string", "date" -> parser.nextText()
            "integer" -> parser.nextText().trim().toLong().let { if (it in Int.MIN_VALUE..Int.MAX_VALUE) it.toInt() else it }
            "real" -> parser.nextText().trim().toDouble()
            "true" -> { next(); true }
            "false" -> { next(); false }
            "data" -> { parser.nextText(); null }
            else -> error("unknown plist element $name")
        }
    }
    var event = parser.eventType
    while (event != org.xmlpull.v1.XmlPullParser.START_TAG || parser.name == "plist") event = parser.next()
    value()
}.getOrNull()

/**
 * The local file a configuration is read from: a path, or "asset:name" in the app's assets: a ".json" file or an XML
 * ".plist" (property list), as on iOS.
 */
internal fun readConfigurationFile(context: Context, path: String, error: CYLPlaceholderConfigurationErrorHandler?): Map<String, Any?>? {
    val text = runCatching {
        if (path.startsWith("asset:")) context.assets.open(path.removePrefix("asset:")).bufferedReader().use { it.readText() }
        else File(path).readText()
    }.getOrElse { return error.fail("The configuration file cannot be read: ${it.message}") }
    val plist = path.lowercase().endsWith(".plist")
    val parsed = if (plist) CYLPlaceholderConfiguration_fromPropertyList(text) else CYLPlaceholderConfiguration_fromJSON(text)
    @Suppress("UNCHECKED_CAST")
    return parsed as? Map<String, Any?> ?: error.fail(if (plist) "The configuration file is not a property list dictionary." else "The configuration file is not a JSON object.")
}

private fun styleFromValue(value: Any?): CYLPlaceholderStyle? {
    if (value is Number) {
        val number = value.toInt()
        return if (number < 0 || number >= CYLPlaceholderStyle.values().size || value.toDouble() != number.toDouble()) null else CYLPlaceholderStyle.values()[number]
    }
    var name = string(value)?.lowercase()?.takeIf { it.isNotEmpty() } ?: return null
    if (!name.startsWith("cylplaceholder")) name = "cylplaceholder$name"
    return CYLPlaceholderStyle.values().firstOrNull { CYLPlaceholderView.imageNameForStyle(it).lowercase() == name }
}

private fun sizeFromValue(value: Any?): Pair<Double, Double>? {
    val (width, height) = when {
        value is Number -> value.toDouble() to value.toDouble()
        value is List<*> && value.size == 2 && value[0] is Number && value[1] is Number -> (value[0] as Number).toDouble() to (value[1] as Number).toDouble()
        else -> return null
    }
    if (!width.isFinite() || !height.isFinite() || width <= 0 || height <= 0 || width > 1000 || height > 1000) return null
    return width to height
}

private fun applyConfiguration(component: CYLPlaceholderComponent, map: Map<String, Any?>, error: CYLPlaceholderConfigurationErrorHandler?): Boolean {
    map["interactionEnabled"]?.let {
        if (it !is Boolean) { error.fail("interactionEnabled must be a boolean."); return false }
        component.interactionEnabled = it
    }
    map["highlightStyle"]?.let {
        val index = listOf("dim", "shrink", "none").indexOf(string(it)?.lowercase())
        if (index < 0) { error.fail("highlightStyle must be dim, shrink or none."); return false }
        component.tapHighlightStyle = CYLPlaceholderTapHighlightStyle.values()[index]
    }
    map["repeatCount"]?.let {
        val count = when {
            it is String && it.lowercase() == "loop" -> 0
            it is String && it.lowercase() == "once" -> 1
            it is Number && it.toDouble() == Math.floor(it.toDouble()) -> it.toInt()
            else -> -1
        }
        if (count < 0 || count > 10000) { error.fail("repeatCount must be 0 (loop) or more, \"loop\" or \"once\"."); return false }
        component.animationRepeatCount = count
    }
    map["spacingBefore"]?.let {
        if (it !is Number || !it.toDouble().isFinite() || it.toDouble() < 0) { error.fail("spacingBefore must be a number of points."); return false }
        component.spacingBefore = it.toFloat()
    }
    map["accessibilityIdentifier"]?.let {
        if (it !is String) { error.fail("accessibilityIdentifier must be a string."); return false }
        component.accessibilityIdentifier = it
    }
    if (map.containsKey("action") && map["type"] == null) {
        val name = string(map["action"])
        component.action = if (name.isNullOrEmpty()) null else CYLPlaceholderScenarioCatalog.actionNamed(name)
    }
    return true
}

/**
 * A component from a configuration dictionary (iOS `+[CYLPlaceholderComponent componentWithDictionary:error:]`):
 * "type" ("icon", "hint", "button", "separator" or "item"), "title" / "titleKey", "action", and the fields of
 * "icon" (style, size, animation), "button" (buttonStyle) and "item" (attributes); every type takes
 * "interactionEnabled", "highlightStyle", "repeatCount", "spacingBefore" and "accessibilityIdentifier". Null, with the
 * reason given to [error], when a value is invalid.
 */
fun CYLPlaceholderComponent.Companion.componentWithDictionary(context: Context, dictionary: Map<String, Any?>?, error: CYLPlaceholderConfigurationErrorHandler? = null): CYLPlaceholderComponent? {
    if (dictionary == null) return error.fail("A component must be a dictionary.")
    val type = string(dictionary["type"]) ?: "icon"
    val title = configuredText(context, dictionary, "title", "titleKey") ?: configuredText(context, dictionary, "text", "textKey")
    var action: String? = null
    if (dictionary.containsKey("action")) {
        val name = string(dictionary["action"])
        if (name.isNullOrEmpty()) return error.fail("A component action must be a non-empty string.")
        action = CYLPlaceholderScenarioCatalog.actionNamed(name)
    }
    val component = when (type) {
        "icon" -> {
            var style = CYLPlaceholderStyle.Empty
            if (dictionary.containsKey("style")) style = styleFromValue(dictionary["style"]) ?: return error.fail("Unknown placeholder style.")
            var side = ICON_SIDE.toDouble()
            if (dictionary.containsKey("size")) side = sizeFromValue(dictionary["size"])?.first ?: return error.fail("A component size must be [width, height] or a number.")
            val animation = string(dictionary["animation"])
            if (animation != null && CYLPlaceholderScenarioCatalog.allAnimationFileNames().none { it == animation }) return error.fail("Bundled animation $animation was not found.")
            val image = drawableId(context, "cyl_placeholder_" + snake(style.name))
            CYLPlaceholderComponent.icon(image, title, side.toFloat(), style != CYLPlaceholderStyle.Empty, action)
        }
        "hint" -> CYLPlaceholderComponent.hintComponentWithText(title ?: "")
        "button" -> {
            var style = CYLPlaceholderButtonStyle.Filled
            dictionary["buttonStyle"]?.let {
                val index = listOf("filled", "outlined", "capsule").indexOf(string(it)?.lowercase())
                if (index < 0) return error.fail("A button style must be filled, outlined or capsule.")
                style = CYLPlaceholderButtonStyle.values()[index]
            }
            if (action == null) return error.fail("A button needs an action.")
            CYLPlaceholderComponent.buttonComponentWithTitle(title ?: CYLPlaceholderScenarioCatalog.localizedTitleForAction(context, action) ?: "", style, action)
        }
        "separator" -> CYLPlaceholderComponent.separatorComponentWithText(title ?: configuredText(context, mapOf("textKey" to "CYLPlaceholderScenarioOrSeparator", "text" to "or"), "text", "textKey") ?: "or")
        "item" -> {
            @Suppress("UNCHECKED_CAST")
            val attributes = dictionary["attributes"] as? Map<String, Any?> ?: return error.fail("An item component needs an \"attributes\" dictionary.")
            val resolved = HashMap<String, Any>()
            attributes.forEach { (key, value) -> if (value != null) resolved[key] = if (key == "CYLPlaceholderItemImage" && value is String) drawableId(context, value) else value }
            if (title != null) resolved["CYLPlaceholderItemTitle"] = title
            CYLPlaceholderComponent.componentWithAttributes(resolved, action)
        }
        else -> return error.fail("Unknown component type $type.")
    }
    return if (applyConfiguration(component, dictionary, error)) component else null
}

/**
 * A placeholder from a configuration dictionary (iOS `-[CYLPlaceholderStackView initWithConfiguration:actions:error:]`):
 * "scenario" (a name), "components" (component dictionaries, replacing the scenario's), "overrides" (dictionaries
 * with an "index" and component fields) and "backgroundAction" (an action name, or "" for none). Handlers come from
 * [actions], keyed by action.
 */
fun CYLPlaceholderStackView.Companion.fromConfiguration(
    context: Context,
    configuration: Map<String, Any?>?,
    actions: Map<String, CYLPlaceholderActionHandler>? = null,
    error: CYLPlaceholderConfigurationErrorHandler? = null,
): CYLPlaceholderStackView? {
    if (configuration == null) return error.fail("The configuration must be a dictionary.")
    var scenario: CYLPlaceholderScenario? = null
    if (configuration.containsKey("scenario")) {
        scenario = CYLPlaceholderScenarioCatalog.scenarioNamed(string(configuration["scenario"])) ?: return error.fail("Unknown scenario ${configuration["scenario"]}.")
    }
    val components = ArrayList<CYLPlaceholderComponent>()
    val list = configuration["components"]
    if (list != null) {
        if (list !is List<*> || list.isEmpty()) return error.fail("\"components\" must be a non-empty array.")
        for (entry in list) {
            @Suppress("UNCHECKED_CAST")
            components += CYLPlaceholderComponent.componentWithDictionary(context, entry as? Map<String, Any?>, error) ?: return null
        }
    } else if (scenario != null) {
        components += CYLPlaceholderScenarioCatalog.componentsForScenario(context, scenario)
    } else {
        return error.fail("The configuration needs a \"scenario\" or \"components\".")
    }
    val overrides = configuration["overrides"]
    if (overrides != null && overrides !is List<*>) return error.fail("\"overrides\" must be an array.")
    for (override in overrides as List<*>? ?: emptyList<Any?>()) {
        @Suppress("UNCHECKED_CAST")
        val fields = override as? Map<String, Any?>
        val index = (fields?.get("index") as? Number)?.toInt()
        if (fields == null || index == null || index < 0 || index >= components.size) return error.fail("Each override needs the \"index\" of an existing component.")
        if (!applyConfiguration(components[index], fields - "index", error)) return null
    }
    val background = configuration["backgroundAction"]
    if (background != null && background !is String) return error.fail("\"backgroundAction\" must be an action name.")
    val stack = CYLPlaceholderStackView(context, scenario, components, actions)
    if (background is String) stack.backgroundAction = if (background.isEmpty()) null else CYLPlaceholderScenarioCatalog.actionNamed(background)
    (configuration["accessibilityIdentifier"] as? String)?.let { stack.tag = it }
    return stack
}

/**
 * The configuration in a local ".json" file, a path or "asset:name" (iOS `-initWithContentsOfURL:actions:error:`).
 */
fun CYLPlaceholderStackView.Companion.fromContentsOfURL(
    context: Context,
    path: String,
    actions: Map<String, CYLPlaceholderActionHandler>? = null,
    error: CYLPlaceholderConfigurationErrorHandler? = null,
): CYLPlaceholderStackView? = readConfigurationFile(context, path, error)?.let { fromConfiguration(context, it, actions, error) }

/**
 * A banner from a configuration dictionary (iOS `-[CYLPlaceholderStatusView initWithConfiguration:error:]`): "text",
 * "textKey", "image" (a drawable name), "titleColor" and "backgroundColor" (color strings such as "#FFC7C7"),
 * "accessibilityIdentifier"; missing keys keep the network banner's values.
 */
fun CYLPlaceholderStatusView.Companion.fromConfiguration(context: Context, configuration: Map<String, Any?>?, error: CYLPlaceholderConfigurationErrorHandler? = null): CYLPlaceholderStatusView? {
    if (configuration == null) return error.fail("The status bar configuration must be a dictionary.")
    for (key in listOf("text", "textKey", "image", "titleColor", "backgroundColor", "accessibilityIdentifier")) {
        if (configuration[key] != null && configuration[key] !is String) return error.fail("\"$key\" must be a string.")
    }
    val attributes = HashMap<String, Any>(networkUnavailableItemAttributes(context))
    string(configuration["image"])?.let { name ->
        if (name.startsWith("system:")) return error.fail("An SF Symbol is an iOS image; name a drawable.")
        val id = drawableId(context, name).takeIf { it != 0 } ?: return error.fail("The image $name was not found.")
        attributes["CYLPlaceholderItemImage"] = id
    }
    string(configuration["titleColor"])?.let { attributes["CYLPlaceholderItemTitleColor"] = color(it) ?: return error.fail("\"titleColor\" is not a color.") }
    val background = string(configuration["backgroundColor"])?.let { color(it) ?: return error.fail("\"backgroundColor\" is not a color.") }
    configuredText(context, configuration, "text", "textKey")?.let { attributes["CYLPlaceholderItemTitle"] = it }
    val bar = CYLPlaceholderStatusView(context, attributes)
    background?.let { bar.setBackgroundColor(it) }
    (configuration["accessibilityIdentifier"] as? String)?.let { bar.tag = it }
    return bar
}

/**
 * A placeholder view from item keys (iOS `-[CYLPlaceholderView initWithItemAttributes:imageBundle:error:]`):
 * "CYLPlaceholderItemTitle", "CYLPlaceholderItemImage" (a drawable resource, a Drawable or a drawable name),
 * "CYLPlaceholderItemStyle" / "CYLPlaceholderItemMessage" (the built-in icon / text when no image / title is set),
 * "CYLPlaceholderItemImagePositionAdjustment" / "CYLPlaceholderItemTitlePositionAdjustment" ([x, y] in dp), the colors
 * "CYLPlaceholderItemTitleColor", "CYLPlaceholderItemIconColor", "CYLPlaceholderItemBackgroundColor" and their
 * "CYLPlaceholderItemSelected…" variants (a color int or "#RRGGBB"), "CYLPlaceholderItemTitleFontSize" (sp, Android takes
 * no UIFont), an animation file ("CYLPlaceholderItemAnimationFilePath" or the Lottie / PAG / Rive / GIF file keys, played
 * by CYLTabBarController's CYLAnimatedItem engine when the app adds the animation library), "CYLPlaceholderItemAnimationRepeatCount", "CYLPlaceholderItemInteractionEnabled",
 * "CYLPlaceholderItemTapHighlightStyle" ("dim", "shrink", "none"), "CYLPlaceholderItemAccessibilityIdentifier" (the
 * view's tag) and "CYLPlaceholderItemAccessibilityLabel". Every key is kept in [CYLPlaceholderView.itemAttributes].
 * There is no image bundle: names are drawable resources.
 */
fun CYLPlaceholderView.Companion.fromItemAttributes(context: Context, attributes: Map<String, Any?>?, error: CYLPlaceholderConfigurationErrorHandler? = null): CYLPlaceholderView? {
    if (attributes == null) return error.fail("The item attributes must be a dictionary.")
    val title = attributes["CYLPlaceholderItemTitle"]
    if (title != null && title !is CharSequence) return error.fail("CYLPlaceholderItemTitle must be a string.")
    val image: Drawable? = when (val value = attributes["CYLPlaceholderItemImage"]) {
        null -> null
        is Drawable -> value
        is Int -> ContextCompat.getDrawable(context, value) ?: return error.fail("The image resource was not found.")
        is String -> drawableId(context, value).takeIf { it != 0 }?.let { ContextCompat.getDrawable(context, it) } ?: return error.fail("The image $value was not found.")
        else -> return error.fail("CYLPlaceholderItemImage must be a drawable, a resource or a name.")
    }
    // "CYLPlaceholderItemStyle" and "CYLPlaceholderItemMessage" give the built-in icon and text when no image or title is
    // set: the iOS raw value (an Int), the name ("warning") or the enum.
    val style: CYLPlaceholderStyle? = when (val value = attributes["CYLPlaceholderItemStyle"]) {
        null -> null
        is CYLPlaceholderStyle -> value
        is Number -> CYLPlaceholderStyle.values().getOrNull(value.toInt()) ?: return error.fail("CYLPlaceholderItemStyle ${value.toInt()} is not a style.")
        is String -> CYLPlaceholderStyle.values().firstOrNull { it.name.equals(value, ignoreCase = true) } ?: return error.fail("CYLPlaceholderItemStyle $value is not a style.")
        else -> return error.fail("CYLPlaceholderItemStyle must be a style.")
    }
    val message: CYLPlaceholderMessage? = when (val value = attributes["CYLPlaceholderItemMessage"]) {
        null -> null
        is CYLPlaceholderMessage -> value
        is Number -> CYLPlaceholderMessage.values().getOrNull(value.toInt()) ?: return error.fail("CYLPlaceholderItemMessage ${value.toInt()} is not a message.")
        is String -> CYLPlaceholderMessage.values().firstOrNull { it.name.equals(value, ignoreCase = true) } ?: return error.fail("CYLPlaceholderItemMessage $value is not a message.")
        else -> return error.fail("CYLPlaceholderItemMessage must be a message.")
    }
    val view = CYLPlaceholderView(context, image ?: style?.let { CYLPlaceholderView.imageForStyle(context, it) },
        (title as CharSequence?) ?: message?.let { CYLPlaceholderView.localizedTextForMessage(context, it) })
    if (!view.applyItemAttributes(context, attributes, error)) return null
    return view
}

/**
 * Reads the item keys from a local ".json" file (iOS `-initWithItemContentsOfURL:imageBundle:error:`).
 */
fun CYLPlaceholderView.Companion.fromItemContentsOfURL(context: Context, path: String, error: CYLPlaceholderConfigurationErrorHandler? = null): CYLPlaceholderView? =
    readConfigurationFile(context, path, error)?.let { fromItemAttributes(context, it, error) }

/**
 * Applies a status configuration (iOS `-[UIViewController cyl_applyStatusConfiguration:error:`): "statusBar" (true or
 * "networkUnavailable" for the network banner, or a dictionary for [CYLPlaceholderStatusView.Companion.fromConfiguration]),
 * "display" ("statusAndPlaceholder", "status", "placeholder" or "none"; by default "statusAndPlaceholder" when
 * "statusBar" is given, else "placeholder") and "showsWhenOffline". False, with nothing changed, when a value is
 * invalid.
 */
fun Activity.cyl_applyStatusConfiguration(configuration: Map<String, Any?>?, error: CYLPlaceholderConfigurationErrorHandler? = null): Boolean {
    if (configuration == null) { error.fail("The configuration must be a dictionary."); return false }
    val barValue = configuration["statusBar"]
    var bar: CYLPlaceholderStatusView? = null
    if (barValue is Map<*, *>) {
        @Suppress("UNCHECKED_CAST")
        bar = CYLPlaceholderStatusView.fromConfiguration(this, barValue as Map<String, Any?>, error) ?: return false
    } else if (barValue != null && !(barValue is Boolean || barValue == "networkUnavailable")) {
        error.fail("\"statusBar\" must be true, \"networkUnavailable\" or a dictionary.")
        return false
    }
    val displays = mapOf(
        "statusAndPlaceholder" to CYLPlaceholderStatusDisplay.All, "status" to CYLPlaceholderStatusDisplay.StatusBar,
        "placeholder" to CYLPlaceholderStatusDisplay.Placeholder, "none" to CYLPlaceholderStatusDisplay.None,
    )
    val wantsBar = barValue != null && barValue != false
    val displayValue = configuration["display"]
    val display = if (displayValue != null) displays[displayValue as? String] else if (wantsBar) CYLPlaceholderStatusDisplay.All else CYLPlaceholderStatusDisplay.Placeholder
    if (display == null) { error.fail("\"display\" must be \"statusAndPlaceholder\", \"status\", \"placeholder\" or \"none\"."); return false }
    val offline = configuration["showsWhenOffline"]
    if (offline != null && offline !is Boolean) { error.fail("\"showsWhenOffline\" must be a boolean."); return false }
    if (bar != null) cyl_statusView = bar else if (wantsBar) cyl_resetStatusView()
    if (offline is Boolean) cyl_showsStatusViewWhenOffline = offline
    cyl_statusDisplay = display
    return true
}

/**
 * The same, from a local ".json" file (iOS `-cyl_applyStatusConfigurationWithContentsOfURL:error:`).
 */
fun Activity.cyl_applyStatusConfigurationWithContentsOfURL(path: String, error: CYLPlaceholderConfigurationErrorHandler? = null): Boolean {
    val configuration = readConfigurationFile(this, path, error) ?: return false
    return cyl_applyStatusConfiguration(configuration, error)
}

/**
 * Applies the item keys other than the image, style, message and title to [this] (offsets, colors, font size, repeat
 * count, interaction, highlight, accessibility, animation file, images) and records every key in [itemAttributes];
 * false (after [error]) when a value is wrong. Used by [fromItemAttributes] and CYLPlaceholderStatusView.
 */
internal fun CYLPlaceholderView.applyItemAttributes(context: Context, attributes: Map<String, Any?>, error: CYLPlaceholderConfigurationErrorHandler?): Boolean {
    val view = this
    fun offset(key: String): FloatArray? = when (val value = attributes[key]) {
        null -> null
        is FloatArray -> value.takeIf { it.size == 2 }
        is List<*> -> value.mapNotNull { (it as? Number)?.toFloat() }.takeIf { it.size == 2 }?.toFloatArray()
        else -> null
    }
    for (key in listOf("CYLPlaceholderItemImagePositionAdjustment", "CYLPlaceholderItemTitlePositionAdjustment")) {
        if (attributes[key] != null && offset(key) == null) return error.failed("$key must be two numbers, x and y in dp.")
    }
    offset("CYLPlaceholderItemImagePositionAdjustment")?.let {
        view.imageView.translationX = it[0] * context.resources.displayMetrics.density
        view.imageView.translationY = it[1] * context.resources.displayMetrics.density
    }
    offset("CYLPlaceholderItemTitlePositionAdjustment")?.let { view.defaultTitlePositionAdjustment = it }
    val colors = listOf<Pair<String, (Int) -> Unit>>(
        "CYLPlaceholderItemTitleColor" to { view.defaultTitleColor = it },
        "CYLPlaceholderItemIconColor" to { view.defaultIconColor = it },
        "CYLPlaceholderItemBackgroundColor" to { view.defaultBackgroundColor = it },
        "CYLPlaceholderItemSelectedTitleColor" to { view.defaultSelectedTitleColor = it },
        "CYLPlaceholderItemSelectedIconColor" to { view.defaultSelectedIconColor = it },
        "CYLPlaceholderItemSelectedBackgroundColor" to { view.defaultSelectedBackgroundColor = it },
    )
    for ((key, apply) in colors) {
        when (val value = attributes[key]) {
            null -> Unit
            is Int -> apply(value)
            is String -> apply(color(value) ?: return error.failed("$key is not a color."))
            else -> return error.failed("$key must be a color.")
        }
    }
    when (val size = attributes["CYLPlaceholderItemTitleFontSize"]) {
        null -> Unit
        is Number -> if (size.toFloat() > 0f) view.defaultTitleFont = size.toFloat() else return error.failed("CYLPlaceholderItemTitleFontSize must be positive.")
        else -> return error.failed("CYLPlaceholderItemTitleFontSize must be a number.")
    }
    when (val count = attributes["CYLPlaceholderItemAnimationRepeatCount"]) {
        null -> Unit
        is Number -> view.animationRepeatCount = count.toInt()
        else -> return error.failed("CYLPlaceholderItemAnimationRepeatCount must be a number.")
    }
    when (val enabled = attributes["CYLPlaceholderItemInteractionEnabled"]) {
        null -> Unit
        is Boolean -> view.tapInteractionEnabled = enabled
        else -> return error.failed("CYLPlaceholderItemInteractionEnabled must be a boolean.")
    }
    when (val style = attributes["CYLPlaceholderItemTapHighlightStyle"]) {
        null -> Unit
        is CYLPlaceholderTapHighlightStyle -> view.tapHighlightStyle = style
        is String -> view.tapHighlightStyle = CYLPlaceholderTapHighlightStyle.values().firstOrNull { it.name.equals(style, ignoreCase = true) }
            ?: return error.failed("CYLPlaceholderItemTapHighlightStyle must be dim, shrink or none.")
        else -> return error.failed("CYLPlaceholderItemTapHighlightStyle must be a style.")
    }
    string(attributes["CYLPlaceholderItemAccessibilityIdentifier"])?.let { view.tag = it }
    string(attributes["CYLPlaceholderItemAccessibilityLabel"])?.let { view.accessibilityLabel = it }
    // The first animation file an animator of the CYLAnimatedItem engine plays (its library is in the app) replaces the
    // icon; the icon stays when none does (as iOS).
    val animationKeys = listOf("CYLPlaceholderItemAnimationFilePath", "CYLPlaceholderItemLottieFilePath", "CYLPlaceholderItemPAGFilePath",
        "CYLPlaceholderItemRiveFilePath", "CYLPlaceholderItemGIFFilePath")
    animationKeys.firstNotNullOfOrNull { string(attributes[it]) }?.let { view.setAnimationFile(it) }
    // "CYLPlaceholderItemImages" (drawables) with "CYLPlaceholderItemAnimationDuration" (seconds): one animated icon.
    when (val images = attributes["CYLPlaceholderItemImages"]) {
        null -> Unit
        is List<*> -> {
            val drawables = images.filterIsInstance<Drawable>()
            if (drawables.isEmpty() || drawables.size != images.size) return error.failed("CYLPlaceholderItemImages must be a list of drawables.")
            val duration = (attributes["CYLPlaceholderItemAnimationDuration"] as? Number)?.toDouble() ?: (drawables.size * 0.1)
            view.setAnimationImages(drawables, duration)
        }
        else -> return error.failed("CYLPlaceholderItemImages must be a list of drawables.")
    }
    view.itemAttributes = view.itemAttributes + attributes.filterValues { it != null }.mapValues { it.value!! }
    return true
}
