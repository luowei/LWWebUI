//
//  MyWKWebView.m
//  Webkit-Demo
//
//  Created by luowei on 15/6/25.
//  Copyright (c) 2015 rootls. All rights reserved.
//

#import "LWWKWebView.h"
#import "LWWKReachability.h"
#import <objc/message.h>

@implementation NSObject (LWWKSwizzling)

+ (BOOL)lwwk_swizzleMethod:(SEL)origSel withMethod:(SEL)altSel {
    Method origMethod = class_getInstanceMethod(self, origSel);
    Method altMethod = class_getInstanceMethod(self, altSel);
    if (!origMethod || !altMethod) {
        return NO;
    }
    class_addMethod(self, origSel, class_getMethodImplementation(self, origSel), method_getTypeEncoding(origMethod));
    class_addMethod(self, altSel, class_getMethodImplementation(self, altSel), method_getTypeEncoding(altMethod));
    method_exchangeImplementations(class_getInstanceMethod(self, origSel), class_getInstanceMethod(self, altSel));
    return YES;
}

+ (BOOL)lwwk_swizzleClassMethod:(SEL)origSel withMethod:(SEL)altSel {
    return [object_getClass((id) self) lwwk_swizzleMethod:origSel withMethod:altSel];
}

@end

@implementation WKWebView (LWWKSwizzling)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [WKWebView lwwk_swizzleMethod:@selector(loadRequest:) withMethod:@selector(myLoadRequest:)];
    });
}

- (void)myLoadRequest:(NSURLRequest *_Nullable)request {

    NSMutableURLRequest *mRequest = request.mutableCopy;

    NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:request.URL];
//    NSArray<NSHTTPCookie *> *cookies = @[];
    if(@available(iOS 11.0,*)){

        dispatch_group_t group = dispatch_group_create();
//        dispatch_queue_main_t queue = dispatch_get_main_queue();
        dispatch_queue_t queue = dispatch_queue_create("com.wodedata.libLWWebUI.LWWKWebView", DISPATCH_QUEUE_CONCURRENT);

//        //把并行队列加入到group当中，异步执行，执行完后会触发 dispatch_group_notify
//        dispatch_group_async(group, queue, ^{});

        //使用 enter/leave 控制执行流程，只有成对出现时才会触发 dispatch_group_notify
        for (NSHTTPCookie *cookie in cookies) {
            dispatch_group_enter(group);
            [[[WKWebsiteDataStore defaultDataStore] httpCookieStore] setCookie:cookie completionHandler:^{
                dispatch_group_leave(group);
            }];
        }

        dispatch_group_notify(group, queue, ^(){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self myLoadRequest:mRequest];
            });
        });

    }else{
        NSDictionary<NSString *, NSString *> *requestHeaderFields = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
        [mRequest setHTTPShouldHandleCookies:YES];
        [mRequest setAllHTTPHeaderFields:requestHeaderFields];
        [self myLoadRequest:mRequest];
    }
}

@end

@implementation UIResponder (LWWKExtension)

//打开指定url
- (void)lwwk_openURLWithUrl:(NSURL *)url {
    UIResponder *responder = self;
    while ((responder = [responder nextResponder]) != nil) {
        if (@available(iOS 10.0,*)) {
            SEL sel = @selector(openURL:options:completionHandler:);
            if ([responder respondsToSelector:sel]) {
                NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[responder methodSignatureForSelector:sel]];
                [inv setSelector:sel];
                [inv setTarget:responder];

                NSDictionary *dict = nil;
                void (^completionHandler)(BOOL);
                
                [inv setArgument:&url atIndex:2];
                [inv setArgument:&dict atIndex:3];
                [inv setArgument:&completionHandler atIndex:4];

                [inv invoke];
                return;
            }
        }else{
            if ([responder respondsToSelector:@selector(openURL:)]) {
                [responder performSelector:@selector(openURL:) withObject:url];
                return;
            }
        }
    }
}

