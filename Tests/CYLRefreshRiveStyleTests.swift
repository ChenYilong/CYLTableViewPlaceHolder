//
//  CYLRefreshRiveStyleTests.swift
//  CYLTableViewPlaceHolder tests
//
//  [EN] The `rive` refresh style without a Rive runtime (RiveRuntime is not part of this test target): the creation parameters
//       (`CYLRefreshRiveOptions`), the factory's choice of the Rive builder and its fall back to classic with one reason, the Flutter
//       host and the React Native container reaching it. A fake builder named like the real one (`CYLRefreshRiveBuilder`) stands in
//       for the `CYLTableViewPlaceHolder/Rive` subspec, so the core's lookup by name is tested too.
//  [CN] 没有 Rive 运行时（本测试目标不含 RiveRuntime）的 `rive` 刷新样式：创建参数（`CYLRefreshRiveOptions`）、工厂对 Rive 构建器的选择
//       以及退回经典样式时的一条原因、Flutter 宿主与 React Native 容器对它的使用。名称与真实构建器相同的假构建器
//       （`CYLRefreshRiveBuilder`）代替 `CYLTableViewPlaceHolder/Rive` 子库，所以核心按名称查找也被测试。
//

import XCTest
import UIKit

/// A header the fake builder makes. [CN] 假构建器创建的刷新头。
final class FakeRiveHeader: CYLRefreshNormalHeader {}
/// A footer the fake builder makes. [CN] 假构建器创建的刷新尾。
final class FakeRiveFooter: CYLRefreshBackNormalFooter {}

@objc(CYLRefreshRiveBuilder)
final class FakeRiveBuilder: NSObject, CYLRefreshRiveBuilding {
    static var succeeds = true
    static var made: [CYLRefreshRiveOptions] = []

    static func riveHeader(options: CYLRefreshRiveOptions) -> CYLRefreshHeader? {
        made.append(options)
        return succeeds ? FakeRiveHeader(refreshingBlock: {}) : nil
    }

    static func riveFooter(options: CYLRefreshRiveOptions) -> CYLRefreshFooter? {
        made.append(options)
        return succeeds ? FakeRiveFooter(refreshingBlock: {}) : nil
    }
}

final class CYLRefreshRiveStyleTests: XCTestCase {

    private var savedBuilder: CYLRefreshRiveBuilding.Type?
    private var window: UIWindow!
    private let bow: [String: Any] = ["riveFile": "Bow", "riveStateMachine": "numberSimulation", "rivePullInput": "pull"]

