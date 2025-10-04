//
// LWWKWebView.swift
// LWWebUI
//
// Swift version of WKWebView wrapper
// Copyright (c) 2025 luowei. All rights reserved.
//

import Foundation
import WebKit
import UIKit

#if DEBUG
func LWWKLog(_ items: Any..., separator: String = " ", terminator: String = "\n\n\n") {
    let output = items.map { "\($0)" }.joined(separator: separator)
    print(output, terminator: terminator)
}
#else
func LWWKLog(_ items: Any..., separator: String = " ", terminator: String = "\n\n\n") {}
#endif

// MARK: - Bundle Helper

public func LWWKWebBundle(from obj: AnyObject) -> Bundle {
    let classBundle = Bundle(for: type(of: obj))

    if let bundlePath = classBundle.path(forResource: "libLWWebUI", ofType: "bundle"),
       let bundle = Bundle(path: bundlePath) {
        return bundle
    }

    if let bundlePath = Bundle.main.path(forResource: "libLWWebUI", ofType: "bundle"),
       let bundle = Bundle(path: bundlePath) {
        return bundle
    }

    return Bundle.main
}

// MARK: - UIResponder Extension

public extension UIResponder {

    @objc func lwwk_openURL(_ url: URL) {
        var responder: UIResponder? = self

        while let currentResponder = responder {
            if #available(iOS 10.0, *) {
                if currentResponder.responds(to: #selector(UIApplication.open(_:options:completionHandler:))) {
                    (currentResponder as? UIApplication)?.open(url, options: [:], completionHandler: nil)
                    return
                }
            } else {
                if currentResponder.responds(to: #selector(UIApplication.openURL(_:))) {
                    (currentResponder as? UIApplication)?.openURL(url)
                    return
                }
            }
            responder = currentResponder.next
        }
    }
}

// MARK: - LWWKUserContentController

public class LWWKUserContentController: WKUserContentController {

    public var handlerNames: [String: Any] = [:]

    private static var _sharedInstance: LWWKUserContentController?

    public static var shared: LWWKUserContentController {
        if _sharedInstance == nil {
            _sharedInstance = LWWKUserContentController()
        }
        return _sharedInstance!
    }

    public override init() {
        super.init()

        let cancelTouchCalloutJS = "document.body.style.webkitTouchCallout='none';"
        let script = WKUserScript(
            source: cancelTouchCalloutJS,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        addUserScript(script)
    }

    public override func add(_ scriptMessageHandler: WKScriptMessageHandler, name: String) {
        super.add(scriptMessageHandler, name: name)
        handlerNames[name] = NSNull()
    }
}

// MARK: - LWWKWebView

open class LWWKWebView: WKWebView {

    // MARK: - Type Aliases

    public typealias FinishNavigationProgressBlock = () -> Void
    public typealias PresentViewControllerBlock = (UIViewController) -> Void
    public typealias RemoveProgressObserverBlock = () -> Void

    // MARK: - Properties

    public var finishNavigationProgressBlock: FinishNavigationProgressBlock?
    public var presentViewControllerBlock: PresentViewControllerBlock?
    public var removeProgressObserverBlock: RemoveProgressObserverBlock?

    public var screenImage: UIImage?

    public lazy var netStatusLabel: UILabel = {
        let label = UILabel()
        label.alpha = 0
        label.text = NSLocalizedString("Unable Open Web Page With NetWork Disconnected", comment: "")
        label.font = UIFont.systemFont(ofSize: 10.0)
        label.textColor = .gray
        label.sizeToFit()
        label.isHidden = true
        return label
    }()

    private var lastError: Error?

    private static var _processPool: WKProcessPool?

    private static var processPool: WKProcessPool {
        if _processPool == nil {
            _processPool = WKProcessPool()
        }
        return _processPool!
    }

    // MARK: - Initialization

    public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        // Set shared process pool for cookie sharing
        configuration.processPool = LWWKWebView.processPool

        super.init(frame: frame, configuration: configuration)

        navigationDelegate = self
        uiDelegate = self
        allowsBackForwardNavigationGestures = true

        // Add user scripts
        if let userContentController = configuration.userContentController as? LWWKUserContentController {
            addUserScripts(to: userContentController)
        }

        // Add network status label
        addSubview(netStatusLabel)
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    deinit {
        removeProgressObserverBlock?()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        netStatusLabel.center = CGPoint(x: frame.width / 2, y: frame.height / 2)
    }

    // MARK: - User Scripts

