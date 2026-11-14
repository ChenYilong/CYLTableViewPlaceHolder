---
name: cyl-xcode-compat
description: Maintain Xcode project format, deployment targets, schemes, and CocoaPods compatibility for this repository.
---

# Xcode compatibility

Use this skill when changing an Xcode project, scheme, build configuration,
deployment target, or podspec.

- The library podspec minimum is iOS 12.0. Runnable projects' Podfiles follow
  the iOS 15.0 and CocoaPods `post_install` checks in `instructions.md`;
  these settings do not change the library's published minimum. Availability-check
  newer APIs.
- CYLTabBarController is a CocoaPods dependency in every Podfile that uses it: by commit
  (`:git => 'https://github.com/ChenYilong/CYLTabBarController.git', :commit => '<40 characters>'`), the
  newest commit by committer timestamp on any branch, found before every build with
  `scripts/resolve-cyltabbarcontroller-commit.sh [--write <Podfile>...]`; never a version, tag or branch.
  Only a project named CYLTabBarController uses `:path` (relative, to the folder containing the podspec).
  Run `pod install`, or `pod update CYLTabBarController` when a lock pins an older commit
  (`instructions.md`, "Depending on CYLTabBarController").
- Every example Podfile (`Examples/*/Podfile`) also has `pod 'MJRefresh', '<latest version>'` in the app target:
  the highest stable version on the CocoaPods trunk, set before every build with
  `scripts/resolve-mjrefresh-version.sh [--write <Podfile>...]`. Run `pod install` (`pod update MJRefresh` when a
  lock pins an older version) and check the example compiles. If the newest MJRefresh breaks the build, fix the code
  in `CYLRefresh/` and rebuild until it succeeds; never pin an older MJRefresh. The root `Podfile` of the main app is excluded
  (`instructions.md`, "Depending on MJRefresh in the examples").
- `CYLTableViewPlaceHolder.xcodeproj/project.pbxproj` uses object version 46
  and compatibility version `Xcode 3.2`. Keep explicit file references; do not
  silently switch to synchronized groups or a newer project format.
- Keep the example's shared scheme and all source, bundle, privacy manifest,
  and license target memberships intact. Do not add a dependency on generated
  `Pods/` for the example. The main example app (target `CYLTableViewPlaceHolder`)
  is Swift: it depends on, links and embeds the `CYLTableViewPlaceHolderFramework`
  target and imports its module `CYLTableViewPlaceHolder` (the app's own Swift module is
  `PRODUCT_MODULE_NAME = CYLTableViewPlaceHolderExample`, because both products are named
  `CYLTableViewPlaceHolder`); it no longer compiles the core sources itself. The core bundle,
  privacy manifest and licenses stay in both targets' Copy Bundle Resources.
- Xcode 27 simulator SDKs require iOS 15 or later during builds. Project
  configurations use a simulator SDK-specific override; if needed, supply
  `IPHONEOS_DEPLOYMENT_TARGET=15.0` to `xcodebuild`, or set
  `XCODE_XCCONFIG_FILE="$PWD/scripts/pod-lint.xcconfig"` when linting with that
  toolchain. This is a validation override, not a change to the library minimum.
- Do not copy simulator UUIDs, signing identities, development teams, or local
  paths from another repository. Select an available simulator at runtime.
- After editing a project, parse it with `xcodeproj`, inspect its build phases,
  and build the example. Report any Xcode version not actually verified.
