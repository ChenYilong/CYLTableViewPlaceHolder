#!/usr/bin/env ruby
require 'tmpdir'
require 'xcodeproj'

root = File.expand_path('..', __dir__)
Dir.mktmpdir('cyl-placeholder-tests-') do |dir|
  project = Xcodeproj::Project.new(File.join(dir, 'Tests.xcodeproj'))
  target = project.new_target(:unit_test_bundle, 'PlaceholderTests', :ios, '17.0')
  target.build_configurations.each do |config|
    config.build_settings['CLANG_ENABLE_OBJC_ARC'] = 'YES'
    config.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
    config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'org.cyl.placeholder.tests'
    config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
  end
  ['Tests/PlaceholderTests.m', 'Tests/CYLAutomaticPlaceholderTests.m',
   'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/UITableView+CYLTableViewPlaceHolder.m',
   'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/UIScrollView+CYLPlaceholder.m',
   'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderView.m'].each do |path|
    ref = project.main_group.new_file(File.join(root, path))
    target.source_build_phase.add_file_reference(ref)
  end
  refresh_dir = File.join(root, 'CYLTableViewPlaceHolder/CYLRefresh')
  target.build_configurations.each do |config|
    config.build_settings['HEADER_SEARCH_PATHS'] = "\"#{refresh_dir}/**\""
  end
  Dir.glob(File.join(refresh_dir, '**/*.m')).reject { |path| File.basename(path).start_with?('._') }.each do |path|
    target.source_build_phase.add_file_reference(project.main_group.new_file(path))
  end
  resource = project.main_group.new_file(File.join(refresh_dir, 'CYLRefresh.bundle'))
  target.resources_build_phase.add_file_reference(resource)
  placeholder_bundle = project.main_group.new_file(File.join(root, 'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.bundle'))
  target.resources_build_phase.add_file_reference(placeholder_bundle)
  project.save
  scheme = Xcodeproj::XCScheme.new
  scheme.add_build_target(target)
  scheme.add_test_target(target)
  scheme.save_as(project.path, 'PlaceholderTests', true)
  destination = ENV.fetch('DESTINATION', 'platform=iOS Simulator,name=iPhone 15,OS=17.5')
  success = system('xcodebuild', 'test', '-project', project.path.to_s, '-scheme', 'PlaceholderTests',
                   '-destination', destination, '-derivedDataPath', File.join(dir, 'DerivedData'),
                   'CODE_SIGNING_ALLOWED=NO')
  exit(success ? 0 : 1)
end