    private func addUserScripts(to userContentController: LWWKUserContentController) {
        if userContentController.handlerNames["webViewBack"] == nil {
            userContentController.add(self, name: "webViewBack")
        }
        if userContentController.handlerNames["webViewReload"] == nil {
            userContentController.add(self, name: "webViewReload")
        }
    }

    // MARK: - JavaScript Execution

    public func stringByEvaluatingJavaScript(from javascript: String) -> String? {
        var result: String?
        var finished = false

        evaluateJavaScript(javascript) { res, error in
            result = res as? String
            finished = true
        }

        while !finished {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
        }

        return result
    }

    // MARK: - Network Status

    public var isConnected: Bool {
        guard let reachability = LWWKReachability.reachabilityForInternetConnection() else {
            return false
        }
        return reachability.currentReachabilityStatus != .notReachable
    }

    // MARK: - Load Request Override

    open override func load(_ request: URLRequest) -> WKNavigation? {
        netStatusLabel.isHidden = isConnected
        return super.load(request)
    }

    // MARK: - HTTPS Certificate

    public func setAllowsHTTPSCertificate(withCertChain certChain: [Any], forHost host: String) {
        let selector = NSSelectorFromString("_setAllowsSpecificHTTPSCertificate:forHost:")

        if configuration.processPool.responds(to: selector) {
            configuration.processPool.perform(selector, with: certChain, with: host)
        }
    }

    // MARK: - iTunes URL Detection

    private func isItunesURL(_ urlString: String) -> Bool {
        guard let regex = try? NSRegularExpression(
            pattern: "\\/\\/itunes\\.apple\\.com\\/",
            options: .caseInsensitive
        ) else {
            return false
        }

        let matches = regex.numberOfMatches(
            in: urlString,
            options: [],
            range: NSRange(location: 0, length: urlString.count)
        )

        return matches > 0
    }

    // MARK: - Snapshot

    public func snapshotWebView() {
        snapshot { [weak self] imageRef in
            guard let self = self, let imageRef = imageRef else { return }
            let image = UIImage(cgImage: imageRef)
            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
        }
    }

    public func snapshot(completionHandler: @escaping (CGImageRef?) -> Void) {
        let bounds = self.bounds
        let imageWidth = frame.width * UIScreen.main.scale

        let selector = NSSelectorFromString("_snapshotRect:intoImageOfWidth:completionHandler:")

        if responds(to: selector) {
            typealias SnapshotFunction = @convention(c) (AnyObject, Selector, CGRect, CGFloat, @escaping (CGImageRef?) -> Void) -> Void
            let method = unsafeBitCast(self.method(for: selector), to: SnapshotFunction.self)
            method(self, selector, bounds, imageWidth, completionHandler)
        }
    }

    // MARK: - User Agent

    private static func getiOSUserAgent() -> String {
        let model = UIDevice.current.model
        let systemVersion = UIDevice.current.systemVersion
        let systemVersionUnderscore = systemVersion.replacingOccurrences(of: ".", with: "_")
        let uuidString = UIDevice.current.identifierForVendor?.uuidString ?? ""
        let randomId = String(uuidString.replacingOccurrences(of: "-", with: "").prefix(6))

        return "Mozilla/5.0 (\(model); CPU \(model) OS \(systemVersionUnderscore) like Mac OS X) AppleWebKit/602.2.14 (KHTML, like Gecko) Version/\(systemVersion) Mobile/\(randomId) Safari/602.1"
    }

    private static func getMacUserAgent() -> String {
        return "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36"
    }
}

// MARK: - WKNavigationDelegate

extension LWWKWebView: WKNavigationDelegate {

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        let urlString = url.absoluteString

        // iTunes App Store link
        if isItunesURL(urlString) {
            lwwk_openURL(url)
            decisionHandler(.cancel)
            return
        }

        // iTunes services (e.g., Dandelion installation)
        let prefix = "itms-services://"
        if urlString.hasPrefix(prefix) {
            lwwk_openURL(url)
            decisionHandler(.cancel)
            return
        }

        // Phone calls
        if url.scheme == "tel" {
            lwwk_openURL(url)
            decisionHandler(.cancel)
            return
        }

        // Custom scheme
        if url.scheme?.lowercased() == "lwinputmethod" {
            lwwk_openURL(url)
            decisionHandler(.cancel)
            return
        }

        // Handle target frame
        if navigationAction.targetFrame == nil {
            if urlString.hasSuffix(".apk") {
                decisionHandler(.cancel)
                return
            }
            webView.load(navigationAction.request)
        }

