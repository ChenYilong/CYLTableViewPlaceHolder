require 'xcodeproj'
# [EN] Writes CYLExample.xcodeproj (the app target of React Native 0.76's template, with a Swift app delegate); run once from this folder.
# [CN] 生成 CYLExample.xcodeproj（React Native 0.76 模板的应用 target，AppDelegate 为 Swift）；在本目录运行一次。
path = File.join(__dir__, 'CYLExample.xcodeproj')
project = Xcodeproj::Project.new(path)
target = project.new_target(:application, 'CYLExample', :ios, '15.1')
group = project.main_group.new_group('CYLExample', 'CYLExample')
target.source_build_phase.add_file_reference(group.new_file('AppDelegate.swift'))
target.source_build_phase.add_file_reference(group.new_file('SceneDelegate.swift'))
info = group.new_file('Info.plist')
target.resources_build_phase.add_file_reference(group.new_file('LaunchScreen.storyboard'))
target.resources_build_phase.add_file_reference(group.new_file('Images.xcassets'))
target.resources_build_phase.add_file_reference(group.new_file('PrivacyInfo.xcprivacy'))
phase = target.new_shell_script_build_phase('Bundle React Native code and images')
phase.shell_script = "set -e\n\nWITH_ENVIRONMENT=\"$REACT_NATIVE_PATH/scripts/xcode/with-environment.sh\"\nREACT_NATIVE_XCODE=\"$REACT_NATIVE_PATH/scripts/react-native-xcode.sh\"\n\n/bin/sh -c \"$WITH_ENVIRONMENT $REACT_NATIVE_XCODE\"\n"
target.build_configurations.each do |config|
  s = config.build_settings
  s['PRODUCT_BUNDLE_IDENTIFIER'] = 'org.cyl.placeholder.reactnative.example'
  s['PRODUCT_NAME'] = 'CYLExample'
  s['INFOPLIST_FILE'] = 'CYLExample/Info.plist'
  s['ASSETCATALOG_COMPILER_APPICON_NAME'] = 'AppIcon'
  s['SWIFT_VERSION'] = '5.0'
  s['MARKETING_VERSION'] = '1.0'
  s['CURRENT_PROJECT_VERSION'] = '1'
  s['TARGETED_DEVICE_FAMILY'] = '1'
  s['CODE_SIGNING_ALLOWED'] = 'NO'
  s['CLANG_ENABLE_MODULES'] = 'YES'
  s['REACT_NATIVE_PATH'] = '${PODS_ROOT}/../../node_modules/react-native'
  s['LD_RUNPATH_SEARCH_PATHS'] = '$(inherited) @executable_path/Frameworks'
  s['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone' if config.name == 'Debug'
end
project.save
scheme = Xcodeproj::XCScheme.new
scheme.add_build_target(target)
scheme.set_launch_target(target)
scheme.save_as(path, 'CYLExample', true)
