//
// LWWebView+SwiftUI.swift
// LWWebUI
//
// SwiftUI wrapper for LWWKWebView
// Copyright (c) 2025 luowei. All rights reserved.
//

import SwiftUI
import WebKit
import Combine

// MARK: - WebView SwiftUI Wrapper

@available(iOS 13.0, *)
public struct LWWebView: UIViewRepresentable {

    // MARK: - Types

    public enum LoadType {
        case url(URL)
        case htmlString(String, baseURL: URL?)
    }

    // MARK: - Properties

    private let loadType: LoadType
    @Binding private var isLoading: Bool
    @Binding private var progress: Double
    @Binding private var title: String
    @Binding private var canGoBack: Bool
    @Binding private var canGoForward: Bool

    private var onNavigationFinished: (() -> Void)?
    private var onNavigationFailed: ((Error) -> Void)?

    // MARK: - Initialization

    public init(
        url: URL,
        isLoading: Binding<Bool> = .constant(false),
        progress: Binding<Double> = .constant(0),
        title: Binding<String> = .constant(""),
        canGoBack: Binding<Bool> = .constant(false),
        canGoForward: Binding<Bool> = .constant(false),
        onNavigationFinished: (() -> Void)? = nil,
        onNavigationFailed: ((Error) -> Void)? = nil
    ) {
        self.loadType = .url(url)
        self._isLoading = isLoading
        self._progress = progress
        self._title = title
        self._canGoBack = canGoBack
        self._canGoForward = canGoForward
        self.onNavigationFinished = onNavigationFinished
        self.onNavigationFailed = onNavigationFailed
    }

    public init(
        htmlString: String,
        baseURL: URL? = nil,
        isLoading: Binding<Bool> = .constant(false),
        progress: Binding<Double> = .constant(0),
        title: Binding<String> = .constant(""),
        canGoBack: Binding<Bool> = .constant(false),
        canGoForward: Binding<Bool> = .constant(false),
        onNavigationFinished: (() -> Void)? = nil,
        onNavigationFailed: ((Error) -> Void)? = nil
    ) {
        self.loadType = .htmlString(htmlString, baseURL: baseURL)
        self._isLoading = isLoading
        self._progress = progress
        self._title = title
        self._canGoBack = canGoBack
        self._canGoForward = canGoForward
        self.onNavigationFinished = onNavigationFinished
        self.onNavigationFailed = onNavigationFailed
    }

    // MARK: - UIViewRepresentable

    public func makeUIView(context: Context) -> LWWKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = LWWKUserContentController.shared

        let webView = LWWKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator

        webView.finishNavigationProgressBlock = { [weak webView] in
            guard let webView = webView else { return }
            DispatchQueue.main.async {
                context.coordinator.parent.isLoading = false
                context.coordinator.parent.progress = webView.estimatedProgress
            }
        }

        // Add KVO for progress and title
        webView.addObserver(
            context.coordinator,
            forKeyPath: "estimatedProgress",
            options: .new,
            context: nil
        )
        webView.addObserver(
            context.coordinator,
            forKeyPath: "title",
            options: .new,
            context: nil
        )
        webView.addObserver(
            context.coordinator,
            forKeyPath: "canGoBack",
            options: .new,
            context: nil
        )
        webView.addObserver(
            context.coordinator,
            forKeyPath: "canGoForward",
            options: .new,
            context: nil
        )

        // Load content
        switch loadType {
        case .url(let url):
            webView.load(URLRequest(url: url))

        case .htmlString(let htmlString, let baseURL):
            webView.loadHTMLString(htmlString, baseURL: baseURL)
        }

        return webView
    }

    public func updateUIView(_ uiView: LWWKWebView, context: Context) {
        // Update only if needed
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - Coordinator

    public class Coordinator: NSObject, WKNavigationDelegate {

        var parent: LWWebView

        init(_ parent: LWWebView) {
            self.parent = parent
        }

        deinit {
            // Observers will be removed when webView is deallocated
        }

        // MARK: - KVO

        public override func observeValue(
            forKeyPath keyPath: String?,
            of object: Any?,
            change: [NSKeyValueChangeKey : Any]?,
            context: UnsafeMutableRawPointer?
        ) {
            guard let webView = object as? WKWebView else { return }

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                switch keyPath {
                case "estimatedProgress":
                    self.parent.progress = webView.estimatedProgress

                case "title":
                    self.parent.title = webView.title ?? ""

                case "canGoBack":
                    self.parent.canGoBack = webView.canGoBack

                case "canGoForward":
                    self.parent.canGoForward = webView.canGoForward

                default:
                    break
                }
            }
        }

        // MARK: - WKNavigationDelegate

        public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async { [weak self] in
                self?.parent.isLoading = true
            }
        }

        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.parent.isLoading = false
                self.parent.onNavigationFinished?()
            }
        }

        public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.parent.isLoading = false
                self.parent.onNavigationFailed?(error)
            }
        }

        public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.parent.isLoading = false
                self.parent.onNavigationFailed?(error)
            }
        }
    }
}

