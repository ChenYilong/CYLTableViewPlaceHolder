---
name: cyl-verify
description: Build and test the placeholder library, refresh component, resources, and CocoaPods integration.
---

# Verification

Use the smallest relevant test set and state any unverified behavior.

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
Before committing a verified change, check the message contains the author line
`By @ChenYilong <luohanchenyilong@163.com>` on its own line before the trailers (`instructions.md`,
"Author line in every commit message").
