//
// LWWebUI+Examples.swift
// LWWebUI
//
// Usage examples for Swift/SwiftUI version
// Copyright (c) 2025 luowei. All rights reserved.
//

import SwiftUI
import UIKit

// MARK: - UIKit Examples

public class LWWebUIKitExamples {

    // MARK: - Example 1: Basic URL Loading with UIKit

    public static func basicURLExample() -> LWWKWebViewController {
        // Load a URL
        let url = URL(string: "https://www.apple.com")!
        let webViewController = LWWKWebViewController.loadURL(url)
        return webViewController
    }

    // MARK: - Example 2: Load HTML String

    public static func htmlStringExample() -> LWWKWebViewController {
        let htmlString = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body { font-family: -apple-system; padding: 20px; }
                h1 { color: #007AFF; }
            </style>
        </head>
        <body>
            <h1>Hello from LWWebUI</h1>
            <p>This is a Swift/SwiftUI version of LWWebUI library.</p>
        </body>
        </html>
        """

        let webViewController = LWWKWebViewController.loadHTMLString(htmlString, baseURL: nil)
        return webViewController
    }

    // MARK: - Example 3: Custom WebView Configuration

    public static func customWebViewExample() -> LWWKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = LWWKUserContentController.shared

        let webView = LWWKWebView(frame: .zero, configuration: configuration)

        // Set up callbacks
        webView.finishNavigationProgressBlock = {
            print("Navigation finished!")
        }

        webView.presentViewControllerBlock = { viewController in
            // Handle presenting view controller
            print("Need to present: \(viewController)")
        }

        return webView
    }

    // MARK: - Example 4: Network Reachability

    public static func reachabilityExample() {
        guard let reachability = LWWKReachability.reachabilityForInternetConnection() else {
            print("Failed to create reachability")
            return
        }

        // Set up callbacks
        reachability.reachableBlock = { reachability in
            print("Network is reachable: \(reachability.currentReachabilityString)")
        }

        reachability.unreachableBlock = { reachability in
            print("Network is unreachable")
        }

        // Start monitoring
        reachability.startNotifier()

        // Check current status
        if reachability.isReachable {
            if reachability.isReachableViaWiFi {
                print("Connected via WiFi")
            } else if reachability.isReachableViaWWAN {
                print("Connected via Cellular")
            }
        } else {
            print("No connection")
        }
    }
}

// MARK: - SwiftUI Examples

@available(iOS 13.0, *)
public struct LWWebUISwiftUIExamples {

    // MARK: - Example 1: Basic SwiftUI WebView

    public struct BasicWebViewExample: View {
        public var body: some View {
            NavigationView {
                LWWebView(url: URL(string: "https://www.apple.com")!)
                    .navigationTitle("Apple")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    // MARK: - Example 2: WebView with Progress and Controls

    public struct WebViewWithProgressExample: View {
        @State private var isLoading = false
        @State private var progress: Double = 0
        @State private var title = ""
        @State private var canGoBack = false
        @State private var canGoForward = false

        public var body: some View {
            NavigationView {
                VStack(spacing: 0) {
                    if isLoading {
                        ProgressView(value: progress, total: 1.0)
                            .progressViewStyle(.linear)
                    }

                    LWWebView(
                        url: URL(string: "https://www.github.com")!,
                        isLoading: $isLoading,
                        progress: $progress,
                        title: $title,
                        canGoBack: $canGoBack,
                        canGoForward: $canGoForward
                    )
                }
                .navigationTitle(title.isEmpty ? "Loading..." : title)
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    // MARK: - Example 3: WebView with Sheet Presentation

    public struct WebViewSheetExample: View {
        @State private var showWebView = false

        public var body: some View {
            Button("Open Web Page") {
                showWebView = true
            }
            .lwWebSheet(
                isPresented: $showWebView,
                url: URL(string: "https://www.apple.com")!
            )
        }
    }

    // MARK: - Example 4: Advanced WebView with Controls

    public struct AdvancedWebViewExample: View {
        public var body: some View {
            NavigationView {
                LWAdvancedWebView(url: URL(string: "https://www.apple.com")!)
            }
        }
    }

    // MARK: - Example 5: HTML String Loading

    public struct HTMLStringExample: View {
        private let htmlString = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
                    padding: 20px;
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    color: white;
                }
                .container {
                    background: rgba(255, 255, 255, 0.1);
                    border-radius: 10px;
                    padding: 20px;
                    backdrop-filter: blur(10px);
                }
                h1 { margin-top: 0; }
                .feature {
                    background: rgba(255, 255, 255, 0.2);
                    padding: 15px;
                    margin: 10px 0;
                    border-radius: 5px;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>🚀 LWWebUI Swift Version</h1>
                <p>A modern Swift/SwiftUI wrapper for WKWebView</p>

                <div class="feature">
                    <h3>✨ Features</h3>
                    <ul>
                        <li>Full Swift implementation</li>
                        <li>SwiftUI support</li>
                        <li>Progress tracking</li>
                        <li>PDF export</li>
                        <li>Network reachability</li>
                    </ul>
                </div>

                <div class="feature">
                    <h3>📱 Platform Support</h3>
                    <p>iOS 13.0+ for SwiftUI, iOS 8.0+ for UIKit</p>
                </div>
            </div>
        </body>
        </html>
        """

        public var body: some View {
            NavigationView {
                LWWebView(htmlString: htmlString)
                    .navigationTitle("HTML Content")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    // MARK: - Example 6: WebView with Navigation Callbacks

    public struct WebViewWithCallbacksExample: View {
        @State private var isLoading = false
        @State private var progress: Double = 0
        @State private var title = ""
        @State private var errorMessage: String?
        @State private var showError = false

        public var body: some View {
            NavigationView {
                VStack(spacing: 0) {
                    if isLoading {
                        ProgressView(value: progress, total: 1.0)
                            .progressViewStyle(.linear)
                    }

                    LWWebView(
                        url: URL(string: "https://www.apple.com")!,
                        isLoading: $isLoading,
                        progress: $progress,
                        title: $title,
                        onNavigationFinished: {
                            print("✅ Navigation finished successfully")
                        },
                        onNavigationFailed: { error in
                            print("❌ Navigation failed: \(error.localizedDescription)")
                            errorMessage = error.localizedDescription
                            showError = true
                        }
                    )
                }
                .navigationTitle(title.isEmpty ? "Loading..." : title)
                .navigationBarTitleDisplayMode(.inline)
                .alert("Navigation Error", isPresented: $showError) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(errorMessage ?? "Unknown error occurred")
                }
            }
        }
    }

    // MARK: - Example 7: Multiple WebViews with TabView

    public struct MultipleWebViewsExample: View {
        public var body: some View {
            TabView {
                LWWebViewExample(url: URL(string: "https://www.apple.com")!)
                    .tabItem {
                        Label("Apple", systemImage: "apple.logo")
                    }

                LWWebViewExample(url: URL(string: "https://www.github.com")!)
                    .tabItem {
                        Label("GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                    }

                LWWebViewExample(url: URL(string: "https://www.swift.org")!)
                    .tabItem {
                        Label("Swift", systemImage: "swift")
                    }
            }
        }
    }
}

// MARK: - Usage Documentation

/*
 # LWWebUI Swift/SwiftUI Usage Guide

 ## UIKit Usage

 ### Basic URL Loading
 ```swift
 let url = URL(string: "https://www.apple.com")!
 let webViewController = LWWKWebViewController.loadURL(url)
 navigationController?.pushViewController(webViewController, animated: true)
 ```

 ### Load HTML String
 ```swift
 let html = "<html><body><h1>Hello</h1></body></html>"
 let webViewController = LWWKWebViewController.loadHTMLString(html, baseURL: nil)
 present(webViewController, animated: true)
 ```

 ### Custom WebView
 ```swift
 let configuration = WKWebViewConfiguration()
 configuration.userContentController = LWWKUserContentController.shared

 let webView = LWWKWebView(frame: view.bounds, configuration: configuration)
 webView.finishNavigationProgressBlock = {
     print("Loading finished")
 }
 view.addSubview(webView)
 webView.load(URLRequest(url: url))
 ```

 ## SwiftUI Usage

 ### Basic WebView
 ```swift
 struct ContentView: View {
     var body: some View {
         LWWebView(url: URL(string: "https://www.apple.com")!)
     }
 }
 ```

 ### WebView with Progress
 ```swift
 struct ContentView: View {
     @State private var isLoading = false
     @State private var progress: Double = 0

     var body: some View {
         VStack {
             if isLoading {
                 ProgressView(value: progress)
             }
             LWWebView(
                 url: URL(string: "https://www.apple.com")!,
                 isLoading: $isLoading,
                 progress: $progress
             )
         }
     }
 }
 ```

 ### WebView in Sheet
 ```swift
 struct ContentView: View {
     @State private var showWeb = false

     var body: some View {
         Button("Open") {
             showWeb = true
         }
         .lwWebSheet(isPresented: $showWeb, url: URL(string: "https://www.apple.com")!)
     }
 }
 ```

 ### Advanced WebView with Controls
 ```swift
 struct ContentView: View {
     var body: some View {
         LWAdvancedWebView(url: URL(string: "https://www.apple.com")!)
     }
 }
 ```

 ## Network Reachability

 ```swift
 guard let reachability = LWWKReachability.reachabilityForInternetConnection() else {
     return
 }

 reachability.reachableBlock = { reachability in
     print("Network available: \(reachability.currentReachabilityString)")
 }

 reachability.unreachableBlock = { _ in
     print("Network unavailable")
 }

 reachability.startNotifier()
 ```

 ## Features

 - ✅ Full Swift implementation
 - ✅ SwiftUI support with @State bindings
 - ✅ Progress tracking
 - ✅ PDF export functionality
 - ✅ Network reachability monitoring
 - ✅ JavaScript execution
 - ✅ Custom user agents
 - ✅ HTTPS certificate handling
 - ✅ Navigation callbacks
 - ✅ Share functionality (Safari, PDF)

 */