// MARK: - WebViewController SwiftUI Wrapper

@available(iOS 13.0, *)
public struct LWWebViewController: UIViewControllerRepresentable {

    private let loadType: LWWKWebViewController

    public init(url: URL) {
        self.loadType = LWWKWebViewController.loadURL(url)
    }

    public init(htmlString: String, baseURL: URL? = nil) {
        self.loadType = LWWKWebViewController.loadHTMLString(htmlString, baseURL: baseURL)
    }

    public func makeUIViewController(context: Context) -> LWWKWebViewController {
        return loadType
    }

    public func updateUIViewController(_ uiViewController: LWWKWebViewController, context: Context) {
        // Update only if needed
    }
}

// MARK: - SwiftUI View Extensions

@available(iOS 13.0, *)
public extension View {

    func lwWebSheet(
        isPresented: Binding<Bool>,
        url: URL
    ) -> some View {
        sheet(isPresented: isPresented) {
            NavigationView {
                LWWebViewController(url: url)
            }
        }
    }

    func lwWebSheet(
        isPresented: Binding<Bool>,
        htmlString: String,
        baseURL: URL? = nil
    ) -> some View {
        sheet(isPresented: isPresented) {
            NavigationView {
                LWWebViewController(htmlString: htmlString, baseURL: baseURL)
            }
        }
    }
}

// MARK: - Example SwiftUI Views

@available(iOS 13.0, *)
public struct LWWebViewExample: View {

    @State private var isLoading = false
    @State private var progress: Double = 0
    @State private var title = ""
    @State private var canGoBack = false
    @State private var canGoForward = false

    private let url: URL

    public init(url: URL) {
        self.url = url
    }

    public var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                ProgressView(value: progress, total: 1.0)
                    .progressViewStyle(.linear)
            }

            LWWebView(
                url: url,
                isLoading: $isLoading,
                progress: $progress,
                title: $title,
                canGoBack: $canGoBack,
                canGoForward: $canGoForward,
                onNavigationFinished: {
                    print("Navigation finished")
                },
                onNavigationFailed: { error in
                    print("Navigation failed: \(error)")
                }
            )
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - ObservableObject for Advanced Usage

@available(iOS 13.0, *)
public class LWWebViewModel: ObservableObject {

    @Published public var isLoading = false
    @Published public var progress: Double = 0
    @Published public var title = ""
    @Published public var canGoBack = false
    @Published public var canGoForward = false
    @Published public var currentURL: URL?

    private var webView: LWWKWebView?

    public init() {}

    public func setWebView(_ webView: LWWKWebView) {
        self.webView = webView
    }

    public func goBack() {
        webView?.goBack()
    }

    public func goForward() {
        webView?.goForward()
    }

    public func reload() {
        webView?.reload()
    }

    public func stopLoading() {
        webView?.stopLoading()
    }

    public func evaluateJavaScript(_ script: String, completion: ((Result<Any, Error>) -> Void)? = nil) {
        webView?.evaluateJavaScript(script) { result, error in
            if let error = error {
                completion?(.failure(error))
            } else if let result = result {
                completion?(.success(result))
            }
        }
    }
}

// MARK: - Advanced SwiftUI View with ViewModel

@available(iOS 13.0, *)
public struct LWAdvancedWebView: View {

    @StateObject private var viewModel = LWWebViewModel()
    private let url: URL

    public init(url: URL) {
        self.url = url
    }

    public var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                ProgressView(value: viewModel.progress, total: 1.0)
                    .progressViewStyle(.linear)
            }

            LWWebView(
                url: url,
                isLoading: $viewModel.isLoading,
                progress: $viewModel.progress,
                title: $viewModel.title,
                canGoBack: $viewModel.canGoBack,
                canGoForward: $viewModel.canGoForward
            )

            HStack {
                Button(action: { viewModel.goBack() }) {
                    Image(systemName: "chevron.left")
                }
                .disabled(!viewModel.canGoBack)

                Button(action: { viewModel.goForward() }) {
                    Image(systemName: "chevron.right")
                }
                .disabled(!viewModel.canGoForward)

                Spacer()

                Button(action: { viewModel.reload() }) {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(viewModel.isLoading)

                Button(action: { viewModel.stopLoading() }) {
                    Image(systemName: "xmark")
                }
                .disabled(!viewModel.isLoading)
            }
            .padding()
        }
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
