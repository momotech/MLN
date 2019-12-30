//
//  MLNOfflineViewController.m
//  MLNDevTool
//
//  Created by MoMo on 2019/9/17.
//

#import "MLNOfflineViewController.h"
#import "MLNOfflineDevTool.h"

@interface MLNOfflineViewController ()

@property (nonatomic, weak) MLNKitInstance *kitInstance;

// NavigationBar
@property (nonatomic, assign) BOOL navigationBarTransparent;
@property (nonatomic, strong) UIImage *backgroundImageForBarMetrics;
@property (nonatomic, strong) UIImage *shadowImage;

@end

@implementation MLNOfflineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (![MLNOfflineDevTool getInstance].isUtilViewControllerShow) {
        [[MLNOfflineDevTool getInstance] startWithRootView:self.view viewController:self];
    }
    if (self.navigationBarTransparent) {
        self.backgroundImageForBarMetrics = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
        self.shadowImage = self.navigationController.navigationBar.shadowImage;
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = [UIImage new];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.navigationBarTransparent) {
        [self.navigationController.navigationBar setBackgroundImage:self.backgroundImageForBarMetrics forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:self.shadowImage];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[MLNOfflineDevTool getInstance] doLuaViewDidDisappear];
    if (![MLNOfflineDevTool getInstance].isUtilViewControllerShow) {
        [[MLNOfflineDevTool getInstance] stop];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
