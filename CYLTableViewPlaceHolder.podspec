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
  s.resources     = 'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.bundle', 'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/LICENSE.placeholder-third-party', 'CYLTableViewPlaceHolder/CYLRefresh/CYLRefresh.bundle', 'CYLTableViewPlaceHolder/CYLRefresh/PrivacyInfo.xcprivacy', 'CYLTableViewPlaceHolder/CYLRefresh/LICENSE.third-party'
  s.requires_arc = true
  s.frameworks = 'ImageIO', 'QuartzCore'
  s.swift_version = '5.0'
  s.default_subspecs = 'Core'

  s.subspec 'Core' do |core|
    core.source_files = 'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/**/*.{h,m}',
                        'CYLTableViewPlaceHolder/CYLRefresh/**/*.{h,m}'
  end

  s.subspec 'Animation' do |animation|
    animation.dependency 'CYLTableViewPlaceHolder/Core'
    animation.source_files = 'CYLTableViewPlaceHolder/CYLPlaceholderAnimation/*.{h,m,swift}'
    animation.private_header_files = 'CYLTableViewPlaceHolder/CYLPlaceholderAnimation/*.h'
  end

  s.subspec 'Lottie' do |lottie|
    lottie.ios.deployment_target = '13.0'
    lottie.dependency 'CYLTableViewPlaceHolder/Animation'
    lottie.dependency 'lottie-ios', '>= 4.5.1'
  end

  s.subspec 'PAG' do |pag|
    pag.dependency 'CYLTableViewPlaceHolder/Animation'
    pag.dependency 'libpag', '>= 4.0'
  end

  s.subspec 'Rive' do |rive|
    rive.ios.deployment_target = '14.0'
    rive.dependency 'CYLTableViewPlaceHolder/Animation'
    rive.dependency 'RiveRuntime', '~> 6.29'
  end

end
