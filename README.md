# libLWWebUI

[![CI Status](https://img.shields.io/travis/luowei/libLWWebUI.svg?style=flat)](https://travis-ci.org/luowei/libLWWebUI)
[![Version](https://img.shields.io/cocoapods/v/libLWWebUI.svg?style=flat)](https://cocoapods.org/pods/libLWWebUI)
[![License](https://img.shields.io/cocoapods/l/libLWWebUI.svg?style=flat)](https://cocoapods.org/pods/libLWWebUI)
[![Platform](https://img.shields.io/cocoapods/p/libLWWebUI.svg?style=flat)](https://cocoapods.org/pods/libLWWebUI)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

```Objective-C
if(@available(iOS 11.0,*)){

    dispatch_group_t group = dispatch_group_create();

    //删除所有cookie，再添加
    [[[WKWebsiteDataStore defaultDataStore] httpCookieStore] getAllCookies:^(NSArray<NSHTTPCookie *> *cookies) {
        for(NSHTTPCookie *cookie in cookies){
            dispatch_group_enter(group);
            [[[WKWebsiteDataStore defaultDataStore] httpCookieStore] deleteCookie:cookie completionHandler:^{
                dispatch_group_leave(group);
            }];
        }
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
```


## Requirements

## Installation

libLWWebUI is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'LWWebUI'
```

**Carthage**
```ruby
github "luowei/LWWebUI"
```

## Author

luowei, luowei@wodedata.com

## License

libLWWebUI is available under the MIT license. See the LICENSE file for more info.
