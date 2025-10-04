# LWWebUI Swift/SwiftUI Version

## Overview

This directory contains a complete Swift/SwiftUI reimplementation of the LWWebUI library, originally written in Objective-C. The Swift version maintains the same functionality while providing modern Swift APIs, SwiftUI support, and improved type safety.

## Files Created

### 1. LWWKReachability.swift (337 lines)
**Purpose**: Network reachability monitoring

**Original**: `/LWWebUI/Classes/Reachability/LWWKReachability.h` & `.m`

**Key Features**:
- Swift enum for network status (`LWWKNetworkStatus`)
- Modern closure-based callbacks instead of Objective-C blocks
- Type-safe API using Swift optionals
- Notification support via `NotificationCenter`

**Example**:
```swift
guard let reachability = LWWKReachability.reachabilityForInternetConnection() else {
    return
}

reachability.reachableBlock = { reachability in
    print("Network: \(reachability.currentReachabilityString)")
}

reachability.startNotifier()
```

---

### 2. LWWKWebView.swift (530 lines)
**Purpose**: Enhanced WKWebView wrapper with additional functionality

**Original**: `/LWWebUI/Classes/LWWKWebView.h` & `.m`

**Key Features**:
- Full Swift WKWebView subclass
- Closure-based callbacks for navigation events
- JavaScript execution support
- Network status integration
- HTTPS certificate handling
- Custom user agent management
- Snapshot/screenshot functionality
- Built-in error page handling

**Example**:
```swift
let configuration = WKWebViewConfiguration()
configuration.userContentController = LWWKUserContentController.shared

let webView = LWWKWebView(frame: .zero, configuration: configuration)

webView.finishNavigationProgressBlock = {
    print("Navigation completed")
}

webView.presentViewControllerBlock = { viewController in
    self.present(viewController, animated: true)
}

webView.load(URLRequest(url: url))
```

---

### 3. LWWKWebViewController.swift (489 lines)
**Purpose**: Ready-to-use web view controller with progress bar and controls

**Original**: `/LWWebUI/Classes/LWWKWebViewController.h` & `.m`

**Key Features**:
- Complete UIViewController implementation
- Built-in progress bar
- Share sheet with Safari and PDF export options
- KVO-based progress monitoring
- Modal presentation detection
- Custom activity classes for sharing

**Example**:
```swift
let url = URL(string: "https://www.apple.com")!
let webViewController = LWWKWebViewController.loadURL(url)
navigationController?.pushViewController(webViewController, animated: true)
```

---

### 4. LWWebView+SwiftUI.swift (423 lines)
**Purpose**: SwiftUI wrappers for modern declarative UI

**Key Features**:
- `LWWebView`: SwiftUI view wrapping LWWKWebView
- `LWWebViewController`: SwiftUI view wrapping LWWKWebViewController
- State bindings for progress, loading, navigation
- `LWWebViewModel`: ObservableObject for advanced usage
- `LWAdvancedWebView`: Pre-built view with controls
- View modifiers for sheet presentation

**Example**:
```swift
struct ContentView: View {
    @State private var isLoading = false
    @State private var progress: Double = 0
    @State private var title = ""

    var body: some View {
        VStack {
            if isLoading {
                ProgressView(value: progress)
            }

            LWWebView(
                url: URL(string: "https://www.apple.com")!,
                isLoading: $isLoading,
                progress: $progress,
                title: $title
            )
        }
        .navigationTitle(title)
    }
}
```

---

### 5. LWWebUI+Examples.swift (429 lines)
**Purpose**: Comprehensive usage examples and documentation

**Contains**:
- UIKit examples (7 different use cases)
- SwiftUI examples (7 different views)
- Inline documentation
- Code snippets
- Best practices

---

## API Comparison

### Objective-C → Swift

#### Loading a URL
**Objective-C**:
```objc
NSURL *url = [NSURL URLWithString:@"https://www.apple.com"];
LWWKWebViewController *vc = [LWWKWebViewController loadURL:url];
[self.navigationController pushViewController:vc animated:YES];
```

**Swift**:
```swift
let url = URL(string: "https://www.apple.com")!
let vc = LWWKWebViewController.loadURL(url)
navigationController?.pushViewController(vc, animated: true)
```

#### Network Reachability
**Objective-C**:
```objc
LWWKReachability *reachability = [LWWKReachability reachabilityForInternetConnection];
reachability.reachableBlock = ^(LWWKReachability *reachability) {
    NSLog(@"Network available");
};
[reachability startNotifier];
```

**Swift**:
```swift
guard let reachability = LWWKReachability.reachabilityForInternetConnection() else {
    return
}
reachability.reachableBlock = { reachability in
    print("Network available")
}
reachability.startNotifier()
```

#### WebView Callbacks
**Objective-C**:
```objc
self.wkWebView.finishNavigationProgressBlock = ^() {
    NSLog(@"Navigation finished");
};
```

**Swift**:
```swift
wkWebView.finishNavigationProgressBlock = {
    print("Navigation finished")
}
```

---

## SwiftUI Integration

### Basic Usage
```swift
import SwiftUI

struct WebContentView: View {
    var body: some View {
        LWWebView(url: URL(string: "https://www.apple.com")!)
            .navigationTitle("Apple")
    }
}
```

