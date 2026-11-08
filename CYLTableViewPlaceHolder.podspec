Pod::Spec.new do |s|
  s.name         = "CYLTableViewPlaceHolder"
  s.version      = "1.1.0"
  s.summary      = "When UITableView(iOS) is empty,then it can automaticely make an empty overlay view "
  s.description  = "It can observe UITableView(iOS) being empty,then automaticely make an empty overlay view as a place holder. CYLTableViewPlaceHolder is iPad and iPhone compatible."
  s.homepage     = "https://github.com/ChenYilong/CYLTableViewPlaceHolder"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "ChenYilong" => "luohanchenyilong@163.com" }
  s.platform     = :ios, '12.0'
  s.source       = { :git => "https://github.com/ChenYilong/CYLTableViewPlaceHolder.git", :tag => s.version.to_s }
  s.source_files  = 'CYLTableViewPlaceHolder', 'CYLTableViewPlaceHolder/**/*.{h,m}'
  s.resources     = 'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.bundle', 'CYLTableViewPlaceHolder/LICENSE.placeholder-third-party', 'CYLTableViewPlaceHolder/CYLRefresh/CYLRefresh.bundle', 'CYLTableViewPlaceHolder/CYLRefresh/PrivacyInfo.xcprivacy', 'CYLTableViewPlaceHolder/CYLRefresh/LICENSE.third-party'
  s.requires_arc = true
end
