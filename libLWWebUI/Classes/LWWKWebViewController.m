//
// Created by Luo Wei on 2017/5/8.
// Copyright (c) 2017 luowei. All rights reserved.
//

#import "LWWKWebViewController.h"
#import "LWWKWebView.h"
#import "Masonry.h"


@implementation UIView (LWWKSuperRecurse)

//获得指class类型的父视图
- (id)lwwk_superViewWithClass:(Class)clazz {
    UIResponder *responder = self;
    while (![responder isKindOfClass:clazz]) {
        responder = [responder nextResponder];
        if (nil == responder) {
            break;
        }
    }
    return responder;
}

@end


@implementation UIPrintPageRenderer (LWWKPDF)

- (NSData *)lwwk_printToPDF {
    NSMutableData *pdfData = [NSMutableData data];
    UIGraphicsBeginPDFContextToData(pdfData, self.paperRect, nil);
    [self prepareForDrawingPages:NSMakeRange(0, (NSUInteger) self.numberOfPages)];

    CGRect bounds = UIGraphicsGetPDFContextBounds();
    for (int i = 0; i < self.numberOfPages; i++) {
        UIGraphicsBeginPDFPage();
        [self drawPageAtIndex:i inRect:bounds];
    }

    UIGraphicsEndPDFContext();
    return pdfData;
}

@end


@interface LWWKWebViewController ()

@property(nonatomic, copy) NSString *HTMLString;
@property(nonatomic, strong) NSURL *HTMLStringBaseURL;

@end

@implementation LWWKWebViewController {

}

+ (LWWKWebViewController *)loadURL:(NSURL *)url {
    LWWKWebViewController *wkWebVC = [LWWKWebViewController wkWebViewControllerWithURL:url];
    return wkWebVC;
}

+ (LWWKWebViewController *)wkWebViewControllerWithURL:(NSURL *)url {
    LWWKWebViewController *wkWebVC = [LWWKWebViewController new];
    wkWebVC.url = url;
    return wkWebVC;
}

+ (LWWKWebViewController *)loadHTMLString:(NSString *)htmlString baseURL:(nullable NSURL *)baseURL{
    LWWKWebViewController *wkWebVC = [LWWKWebViewController new];
    wkWebVC.HTMLString = htmlString;
    wkWebVC.HTMLStringBaseURL = baseURL;
    return wkWebVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    UIImage *image = [UIImage imageNamed:@"more_dot" inBundle:LWWKWebBundle(self) compatibleWithTraitCollection:nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
            initWithImage:image
                    style:UIBarButtonItemStylePlain
                   target:self
                   action:@selector(moreAction:)];

    //添加webview
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = [LWWKUserContentController shareInstance];
    self.wkWebView = [[LWWKWebView alloc] initWithFrame:self.view.frame configuration:configuration];
    [self.view addSubview:self.wkWebView];

    [self.wkWebView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];

    //进度条
    self.webProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 2)];
    [self.view addSubview:self.webProgress];

    [self.webProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view).offset(0);
        make.top.equalTo(self.view).offset(0);
        make.height.mas_equalTo(2);
    }];

    //更新刷新进度条的block
    __weak __typeof(self) weakSelf = self;
    self.wkWebView.finishNavigationProgressBlock = ^() {
        weakSelf.webProgress.hidden = NO;
        [weakSelf.webProgress setProgress:0.0 animated:NO];
        weakSelf.webProgress.trackTintColor = [UIColor whiteColor];
    };

    //删除监听
    self.wkWebView.removeProgressObserverBlock = ^() {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [weakSelf.wkWebView removeObserver:strongSelf forKeyPath:@"estimatedProgress"];
        [weakSelf.wkWebView removeObserver:strongSelf forKeyPath:@"title"];
    };

    //添加对webView的监听器
    if (self.wkWebView) {
        [self.wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
        [self.wkWebView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    }

    if(self.url){
        [self loadURL:self.url];
    }else if(self.HTMLString){
        [self loadHTMLString:self.HTMLString baseURL:self.HTMLStringBaseURL];
    }

}

- (void)moreAction:(UIBarButtonItem *)moreBtn {

    //添加一个Safari浏览打开的图标
    //NSString *textItem = self.wkWebView.URL.absoluteString;
    NSArray *items = @[self.wkWebView.URL];

    UIImage *safari50Image = [UIImage imageNamed:@"Safari50" inBundle:LWWKWebBundle(self) compatibleWithTraitCollection:nil];
    UIImage *safari53Image = [UIImage imageNamed:@"Safari53" inBundle:LWWKWebBundle(self) compatibleWithTraitCollection:nil];
    UIImage *pdfPrint50Image = [UIImage imageNamed:@"pdfPrint50" inBundle:LWWKWebBundle(self) compatibleWithTraitCollection:nil];
    UIImage *pdfPrint53Image = [UIImage imageNamed:@"pdfPrint53" inBundle:LWWKWebBundle(self) compatibleWithTraitCollection:nil];

    LWWebViewMoreActivity *webViewMoreActivity = [[LWWebViewMoreActivity alloc] initWithiphoneImage:safari50Image ipadImage:safari53Image];
    webViewMoreActivity.URL = self.wkWebView.URL;

    //添加导出pdf
    LWPDFPrintActivity *pdfPrintActivity = [[LWPDFPrintActivity alloc] initWithiphoneImage:pdfPrint50Image ipadImage:pdfPrint53Image];
    pdfPrintActivity.printView = self.wkWebView;
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:@[webViewMoreActivity,pdfPrintActivity]];
    activityVC.excludedActivityTypes = @[UIActivityTypePostToVimeo,UIActivityTypeMail,UIActivityTypeMail,UIActivityTypePostToFlickr, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll];

    //显示弹出层
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:activityVC];
        CGRect rect = [[UIScreen mainScreen] bounds];
        [popoverController presentPopoverFromRect:rect inView:self.view permittedArrowDirections:0 animated:YES];
    } else {
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}

