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
  s.source_files = 'ios/**/*.{h,m}'
  s.dependency 'React-Core'
  # [EN] The refresh kernel is this repository's CYLRefresh, in the CYLTableViewPlaceHolder pod. [CN] 刷新内核是本仓库的 CYLRefresh，在 CYLTableViewPlaceHolder pod 中。
  s.dependency 'CYLTableViewPlaceHolder'
end
