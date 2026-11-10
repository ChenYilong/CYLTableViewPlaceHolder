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
  # The core bundle: <language>.lproj/Localizable.strings (placeholder, scenario and component texts) and
  # CYLRefresh.strings, the images, and Animations/ (32 scenario animations: Lottie, PAG, Rive, GIF, with
  # NOTICE.animations and the license of each source repository).
  s.resources     = 'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.bundle', 'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/LICENSE.placeholder-third-party', 'CYLTableViewPlaceHolder/CYLRefresh/PrivacyInfo.xcprivacy', 'CYLTableViewPlaceHolder/CYLRefresh/LICENSE.third-party'
  s.requires_arc = true
  s.frameworks = 'ImageIO', 'QuartzCore'
  s.swift_version = '5.0'
  s.default_subspecs = 'Core'
  s.static_framework = true

  # Placeholder view, automatic table/collection integration and CYLRefresh. GIF files play through Core's
  # built-in ImageIO decoder when the GIF subspec is not installed.
  s.subspec 'Core' do |core|
    core.source_files = 'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/**/*.{h,m}',
                        'CYLTableViewPlaceHolder/CYLRefresh/**/*.{h,m}'
    # The interface to the CYLPlaceholderItemAnimation subspec, internal, not public API. Core does not depend on
    # that subspec: the engine installs itself at load time (as `CYLTabBarItemAnimationService` in CYLTabBarController).
    core.private_header_files = 'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderItemAnimationService.h'
  end

  # The animation shared by every animation library, pulled in only by a library's subspec (Lottie, PAG...), organized
  # like CYLTabBarController's `CYLTabBarItemAnimation`: `CYLPlaceholderItemAnimator` (file matching + view factory),
  # `CYLPlaceholderItemAnimationPlayer`, `CYLPlaceholderItemAnimatorRegistry`, `CYLPlaceholderItemAnimationFactory`, and
  # the short path `CYLPlaceholderItemAnimationPlayableView` + `CYLPlaceholderItemViewAnimator`. Each library's animator
  # lives in `CYLPlaceholderAnimation/<Library>/` and registers itself.
  s.subspec 'CYLPlaceholderItemAnimation' do |animation|
    animation.dependency 'CYLTableViewPlaceHolder/Core'
    animation.source_files = 'CYLTableViewPlaceHolder/CYLPlaceholderAnimation/*.{h,m}'
    animation.public_header_files = 'CYLTableViewPlaceHolder/CYLPlaceholderAnimation/CYLPlaceholderItemAnimator.h',
                                    'CYLTableViewPlaceHolder/CYLPlaceholderAnimation/CYLPlaceholderItemAnimationPlayer.h',
                                    'CYLTableViewPlaceHolder/CYLPlaceholderAnimation/CYLPlaceholderItemAnimatorRegistry.h',
                                    'CYLTableViewPlaceHolder/CYLPlaceholderAnimation/CYLPlaceholderItemAnimationFactory.h',
                                    'CYLTableViewPlaceHolder/CYLPlaceholderAnimation/CYLPlaceholderItemAnimationPlayableView.h',
                                    'CYLTableViewPlaceHolder/CYLPlaceholderAnimation/CYLPlaceholderItemViewAnimator.h',
                                    'CYLTableViewPlaceHolder/CYLPlaceholderAnimation/CYLPlaceholderAnimationView.h'
    animation.private_header_files = 'CYLTableViewPlaceHolder/CYLPlaceholderAnimation/CYLPlaceholderItemAnimationEngine.h'
    animation.frameworks = 'UIKit'
  end

  # Former name of the shared animation subspec, kept so existing Podfiles keep working.
  s.subspec 'Animation' do |legacy|
    legacy.dependency 'CYLTableViewPlaceHolder/CYLPlaceholderItemAnimation'
  end

  # Lottie uses the Swift version of lottie-ios only (no Objective-C Lottie 2.x flavor).
  s.subspec 'Lottie' do |lottie|
    lottie.dependency 'CYLTableViewPlaceHolder/LottieSwift'
    lottie.ios.deployment_target = '13.0' # depends on LottieSwift
  end

  s.subspec 'LottieSwift' do |lottieswift|
    # The Swift bridge, and the Lottie animator.
    lottieswift.source_files = 'CYLTableViewPlaceHolder/**/LottieSwift/*.{h,m,swift}', 'CYLTableViewPlaceHolder/CYLPlaceholderAnimation/Lottie/*.{h,m}'
    lottieswift.private_header_files = 'CYLTableViewPlaceHolder/CYLPlaceholderAnimation/Lottie/*.h'
    # 4.5.1 adds `removeValueProvider(for:)`, used to restore colors when leaving Dark Mode.
    lottieswift.dependency 'lottie-ios', '>= 4.5.1'
    # lottie-ios 4.5.1 requires iOS 13.
    lottieswift.ios.deployment_target = '13.0'
    lottieswift.dependency 'CYLTableViewPlaceHolder/Core'
    lottieswift.dependency 'CYLTableViewPlaceHolder/CYLPlaceholderItemAnimation'
  end

  # PAG animations (Tencent libpag), a binary pod; the animator finds it with `__has_include(<libpag/PAGView.h>)`.
  s.subspec 'PAG' do |pag|
    pag.dependency 'CYLTableViewPlaceHolder/Core'
    pag.dependency 'CYLTableViewPlaceHolder/CYLPlaceholderItemAnimation'
    pag.source_files = 'CYLTableViewPlaceHolder/CYLPlaceholderAnimation/PAG/*.{h,m}'
    pag.public_header_files = 'CYLTableViewPlaceHolder/CYLPlaceholderAnimation/PAG/*.h'
    pag.dependency 'libpag', '>= 4.0'
  end

  # PAG Enterprise (`libpag-enterprise`). It ships the same `libpag.xcframework`, so use either `PAG` or
  # `PAGEnterprise`, not both.
  s.subspec 'PAGEnterprise' do |pagenterprise|
    pagenterprise.dependency 'CYLTableViewPlaceHolder/Core'
    pagenterprise.dependency 'CYLTableViewPlaceHolder/CYLPlaceholderItemAnimation'
    pagenterprise.source_files = 'CYLTableViewPlaceHolder/CYLPlaceholderAnimation/PAG/*.{h,m}'
    pagenterprise.public_header_files = 'CYLTableViewPlaceHolder/CYLPlaceholderAnimation/PAG/*.h'
    pagenterprise.dependency 'libpag-enterprise', '>= 4.0'
    # libpag-enterprise 4.4.x-4.5.98: the module's umbrella header imports a header the framework does not ship, so a
    # modular import fails. The PAG animator imports only `PAGView.h`, so its file is compiled without modules.
    pagenterprise.compiler_flags = '-fno-modules'
  end

  # Rive animations (`RiveRuntime`): the Swift views (RiveSwift/) adopt the playable view protocols, and the
  # animator only registers a ready-made `CYLPlaceholderItemViewAnimator` for ".riv" files.
  s.subspec 'Rive' do |rive|
    rive.dependency 'CYLTableViewPlaceHolder/Core'
    rive.dependency 'CYLTableViewPlaceHolder/CYLPlaceholderItemAnimation'
    rive.source_files = 'CYLTableViewPlaceHolder/CYLPlaceholderAnimation/Rive/*.{h,m}', 'CYLTableViewPlaceHolder/RiveSwift/*.swift'
    rive.public_header_files = 'CYLTableViewPlaceHolder/CYLPlaceholderAnimation/Rive/*.h'
    rive.dependency 'RiveRuntime', '~> 6.29'
    # RiveRuntime requires iOS 14.
    rive.ios.deployment_target = '14.0'
  end

  # GIF placeholder animations that play once through the registry, like Lottie, PAG and Rive. No third-party
  # library: ImageIO decodes it.
  s.subspec 'GIF' do |gif|
    gif.dependency 'CYLTableViewPlaceHolder/Core'
    gif.dependency 'CYLTableViewPlaceHolder/CYLPlaceholderItemAnimation'
    gif.source_files = 'CYLTableViewPlaceHolder/CYLPlaceholderAnimation/GIF/*.{h,m}'
    gif.public_header_files = 'CYLTableViewPlaceHolder/CYLPlaceholderAnimation/GIF/*.h'
    gif.frameworks = 'ImageIO', 'QuartzCore'
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
