#
# Be sure to run `pod lib lint LWWebUI_swift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LWWebUI_swift'
  s.version          = '1.0.0'
  s.summary          = 'Swift版本的LWWebUI - 基于WKWebView的WebView容器与控制器组件'

  s.description      = <<-DESC
LWWebUI_swift 是 LWWebUI 的 Swift 版本实现。
提供了 UIKit (LWWKWebViewController、LWWKWebView) 和 SwiftUI 接口，
用于创建功能完善的 Web 视图容器和控制器。
包含网络可达性检测、SwiftUI 扩展等功能。
                       DESC

  s.homepage         = 'https://github.com/luowei/LWWebUI'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'luowei' => 'luowei@wodedata.com' }
  s.source           = { :git => 'https://github.com/luowei/LWWebUI.git', :tag => "swift-#{s.version}" }

  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'

  s.source_files = 'LWWebUI_swift/**/*.swift'

  s.resource_bundles = {
    'LWWebUI' => ['LWWebUI/Assets/**/*']
  }

  s.frameworks = 'UIKit', 'WebKit'
  s.dependency 'Masonry'
end
