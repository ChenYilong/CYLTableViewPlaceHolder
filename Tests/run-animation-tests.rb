#!/usr/bin/env ruby
require 'tmpdir'
require 'fileutils'
require 'xcodeproj'

root = File.expand_path('..', __dir__)
Dir.mktmpdir('cyl-placeholder-animation-tests-') do |dir|
  project = Xcodeproj::Project.new(File.join(dir, 'AnimationTests.xcodeproj'))
  target = project.new_target(:unit_test_bundle, 'AnimationTests', :ios, '15.0')
  target.build_configurations.each do |config|
    config.build_settings['CLANG_ENABLE_OBJC_ARC'] = 'YES'
    config.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
    config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'org.cyl.placeholder.animation.tests'
    config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
  end
  # The tests are Swift (docs/Swift-Migration.md, step 13) and import the pods' modules, so they build with static and
  # dynamic frameworks alike. The PAG view is read by class name and key-value coding: the PAGEnterprise umbrella header
  # of libpag-enterprise 4.4.x-4.5.98 imports a missing header, so libpag cannot be imported as a module there.
  %w[CYLPlaceholderLottiePlaybackTests.swift CYLPlaceholderBackendPlaybackTests.swift CYLPlaceholderAnimationRegistryTests.swift].each do |filename|
    target.source_build_phase.add_file_reference(project.main_group.new_file(File.join(root, 'Tests', filename)))
  end
  target.build_configurations.each { |config| config.build_settings['SWIFT_VERSION'] = '5.0' }
  fixtures = {
    'CYLPlaceholderTest.pag' => ENV.fetch('PAG_FIXTURE', File.expand_path('../CYLTabBarController/Example-Shared/PAGResources/tab-icons/tab_home.pag', root)),
    'CYLPlaceholderTest.riv' => ENV.fetch('RIVE_FIXTURE', File.expand_path('../CYLTabBarController/Example-SwiftUI-Rive/AnimatedApp/RiveAssets/icons.riv', root)),
    'CYLPlaceholderTrigger.riv' => ENV.fetch('RIVE_TRIGGER_FIXTURE', File.expand_path('../CYLTabBarController/Example-SwiftUI-Rive/AnimatedApp/RiveAssets/check.riv', root)),
    'CYLPlaceholderLinear.riv' => ENV.fetch('RIVE_LINEAR_FIXTURE', File.expand_path('../CYLTabBarController/Example-SwiftUI-Rive/AnimatedApp/RiveAssets/button.riv', root)),
    # rive-app/rive-ios Tests/Assets/data_binding_test.riv (MIT); scripts/animation-tests.sh downloads it.
    'CYLPlaceholderBinding.riv' => ENV.fetch('RIVE_BINDING_FIXTURE', File.join(root, 'build/fixtures/data_binding_test.riv')),
    # CYLTabBarController's tab_list.svga (Apache-2.0, Examples/Example-Scenarios/.../Animations/NOTICE.svga-samples.md).
    'CYLPlaceholderTest.svga' => File.join(dir, 'tab_list.svga')
  }
  # Copied out of the example's .bundle folder: a file reference inside a bundle is not copied as a resource.
  FileUtils.cp(File.join(root, 'Examples/Example-Scenarios/Sources/CYLScenarioExample.bundle/Animations/tab_list.svga'),
               File.join(dir, 'tab_list.svga'))
  fixtures.each do |name, path|
    abort "Missing animation fixture: #{path}" unless File.file?(path)
    ref = project.main_group.new_file(path)
    ref.name = name
    target.resources_build_phase.add_file_reference(ref)
  end
  project.save
  scheme = Xcodeproj::XCScheme.new
  scheme.add_build_target(target)
  scheme.add_test_target(target)
  scheme.save_as(project.path, 'AnimationTests', true)
  linkage = ENV.fetch('LINKAGE', 'static')
  abort 'LINKAGE must be static or dynamic' unless %w[static dynamic].include?(linkage)
  # Core depends on the CYLAnimatedItem pod (CYLTabBarController repository): the commit the Cartfile pins.
  tabbar_sha = File.read(File.join(root, 'Cartfile'))[/^github "ChenYilong\/CYLTabBarController" "([0-9a-f]{40})"/, 1] || abort('Cartfile pins no CYLTabBarController commit')
  File.write(File.join(dir, 'Podfile'), <<~PODFILE)
    platform :ios, '15.0'
    project 'AnimationTests.xcodeproj'
    use_frameworks! :linkage => :#{linkage}
    target 'AnimationTests' do
      pod 'CYLAnimatedItem', :git => 'https://github.com/ChenYilong/CYLTabBarController.git', :commit => '#{tabbar_sha}'
      pod 'CYLTableViewPlaceHolder/LottieSwift', :path => #{root.dump}
      pod 'CYLTableViewPlaceHolder/GIF', :path => #{root.dump}
      pod 'CYLTableViewPlaceHolder/#{ENV.fetch('PAG_SUBSPEC', 'PAG')}', :path => #{root.dump}
      pod 'CYLTableViewPlaceHolder/Rive', :path => #{root.dump}
      pod 'CYLTableViewPlaceHolder/SVGA', :path => #{root.dump}
    end
    post_install do |installer|
      installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
        end
      end
    end
  PODFILE
  Dir.chdir(dir) do
    # CI runners sometimes cannot reach github.com for a moment ("could not read Username", "Could not resolve host"),
    # which failed the whole job in pod install (PR #35, run 44963099871). Retry with a pause before giving up.
    pod_ok = (1..3).any? do |attempt|
      ok = system('pod', 'install', '--silent')
      warn "pod install failed (attempt #{attempt} of 3)" unless ok
      sleep(15 * attempt) if !ok && attempt < 3
      ok
    end
    abort 'pod install failed' unless pod_ok
    destination = ENV.fetch('DESTINATION', 'platform=iOS Simulator,name=iPhone 15,OS=17.5')
    success = system('xcodebuild', 'test', '-workspace', 'AnimationTests.xcworkspace',
      '-scheme', 'AnimationTests', '-destination', destination,
      '-derivedDataPath', File.join(dir, 'DerivedData'), 'CODE_SIGNING_ALLOWED=NO')
    exit(success ? 0 : 1)
  end
end
