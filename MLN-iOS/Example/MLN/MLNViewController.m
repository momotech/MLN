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
#import <MLNDevTool/MLNFloatingMenu.h>
#import "MLNGalleryViewController.h"
#import "MLNKitViewController.h"
#import <MLNDevTool/MLNFPSLabel.h>
#import <MLNDevTool/MLNLoadTimeStatistics.h>
#import "MLNGalleryNative.h"

@interface MLNViewController () <MLNKitInstanceErrorHandlerProtocol, MLNViewControllerProtocol, MLNKitInstanceDelegate>

@property (nonatomic, strong) MLNKitInstance *kitInstance;
@property (nonatomic, strong) id<MLNHttpHandlerProtocol> httpHandler;
@property (nonatomic, strong) id<MLNRefreshDelegate> refreshHandler;
@property (nonatomic, strong) id<MLNImageLoaderProtocol> imgLoader;
@property (nonatomic, strong) id<MLNNavigatorHandlerProtocol> navHandler;

@property (nonatomic, strong) MLNKitViewController *kcv;
@property (nonatomic, strong) UIButton *galleryButton;
@property (nonatomic, strong) MLNFPSLabel *fpsLabel;
@property (nonatomic, strong) UILabel *loadTimeLabel;
@property (nonatomic, strong) MLNLoadTimeStatistics *loadTimeStatistics;
@end

@implementation MLNViewController

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
    
    [self setupSubController];
    [self setupSubviews];
}

- (void)setupSubController
{
    NSString *entryFile = @"Main.lua";
    MLNLuaBundle *bundle = [MLNLuaBundle mainBundleWithPath:@"gallery"];
    MLNKitViewController *kcv = [[MLNKitViewController alloc] initWithEntryFilePath:entryFile];
    kcv.kitInstance.delegate = self;
    [kcv regClasses:@[[MLNTestMe class],
                      [MLNStaticTest class],
                      [MLNGlobalVarTest class],
                      [MLNGlobalFuncTest class]]];
    [kcv changeCurrentBundlePath:bundle.bundlePath];
    [self addChildViewController:kcv];
    [self.view addSubview:kcv.view];
    self.kcv = kcv;
}

- (void)setupSubviews
{
    CGFloat galleryButtonW = 80;
    CGFloat galleryButtonH = 30;
    CGFloat galleryButtonX = kScreenWidth - galleryButtonW - 10;
    CGFloat galleryButtonY = 22;
    self.galleryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.galleryButton.frame = CGRectMake(galleryButtonX, galleryButtonY, galleryButtonW, galleryButtonH);
    [self.galleryButton setTitle:@"调试点我" forState:UIControlStateNormal];
    self.galleryButton.backgroundColor = [UIColor orangeColor];
    [self.galleryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.galleryButton addTarget:self action:@selector(galleryButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.galleryButton];
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    self.fpsLabel = [[MLNFPSLabel alloc] initWithFrame:CGRectMake(10, screenHeight * 0.8, 50, 20)];
    [self.kcv.view addSubview:self.fpsLabel];
}

- (void)galleryButtonClicked:(id)sender
{
    MLNGalleryViewController *galleryVc = [[MLNGalleryViewController alloc] init];
    [self presentViewController:galleryVc animated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    [self showLuaScriptLoadTime];
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

#pragma mark - MLNKitInstanceDelegate
- (void)willSetupLuaCore:(MLNKitInstance *)instance
{
    [self.loadTimeStatistics recordStartTime];
    [self.loadTimeStatistics recordLuaCoreCreateStartTime];
}

- (void)didSetupLuaCore:(MLNKitInstance *)instance
{
    [self.loadTimeStatistics recordLuaCoreCreateEndTime];
}

- (void)instance:(MLNKitInstance *)instance willLoad:(NSData *)data fileName:(NSString *)fileName
{
    [self.loadTimeStatistics recordLoadScriptStartTimeWithFileName:fileName];
}

- (void)instance:(MLNKitInstance *)instance didLoad:(NSData *)data fileName:(NSString *)fileName
{
    [self.loadTimeStatistics recordLoadScriptEndTimeWithFileName:fileName];
}

- (void)instance:(MLNKitInstance *)instance didFinishRun:(NSString *)entryFileName
{
    [self.loadTimeStatistics recordEndTime];
}


#pragma mark - Private method

- (void)showLuaScriptLoadTime
{
    [self.kcv.view addSubview:self.loadTimeLabel];
    self.loadTimeLabel.hidden = NO;
    self.loadTimeLabel.text = [NSString stringWithFormat:@"%.0f ms", [self.loadTimeStatistics luaCoreCreateTime] * 1000];
    CGSize loadTimeLabelSize = [self.loadTimeLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    CGFloat loadTimeLabelY = [UIScreen mainScreen].bounds.size.height * 0.75;
    self.loadTimeLabel.frame = CGRectMake(10, loadTimeLabelY, loadTimeLabelSize.width + 10, loadTimeLabelSize.height + 10);
}

- (void)hideLuaScriptLoadTime
{
    self.loadTimeLabel.hidden = YES;
}

- (MLNLoadTimeStatistics *)loadTimeStatistics
{
    if (!_loadTimeStatistics) {
        _loadTimeStatistics = [[MLNLoadTimeStatistics alloc] init];
    }
    return _loadTimeStatistics;
}


- (UILabel *)loadTimeLabel
{
    if (!_loadTimeLabel) {
        _loadTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _loadTimeLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        _loadTimeLabel.textColor = [UIColor whiteColor];
        _loadTimeLabel.font = [UIFont systemFontOfSize:12];
        _loadTimeLabel.textAlignment = NSTextAlignmentCenter;
        _loadTimeLabel.adjustsFontSizeToFitWidth = YES;
        _loadTimeLabel.numberOfLines = 0;
    }
    return _loadTimeLabel;
}


@end