- (void)dealloc {
    if (self.wkWebView) {
        [self.wkWebView removeObserver:self forKeyPath:@"estimatedProgress" context:nil];
        [self.wkWebView removeObserver:self forKeyPath:@"title" context:nil];
    }
}

#pragma mark - KVO Observe

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        BOOL animated = self.wkWebView.estimatedProgress > self.webProgress.progress;
        [self.webProgress setProgress:(float) self.wkWebView.estimatedProgress animated:animated];

        //加载完成隐藏进度条
        if (self.wkWebView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.webProgress.hidden = YES;
            }                completion:^(BOOL finished) {
                [self.webProgress setProgress:0.0f animated:NO];
            }];
        }
    }
    if ([keyPath isEqualToString:@"title"]) {
        self.title = self.wkWebView.title;
    }
}


//加载URL
- (void)loadURL:(NSURL *)url {
    [self.wkWebView loadRequest:[NSURLRequest requestWithURL:url]];
}

//加载htmlString
- (void)loadHTMLString:(NSString *)htmlString baseURL:(nullable NSURL *)baseURL{
    [self.wkWebView loadHTMLString:htmlString baseURL:baseURL];
}

@end


NSString *const UIActivityTypeOpenInSafari = @"OpenInSafariActivityMine";

@implementation LWWebViewMoreActivity

- (instancetype)initWithiphoneImage:(UIImage *)iphoneImg ipadImage:(UIImage *)ipadImg {
    self = [super init];
    if (self) {
        self.iphoneImg = iphoneImg;
        self.ipadImg = ipadImg;
    }

    return self;
}


- (UIActivityType)activityType {
    return UIActivityTypeOpenInSafari;
}

- (NSString *)activityTitle {
//    return NSLocalizedString(@"Open in Safari", nil);
    return NSLocalizedStringFromTableInBundle(@"Open in Safari", @"Local", LWWKWebBundle(self), nil);
}

- (UIImage *)activityImage {
    // Note: These images need to have a transparent background and I recommend these sizes:
    // iPadShare@2x should be 126 px, iPadShare should be 53 px, iPhoneShare@2x should be 100
    // px, and iPhoneShare should be 50 px. I found these sizes to work for what I was making.

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return self.ipadImg;
    } else {
        return self.iphoneImg;
    }
}

+ (UIActivityCategory)activityCategory {
    LWWKLog(@"--------%d:%s \n\n", __LINE__, __func__);
    //return [super activityCategory];
    return UIActivityCategoryShare;
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    LWWKLog(@"--------%d:%s \n\n", __LINE__, __func__);
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    LWWKLog(@"--------%d:%s \n\n", __LINE__, __func__);
    [super prepareWithActivityItems:activityItems];
}

- (void)performActivity {
    if(@available(iOS 10.0,*)){
        [[UIApplication sharedApplication] openURL:self.URL options:@{} completionHandler:nil];
    }else {
        [[UIApplication sharedApplication] openURL:self.URL];
    }
    [self activityDidFinish:YES];
}


