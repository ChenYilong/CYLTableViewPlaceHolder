//
//  CYLPlaceholderResourceReporter.swift
//  CYLTableViewPlaceHolder
//
//  Copyright © 2026 https://github.com/ChenYilong . All rights reserved.
//

// [EN] Turns "an animation resource is missing" reports into the text of the red status bar (docs/Status-Bar.md, "Missing
//      resource"). Foundation and UIKit only. The animation engine of CYLTabBarController has no missing-resource callback
//      yet, so the core detects missing files where it resolves the animation path and reports them here; an engine
//      callback `onResourceMissing(resource, reason)` can report to the same object later.
// [CN] 把“动画资源缺失”的报告变成红色状态条的文字（docs/Status-Bar.md“资源缺失”）。只依赖 Foundation 与 UIKit。CYLTabBarController 的动画
//      引擎目前没有资源缺失回调，所以核心在解析动画路径的地方检测缺失的文件并报告到这里；以后引擎的 `onResourceMissing(resource, reason)`
//      回调可以报告给同一个对象。

import UIKit

/**
 * Collects the animation resources that are missing and says which ones, for the red status bar. Use it on the main
 * thread; `CYLPlaceholderView` reports to `shared`, and a view controller shows it with `cyl_showsMissingResources`.
 */
@objc(CYLPlaceholderResourceReporter)
public final class CYLPlaceholderResourceReporter: NSObject {

    private final class WeakSource {
        weak var object: AnyObject?
        let identifier: ObjectIdentifier
        init(_ object: AnyObject) {
            self.object = object
            identifier = ObjectIdentifier(object)
        }
    }

    private struct Entry {
        let name: String
        let reason: String
        var sources: [WeakSource]
        var hasNoSource: Bool
    }

    private var entries = [Entry]()

    /**
     * [EN] The guard of the red bar's logic: `true` only in a debug build (`#if DEBUG`, decided when the app is built), so a
     *      release build reports nothing and the core skips its file checks for it. Set it to force either value (tests).
     * [CN] 红条逻辑的守卫：只在调试构建中为 `true`（`#if DEBUG`，构建时确定），发布构建不报告，核心也不做文件检查；可手动设置（测试）。
     */
    @objc public static var isEnabled: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()

    /**
     * The reporter the views of the core report to.
     */
    @objc public static let shared = CYLPlaceholderResourceReporter()

    /**
     * Posted on the main queue when the list of missing resources changes, or when a view that reported one moves.
     */
    @objc public static let didChangeNotification = Notification.Name("CYLPlaceholderResourceReporterDidChangeNotification")

    /**
     * Called once for each resource that becomes missing, with its short name and the reason (`file not found`,
     * `unreadable`), on the main queue.
     */
    @objc public var onResourceMissing: ((String, String) -> Void)?

    /**
     * The resource as the bar names it: the last path segment (`asset:Folder/home.pag` is `home.pag`), so that reports of
     * the core and of the engine for one file become one entry.
     */
    @objc(shortNameOfResource:)
    public static func shortName(of resource: String) -> String {
        var name = resource
        if let fragment = name.firstIndex(of: "#") { name = String(name[..<fragment]) }
        if let query = name.firstIndex(of: "?") { name = String(name[..<query]) }
        if let separator = name.lastIndex(where: { $0 == "/" || $0 == "\\" }) {
            name = String(name[name.index(after: separator)...])
        } else if name.hasPrefix("asset:") {
            name = String(name.dropFirst("asset:".count))
        }
        return name.isEmpty ? resource : name
    }

    /**
     * Reports a missing resource. Returns YES when it is new: a resource is reported once, whoever reports it. `source`
     * is the view the resource belongs to (held weakly): the entry is cleared when the source is gone, and a page shows
     * only the entries of its own views.
     */
    @discardableResult
    @objc(reportResource:reason:source:)
    public func report(resource: String, reason: String, source: AnyObject?) -> Bool {
        guard CYLPlaceholderResourceReporter.isEnabled else { return false }
        let name = CYLPlaceholderResourceReporter.shortName(of: resource)
        var isNew = false
        if let index = entries.firstIndex(where: { $0.name == name }) {
            if let source = source {
                if !entries[index].sources.contains(where: { $0.identifier == ObjectIdentifier(source) }) {
                    entries[index].sources.append(WeakSource(source))
                }
            } else {
                entries[index].hasNoSource = true
            }
        } else {
            entries.append(Entry(name: name, reason: reason, sources: source.map { [WeakSource($0)] } ?? [],
                                 hasNoSource: source == nil))
            isNew = true
        }
        if isNew {
            deliver { [weak self] in self?.onResourceMissing?(name, reason) }
        }
        postChange()
        return isNew
    }