- (void)performWithArguments:(NSArray *)arguments {

    SEL aSelector = NSSelectorFromString([arguments firstObject]);

    NSMethodSignature *signature = [self methodSignatureForSelector:aSelector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:self];
    [invocation setSelector:aSelector];

    for (NSUInteger i = 1; i < arguments.count; i++) {
        id obj = arguments[i];
        [invocation setArgument:&obj atIndex:i + 1];
    }

    [invocation invoke];
}

@end


@implementation LWWKUserContentController

//获得MyWKUserContentController单例
+ (instancetype)shareInstance {
    static LWWKUserContentController *myContentController = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        myContentController = [[self alloc] init];
    });

    return myContentController;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *cancelTouchCalloutJS = @"document.body.style.webkitTouchCallout='none';";
        WKUserScript *compileFiltersUserScript = [[WKUserScript alloc] initWithSource:cancelTouchCalloutJS injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
        [self addUserScript:compileFiltersUserScript];
    }

    return self;
}

- (void)addScriptMessageHandler:(id <WKScriptMessageHandler>)scriptMessageHandler name:(NSString *)name {
    [super addScriptMessageHandler:scriptMessageHandler name:name];
    _handlerNames = _handlerNames ?: @{}.mutableCopy;
    [_handlerNames setValue:[NSNull null] forKey:name];
}


@end


@interface LWWKWebView () {

}

@property(nonatomic, strong) NSError *error;
@end

@implementation LWWKWebView

static WKProcessPool *_pool;

+ (WKProcessPool *)pool {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _pool = [[WKProcessPool alloc] init];
    });
    return _pool;
}


- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {

    //设置多窗口cookie共享
    configuration.processPool = [LWWKWebView pool];
//    self.backForwardList

    self = [super initWithFrame:frame configuration:configuration];
    if (self) {
        self.navigationDelegate = self;
        self.UIDelegate = self;
        self.allowsBackForwardNavigationGestures = YES;
//        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        //加载用户js文件,修改加载网页内容
        [self addUserScriptsToWeb:(LWWKUserContentController *) configuration.userContentController];

        //网络连接状态标示
        _netStatusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        //隐藏
        _netStatusLabel.alpha = 0;
        _netStatusLabel.text = NSLocalizedString(@"Unable Open Web Page With NetWork Disconnected", nil);
        _netStatusLabel.font = [UIFont systemFontOfSize:10.0];
        _netStatusLabel.textColor = [UIColor grayColor];
        [_netStatusLabel sizeToFit];
        _netStatusLabel.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        [self addSubview:_netStatusLabel];
        _netStatusLabel.hidden = YES;
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _netStatusLabel.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
}


- (void)dealloc {
    if(self.removeProgressObserverBlock){
        self.removeProgressObserverBlock();
    }
}

//加载用户js文件
- (void)addUserScriptsToWeb:(LWWKUserContentController *)userContentController {
//    //添加脚本消息处理器根据消息名称
//    if (![userContentController.handlerNames valueForKey:@"docStartInjection"])
//        [userContentController addScriptMessageHandler:self name:@"docStartInjection"];

    //添加ScriptMessageHandler
    if (![userContentController.handlerNames valueForKey:@"webViewBack"])
        [userContentController addScriptMessageHandler:self name:@"webViewBack"];
    if (![userContentController.handlerNames valueForKey:@"webViewReload"])
        [userContentController addScriptMessageHandler:self name:@"webViewReload"];
}


//Sync JavaScript in WKWebView(同步版的javascript执行器)
//evaluateJavaScript is callback type. result should be handled by callback so, it is async.
- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)javascript {
    __block NSString *res = nil;
    __block BOOL finish = NO;
    [self evaluateJavaScript:javascript completionHandler:^(NSString *result, NSError *error) {
        res = result;
        finish = YES;
    }];

    while (!finish) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    return res;
}


//加载请求
- (WKNavigation *)loadRequest:(NSURLRequest *)request {
    NSString *urlText = nil;
    if (request && request.URL) {
        urlText = request.URL.absoluteString;
    }
    //todo:把urlText更新到地址栏

    _netStatusLabel.hidden = [self connected];

    return [super loadRequest:request];
}