### With Progress Tracking
```swift
struct WebContentView: View {
    @State private var isLoading = false
    @State private var progress: Double = 0
    @State private var title = ""

    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                ProgressView(value: progress, total: 1.0)
                    .progressViewStyle(.linear)
            }

            LWWebView(
                url: URL(string: "https://www.github.com")!,
                isLoading: $isLoading,
                progress: $progress,
                title: $title
            )
        }
        .navigationTitle(title)
    }
}
```

### Sheet Presentation
```swift
struct ContentView: View {
    @State private var showWebView = false

    var body: some View {
        Button("Open Web Page") {
            showWebView = true
        }
        .lwWebSheet(
            isPresented: $showWebView,
            url: URL(string: "https://www.apple.com")!
        )
    }
}
```

### Advanced with Controls
```swift
struct ContentView: View {
    var body: some View {
        NavigationView {
            LWAdvancedWebView(url: URL(string: "https://www.apple.com")!)
        }
    }
}
```

---

## Features

### Maintained from Objective-C Version
- ✅ WKWebView integration
- ✅ Progress tracking
- ✅ Network reachability monitoring
- ✅ HTTPS certificate handling (12306.cn support)
- ✅ PDF export functionality
- ✅ Share to Safari functionality
- ✅ Custom user agent
- ✅ JavaScript execution
- ✅ Cookie synchronization
- ✅ Failed page handling
- ✅ iTunes/App Store link handling
- ✅ Phone call link handling

### New Swift/SwiftUI Features
- ✅ Type-safe Swift API
- ✅ SwiftUI view wrappers
- ✅ @State bindings for reactive UI
- ✅ ObservableObject support
- ✅ Combine framework compatibility
- ✅ Modern Swift concurrency ready
- ✅ Automatic memory management
- ✅ Swift optionals for safety
- ✅ Closures instead of blocks
- ✅ Protocol-oriented design

---

## Migration Guide

### For UIKit Projects

**Step 1**: Import the Swift files into your project

**Step 2**: Replace Objective-C imports
```swift
// Remove
#import "LWWKWebViewController.h"

// Add
import LWWebUI // or just use the classes directly
```

**Step 3**: Update your code
```swift
// Old (Objective-C style)
let vc = LWWKWebViewController.loadURL(url)

// New (same in Swift!)
let vc = LWWKWebViewController.loadURL(url)
```

### For SwiftUI Projects

**Step 1**: Import SwiftUI support
```swift
import SwiftUI
```

**Step 2**: Use SwiftUI views
```swift
struct MyWebView: View {
    var body: some View {
        LWWebView(url: URL(string: "https://www.apple.com")!)
    }
}
```

---

## Platform Support

- **iOS Deployment Target**: 13.0+ (for SwiftUI), 8.0+ (for UIKit)
- **Swift Version**: 5.0+
- **Xcode**: 13.0+

---

## File Structure

```
LWWebUI/SwiftClasses/
├── LWWKReachability.swift          # Network reachability
├── LWWKWebView.swift                # WebView wrapper
├── LWWKWebViewController.swift      # UIKit view controller
├── LWWebView+SwiftUI.swift          # SwiftUI wrappers
├── LWWebUI+Examples.swift           # Usage examples
└── SWIFT_VERSION_SUMMARY.md         # This file
```

---

## Dependencies

Same as Objective-C version:
- WebKit framework
- SystemConfiguration framework
- UIKit framework
- SwiftUI framework (iOS 13.0+)

CocoaPods dependency:
- Masonry (for UIKit version)
- Note: SwiftUI version uses native Auto Layout constraints

---

## Code Statistics

- **Total Lines**: 2,208 lines of Swift code
- **5 Swift Files**:
  - LWWKReachability.swift: 337 lines
  - LWWKWebView.swift: 530 lines
  - LWWKWebViewController.swift: 489 lines
  - LWWebView+SwiftUI.swift: 423 lines
  - LWWebUI+Examples.swift: 429 lines

---

## Testing

### UIKit Testing
```swift
func testWebViewController() {
    let url = URL(string: "https://www.apple.com")!
    let vc = LWWKWebViewController.loadURL(url)

    XCTAssertNotNil(vc.wkWebView)
    XCTAssertEqual(vc.webURL, url)
}
```

### SwiftUI Testing
```swift
func testSwiftUIWebView() {
    let view = LWWebView(url: URL(string: "https://www.apple.com")!)
    XCTAssertNotNil(view)
}
```

---

## License

Same as the original LWWebUI library - MIT License

Copyright (c) 2025 luowei. All rights reserved.

---

## Notes

1. **No Objective-C Bridge Required**: These are pure Swift implementations, not Objective-C wrappers
2. **API Compatibility**: Public API maintains similar structure to Objective-C version
3. **Modern Swift**: Uses latest Swift features like Result types, optionals, and closures
4. **SwiftUI First**: New SwiftUI APIs designed for declarative UI
5. **Backward Compatible**: UIKit version works alongside Objective-C code

---

## Next Steps

### For Library Maintainers
1. Add to CocoaPods spec (Swift version)
2. Create Swift Package Manager support
3. Add unit tests
4. Create demo app showing both UIKit and SwiftUI usage
5. Update documentation

### For Users
1. Review examples in `LWWebUI+Examples.swift`
2. Choose UIKit or SwiftUI based on your project
3. Integrate into your app
4. Report issues and contribute improvements

---

## Contact

For issues, questions, or contributions, please refer to the main LWWebUI repository.
