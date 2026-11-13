//
//  CYLRefreshExampleViewController.swift
//  Example-Scenarios
//
//  The example layer of MJRefresh (https://github.com/CoderMJLee/MJRefresh, Examples/MJRefreshExample, MIT;
//  originally created by MJ Lee, Copyright (c) 2015 小码哥), transcribed to Swift on this project's API: `MJ` became
//  `CYL` and `mj_` became `cyl_`. This file is MJExampleViewController (the list), MJExample (a section) and
//  MJTestViewController. A last section adds animated icons (GIF, Lottie, PAG, Rive) on the same pages.
//
//  Differences from the original, each for a reason:
//  - UIWebView no longer exists in the iOS SDK, so example40 runs on WKWebView like example41.
//  - The "animated images" (MJChiBaoZiHeader and friends) use frames of this project's bundled refresh GIFs instead of
//    MJRefresh's mascot images, as the example uses refresh resources only.
//  - Texts come from CYLScenarioExample.bundle in seven languages; the i18n page uses a table of that bundle.
//

import UIKit
import CYLTableViewPlaceHolder

/// A page of the list: MJExample's header, titles, methods and view controller classes.
struct CYLRefreshExample {
    let header: CYLScenarioL10n
    let titles: [CYLScenarioL10n]
    let methods: [String]
    /// One maker per class; rows past the last class use the last one, as in MJRefresh.
    let viewControllers: [(name: String, make: () -> CYLRefreshExampleRunning)]
}

/// A page that runs one example method by name (MJRefresh's `method` key path).
protocol CYLRefreshExampleRunning: UIViewController {
    var method: String { get set }
}

final class CYLRefreshExampleViewController: UITableViewController {

    private let examples: [CYLRefreshExample] = {
        let table: (name: String, make: () -> CYLRefreshExampleRunning) =
            ("CYLRefreshTableViewController", { CYLRefreshTableViewController() })
        let exam0 = CYLRefreshExample(header: .mjSectionHeader,
            titles: [.mjDefault, .mjAnimatedImages, .mjHideTime, .mjHideStateAndTime, .mjCustomText, .mjCustomControl],
            methods: ["example01", "example02", "example03", "example04", "example05", "example06"],
            viewControllers: [table])
        let exam1 = CYLRefreshExample(header: .mjSectionFooter,
            titles: [.mjDefault, .mjAnimatedImages, .mjHideRefreshingText, .mjAllLoaded, .mjNoAutoLoading, .mjCustomText,
                     .mjHideAfterLoading, .mjAutoBack01, .mjAutoBack02, .mjCustomAutoControl, .mjCustomBackControl],
            methods: ["example11", "example12", "example13", "example14", "example15", "example16", "example17",
                      "example18", "example19", "example20", "example21"],
            viewControllers: [table])
        let exam2 = CYLRefreshExample(header: .mjSectionCollection,
            titles: [.mjPullUpAndDown, .mjPinHeader, .mjPullLeft],
            methods: ["example31", "example31", "example42"],
            viewControllers: [
                ("CYLRefreshCollectionViewController", { CYLRefreshCollectionViewController() }),
                ("CYLRefreshPinHeaderCollectionViewController", { CYLRefreshPinHeaderCollectionViewController() }),
                ("CYLRefreshHorizontalCollectionViewController", { CYLRefreshHorizontalCollectionViewController() }),
            ])
        let exam3 = CYLRefreshExample(header: .mjSectionWeb, titles: [.mjWebPullOld, .mjWebPull],
            methods: ["example40", "example41"],
            viewControllers: [("CYLRefreshWKWebViewController", { CYLRefreshWKWebViewController() })])
        let exam4 = CYLRefreshExample(header: .mjSectionI18n, titles: [.mjLanguages], methods: ["i18n"],
            viewControllers: [("CYLRefreshI18NExampleViewController", { CYLRefreshI18NExampleViewController() })])
        // Beyond MJRefresh: the animated-image controls drawing GIF, Lottie, PAG and Rive icons.
        let exam5 = CYLRefreshExample(header: .mjSectionAnimations,
            titles: [.mjGifIcon, .mjLottieStates, .mjPagRing, .mjRiveIcon, .mjGifFrames, .mjMixedEngines,
                     .mjCollectionIcons],
            methods: ["example51", "example52", "example53", "example54", "example55", "example56", "example32"],
            viewControllers: [table, table, table, table, table, table,
                              ("CYLRefreshCollectionViewController", { CYLRefreshCollectionViewController() })])
        // Beyond MJRefresh: SmartRefreshControl's demo (CYLSmartRefreshDemoViewController), one method per style.
        let smart: (name: String, make: () -> CYLRefreshExampleRunning) =
            ("CYLSmartRefreshDemoViewController", { CYLSmartRefreshDemoViewController() })
        let styles: [(CYLScenarioL10n, String)] = [
            (.smartDelivery, "smartDelivery"), (.smartClassics, "smartClassics"), (.smartDropBox, "smartDropBox"),
            (.smartPhoenix, "smartPhoenix"), (.smartTaurus, "smartTaurus"), (.smartBezierRadar, "smartBezierRadar"),
            (.smartBezierCircle, "smartBezierCircle"), (.smartStoreHouse, "smartStoreHouse"),
            (.smartWaveSwipe, "smartWaveSwipe"), (.smartOriginal, "smartOriginal"), (.smartMaterial, "smartMaterial"),
            (.smartGameHitBlock, "smartGameHitBlock"), (.smartGameBattleCity, "smartGameBattleCity"),
            (.smartFly, "smartFly"), (.smartClassicsFooter, "smartClassicsFooter"),
            // flutter_easy_refresh's drawn footers (CYLRefreshDrawnFooter), on the same page.
            (.smartBezierRadarFooter, "smartBezierRadarFooter"), (.smartMaterialFooter, "smartMaterialFooter"),
            (.smartDeliveryFooter, "smartDeliveryFooter"), (.smartPhoenixFooter, "smartPhoenixFooter"),
            (.smartTaurusFooter, "smartTaurusFooter"),
            // flutter_easy_refresh's Rive style packages (CYLRefreshRiveHeader), with the example's own .riv files.
            (.smartRiveBow, "smartRiveBow"), (.smartRiveBubbles, "smartRiveBubbles"),
            (.smartRiveHalloween, "smartRiveHalloween"), (.smartRiveSkating, "smartRiveSkating"),
            (.smartRiveSpace, "smartRiveSpace"), (.smartRiveSquats, "smartRiveSquats"),
            (.smartRiveSpaceFooter, "smartRiveSpaceFooter"),
        ]
        let exam6 = CYLRefreshExample(header: .smartSection, titles: styles.map { $0.0 },
                                      methods: styles.map { $0.1 }, viewControllers: [smart])
        // Beyond MJRefresh: flutter_easy_refresh's demo pages (CYLEasyRefreshDemoViewController), one method per page.
        let easy: (name: String, make: () -> CYLRefreshExampleRunning) =
            ("CYLEasyRefreshDemoViewController", { CYLEasyRefreshDemoViewController() })
        let pages: [(CYLScenarioL10n, String)] = [
            (.easyCupertino, "easyCupertino"), (.easySecondary, "easySecondary"), (.easyTriggerMode, "easyTriggerMode"),
            (.easyRefreshOnStart, "easyRefreshOnStart"), (.easyPaging, "easyPaging"), (.easyListener, "easyListener"),
            (.easyChat, "easyChat"), (.easyUserProfile, "easyUserProfile"),
        ]
        let exam7 = CYLRefreshExample(header: .easySection, titles: pages.map { $0.0 },
                                      methods: pages.map { $0.1 }, viewControllers: [easy])
        return [exam0, exam1, exam2, exam3, exam4, exam5, exam6, exam7]
    }()

