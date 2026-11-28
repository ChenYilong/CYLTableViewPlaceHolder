# Hand-over: merge the open PRs, publish the packages, close the port gaps

Written 2026-11-26 by the departing Windows developer (session "winsCYLTableViewPlaceHolder"), for the next developer.
Repository: <https://github.com/ChenYilong/CYLTableViewPlaceHolder>. Integration branch: `feat/android-refresh-port-followup` (PR #31).

**Folder rule.** `docs/todo/<YYYYMM><WW>/` where `WW` is the week of the month, counted as `ceil(day / 7)` with weeks
starting on day 1 (day 22 to 28 is week 04). 2026-11-26 is the 4th week of November 2026, so this folder is `20261104`.
Next week (2026-11-29 and later) is `20261105`. **One file per folder: if the folder already has a file, append to it;
do not create a second file.** The Mac developer appends the iOS chapter and the iOS rows of the tables to this file.

**Scope of this version.** Chapters for Android, HarmonyOS, WeChat mini program, React Native and Flutter are written
here (Windows). The "iOS" chapter and the iOS cells of the tables are the Mac developer's; empty cells say so.

## 1. What to do next (in this order)

1. **Get the integration branch merged.** Nothing has reached `master` (last master commit 2026-11-15). PR #31 is about
   1011 commits ahead of master. Decide the merge order of the open PRs (section 3) and merge them into #31 or close
   them as contained. Every PR below has diverged from #31 (none is an ancestor of the other); each needs a merge of
   origin into it, not a rebase.
2. **Pins off feature branches.** The Android and HarmonyOS examples pin ClassifyMenu on `feat/glass-backdrop`
   (`android/classifymenu.commit` = `c0b183de12c62c8b0b575b5a9ff0613f9a970468`), and the Android CI resolves the newest
   CYLTabBarController commit across all branches. Move both pins onto released commits once upstream tags them.
3. **Finish the in-flight Android tag-list example** (section 5): uncommitted work lives only on the previous
   developer's machine; the colleague must ask for it or redo it from the acceptance list in `docs/Task-Log.md`.
4. **Publish.** Nothing is on any registry (Maven Central, npm, pub.dev). Each needs the owner's account (section 7).
5. **Close the verification gaps** in the tables of section 3 and 4: much of HarmonyOS, Flutter and React Native is
   "built and host-tested, not seen on a device".
6. **Answer the open owner decisions** (section 6) or ask the owner; several block code.

**iOS priorities (added by the Mac developer, 2026-11-26; details in section 5.6):**

1. **Port the work that exists only on PR #35** (46 commits, conflicts in 10 files). It holds iOS core fixes and fixes on
   four platforms. This is the largest iOS item.
2. **Get a green macOS CI run on the current head.** Full "iOS" runs have been queued on `macos-26` since `057dec87`.
3. Finish or check the CI fix for run 45566803410 (`docs/Task-Log.md`, entry still marked TODO when this was written).
4. Fix the React Native `refreshing` toggle bug (section 8).

## 2. Rules you must follow

Read `AGENTS.md` and `docs/instructions/*.md` first. Highlights:

- Commit message body ends with `By @ChenYilong <luohanchenyilong@163.com>`; no Co-Authored-By; never bypass hooks
  (`--no-verify`, `core.hooksPath`); no rebase, no force-push, no stash; merge origin before pushing.
- HarmonyOS: unsigned HAP only (never ask for signing). Do not change any `finishTimeout`. Do not change the CI pin rule
  in `scripts/resolve-cyltabbarcontroller-commit.sh`.
- Emulators: stop the app and the emulator after every test (`docs/instructions/testing.md`, "Emulator run rules").
  To free RAM on Windows use [`scripts/free-ram-windows.ps1`](../../../scripts/free-ram-windows.ps1), manual in
  [`docs/Free-RAM.md`](../../Free-RAM.md). Run it only when no session is debugging; use `-KeepEmulator`.
- Heavy Gradle/hvigor jobs take the lock `C:/w/heavy.lock` (mkdir); never remove a lock you did not create.
- Windows tooling: Python is `py -3`. Android emulators: `emulator-5556` (`Medium_Phone_API_37.0`), `emulator-5558`
  (`CYL_Second_API_37`); HarmonyOS: "Mate 70 Pro" at `127.0.0.1:5555`.

## 3. All open branches and PRs

Progress is the previous developer's estimate of the non-iOS work on that branch (not a measurement). Branch links are
GitHub URLs. iOS cells are for the Mac developer.

