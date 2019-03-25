//
//  MyWKWebView.h
//  Webkit-Demo
//
//  Created by luowei on 15/6/25.
//  Copyright (c) 2015 rootls. All rights reserved.
//

#ifdef DEBUG
#define MyLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define MyLog(format, ...)
#endif

#import <WebKit/WebKit.h>

@class MyWKWebView;

@interface MyWKUserContentController:WKUserContentController

@property(nonatomic, strong) NSMutableDictionary<NSString*,id> *handlerNames;

//获得MyWKUserContentController单例
+ (instancetype)shareInstance;

@end


@protocol MyWebViewDelegate<NSObject>

@property(nonatomic, copy) void (^finishNavigationProgressBlock)();
@property(nonatomic, copy) void (^addWebViewBlock)(MyWKWebView **wb, NSURL *);
@property(nonatomic, copy) void (^closeActiveWebViewBlock)();
@property(nonatomic, copy) void (^presentViewControllerBlock)(UIViewController *);

@end

@interface MyWKWebView : WKWebView<WKNavigationDelegate, WKScriptMessageHandler,WKUIDelegate,UIActionSheetDelegate>

@property(nonatomic, copy) void (^finishNavigationProgressBlock)();

@property(nonatomic, copy) void (^presentViewControllerBlock)(UIViewController *);

@property(nonatomic, copy) void (^removeProgressObserverBlock)();

@property(nonatomic, strong) UIImage *screenImage;

@property(nonatomic, strong) UILabel *netStatusLabel;

//Sync JavaScript in WKWebView
//evaluateJavaScript is callback type. result should be handled by callback so, it is async.
- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)javascript;

//判断网络连接状态
- (BOOL)connected;


//允许HTTPS验证钥匙中证书
- (void)setAllowsHTTPSCertifcateWithCertChain:(NSArray *)certChain ForHost:(NSString *)host;


#pragma mark - snapshot(快照截图)

//截图快照
- (void)snapshotWebView;
//快照截图Handler
- (void)snapshotWithHandler:(void (^)(CGImageRef imgRef))completionHandler;

@end

