//
//  CYLRefreshWebViewController.swift
//  Example-Scenarios
//
//  MJWKWebViewController, MJWebViewViewController and I18NExampleViewController of MJRefresh's example layer (MIT;
//  originally created by MJ Lee, Copyright (c) 2015 小码哥), transcribed to Swift on this project's API
//  (`MJ` → `CYL`, `mj_` → `cyl_`). UIWebView is gone from the iOS SDK, so example40 runs on WKWebView like example41.
//

import UIKit
import WebKit
import CYLTableViewPlaceHolder

/// MJWKWebViewController (example41) and MJWebViewViewController (example40): pull down to reload a web page.
final class CYLRefreshWKWebViewController: UIViewController, CYLRefreshExampleRunning {

    var method = ""
    private var webView: WKWebView!

    /// The former UIWebView sample: the animated-images header, linked to the scroll view, fading automatically.
    func example40() {
        let webView = self.webView
        CYLRefreshExampleImagesHeader { [weak webView] in
            webView?.reload()
        }.cyl_link(to: webView!.scrollView).cyl_autoChangeTransparency(true)
        // A footer would work the same way
        webView?.scrollView.cyl_header?.beginRefreshing()
    }

    func example41() {
        CYLRefreshExampleImagesHeader { [weak self] in
            self?.webView.reload()
        }.cyl_autoChangeTransparency(true).cyl_link(to: webView.scrollView)
        webView.scrollView.cyl_header?.beginRefreshing()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        constructViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        setNeedsStatusBarAppearanceUpdate()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override var prefersStatusBarHidden: Bool {
        true
    }

    private func constructViews() {
        webView = WKWebView(frame: view.bounds)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        view.addSubview(webView)

        let size = view.bounds.size
        let mask: UIView.AutoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin]
        let warningLabel = UILabel(frame: CGRect(x: size.width - 210, y: size.height - 160, width: 200, height: 50))
        warningLabel.text = CYLScenarioLocalizedString(.mjWebWarning)
        warningLabel.adjustsFontSizeToFitWidth = true
        warningLabel.textColor = .label
        warningLabel.backgroundColor = UIColor.systemGray.withAlphaComponent(0.3)
        warningLabel.numberOfLines = 0
        warningLabel.autoresizingMask = mask
        webView.addSubview(warningLabel)

        let backButton = UIButton(frame: CGRect(x: size.width - 210, y: size.height - 100, width: 200, height: 50))
        backButton.setTitle(CYLScenarioLocalizedString(.mjWebBack), for: .normal)
        backButton.titleLabel?.adjustsFontForContentSizeCategory = true
        backButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        backButton.backgroundColor = .systemRed
        backButton.autoresizingMask = mask
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        webView.addSubview(backButton)

        if let url = URL(string: "https://github.com/CoderMJLee/MJRefresh") {
            webView.load(URLRequest(url: url))
        }
        if method == "example40" {
            example40()
        } else {
            example41()
        }
    }

    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }
}

extension CYLRefreshWKWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.scrollView.cyl_header?.endRefreshing()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        webView.scrollView.cyl_header?.endRefreshing()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        webView.scrollView.cyl_header?.endRefreshing()
    }
}

/// I18NExampleViewController: the language of the refresh texts, from the built-in strings or from a custom table.
/// MJRefresh's custom table lives in the main bundle; here it lives in the example's own bundle
/// (CYLScenarioExample.bundle/<language>.lproj/CYLRefreshCustom.strings), set through `i18nBundle`.
final class CYLRefreshI18NExampleViewController: UITableViewController, CYLRefreshExampleRunning {

    var method = ""
    private let languages = ["zh-Hans", "zh-Hant", "en", "ru", "ko", "uk", "ja"]
    private static let customTable = "CYLRefreshCustom"

    init() {
        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.accessibilityIdentifier = "refreshI18n"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        CYLRefreshNormalHeader { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self?.tableView.cyl_header?.endRefreshing()
            }
        }.cyl_autoChangeTransparency(true).cyl_link(to: tableView)
        CYLRefreshAutoNormalFooter { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self?.tableView.cyl_footer?.endRefreshing()
            }
        }.cyl_link(to: tableView)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // The configuration is shared by the whole app: give the other pages their default texts back.
        guard isMovingFromParent else { return }
        CYLRefreshConfig.default.i18nFilename = nil
        CYLRefreshConfig.default.i18nBundle = nil
        CYLRefreshConfig.default.languageCode = nil
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        languages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = languages[indexPath.row]
        content.secondaryText = Locale.current.localizedString(forIdentifier: languages[indexPath.row])
        cell.contentConfiguration = content
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        CYLScenarioLocalizedString(section == 0 ? .mjI18nBuiltIn : .mjI18nCustom)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            CYLRefreshConfig.default.i18nFilename = Self.customTable
            CYLRefreshConfig.default.i18nBundle = CYLScenarioExampleBundle()
        } else {
            CYLRefreshConfig.default.i18nFilename = nil
            CYLRefreshConfig.default.i18nBundle = nil
        }
        CYLRefreshConfig.default.languageCode = languages[indexPath.row]
        let alert = UIAlertController(title: nil,
                                      message: CYLScenarioLocalizedFormat(.mjLanguageChanged, languages[indexPath.row]),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: CYLScenarioLocalizedString(.mjOK), style: .default))
        present(alert, animated: true)
    }
}
