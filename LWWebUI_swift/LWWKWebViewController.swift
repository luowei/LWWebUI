//
// LWWKWebViewController.swift
// LWWebUI
//
// Swift version of WKWebView view controller
// Copyright (c) 2025 luowei. All rights reserved.
//

import UIKit
import WebKit

// MARK: - UIView Extension

public extension UIView {

    func lwwk_superView<T: UIView>(ofClass classType: T.Type) -> T? {
        var responder: UIResponder? = self

        while let currentResponder = responder {
            if let view = currentResponder as? T {
                return view
            }
            responder = currentResponder.next
        }

        return nil
    }
}

// MARK: - UIPrintPageRenderer Extension

public extension UIPrintPageRenderer {

    func lwwk_printToPDF() -> Data {
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, paperRect, nil)
        prepare(forDrawingPages: NSRange(location: 0, length: numberOfPages))

        let bounds = UIGraphicsGetPDFContextBounds()
        for i in 0..<numberOfPages {
            UIGraphicsBeginPDFPage()
            drawPage(at: i, in: bounds)
        }

        UIGraphicsEndPDFContext()
        return pdfData as Data
    }
}

// MARK: - LWWKWebViewController

open class LWWKWebViewController: UIViewController {

    // MARK: - Properties

    public private(set) var wkWebView: LWWKWebView!
    public private(set) var webProgress: UIProgressView!

    public var url: String?
    public var webURL: URL?

    private var htmlString: String?
    private var htmlStringBaseURL: URL?

    // MARK: - Factory Methods

    public static func loadURL(_ url: URL) -> LWWKWebViewController {
        return wkWebViewController(with: url)
    }

    public static func wkWebViewController(with url: URL) -> LWWKWebViewController {
        let viewController = LWWKWebViewController()
        viewController.webURL = url
        return viewController
    }

    public static func loadHTMLString(_ htmlString: String, baseURL: URL? = nil) -> LWWKWebViewController {
        let viewController = LWWKWebViewController()
        viewController.htmlString = htmlString
        viewController.htmlStringBaseURL = baseURL
        return viewController
    }

    // MARK: - Lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        // Setup navigation bar
        setupNavigationBar()

        // Setup web view
        setupWebView()

        // Setup progress view
        setupProgressView()

