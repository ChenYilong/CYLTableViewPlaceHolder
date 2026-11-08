# Agent rules for CYLTableViewPlaceHolder

This repository contains an Objective-C iOS table-view placeholder library,
the integrated `CYLRefresh` component, and an example application. Read
`instructions.md` and the relevant project skill before changing code.

## Source of truth

- Public headers under `CYLTableViewPlaceHolder/` define the current API.
- `README.md` documents integration and usage; `docs/issue-progress.md` records
  issue history and known limits. If they disagree, verify the code and update
  the affected documentation.
- Use the project skills in `.agents/skills/`: `cyl-api-map` for API locations,
  `cyl-xcode-compat` for project settings, `cyl-verify` for verification, and
  `cyl-docs` for documentation changes.

## Naming and compatibility

- Follow the English naming rules in `instructions.md`: new project-owned
  classes use `CYL`; UIKit category files use `+CYL`; category methods and
  properties use `cyl_`, except required system overrides.
- Do not rename existing public symbols, serialized keys, or resources without
  assessing compatibility and obtaining approval for breaking changes.
- Preserve third-party copyright, license text, and original attribution. Do
  not replace an author's name with the project author's name.
- The minimum supported iOS version is 12.0. Preserve it in the podspec,
  Podfile, and Xcode target unless a change is explicitly approved. Guard APIs
  unavailable on supported systems.
- Preserve the Xcode project format: `objectVersion = 46`,
  `compatibilityVersion = "Xcode 3.2"`, explicit file references, and a shared
  scheme. Do not copy device identifiers or signing credentials from another
  machine.

## Project and verification

- The example compiles local refresh sources directly and does not require the
  former external refresh Pod. Keep the source files, refresh bundle, privacy
  manifest, and third-party license in both the project and podspec.
- Run `ruby Tests/run-tests.rb` for relevant simulator tests. Use `DESTINATION`
  to select an installed simulator. Build the example and validate the
  podspec when their integration changes; see `cyl-verify`.
- Xcode 27's simulator SDK requires a deployment target of at least 15.0 during
  builds. Override the build target for that toolchain instead of changing the
  library's iOS 12.0 minimum.
- Update relevant documentation and skills with user-visible changes. Explain
  what could not be verified; do not claim a visual behavior from compilation.

## Git

- Never commit AppleDouble files named `._*`. Follow the vault's cleanup rule
  before Git commands and check staged paths before committing.
- Do not overwrite another person's changes or rewrite pushed history.
- Follow the current task's instructions for commits, branches, and pull
  requests; do not assume permission to create or merge a pull request.