#pragma mark WKNavigationDelegate Implementation

//决定是否请允许打开
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    MyLog(@"--------%d:%s \n\n", __LINE__, __func__);

    NSURL *url = navigationAction.request.URL;
    NSString *urlString = (url) ? url.absoluteString : @"";
    // iTunes: App Store link跳转不了问题
    BOOL isMatch = [self is_itunesURLString:urlString];
    if (isMatch) {
        [self lwwk_openURLWithUrl:url];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    //蒲公英安装不了问题
    NSString *prefix = [[[@"itm" stringByAppendingString:@"s-s"] stringByAppendingString:@"ervices"] stringByAppendingString:@"://"];
    if ([urlString hasPrefix:prefix]) {
        [self lwwk_openURLWithUrl:url];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ([url.scheme isEqualToString:@"tel"]) {
        [self lwwk_openURLWithUrl:url];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if([url.scheme.lowercaseString isEqualToString:@"lwinputmethod"]){
        [self lwwk_openURLWithUrl:url];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    //决定是否新窗口打开
    if (!navigationAction.targetFrame) {
        if ([urlString hasSuffix:@".apk"]) {
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
        [webView loadRequest:navigationAction.request];
    }

    decisionHandler(WKNavigationActionPolicyAllow);
}

- (BOOL)is_itunesURLString:(NSString *)urlString {
    NSRegularExpression *rx = [[NSRegularExpression alloc] initWithPattern:@"\\/\\/itunes\\.apple\\.com\\/" options:NSRegularExpressionCaseInsensitive error:nil];
    BOOL isMatch = [rx numberOfMatchesInString:urlString options:0 range:NSMakeRange(0, urlString.length)] > 0 ;
    return isMatch;
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    if([navigationResponse.response.MIMEType isEqualToString:[@"application/x-a" stringByAppendingString:@"pple-aspen-config"]]){
        [self lwwk_openURLWithUrl:navigationResponse.response.URL];
        decisionHandler(WKNavigationResponsePolicyCancel);
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
}


//处理当接收到验证窗口时
- (void)  webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
    MyLog(@"-----处理当接收到验证窗口时---%d:%s \n\n", __LINE__, __func__);
//    NSString *hostName = webView.URL.host;
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);

}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {

    //修改浏览器UA设置
//    __weak typeof(self) weadSelf = self;
    [self evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError *error) {
        NSString *userAgent = result;
        if (userAgent && userAgent.length > 0) {
            //切换用户代理模式
            //- (void)_setCustomUserAgent:(id)arg1;
            NSString *selectorName = [@"_setCustom" stringByAppendingString:@"UserAgent:"];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
                NSString *UAString = [LWWKWebView getiOSUserAgent];
                ((void (*)(id, SEL, id)) objc_msgSend)(self, NSSelectorFromString(selectorName), UAString);
            }else{
                NSString *UAString = [LWWKWebView getMacUserAgent];
                ((void (*)(id, SEL, id)) objc_msgSend)(self, NSSelectorFromString(selectorName), UAString);
            }
        }
    }];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"error = %@", error);
    self.error = error;

    switch ([error code]) {
        case kCFURLErrorServerCertificateUntrusted: {
            //解决12306不能买票问题
            NSRange range = [[webView.URL host] rangeOfString:@"12306.cn"];
            
            if (range.location != NSNotFound && range.location) {
                NSArray *chain = error.userInfo[@"NSErrorPeerCertificateChainKey"];
                NSURL *failingURL = error.userInfo[@"NSErrorFailingURLKey"];
                [self setAllowsHTTPSCertifcateWithCertChain:chain ForHost:[failingURL host]];
                [webView loadRequest:[NSURLRequest requestWithURL:failingURL]];
            } else {
                // 网站证书不被信任，给出提示
                MyLog(@"====:%@",NSLocalizedString(@"HTTPS Certifcate Not Trust", nil));
            }
            break;
        }
        case kCFURLErrorBadServerResponse:
        case kCFURLErrorNotConnectedToInternet:
        case kCFSOCKS5ErrorNoAcceptableMethod:
        case kCFErrorHTTPBadCredentials:
        case kCFErrorHTTPConnectionLost:
        case kCFErrorHTTPBadURL:
        case kCFErrorHTTPBadProxyCredentials:
        case kCFURLErrorBadURL:
        case kCFURLErrorTimedOut:
        case kCFURLErrorCannotFindHost:
        case kCFURLErrorCannotConnectToHost:
        case kCFURLErrorNetworkConnectionLost:
        case kCFNetServiceErrorTimeout:
        case kCFNetServiceErrorNotFound:
//            NSLog(@"errorCode:%ld",(long)[error code]);
            //error webView
            if (self.estimatedProgress < 0.3) {
//                NSString *bundlePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"libLWWebUI" ofType:@"bundle"];
//                NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"libLWWebUI" ofType:@"bundle"]];
                NSString *path = [LWWKWebBundle(self) pathForResource:@"failedPage" ofType:@"html"];
                NSError *error2;
                NSString *htmlString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error2];
                NSURL *failingURL = error.userInfo[@"NSErrorFailingURLKey"];
                [webView loadHTMLString:htmlString baseURL:failingURL];
            }
            break;
        default: {
            break;
        }
    }
}

