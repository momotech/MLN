//
//  MLNViewController.h
//  MLN
//
//  Created by MoMo on 12/06/2019.
//  Copyright (c) 2019 MoMo. All rights reserved.
//

#import "MLNHomeViewController.h"
#import <MLN/MLNKit.h>
#import "MLNOfflineViewController.h"
#import "MLNHotReloadViewController.h"
#import "MLNMyRefreshHandler.h"
#import "MLNMyHttpHandler.h"
#import "MLNMyImageHandler.h"
#import <SDWebImage/SDImageCodersManager.h>
#import "MLNNavigatorHandler.h"
#import "MLNLuaGalleryViewController.h"
#import "MLNDemoListViewController.h"
#import "MLNStaticTest.h"
#import "MLNTestMe.h"
#import <MLNDataBinding.h>
#import <NSArray+MLNKVO.h>

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
@property (nonatomic, strong) MLNTestMe *model;
@property (nonatomic, strong) NSMutableArray *modelArray;
@end

@implementation MLNHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    MLNTestMe *m = [MLNTestMe new];
    m.text = @"init";
    m.open = YES;
    self.model = m;
    [self bindArray];
    [self test];
}

- (void)bindArray {
    NSMutableArray *arr = @[].mutableCopy;
    for (int i = 0; i < 2; i++) {
        MLNTestMe *m = [MLNTestMe new];
        m.text = [NSString stringWithFormat:@"hello %d",i];
        [arr addObject:m];
    }
    self.modelArray = arr;
    [self testArray];
}

- (void)testArray {
    static int i = 1;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        MLNTestMe *m = [MLNTestMe new];
        m.text = [NSString stringWithFormat:@"add %d",i++];
        [self.modelArray addObject:m];
        [self testArray];
    });
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

- (void)test {
    static int cnt = 1;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self test];
        self.model.text = [NSString stringWithFormat:@"hello %d",cnt++];
    });
}

- (IBAction)hotReloadAction:(id)sender {
    MLNHotReloadViewController  *hotReloadVC = [[MLNHotReloadViewController alloc] initWithRegisterClasses:@[[MLNStaticTest class]] extraInfo:nil];
    [hotReloadVC bindData:self.model forKey:@"userData"];
    
    
    NSMutableArray *models = self.modelArray;
    models.mln_resueIdBlock = ^NSString * _Nonnull(NSArray * _Nonnull items, NSUInteger section, NSUInteger row) {
        return @"TYPE_CELL_TEXT";
    };
    models.mln_heightBlock = ^NSUInteger(NSArray * _Nonnull items, NSUInteger section, NSUInteger row) {
        return 50;
    };
    [hotReloadVC.dataBinding bindArray:models forKey:@"source"];
    
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
