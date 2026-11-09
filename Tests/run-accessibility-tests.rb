#!/usr/bin/env ruby
# Builds a minimal host app with Core and runs XCUITests that read the accessibility tree VoiceOver reads,
# plus Apple's accessibility audit (iOS 17+ simulators).
require 'tmpdir'
require 'xcodeproj'

root = File.expand_path('..', __dir__)
core_dir = File.join(root, 'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder')
refresh_dir = File.join(root, 'CYLTableViewPlaceHolder/CYLRefresh')
visible = ->(path) { !File.basename(path).start_with?('._') }

Dir.mktmpdir('cyl-placeholder-accessibility-') do |dir|
  project = Xcodeproj::Project.new(File.join(dir, 'AccessibilityTests.xcodeproj'))
  app = project.new_target(:application, 'AccessibilityHost', :ios, '15.0')
  ui = project.new_target(:ui_test_bundle, 'AccessibilityUITests', :ios, '15.0')
  ui.add_dependency(app)

  [app, ui].each do |target|
    target.build_configurations.each do |config|
      config.build_settings['CLANG_ENABLE_OBJC_ARC'] = 'YES'
      config.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
      config.build_settings['CODE_SIGN_STYLE'] = 'Manual'
      config.build_settings['CODE_SIGN_IDENTITY'] = '-'
      config.build_settings['DEVELOPMENT_TEAM'] = ''
    end
  end
  app.build_configurations.each do |config|
    config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'org.cyl.placeholder.accessibility.host'
    config.build_settings['INFOPLIST_KEY_UILaunchScreen_Generation'] = 'YES'
    config.build_settings['INFOPLIST_KEY_UIApplicationSceneManifest_Generation'] = 'YES'
    config.build_settings['INFOPLIST_KEY_UISupportedInterfaceOrientations'] = 'UIInterfaceOrientationPortrait'
    config.build_settings['HEADER_SEARCH_PATHS'] = "\"#{refresh_dir}/**\" \"#{core_dir}\""
  end
  ui.build_configurations.each do |config|
    config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'org.cyl.placeholder.accessibility.uitests'
    config.build_settings['TEST_TARGET_NAME'] = 'AccessibilityHost'
  end

  sources = [File.join(root, 'Tests/AccessibilityHost/main.m')] +
            Dir.glob(File.join(core_dir, '*.m')).select(&visible) +
            Dir.glob(File.join(refresh_dir, '**/*.m')).select(&visible)
  sources.sort.each { |path| app.source_build_phase.add_file_reference(project.main_group.new_file(path)) }
  [File.join(core_dir, 'CYLTableViewPlaceHolder.bundle'), File.join(refresh_dir, 'CYLRefresh.bundle')].each do |path|
    app.resources_build_phase.add_file_reference(project.main_group.new_file(path))
  end
  ui.source_build_phase.add_file_reference(project.main_group.new_file(File.join(root, 'Tests/CYLPlaceholderAccessibilityUITests.m')))
  project.save

  scheme = Xcodeproj::XCScheme.new
  scheme.add_build_target(app)
  scheme.add_test_target(ui)
  scheme.set_launch_target(app)
  scheme.save_as(project.path, 'AccessibilityTests', true)

  destination = ENV.fetch('DESTINATION', 'platform=iOS Simulator,name=iPhone 15,OS=17.5')
  success = system('xcodebuild', 'test', '-project', project.path.to_s, '-scheme', 'AccessibilityTests',
                   '-destination', destination, '-derivedDataPath', File.join(dir, 'DerivedData'))
  exit(success ? 0 : 1)
end