//当加载页面发生错误
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {

    //todo:更新进度条(didFailLoadWebView)

    switch ([error code]) {
        case kCFURLErrorServerCertificateUntrusted: {
            //解决12306不能买票问题
            NSRange range = [[webView.URL host] rangeOfString:@"12306.cn"];
            if (range.location != NSNotFound) {
                NSArray *chain = error.userInfo[@"NSErrorPeerCertificateChainKey"];
                NSURL *failingURL = error.userInfo[@"NSErrorFailingURLKey"];
                [self setAllowsHTTPSCertifcateWithCertChain:chain ForHost:[failingURL host]];
                [webView loadRequest:[NSURLRequest requestWithURL:failingURL]];
            }
            break;
        }
        case kCFURLErrorBadServerResponse:
        case kCFURLErrorNotConnectedToInternet:
        case kCFSOCKS5ErrorNoAcceptableMethod:
        case kCFErrorHTTPBadCredentials:
        case kCFErrorHTTPConnectionLost:
        case kCFErrorHTTPBadURL:
        case kCFErrorHTTPBadProxyCredentials:
        case kCFURLErrorBadURL:
        case kCFURLErrorTimedOut:
        case kCFURLErrorCannotFindHost:
        case kCFURLErrorCannotConnectToHost:
        case kCFURLErrorNetworkConnectionLost:
        case kCFNetServiceErrorTimeout:
        case kCFNetServiceErrorNotFound:
            NSLog(@"errorCode:%ld", (long) [error code]);
            //error webView
            if (self.estimatedProgress < 0.3) {
                NSString *path = [LWWKWebBundle(self)pathForResource:@"failedPage" ofType:@"htm"];
                NSError *error2;
                NSString *htmlString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error2];
                NSURL *failingURL = error.userInfo[@"NSErrorFailingURLKey"];
                [webView loadHTMLString:htmlString baseURL:failingURL];
            }
            break;
        default: {
            break;
        }
    }

}

//当页面加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if(self.finishNavigationProgressBlock){
        self.finishNavigationProgressBlock();
    }

}

//允许HTTPS验证钥匙中证书
- (void)setAllowsHTTPSCertifcateWithCertChain:(NSArray *)certChain ForHost:(NSString *)host {
    ((void (*)(id, SEL, id, id)) objc_msgSend)(self.configuration.processPool,
            //- (void)_setAllowsSpecificHTTPSCertificate:(id)arg1 forHost:(id)arg2;
//            NSSelectorFromString([NSString base64Decoding:@"X3NldEFsbG93c1NwZWNpZmljSFRUUFNDZXJ0aWZpY2F0ZTpmb3JIb3N0Og=="]),
            NSSelectorFromString([@"_setAllowsSpecific" stringByAppendingString:@"HTTPSCertificate:forHost:"]),
            certChain, host);
}

