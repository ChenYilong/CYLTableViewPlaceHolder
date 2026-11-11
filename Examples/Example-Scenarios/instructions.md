# Folder instructions

Aggregated placeholder demo, written in Swift: a CYLTabBarController tab bar with a plus button, modeled on
CYLTabBarController's Objective-C demo. It only calls the library's core API; scenario structure, texts and animations
belong to the core.

| Tab | File | What it shows |
| --- | --- | --- |
| Scenarios | `Sources/CYLScenarioListViewController.swift`, `CYLScenarioDetailViewController.swift` | Every `CYLPlaceholderScenario` of `CYLPlaceholderScenarioCatalog` (README screenshots, then business cases); each row pushes `CYLPlaceholderStackView(scenario:actions:)` with handlers for retry, contact support (pushes a page), open settings, go shopping and done. The 🌐 button at the top switches the language. |
| Animations | `Sources/CYLAnimationListViewController.swift` | Every file of `CYLTableViewPlaceHolder.bundle/Animations`, by engine; "Sources" shows `NOTICE.animations`. |
| Flows | `Sources/CYLFlowListViewController.swift` | Switching states (#3), keeping the table header (#17) and section headers (#16), refresh controls (#8), a scrollable placeholder, a collection view (#11). |
| Feed | `Sources/CYLFeedViewController.swift` | Loading, alternately failing refresh with a Retry scenario, load more. |
| Plus button | `Sources/CYLScenarioTabBarController.swift` | The Uploading scenario, then Success with a Done button. |

- Run `pod install` here, then open `Example-Scenarios.xcworkspace`. The Podfile uses the local library
  (`:path => '../..'`) with the LottieSwift, PAG, Rive and GIF subspecs, CYLTabBarController at its newest commit
  (`scripts/resolve-cyltabbarcontroller-commit.sh --write Examples/Example-Scenarios/Podfile` before every build; CI
  does it) and the latest MJRefresh.
- Language switch (`Sources/CYLScenarioLanguage.swift`): sets `CYLPlaceholderLocalization.language`,
  `CYLRefreshConfig.default.languageCode` and `CYLSetLocalizationLanguage`; the window's
  `cyl_setRootViewControllerProvider` (`CYLScenarioAppDelegate.swift`) rebuilds the whole interface.
- Text: scenario texts come from the core bundle. The demo's own texts live in `Sources/CYLScenarioExample.bundle`
  and are read only through `CYLScenarioLocalizedString(_:)` with a `CYLScenarioL10n` key
  (`Sources/CYLScenarioLocalization.swift`); add a key to the enum and to all seven `.strings` files, then run
  `python3 scripts/check_localizations.py`.
- Configuration files: `Sources/CYLScenarioExample.bundle/Configurations/*.json|plist`, listed in the last section of the
  Scenarios tab and opened by `Sources/CYLConfigurationViewController.swift` with `CYLPlaceholderStackView(contentsOf:actions:)`.
  A file that uses the example's own texts marks them `exampleTitleKey` (a `CYLScenarioL10n` raw value); the example
  resolves them and calls `CYLPlaceholderStackView(configuration:actions:)`. Add a file to add a demo; the format is in
  `docs/Placeholder-Scenarios.md`.
- The detail page's "Tap: on/off" button sets every component's `tapInteractionEnabled` (each component's own API).
- To add a scenario, add it to the core (`CYLPlaceholderScenario.h/.m`, core strings, tests); the list picks it up.
- The Xcode project (objectVersion 46) lists the Swift files explicitly; add a new file to the `ExampleScenarios`
  target.
- The app icon and launch screen come from CYLTabBarController (MIT); keep `LICENSE.third-party`. Inherit the
  repository instructions.
