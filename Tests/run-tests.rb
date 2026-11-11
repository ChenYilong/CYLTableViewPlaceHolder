#!/usr/bin/env ruby
require 'tmpdir'
require 'xcodeproj'

root = File.expand_path('..', __dir__)
Dir.mktmpdir('cyl-placeholder-tests-') do |dir|
  project = Xcodeproj::Project.new(File.join(dir, 'Tests.xcodeproj'))
  # TEST_DEPLOYMENT_TARGET builds the suite at another deployment target (e.g. 15.0, the lowest Xcode 27 allows).
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
    config.build_settings['OTHER_CFLAGS'] = '$(inherited) -Werror=unguarded-availability-new'
  end
  ['Tests/PlaceholderTests.m', 'Tests/CYLAutomaticPlaceholderTests.m', 'Tests/CYLPlaceholderScenarioTests.m',
   'Tests/CYLRefreshIconTests.m', 'Tests/CYLPlaceholderStatusViewTests.m',
   'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/UITableView+CYLTableViewPlaceHolder.m',
   'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/UIScrollView+CYLPlaceholder.m',
   'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderView.m',
   'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderLocalization.m',
   'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderScenario.m',
   'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderStackView.m',
   'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderStatusView.m',
   'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderNetworkMonitor.m',
   'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/UIViewController+CYLPlaceholderStatus.m'].each do |path|
    ref = project.main_group.new_file(File.join(root, path))
    target.source_build_phase.add_file_reference(ref)
  end
  # The shared animation subspec (registry, factory, engine, host view), without any engine adapter, so Core's
  # built-in GIF decoder and the "backend unavailable" paths are exercised.
  Dir.glob(File.join(root, 'CYLTableViewPlaceHolder/CYLPlaceholderAnimation/*.m')).reject { |path| File.basename(path).start_with?('._') }.sort.each do |path|
    target.source_build_phase.add_file_reference(project.main_group.new_file(path))
  end
  refresh_dir = File.join(root, 'CYLTableViewPlaceHolder/CYLRefresh')
  target.build_configurations.each do |config|
    config.build_settings['HEADER_SEARCH_PATHS'] = "\"#{refresh_dir}/**\" \"#{root}/CYLTableViewPlaceHolder/CYLTableViewPlaceHolder\" \"#{root}/CYLTableViewPlaceHolder/CYLPlaceholderAnimation\""
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
  destination = ENV.fetch('DESTINATION', 'platform=iOS Simulator,name=iPhone 15,OS=17.5')
  signing = ENV['DEVELOPMENT_TEAM'].to_s.empty? ? ['CODE_SIGNING_ALLOWED=NO'] : ['-allowProvisioningUpdates']
  success = system('xcodebuild', 'test', '-project', project.path.to_s, '-scheme', 'PlaceholderTests',
                   '-destination', destination, '-derivedDataPath', File.join(dir, 'DerivedData'), *signing)
  exit(success ? 0 : 1)
end
