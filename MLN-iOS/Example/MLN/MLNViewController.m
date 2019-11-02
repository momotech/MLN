//
//  MLNViewController.m
//  MLNCore
//
//  Created by MoMo on 07/23/2019.
//  Copyright (c) 2019 MoMo. All rights reserved.
//

#import "MLNViewController.h"
#import "MLNTestMe.h"
#import "MLNStaticTest.h"
#import "MLNGlobalVarTest.h"
#import "MLNGlobalFuncTest.h"
#import "MLNKitInstance.h"
#import "MLNKitInstanceHandlersManager.h"
#import "MLNMyHttpHandler.h"
#import "MLNMyRefreshHandler.h"
#import "MLNMyImageHandler.h"
#import "MLNNavigatorHandler.h"
#import "MLNHotReloadViewController.h"
#import "MLNOfflineViewController.h"
#import "MLNFPSLabel.h"

@interface MLNViewController () <MLNKitInstanceErrorHandlerProtocol, MLNViewControllerProtocol>

@property (nonatomic, strong) MLNKitInstance *kitInstance;
@property (nonatomic, strong) id<MLNHttpHandlerProtocol> httpHandler;
@property (nonatomic, strong) id<MLNRefreshDelegate> refreshHandler;
@property (nonatomic, strong) id<MLNImageLoaderProtocol> imgLoader;
@property (nonatomic, strong) id<MLNNavigatorHandlerProtocol> navHandler;
@property (nonatomic, strong) MLNKitViewController *kcv;
@property (nonatomic, strong) MLNHotReloadViewController *hotvc;
@property (nonatomic, strong) MLNOfflineViewController *ovc;
@property (nonatomic, strong) MLNFPSLabel *fpsLabel;

@end

@implementation MLNViewController
{
    NSTimeInterval _startTime;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 初始化handlers
    self.httpHandler = [[MLNMyHttpHandler alloc] init];
    self.refreshHandler = [[MLNMyRefreshHandler alloc] init];
    self.imgLoader = [[MLNMyImageHandler alloc] init];
    self.navHandler = [[MLNNavigatorHandler alloc] init];
    
    MLNKitInstanceHandlersManager *handlersManager = [MLNKitInstanceHandlersManager defaultManager];
    handlersManager.errorHandler = self;
    handlersManager.httpHandler = self.httpHandler;
    handlersManager.scrollRefreshHandler = self.refreshHandler;
    handlersManager.imageLoader = self.imgLoader;
    handlersManager.navigatorHandler = self.navHandler;
    
    _startTime = [NSDate date].timeIntervalSince1970;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSLog(@"-------> %f", ([NSDate date].timeIntervalSince1970 - _startTime) * 1000);
}

- (IBAction)showDemoClick:(id)sender {
    NSString *entryFile = @"Main.lua";
    MLNLuaBundle *bundle = [MLNLuaBundle mainBundleWithPath:@"gallery"];
    MLNKitViewController *kcv = [[MLNKitViewController alloc] initWithEntryFilePath:entryFile];
    [kcv regClasses:@[[MLNTestMe class],
                      [MLNStaticTest class],
                      [MLNGlobalVarTest class],
                      [MLNGlobalFuncTest class]]];
    [kcv changeCurrentBundlePath:bundle.bundlePath];
    self.kcv = kcv;
    [self presentViewController:kcv animated:YES completion:nil];
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    self.fpsLabel = [[MLNFPSLabel alloc] initWithFrame:CGRectMake(10, screenHeight * 0.8, 50, 20)];
    [self.kcv.view addSubview:self.fpsLabel];
}


- (IBAction)showHotReload:(id)sender {
    self.hotvc = [[MLNHotReloadViewController alloc] init];
    [self presentViewController:self.hotvc animated:YES completion:nil];
}

- (IBAction)showOffline:(id)sender {
    self.ovc = [[MLNOfflineViewController alloc] init];
    [self presentViewController:self.ovc animated:YES completion:nil];
}

#pragma mark - MLNUIInStanceErrorHandlerProtocol
- (BOOL)canHandleAssert:(MLNKitInstance *)instance
{
    return YES;
}

- (void)instance:(MLNKitInstance *)instance error:(NSString *)error
{
    NSLog(@"%@%@",instance,error);
}

- (void)instance:(MLNKitInstance *)instance luaError:(NSString *)error luaTraceback:(NSString *)luaTraceback
{
    NSLog(@"%@%@",instance,error);
}

@end
