Pod::Spec.new do |s|
  s.name         = "CYLTableViewPlaceHolder"
  s.version      = "1.0.0"
  s.summary      = "It can observe iOS-UITableView being empty,then automaticely make a EmptyOverlayView as a place holder"
  s.description  = "CYLTableViewPlaceHolder is iPad and iPhone compatible."
  s.homepage     = "https://github.com/ChenYilong/CYLTableViewPlaceHolder"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "ChenYilong" => "luohanchenyilong@163.com" }
  s.platform     = :ios, '6.0'
  s.source       = { :git => "https://github.com/ChenYilong/CYLTableViewPlaceHolder.git", :tag => s.version.to_s }
  s.source_files  = 'CYLTableViewPlaceHolder', 'CYLTableViewPlaceHolder/**/*.{h,m}'
  s.requires_arc = true
end