        // Load content
        loadContent()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isModal {
            let closeItem = UIBarButtonItem(
                title: "Close",
                style: .plain,
                target: self,
                action: #selector(dismissController)
            )
            navigationItem.leftBarButtonItem = closeItem
        }
    }

    deinit {
        wkWebView?.removeObserver(self, forKeyPath: "estimatedProgress")
        wkWebView?.removeObserver(self, forKeyPath: "title")
    }

    // MARK: - Setup Methods

    private func setupNavigationBar() {
        let bundle = LWWKWebBundle(from: self)
        if let image = UIImage(named: "more_dot", in: bundle, compatibleWith: nil) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: image,
                style: .plain,
                target: self,
                action: #selector(moreAction(_:))
            )
        }
    }

    private func setupWebView() {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = LWWKUserContentController.shared

        wkWebView = LWWKWebView(frame: view.frame, configuration: configuration)
        view.addSubview(wkWebView)

        wkWebView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            wkWebView.topAnchor.constraint(equalTo: view.topAnchor),
            wkWebView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            wkWebView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            wkWebView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Setup blocks
        wkWebView.finishNavigationProgressBlock = { [weak self] in
            guard let self = self else { return }
            self.webProgress.isHidden = false
            self.webProgress.setProgress(0.0, animated: false)
            self.webProgress.trackTintColor = .white
        }

        wkWebView.removeProgressObserverBlock = { [weak self] in
            guard let self = self else { return }
            self.wkWebView?.removeObserver(self, forKeyPath: "estimatedProgress")
            self.wkWebView?.removeObserver(self, forKeyPath: "title")
        }

        wkWebView.presentViewControllerBlock = { [weak self] viewController in
            self?.present(viewController, animated: true, completion: nil)
        }

        // Add KVO observers
        wkWebView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        wkWebView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
    }

    private func setupProgressView() {
        webProgress = UIProgressView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 2))
        view.addSubview(webProgress)

        webProgress.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webProgress.topAnchor.constraint(equalTo: view.topAnchor),
            webProgress.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webProgress.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webProgress.heightAnchor.constraint(equalToConstant: 2)
        ])
    }

    private func loadContent() {
        if let webURL = webURL {
            loadURL(webURL)
        } else if let htmlString = htmlString {
            loadHTMLString(htmlString, baseURL: htmlStringBaseURL)
        } else if let urlString = url, let url = URL(string: urlString) {
            loadURL(url)
        }
    }

    // MARK: - Actions

    @objc private func dismissController() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func moreAction(_ sender: UIBarButtonItem) {
        guard let url = wkWebView.url else { return }

        let items: [Any] = [url]
        let bundle = LWWKWebBundle(from: self)

        let safari50Image = UIImage(named: "Safari50", in: bundle, compatibleWith: nil)
        let safari53Image = UIImage(named: "Safari53", in: bundle, compatibleWith: nil)
        let pdfPrint50Image = UIImage(named: "pdfPrint50", in: bundle, compatibleWith: nil)
        let pdfPrint53Image = UIImage(named: "pdfPrint53", in: bundle, compatibleWith: nil)

        var activities: [UIActivity] = []

        if let safari50 = safari50Image, let safari53 = safari53Image {
            let safariActivity = LWWebViewMoreActivity(
                iphoneImage: safari50,
                ipadImage: safari53,
                url: url
            )
            activities.append(safariActivity)
        }

        if let pdf50 = pdfPrint50Image, let pdf53 = pdfPrint53Image {
            let pdfActivity = LWPDFPrintActivity(
                iphoneImage: pdf50,
                ipadImage: pdf53,
                printView: wkWebView,
                title: wkWebView.title
            )
            activities.append(pdfActivity)
        }

        let activityVC = UIActivityViewController(
            activityItems: items,
            applicationActivities: activities
        )

        activityVC.excludedActivityTypes = [
            .postToVimeo,
            .mail,
            .postToFlickr,
            .assignToContact,
            .saveToCameraRoll
        ]

        // For iPad
        if UIDevice.current.userInterfaceIdiom == .pad {
            activityVC.popoverPresentationController?.barButtonItem = sender
        }

        present(activityVC, animated: true, completion: nil)
    }

    // MARK: - Helper Methods

    private var isModal: Bool {
        if presentingViewController != nil {
            return true
        }

        if let navigationController = navigationController,
           navigationController.presentingViewController?.presentedViewController == navigationController {
            return true
        }

        if let tabBarController = tabBarController,
           tabBarController.presentingViewController is UITabBarController {
            return true
        }

        return false
    }

    // MARK: - KVO

    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        if keyPath == "estimatedProgress" {
            let animated = wkWebView.estimatedProgress > webProgress.progress
            webProgress.setProgress(Float(wkWebView.estimatedProgress), animated: animated)

            if wkWebView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
                    self.webProgress.isHidden = true
                }, completion: { _ in
                    self.webProgress.setProgress(0.0, animated: false)
                })
            }
        } else if keyPath == "title" {
            title = wkWebView.title
        }
    }

    // MARK: - Public Methods

    public func loadURL(_ url: URL) {
        wkWebView.load(URLRequest(url: url))
    }

    public func loadHTMLString(_ htmlString: String, baseURL: URL? = nil) {
        wkWebView.loadHTMLString(htmlString, baseURL: baseURL)
    }
}

// MARK: - LWWebViewMoreActivity

public let UIActivityTypeOpenInSafari = "OpenInSafariActivityMine"

open class LWWebViewMoreActivity: UIActivity {

    public var url: URL?
    public var iphoneImage: UIImage?
    public var ipadImage: UIImage?

    public init(iphoneImage: UIImage?, ipadImage: UIImage?, url: URL?) {
        self.iphoneImage = iphoneImage
        self.ipadImage = ipadImage
        self.url = url
        super.init()
    }

    open override var activityType: UIActivity.ActivityType? {
        return UIActivity.ActivityType(rawValue: UIActivityTypeOpenInSafari)
    }

    open override var activityTitle: String? {
        let bundle = LWWKWebBundle(from: self)
        return NSLocalizedString("Open in Safari", tableName: "Local", bundle: bundle, comment: "")
    }

