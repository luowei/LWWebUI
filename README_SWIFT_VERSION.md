# LWWebUI Swift Version

## 概述

LWWebUI_swift 是 LWWebUI 的 Swift 版本实现，提供了现代化的 Swift API 用于创建基于 WKWebView 的 WebView 容器组件和 Web 控制器组件。

## 安装

### CocoaPods

在您的 `Podfile` 中添加：

```ruby
pod 'LWWebUI_swift'
```

然后运行：

```bash
pod install
```

## 使用方法

### UIKit - LWWKWebViewController

```swift
import LWWebUI_swift

// 使用 LWWKWebViewController
let webViewController = LWWKWebViewController()
webViewController.loadURL(URL(string: "https://www.example.com")!)
navigationController?.pushViewController(webViewController, animated: true)
```

### UIKit - LWWKWebView

```swift
import LWWebUI_swift

// 使用 LWWKWebView
let webView = LWWKWebView(frame: view.bounds)
webView.load(URLRequest(url: URL(string: "https://www.example.com")!))
view.addSubview(webView)

// 配置回调
webView.onPageLoadFinished = { url in
    print("Page loaded: \(url)")
}
```

### SwiftUI

```swift
import SwiftUI
import LWWebUI_swift

struct ContentView: View {
    var body: some View {
        LWWebView(url: URL(string: "https://www.example.com")!)
            .edgesIgnoringSafeArea(.all)
    }
}
```

### 网络可达性检测

```swift
import LWWebUI_swift

// 使用 LWWKReachability
let reachability = LWWKReachability.shared

reachability.startMonitoring()

reachability.onNetworkStatusChanged = { status in
    switch status {
    case .notReachable:
        print("No network connection")
    case .reachableViaWiFi:
        print("Connected via WiFi")
    case .reachableViaWWAN:
        print("Connected via cellular")
    }
}
```

## 主要特性

- **完整的 Web 容器**: 提供功能完善的 WebView 容器和控制器
- **UIKit 和 SwiftUI 支持**: 同时支持 UIKit 和 SwiftUI
- **网络可达性**: 内置网络状态检测
- **简单易用**: 简洁的 API 设计
- **可定制**: 支持丰富的自定义选项

## 组件说明

- **LWWKWebViewController**: UIKit 视图控制器，提供完整的 Web 浏览功能
- **LWWKWebView**: UIKit WebView 组件，可以嵌入到任何视图中
- **LWWebView+SwiftUI**: SwiftUI 扩展，提供声明式 API
- **LWWKReachability**: 网络可达性检测工具

## 系统要求

- iOS 11.0+
- Swift 5.0+
- Xcode 12.0+

## 依赖

- Masonry

## 与 Objective-C 版本的关系

- **LWWebUI**: Objective-C 版本，适用于传统的 Objective-C 项目
- **LWWebUI_swift**: Swift 版本，提供现代化的 Swift API 和 SwiftUI 支持

您可以根据项目需要选择合适的版本。两个版本功能相同，但 Swift 版本提供了更好的类型安全性和 SwiftUI 集成。

## License

LWWebUI_swift is available under the MIT license. See the LICENSE file for more info.
