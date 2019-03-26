//
// Created by Luo Wei on 2017/5/8.
// Copyright (c) 2017 luowei. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef DEBUG
#define LWWKLog(fmt, ...) NSLog((@"%s [Line %d]\n" fmt @"\n\n\n"), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define LWWKLog(...)
#endif

@class LWWKWebView;

@interface UIView (LWWKSuperRecurse)
//获得指class类型的父视图
- (id)lwwk_superViewWithClass:(Class)clazz;
@end

@interface UIPrintPageRenderer (LWWKPDF)
- (NSData*)lwwk_printToPDF;
@end

@interface LWWKWebViewController : UIViewController

@property (nonatomic, strong) LWWKWebView *wkWebView;
@property (strong, nonatomic) UIProgressView *webProgress;

@property(nonatomic, strong) NSURL *url;

+ (LWWKWebViewController *)loadURL:(NSURL *)url;

+ (LWWKWebViewController *)wkWebViewControllerWithURL:(NSURL *)url;

+ (LWWKWebViewController *)loadHTMLString:(NSString *)htmlString baseURL:(nullable NSURL *)baseURL;

- (void)loadURL:(NSURL *)url;

//加载htmlString
- (void)loadHTMLString:(NSString *)htmlString baseURL:(nullable NSURL *)baseURL;

@end


UIKIT_EXTERN UIActivityType const UIActivityTypeOpenInSafari;

@interface LWWebViewMoreActivity : UIActivity

@property(nonatomic, strong) NSURL *URL;

@property(nonatomic, strong) UIImage *iphoneImg;
@property(nonatomic, strong) UIImage *ipadImg;

- (instancetype)initWithiphoneImage:(UIImage *)iphoneImg ipadImage:(UIImage *)ipadImg;

@end



UIKIT_EXTERN UIActivityType const UIActivityTypePDFPrintActivity;

@interface LWPDFPrintActivity : UIActivity


@property(nonatomic, strong) UIImage *iphoneImg;
@property(nonatomic, strong) UIImage *ipadImg;

@property(nonatomic, strong) UIView *printView;

@property(nonatomic, copy) NSString *title;

- (instancetype)initWithiphoneImage:(UIImage *)iphoneImg ipadImage:(UIImage *)ipadImg;

@end