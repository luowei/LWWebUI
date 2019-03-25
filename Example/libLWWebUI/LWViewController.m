//
//  LWViewController.m
//  libLWWebUI
//
//  Created by luowei on 03/25/2019.
//  Copyright (c) 2019 luowei. All rights reserved.
//

#import "LWViewController.h"
#import "LWWKWebViewController.h"

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
    LWWKWebViewController *webVC = [LWWKWebViewController wkWebViewControllerWithURL:[NSURL URLWithString:@"https://m.baidu.com"]];
    [self presentViewController:webVC  animated:YES completion:^{
    }];
}

@end
