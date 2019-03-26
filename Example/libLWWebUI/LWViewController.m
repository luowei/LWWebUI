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
//    LWWKWebViewController *webVC = [LWWKWebViewController wkWebViewControllerWithURL:[NSURL URLWithString:@"https://m.baidu.com"]];
//    [self.navigationController pushViewController:webVC animated:YES];

    [self.view lwwk_openURLWithUrl:[NSURL URLWithString:@"tel://1582140005"]];

}

@end
