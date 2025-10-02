# LWWebUI

[![CI Status](https://img.shields.io/travis/luowei/libLWWebUI.svg?style=flat)](https://travis-ci.org/luowei/libLWWebUI)
[![Version](https://img.shields.io/cocoapods/v/libLWWebUI.svg?style=flat)](https://cocoapods.org/pods/libLWWebUI)
[![License](https://img.shields.io/cocoapods/l/libLWWebUI.svg?style=flat)](https://cocoapods.org/pods/libLWWebUI)
[![Platform](https://img.shields.io/cocoapods/p/libLWWebUI.svg?style=flat)](https://cocoapods.org/pods/libLWWebUI)

[English](./README.md) | [中文版](./README_ZH.md)

---

## Overview

LWWebUI is a powerful and easy-to-use WKWebView wrapper library for iOS, providing enhanced functionality including cookie synchronization, progress tracking, PDF export, and rich UI components. It offers a complete solution for integrating web content into iOS applications with minimal configuration.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Core Components](#core-components)
- [Usage Examples](#usage-examples)
- [API Reference](#api-reference)
- [Advanced Features](#advanced-features)
- [Cookie Management](#cookie-management)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)
- [Author](#author)

## Features

### Core Capabilities

- **Modern WKWebView Integration**: Built on iOS 8.0+ WKWebView technology with full navigation support
- **Automatic Cookie Synchronization**: Seamless cookie sync between NSHTTPCookieStorage and WKWebView (iOS 11+ and legacy support)
- **Progress Tracking**: Smooth animated progress bar with KVO-based loading state monitoring
- **PDF Export**: Export web content to PDF with customizable paper sizes (A3, A4, A5, A6)
- **Safari Integration**: Quick action to open current page in Safari browser
- **Network Status Detection**: Real-time network connectivity monitoring with automatic error handling
- **HTTPS Certificate Handling**: Support for custom HTTPS certificates including special domains (e.g., 12306.cn)

### Advanced Features

- **JavaScript Bridge**: Built-in script message handlers for bidirectional native-web communication
- **User Agent Customization**: Dynamic user agent switching between iOS and Mac modes
- **Snapshot Support**: Programmatic web page screenshot capture with custom handlers
- **Multi-window Cookie Sharing**: Shared WKProcessPool for consistent cookies across instances
- **Back/Forward Gestures**: Native swipe gestures for intuitive navigation
- **Activity View Integration**: System share sheet integration with custom activities
- **Auto Layout Support**: Full Masonry integration for responsive layouts
- **Error Handling**: Custom error pages for network failures and certificate issues
- **Localization Support**: Built-in English and Simplified Chinese localization

## Requirements

- **iOS**: 9.0 or later
- **Xcode**: 8.0 or later
- **Dependencies**: Masonry (for Auto Layout)
- **Language**: Objective-C

## Installation

LWWebUI can be integrated into your project using CocoaPods or Carthage.

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. To install LWWebUI, add the following line to your `Podfile`:

```ruby
pod 'LWWebUI'
```

Then run:

```bash
pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager. To integrate LWWebUI using Carthage, add the following to your `Cartfile`:

```ruby
github "luowei/LWWebUI"
```

Then run:

```bash
carthage update
```

### Manual Installation

You can also manually integrate LWWebUI by:

1. Cloning this repository
2. Dragging the `LWWebUI` folder into your Xcode project
3. Ensuring Masonry is also included in your project

## Quick Start

Here's a minimal example to get you started with LWWebUI:

```objective-c
#import <LWWebUI/LWWKWebViewController.h>

// Create and present a web view controller
LWWKWebViewController *webVC = [LWWKWebViewController wkWebViewControllerWithURL:
                                [NSURL URLWithString:@"https://www.example.com"]];
UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webVC];
[self presentViewController:nav animated:YES completion:nil];
```

That's it! This single line creates a fully-featured web browser with:
- Loading progress bar
- Share functionality (Safari, PDF export)
- Automatic title updates
- Back/forward navigation support
- Cookie management
- Error handling

## Core Components

LWWebUI provides three main components that work together to deliver a complete web browsing solution:

### 1. LWWKWebViewController

A fully-featured web browsing view controller that provides an out-of-the-box web browser experience.

**Key Features:**
- **Progress Bar**: Smooth loading progress indicator at the top of the screen
- **Navigation Bar Integration**: Built-in share button with Safari and PDF export options
- **Automatic Title Updates**: Dynamically updates navigation title from web page
- **Modal Presentation Support**: Automatically displays close button when presented modally
- **KVO-Based Tracking**: Observes loading progress and title changes using Key-Value Observing
- **Flexible Initialization**: Multiple convenient initializers for different use cases
- **Memory Management**: Proper cleanup of observers and delegates

**Ideal Use Cases:**
- Quick web content display without custom UI
- In-app browser for external links
- OAuth/authentication flows
- Help and documentation pages
- Terms of service/privacy policy display

### 2. LWWKWebView

An enhanced WKWebView subclass with powerful features for modern iOS apps.

**Core Features:**
- **Network Status Detection**: Real-time network connectivity monitoring with visual feedback
- **Automatic Cookie Synchronization**: Seamless cookie injection for both iOS 11+ and legacy versions
- **JavaScript Bridge**: Built-in message handlers for native-web communication
- **Custom Error Pages**: User-friendly error display for network failures
- **HTTPS Certificate Handling**: Support for custom certificates (e.g., 12306.cn)
- **Snapshot/Screenshot**: Capture web page screenshots programmatically
- **Synchronous JS Execution**: Convenient synchronous JavaScript evaluation method
- **User Agent Control**: Dynamic switching between iOS and Mac user agents
- **Process Pool Sharing**: Multi-window cookie sharing via shared WKProcessPool

**Advanced Capabilities:**
- Custom URL scheme handling (tel://, itms-services://, custom schemes)
- Automatic App Store link detection and opening
- Network disconnection error handling
- Request header cookie injection for iOS 10 and below
- Block-based callbacks for flexibility

### 3. LWWKUserContentController

A singleton user content controller for managing scripts and message handlers.

**Features:**
- **Singleton Pattern**: Global shared configuration for consistency
- **Default Script Injection**: Automatically injects useful scripts (e.g., disabling long-press menu)
- **Message Handler Management**: Centralized JavaScript-to-native communication
- **Built-in Handlers**: Pre-configured handlers for back navigation and reload

### 4. Custom Activity Components

Pre-built `UIActivity` subclasses for common web actions:

**LWWebViewMoreActivity**
- Open current page in Safari browser
- Handles iOS 10+ and legacy URL opening APIs
- Localized "Open in Safari" title

**LWPDFPrintActivity**
- Export web page to PDF
- Multiple paper size support (A3, A4, A5, A6)
- Automatic size selection based on device type
- Uses web page title as PDF filename
- Localized "Export PDF" title

## Usage Examples

### Basic Usage

#### Simple URL Loading

```objective-c
// Load a URL in a web view controller
LWWKWebViewController *webVC = [LWWKWebViewController wkWebViewControllerWithURL:
                                [NSURL URLWithString:@"https://www.apple.com"]];
UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webVC];
[self presentViewController:nav animated:YES completion:nil];
```

#### Push to Navigation Stack

```objective-c
LWWKWebViewController *webVC = [LWWKWebViewController wkWebViewControllerWithURL:
                                [NSURL URLWithString:@"https://www.apple.com"]];
[self.navigationController pushViewController:webVC animated:YES];
```

#### Load HTML String

```objective-c
NSString *htmlString = @"<html><body><h1>Hello World</h1></body></html>";
LWWKWebViewController *webVC = [LWWKWebViewController loadHTMLString:htmlString baseURL:nil];
[self.navigationController pushViewController:webVC animated:YES];
```

### Custom LWWKWebView Usage

```objective-c
// Configure WKWebView
WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
configuration.userContentController = [LWWKUserContentController shareInstance];

// Create custom web view
LWWKWebView *webView = [[LWWKWebView alloc] initWithFrame:self.view.bounds
                                            configuration:configuration];

// Set up callbacks
webView.finishNavigationProgressBlock = ^{
    NSLog(@"Page loaded successfully");
};

// Add to view hierarchy
[self.view addSubview:webView];

// Load URL
NSURL *url = [NSURL URLWithString:@"https://www.apple.com"];
NSURLRequest *request = [NSURLRequest requestWithURL:url];
[webView loadRequest:request];
```

### JavaScript Execution

```objective-c
// Synchronous JavaScript execution
NSString *result = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];

// Asynchronous JavaScript execution
[webView evaluateJavaScript:@"document.body.innerHTML" completionHandler:^(id result, NSError *error) {
    if (!error) {
        NSLog(@"Result: %@", result);
    }
}];
```

### Snapshot/Screenshot

```objective-c
// Save to photo album
[webView snapshotWebView];

// Custom handler
[webView snapshotWithHandler:^(CGImageRef imgRef) {
    UIImage *image = [UIImage imageWithCGImage:imgRef];
    // Do something with the image
}];
```

### Progress Handling

```objective-c
LWWKWebViewController *webVC = [LWWKWebViewController wkWebViewControllerWithURL:url];
webVC.wkWebView.finishNavigationProgressBlock = ^{
    NSLog(@"Navigation finished");
};
[self.navigationController pushViewController:webVC animated:YES];
```

## Cookie Management

### Overview

LWWebUI provides comprehensive cookie management that automatically handles differences between iOS 11+ and earlier versions. The library uses method swizzling on WKWebView to automatically inject cookies from NSHTTPCookieStorage into each request's headers, ensuring seamless cookie synchronization across all iOS versions.

### iOS Version Compatibility

**iOS 11+**: Async API with WKHTTPCookieStore
- Uses dispatch groups for proper async handling
- Ensures cookies are set before page load
- Supports cookie observation and change notifications

**iOS 10 and below**: Sync API with NSHTTPCookieStorage
- Immediate cookie availability
- Automatic injection via HTTP headers
- No async handling required

### Creating Cookies

```objective-c
// Helper method to create a cookie
- (NSHTTPCookie *)cookieWithCookieDomain:(NSString *)cookieDomain
                              cookieName:(NSString *)cookieName
                             cookieValue:(NSString *)cookieValue {
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    properties[NSHTTPCookieName] = cookieName;
    properties[NSHTTPCookieValue] = cookieValue;
    properties[NSHTTPCookieDomain] = cookieDomain;
    properties[NSHTTPCookiePath] = @"/";
    properties[NSHTTPCookieMaximumAge] = @"86400";  // 1 day

    return [[NSHTTPCookie alloc] initWithProperties:properties];
}

// Setup cookies helper
- (void)setupCookies {
    NSHTTPCookie *sessionCookie = [self cookieWithCookieDomain:@"example.com"
                                                    cookieName:@"sessionId"
                                                   cookieValue:@"abc123"];
    NSHTTPCookie *userCookie = [self cookieWithCookieDomain:@"example.com"
                                                 cookieName:@"userId"
                                                cookieValue:@"user001"];

    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:sessionCookie];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:userCookie];
}
```

### iOS 11+ Cookie Management with Async API

```objective-c
if (@available(iOS 11.0, *)) {
    dispatch_group_t group = dispatch_group_create();
    WKHTTPCookieStore *cookieStore = [[WKWebsiteDataStore defaultDataStore] httpCookieStore];

    // Step 1: Clear all existing cookies
    [cookieStore getAllCookies:^(NSArray<NSHTTPCookie *> *cookies) {
        for (NSHTTPCookie *cookie in cookies) {
            dispatch_group_enter(group);
            [cookieStore deleteCookie:cookie completionHandler:^{
                dispatch_group_leave(group);
            }];
        }
    }];

    // Step 2: Wait for deletion, then add new cookies and load page
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // Add cookies to NSHTTPCookieStorage (for automatic injection)
        [self setupCookies];

        // Create and present web view controller
        LWWKWebViewController *webVC = [LWWKWebViewController wkWebViewControllerWithURL:
                                        [NSURL URLWithString:@"https://www.example.com"]];
        UINavigationController *nav = [[UINavigationController alloc]
                                       initWithRootViewController:webVC];
        [self presentViewController:nav animated:YES completion:nil];
    });
} else {
    // iOS 10 and below: Synchronous cookie management
    [self setupCookies];

    LWWKWebViewController *webVC = [LWWKWebViewController wkWebViewControllerWithURL:
                                    [NSURL URLWithString:@"https://www.example.com"]];
    UINavigationController *nav = [[UINavigationController alloc]
                                   initWithRootViewController:webVC];
    [self presentViewController:nav animated:YES completion:nil];
}
```

### Alternative: Direct WKHTTPCookieStore Usage (iOS 11+)

```objective-c
if (@available(iOS 11.0, *)) {
    WKHTTPCookieStore *cookieStore = [[WKWebsiteDataStore defaultDataStore] httpCookieStore];

    // Create cookie
    NSHTTPCookie *cookie = [self cookieWithCookieDomain:@"example.com"
                                             cookieName:@"token"
                                            cookieValue:@"xyz789"];

    // Set cookie directly in WKWebView's cookie store
    [cookieStore setCookie:cookie completionHandler:^{
        NSLog(@"Cookie set successfully");

        // Now load the page
        LWWKWebViewController *webVC = [LWWKWebViewController wkWebViewControllerWithURL:
                                        [NSURL URLWithString:@"https://www.example.com"]];
        [self.navigationController pushViewController:webVC animated:YES];
    }];
}
```

### Retrieving Cookies (iOS 11+)

```objective-c
if (@available(iOS 11.0, *)) {
    WKHTTPCookieStore *cookieStore = [[WKWebsiteDataStore defaultDataStore] httpCookieStore];

    [cookieStore getAllCookies:^(NSArray<NSHTTPCookie *> *cookies) {
        for (NSHTTPCookie *cookie in cookies) {
            NSLog(@"Cookie: %@ = %@ (Domain: %@)",
                  cookie.name, cookie.value, cookie.domain);
        }
    }];
}
```


## API Reference

### LWWKWebViewController

A fully-featured web view controller for displaying web content.

#### Class Methods

```objective-c
// Create a web view controller with URL
+ (LWWKWebViewController *)wkWebViewControllerWithURL:(NSURL *)url;

// Convenience method to create and load URL
+ (LWWKWebViewController *)loadURL:(NSURL *)url;

// Load HTML string
+ (LWWKWebViewController *)loadHTMLString:(NSString *)htmlString baseURL:(NSURL *)baseURL;
```

#### Instance Methods

```objective-c
// Load a URL
- (void)loadURL:(NSURL *)url;

// Load HTML content
- (void)loadHTMLString:(NSString *)htmlString baseURL:(NSURL *)baseURL;
```

#### Properties

```objective-c
// The WKWebView instance
@property (nonatomic, strong) LWWKWebView *wkWebView;

// Progress indicator
@property (strong, nonatomic) UIProgressView *webProgress;

// URL string
@property (nonatomic, copy) NSString *url;

// URL object
@property (nonatomic, strong) NSURL *webURL;
```

### LWWKWebView

Enhanced WKWebView subclass with additional features.

#### Instance Methods

```objective-c
// Synchronous JavaScript execution
- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)javascript;

// Check network connectivity
- (BOOL)connected;

// Allow HTTPS certificate for specific host
- (void)setAllowsHTTPSCertifcateWithCertChain:(NSArray *)certChain ForHost:(NSString *)host;

// Take screenshot and save to photo album
- (void)snapshotWebView;

// Take screenshot with custom handler
- (void)snapshotWithHandler:(void (^)(CGImageRef imgRef))completionHandler;
```

#### Properties

```objective-c
// Callback when navigation finishes
@property (nonatomic, copy) void (^finishNavigationProgressBlock)(void);

// Present view controller callback
@property (nonatomic, copy) void (^presentViewControllerBlock)(UIViewController *);

// Remove KVO observers callback
@property (nonatomic, copy) void (^removeProgressObserverBlock)(void);

// Screenshot image
@property (nonatomic, strong) UIImage *screenImage;

// Network status label
@property (nonatomic, strong) UILabel *netStatusLabel;
```

### LWWKUserContentController

Singleton user content controller for managing scripts and message handlers.

#### Class Methods

```objective-c
// Get shared instance
+ (instancetype)shareInstance;
```

#### Properties

```objective-c
// Registered message handlers
@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *handlerNames;
```

## Advanced Features

### Custom User Scripts

Inject custom JavaScript into web pages:

```objective-c
WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
LWWKUserContentController *contentController = [LWWKUserContentController shareInstance];

NSString *jsCode = @"document.body.style.backgroundColor = 'lightblue';";
WKUserScript *script = [[WKUserScript alloc] initWithSource:jsCode
                                              injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                           forMainFrameOnly:YES];
[contentController addUserScript:script];

configuration.userContentController = contentController;
LWWKWebView *webView = [[LWWKWebView alloc] initWithFrame:self.view.frame
                                            configuration:configuration];
```

### JavaScript Message Handlers

#### Built-in Handlers

The library provides pre-configured message handlers:

- `webViewBack` - Navigate back to previous page
- `webViewReload` - Reload current page

#### Calling from JavaScript

```javascript
// Navigate back
window.webkit.messageHandlers.webViewBack.postMessage(null);

// Reload page
window.webkit.messageHandlers.webViewReload.postMessage(null);
```

#### Custom Message Handlers

```objective-c
LWWKUserContentController *contentController = [LWWKUserContentController shareInstance];
[contentController addScriptMessageHandler:self name:@"myHandler"];

// Implement WKScriptMessageHandler protocol
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"myHandler"]) {
        NSLog(@"Received: %@", message.body);
    }
}
```

### Network Status Monitoring

LWWebUI uses LWWKReachability to monitor network status and automatically displays error messages when offline.

```objective-c
// Check network connectivity
BOOL isConnected = [webView connected];
if (!isConnected) {
    // Handle offline state
}
```

## Best Practices

### Memory Management

```objective-c
- (void)dealloc {
    // LWWKWebViewController automatically removes KVO observers
    // If using custom LWWKWebView, ensure proper cleanup
    if (self.wkWebView) {
        [self.wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
        [self.wkWebView removeObserver:self forKeyPath:@"title"];
        self.wkWebView.navigationDelegate = nil;
    }
}
```

### Cookie Security

```objective-c
- (NSHTTPCookie *)createSecureCookie:(NSString *)name
                               value:(NSString *)value
                              domain:(NSString *)domain {
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    properties[NSHTTPCookieName] = name;
    properties[NSHTTPCookieValue] = value;
    properties[NSHTTPCookieDomain] = domain;
    properties[NSHTTPCookiePath] = @"/";
    properties[NSHTTPCookieSecure] = @YES;  // HTTPS only
    properties[NSHTTPCookieMaximumAge] = @"3600";  // 1 hour

    return [[NSHTTPCookie alloc] initWithProperties:properties];
}
```

### Performance Optimization

1. **Reuse WKProcessPool**: LWWKWebView automatically uses a shared WKProcessPool for better performance and cookie sharing
2. **Lazy Load Web Views**: Create web view controllers only when needed
3. **Clear Cache Periodically**: For iOS 11+, clear website data when appropriate
4. **Optimize JavaScript Injection**: Inject scripts at appropriate times (Document Start vs Document End)

## Troubleshooting

### Cookies Not Syncing

**Problem**: Cookies are not being shared between native code and WKWebView.

**Solution**:
- Ensure cookies are set before loading the web view
- For iOS 11+, use dispatch groups to ensure async cookie operations complete before navigation
- Verify cookie domain matches the target URL domain

```objective-c
// iOS 11+ example
if (@available(iOS 11.0, *)) {
    WKHTTPCookieStore *cookieStore = [[WKWebsiteDataStore defaultDataStore] httpCookieStore];
    [cookieStore setCookie:cookie completionHandler:^{
        // Load web view AFTER cookie is set
        [webView loadRequest:request];
    }];
}
```

### HTTPS Certificate Errors

**Problem**: Custom HTTPS certificates are not being accepted.

**Solution**: Use the built-in certificate handling method:

```objective-c
[webView setAllowsHTTPSCertifcateWithCertChain:certChain ForHost:@"yourdomain.com"];
```

**Note**: The library automatically handles 12306.cn certificates.

### Progress Bar Not Showing

**Problem**: Loading progress bar is not visible.

**Solution**:
- Verify the progress bar is added to the view hierarchy
- Ensure Auto Layout constraints are properly set
- Check that `webProgress` property is not nil

### Memory Leaks with KVO

**Problem**: Memory leaks occur when deallocating web views.

**Solution**: Always remove KVO observers in `dealloc`:

```objective-c
- (void)dealloc {
    [self.wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.wkWebView removeObserver:self forKeyPath:@"title"];
}
```

**Note**: LWWKWebViewController handles this automatically.

## Example Project

To run the example project:

1. Clone the repository
   ```bash
   git clone https://github.com/luowei/LWWebUI.git
   cd LWWebUI
   ```

2. Install dependencies
   ```bash
   cd Example
   pod install
   ```

3. Open the workspace
   ```bash
   open LWWebUI.xcworkspace
   ```

4. Build and run the project in Xcode

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Guidelines

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

LWWebUI is available under the MIT License. See the [LICENSE](LICENSE) file for more information.

```
MIT License

Copyright (c) 2019 luowei

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## Author

**luowei**
Email: luowei@wodedata.com

## Acknowledgments

- Built with [Masonry](https://github.com/SnapKit/Masonry) for Auto Layout
- Inspired by the need for a modern, easy-to-use WKWebView wrapper

---

**Star this repository if you find it helpful!**
