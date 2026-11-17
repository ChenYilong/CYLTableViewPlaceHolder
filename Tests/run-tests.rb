#!/usr/bin/env ruby
require 'tmpdir'
require 'xcodeproj'

root = File.expand_path('..', __dir__)
Dir.mktmpdir('cyl-placeholder-tests-') do |dir|
  project = Xcodeproj::Project.new(File.join(dir, 'Tests.xcodeproj'))
  # TEST_DEPLOYMENT_TARGET builds the suite at another deployment target: 15.0 (the lowest Xcode 27 allows) or 12.0
  # (the podspec's minimum, CI: .github/workflows/ios12-runtime.yml on the Intel runner with the iOS 12.4 simulator).
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
    # CYL_EXTRA_CFLAGS adds more (scripts/ios12-build.sh: -Werror=unguarded-availability).
    config.build_settings['OTHER_CFLAGS'] = "$(inherited) -Werror=unguarded-availability-new #{ENV['CYL_EXTRA_CFLAGS']}".strip
  end
  ['Tests/PlaceholderTests.m', 'Tests/CYLAutomaticPlaceholderTests.m', 'Tests/CYLPlaceholderScenarioTests.m',
   'Tests/CYLRefreshIconTests.m', 'Tests/CYLRefreshSmartAPITests.m', 'Tests/CYLRefreshDrawnHeaderTests.m', 'Tests/CYLPlaceholderStatusViewTests.m', 'Tests/CYLPlaceholderHUDTests.m', 'Tests/CYLAndroidParityTests.m', 'Tests/CYLRefreshConsolidationTests.m',
   'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/UITableView+CYLTableViewPlaceHolder.m',
   'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/UIScrollView+CYLPlaceholder.m',
   'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderView.m',
   'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderLocalization.m',
   'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderScenario.m',
   'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderStackView.m',
   'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderStatusView.m',
   'CYLTableViewPlaceHolder/CYLPlaceholderHUD/CYLPlaceholderHUD.m',
   'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderNetworkMonitor.m',
   'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/UIViewController+CYLPlaceholderStatus.m'].each do |path|
    ref = project.main_group.new_file(File.join(root, path))
    target.source_build_phase.add_file_reference(ref)
  end
  refresh_dir = File.join(root, 'CYLTableViewPlaceHolder/CYLRefresh')
  target.build_configurations.each do |config|
    config.build_settings['HEADER_SEARCH_PATHS'] = "\"#{refresh_dir}/**\" \"#{root}/CYLTableViewPlaceHolder/CYLTableViewPlaceHolder\" \"#{root}/CYLTableViewPlaceHolder/CYLPlaceholderHUD\""
    # CYLPlaceholderNetworkMonitor uses NWPathMonitor (Network.framework, the podspec's `frameworks`).
    config.build_settings['OTHER_LDFLAGS'] = '$(inherited) -framework Network'
  end
  Dir.glob(File.join(refresh_dir, '**/*.m')).reject { |path| File.basename(path).start_with?('._') }.each do |path|
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
  # is 1 and the tests register their own animators. CocoaPods builds it with the same Xcode as the tests (the iOS 12
  # jobs use Xcode 16, which cannot import a framework built by Xcode 26).
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
    abort 'pod install failed' unless system('pod', 'install', '--silent')
  end
  # CYL_TEST_ACTION=build-for-testing only builds (scripts/ios12-build.sh, generic simulator destination).
  action = ENV.fetch('CYL_TEST_ACTION', 'test')
  destination = ENV.fetch('DESTINATION', action == 'test' ? 'platform=iOS Simulator,name=iPhone 15,OS=17.5' : 'generic/platform=iOS Simulator')
  signing = ENV['DEVELOPMENT_TEAM'].to_s.empty? ? ['CODE_SIGNING_ALLOWED=NO'] : ['-allowProvisioningUpdates']
  success = system('xcodebuild', action, '-workspace', File.join(dir, 'Tests.xcworkspace'), '-scheme', 'PlaceholderTests',
                   '-destination', destination, '-derivedDataPath', File.join(dir, 'DerivedData'), *signing)
  exit(success ? 0 : 1)
end
