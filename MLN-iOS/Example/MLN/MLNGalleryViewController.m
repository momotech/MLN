//
//  MLNGalleryViewController.m
//  MLN_Example
//
//  Created by MoMo on 2019/11/4.
//  Copyright (c) 2019 MoMo. All rights reserved.
//

#import "MLNGalleryViewController.h"
#import "MLNTestMe.h"
#import "MLNStaticTest.h"
#import "MLNGlobalVarTest.h"
#import "MLNGlobalFuncTest.h"
#import "MLNHotReloadViewController.h"
#import "MLNOfflineViewController.h"
#import <MLNDevTool/MLNFPSLabel.h>
#import <MLNDevTool/MLNLoadTimeStatistics.h>
#import "MLNGalleryMainViewController.h"

@interface MLNGalleryViewController () <MLNKitInstanceDelegate, MLNKitViewControllerDelegate>

@property (nonatomic, strong) MLNKitViewController *kcv;
@property (nonatomic, strong) MLNHotReloadViewController *hotvc;
@property (nonatomic, strong) MLNOfflineViewController *ovc;
@property (nonatomic, strong) MLNGalleryMainViewController *galleryMainVc;

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *showDemoButton;
@property (nonatomic, strong) UIButton *showHotReloadButton;
@property (nonatomic, strong) UIButton *showOfflineButton;
@property (nonatomic, strong) UIButton *showNativeDemoButton;

@property (nonatomic, strong) MLNFPSLabel *fpsLabel;
@property (nonatomic, strong) UILabel *loadTimeLabel;
@property (nonatomic, strong) MLNLoadTimeStatistics *loadTimeStatistics;

@end

@implementation MLNGalleryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupSubviews];
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeGesture];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self showLuaScriptLoadTime];
}

- (void)swipe:(UIGestureRecognizer *)gesture
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showDemoClick:(id)sender {
    NSString *entryFile = @"Main.lua";
    MLNLuaBundle *bundle = [MLNLuaBundle mainBundleWithPath:@"gallery"];
    MLNKitViewController *kcv = [[MLNKitViewController alloc] initWithEntryFilePath:entryFile];
    kcv.delegate = self;
    [kcv regClasses:@[[MLNTestMe class],
                      [MLNStaticTest class],
                      [MLNGlobalVarTest class],
                      [MLNGlobalFuncTest class]]];
    [kcv changeCurrentBundlePath:bundle.bundlePath];
    self.kcv = kcv;
    [self.navigationController pushViewController:self.kcv animated:YES];
}


- (void)showHotReload:(id)sender {
    self.hotvc = [[MLNHotReloadViewController alloc] init];
    [self.navigationController pushViewController:self.hotvc animated:YES];
}

- (void)showOffline:(id)sender {
    self.ovc = [[MLNOfflineViewController alloc] init];
    [self.navigationController pushViewController:self.ovc animated:YES];
}

- (void)showNativeDemo:(id)sender
{
    [[MLNLoadTimeStatistics sharedInstance] recordStartTime];
    self.galleryMainVc = [[MLNGalleryMainViewController alloc] init];
    [self.navigationController pushViewController:self.galleryMainVc animated:YES];
}


#pragma mark - Private method

- (void)showLuaScriptLoadTime
{
    if (!_loadTimeLabel) {
        CGFloat loadTimeLabelY = [UIScreen mainScreen].bounds.size.height * 0.7;
        _loadTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, loadTimeLabelY, 50, 50)];
        _loadTimeLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        _loadTimeLabel.textColor = [UIColor whiteColor];
        _loadTimeLabel.font = [UIFont systemFontOfSize:12];
        _loadTimeLabel.textAlignment = NSTextAlignmentCenter;
        _loadTimeLabel.adjustsFontSizeToFitWidth = YES;
        _loadTimeLabel.numberOfLines = 0;
        [self.kcv.view addSubview:_loadTimeLabel];
    }

    [self.kcv.view bringSubviewToFront:_loadTimeLabel];
    self->_loadTimeLabel.hidden = NO;
    self->_loadTimeLabel.text = [NSString stringWithFormat:@"%.0f ms\n%.0f ms\n%.0f ms\n", [self.loadTimeStatistics luaCoreCreateTime] * 1000, [self.loadTimeStatistics loadScriptTime] * 1000, [self.loadTimeStatistics allLoadTime] * 1000];
}

- (void)hideLuaScriptLoadTime
{
    self->_loadTimeLabel.hidden = YES;
}

- (void)setupSubviews
{
    [self backButton];
    
    CGFloat buttonW = 140;
    CGFloat buttonH = 40;
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    CGFloat space = 20;
    
    CGFloat showDemoButtonX = (screenW - buttonW) / 2.0;
    CGFloat showDemoButtonY = (screenH - buttonH) / 2.0 - space - buttonH;
    self.showDemoButton = [self createButtonWithTitle:@"Demo 展示" action:@selector(showDemoClick:)];
    self.showDemoButton.frame = CGRectMake(showDemoButtonX, showDemoButtonY, buttonW, buttonH);
    self.showDemoButton.hidden = YES;
    [self.view addSubview:self.showDemoButton];
    
    CGFloat showHotReloadButtonX = showDemoButtonX;
    CGFloat showHotReloadButtonY = (screenH - buttonH) / 2.0;
    self.showHotReloadButton = [self createButtonWithTitle:@"热重载" action:@selector(showHotReload:)];
    self.showHotReloadButton.frame = CGRectMake(showHotReloadButtonX, showHotReloadButtonY, buttonW, buttonH);
    [self.view addSubview:self.showHotReloadButton];
    
    CGFloat showNativeDemoButtonX = showDemoButtonX;
    CGFloat showNativeDemoButtonY = (screenH - buttonH) / 2.0 + space + buttonH;
    self.showNativeDemoButton = [self createButtonWithTitle:@"NativeDemo展示" action:@selector(showNativeDemo:)];
    self.showNativeDemoButton.frame = CGRectMake(showNativeDemoButtonX, showNativeDemoButtonY, buttonW, buttonH);
    [self.view addSubview:self.showNativeDemoButton];
    
    CGFloat showOfflineButtonX = showDemoButtonX;
    CGFloat showOfflineButtonY = showNativeDemoButtonY + buttonH + space;
    self.showOfflineButton = [self createButtonWithTitle:@"离线加载" action:@selector(showOfflineButton)];
    self.showOfflineButton.frame = CGRectMake(showOfflineButtonX, showOfflineButtonY, buttonW, buttonH);
    self.showOfflineButton.hidden = YES;
    [self.view addSubview:self.showOfflineButton];
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    self.fpsLabel = [[MLNFPSLabel alloc] initWithFrame:CGRectMake(10, screenHeight * 0.8, 50, 20)];
    [self.kcv.view addSubview:self.fpsLabel];
}

- (UIButton *)createButtonWithTitle:(NSString *)title action:(SEL)aSelector
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    button.backgroundColor = [UIColor orangeColor];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:aSelector forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (void)back:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIButton *)backButton
{
    if (!_backButton) {
        _backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 120, 30)];
        _backButton.backgroundColor = [UIColor orangeColor];
        [_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_backButton setTitle:@"点我/侧滑返回" forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_backButton];
    }
    return _backButton;
}

- (MLNLoadTimeStatistics *)loadTimeStatistics
{
    if (!_loadTimeStatistics) {
        _loadTimeStatistics = [[MLNLoadTimeStatistics alloc] init];
    }
    return _loadTimeStatistics;
}


@end

