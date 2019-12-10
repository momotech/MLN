//
//  WebViewController.m
//  LuaTeachApp
//
//  Created by MOMO on 2018/12/24.
//  Copyright © 2018年 MoMo. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>

@interface WebViewController () <WKUIDelegate>

@property (nonatomic, strong) WKWebView *webview;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureNavigationController];
    
    self.webview = [[WKWebView alloc] initWithFrame:self.view.bounds];
    self.webview.backgroundColor = [UIColor whiteColor];
    self.webview.UIDelegate = self;
    [self.view addSubview:self.webview];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
    [self.webview loadRequest:request];
}

- (void)configureNavigationController {
    self.navigationController.navigationBar.backIndicatorImage = [UIImage imageNamed:@"btn_goback"];
    self.navigationController.navigationBar.backIndicatorTransitionMaskImage = [UIImage imageNamed:@"btn_goback"];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:50.0/255 green:50.0/255 blue:51.0/255 alpha:1.f];
    self.navigationController.navigationBar.topItem.title = @" ";
    [self.navigationItem.backBarButtonItem setTitle:@" "];
}

@end