    /**
     * The resource loaded after all, or is no longer wanted by `source`: the entry goes when no other source still
     * misses it. A nil `source` clears the entry for everyone.
     */
    @objc(resolveResource:source:)
    public func resolve(resource: String, source: AnyObject?) {
        let name = CYLPlaceholderResourceReporter.shortName(of: resource)
        guard let index = entries.firstIndex(where: { $0.name == name }) else { return }
        if let source = source {
            entries[index].sources.removeAll { $0.identifier == ObjectIdentifier(source) || $0.object == nil }
            if entries[index].sources.isEmpty && !entries[index].hasNoSource { entries.remove(at: index) }
        } else {
            entries.remove(at: index)
        }
        postChange()
    }

    /**
     * Forgets everything `source` reported, for a view that goes away.
     */
    @objc(removeSource:)
    public func removeSource(_ source: AnyObject) {
        let identifier = ObjectIdentifier(source)
        var changed = false
        entries = entries.compactMap { entry in
            var entry = entry
            let before = entry.sources.count
            entry.sources.removeAll { $0.identifier == identifier }
            if entry.sources.count != before { changed = true }
            return (entry.sources.isEmpty && !entry.hasNoSource) ? nil : entry
        }
        if changed { postChange() }
    }

    /**
     * Forgets every entry.
     */
    @objc public func reset() {
        if entries.isEmpty { return }
        entries.removeAll()
        postChange()
    }

    /**
     * The short names of the missing resources, in the order they were reported.
     */
    @objc public var missingResourceNames: [String] {
        prune()
        return entries.map { $0.name }
    }

    /**
     * The red bar's text for the resources a page shows, localized: one resource reads `Missing resource: x (reason)`,
     * several read `Missing resources: first +N more`. `view` is the page's view; its own views and views that are not on
     * any screen yet count, other pages' views do not. A nil `view` counts every entry. nil when nothing is missing.
     */
    @objc(textVisibleInView:)
    public func text(visibleIn view: UIView?) -> String? {
        prune()
        let visible = entries.filter { entry in
            guard let view = view else { return true }
            if entry.hasNoSource { return true }
            return entry.sources.contains { weakSource in
                guard let source = weakSource.object as? UIView else { return true }
                return source.isDescendant(of: view) || (source.window == nil && source.superview == nil)
            }
        }
        guard let first = visible.first else { return nil }
        if visible.count == 1 {
            let format = CYLPlaceholderLocalizedStringForKey("CYLPlaceholderResourceMissing", "Missing resource: %@ (%@)")
            return String(format: format, first.name, first.reason)
        }
        let format = CYLPlaceholderLocalizedStringForKey("CYLPlaceholderResourcesMissing", "Missing resources: %1$@ +%2$ld more")
        return String(format: format, first.name, visible.count - 1)
    }

    /**
     * Tells the pages that a view that reported a resource moved, so they show or hide its entry.
     */
    @objc(sourceDidMove:)
    public func sourceDidMove(_ source: AnyObject) {
        let identifier = ObjectIdentifier(source)
        if entries.contains(where: { $0.sources.contains { $0.identifier == identifier } }) { postChange() }
    }

    // [EN] Drops the entries whose sources are all gone. [CN] 丢弃所有来源都已消失的条目。
    private func prune() {
        entries = entries.compactMap { entry in
            var entry = entry
            let hadSources = !entry.sources.isEmpty
            entry.sources.removeAll { $0.object == nil }
            return (hadSources && entry.sources.isEmpty && !entry.hasNoSource) ? nil : entry
        }
    }

    private func deliver(_ block: @escaping () -> Void) {
        if Thread.isMainThread { block() } else { DispatchQueue.main.async(execute: block) }
    }

    private func postChange() {
        deliver {
            NotificationCenter.default.post(name: CYLPlaceholderResourceReporter.didChangeNotification, object: nil)
        }
    }
}
