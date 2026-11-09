# Folder instructions

This repository contains an Objective-C table-view placeholder library, an
integrated refresh component, and an iOS example. It inherits the vault's root
instructions. Read `AGENTS.md` before changing the project.

## English naming rules

- Write repository instructions, skill instructions, and new identifier names in English.
- Prefix new project-owned Objective-C class names and corresponding class
  filenames with `CYL`, following `CYLRefreshComponent`.
- Name UIKit category files `<SystemClass>+CYL<Feature>.h` and `.m`, and prefix
  new category selectors and properties with `cyl_`. Objective-C property
  setters use `setCyl_`. Do not rename required system overrides such as `load`.
- Use `CYL` for project-defined type and constant prefixes. Do not copy
  unrelated vendor prefixes into new project APIs.
- These rules apply to new or intentionally migrated code. Do not silently
  rename an existing public API or break callers; document and explicitly
  approve breaking changes.
- Retain required third-party copyright notices, licenses, and source
  attribution even when they contain original names or URLs. Never claim
  third-party code as original work.

## Xcode and CocoaPods project checks

When working on a runnable Xcode project, check its Podfile. At the top, use
the `.xcodeproj` filename in the same folder:

```ruby
platform :ios, '15.0'
ENV['SWIFT_VERSION'] = '5'
project '<projectname>.xcodeproj'
```

At the bottom, ensure the following `post_install` logic is present. If a
`post_install` hook already exists, incorporate the logic into that hook
instead of adding a second hook:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "15.0"
    end
  end
end
```

These settings apply to the runnable project's CocoaPods integration; they do
not by themselves change the library podspec's supported iOS version.

Check whether the app has a launch screen and an app icon with image assets.
If either is missing, copy the corresponding icon and custom launch screen from
`CYLTabBarController`, include their dependent assets and target membership,
and verify the result builds. Do not overwrite existing project assets.

## Commit readiness and TODO tracking

Before every commit, review the current changes and all project comparison,
parity, issue-progress, and implementation-status documents. For every item
that is not fully complete and verified at 100%, ensure a corresponding entry
exists under a `TODO` heading in the most relevant document under `docs/`.
Use an existing relevant document when possible; do not create duplicate
tracking documents.

Each `TODO` entry must identify the incomplete behavior and current score,
describe the remaining work and implementation constraints, and state how it
will be verified. Explicitly document known defects, compatibility risks, and
optimization opportunities. Review public and serialized API design in
particular: identify missing behaviors, inconsistent keys, ambiguous values,
unsupported backends, lifecycle or accessibility gaps, and migration concerns.
Do not treat reserved keys, stubs, successful compilation, or unverified visual
behavior as complete.

After addressing an item, update its status and score from code and test
evidence. Keep every remaining sub-100 item listed with the literal keyword
`TODO`; do not remove a limitation merely because it was attempted. Before
staging, confirm that the documentation covers every sub-100 row in the
relevant score tables and that the descriptions match the current code.

Use an English Conventional Commit subject compatible with Commitizen. The
subject summarizes completed work; use the body for details and pending tasks.
If the detailed description exceeds 50 characters, create or update a suitable
document under `docs/` and link it in the commit body. Reuse the relevant
existing tracker and avoid duplicate documents.
