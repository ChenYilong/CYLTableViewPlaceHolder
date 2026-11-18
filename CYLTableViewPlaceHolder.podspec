Pod::Spec.new do |s|
  s.name         = "CYLTableViewPlaceHolder"
  s.version      = "1.1.0"
  s.summary      = "When UITableView(iOS) is empty,then it can automaticely make an empty overlay view "
  s.description  = "It can observe UITableView(iOS) being empty,then automaticely make an empty overlay view as a place holder. CYLTableViewPlaceHolder is iPad and iPhone compatible."
  s.homepage     = "https://github.com/ChenYilong/CYLTableViewPlaceHolder"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "ChenYilong" => "luohanchenyilong@163.com" }
  s.platform     = :ios, '12.0'
  s.source       = { :git => "https://github.com/ChenYilong/CYLTableViewPlaceHolder.git", :tag => s.version.to_s }
  s.requires_arc = true
  # SpriteKit draws the two game headers ported from SmartRefreshControl (BattleCity, HitBlock).
  s.frameworks = 'ImageIO', 'QuartzCore', 'Network', 'SpriteKit'
  s.swift_version = '5.0'
  s.default_subspecs = 'Core'
  s.static_framework = true

  # Placeholder view, automatic table/collection integration, CYLPlaceholderHUD and CYLRefresh. `CYLPlaceholderView` (the
  # packaged icon + title view) is a subclass of `CYLAnimatedItemView` from the `CYLAnimatedItem` pod (CYLTabBarController repository; guide:
  # https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md), so Core depends on `CYLAnimatedItem/Core`: static images, no animation engine. An
  # animation file plays only when the app adds an animation subspec below (since CYLPlaceholderView is Swift, adding
  # `CYLAnimatedItem/<Type>` directly is not enough: see the animation subspecs); without one, the view shows its
  # static image.
  s.subspec 'Core' do |core|
    core.dependency 'CYLAnimatedItem/Core'
    # CYLPlaceholderView is Swift since 2026-11-19 (CYLAnimatedItemView became Swift; Objective-C cannot subclass it), with
    # its Objective-C API unchanged; its keys, enums and badge appearance stay in CYLPlaceholderView.h / .m files.
    core.source_files = 'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/**/*.{h,m,swift}',
                        'CYLTableViewPlaceHolder/CYLPlaceholderHUD/*.{h,m}',
                        'CYLTableViewPlaceHolder/CYLRefresh/**/*.{h,m}'
    # The drawn headers' support code (vector parser, value animator, StoreHouse paths, scenes) is internal.
    core.private_header_files = 'CYLTableViewPlaceHolder/CYLRefresh/Custom/Drawn/Support/*.h'
    # The core bundle: <language>.lproj/Localizable.strings (placeholder, scenario and component texts) and
    # CYLRefresh.strings, the images, and Animations/ (the scenario animations and CYLRefresh icons: Lottie, PAG, Rive,
    # GIF, with NOTICE.animations and the license of each source repository). Declared on Core, which reads them: a
    # root-level `resources` was not installed when a Podfile names subspecs, so every icon fell back to the default.
    core.resources = 'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.bundle',
                     'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/LICENSE.placeholder-third-party',
                     'CYLTableViewPlaceHolder/CYLRefresh/LICENSE.third-party'
    # The privacy manifest in a bundle of its own, as CocoaPods recommends: copied as a plain resource it landed at the
    # app's root and clashed with the app's own PrivacyInfo.xcprivacy ("Multiple commands produce", a React Native app).
    core.resource_bundles = { 'CYLTableViewPlaceHolderPrivacy' => 'CYLTableViewPlaceHolder/CYLRefresh/PrivacyInfo.xcprivacy' }
  end

  # The animation subspecs: each adds the animation engine (`CYLAnimatedItem/Engine`) and one animator through the
  # matching `CYLAnimatedItem/<Type>` subspec. Nothing else changes: `CYLPlaceholderView` sees the engine at compile
  # time (`CYL_ANIMATION_ENGINE_AVAILABLE`) and plays the files of every installed type. Pick one per type.
  # CYLPlaceholderView is Swift, which cannot read the C macro of the engine headers: every animation subspec sets the
  # Swift condition of the same name on this pod's target (`engine_condition`), as `CYLAnimatedItem/Engine` does on its
  # own. An app that adds `CYLAnimatedItem/<Type>` directly, without one of these subspecs, therefore shows static images
  # in CYLPlaceholderView: add the matching subspec of this pod instead.
  engine_condition = { 'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => '$(inherited) CYL_ANIMATION_ENGINE_AVAILABLE' }
  # Lottie uses the Swift version of lottie-ios (iOS 13).
  s.subspec 'Lottie' do |lottie|
    lottie.dependency 'CYLTableViewPlaceHolder/LottieSwift'
    lottie.ios.deployment_target = '13.0'
  end

  s.subspec 'LottieSwift' do |lottieswift|
    lottieswift.dependency 'CYLTableViewPlaceHolder/Core'
    lottieswift.dependency 'CYLAnimatedItem/LottieSwift'
    lottieswift.pod_target_xcconfig = engine_condition
    lottieswift.ios.deployment_target = '13.0'
  end

  # PAG animations (Tencent libpag, a binary pod).
  s.subspec 'PAG' do |pag|
    pag.dependency 'CYLTableViewPlaceHolder/Core'
    pag.dependency 'CYLAnimatedItem/PAG'
    pag.pod_target_xcconfig = engine_condition
  end

  # PAG Enterprise (`libpag-enterprise`). It ships the same `libpag.xcframework`, so use either `PAG` or
  # `PAGEnterprise`, not both.
  s.subspec 'PAGEnterprise' do |pagenterprise|
    pagenterprise.dependency 'CYLTableViewPlaceHolder/Core'
    pagenterprise.dependency 'CYLAnimatedItem/PAGEnterprise'
    pagenterprise.pod_target_xcconfig = engine_condition
  end

  # Rive animations (`RiveRuntime`, iOS 14). The Rive refresh header lives with the other refresh controls in
  # CYLRefresh/Custom/Rive/ and is compiled here, since it needs RiveRuntime.
  s.subspec 'Rive' do |rive|
    rive.dependency 'CYLTableViewPlaceHolder/Core'
    rive.dependency 'CYLAnimatedItem/Rive'
    rive.pod_target_xcconfig = engine_condition
    rive.source_files = 'CYLTableViewPlaceHolder/CYLRefresh/Custom/Rive/*.swift'
    rive.ios.deployment_target = '14.0'
  end

  # SVGA animations (`SVGAPlayerLite`).
  s.subspec 'SVGA' do |svga|
    svga.dependency 'CYLTableViewPlaceHolder/Core'
    svga.dependency 'CYLAnimatedItem/SVGA'
    svga.pod_target_xcconfig = engine_condition
  end

  # GIF animations through the engine (ImageIO, no third-party library). Without it a GIF shows as a static image.
  s.subspec 'GIF' do |gif|
    gif.dependency 'CYLTableViewPlaceHolder/Core'
    gif.dependency 'CYLAnimatedItem/GIF'
    gif.pod_target_xcconfig = engine_condition
  end

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'WARNING_CFLAGS' => [
      '-Werror=undeclared-selector',
      '-Werror=incomplete-implementation',
      # libpag's umbrella header leaves out its C++ headers; third-party module map, not ours to fix.
      '-Wno-incomplete-umbrella'
    ]
  }

end
