#!/usr/bin/env ruby
require 'tmpdir'
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
  %w[CYLPlaceholderLottiePlaybackTests.m CYLPlaceholderBackendPlaybackTests.m].each do |filename|
    ref = project.main_group.new_file(File.join(root, 'Tests', filename))
    target.source_build_phase.add_file_reference(ref)
  end
  fixtures = {
    'CYLPlaceholderTest.pag' => ENV.fetch('PAG_FIXTURE', File.expand_path('../CYLTabBarController/Example-Shared/PAGResources/tab-icons/tab_home.pag', root)),
    'CYLPlaceholderTest.riv' => ENV.fetch('RIVE_FIXTURE', File.expand_path('../CYLTabBarController/Example-SwiftUI-Rive/AnimatedApp/RiveAssets/icons.riv', root)),
    'CYLPlaceholderTrigger.riv' => ENV.fetch('RIVE_TRIGGER_FIXTURE', File.expand_path('../CYLTabBarController/Example-SwiftUI-Rive/AnimatedApp/RiveAssets/check.riv', root)),
    'CYLPlaceholderLinear.riv' => ENV.fetch('RIVE_LINEAR_FIXTURE', File.expand_path('../CYLTabBarController/Example-SwiftUI-Rive/AnimatedApp/RiveAssets/button.riv', root))
  }
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
  File.write(File.join(dir, 'Podfile'), <<~PODFILE)
    platform :ios, '15.0'
    project 'AnimationTests.xcodeproj'
    use_frameworks! :linkage => :#{linkage}
    target 'AnimationTests' do
      pod 'CYLTableViewPlaceHolder/Lottie', :path => #{root.dump}
      pod 'CYLTableViewPlaceHolder/PAG', :path => #{root.dump}
      pod 'CYLTableViewPlaceHolder/Rive', :path => #{root.dump}
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
    abort 'pod install failed' unless system('pod', 'install', '--silent')
    destination = ENV.fetch('DESTINATION', 'platform=iOS Simulator,name=iPhone 15,OS=17.5')
    success = system('xcodebuild', 'test', '-workspace', 'AnimationTests.xcworkspace',
      '-scheme', 'AnimationTests', '-destination', destination,
      '-derivedDataPath', File.join(dir, 'DerivedData'), 'CODE_SIGNING_ALLOWED=NO')
    exit(success ? 0 : 1)
  end
end
