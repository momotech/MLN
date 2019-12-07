//
//  ViewController.m
//  LuaTeachApp
//
//  Created by yeye(* ￣＾￣) on 2018/12/20.
//  Copyright © 2018年 com.test. All rights reserved.
//

#import "MLNHomeViewController.h"
#import <MLNKit.h>
#import "MLNOfflineViewController.h"
#import "MLNHotReloadViewController.h"
#import "WebViewController.h"
#import "MLNMyRefreshHandler.h"
#import "MLNMyHttpHandler.h"
#import "MLNMyImageHandler.h"
#import <SDWebImage/SDImageCodersManager.h>
#import "MLNNavigatorHandler.h"
#import "MLNViewController.h"
#import "MLNDemoListViewController.h"

#define kConsoleWidth 250.f
#define kConsoleHeight 280.f

static NSInteger kButtonTagOffset = 1001;

@interface MLNHomeViewController ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIView *loadingIndicatorBgView;

@property (weak, nonatomic) IBOutlet UILabel *toastLabel;
@property (weak, nonatomic) IBOutlet UIView *toastBgView;

///4个 button
@property (nonatomic, strong) NSArray *buttonsTitleArray;
@property (nonatomic, strong) NSArray *buttonsUrlArray;

@property (nonatomic, strong) MLNHotReloadViewController *luaVC;
@property (nonatomic, strong) MLNOfflineViewController *offlineViewController;

@property (nonatomic, strong) MLNMyImageHandler *imageHandler;
@property (nonatomic, strong) MLNMyRefreshHandler *refreshHandler;
@property (nonatomic, strong) MLNMyHttpHandler *httpHandler;
@property (nonatomic, strong) MLNNavigatorHandler *navHandler;

@end

@implementation MLNHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    MLNKitInstanceHandlersManager *handlersManager = [MLNKitInstanceHandlersManager defaultManager];
    handlersManager.httpHandler = self.httpHandler;
    handlersManager.scrollRefreshHandler = self.refreshHandler;
    handlersManager.imageLoader = self.imageHandler;
    handlersManager.navigatorHandler = self.navHandler;
    
//    [self configButtonsUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (void)configButtonsUI {
    self.buttonsTitleArray = @[@"教程",
                               @"实例",
                               @"资讯",
                               @"关于"];
    self.buttonsUrlArray = @[@"http://beta.apa.wemomo.com:8002/zh-cn/docs/build_dev_environment.html",
                             @"http://beta.apa.wemomo.com:8002/zh-cn/api/NewListView.lua.html",
                             @"https://github.com/wemomo",
                             @"http://beta.apa.wemomo.com:8002/zh-cn/"];
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat buttonWidth = screenWidth/2;
    CGFloat buttonHeight = buttonWidth * 0.56;
    CGFloat buttonStartY = screenHeight - 2 * buttonHeight;
    
    for (NSInteger i = 0; i < self.buttonsTitleArray.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
        [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:24.f];
        [btn setTitle:self.buttonsTitleArray[i] forState:UIControlStateNormal];
        btn.frame = CGRectMake((i % 2) * buttonWidth,
                               buttonStartY + (i / 2) * buttonHeight,
                               buttonWidth,
                               buttonHeight);
        btn.tag = kButtonTagOffset + i;
        [btn addTarget:self action:@selector(onclickButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
    //加上3根线。
    UIView *view1 = [UIView new];
    view1.backgroundColor = [UIColor lightGrayColor];
    view1.frame = CGRectMake(0, buttonStartY, screenWidth, 0.5);
    [self.view addSubview:view1];
    
    UIView *view2 = [UIView new];
    view2.backgroundColor = [UIColor lightGrayColor];
    view2.frame = CGRectMake(0, buttonStartY + buttonHeight, screenWidth, 0.5);
    [self.view addSubview:view2];
    
    UIView *view3 = [UIView new];
    view3.backgroundColor = [UIColor lightGrayColor];
    view3.frame = CGRectMake(buttonWidth, buttonStartY, 0.5, 2 * buttonHeight);
    [self.view addSubview:view3];
}

- (void)onclickButton:(UIButton *)btn {
    NSInteger btnIndex = btn.tag - kButtonTagOffset;
    NSString *urlString = self.buttonsUrlArray[btnIndex];
    
    WebViewController *webViewController = [WebViewController new];
    webViewController.urlString = urlString;
    [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma mark - accessor
- (MLNMyHttpHandler *)httpHandler
{
    if (!_httpHandler) {
        _httpHandler = [[MLNMyHttpHandler alloc] init];
    }
    return _httpHandler;
}

- (MLNMyImageHandler *)imageHandler
{
    if (!_imageHandler) {
        _imageHandler = [[MLNMyImageHandler alloc] init];
    }
    return _imageHandler;
}

- (MLNMyRefreshHandler *)refreshHandler
{
    if (!_refreshHandler) {
        _refreshHandler = [[MLNMyRefreshHandler alloc] init];
    }
    return _refreshHandler;
}

- (MLNNavigatorHandler *)navHandler
{
    if (!_navHandler) {
        _navHandler = [[MLNNavigatorHandler alloc] init];
    }
    return _navHandler;
}

- (void)hideToast {
    self.toastBgView.hidden = YES;
}

#pragma mark - action

- (IBAction)hotReloadAction:(id)sender {
    MLNHotReloadViewController  *hotReloadVC = [[MLNHotReloadViewController alloc] init];
    [self.navigationController pushViewController:hotReloadVC animated:YES];
}

- (IBAction)onclickQRCodeButton:(id)sender {
    [self.navigationController pushViewController:[[MLNHotReloadViewController alloc] initWithNavigationBarTransparent:YES]  animated:YES];
}

- (IBAction)demoListButtonAction:(id)sender {
    MLNDemoListViewController *listVC = [[MLNDemoListViewController alloc] init];
    [self.navigationController pushViewController:listVC animated:YES];
}

- (IBAction)meilishuoButtonAction:(id)sender {
    MLNViewController *viewController = [[MLNViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}



@end