#pragma mark WKMessageHandle Implementation

//处理当接收到html页面脚本发来的消息
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    //返回
    if ([message.name isEqualToString:@"webViewBack"]) {
        [self goBack];

        //重新加载
    } else if ([message.name isEqualToString:@"webViewReload"]) {
        [self reload];

    }
}


#pragma mark WKUIDelegate Implementation

//let link has arget=”_blank” work
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
   forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {

    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }

    return nil;
}

//处理页面的alert弹窗
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    MyLog(@"----处理页面的alert弹窗----%d:%s \n\n", __LINE__, __func__);
}

//处理页面的confirm弹窗
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    MyLog(@"-----处理页面的confirm弹窗---%d:%s \n\n", __LINE__, __func__);
}

//处理页面的promt弹窗
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *))completionHandler {
    MyLog(@"-----处理页面的promt弹窗---%d:%s \n\n", __LINE__, __func__);
}


#pragma mark - UIActionSheetDelegate

// 网站证书不被信任的情况
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {
            NSArray *chain = _error.userInfo[@"NSErrorPeerCertificateChainKey"];
            NSURL *failingURL = _error.userInfo[@"NSErrorFailingURLKey"];
            [self setAllowsHTTPSCertifcateWithCertChain:chain ForHost:[failingURL host]];
            [self loadRequest:[NSURLRequest requestWithURL:failingURL]];
            break;
        }
        default:
            break;
    }
}


//判断网络连接状态
- (BOOL)connected {
    LWWKReachability *reachability = [LWWKReachability reachabilityForInternetConnection];
    LWWKNetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}


#pragma mark - snapshot(快照截图)

//截图快照
- (void)snapshotWebView {
    __weak typeof(self) weakSelf = self;
    [self snapshotWithHandler:^(CGImageRef imgRef) {
        UIImage *image = [UIImage imageWithCGImage:imgRef];
        UIImageWriteToSavedPhotosAlbum(image, weakSelf, NULL, NULL);
    }];
}

//快照截图Handler
- (void)snapshotWithHandler:(void (^)(CGImageRef imgRef))completionHandler {

    CGRect bounds = self.bounds;
    CGFloat imageWidth = self.frame.size.width * [UIScreen mainScreen].scale;

    //- (void)_snapshotRect:(CGRect)rectInViewCoordinates intoImageOfWidth:(CGFloat)imageWidth completionHandler:(void(^)(CGImageRef))completionHandler;
    SEL snapShotSel = NSSelectorFromString([@"_snapshot" stringByAppendingString:@"Rect:intoImageOfWidth:completionHandler:"]);

    if ([self respondsToSelector:snapShotSel]) {
        ((void (*)(id, SEL, CGRect, CGFloat, id)) objc_msgSend)(self, snapShotSel, bounds, imageWidth, completionHandler);

    }

}

//获取UserAgent
+(NSString *)getiOSUserAgent{
//    NSString *localizedModel = UIDevice.currentDevice.localizedModel;
//    NSString *name = UIDevice.currentDevice.name;
    NSString *model = UIDevice.currentDevice.model;
//    NSString *systemName = UIDevice.currentDevice.systemName;
    NSString *systemVersion = UIDevice.currentDevice.systemVersion;
    NSString *system_Version = [systemVersion stringByReplacingOccurrencesOfString:@"." withString:@"_"];
    NSString *UUIDString = UIDevice.currentDevice.identifierForVendor.UUIDString;
    NSString *randomId = [[UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""] substringToIndex:6];
    NSString *userAgent = [NSString stringWithFormat:@"Mozilla/5.0 (%@; CPU %@ OS %@ like Mac OS X) AppleWebKit/602.2.14 (KHTML, like Gecko) Version/%@ Mobile/%@ Safari/602.1",model,model,system_Version,systemVersion,randomId];
//    Log(@"====getiOSUserAgent:%@",userAgent);

    return userAgent;
}

+ (id)getMacUserAgent {
    return @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36";
}


@end
