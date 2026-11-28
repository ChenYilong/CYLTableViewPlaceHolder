# Folder instructions

This folder contains regression tests for the placeholder library. It inherits
the vault's root `instructions.md`.

## Tag: macOS-only scenario (`macos`)

### Language: Swift tests and one Objective-C smoke test (owner's decision, 2026-11-20)

- The tests are Swift (`docs/Swift-Migration.md`, step 13). The core runner (`run-tests.rb`) compiles every
  `Tests/*.swift` and `Tests/*.m` into the library's own module (`CYLTableViewPlaceHolder`), so a test reaches internal
  members directly, without `@testable` or selectors. The animation tests (`run-animation-tests.rb`) import the pods'
  module and run with static and dynamic linkage; the accessibility UI tests and their host app
  (`run-accessibility-tests.rb`) are Swift too.
- Keep helper types and functions of a test file `private`: every test file shares one module with the library.
- The only Objective-C file is `CYLObjectiveCAPISmokeTests.m`: it calls the public Objective-C API surface (the
  initializers, factories, categories, variadic shims, exported constants, error domains and codes, and the
  dictionary entry points given a wrong type) so CI proves Objective-C callers still compile and work. Keep it small;
  add a line there when a public Objective-C entry point is added. Checks only Objective-C can express (nil for a
  nonnull parameter, a wrong type for an `id` parameter) belong there.
- When translating a test, keep its name and every assertion; never weaken an expectation to make a test pass.
