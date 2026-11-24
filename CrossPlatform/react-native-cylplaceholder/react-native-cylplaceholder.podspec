require 'json'
package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name         = 'react-native-cylplaceholder'
  s.version      = package['version']
  s.summary      = package['description']
  s.homepage     = package['repository']
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = 'ChenYilong'
  s.platform     = :ios, '15.0'
  s.source       = { :git => 'https://github.com/ChenYilong/CYLTableViewPlaceHolder.git', :tag => "rn-#{s.version}" }
  # [EN] The refresh container is Objective-C; the placeholder stack and HUD are Swift (the core's CYLPlaceholderBridge is Swift) with a
  #      small Objective-C file that declares their React Native names (CYLPlaceholderReactBridge.m).
  # [CN] 刷新容器是 Objective-C；占位 stack 与 HUD 是 Swift（核心的 CYLPlaceholderBridge 是 Swift），并用一个小的 Objective-C 文件
  #      声明它们的 React Native 名称（CYLPlaceholderReactBridge.m）。
  s.source_files = 'ios/**/*.{h,m,swift}'
  s.swift_version = '5.0'
  s.dependency 'React-Core'
  # [EN] The refresh kernel is this repository's CYLRefresh, in the CYLTableViewPlaceHolder pod. [CN] 刷新内核是本仓库的 CYLRefresh，在 CYLTableViewPlaceHolder pod 中。
  s.dependency 'CYLTableViewPlaceHolder'
end
