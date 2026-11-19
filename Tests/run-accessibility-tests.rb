#!/usr/bin/env ruby
# Builds a minimal host app with Core and runs XCUITests that read the accessibility tree VoiceOver reads,
# plus Apple's accessibility audit (iOS 17+ simulators).
require 'tmpdir'
require 'xcodeproj'

root = File.expand_path('..', __dir__)
core_dir = File.join(root, 'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder')
refresh_dir = File.join(root, 'CYLTableViewPlaceHolder/CYLRefresh')
hud_dir = File.join(root, 'CYLTableViewPlaceHolder/CYLPlaceholderHUD')
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
    config.build_settings['HEADER_SEARCH_PATHS'] = "\"#{refresh_dir}/**\" \"#{core_dir}\" \"#{hud_dir}\""
    # CYLPlaceholderView is Swift (2026-11-19): the module is named like the pod (so the Objective-C files find
    # CYLTableViewPlaceHolder-Swift.h), the bridging header plays the pod's umbrella header for the Swift file, and the
    # CYLAnimatedItem framework always has the engine.
    config.build_settings['SWIFT_VERSION'] = '5.0'
    config.build_settings['PRODUCT_MODULE_NAME'] = 'CYLTableViewPlaceHolder'
    config.build_settings['SWIFT_OBJC_BRIDGING_HEADER'] = File.join(dir, 'AccessibilityHost-Bridging-Header.h')
    config.build_settings['SWIFT_ACTIVE_COMPILATION_CONDITIONS'] = '$(inherited) CYL_ANIMATION_ENGINE_AVAILABLE'
  end
  File.write(File.join(dir, 'AccessibilityHost-Bridging-Header.h'), "#import \"CYLTableViewPlaceHolder.h\"\n")
  ui.build_configurations.each do |config|
    config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'org.cyl.placeholder.accessibility.uitests'
    config.build_settings['TEST_TARGET_NAME'] = 'AccessibilityHost'
  end

  sources = [File.join(root, 'Tests/AccessibilityHost/main.m')] +
            Dir.glob(File.join(core_dir, '*.{m,swift}')).select(&visible) +
            Dir.glob(File.join(refresh_dir, '**/*.m')).select(&visible) +
            # The CYLRefresh Swift files except the Rive header, which needs RiveRuntime (as in the podspec's Core).
            Dir.glob(File.join(refresh_dir, '**/*.swift')).reject { |path| path.include?('/Custom/Rive/') }.select(&visible) +
            Dir.glob(File.join(hud_dir, '*.{m,swift}')).select(&visible)
  sources.sort.each { |path| app.source_build_phase.add_file_reference(project.main_group.new_file(path)) }
  # One resource bundle holds the placeholder and refresh localizations and images.
  app.resources_build_phase.add_file_reference(project.main_group.new_file(File.join(core_dir, 'CYLTableViewPlaceHolder.bundle')))
  # CYLPlaceholderView is a subclass of CYLTabBarController's CYLAnimatedItemView: link and embed its framework.
  system('bash', File.join(root, 'scripts/cyltabbarcontroller-xcframework.sh'), 'simulator') || abort('CYLTabBarController.xcframework failed to build')
  # Newer CYLTabBarController commits split CYLAnimatedItem into its own framework; link it too when it was built.
  embed = app.new_copy_files_build_phase('Embed Frameworks')
  embed.symbol_dst_subfolder_spec = :frameworks
  %w[CYLTabBarController CYLAnimatedItem].each do |name|
    path = File.join(root, "Carthage/Build/#{name}.xcframework")
    next unless File.exist?(path)
    ref = project.main_group.new_file(path)
    app.frameworks_build_phase.add_file_reference(ref)
    embed.add_file_reference(ref).settings = { 'ATTRIBUTES' => ['CodeSignOnCopy', 'RemoveHeadersOnCopy'] }
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
