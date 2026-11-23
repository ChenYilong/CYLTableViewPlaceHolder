#
# The iOS half of flutter_cylplaceholder: platform views of the native CYLPlaceholderView and CYLPlaceholderStackView and the
# method channel of the native CYLPlaceholderHUD. Everything they show is CYLTableViewPlaceHolder's own component, reached
# through its CYLPlaceholderBridge / CYLPlaceholderHUDBridge; there is no second implementation here.
#
# [EN] The app's Podfile chooses where the pods come from: CYLTableViewPlaceHolder from this repository (:path => the repository
#      root), CYLAnimatedItem from CYLTabBarController at the commit the Cartfile pins (:git + :commit), and the animation
#      engine (a CYLTableViewPlaceHolder animation subspec, for example LottieSwift). See example/ios/Podfile.
# [CN] 由应用的 Podfile 决定各 pod 的来源：CYLTableViewPlaceHolder 取本仓库（:path 指向仓库根目录），CYLAnimatedItem 取
#      Cartfile 固定的 CYLTabBarController 提交（:git + :commit），动画引擎为 CYLTableViewPlaceHolder 的动画子库（如 LottieSwift）。
#
Pod::Spec.new do |s|
  s.name             = 'flutter_cylplaceholder'
  s.version          = '0.0.1'
  s.summary          = 'CYLTableViewPlaceHolder for Flutter: the native placeholder view, stack and HUD of iOS'
  s.description      = 'Hosts the native CYLPlaceholderView and CYLPlaceholderStackView as Flutter platform views and drives the native CYLPlaceholderHUD over a method channel.'
  s.homepage         = 'https://github.com/ChenYilong/CYLTableViewPlaceHolder'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'ChenYilong' => 'luohanchenyilong@163.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*.swift'
  s.dependency 'Flutter'
  s.dependency 'CYLTableViewPlaceHolder'
  s.platform         = :ios, '15.0'
  s.swift_version    = '5.0'
  s.static_framework = true
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
end
