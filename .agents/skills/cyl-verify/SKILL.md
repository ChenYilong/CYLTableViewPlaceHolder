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
Confirm refresh bundle images, localized strings, privacy manifest and license
are included in the applicable built product. A successful build alone does not
verify on-screen behavior.
