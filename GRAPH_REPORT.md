# Graph Report - /Users/luowei/projects/libs/LWWebUI  (2026-05-04)

## Corpus Check
- Corpus is ~22,826 words - fits in a single context window. You may not need a graph.

## Summary
- 251 nodes · 290 edges · 14 communities detected
- Extraction: 96% EXTRACTED · 4% INFERRED · 0% AMBIGUOUS · INFERRED: 11 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]
- [[_COMMUNITY_Community 10|Community 10]]
- [[_COMMUNITY_Community 11|Community 11]]
- [[_COMMUNITY_Community 12|Community 12]]
- [[_COMMUNITY_Community 13|Community 13]]

## God Nodes (most connected - your core abstractions)
1. `LWWKWebView` - 29 edges
2. `LWWKReachability` - 23 edges
3. `LWWKWebView` - 20 edges
4. `LWWKWebViewController` - 15 edges
5. `LWWKReachability` - 11 edges
6. `LWWKWebViewController` - 11 edges
7. `LWWebViewModel` - 9 edges
8. `LWWebViewMoreActivity` - 9 edges
9. `LWPDFPrintActivity` - 9 edges
10. `Coordinator` - 8 edges

## Surprising Connections (you probably didn't know these)
- `LWWKWebView` --inherits--> `WKNavigationDelegate`  [EXTRACTED]
  LWWebUI_swift/LWWKWebView.swift →   _Bridges community 2 → community 1_

## Communities (20 total, 1 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.07
Nodes (29): LWWKWebView, -actionSheetclickedButtonAtIndex, -addUserScriptsToWeb, -connected, -dealloc, -getiOSUserAgent, -getMacUserAgent, -initWithFrameconfiguration (+21 more)

### Community 1 - "Community 1"
Cohesion: 0.11
Nodes (8): LWWKLog(), LWWKUserContentController, LWWKWebView, UIResponder, WKScriptMessageHandler, WKUIDelegate, WKUserContentController, WKWebView

### Community 2 - "Community 2"
Cohesion: 0.09
Nodes (10): Coordinator, LWAdvancedWebView, LWWebView, LWWebViewController, LWWebViewExample, View, NSObject, UIViewControllerRepresentable (+2 more)

### Community 3 - "Community 3"
Cohesion: 0.08
Nodes (24): LWPDFPrintActivity, -activityCategory, -activityImage, -activityTitle, -activityType, -canPerformWithActivityItems, -initWithiphoneImageipadImage, -performActivity (+16 more)

### Community 4 - "Community 4"
Cohesion: 0.08
Nodes (23): LWWKReachability, -connectionRequired, -currentReachabilityFlags, -currentReachabilityStatus, -currentReachabilityString, -dealloc, -description, -initWithReachabilityRef (+15 more)

### Community 5 - "Community 5"
Cohesion: 0.15
Nodes (13): AdvancedWebViewExample, BasicWebViewExample, HTMLStringExample, LWWebUIKitExamples, LWWebUISwiftUIExamples, MultipleWebViewsExample, WebViewSheetExample, WebViewWithCallbacksExample (+5 more)

### Community 6 - "Community 6"
Cohesion: 0.13
Nodes (8): CustomStringConvertible, Int, LWWKNetworkStatus, notReachable, reachableViaWiFi, reachableViaWWAN, LWWKReachability, Notification.Name

### Community 7 - "Community 7"
Cohesion: 0.18
Nodes (5): LWPDFPrintActivity, LWWebViewMoreActivity, UIPrintPageRenderer, UIView, UIActivity

### Community 8 - "Community 8"
Cohesion: 0.2
Nodes (3): LWWKWebBundle(), LWWKWebViewController, UIViewController

### Community 9 - "Community 9"
Cohesion: 0.14
Nodes (13): LWWKUserContentController, -addScriptMessageHandlername, -init, -shareInstance, NSObject, -lwwk_swizzleClassMethodwithMethod, -lwwk_swizzleMethodwithMethod, UIResponder (+5 more)

### Community 11 - "Community 11"
Cohesion: 0.22
Nodes (9): LWWebViewMoreActivity, -activityCategory, -activityImage, -activityTitle, -activityType, -canPerformWithActivityItems, -initWithiphoneImageipadImage, -performActivity (+1 more)

### Community 12 - "Community 12"
Cohesion: 0.25
Nodes (7): LWAppDelegate, -applicationDidBecomeActive, -applicationDidEnterBackground, -applicationdidFinishLaunchingWithOptions, -applicationWillEnterForeground, -applicationWillResignActive, -applicationWillTerminate

### Community 13 - "Community 13"
Cohesion: 0.29
Nodes (6): LWViewController, -btnAction, -cookieWithCookieDomaincookieNamecookieValue, -didReceiveMemoryWarning, -setupCookies, -viewDidLoad

## Knowledge Gaps
- **104 isolated node(s):** `htmlString`, `LWWebUISwiftUIExamples`, `notReachable`, `reachableViaWiFi`, `reachableViaWWAN` (+99 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `url` connect `Community 5` to `Community 8`, `Community 7`?**
  _High betweenness centrality (0.075) - this node is a cross-community bridge._
- **Why does `LWWKWebView` connect `Community 1` to `Community 2`, `Community 10`?**
  _High betweenness centrality (0.057) - this node is a cross-community bridge._
- **Why does `LoadType` connect `Community 5` to `Community 2`?**
  _High betweenness centrality (0.047) - this node is a cross-community bridge._
- **What connects `htmlString`, `LWWebUISwiftUIExamples`, `notReachable` to the rest of the system?**
  _104 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.07 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.11 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.09 - nodes in this community are weakly interconnected._