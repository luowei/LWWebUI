# LWWebUI

[![CI Status](https://img.shields.io/travis/luowei/libLWWebUI.svg?style=flat)](https://travis-ci.org/luowei/libLWWebUI)
[![Version](https://img.shields.io/cocoapods/v/libLWWebUI.svg?style=flat)](https://cocoapods.org/pods/libLWWebUI)
[![License](https://img.shields.io/cocoapods/l/libLWWebUI.svg?style=flat)](https://cocoapods.org/pods/libLWWebUI)
[![Platform](https://img.shields.io/cocoapods/p/libLWWebUI.svg?style=flat)](https://cocoapods.org/pods/libLWWebUI)

## 简介

LWWebUI 是一个基于 WKWebView 的强大 WebView 容器组件和 Web 控制器组件库。它提供了完整的网页加载、展示和交互功能，包括进度条显示、Cookie 管理、HTTPS 证书处理、截图功能等。

### 主要特性

- **基于 WKWebView** - 采用 iOS 8.0+ 的现代化 WebView 技术
- **完整的网页控制器** - 开箱即用的 Web 浏览器功能
- **Cookie 同步管理** - 自动处理 iOS 11+ 和旧版本的 Cookie 同步
- **进度条显示** - 优雅的页面加载进度展示
- **网络状态检测** - 集成 Reachability 网络连接状态监控
- **HTTPS 证书处理** - 支持自定义证书验证（如 12306 网站）
- **分享功能** - 内置 Safari 打开和 PDF 导出功能
- **截图功能** - 支持网页截图和快照
- **自定义 UserAgent** - 智能切换 iOS/Mac UserAgent
- **错误页面处理** - 提供友好的网络错误页面

## 系统要求

- iOS 8.0+
- Xcode 9.0+

## 安装

### CocoaPods

LWWebUI 可通过 [CocoaPods](https://cocoapods.org) 安装，只需在你的 Podfile 中添加：

```ruby
pod 'LWWebUI'
```

然后运行：

```bash
pod install
```

### Carthage

在你的 Cartfile 中添加：

```ruby
github "luowei/LWWebUI"
```

## 核心组件

### 1. LWWKWebViewController

一个功能完整的 Web 视图控制器，提供了以下功能：

#### 主要特性

- 自动集成进度条展示
- 导航栏右侧"更多"按钮（分享、在 Safari 中打开、导出 PDF）
- 自动更新页面标题到导航栏
- 支持模态展示时显示关闭按钮
- KVO 监听加载进度和标题变化

#### 使用方法

**基本使用 - 加载 URL**

```objective-c
// 方式一：便捷方法
LWWKWebViewController *webVC = [LWWKWebViewController wkWebViewControllerWithURL:[NSURL URLWithString:@"https://www.apple.com"]];
UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webVC];
[self presentViewController:nav animated:YES completion:nil];

// 方式二：使用 loadURL 方法
LWWKWebViewController *webVC = [LWWKWebViewController loadURL:[NSURL URLWithString:@"https://www.apple.com"]];
UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webVC];
[self presentViewController:nav animated:YES completion:nil];
```

**加载 HTML 字符串**

```objective-c
NSString *htmlString = @"<html><body><h1>Hello, World!</h1></body></html>";
LWWKWebViewController *webVC = [LWWKWebViewController loadHTMLString:htmlString baseURL:nil];
UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webVC];
[self presentViewController:nav animated:YES completion:nil];
```

**完整示例 - 带 Cookie 管理（iOS 11+）**

```objective-c
if(@available(iOS 11.0, *)) {
    dispatch_group_t group = dispatch_group_create();

    // 删除所有现有 Cookie
    [[[WKWebsiteDataStore defaultDataStore] httpCookieStore] getAllCookies:^(NSArray<NSHTTPCookie *> *cookies) {
        for(NSHTTPCookie *cookie in cookies){
            dispatch_group_enter(group);
            [[[WKWebsiteDataStore defaultDataStore] httpCookieStore] deleteCookie:cookie completionHandler:^{
                dispatch_group_leave(group);
            }];
        }
    }];

    // 等待删除完成后，设置新的 Cookie 并加载页面
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self setupCookies];
        LWWKWebViewController *webVC = [LWWKWebViewController wkWebViewControllerWithURL:[NSURL URLWithString:@"https://example.com"]];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webVC];
        [self presentViewController:nav animated:YES completion:nil];
    });
} else {
    // iOS 11 以下版本
    [self setupCookies];
    LWWKWebViewController *webVC = [LWWKWebViewController wkWebViewControllerWithURL:[NSURL URLWithString:@"https://example.com"]];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webVC];
    [self presentViewController:nav animated:YES completion:nil];
}
```

**设置 Cookie 辅助方法**

```objective-c
- (void)setupCookies {
    NSHTTPCookie *cookie1 = [self cookieWithCookieDomain:@"example.com"
                                              cookieName:@"sessionId"
                                             cookieValue:@"abc123"];
    NSHTTPCookie *cookie2 = [self cookieWithCookieDomain:@"example.com"
                                              cookieName:@"userId"
                                             cookieValue:@"user001"];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie1];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie2];
}

- (NSHTTPCookie *)cookieWithCookieDomain:(NSString *)cookieDomain
                              cookieName:(NSString *)cookieName
                             cookieValue:(NSString *)cookieValue {
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    properties[NSHTTPCookieName] = cookieName;
    properties[NSHTTPCookieValue] = cookieValue;
    properties[NSHTTPCookieDomain] = cookieDomain;
    properties[NSHTTPCookiePath] = @"/";
    properties[NSHTTPCookieMaximumAge] = @86400;  // 1天

    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
    return cookie;
}
```

### 2. LWWKWebView

一个增强的 WKWebView 子类，提供了更多实用功能。

#### 主要特性

- **Cookie 自动同步** - 在加载请求时自动同步 Cookie（iOS 11+ 和旧版本自动适配）
- **网络状态检测** - 集成 Reachability 检测网络连接状态
- **HTTPS 证书处理** - 支持特定域名的自定义证书验证
- **截图功能** - 提供网页快照截图能力
- **同步 JavaScript 执行** - 提供同步版本的 JavaScript 执行方法
- **自定义 UserAgent** - 根据设备类型自动设置合适的 UserAgent
- **错误页面处理** - 网络错误时显示友好的错误页面
- **JavaScript 消息处理** - 支持网页与原生的消息通信

#### 使用方法

**基本初始化**

```objective-c
WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
configuration.userContentController = [LWWKUserContentController shareInstance];

LWWKWebView *webView = [[LWWKWebView alloc] initWithFrame:self.view.bounds
                                            configuration:configuration];
[self.view addSubview:webView];

// 加载 URL
[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.apple.com"]]];
```

**网络状态检测**

```objective-c
BOOL isConnected = [webView connected];
if (!isConnected) {
    NSLog(@"网络未连接");
}
```

**截图功能**

```objective-c
// 方式一：直接保存到相册
[webView snapshotWebView];

// 方式二：自定义处理
[webView snapshotWithHandler:^(CGImageRef imgRef) {
    UIImage *image = [UIImage imageWithCGImage:imgRef];
    // 处理截图
}];
```

**同步执行 JavaScript**

```objective-c
NSString *result = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
NSLog(@"页面标题: %@", result);
```

**HTTPS 证书处理（例如 12306）**

```objective-c
// 允许特定域名使用自定义证书
[webView setAllowsHTTPSCertifcateWithCertChain:certChain ForHost:@"12306.cn"];
```

**Block 回调**

```objective-c
// 页面加载完成回调
webView.finishNavigationProgressBlock = ^() {
    NSLog(@"页面加载完成");
};

// 需要展示控制器回调
webView.presentViewControllerBlock = ^(UIViewController *viewController) {
    [self presentViewController:viewController animated:YES completion:nil];
};

// 移除观察者回调
webView.removeProgressObserverBlock = ^() {
    // 清理 KVO 观察者
};
```

### 3. LWWKUserContentController

一个单例的 WKUserContentController，用于管理用户脚本和消息处理器。

#### 主要特性

- **单例模式** - 全局共享配置
- **默认脚本注入** - 自动注入禁用长按菜单的脚本
- **消息处理器管理** - 统一管理 JavaScript 消息处理器

#### 使用方法

```objective-c
LWWKUserContentController *userContentController = [LWWKUserContentController shareInstance];

// 添加自定义脚本
NSString *jsCode = @"console.log('Hello from native!');";
WKUserScript *script = [[WKUserScript alloc] initWithSource:jsCode
                                              injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                           forMainFrameOnly:NO];
[userContentController addUserScript:script];

// 添加消息处理器
[userContentController addScriptMessageHandler:self name:@"myMessageHandler"];
```

### 4. UIResponder 扩展

#### lwwk_openURLWithUrl:

在响应链中查找能够打开 URL 的对象并打开 URL，兼容 iOS 10+ 和旧版本。

```objective-c
[self.view lwwk_openURLWithUrl:[NSURL URLWithString:@"https://www.apple.com"]];
[self.view lwwk_openURLWithUrl:[NSURL URLWithString:@"tel://10086"]];
```

### 5. 内置活动控件

#### LWWebViewMoreActivity

提供"在 Safari 中打开"功能的自定义活动控件。

#### LWPDFPrintActivity

提供"导出 PDF"功能的自定义活动控件，支持：
- 自动根据 iPad/iPhone 调整纸张大小
- 使用网页标题作为 PDF 文件名
- 自动过滤文件名中的非法字符

## 高级功能

### Cookie 管理

LWWebUI 提供了完整的 Cookie 管理方案，自动处理 iOS 11+ 的异步 Cookie API 和旧版本的同步 API。

**iOS 11+ Cookie 管理**

```objective-c
// 获取所有 Cookie
[[[WKWebsiteDataStore defaultDataStore] httpCookieStore] getAllCookies:^(NSArray<NSHTTPCookie *> *cookies) {
    for (NSHTTPCookie *cookie in cookies) {
        NSLog(@"Cookie: %@", cookie);
    }
}];

// 设置 Cookie
NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:@{
    NSHTTPCookieName: @"key",
    NSHTTPCookieValue: @"value",
    NSHTTPCookieDomain: @"example.com",
    NSHTTPCookiePath: @"/"
}];
[[[WKWebsiteDataStore defaultDataStore] httpCookieStore] setCookie:cookie completionHandler:^{
    NSLog(@"Cookie 设置完成");
}];
```

**iOS 11 以下版本**

```objective-c
[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
```

### 网络连接状态监控

使用内置的 LWWKReachability 类进行网络状态监控：

```objective-c
LWWKReachability *reachability = [LWWKReachability reachabilityForInternetConnection];
LWWKNetworkStatus networkStatus = [reachability currentReachabilityStatus];

switch (networkStatus) {
    case NotReachable:
        NSLog(@"无网络连接");
        break;
    case ReachableViaWiFi:
        NSLog(@"WiFi 连接");
        break;
    case ReachableViaWWAN:
        NSLog(@"蜂窝网络连接");
        break;
}

// 开始监听
[reachability startNotifier];

// 设置回调
reachability.reachableBlock = ^(LWWKReachability *reachability) {
    NSLog(@"网络可用");
};

reachability.unreachableBlock = ^(LWWKReachability *reachability) {
    NSLog(@"网络不可用");
};
```

### JavaScript 与原生交互

#### 原生调用 JavaScript

```objective-c
// 异步调用
[webView evaluateJavaScript:@"document.title" completionHandler:^(id result, NSError *error) {
    NSLog(@"页面标题: %@", result);
}];

// 同步调用（LWWKWebView 提供）
NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
```

#### JavaScript 调用原生

在 JavaScript 中：

```javascript
// 返回上一页
window.webkit.messageHandlers.webViewBack.postMessage(null);

// 刷新页面
window.webkit.messageHandlers.webViewReload.postMessage(null);
```

### URL Scheme 处理

LWWKWebView 自动处理多种 URL Scheme：

- **iTunes/App Store** - 自动识别并跳转到 App Store
- **电话** - `tel://` scheme 自动拨号
- **蒲公英分发** - `itms-services://` scheme 自动处理
- **自定义 Scheme** - 如 `lwinputmethod://`

### 错误页面处理

当网络错误或页面加载失败时，LWWKWebView 会自动显示友好的错误页面。错误页面位于 `LWWebUI/Assets/failedPage.html`。

### 进度条定制

LWWKWebViewController 提供的进度条可以通过访问 `webProgress` 属性进行定制：

```objective-c
webVC.webProgress.progressTintColor = [UIColor blueColor];
webVC.webProgress.trackTintColor = [UIColor lightGrayColor];
```

## 国际化支持

LWWebUI 支持多语言，目前包含：

- **英文** (en.lproj)
- **简体中文** (zh-Hans.lproj)

支持的本地化字符串：
- "Open in Safari" / "在 Safari 中打开"
- "Export PDF" / "导出 PDF"
- "Unable Open Web Page With NetWork Disconnected" / "网络未连接，无法打开网页"
- "HTTPS Certifcate Not Trust" / "HTTPS 证书不受信任"

## 调试

在 DEBUG 模式下，LWWebUI 提供详细的日志输出：

```objective-c
// 在 LWWKWebViewController.h 中定义
#ifdef DEBUG
#define LWWKLog(fmt, ...) NSLog((@"%s [Line %d]\n" fmt @"\n\n\n"), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define LWWKLog(...)
#endif

// 在 LWWKWebView.h 中定义
#ifdef DEBUG
#define MyLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define MyLog(format, ...)
#endif
```

## 常见问题

### 1. 如何处理自签名证书？

```objective-c
// 在 WKNavigationDelegate 的回调中
- (void)webView:(WKWebView *)webView
        didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
        completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {

    NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
}
```

### 2. 如何在 iPad 上正确显示分享菜单？

LWWebUI 已经处理了 iPad 的 popover 显示：

```objective-c
if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    UIPopoverController *popoverController = [[UIPopoverController alloc]
        initWithContentViewController:activityVC];
    CGRect rect = [[UIScreen mainScreen] bounds];
    [popoverController presentPopoverFromRect:rect
                                       inView:self.view
                     permittedArrowDirections:0
                                     animated:YES];
}
```

### 3. 如何禁用网页的长按菜单？

LWWKUserContentController 默认已经注入了禁用长按菜单的脚本：

```javascript
document.body.style.webkitTouchCallout='none';
```

### 4. 如何获取网页快照？

```objective-c
[webView snapshotWithHandler:^(CGImageRef imgRef) {
    UIImage *image = [UIImage imageWithCGImage:imgRef];
    // 保存或使用 image
}];
```

### 5. 如何实现多窗口 Cookie 共享？

LWWKWebView 使用共享的 WKProcessPool 实现多窗口 Cookie 共享：

```objective-c
static WKProcessPool *_pool;

+ (WKProcessPool *)pool {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _pool = [[WKProcessPool alloc] init];
    });
    return _pool;
}
```

## 运行示例项目

要运行示例项目，请按照以下步骤：

1. 克隆仓库到本地
```bash
git clone https://github.com/luowei/LWWebUI.git
cd LWWebUI
```

2. 进入 Example 目录并安装依赖
```bash
cd Example
pod install
```

3. 打开工作空间
```bash
open LWWebUI.xcworkspace
```

4. 运行项目

## 依赖库

- **Masonry** - 用于自动布局

## 版本历史

### 1.0.0
- 基于 WKWebView 的 WebView 容器
- LWWKWebViewController 完整功能
- LWWKWebView 增强功能
- Cookie 自动同步
- 网络状态检测
- 截图功能
- HTTPS 证书处理
- 分享和 PDF 导出

## 作者

**luowei**
邮箱: luowei@wodedata.com

## 许可证

LWWebUI 采用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

---

Copyright (c) 2019 luowei

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
