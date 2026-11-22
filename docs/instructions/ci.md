# CI/CD scenario (`ci`)

Full text of the `ci` rules (GitHub workflows and CI screenshots), moved verbatim from `instructions.md` and `AGENTS.md` on 2026-11-22 (owner's
rule: instruction files by tag, at most 200 lines each). Summaries: [instructions.md](../../instructions.md) and
[AGENTS.md](../../AGENTS.md), heading "Tag: CI/CD scenario". English only.

## CI/CD

The default runner environment for iOS on GitHub CI/CD is **macOS 26**
(`runs-on: ${{ vars.MACOS_RUNNER || 'macos-26' }}`, the stable image with its
default Xcode 26.x); Linux-only jobs (docs, localization, shellcheck) stay on
`ubuntu-latest`.

- Before changing or diagnosing a workflow, always read CYLTabBarController's
  current
  [`.github/workflows/ios.yml`](https://github.com/ChenYilong/CYLTabBarController/blob/master/.github/workflows/ios.yml)
  first, to confirm the runner image and Xcode it uses, and follow it when it
  differs from this repository's `ios.yml`. Last checked: master `4209e37`
  (2026-11-10) uses `macos-26`, overridable with the repository variable
  `MACOS_RUNNER`.
- Jobs that need an older toolchain on purpose keep their own runner (for
  example a build that needs an Xcode other than the runner's newest); say why in a
  comment next to `runs-on`.
- **Local runs ignore this restriction.** A local run does not go through
  GitHub CI/CD: it uses the developer's own Mac directly, where the simulator
  and Xcode can be started for testing. Assume that Mac runs **macOS 27 with
  Xcode 27**, so builds there need the deployment-target override for Xcode 27
  (at least iOS 15.0 for the build; CI builds and tests iOS 15.0 since 2026-11-20, the library's minimum is 15.0 too since 2026-11-20). Run
  the same scripts as CI (`scripts/`, `ruby Tests/run-tests.rb` with
  `DESTINATION`), choosing an installed simulator with
  `xcrun simctl list devices available`.
- Details of every job: `docs/CI-CD.md`.

## CI example screenshots

Every CI run that builds code must provide a screenshot of each example app
running. The `Demo` jobs in `.github/workflows/ios.yml` run
`scripts/ci-build-example.sh <folder>`, which builds the example, installs and
launches it on an iPhone simulator, and saves `build/screenshots/<scheme>.png`.
The workflow uploads it as the artifact `example-screenshot-<folder>` (`.`
becomes `Example`, `/` becomes `-`), and the job summary shows a Screenshot
column. The `Example screenshots` job then shows all of them inline in its
summary and in one pull request comment, from the `ci-screenshots` branch
(`docs/CI-CD.md`). A build that produces no screenshot fails the job. Runs that change only
documentation skip the macOS builds and need no screenshot.

- When reporting CI results for a change that triggers a build, give the run
  link, the screenshot artifact names for every example, and the pull
  request's screenshot comment when there is one. Describe a
  screenshot only if you have actually viewed it; a launch screenshot shows the
  first screen and does not verify interactions or animations.
- If a screenshot cannot be produced, first change the CI script or workflow
  so that it is produced. Only if that still fails, state the concrete reason
  (for example, the runner has no iOS simulator runtime, or the app crashes on
  launch, with the relevant log lines) and record it under Known limits in
  `docs/CI-CD.md`.
- On a Mac, `scripts/ci-build-example.sh <folder>` produces the same
  screenshot locally; `SCREENSHOT_DELAY` (seconds, default 8) waits longer for
  the first frame.

## AGENTS.md: Project and verification

- CI/CD (`instructions.md`, "CI/CD"): iOS jobs on GitHub run on macOS 26 by default
  (`vars.MACOS_RUNNER || 'macos-26'`). Always read CYLTabBarController's
  [`.github/workflows/ios.yml`](https://github.com/ChenYilong/CYLTabBarController/blob/master/.github/workflows/ios.yml)
  first to confirm the runner environment. Local runs (the developer's own Mac,
  not GitHub CI/CD, running the simulator and Xcode directly) ignore this and
  assume macOS 27 with Xcode 27.

- Every CI run that builds code must provide a screenshot of each example
  running (artifacts `example-screenshot-*` from the `Demo` jobs, shown inline
  by the `Example screenshots` job and its pull request comment). Link them
  when reporting CI results. If none can be produced, first fix the CI to
  produce it; if that still fails, state the concrete reason. See "CI example
  screenshots" in `instructions.md`.