    init() {
        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.accessibilityIdentifier = "refreshExamples"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "example")
        // Pull down to refresh
        tableView.cyl_header = CYLRefreshNormalHeader { [weak self] in
            // Simulates a delayed load, so endRefreshing comes 2 seconds later (remove the delay in a real app).
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self?.tableView.cyl_header?.endRefreshing()
            }
        }
        // Fades automatically (hides under the navigation bar).
        tableView.cyl_header?.isAutomaticallyChangeAlpha = true
        // Pull up to load
        tableView.cyl_footer = CYLRefreshBackNormalFooter { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self?.tableView.cyl_footer?.endRefreshing()
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        examples.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        examples[section].titles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "example", for: indexPath)
        let exam = examples[indexPath.section]
        var content = UIListContentConfiguration.subtitleCell()
        content.text = CYLScenarioLocalizedString(exam.titles[indexPath.row])
        content.secondaryText = "\(viewController(of: exam, row: indexPath.row).name) - \(exam.methods[indexPath.row])"
        content.secondaryTextProperties.color = .secondaryLabel
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        CYLScenarioLocalizedString(examples[section].header)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let exam = examples[indexPath.section]
        let vc = viewController(of: exam, row: indexPath.row).make()
        vc.title = CYLScenarioLocalizedString(exam.titles[indexPath.row])
        vc.method = exam.methods[indexPath.row]
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    private func viewController(of exam: CYLRefreshExample, row: Int)
        -> (name: String, make: () -> CYLRefreshExampleRunning) {
        exam.viewControllers[min(row, exam.viewControllers.count - 1)]
    }
}

/// MJTestViewController: the page a row pushes or presents.
final class CYLRefreshTestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = CYLScenarioLocalizedString(.mjTestTitle)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: CYLScenarioLocalizedString(.mjClose), style: .done,
                                                            target: self, action: #selector(close))
    }

    @objc private func close() {
        if presentingViewController != nil {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    /// Pushes on odd rows and presents on even rows, as every MJRefresh list does.
    static func show(from controller: UIViewController, row: Int) {
        let test = CYLRefreshTestViewController()
        if row % 2 == 1 {
            controller.navigationController?.pushViewController(test, animated: true)
        } else {
            controller.present(UINavigationController(rootViewController: test), animated: true)
        }
    }
}

/// A random color (MJRandomColor).
func CYLRefreshRandomColor() -> UIColor {
    UIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: 1)
}
