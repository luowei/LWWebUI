//
//  LWViewController.m
//  libLWWebUI
//
//  Created by luowei on 03/25/2019.
//  Copyright (c) 2019 luowei. All rights reserved.
//

#import <libLWWebUI/libLWWebUI-umbrella.h>
#import "LWViewController.h"
#import "LWWKWebViewController.h"
#import "LWWKWebView.h"

@interface LWViewController ()

@end

@implementation LWViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnAction:(UIButton *)sender {
    if(@available(iOS 11.0,*)){

        dispatch_group_t group = dispatch_group_create();

        //删除所有cookie，再添加
        dispatch_group_enter(group);
        [[[WKWebsiteDataStore defaultDataStore] httpCookieStore] getAllCookies:^(NSArray<NSHTTPCookie *> *cookies) {
            for(NSHTTPCookie *cookie in cookies){
                dispatch_group_enter(group);
                [[[WKWebsiteDataStore defaultDataStore] httpCookieStore] deleteCookie:cookie completionHandler:^{
                    dispatch_group_leave(group);
                }];
            }
            dispatch_group_leave(group);
        }];

//        dispatch_group_async(group, dispatch_get_current_queue(), ^{
//        dispatch_group_async(group, dispatch_get_main_queue(), ^{
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            [self setupCookies];
            LWWKWebViewController *webVC = [LWWKWebViewController wkWebViewControllerWithURL:[NSURL URLWithString:@"http://wodedata.com/index.php/blog"]];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webVC];
            [self presentViewController:nav animated:YES completion:nil];
        });

    } else{
        [self setupCookies];
        LWWKWebViewController *webVC = [LWWKWebViewController wkWebViewControllerWithURL:[NSURL URLWithString:@"http://wodedata.com/index.php/blog"]];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webVC];
        [self presentViewController:nav animated:YES completion:nil];
    }

//    [self.view lwwk_openURLWithUrl:[NSURL URLWithString:@"tel://1582140005"]];

}

-(void)setupCookies{
    NSHTTPCookie *a = [self cookieWithCookieDomain:@"wodedata.com" cookieName:@"aaa" cookieValue:@"aaaaaValue"];
    NSHTTPCookie *b = [self cookieWithCookieDomain:@"wodedata.com" cookieName:@"bbb" cookieValue:@"bbbbbValue"];
    NSHTTPCookie *c = [self cookieWithCookieDomain:@"wodedata.com" cookieName:@"ccc" cookieValue:@"cccccValue"];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:a];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:b];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:c];
//    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:@[a,b,c] forURL:<#(nullable NSURL *)URL#> mainDocumentURL:<#(nullable NSURL *)mainDocumentURL#>];
}

- (NSHTTPCookie *)cookieWithCookieDomain:(NSString *)cookieDomain cookieName:(NSString *)cookieName  cookieValue:(NSString *)cookieValue {
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    properties[NSHTTPCookieName] = cookieName;
    properties[NSHTTPCookieValue] = cookieValue;
    properties[NSHTTPCookieDomain] = cookieDomain;
    properties[NSHTTPCookiePath] = @"/";

//    [properties setObject:@(365 * 86400) forKey:NSHTTPCookieMaximumAge];
//    properties[NSHTTPCookieExpires] = [NSDate dateWithTimeInterval:365 * 86400 sinceDate:[NSDate new] ];  //1年
    properties[NSHTTPCookieMaximumAge] = @86400;    //1天

    NSHTTPCookie *accessCookie = [[NSHTTPCookie alloc] initWithProperties:properties];
    return accessCookie;
}

@end
