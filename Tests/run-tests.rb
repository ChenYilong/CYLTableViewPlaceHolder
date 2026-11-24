#!/usr/bin/env ruby
require 'tmpdir'
require 'xcodeproj'

root = File.expand_path('..', __dir__)
Dir.mktmpdir('cyl-placeholder-tests-') do |dir|
  project = Xcodeproj::Project.new(File.join(dir, 'Tests.xcodeproj'))
  # TEST_DEPLOYMENT_TARGET builds the suite at another deployment target: 15.0 (the lowest Xcode 26/27 allow; CI:
  # .github/workflows/ios15-runtime.yml on an iOS 15 simulator). iOS 12 is no longer buildable (CYLAnimatedItem needs iOS 13+).
  deployment = ENV.fetch('TEST_DEPLOYMENT_TARGET', '17.0')
  target = project.new_target(:unit_test_bundle, 'PlaceholderTests', :ios, deployment)
  target.build_configurations.each do |config|
    config.build_settings['CLANG_ENABLE_OBJC_ARC'] = 'YES'
    config.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
    config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'org.cyl.placeholder.tests'
    # DEVELOPMENT_TEAM signs the bundle for a physical device (scripts/device-tests.sh); simulators need no signing.
    if ENV['DEVELOPMENT_TEAM'].to_s.empty?
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
    else
      config.build_settings['DEVELOPMENT_TEAM'] = ENV['DEVELOPMENT_TEAM']
      config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
      config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "org.cyl.placeholder.tests.#{ENV['DEVELOPMENT_TEAM'].downcase}"
    end
    # Any newer API the suite or the library uses without @available fails the build at a low deployment target.
    # CYL_EXTRA_CFLAGS adds more (scripts/ios15-build.sh: -Werror=unguarded-availability).
    config.build_settings['OTHER_CFLAGS'] = "$(inherited) -Werror=unguarded-availability-new #{ENV['CYL_EXTRA_CFLAGS']}".strip
  end
  # The tests are Swift since 2026-11-20 (docs/Swift-Migration.md, step 13), compiled into the library's module, so they
  # reach internal members without @testable; the one Objective-C file is the smoke test of the Objective-C API
  # (Tests/CYLObjectiveCAPISmokeTests.m). The animation and accessibility tests have their own runners.
  other_runners = %w[CYLPlaceholderLottiePlaybackTests CYLPlaceholderBackendPlaybackTests CYLPlaceholderAnimationRegistryTests
                     CYLPlaceholderAccessibilityUITests]
  tests = Dir.glob(File.join(root, 'Tests/*.{swift,m}')).reject do |path|
    File.basename(path).start_with?('._') || other_runners.include?(File.basename(path, '.*'))
  end
  tests.sort.map { |path| path.delete_prefix("#{root}/") }.concat([
   'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/UITableView+CYLTableViewPlaceHolder.swift',
   'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/UIScrollView+CYLPlaceholder.swift',
   'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/UIScrollView+CYLPlaceholderSupport.m',
   'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderView.swift',
   'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderItemStackView.swift',
   'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderViewSupport.m',
   'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderLocalization.swift',
   'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderLocalizationSupport.m',
   'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderScenario.swift',
   'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderScenarioSupport.m',
   'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderStackView.swift',
   'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderBridge.swift',
   # The Flutter-free core of the Flutter iOS refresh view (its plugin file imports nothing without Flutter).
   'CrossPlatform/flutter_cylplaceholder/ios/Classes/CYLRefreshDrivenHost.swift',
   'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderStatusView.swift',
   'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderStatusViewSupport.m',
   'CYLTableViewPlaceHolder/CYLPlaceholderHUD/CYLPlaceholderHUD.swift',
   'CYLTableViewPlaceHolder/CYLPlaceholderHUD/CYLPlaceholderHUDSupport.m',
   'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderNetworkMonitor.swift',
   'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderNetworkMonitorSupport.m',
   'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/UIViewController+CYLPlaceholderStatus.swift']).each do |path|
    ref = project.main_group.new_file(File.join(root, path))
    target.source_build_phase.add_file_reference(ref)
  end
  refresh_dir = File.join(root, 'CYLTableViewPlaceHolder/CYLRefresh')
  target.build_configurations.each do |config|
    config.build_settings['HEADER_SEARCH_PATHS'] = "\"#{refresh_dir}/**\" \"#{root}/CYLTableViewPlaceHolder/CYLTableViewPlaceHolder\" \"#{root}/CYLTableViewPlaceHolder/CYLPlaceholderHUD\""
    # CYLPlaceholderNetworkMonitor uses NWPathMonitor (Network.framework, the podspec's `frameworks`).
    config.build_settings['OTHER_LDFLAGS'] = '$(inherited) -framework Network'
    # CYLPlaceholderView, CYLPlaceholderLocalization, CYLPlaceholderNetworkMonitor, the legacy cyl_reloadData category,
    # CYLPlaceholderStatusView, CYLPlaceholderStackView, the view controller status category, CYLPlaceholderComponent,
    # CYLPlaceholderScenarioCatalog and CYLPlaceholderHUD are Swift (2026-11-19). The module is named like the pod, so the library's Objective-C files find
    # the generated header as CYLTableViewPlaceHolder-Swift.h; the bridging header gives the Swift file the Objective-C
    # declarations the pod's umbrella header gives it; the CYLAnimatedItem pod below has the engine, so the Swift
    # condition is set as the pod's animation subspecs set it.
    config.build_settings['SWIFT_VERSION'] = '5.0'
    config.build_settings['PRODUCT_MODULE_NAME'] = 'CYLTableViewPlaceHolder'
    config.build_settings['SWIFT_OBJC_BRIDGING_HEADER'] = File.join(dir, 'PlaceholderTests-Bridging-Header.h')
    config.build_settings['SWIFT_ACTIVE_COMPILATION_CONDITIONS'] = '$(inherited) CYL_ANIMATION_ENGINE_AVAILABLE'
  end
  File.write(File.join(dir, 'PlaceholderTests-Bridging-Header.h'), "#import \"CYLTableViewPlaceHolder.h\"\n")
  # The CYLRefresh root (configuration, categories) is Swift since 2026-11-19 (docs/Swift-Migration.md, step 6), and so
  # are CYLRefreshIconView, CYLRefreshPaging and the drawn styles' support classes (step 7); the Rive header in
  # Custom/Rive/ needs RiveRuntime and is left out, as in the podspec's Core.
  refresh_swift = Dir.glob(File.join(refresh_dir, '**/*.swift')).reject { |path| path.include?('/Custom/Rive/') }
  (Dir.glob(File.join(refresh_dir, '**/*.m')) + refresh_swift).reject { |path| File.basename(path).start_with?('._') }.each do |path|
    target.source_build_phase.add_file_reference(project.main_group.new_file(path))
  end
  # One resource bundle holds the placeholder and refresh localizations and images.
  placeholder_bundle = project.main_group.new_file(File.join(root, 'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.bundle'))
  target.resources_build_phase.add_file_reference(placeholder_bundle)
  project.save
  scheme = Xcodeproj::XCScheme.new
  scheme.add_build_target(target)
  scheme.add_test_target(target)
  scheme.save_as(project.path, 'PlaceholderTests', true)
  # CYLPlaceholderView is a subclass of CYLAnimatedItemView: the CYLAnimatedItem pod (CYLTabBarController repository, not
  # on the trunk yet) at the commit the Cartfile pins, with its engine and no animator, so CYL_ANIMATION_ENGINE_AVAILABLE
  # is 1 and the tests register their own animators. CocoaPods builds it with the same Xcode as the tests (one Xcode for the pod and the tests).
  tabbar_sha = File.read(File.join(root, 'Cartfile'))[/^github "ChenYilong\/CYLTabBarController" "([0-9a-f]{40})"/, 1] || abort('Cartfile pins no CYLTabBarController commit')
  File.write(File.join(dir, 'Podfile'), <<~PODFILE)
    platform :ios, '#{deployment}'
    project 'Tests.xcodeproj'
    use_frameworks!
    target 'PlaceholderTests' do
      pod 'CYLAnimatedItem/Engine', :git => 'https://github.com/ChenYilong/CYLTabBarController.git', :commit => '#{tabbar_sha}'
    end
    post_install do |installer|
      installer.pods_project.targets.each do |pod_target|
        pod_target.build_configurations.each do |config|
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '#{deployment}'
          config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO' if ENV['DEVELOPMENT_TEAM'].to_s.empty?
        end
      end
    end
  PODFILE
  Dir.chdir(dir) do
    ENV['LANG'] ||= 'en_US.UTF-8'
    ENV['LC_ALL'] ||= 'en_US.UTF-8'
    # GitHub sometimes drops an anonymous clone on CI ("could not read Username for 'https://github.com'", "expected flush
    # after ref listing", 2026-11-22), and pod install clones CYLTabBarController: never prompt, retry up to 4 times.
    ENV['GIT_TERMINAL_PROMPT'] = '0'
    installed = (1..4).any? do |attempt|
      next true if system('pod', 'install', '--silent')
      if attempt < 4
        warn "pod install failed (attempt #{attempt}), retrying"
        sleep(attempt * 5)
      end
      false
    end
    abort 'pod install failed' unless installed
  end
  # CYL_TEST_ACTION=build-for-testing only builds (scripts/ios15-build.sh, generic simulator destination).
  action = ENV.fetch('CYL_TEST_ACTION', 'test')
  destination = ENV.fetch('DESTINATION', action == 'test' ? 'platform=iOS Simulator,name=iPhone 15,OS=17.5' : 'generic/platform=iOS Simulator')
  signing = ENV['DEVELOPMENT_TEAM'].to_s.empty? ? ['CODE_SIGNING_ALLOWED=NO'] : ['-allowProvisioningUpdates']
  # CYL_ONLY_TESTING=PlaceholderTests/testName runs one test (xcodebuild -only-testing), e.g. to repeat it under load.
  only = ENV['CYL_ONLY_TESTING'].to_s.empty? ? [] : ["-only-testing:#{ENV['CYL_ONLY_TESTING']}"]
  success = system('xcodebuild', action, '-workspace', File.join(dir, 'Tests.xcworkspace'), '-scheme', 'PlaceholderTests',
                   '-destination', destination, '-derivedDataPath', File.join(dir, 'DerivedData'), *only, *signing)
  exit(success ? 0 : 1)
end
