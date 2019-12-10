//
//  MLNViewController.h
//  MLN
//
//  Created by MoMo on 12/06/2019.
//  Copyright (c) 2019 MoMo. All rights reserved.
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
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
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

- (IBAction)demoListButtonAction:(id)sender {
    MLNDemoListViewController *listVC = [[MLNDemoListViewController alloc] init];
    [self.navigationController pushViewController:listVC animated:YES];
}

- (IBAction)meilishuoButtonAction:(id)sender {
    MLNViewController *viewController = [[MLNViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}



@end