    override func setUp() {
        super.setUp()
        savedBuilder = CYLRefreshStyleFactory.riveBuilder
        FakeRiveBuilder.succeeds = true
        FakeRiveBuilder.made = []
        window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 600))
        window.isHidden = false
    }

    override func tearDown() {
        CYLRefreshStyleFactory.riveBuilder = savedBuilder
        super.tearDown()
    }

    private func header(_ style: String?, _ options: [String: Any]?) -> (CYLRefreshHeader, [String]) {
        var reasons = [String]()
        let header = CYLRefreshStyleFactory.header(style: style, options: options) { reasons.append($0) }
        return (header, reasons)
    }

    private func footer(_ style: String?, _ options: [String: Any]?) -> (CYLRefreshFooter, [String]) {
        var reasons = [String]()
        let footer = CYLRefreshStyleFactory.footer(style: style, options: options) { reasons.append($0) }
        return (footer, reasons)
    }

    // MARK: - The key

    func testRiveIsTheNinthKeyOfTheEnumAndTheFactory() {
        XCTAssertEqual(CYLRefreshStyle.fromKey("rive"), .rive)
        XCTAssertEqual(CYLRefreshStyle.rive.key, "rive")
        XCTAssertEqual(CYLRefreshStyle.allCases.last, .rive)
        XCTAssertEqual(CYLRefreshStyleFactory.styleNames.last, "rive")
        XCTAssertNil(CYLRefreshStyle.fromKey("Rive"), "keys are lower camel case and exact")
    }

    // MARK: - The creation parameters

    func testOptionsNeedANonEmptyStringFile() {
        XCTAssertNil(CYLRefreshRiveOptions(dictionary: nil))
        XCTAssertNil(CYLRefreshRiveOptions(dictionary: [:]))
        XCTAssertNil(CYLRefreshRiveOptions(dictionary: ["riveFile": ""]))
        XCTAssertNil(CYLRefreshRiveOptions(dictionary: ["riveFile": 3]))
        XCTAssertNotNil(CYLRefreshRiveOptions(dictionary: ["riveFile": "Bow"]))
    }

    func testOptionsReadTypedValuesAndKeepOnlyRiveKeys() {
        let options = CYLRefreshRiveOptions(dictionary: ["riveFile": "Bow.riv", "riveStateMachine": "m", "riveTriggerOffset": 200,
                                                         "riveFitsWidth": true, "riveEmpty": "", "style": "rive", "footer": true, "riveBad": Double.nan])!
        XCTAssertEqual(options.file, "Bow.riv")
        XCTAssertEqual(options.string("riveStateMachine"), "m")
        XCTAssertNil(options.string("riveEmpty"), "an empty name is no name")
        XCTAssertNil(options.string("riveTriggerOffset"), "a number is no string")
        XCTAssertEqual(options.number("riveTriggerOffset"), 200)
        XCTAssertNil(options.number("riveBad"), "NaN is no number")
        XCTAssertNil(options.number("riveStateMachine"))
        XCTAssertTrue(options.bool("riveFitsWidth"))
        XCTAssertFalse(options.bool("riveStateMachine"), "only a boolean true counts")
        XCTAssertNil(options.values["style"], "the other creation parameters are not Rive's")
        XCTAssertNil(options.values["footer"])
        XCTAssertEqual(options, CYLRefreshRiveOptions(dictionary: options.values))
    }

    func testAnAbsolutePathMustExist() throws {
        let file = FileManager.default.temporaryDirectory.appendingPathComponent("RiveStyleTests-\(UUID().uuidString).riv")
        try Data([1]).write(to: file)
        defer { try? FileManager.default.removeItem(at: file) }
        XCTAssertEqual(CYLRefreshRiveOptions(dictionary: ["riveFile": file.path])?.resolvedFileURL()?.path, file.path)
        XCTAssertNil(CYLRefreshRiveOptions(dictionary: ["riveFile": file.path + ".missing"])?.resolvedFileURL())
    }

    func testANameFindsAFlutterAssetOrAnAppResource() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("RiveStyleBundle-\(UUID().uuidString)")
        let flutter = root.appendingPathComponent("flutter_assets/assets/animations")
        try FileManager.default.createDirectory(at: flutter, withIntermediateDirectories: true)
        try Data([1]).write(to: flutter.appendingPathComponent("Bow.riv"))
        try Data([1]).write(to: root.appendingPathComponent("Loose.riv"))
        defer { try? FileManager.default.removeItem(at: root) }
        let bundle = try XCTUnwrap(Bundle(url: root))
        for name in ["Bow", "Bow.riv"] {
            XCTAssertEqual(CYLRefreshRiveOptions(dictionary: ["riveFile": name])?.resolvedFileURL(bundles: [bundle])?.lastPathComponent, "Bow.riv", name)
        }
        XCTAssertEqual(CYLRefreshRiveOptions(dictionary: ["riveFile": "Loose"])?.resolvedFileURL(bundles: [bundle])?.lastPathComponent, "Loose.riv")
        XCTAssertEqual(CYLRefreshRiveOptions(dictionary: ["riveFile": "assets/animations/Bow.riv"])?.resolvedFileURL(bundles: [bundle])?.lastPathComponent, "Bow.riv")
        XCTAssertNil(CYLRefreshRiveOptions(dictionary: ["riveFile": "Nope"])?.resolvedFileURL(bundles: [bundle]))
    }

    // MARK: - The factory

    func testTheCoreFindsTheBuilderByItsName() {
        XCTAssertTrue(NSClassFromString("CYLRefreshRiveBuilder") is CYLRefreshRiveBuilding.Type)
        XCTAssertTrue(savedBuilder === FakeRiveBuilder.self, "the default lookup found the class named CYLRefreshRiveBuilder")
    }

    func testTheRiveStyleMakesTheBuildersHeaderAndFooterFromTheOptions() {
        CYLRefreshStyleFactory.riveBuilder = FakeRiveBuilder.self
        let (h, hReasons) = header("rive", bow)
        XCTAssertTrue(h is FakeRiveHeader)
        XCTAssertTrue(hReasons.isEmpty)
        let (f, fReasons) = footer("rive", bow)
        XCTAssertTrue(f is FakeRiveFooter)
        XCTAssertTrue(fReasons.isEmpty)
        XCTAssertEqual(FakeRiveBuilder.made.map { $0.file }, ["Bow", "Bow"])
        XCTAssertEqual(FakeRiveBuilder.made.first?.string("rivePullInput"), "pull")
        XCTAssertTrue(CYLRefreshStyle.rive.newHeader(riveOptions: bow) is FakeRiveHeader)
        XCTAssertTrue(CYLRefreshStyle.rive.newFooter(riveOptions: bow) is FakeRiveFooter)
    }

    func testWithoutTheRiveSubspecTheStyleIsClassicWithOneReason() {
        CYLRefreshStyleFactory.riveBuilder = nil
        let (h, hReasons) = header("rive", bow)
        XCTAssertTrue(h is CYLRefreshNormalHeader && !(h is FakeRiveHeader))
        XCTAssertEqual(hReasons, ["rive runtime not linked (add the CYLTableViewPlaceHolder/Rive subspec)"])
        let (f, fReasons) = footer("rive", bow)
        XCTAssertTrue(f is CYLRefreshBackNormalFooter)
        XCTAssertEqual(fReasons.count, 1)
    }

    func testAMissingOrUnreadableFileIsClassicWithOneReason() {
        CYLRefreshStyleFactory.riveBuilder = FakeRiveBuilder.self
        FakeRiveBuilder.succeeds = false
        let (h, hReasons) = header("rive", bow)
        XCTAssertFalse(h is FakeRiveHeader)
        XCTAssertEqual(hReasons, ["rive file Bow not found or unreadable"])
        let (f, fReasons) = footer("rive", bow)
        XCTAssertFalse(f is FakeRiveFooter)
        XCTAssertEqual(fReasons, ["rive file Bow not found or unreadable"])
    }

    func testRiveWithoutAFileNameIsClassicWithOneReason() {
        CYLRefreshStyleFactory.riveBuilder = FakeRiveBuilder.self
        for options in [[:], ["riveStateMachine": "m"]] as [[String: Any]] {
            let (h, reasons) = header("rive", options)
            XCTAssertFalse(h is FakeRiveHeader)
            XCTAssertEqual(reasons, ["rive needs the creation parameter riveFile"])
        }
        XCTAssertTrue(FakeRiveBuilder.made.isEmpty)
    }

    func testTheOldEntryPointsMakeClassicForRiveWithoutAReport() {
        CYLRefreshStyleFactory.riveBuilder = FakeRiveBuilder.self
        var reported = [String?]()
        XCTAssertFalse(CYLRefreshStyleFactory.header(style: "rive") { reported.append($0) } is FakeRiveHeader)
        XCTAssertFalse(CYLRefreshStyleFactory.footer(style: "rive") { reported.append($0) } is FakeRiveFooter)
        XCTAssertTrue(reported.isEmpty, "rive is a known name: only its options are missing")
    }

    func testOtherStylesIgnoreTheRiveOptionsAndAnUnknownNameIsStillReported() {
        CYLRefreshStyleFactory.riveBuilder = FakeRiveBuilder.self
        let (h, hReasons) = header("phoenix", bow)
        XCTAssertTrue(h is CYLRefreshPhoenixHeader)
        XCTAssertTrue(hReasons.isEmpty)
        let (u, uReasons) = header("rainbow", bow)
        XCTAssertTrue(u is CYLRefreshNormalHeader)
        XCTAssertEqual(uReasons, ["unknown refresh style rainbow"])
        XCTAssertEqual(header(nil, nil).1, ["unknown refresh style (missing)"])
        XCTAssertTrue(FakeRiveBuilder.made.isEmpty)
    }

    // MARK: - The Flutter host

    private func host(_ params: [String: Any]?) -> CYLRefreshDrivenHost {
        let host = CYLRefreshDrivenHost(frame: window.bounds, params: params) { _, _ in }
        window.addSubview(host.layout)
        return host
    }

    func testTheFlutterHostReadsStyleRiveAndTheRiveKeysOfTheCreationParameters() {
        CYLRefreshStyleFactory.riveBuilder = FakeRiveBuilder.self
        var params = bow
        params["style"] = "rive"
        params["footer"] = false
        XCTAssertTrue(host(params).component is FakeRiveHeader)
        params["footer"] = true
        XCTAssertTrue(host(params).component is FakeRiveFooter)
        XCTAssertEqual(FakeRiveBuilder.made.map { $0.file }, ["Bow", "Bow"])
        XCTAssertNil(FakeRiveBuilder.made.first?.values["style"], "only the rive... keys reach the builder")
        XCTAssertEqual(CYLRefreshDrivenHost.Params(params).riveParameters.count, 3)
    }

    func testTheFlutterHostFallsBackToClassicWhenTheRiveFileCannotBeMade() {
        CYLRefreshStyleFactory.riveBuilder = FakeRiveBuilder.self
        FakeRiveBuilder.succeeds = false
        XCTAssertTrue(host(["style": "rive", "riveFile": "Missing"]).component is CYLRefreshNormalHeader)
        XCTAssertFalse(host(["style": "rive", "riveFile": "Missing"]).component is FakeRiveHeader)
        XCTAssertFalse(host(["style": "rive"]).component is FakeRiveHeader, "no riveFile at all")
        XCTAssertTrue(host(["style": "rive", "footer": true]).component is CYLRefreshBackNormalFooter)
    }

    // MARK: - The React Native container

    func testTheReactNativeContainerTakesHeaderRiveAndFooterRiveForTheRiveStyle() {
        CYLRefreshStyleFactory.riveBuilder = FakeRiveBuilder.self
        let container = CYLRefreshContainerView(frame: window.bounds)
        window.addSubview(container)
        let scrollView = UIScrollView(frame: container.bounds)
        scrollView.contentSize = CGSize(width: 320, height: 1200)
        let wrapper = UIView(frame: container.bounds)
        wrapper.addSubview(scrollView)
        container.addSubview(wrapper)
        container.loadMoreEnabled = true
        container.layoutIfNeeded()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))
        // [EN] The style arrives before its parameters (props are set in any order): classic first, then the Rive header. [CN] 样式先于参数到达（属性顺序不定）：先是经典，然后换成 Rive 刷新头。
        container.headerStyle = "rive"
        container.footerStyle = "rive"
        XCTAssertFalse(scrollView.cylHeader is FakeRiveHeader)
        container.headerRive = bow
        container.footerRive = bow
        XCTAssertTrue(scrollView.cylHeader is FakeRiveHeader)
        XCTAssertTrue(scrollView.cylFooter is FakeRiveFooter)
        // [EN] The parameters of a style that is not `rive` change nothing. [CN] 样式不是 `rive` 时，参数不起作用。
        container.headerStyle = "phoenix"
        XCTAssertTrue(scrollView.cylHeader is CYLRefreshPhoenixHeader)
        container.headerRive = ["riveFile": "Other"]
        XCTAssertTrue(scrollView.cylHeader is CYLRefreshPhoenixHeader)
    }
}
