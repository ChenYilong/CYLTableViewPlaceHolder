# Folder instructions

Aggregated placeholder demo: a CYLTabBarController tab bar with a plus button, modeled on CYLTabBarController's
Objective-C demo. The first tab lists placeholder scenarios; each row pushes one placeholder. The second tab plays every
animation bundled in `CYLTableViewPlaceHolder.bundle/Animations` (Lottie, PAG, Rive, GIF).

- Run `pod install` here, then open `Example-Scenarios.xcworkspace`. The Podfile uses the local library
  (`:path => '../..'`) with the LottieSwift, PAG, Rive and GIF subspecs, plus CYLTabBarController 1.99.x.
- Scenarios live in `Sources/CYLScenario.m`; add a row there to add a scenario.
- The app icon and launch screen come from CYLTabBarController (MIT); keep `LICENSE.third-party`. Inherit the
  repository instructions.
