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
- `CYLTableViewPlaceHolder.xcodeproj/project.pbxproj` uses object version 46
  and compatibility version `Xcode 3.2`. Keep explicit file references; do not
  silently switch to synchronized groups or a newer project format.
- Keep the example's shared scheme and all source, bundle, privacy manifest,
  and license target memberships intact. Do not add a dependency on generated
  `Pods/` for the example.
- Xcode 27 simulator SDKs require iOS 15 or later during builds. Project
  configurations use a simulator SDK-specific override; if needed, supply
  `IPHONEOS_DEPLOYMENT_TARGET=15.0` to `xcodebuild`, or set
  `XCODE_XCCONFIG_FILE="$PWD/scripts/pod-lint.xcconfig"` when linting with that
  toolchain. This is a validation override, not a change to the library minimum.
- Do not copy simulator UUIDs, signing identities, development teams, or local
  paths from another repository. Select an available simulator at runtime.
- After editing a project, parse it with `xcodeproj`, inspect its build phases,
  and build the example. Report any Xcode version not actually verified.