| Branch (open) | Progress (non-iOS estimate; iOS estimate in bold) | TODO items |
| --- | --- | --- |
| [`feat/android-refresh-port-followup`](https://github.com/ChenYilong/CYLTableViewPlaceHolder/tree/feat/android-refresh-port-followup) (PR #31, integration branch, 1011+ commits ahead of master) | Android 90, HarmonyOS 82, mini program 84, Flutter 80, React Native 70 (docs' own scores: P:606-610) | Merge into master; Android tag-list example (in flight, section 5); W4: `loadsAfterNoMoreData` in TS spec and Android, `onSecondaryOpened` lifecycle (Flutter and Android); W5: Flutter Rive footer pull-up on Android, spinner style from the creation parameter; Android resource-missing strings are English in 7 languages; `docs/Task-Log.md` open TODOs; remove the reflection hook in the red bar once the engine commit is in every resolver-pickable commit. **iOS 90%.** iOS TODOs: port the #35 fixes; get a green macOS CI run on the current head; close the CI-fix entry for run 45566803410; fix the React Native `refreshing` toggle bug; see the Rive early end on screen; all items in section 5.6 and Appendix A. |
| [`feat/harmony-example-taglist`](https://github.com/ChenYilong/CYLTableViewPlaceHolder/tree/feat/harmony-example-taglist) (PR #39, head `a3cb9821`, 9 ahead / 23 behind #31) | 90 | HarmonyOS example Flows tab uses the ClassifyMenu tag list (glass board and tags, tail control, gradient page); the example instruction files (`docs/instructions/examples.md`) live here; merge origin into it, then into #31; re-vendored ClassifyMenu `bbe56951` and CYLTabBarController `6f563ef4` are feature-branch pins. **iOS:** no iOS code is the point of this PR; it conflicts with #31 in `AGENTS.md`, `instructions.md` and `.agents/skills/cyl-examples/SKILL.md`. Resolve with the #31 wording, which was synced to the newer ClassifyMenu rules. CI on its head: Unit tests and iOS 15 runtime failed (same test family as fixed on #31). Merge ClassifyMenu #37 first or move the pin. |
| [`feat/red-bar-debug-guard`](https://github.com/ChenYilong/CYLTableViewPlaceHolder/tree/feat/red-bar-debug-guard) (PR #38, head `55e15254`, 2 ahead / 61 behind) | 90 | Debug guard for the missing-resource red bar on iOS and Android; replace the reflection hook with direct `CYLAnimationEngines.resourceMissingListener` calls once the engine commit is pickable; `Missing resources: %1$s +%2$d more` has no translations and no iOS key yet. **iOS 75%:** CI "Framework build and analyze" and "Unit tests" succeeded on its head (whether the new test ran there is unverified), so the PR text saying the iOS half was never compiled is partly outdated; add the iOS string key; its iOS 15 failures are the container-view tests fixed later on #31; the bar was not seen on an iOS screen. |
| [`feat/harmony-missing-resource-bar`](https://github.com/ChenYilong/CYLTableViewPlaceHolder/tree/feat/harmony-missing-resource-bar) (PR #37, head `a19bbcc5`, 3 ahead / 63 behind) | 90 | Red status bar names a missing animation file on HarmonyOS; needs a merge with #31 and a device look at the bar. **iOS:** no iOS change. CI on its head: Docs navigation, Unit tests and iOS 15 runtime failed; the iOS 15 log shows the test family fixed on #31 by `6333e813` / `30202b71` (cause of the other two jobs unverified). |
| [`feat/android-refresh-port`](https://github.com/ChenYilong/CYLTableViewPlaceHolder/tree/feat/android-refresh-port) (PR #36, head `50937aa0`, 19 commits not in #31) | 60 (old line) | Decide: merge the 19 commits into #31 or close the PR. Its Android tree lacks `titleMaxLines`, so an example pinned to ClassifyMenu from this line does not compile (the repin to `e20eef2` was refused for this reason). **iOS:** targets `master`, not #31; mostly pre-Swift Objective-C; the iOS 27 SwiftUI fix `05c7f126` is not on #31 (sampled lines; same gap as `a169386c` on #35). Port one of the two, then close or update (owner's call). Its CI checks are green against `master`. |
| [`fix/ios-swift-todos-placeholder`](https://github.com/ChenYilong/CYLTableViewPlaceHolder/tree/fix/ios-swift-todos-placeholder) (PR #35, head `b7dec930`, 46 ahead / 314 behind) | **iOS 70%** (done, not integrated) | **Not on #31** (all 46 commits unmerged), conflicts in `CYLRefreshDrawnFooter.swift`, `CYLRefreshDrawnHeader.swift`, `CYLPlaceholderScenario.swift`, `CYLPlaceholderView.swift`, `UIViewController+CYLPlaceholderStatus.swift`, 3 Example-Scenarios list controllers, `Task-Log.md`, `iOS-API-Map.md`. Port the commits listed in section 5.6.2. No CI checks on its head. Its Kotlin / ArkTS / JS rename needs owner approval for a new branch. |
| [`ci-screenshots`](https://github.com/ChenYilong/CYLTableViewPlaceHolder/tree/ci-screenshots) (no PR, screenshot publishing, 212 ahead / 1382 behind) | n/a | Output of `scripts/ci-publish-screenshots.sh`; do not merge into #31; decide if it stays. No shared history with the code branches (artifact branch). |
| [`master`](https://github.com/ChenYilong/CYLTableViewPlaceHolder/tree/master) (last commit 2026-11-15) | n/a | Target of the final merge; fully contained in #31. |

Related repositories (their branches carry pins used here): CYLTabBarController
[`feat/harmony-animated-item-engines`](https://github.com/ChenYilong/CYLTabBarController/tree/feat/harmony-animated-item-engines)
(selected-icon tint fix `d19e138e`; HarmonyOS icon rendering mode added), CollectionViewClassifyMenu
[`feat/glass-backdrop`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/feat/glass-backdrop)
(`c0b183de`; a later SHA with "board shares the tag glass" and the two-reference icon lift is announced by its owner).

## 4. Local-only work (the colleague cannot see it on GitHub)

| Item | Where | State |
| --- | --- | --- |
| Android example menu lists as ClassifyMenu tag lists (glass tags, tail fold control, liquid backing plate, gradient page, night-aware plate) | main checkout of the previous developer (uncommitted: `TagMenu.kt`, converted pages, `android/classifymenu.commit`, `scripts/classifymenu-checkout.sh`, workflow, Task-Log) | A worker was still capturing final screenshots on `emulator-5556`; commit and push expected after this document. Ask the previous developer, or check `git log` for "tag list" commits after 2026-11-26. |
| `tab-tint` branch (`C:/w/tab-tint`) | local only | Holds `79679d97`, a commit made with hooks disabled. **Never push it.** Its screenshots were re-committed through the push worktree. |
| Free-RAM script and manual | this push | `scripts/free-ram-windows.ps1`, `docs/Free-RAM.md`; a macOS script is not written. The Search repo has its own `docs/Release-RAM.md`: unify the names. |

## 5. Platform chapters (non-iOS)

### 5.1 Android

Score by the docs: 94 (P:606). Advisor estimate 2026-11-26: progress 90, release readiness 65.

Done and verified this period: W1 emulator verification; W2 root-cause fix with on-emulator proof; Rive "drawn table"
clip (Bow) and the early hide 500 ms before the hold ends (black rows 0 in 3 runs); RN Android footer second floor
(`62bad2cc`); tab-bar selected-icon tint (CYLTabBarController `d19e138e`, pixel-verified: JSON, Discover and Me now equal
Message, `#007AFF` light and `#0A84FF` dark).

Open:

- Android example tag-list conversion (acceptance in `docs/Task-Log.md` "TODO (started)": all index screens converted,
  a pure-mapping unit test, batch build green, emulator captures and a sheet). Not seen on an emulator before this work:
  the callout and real 3-line title wrapping. No real title reaches 3 lines (the longest wraps to 2 at font scale 2.0).
- Library defect: the long-press callout stays on screen after switching tabs and after tapping blank space
  (CollectionViewClassifyMenu Android; report sent to its owner).
- Dark-mode defect found: the pastel plate was not night-aware, so dark-mode glass tags sampled bright colours and white
  text was unreadable; a night-aware plate was added (uncommitted, section 4).
- Unverified: drawn-footer colours while pulling; footers in front/behind; Rive footer and its fallback; Bezier circle
  frame; `hapticFeedback` only tested as a call; native `onSecondaryOpened` not logged; native `scrollMode` spinner style
  from the creation parameter.
- `CYLRefreshLayout`: 133 issues marked "TODO: handled in the Kotlin version with a test", 5 left (AP:452-458, 566);
  #1081, #1234, #1315, #1521, #1566 need a device or a MotionLayout scene.
- Publishing to Maven Central / GitHub Packages: blocked on the owner's account and signing key; the upstream
  `cyltabbarcontroller-animateditem` is also unpublished, so consumers outside the composite build cannot resolve it.
- Lottie/PAG animations for the other scenario categories (load failed, permission, progress, success, HUD) (AP:969).
- CI: the Android job resolves the newest CYLTabBarController commit across branches (iOS is pinned); a branch without
  the engine API becoming newest breaks Android CI again. Run `:placeholder:testDebugUnitTest` and a selection-change
  check after any pin move.
- Six `CYLPlaceholderResourceMonitor` rows in the API map have TODO in the iOS column.
- Plus page Success state showed no icon on the 2026-11-21 emulator run; not confirmed fixed on Android (AP:1022).

### 5.2 HarmonyOS

Score by the docs: 85 (script score 99). Advisor estimate: progress 82, release readiness 50.

Done: Rive drawn-table clip (`4596e2ed`, host tests 132/132 and entry 3/3); Feed footer fix (`6bcb2867`: the auto footer
shows the icon only while Refreshing; `cylAdopt` runs the pending play command); icon rendering mode on items and
controller (CYLTabBarController `d19e138e`, hypium 63 passed x3; measured selected `#047CFC`, unselected `#8C8C94`).

Open:

- **No CI for HarmonyOS** (build and `hypium` run on a local emulator only).
- Many rows "built, host-tested, not seen on a device" (HO:445-509, 702-704, 746, 770-773, 816-817, 1294-1297).
- Feed footer: re-check that "No more data" appears at 30 rows (the frozen spinner was fixed; the label was never seen).
- Held pull of the drawn footer rows and the BallPulse rows not captured; held pull per scroll mode (Stretch vs Behind).
- Rive END black-rows measurement and the on-screen look of the clip and early hide are not done.
- 3 API rows need the animator/gestures and a device: `reboundAnimationOptions`, `supportsHorizontalDrag`,
  `-didDragHorizontallyWithOffset:percent:`.
- "Every animation through `CYLPlaceholderViewModel`": `refresh/CYLRefreshView.ets` (ImageAnimator directly) and
  `refresh/CYLRefreshIconView.ets` (picks the engine itself) bypass it (score 70 as written).
- `cyl-refresh` Stretch/Front property needs component work; the native icon component never reads the `animation` key.
- Stale statements in `docs/HarmonyOS.md` (2026-11-16 status vs later tables, e.g. HO:99 vs HO:202/210; Rive options
  `active`, `trigger`, `color`, `legacy`): verify and clean up.
- The x86_64 emulator installs a HAP only without arm64-only libs (use the `emulator` target and `cyl_hap_x86_64.py`).

### 5.3 WeChat mini program

Score by the docs: 86. Advisor estimate: progress 84, release readiness 45.

Open:

- `npm publish` of `cyl-placeholder-miniprogram@0.2.0` needs the owner's `npm login`; `cyl-tag-list-miniprogram` 0.2.0
  (ClassifyMenu) pending.
- Search example run in WeChat DevTools failed before rendering: `module '.../cyl-dealloc-block-executor/registry.js' is
  not defined` (vendored module, cause open).
- No real phone check (skipped; "no physical devices" is the owner's rule); dark mode, other device sizes, touch
  behaviours (drag distances, trigger modes, second floor, trailer pull) not verified.
- Animations: PAG/Rive/GIF variants show the static icon or first JSON variant; Lottie on the HUD and dark-mode colours
  not done; only `.json` plays for the native `animation` key.
- Known differences accepted: `CYLPlaceholderStatusView`, `CYLPlaceholderConfiguration`, `CYLPlaceholderHUD` gaps;
  `cyl-refresh` cannot report the pull beyond the threshold, hides the header at refresh end.
- `cyl-tabbar-miniprogram` stays commit-pinned until CYLTabBarController publishes it (owner decision relayed 2026-11-19).

### 5.4 React Native (old architecture only)

Score by the docs: 72. Advisor estimate: progress 70, release readiness 40.

Open:

- Android: Rive style not seen; `CYLRefreshPaging` not run on a device; HUD `showProgress`/info/error not seen; animated
  icon does not play in the stack example (no Lottie library in the example app).
- `npm run typecheck` not run; the library's `tsc` reports 3 `react-native-cyltabbar` errors (optional peer missing).
- Example pages not built: `styles_page`, `secondary_page` on the Android container, `placeholder_stack_page`.
- `react-native-cyl-tag-list`: native compile verification pending; do not convert RN until the bridge is confirmed.
- README "Not covered": repeat count N > 1, Reduce Motion policy, scenario catalog, status views, HUD look fields.
- Footer second floor drives the native `CYLRefreshBackFooter`, so it needs a back-footer style such as `classic`.
- iOS RN Rive view blank gap for ~2 s of the pull: `isOpaque = false` fix not tried (no failing-first test possible).
- New architecture is out of scope (owner).

### 5.5 Flutter

Score by the docs: 84. Advisor estimate: progress 80, release readiness 50.

Open:

- Flutter bridge for the tag list: owned by the CYLSearchViewController session; do not convert until confirmed.
- Missing example demos: trigger mode, refresh on start, listener, chat, user profile; `refresh_page`, `paging_page`,
  `error_placeholder_page`, `placeholder_stack_page`; styles page completeness.
- Footers (Cupertino, Material) and the Rive footer pull-up on Android not run on a device; Dart has no `stretch` mode.
- Remaining older score-table rows still marked TODO (P:297-380); Dart/TS features are frozen by decision, so these
  rows need an owner call.
- README "Not covered (TODO)": repeat count N > 1, Reduce Motion policy, scenario catalog, HUD and status views.
- Android `message` of a single placeholder is not accepted (returns no view).

### 5.6 iOS

Written by the Mac developer on 2026-11-26 (session "Mac-CYLTableViewPlaceHolder"). Percentages and scores are
advisor estimates from the project documents, not measurements. "Unverified" means nobody proved it.

#### 5.6.1 State today

- **Pins.** CYLTabBarController and CYLAnimatedItem: `b0887513a3c9221af4257884d5d5740baaa8e76b` (branch
  `feat/harmony-animated-item-engines`, CYLTabBarController PR #824), in `Cartfile`, four example Podfiles and the
  tracked `Podfile.lock` files; `.github/workflows/ios.yml` reads it. This **replaces** the `12ed11ff` / `abb5bc3b`
  statement in section 6, item 3, for iOS. The Android CI still resolves the newest engine commit on any branch.
- **ClassifyMenu (examples only):** iOS pins `00b40e8dd222aeffab3002883175431c05e5dd1a` (branch
  `feat/tag-final-merge-plus`, no open PR in that repository's list when checked, so whether it reaches its `master` is
  unverified). Android and HarmonyOS pin a different commit (section 3).
- **CYLDeallocBlockExecutor:** iOS pins `4276a6dab5a428ccc3a5f3f347eab991881fb97c` (1.4.0, not on CocoaPods trunk) in
  `Example-Scenarios` only. `Example-objc-01`, `-objc-02` and `-SwiftUI` do not pin it, so
  `scripts/ci-build-example.sh` injects its newest commit in CI. Suggestion: pin it in all Podfiles.
- **Other pins:** the Flutter `pubspec.yaml` engine ref `f66e85d5` is stale (differs from the Cartfile); HarmonyOS
  engine copy `269eff24` (PR #39 moves it to `11fc94be`); mini program item copy `12ed11ff`.
- **Local verification (2026-11-26, iPhone 18 Pro simulator, iOS 27.2):** `ruby Tests/run-tests.rb` 383 tests,
  0 failures at `12b941b0`; `scripts/ios-api-map.py --check` 877 / 877.
- **Verified with the new engine pin:** the launch status bar is correct in light and dark mode. The example keeps two
  overrides (navigation-controller `childForStatusBarStyle` forwarding and the tag list's `preferredStatusBarStyle`);
  removing either gave a white clock on the light gradient. Details: [`Task-Log.md`](../../Task-Log.md), entry
  "Engine pin b0887513"; [`Status-Bar.md`](../../Status-Bar.md).
- **CI, precisely:** the last fully green "iOS" workflow runs seen were on `f1e4d08b`, `ee0ce13c` and `8e6c499d`.
  Full "iOS" runs from `057dec87` onward were still queued on `macos-26`. The separate "iOS 15 runtime" workflow did
  run on some of them (failed on `057dec87`, before the test fix `30202b71`) and was queued from `aa102c73` onward.
  "Docs navigation" passed on CI at `12b941b0`. The Swift test fixes have **no CI result yet**. There is no real iOS 15
  runtime anywhere: that job runs the newest simulator with a 15.0 deployment target.
- **Run 45566803410** (old head `62bad2cc`; Unit tests and three Animation PAG jobs red). The logs show
  `testLottieColorOverridesFollowAppearance` in the Animation jobs and `DrivenLayout` / `DrivenStyles` tests in Unit
  tests. Later commits touch those: `4f0542cd` (Lottie colours), `6333e813` and `30202b71` (test waits). None is
  confirmed on CI. The follow-up task was still running when this was written (`Task-Log.md` TODO, commit `7a457097`):
  read that entry for its result.

#### 5.6.2 Work that exists only on PR #35 (port it)

| Commit | Content | Platforms |
| --- | --- | --- |
| `a169386c` | Example-SwiftUI finds its scroll view on iOS 27 (MJRefresh #1628) | iOS example |
| `4236e998` | "Success" still image is a check mark (it is `.info` on #31) | iOS core |
| `bbd11906`, `4aba938c`, `83eec946`, `ac9f3e94` | Hide the load-more footer / trailer while the empty placeholder shows (missing on #31 by code reading; not reproduced) | iOS, Android, mini program, HarmonyOS |
| `dae85827`, `07fb2336` | Back footer keeps the pinned section header at the top (#1627, #1507) | iOS core |
| `c5fbcdc6` | Fast-pull stress test, NaN-safe interpolators, `SECURITY.md`, Dependabot | iOS, repository |
| `b2d7c5c2` | Header keeps bounds-placed views while refreshing (#1568) | iOS core |
| `98b4861b` | Back footer leaves the new rows' offset to UIKit (#1146) | iOS core |
| `a6cbd28b` | A refresh begun off screen starts without animation (#862) | iOS core |
| `b1190580` and tests | Footer layout regression tests (#1583, #1595, #1591) | iOS tests |
| docs commits from `985b7d04` | The upstream MJRefresh issues that #31 still lists as "not investigated" are investigated and scored | docs |
| `6554be19` | CI retries `pod install` | CI |
| `0c8961f6` | Swift renames for SonarCloud S100 / S115 / S116, Objective-C selectors unchanged | iOS |

`0d43bc9f` (engine pin `f51057a7`) is superseded by `b0887513`; do not port it.

#### 5.6.3 iOS TODOs

1. Port section 5.6.2 into #31 (merge, never rebase).
2. Get green macOS CI on the current head; then ask for a new score (the 2026-11-25 scoreboard waits for it).
3. Close the CI-fix entry for run 45566803410. If a test still times out on a slow runner (one run took 10.2 s in one
   test), raise the `waitUntil` cap (15 s). About 20 fixed `runUntilDate` waits remain (owner decision to convert them
   all at once).
4. Fix the React Native `refreshing` toggle bug (section 8).
5. Rive: see the "stop ends the hold early" path on screen or cover `CYLRiveStopReportingViewModel` -> `onStop` with a
   real file.
6. Restore "newest engine commit" resolution and remove the exact-pin step in `ios.yml` only after CYLTabBarController
   #823 / #824 merge.
7. Release: the CHANGELOG "Unreleased (next major)" entry (iOS 15 minimum, no Objective-C subclassing of CYLRefresh) is
   not released. `pod trunk push` is blocked because `CYLAnimatedItem` and `CYLDeallocBlockExecutor` 1.4.0 are not on
   CocoaPods trunk.
8. Pin `CYLDeallocBlockExecutor` in the three other demos; refresh the Flutter engine ref and test.
9. Fix stale text in [`CI-CD.md`](../../CI-CD.md): it still says the podspec targets iOS 12; it targets 15.
10. Close GitHub issues #8, #10, #11, #16 (scored 100; owner's call).
11. Low priority: corner-radius survey (documents only); badge dot (empty badge text) has no example fixture; Flutter
    Rive footer loading frame not captured.

#### 5.6.4 iOS undecided questions

- Bow END black bars: "accept" is an advisor recommendation, not an owner decision (override word `也裁`).
- Merge order of #35, #37, #38, #39 into #31; no written decision. Suggestion: #37 and #38 have no textual conflict;
  #35 needs a port.
- Close or update #36 (owner's call).
- Whether to merge CYLTabBarController #823 / #824 (owner's call), and the ClassifyMenu pull request stack order
  (an advisor recommendation exists, revisable).
- Fold-control placement, "More" control placement and glass strength in the example tag lists were advisor choices
  (delegated, revisable).
- SPM support, a preload API and other upstream scope questions (see [`issue-progress.md`](../../issue-progress.md)).
- Already decided, do not reopen: no physical devices; React Native new architecture out of scope; Rive required;
  iOS 15 minimum; the x86_64 debug-engine guard was removed with owner approval on 2026-11-23
  ([`instructions/harmonyos.md`](../../instructions/harmonyos.md)); older text saying removal needs approval is stale.

#### 5.6.5 How to work on iOS here

- Read `AGENTS.md`, then [`instructions/macos.md`](../../instructions/macos.md) (**simulator rules**: use your own
  simulator by UDID, never `simctl shutdown all`, stop the app and the simulator after every test).
- Run tests: `DESTINATION="platform=iOS Simulator,id=<your UDID>" ruby Tests/run-tests.rb`.
- Before committing documents: `python3 scripts/update-docs-navigation.py` then `--check` (a missed run broke CI three
  times). Files under `docs/todo/` are not scanned by that script.
- Screenshots: `python3 scripts/screenshot_sheet.py` and `python3 scripts/check_screenshots.py`.
- Log every task in [`Task-Log.md`](../../Task-Log.md) before starting it.

## 6. Open owner decisions (nothing may be assumed)

1. **Flat tab bar, unselected icons without an icon colour** keep their original colours on Android (tint spec v2,
   issue #787). iOS flat tab bars tint both states. Options: (a) keep and set unselected colours or template mode in the
   configuration, (b) tint with `unselectedTintColor` in the flat style (changes every coloured icon), (c) only for
   icons detected as one colour. The previous developer recommends (c). The tab bar developer will not change it until
   the owner decides.
2. Rive END black wipe: the advisor's delegated "accept" is suspended for Halloween and Bow END; the owner's override
   word is `也裁` (clip the end phase too). Rule: all affected files means clip, one file means accept; the survey found
   2 of 6, which is neither case (`docs/Task-Log.md`).
3. CYLTabBarController pin: advisor recommends keeping it (`12ed11ff` local, `abb5bc3b` CI); the move trigger is
   `onResourceMissing` landing on its mainline. The temporary CI exception ends when PR #823/#824 merge.
   *Mac correction 2026-11-26:* for **iOS** the pin is now `b0887513` (section 5.6.1); the "keep" advice above no longer
   describes iOS.
4. Corner-radius survey (docs only, queued last, rule arrived second-hand).
5. Low-pull gap: flush layout is an advisor recommendation; `git revert 265e0d74` is the owner's escape.
6. Named Rive inputs for the upstream HarmonyOS and mini program engines (nothing blocked).
7. HarmonyOS NEXT cross-platform packages (AP:908-916, likely stale: Flutter and RN packages now exist).
8. Maven coordinates `io.github.chenyilong:cyltableviewplaceholder(-refresh)(-rive):0.1.0` are decided; publishing needs
   the owner's account and key. Same for npm and pub.dev.
9. The two RAM documents (`docs/Free-RAM.md` here and `docs/Release-RAM.md` in the Search repo): one name to keep.
10. Closed, record only: no physical devices; RN new architecture out of scope; Flutter pure-Dart last row not built;
    Rive required; paging stays in Dart/TS.

## 7. Release scoring (advisor, 2026-11-26)

The advisor's estimates from the docs' own scores minus release gates (not measurements). Non-iOS only; the Mac
developer adds iOS and the whole-project score here.

| Platform | Progress | Release readiness | Main missing points |
| --- | --- | --- | --- |
| Android | 90 | 65 | Tag-list conversion uncommitted and in flight; callout never dismisses (library); not on Maven; depends on unpublished `cylanimateditem` |
| HarmonyOS | 82 | 50 | No CI; many rows "built, not seen"; Rive clip and early hide not seen on screen; END black-rows measurement open |
| Mini program | 84 | 45 | npm publish needs owner login; Search example `registry.js` DevTools failure; tag-list 0.2.0 pending; no phone |
| Flutter | 80 | 50 | Missing example pages; footers not run on device; W5 items |
| React Native | 70 | 40 | Old architecture only; typecheck not run; Android Rive not seen; tag-list native compile unverified |
| **Non-iOS overall** | **~81** | **~50** | |
| iOS | 90 | 55 | No green full iOS CI since `f1e4d08b` (-10); trunk publish blocked by two upstream pods (-10); PR #35 core fixes not integrated (-5); pins on feature-branch SHAs (-5); release not cut (-3); unpinned demos and stale Flutter ref (-2) |
| **Whole project** | **84** | **50** | See "Whole-project missing points" below |

Release-wide missing points (cost in points out of 100): nothing merged to master, 6 PRs open (-15); no registry publish
anywhere (-15); dependency pins on feature-branch SHAs (-8); CI run 45566803410 had open failures and HarmonyOS has no CI
(-7); device coverage (-5); open owner decisions (rest).

*Mac correction 2026-11-26 on the CI sentence above:* run 45566803410 failed on the old head `62bad2cc`. Later commits
change the failing tests (section 5.6.1), but no CI run has confirmed them yet.

### Whole-project score (advisor, 2026-11-26): progress 84 / 100, release readiness 50 / 100

These are advisor judgements from the project documents and the state of the branches, **not measurements**.
The 50 missing release points (the individual costs are a guide and overlap, so they are not a strict sum):

| Missing point | Cost guide | How to win it back |
| --- | --- | --- |
| Nothing merged to `master` since 2026-11-15; 6 PRs open | -15 | Merge #31 after resolving the other PRs |
| No registry publish (CocoaPods trunk, Maven Central, npm, pub.dev) | -15 | Owner accounts and keys; upstream pods first |
| Upstream `CYLAnimatedItem` and `CYLDeallocBlockExecutor` 1.4.0 not on CocoaPods trunk | part of the publish cost | Publish upstream |
| Dependency pins on feature-branch SHAs (differ by platform) | -8 | Move to released tags |
| CI: iOS runs queued on `macos-26` (runner capacity, not controllable from the code), unconfirmed test fixes, no HarmonyOS CI | -7 | Green run on the head; add HarmonyOS CI |
| PR #35 core fixes not integrated | -3 | Port section 5.6.2 |
| Device and screen coverage ("built, not seen") | -5 | Verify the rows in sections 3 to 5 |
| Open owner decisions and known defects (sections 6 and 8) | remainder | Decide, then fix |

## 8. Bugs

| Bug | Platform | Why it is not fixed | Fix plan and idea | Docs |
| --- | --- | --- | --- | --- |
| Long-press callout never dismisses on tab switch or blank tap | Android (ClassifyMenu library) | Found only in the last capture; the library belongs to another repository | Ask ClassifyMenu to dismiss the callout on attach/detach and outside touch; recheck on the next pinned SHA | `docs/Task-Log.md` (Android tag-list entry) |
| Dark-mode glass tags unreadable (plate not night-aware) | Android example | Fix written, not committed | Commit `TagMenu.kt` night-aware plate colours; capture dark mode again | `docs/Task-Log.md` |
| Selected tab icon only ~62% opaque | Android (CYLTabBarController) | Fixed at `d19e138e` (platform icons had max alpha 153; SRC_IN keeps source alpha) | Done: alpha scaled by 255/maxAlpha, verified by pixels | `docs/assets/*tabbar-tint-fix*` |
| Merged example tab bar: no icon tint, bar stays light in dark mode | Android example | Configuration facts: no rendering mode or selected colour, no bar background key; the tab bar owner does not change the example | Set the icon rendering mode and colours and a bar background key in the example configuration | `docs/Task-Log.md` |
| Unselected icons keep original colours in the flat style | Android | Owner decision open (section 6, item 1) | Option (c) recommended | CYLTabBarController `Tab-Item-Colors.md` |
| Rive Bow black at low pull input (header black up to input ~30) | Android (and iOS) | The black is drawn by the Bow file | Owner chose B: clip to the drawn height with a per-file table (`riveDrawnTable`); done on Android and HarmonyOS | `docs/Refresh-Library-Parity.md` |
| Black band while the header collapses after finish | Android | The Rive surface stays 2-3 frames while the slot resizes | Early hide 500 ms before the hold ends (`29e42572`); the last 500 ms of the hold shows the white page | `docs/Task-Log.md` |
| Pull start: Bow shows 1-27 black rows for 1-4 frames | Android | Drawn art, not the surface | Look at the Bow table ramping faster than the art's band grows | `docs/Task-Log.md` |
| End animation holds the full timeout | Android | The layout has one fixed delay; Bow never reports a stop | Not stated | `docs/Task-Log.md` |
| END black wipe at refresh end (Bow, Halloween) | iOS and Android | Owner decision open (section 6, item 2) | Clip the end phase (`也裁`) or accept; investigate if the library causes it | `docs/Task-Log.md` |
| Classic header clipped when held | Android Flutter | Fixed for move mode, front/behind in `46040d51`; no before/after pair for one case | Re-capture a held pull | `docs/Task-Log.md` |
| PAG ring draws only its grey track | Android emulator | Emulator ANGLE ("called unimplemented OpenGL ES API") | A real device must confirm | `docs/Android-Port.md:510` |
| Plus page Success state shows no icon | Android | Status not confirmed | Re-run the 2026-11-21 scenario | `docs/Android-Port.md:1022` |
| `:placeholder` fails to compile on newest CYLTabBarController `eff4fbc7` (`drivesAnimationPlayback` unresolved) | Android CI | Branches diverged; a shim would weaken the core API | Merge `82b85e064` into `feat/cross-platform-components` or keep the pin | `docs/Task-Log.md` |
| Feed tab footer showed a frozen spinner and no "No more data" | HarmonyOS | Spinner fixed in `6bcb2867`; "No more data" never seen | Re-check at 30 rows | `docs/Task-Log.md` |
| `laysTheBallPulseBallsOut` float comparison | HarmonyOS | Fixed with 1e-9 tolerance | Done | `docs/Task-Log.md` |
| HUD page crash, GIF detail empty, emulator crash on `.riv`, title cut | HarmonyOS | Old status; table says 16/16 confirmed | Verify and delete stale lines | `docs/HarmonyOS.md:99,114,210` |
| Search example DevTools: `registry.js is not defined` | Mini program | Vendored module, cause open | Check the vendored copy of `cyl-dealloc-block-executor` | `docs/Refresh-Library-Parity.md:588` |
| DevTools refuses `touristappid`; CLI fails on 8.3 short paths or BOM | Mini program | Tool limits | Real AppID in `project.private.config.json` | `docs/WeChat-MiniProgram.md:180,314` |
| Rive view blank for ~2 s of the pull (iOS RN and Flutter) | React Native / Flutter iOS | Cause not proven; the test target has no RiveRuntime | Try `isOpaque = false` on the Rive view and its `CAMetalLayer` | `docs/Refresh-Library-Parity.md:476` |
| `typecheck` shows 3 `react-native-cyltabbar` errors | React Native | Optional peer not installed | Install the peer or type-stub it | `docs/Task-Log.md` |
| Tracked Gradle 8.10.2 cannot evaluate the repo (`failOnNoDiscoveredTests`) | Android | The wrapper's Gradle 9.9.2 is used | Always use `./gradlew` | `docs/Task-Log.md` |
| Flutter `message` of a single placeholder not accepted | Flutter Android | Not stated | Not stated | `docs/Refresh-Library-Parity.md:405` |

### iOS bugs and further rows added by the Mac developer

| Bug | Platform | Why it is not fixed | Fix plan and idea | Docs |
| --- | --- | --- | --- | --- |
| PR #35 fixes missing on the integration branch (load-more footer shown under the empty placeholder; pinned section header with a back footer #1627 / #1507; #1568; #1146; #862). Footer defect inferred from code, not reproduced | iOS and others | PR #35 is unmerged and conflicts | Port the commits in section 5.6.2 | [Task-Log](../../Task-Log.md), [issue-progress](../../issue-progress.md), PR #35 |
| Example-SwiftUI installs no refresh control on iOS 27 (SwiftUIIntrospect 26.0.0 has no iOS 27 selector) | iOS example | Fix only on #35 (`a169386c`) and #36 (`05c7f126`) | Port one, run its UI tests on iOS 27 | [issue-progress](../../issue-progress.md) |
| "Success" still image is the info symbol | iOS | Fix only on #35 (`4236e998`) | Port | [Task-Log](../../Task-Log.md) |
| JavaScript sets `refreshing` true then false within 0.25 s: the pending block still reports `onRefresh` / `onLoadMore` (one-shot flags `_refreshAskedByJS`, `_loadAskedByJS` in `CYLRefreshContainerView`). Self-score 90 | React Native (iOS wrapper) | Rare; found while fixing CI; not yet done | Suggestion: a token per request instead of a one-shot flag, with a failing-first test | [Task-Log](../../Task-Log.md) |
| Rive "stop ends the hold early" never seen; Bow relies on the 1.5 s timeout; the stop callback link is untested | iOS | Needs RiveRuntime and a real file; a video could not tell it from the timeout | Test hook or core test with a real file | [Refresh-Library-Parity](../../Refresh-Library-Parity.md) |
| Bow END black bars (about the last 0.5 s of the hold) | iOS | Accepted by the advisor, revisable (drawn by the file) | Shorter finish timeout or early hide as on Android, if the owner says `也裁` | [Refresh-Library-Parity](../../Refresh-Library-Parity.md) |
| Rive art squeezed with black bands during the 0.4 s retract inside the open slot (state after `ba7ea2d3` unverified) | Flutter on iOS | Reason not recorded after the Halloween fix | Suggestion: default Dart `finishDuration` to the finish timeout | [Task-Log](../../Task-Log.md) |
| Material header circle may be cut at the bottom on a deep pull (a later fix `126d439b`; remaining case unverified); Bezier circle and Delivery deep pull not captured | iOS | Listed as a known limit | Capture a deep pull | [Task-Log](../../Task-Log.md) |
| Missing-resource bar does not check bare relative names | iOS | By design (an app's factory may take any string) | None | [Task-Log](../../Task-Log.md) |
| `CYLPlaceholderView.restartAnimation()` does not call `super`, so the restart token never grows (2026-11-23 audit; current state unverified) | iOS | Calling `super` would bypass Reduce Motion | Needs an upstream hook | [Task-Log](../../Task-Log.md) |
| Three item properties lost `@objc` when the core adopted the engine's versions (`999049e7`) | iOS | No Objective-C caller exists | Closed by the migration note | [Swift-Migration](../../Swift-Migration.md) |
| ClassifyMenu header fold-control defects at `c5c3a2d7` (no "Less", control on non-foldable sections, huge at accessibility text sizes); fixed upstream: unverified | iOS example / library | Upstream library; examples now use the tail control | Recheck on the pinned commit | [Task-Log](../../Task-Log.md) |
| #1630 sporadic KVO removal crash (score 75) | iOS | No reproduction steps | Ask for the reporter's project | [issue-progress](../../issue-progress.md) |
| Largest Dynamic Type: placeholder does not scroll; right-to-left unsupported; VoiceOver / Switch Control never walked | iOS | Needs a device or work not done; the owner later ruled out physical devices | Scrollable stack; accessibility audit UI test | [Placeholder-Scenarios](../../Placeholder-Scenarios.md) |
| FIXME in `CYLRefreshVectorPathsParser.swift:145`, HACK in `CYLRefreshTaurusHeader.swift:285` | iOS | Reason not recorded | Not stated | source |
| No real iOS 15 runtime ever tested | iOS CI | The runtime download fails on `macos-26`; the local Mac cannot run iOS 15 | A macOS 14 or older host | [CI-CD](../../CI-CD.md), [Task-Log](../../Task-Log.md) |
| Test timing on slow runners (fixed-wait family; accessibility badge test failed twice, root cause unverified; one 65 s header test) | iOS CI | Loaded runner; most waits now wait on the condition | Rerun once; raise caps if it repeats | [CI-CD](../../CI-CD.md) |
| GitHub #16 (placeholder covers header / section), #8 (covers refresh footer), #11 (why table view), #10 (linker error): scored 100 but still open. PR #20 merged into a non-default branch, so auto-close did not fire (inference). #16 default stays full screen; #8 changed behaviour; #10 original error not reproduced | iOS | Nobody closed them | Owner closes them | [issue-progress](../../issue-progress.md) |
| Upstream MJRefresh issues partly handled, below 100: #1630 75, #1593 45, #1589 90, #1585 40, #1587 75, #1586 90, #1575 50, #1563 50, #1523 70, #1506 25, #1483 90, #1481 85, #1430 95, #1317 80, #1041 80, #1623 90, #1 10 | iOS | Mostly needs the reporter's data, a device or an old runtime | Per-row notes in the table | [issue-progress](../../issue-progress.md) |
| 31 upstream issues listed as "not investigated" on this branch (#1627 #1625 #1624 #1615 #1614 #1613 #1607 #1600 #1598 #1597 #1595 #1592 #1591 #1590 #1585 #1583 #1582 #1572 #1571 #1570 #1568 #1564 #1540 #1535 #1507 #1238 #1146 #1067 #1029 #920 #862; the same document also scores #1585) | iOS | Their investigation is only on PR #35 | Port the PR #35 documents and fixes | [issue-progress](../../issue-progress.md) |
| `CYLAnimatedItem` not on CocoaPods trunk, so this pod cannot be pushed; Carthage cannot bootstrap CYLTabBarController for one example (script workaround); `libpag` has no licence file (lint with `--allow-warnings`) | iOS / upstream | Upstream | Upstream requests; `scripts/cyltabbarcontroller-xcframework.sh` | [Animated-Item-Migration](../../Animated-Item-Migration.md), [CI-CD](../../CI-CD.md) |
| Newest engine commit by time is not a superset across branches (broke Android CI once; Android CI still follows the newest commit; the test comment to restore waits for CYLTabBarController #824) | Android CI | Upstream branches not merged | Merge #824 or pin the Android CI | [Task-Log](../../Task-Log.md) |
| Rive refresh started from code leaves its area undrawn; Halloween closes the emulator (emulator graphics) | Android emulator | Needs a real device, which the owner ruled out | Not stated | [Android-Port](../../Android-Port.md) |
| 5 CYLRefreshLayout issues unfixed: #1081, #1234, #1315, #1521, #1566 | Android | Need a device or a specific component | Not stated | [Android-Port](../../Android-Port.md) |
| 3 API rows missing (rebound animation options, horizontal drag, drag callback); two code paths bypass `CYLPlaceholderViewModel`; Rive speed not applicable; GIF fallback has no speed or repeat; the `animation` configuration key is not read (state of the last one unverified) | HarmonyOS | Gesture / animator work needs a device; the Rive library has no speed API | See section 5.2 | [HarmonyOS](../../HarmonyOS.md) |
| Footer second floor tested with Robolectric only; library animated icon does not play in the example (no Lottie library) | React Native Android | Robolectric cannot load Rive / Lottie natives | Run on an emulator | [Task-Log](../../Task-Log.md) |

Source for most rows: `docs/Refresh-Library-Parity.md`, `docs/Task-Log.md`, `docs/Android-Port.md`,
`docs/HarmonyOS.md`, `docs/WeChat-MiniProgram.md` (line numbers were correct on 2026-11-26 and move as files grow).
Some older HarmonyOS and mini program statuses conflict with later tables: treat "probably resolved" lines as "verify".

## Appendix A. Every other open TODO found in the documents (Mac sweep, 2026-11-26)

Method and limit: [`Task-Log.md`](../../Task-Log.md) is about 900 KB and was swept by headings and keywords, **not read
line by line**. Some headings still say TODO although a later entry closed the work. Check before you act. Entries are
identified by topic; search the document for it (line numbers move).

### A.1 Task-Log, last two weeks, no closing entry found

- CI fix for run 45566803410 (in progress when written).
- React Native one-shot flag (section 8).
- All-platform "scores to 100" entry: Windows W4 and W5, Mac iOS row (green CI, `pod lib lint`, Carthage job, iOS 15
  runtime job, SwiftUI UI tests, early Rive end), advisor re-score after CI, corner-radius survey.
- Liquid Glass tag lists, unchecked items: Refresh-icons screen capture, selected colour, callout under glass, iOS 26
  fallback (partly covered later).
- Missing-resource bar: "+N more" on a device, rotation, replace the reflection hook with direct calls.
- Re-add the `drivesAnimationPlayback = false` test comment after CYLTabBarController #824
  (`CYLPlaceholderViewTest.kt:113`).
- Remove the exact-pin step in `ios.yml` after #823 / #824.
- `animationLoops` / speed / restart in the Flutter and React Native wrappers with unit tests (partly superseded:
  unverified).
- Flutter Dart Rive finish default (finish duration = timeout): unverified whether done.
- HarmonyOS demo pages for rows tested only on the host.
- Rive black-band option B: code done on iOS, Android, HarmonyOS; device checks missing.

### A.2 Older Task-Log items with no closure found (verify first)

- 2026-11-23 hand-off list: most closed later; a few rows keep TODO text.
- SVGA twins of the Rive scenes need new artwork; the upstream iOS SVGA player has no progress or loop control.
- Playback loop switch: simulator check and screenshot.
- Publish `cyl-tabbar-miniprogram`; Maven Central publication; CocoaPods trunk push (blocked).
- Convert about 20 fixed `runUntilDate` waits (owner decision).
- Merge the two language settings and spinner behaviour (changes behaviour; owner decides).
- New public comments not spot-checked in Quick Help; some API-map data columns are English only.
- README Swift samples not compiled, markdownlint not run, published coordinates unverified.

### A.3 Other documents

| Document | Open items |
| --- | --- |
| [Android-Port](../../Android-Port.md) | HarmonyOS NEXT section waiting for a decision (probably overtaken, unverified); porting step 6 of the iOS examples; Maven publication |
| [WeChat-MiniProgram](../../WeChat-MiniProgram.md) | Five TODO sections scored 95, 95, 85, 85, 90 |
| [Animated-Item-Migration](../../Animated-Item-Migration.md) (dated 2026-11-17, do not quote its score as current) | green CI and README screenshots; arm64 PAG / Rive; screen reader; screenshots; repeat-count gaps; upstream requests; other repositories must add `:cylanimateditem` |
| [issue-progress](../../issue-progress.md), non-issue TODO rows | Swift examples/core 90; localisation macros 95; accessibility 70; animated icons 90; MJRefresh port 80; HUD 90; status bar 70; public API comments 95; README images 99; scenario placeholders 85; bilingual docs 90; translations need native review; CI screenshots 95 |
| [Placeholder-Scenarios](../../Placeholder-Scenarios.md) | known limits; ja / ko / ru / uk translations not reviewed; animations need a manual look; a language change needs view recreation |
| [Placeholder-HUD](../../Placeholder-HUD.md) | PAG / Rive loading inside the box, VoiceOver, largest text not verified |
| [Status-Bar](../../Status-Bar.md) | old "not verified" notes, partly superseded; engine hook |
| [CI-CD](../../CI-CD.md), [commit-readiness-2026-11-09](../../commit-readiness-2026-11-09.md), [flatdesign-item-comparison](../../flatdesign-item-comparison.md) | Carthage and iOS 15 minimum rows at 95; stale iOS 12 text |
| [Swift-Guide](../../Swift-Guide.md) | some entries marked "pending CI" |
| [Example-Animation-Playback](../../Example-Animation-Playback.md) | header still TODO; HarmonyOS Rive speed open |
| [Refresh-Styles](../../Refresh-Styles.md), [Refresh-Icon-Animation](../../Refresh-Icon-Animation.md) | gesture tests cannot replace a frame-by-frame check; one animation file is drawn for a dark background |
| Source comments | Flutter example `build.gradle.kts` (application ID, release signing); HarmonyOS `CYLRefreshComponent.ets` horizontal pan; two iOS FIXME / HACK (section 8); pin-header TODO in three example files |
| CrossPlatform READMEs | some "written, not built" notes may be stale |

### A.4 Related repositories (they block or affect this one)

- CYLTabBarController open PRs #788, #813, #823 (draft until `CYLDeallocBlockExecutor` 1.4.0), #824 (contains our iOS
  pin; merging is the owner's decision).
- CollectionViewClassifyMenu open PRs #31 to #39 when checked (stacked; some conflicting). PR #39 of this repository
  needs ClassifyMenu #37 first or a moved pin.


## Appendix B. Hand-over pickup (Windows, 2026-11-27)

- **Section 1 item 3 / section 4 row 1 is no longer local-only.** The Android example tag-list conversion was found
  uncommitted in the Windows checkout, aligned with the current `docs/instructions/examples.md` (library section cards,
  `headerMaxLines` 2, static template icon colour through the item style) and committed as `3d320a13` on PR #31, with
  an emulator sheet. Score 90: a real 3-line title is not captured; the callout dismissal defect is ClassifyMenu's.
  Details and the "kept: library demo" list: [`Task-Log.md`](../../Task-Log.md), entry "Android example: menu lists
  become CollectionViewClassifyMenu tag lists".
- **Section 8 row "Dark-mode glass tags unreadable":** the night-aware gradient is committed in `3d320a13` and captured
  in dark mode (readable).
- **Pending:** the Mac session is merging PR #35 into #31; after its push the Windows side builds and tests the three
  non-iOS commits it brings (`4aba938c` Android, `83eec946` mini program, `ac9f3e94` HarmonyOS).

## Appendix C. Hand-over pickup (Mac, 2026-11-27)

- **iOS priority 1 / section 5.6.2 done: PR #35 is merged into #31** (`43031e59`, pushed with `7d8d0dd4`). The engine pin
  stays `b0887513` (`0d43bc9f` not taken). #35's Swift rename is applied to the code #31 added since the merge base; the
  generated Objective-C selectors keep `cyl_` (`docs/Swift-Naming.md`, last section). `ruby Tests/run-tests.rb`: 403 tests,
  0 failures (383 before). PR #35 can be closed as contained once CI is green (owner's call). Section 8 rows "PR #35
  fixes missing", "Success still image is the info symbol", "31 upstream issues not investigated" and the Example-SwiftUI
  iOS 27 row are now on #31. The SwiftUI fix is verified on iOS 27.2: the Example-SwiftUI UI tests pass (4 / 4,
  2026-11-27, `7ae66f8e`).
- **iOS priority 4 / section 8 row "JavaScript sets `refreshing` true then false" done:** the React Native iOS wrapper
  reports onRefresh / onLoadMore only while the control is in `CYLRefreshPhaseRefreshing` and JavaScript did not ask for
  it; two failing-first tests.
- **Non-iOS commits from #35 that the Windows session must verify on #31:** `4aba938c` (Android), `83eec946` (mini
  program), `ac9f3e94` (HarmonyOS). Asked on 2026-11-27.
- **Still open for iOS:** priority 2 (green macOS CI on the new head), priority 3 (run 45566803410: the local suite is
  green at the new head, CI not yet). (A first note here named the
  Example-Scenarios `Podfile.lock` as stale: that file is not tracked, so it was only a local copy, now refreshed.) Details: [`Task-Log.md`](../../Task-Log.md), entry "2026-11-27
  Hand-over iOS priority 1 … (DONE)".
