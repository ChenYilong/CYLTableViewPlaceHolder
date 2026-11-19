# Changelog / 更新日志

## Unreleased (next major version) / 未发布（下一个大版本）

### Breaking changes / 破坏性变更

- The minimum iOS version is now **iOS 15.0** (was 12.0): the podspec says `s.platform = :ios, '15.0'`, the framework
  project's `IPHONEOS_DEPLOYMENT_TARGET` is 15.0, and the Lottie, LottieSwift and Rive subspecs no longer set a lower
  target. Apps that still support iOS 12-14 must stay on the previous release. The reason: the CYLAnimatedItem dependency
  needs iOS 13+, and the Xcode 26/27 SDKs cannot build below iOS 15. (Owner's decision, 2026-11-20.)
- 最低 iOS 版本现为 **iOS 15.0**（原为 12.0）：podspec 为 `s.platform = :ios, '15.0'`，framework 工程的
  `IPHONEOS_DEPLOYMENT_TARGET` 为 15.0，Lottie、LottieSwift、Rive 子 spec 不再设置更低的目标版本。仍需支持 iOS 12-14 的
  App 请停留在上一个版本。原因：依赖 CYLAnimatedItem 需要 iOS 13 及以上，Xcode 26/27 的 SDK 也无法编译 iOS 15 以下。（所有者决定，2026-11-20。）
- The Swift migration of the core (see `docs/Swift-Migration.md`): an app can no longer subclass the CYLRefresh classes in
  Objective-C. / 核心迁移到 Swift（见 `docs/Swift-Migration.md`）：App 不能再用 Objective-C 继承 CYLRefresh 的类。

### Internal / 内部

- Removed the unreachable `#available(iOS 13...)` and `@available(iOS 13/14...)` branches and their fallbacks.
  / 删除了不再可达的 `#available(iOS 13...)`、`@available(iOS 13/14...)` 分支及其回退代码。
- CI tests iOS 15 (`iOS 15 deployment build`, `iOS 15 runtime`) instead of iOS 12. / CI 改为测试 iOS 15。
