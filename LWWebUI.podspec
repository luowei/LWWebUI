#
# Be sure to run `pod lib lint LWWebUI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LWWebUI'
  s.version          = '1.0.0'
  s.summary          = '基于WKWebView的WebView容器组件与Web控制器组件'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
LWWebUI，基于WKWebView的WebView容器组件与Web控制器组件，包含 LWWKWebViewController & LWWKWebView.
                       DESC

  s.homepage         = 'https://github.com/luowei/LWWebUI'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'luowei' => 'luowei@wodedata.com' }
  s.source           = { :git => 'https://github.com/luowei/LWWebUI.git'}
  # s.source           = { :git => 'https://gitlab.com/ioslibraries1/liblwwebui.git' }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'LWWebUI/Classes/**/*.{h,m}'
  s.exclude_files = 'LWWebUI/Classes/**/*.swift'

  s.resource_bundles = {
    'LWWebUI' => ['LWWebUI/Assets/**/*']
    # 'LWWebUI' => ['LWWebUI/Assets/*.png']
  }

  s.public_header_files = 'LWWebUI/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'Masonry'

end

