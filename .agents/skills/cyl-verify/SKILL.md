---
name: cyl-verify
description: Build and test the placeholder library, refresh component, resources, and CocoaPods integration.
---

# Verification

Use the smallest relevant test set and state any unverified behavior.

For a translation or port of another project, verify the merged or translated open pull requests and each fixed open
issue with a test, and update that project's issue table and score (`instructions.md`, "Translating or porting
another project").

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

## Animation playback controls

When verifying an example page that shows animations, check its playback controls (`docs/Example-Animation-Playback.md`,
`instructions.md` "Animation playback controls in examples"): "Play all" restarts every animation from progress 0, the
speed slider (0.25x to 3x) and the loop switch change the playing animations live, and the three combine. Screenshot
the page with a non-default speed and the loop state visible. A page without them stays a `TODO` row in that document.

## Example build errors after a core change

When the Swift migration of the core (or any core change) breaks an example's build, fix the example first: update
its call sites to the core's new Swift API in the same change, then rebuild every example. Never add an alias, a shim,
an extra `@objc` name or a wrapper to the core, or lower its Swift quality, so that an example keeps compiling
unchanged; examples have the lowest weight (`instructions.md`, "Examples have the lowest weight";
`docs/Swift-Migration.md`).

## HarmonyOS: IDE preparation and emulator prerequisites (added 2026-11-16)

Before any HarmonyOS work (building, installing or running a HAP, taking emulator screenshots), check these:

1. **DevEco Studio is installed**: `/Applications/DevEco-Studio.app` (DevEco Studio 6.0). The SDK is the bundled one:
   `DEVECO_SDK_HOME=/Applications/DevEco-Studio.app/Contents/sdk`; `hdc` is at
   `sdk/default/openharmony/toolchains/hdc`; build with the bundled node running
   `tools/hvigor/bin/hvigorw.js assembleHap --no-daemon`.
2. **The region is China.** The emulator (Device Manager, emulator images) is only offered when DevEco Studio's region
   is China. The region file is
   `~/Library/Application Support/Huawei/DevEcoStudio6.0/options/country.region.xml` (the folder follows the DevEco
   version). It must say `<countryregion name="CN"/>`, not another region such as `NZ`:

   ```xml
   <application>
       <component name="CountryRegionSetting">
           <countryregion name="CN"/>
       </component>
   </application>
   ```

   Check it with `grep countryregion "$HOME/Library/Application Support/Huawei/DevEcoStudio"*/options/country.region.xml`.
   If it is not `CN`: quit DevEco Studio first (it writes its settings back on exit), keep a copy of the file, change
   the value to `CN`, start DevEco Studio again and check the file once more.
3. **An emulator image is installed and the emulator starts**: the Mate 70 Pro image under `~/.Huawei/Emulator/deployed`
   (`Emulator -hvd "Mate 70 Pro" -path ~/.Huawei/Emulator/deployed -imageRoot ~/Library/Huawei/Sdk`, from
   `/Applications/DevEco-Studio.app/Contents/tools/emulator/`), signed in to a Huawei account in DevEco Studio when
   the image download asks for it, with hardware virtualization available on the Mac.
4. **Signing is not needed on the emulator**: it installs the unsigned `entry-default-unsigned.hap`
   (`hdc install -r`). Do not ask the owner for a signing setup for emulator runs.

## Running scripts: bash first

- **Run scripts with bash, not zsh (added 2026-11-16).** The interactive shell here is zsh, which does not split an
  unquoted variable into words: `for f in $list`, `cmd $args` or `sips $box` get one argument holding the whole
  string, where bash would pass several. A command that works in bash then fails or measures the wrong thing in zsh
  (seen: "zsh doesn't split $box into words either", and the measurement had to be run again as a bash script).
  So prefer bash for every script and every command with variables, loops or word lists:
  - run a script file with `bash script.sh` (shebang `#!/usr/bin/env bash`), never `zsh` or `sh` when it relies on
    bash behavior; run a one-off multi-line command as `bash -c '…'` or a heredoc piped to `bash`;
  - in zsh, when bash is not possible, use arrays (`files=(a b)`, `"${files[@]}"`) or `${=var}` to split on purpose;
  - quote every expansion (`"$var"`) unless splitting is wanted.