        decisionHandler(.allow)
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {

        if let mimeType = navigationResponse.response.mimeType,
           mimeType == "application/x-apple-aspen-config" {
            lwwk_openURL(navigationResponse.response.url!)
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }

    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        // Navigation committed
    }

    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        LWWKLog("Received authentication challenge")
        completionHandler(.performDefaultHandling, nil)
    }

    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // Update user agent
        evaluateJavaScript("navigator.userAgent") { [weak self] result, error in
            guard let self = self, let _ = result as? String else { return }

            let selector = NSSelectorFromString("_setCustomUserAgent:")

            if self.responds(to: selector) {
                let userAgent: String
                if UIDevice.current.userInterfaceIdiom == .phone {
                    userAgent = LWWKWebView.getiOSUserAgent()
                } else {
                    userAgent = LWWKWebView.getMacUserAgent()
                }
                self.perform(selector, with: userAgent)
            }
        }
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("Error: \(error)")
        self.lastError = error

        let nsError = error as NSError

        switch nsError.code {
        case NSURLErrorServerCertificateUntrusted:
            // Handle 12306.cn certificate issue
            if let host = webView.url?.host, host.contains("12306.cn") {
                if let chain = nsError.userInfo["NSErrorPeerCertificateChainKey"] as? [Any],
                   let failingURL = nsError.userInfo[NSURLErrorFailingURLErrorKey] as? URL {
                    setAllowsHTTPSCertificate(withCertChain: chain, forHost: failingURL.host ?? "")
                    webView.load(URLRequest(url: failingURL))
                }
            } else {
                LWWKLog("HTTPS Certificate Not Trust")
            }

        case NSURLErrorBadServerResponse,
             NSURLErrorNotConnectedToInternet,
             NSURLErrorTimedOut,
             NSURLErrorCannotFindHost,
             NSURLErrorCannotConnectToHost,
             NSURLErrorNetworkConnectionLost:

            if estimatedProgress < 0.3 {
                loadFailedPage(baseURL: nsError.userInfo[NSURLErrorFailingURLErrorKey] as? URL)
            }

        default:
            break
        }
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        let nsError = error as NSError

        switch nsError.code {
        case NSURLErrorServerCertificateUntrusted:
            if let host = webView.url?.host, host.contains("12306.cn") {
                if let chain = nsError.userInfo["NSErrorPeerCertificateChainKey"] as? [Any],
                   let failingURL = nsError.userInfo[NSURLErrorFailingURLErrorKey] as? URL {
                    setAllowsHTTPSCertificate(withCertChain: chain, forHost: failingURL.host ?? "")
                    webView.load(URLRequest(url: failingURL))
                }
            }

        case NSURLErrorBadServerResponse,
             NSURLErrorNotConnectedToInternet,
             NSURLErrorTimedOut,
             NSURLErrorCannotFindHost,
             NSURLErrorCannotConnectToHost,
             NSURLErrorNetworkConnectionLost:

            if estimatedProgress < 0.3 {
                loadFailedPage(baseURL: nsError.userInfo[NSURLErrorFailingURLErrorKey] as? URL)
            }

        default:
            break
        }
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        finishNavigationProgressBlock?()
    }

    private func loadFailedPage(baseURL: URL?) {
        let bundle = LWWKWebBundle(from: self)
        guard let path = bundle.path(forResource: "failedPage", ofType: "html"),
              let htmlString = try? String(contentsOfFile: path, encoding: .utf8) else {
            return
        }

        loadHTMLString(htmlString, baseURL: baseURL)
    }
}

// MARK: - WKScriptMessageHandler

extension LWWKWebView: WKScriptMessageHandler {

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "webViewBack":
            goBack()

        case "webViewReload":
            reload()

        default:
            break
        }
    }
}

// MARK: - WKUIDelegate

extension LWWKWebView: WKUIDelegate {

    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {

        if navigationAction.targetFrame?.isMainFrame == false {
            webView.load(navigationAction.request)
        }

        return nil
    }

    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        LWWKLog("JavaScript alert panel with message:", message)

        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler()
        })

        presentViewControllerBlock?(alert)
    }

    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        LWWKLog("JavaScript confirm panel with message:", message)

        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(false)
        })
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler(true)
        })

        presentViewControllerBlock?(alert)
    }

    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        LWWKLog("JavaScript text input panel with prompt:", prompt)

        let alert = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = defaultText
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(nil)
        })
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler(alert.textFields?.first?.text)
        })

        presentViewControllerBlock?(alert)
    }
}