@end


//导出PDF
NSString *const UIActivityTypePDFPrintActivity = @"PDFPrintActivityActivityMine";

@implementation LWPDFPrintActivity

- (instancetype)initWithiphoneImage:(UIImage *)iphoneImg ipadImage:(UIImage *)ipadImg {
    self = [super init];
    if (self) {
        self.iphoneImg = iphoneImg;
        self.ipadImg = ipadImg;
    }

    return self;
}


- (UIActivityType)activityType {
    return UIActivityTypePDFPrintActivity;
}

- (NSString *)activityTitle {
//    return NSLocalizedString(@"Export PDF", nil);
    return NSLocalizedStringFromTableInBundle(@"Export PDF", @"Local", LWWKWebBundle(self), nil);
}

- (UIImage *)activityImage {
    // Note: These images need to have a transparent background and I recommend these sizes:
    // iPadShare@2x should be 126 px, iPadShare should be 53 px, iPhoneShare@2x should be 100
    // px, and iPhoneShare should be 50 px. I found these sizes to work for what I was making.

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return self.ipadImg;
    } else {
        return self.iphoneImg;
    }
}

+ (UIActivityCategory)activityCategory {
    LWWKLog(@"--------%d:%s \n\n", __LINE__, __func__);
    //return [super activityCategory];
    return UIActivityCategoryAction;
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    LWWKLog(@"--------%d:%s \n\n", __LINE__, __func__);
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    LWWKLog(@"--------%d:%s \n\n", __LINE__, __func__);
    [super prepareWithActivityItems:activityItems];
}


//参考:http://www.papersizes.org/a-sizes-in-pixels.htm
#define kPaperSizeA3 CGSizeMake(842 , 1191)
#define kPaperSizeA4 CGSizeMake(595 , 842)
#define kPaperSizeA5 CGSizeMake(420 , 595)
#define kPaperSizeA6 CGSizeMake(298 , 420)

#define kPaperSize ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? kPaperSizeA4 : kPaperSizeA6)

- (void)performActivity {

    UIPrintPageRenderer *render = [[UIPrintPageRenderer alloc] init];
    [render addPrintFormatter:self.printView.viewPrintFormatter startingAtPageAtIndex:0];

    //increase these values according to your requirement
    float topPadding = 10.0f;
    float bottomPadding = 10.0f;
    float leftPadding = 10.0f;
    float rightPadding = 10.0f;
    CGRect printableRect = CGRectMake(leftPadding,topPadding,kPaperSize.width - leftPadding - rightPadding,kPaperSize.height - topPadding - bottomPadding);
    CGRect paperRect = CGRectMake(0, 0, kPaperSize.width, kPaperSize.height);

    [render setValue:[NSValue valueWithCGRect:paperRect] forKey:@"paperRect"];
    [render setValue:[NSValue valueWithCGRect:printableRect] forKey:@"printableRect"];
    NSData *pdfData = [render lwwk_printToPDF];

    NSString *title = NSLocalizedStringFromTableInBundle(@"Export PDF", @"Local", LWWKWebBundle(self), nil);
    if([self.printView isKindOfClass:[WKWebView class]]){
        title = self.title;
        if(!title || title.length == 0){
            title = ((WKWebView *)self.printView).title;
        }
        if(!title || title.length == 0){
            title = NSLocalizedStringFromTableInBundle(@"Export PDF", @"Local", LWWKWebBundle(self), nil);
        }
        NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*|\"<>"];
        title = [[title componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@"_"];
    }

    if (pdfData) {
        NSString *pdfPath = [NSString stringWithFormat:@"%@%@.pdf", NSTemporaryDirectory(),title];
        [pdfData writeToFile:pdfPath atomically:YES];

        //分享
        NSURL *url = [NSURL fileURLWithPath:pdfPath];
        if(!url){
            return;
        }
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[title, url] applicationActivities:nil];
        UIViewController *vc = [self.printView lwwk_superViewWithClass:[UIViewController class]];
        //显示弹出层
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:activityVC];
            CGRect rect = [[UIScreen mainScreen] bounds];
            [popoverController presentPopoverFromRect:rect inView:vc.view permittedArrowDirections:0 animated:YES];
        } else {
            [vc presentViewController:activityVC animated:YES completion:nil];
        }

    } else {
        NSLog(@"PDF couldnot be created");
    }

    [self activityDidFinish:YES];
}


@end