    open override var activityImage: UIImage? {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return ipadImage
        } else {
            return iphoneImage
        }
    }

    open override class var activityCategory: UIActivity.Category {
        return .share
    }

    open override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }

    open override func prepare(withActivityItems activityItems: [Any]) {
        super.prepare(withActivityItems: activityItems)
    }

    open override func perform() {
        guard let url = url else {
            activityDidFinish(false)
            return
        }

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }

        activityDidFinish(true)
    }
}

// MARK: - LWPDFPrintActivity

public let UIActivityTypePDFPrintActivity = "PDFPrintActivityActivityMine"

open class LWPDFPrintActivity: UIActivity {

    public var iphoneImage: UIImage?
    public var ipadImage: UIImage?
    public var printView: UIView?
    public var titleString: String?

    public init(iphoneImage: UIImage?, ipadImage: UIImage?, printView: UIView?, title: String?) {
        self.iphoneImage = iphoneImage
        self.ipadImage = ipadImage
        self.printView = printView
        self.titleString = title
        super.init()
    }

    open override var activityType: UIActivity.ActivityType? {
        return UIActivity.ActivityType(rawValue: UIActivityTypePDFPrintActivity)
    }

    open override var activityTitle: String? {
        let bundle = LWWKWebBundle(from: self)
        return NSLocalizedString("Export PDF", tableName: "Local", bundle: bundle, comment: "")
    }

    open override var activityImage: UIImage? {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return ipadImage
        } else {
            return iphoneImage
        }
    }

    open override class var activityCategory: UIActivity.Category {
        return .action
    }

    open override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }

    open override func prepare(withActivityItems activityItems: [Any]) {
        super.prepare(withActivityItems: activityItems)
    }

    open override func perform() {
        guard let printView = printView else {
            activityDidFinish(false)
            return
        }

        let render = UIPrintPageRenderer()
        render.addPrintFormatter(printView.viewPrintFormatter, startingAt: 0)

        let topPadding: CGFloat = 10.0
        let bottomPadding: CGFloat = 10.0
        let leftPadding: CGFloat = 10.0
        let rightPadding: CGFloat = 10.0

        let paperSize: CGSize
        if UIDevice.current.userInterfaceIdiom == .pad {
            paperSize = CGSize(width: 595, height: 842) // A4
        } else {
            paperSize = CGSize(width: 298, height: 420) // A6
        }

        let printableRect = CGRect(
            x: leftPadding,
            y: topPadding,
            width: paperSize.width - leftPadding - rightPadding,
            height: paperSize.height - topPadding - bottomPadding
        )

        let paperRect = CGRect(origin: .zero, size: paperSize)

        render.setValue(NSValue(cgRect: paperRect), forKey: "paperRect")
        render.setValue(NSValue(cgRect: printableRect), forKey: "printableRect")

        let pdfData = render.lwwk_printToPDF()

        let bundle = LWWKWebBundle(from: self)
        var title = NSLocalizedString("Export PDF", tableName: "Local", bundle: bundle, comment: "")

        if let webView = printView as? WKWebView {
            if let webTitle = titleString ?? webView.title, !webTitle.isEmpty {
                title = webTitle
            }

            let illegalCharacters = CharacterSet(charactersIn: "/\\?%*|\"<>")
            title = title.components(separatedBy: illegalCharacters).joined(separator: "_")
        }

        let pdfPath = NSTemporaryDirectory() + title + ".pdf"

        do {
            try pdfData.write(to: URL(fileURLWithPath: pdfPath), options: .atomic)

            let url = URL(fileURLWithPath: pdfPath)
            let activityVC = UIActivityViewController(
                activityItems: [title, url],
                applicationActivities: nil
            )

            if let viewController = printView.lwwk_superView(ofClass: UIViewController.self) {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    activityVC.popoverPresentationController?.sourceView = viewController.view
                    activityVC.popoverPresentationController?.sourceRect = UIScreen.main.bounds
                }
                viewController.present(activityVC, animated: true, completion: nil)
            }
        } catch {
            print("PDF could not be created: \(error)")
        }

        activityDidFinish(true)
    }
}
