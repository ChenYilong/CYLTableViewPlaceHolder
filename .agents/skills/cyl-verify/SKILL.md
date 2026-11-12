---
name: cyl-verify
description: Build and test the placeholder library, refresh component, resources, and CocoaPods integration.
---

# Verification

Use the smallest relevant test set and state any unverified behavior.

Before verifying, the task must already have its `TODO` entry in `docs/` (`instructions.md`, "Record every task in
docs before starting it"); after verifying, write the results into that entry and mark it done.

New branch: open its pull request right away, without asking, with the source branch as the base (`main` or
`master` only when that is the source, or the source is gone); see `instructions.md`, "A pull request for every new
branch":

```sh
git push -u origin <new-branch>
gh pr create --base <source-branch> --head <new-branch> --fill
```

Image audit (every change to the core or the examples): search for image-setting code and check each hit uses
`CYLPlaceholderView`'s image API, or carries a comment that says why it uses a system `UIImage` / `UIImageView`
instead (`instructions.md`, "Reuse CYLPlaceholderView in the core"):

```sh
grep -rnE 'setImages|setImage|\.image *=|animationImages|UIImageView' CYLTableViewPlaceHolder Examples --include='*.m' --include='*.swift'
```

```sh
ruby Tests/run-tests.rb
DESTINATION='platform=iOS Simulator,name=iPhone 15,OS=17.5' ruby Tests/run-animation-tests.rb
DESTINATION='platform=iOS Simulator,name=iPhone 15,OS=17.5' ruby Tests/run-tests.rb
xcodebuild -project CYLTableViewPlaceHolder.xcodeproj -scheme CYLTableViewPlaceHolder -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' IPHONEOS_DEPLOYMENT_TARGET=15.0 CODE_SIGNING_ALLOWED=NO build
XCODE_XCCONFIG_FILE="$PWD/scripts/pod-lint.xcconfig" pod lib lint CYLTableViewPlaceHolder.podspec --allow-warnings --platforms=ios
```

Before building anything that depends on CYLTabBarController (the demos), run
`scripts/resolve-cyltabbarcontroller-commit.sh --write Examples/*/Podfile` so the Podfiles point at its newest
commit on any branch, then `pod install` (`pod update CYLTabBarController` if a lock pins an older commit);
report the commit that was used.
Examples also depend on the latest MJRefresh: run `scripts/resolve-mjrefresh-version.sh --write Examples/*/Podfile`
before building them (`scripts/ci-build-example.sh` does it) and report the version. A build that fails with the
newest version is fixed in `CYLTableViewPlaceHolder/CYLRefresh/` and rebuilt until it passes; never pin an older MJRefresh.

The test runner requires the `xcodeproj` Ruby gem and an available simulator.
The animation runner installs the optional CocoaPods backends into an isolated
temporary project. It uses PAG and Rive fixtures from the sibling
`CYLTabBarController` checkout; override them with `PAG_FIXTURE` and
`RIVE_FIXTURE`, `RIVE_TRIGGER_FIXTURE`, and `RIVE_LINEAR_FIXTURE`. Set `LINKAGE=dynamic` to test dynamic frameworks; static is
the default. Set `PAG_SUBSPEC=PAGEnterprise` to test the enterprise PAG
subspec instead of `PAG`. CocoaPods needs `LANG=en_US.UTF-8`. Build the
example through `CYLTableViewPlaceHolder.xcworkspace`, not the project. The fixtures must be named `tab_home.pag` and `icons.riv` and
have the expected Rive artboard and state machine. Trigger and linear fixtures
must be named `check.riv` and `button.riv` and contain the corresponding
`Check` trigger and `active` animation used by the tests.
Select a real device and runtime with `xcrun simctl list devices available`.
When an example shows CYLTabBarController, check it follows the default integration (`instructions.md`,
"Integrating CYLTabBarController in the examples"): built from a configuration file in the example's bundle,
a PlusButton whose `plusChildViewController` page is selectable (`hasPlusChildViewController` is YES), localized
titles and plus button label. The plus button bulges: in a screenshot its top edge is above the tab bar's top edge,
and a tap on the raised part opens its page.
Where it runs (`instructions.md`, "CI/CD"): GitHub CI/CD runs iOS jobs on macOS 26
(`vars.MACOS_RUNNER || 'macos-26'`); read CYLTabBarController's
`https://github.com/ChenYilong/CYLTabBarController/blob/master/.github/workflows/ios.yml`
first to confirm the runner, and match it. A local run (your own Mac, no GitHub CI/CD,
simulator and Xcode started directly) ignores that and assumes macOS 27 with Xcode 27.
The 15.0 override is for Xcode 27; use the supported minimum for the toolchain
in use. When CocoaPods packaging changes, also lint with `--use-libraries`.
Run `python3 scripts/update-docs-navigation.py --check` after any change to `README.md` or `docs/` (drop
`--check` to regenerate), and lint the Markdown with `.markdownlint.json`.
Run `python3 scripts/check_localizations.py` after any localization change, and confirm
the project still defines at least two different lookup macros (the core's and an
example's), each reading its own bundle (`instructions.md`, "Lookup macros"), and that resources are read the
same way (`CYLPlaceholderResourceURL` for the core, each example's own lookup).
Check accessibility for every changed control and text (`instructions.md`, "Accessibility"): unit tests for labels,
traits, hidden decorations and the not-enabled state; UI tests find elements by label or identifier; then follow the
`accessibility-audit` skill (VoiceOver, Dynamic Type at the largest sizes, Reduce Motion) on a simulator. Compilation
does not verify accessibility.
Confirm `CYLTableViewPlaceHolder.bundle` (all images and both strings tables), privacy manifest and license
are included in the applicable built product. A successful build alone does not
verify on-screen behavior. Every CI build must also provide a screenshot of each
example running: `scripts/ci-build-example.sh <folder>` captures it (artifact
`example-screenshot-<folder>` in CI); report the artifacts with the CI result,
or fix the CI, or give the concrete reason none could be produced
(`instructions.md`, "CI example screenshots").

Screenshots, local and CI/CD (`instructions.md`, "Screenshots of local builds and CI/CD"): take them at key moments
(a `TODO` or "Linux" note can go, a pull request can be merged, or the result meets the expectation with no bug);
crop to the key detail; stitch vertically (top to bottom) first, then two columns, a single row last (at most three per row);
store them in `docs/assets/` embedded in the fitting document and commit them; when the result is right, update the
README with the platform (iOS, Android, Flutter, React Native, HarmonyOS, mini program), the OS, simulator and SDK
versions, the commit link and the time; use clear original images.
Before committing a verified change, check the message contains the author line
`By @ChenYilong <luohanchenyilong@163.com>` on its own line before the trailers (`instructions.md`,
"Author line in every commit message").
Run `python3 scripts/check_doc_comments.py` after changing a public header or a Swift file of the library: every
documentation comment, single-line or multi-line, is a three-line-or-longer `/*!` (Objective-C) or `/**` (Swift) block
with the markers on their own lines, no trailing comment follows code, and a file never mixes formats
(`instructions.md`, "Code conventions").
