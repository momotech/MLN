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
#import "MLNMyRefreshHandler.h"
#import "MLNMyHttpHandler.h"
#import "MLNMyImageHandler.h"
#import <SDWebImage/SDImageCodersManager.h>
#import "MLNNavigatorHandler.h"
#import "MLNLuaGalleryViewController.h"
#import "MLNDemoListViewController.h"

#define kConsoleWidth 250.f
#define kConsoleHeight 280.f

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

@end

@implementation MLNHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    self.navigationController.navigationBar.alpha = 0;
    [super viewWillDisappear:animated];
}

#pragma mark - accessor
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
    MLNLuaGalleryViewController *viewController = [[MLNLuaGalleryViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
