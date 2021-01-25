//
//  MLNHotLuaViewController.m
//  MLNDebugger_Example
//
//  Created by MoMo on 2019/6/14.
//  Copyright © 2019 MoMo.xiaoning. All rights reserved.
//

#import "MLNHotReloadViewController.h"
#import "MLNHotReload.h"
#import "PBCommandBuilder.h"
#import "MLNDebugPrintFunction.h"
#import <ArgoUI/MLNUIDataBinding.h>
#import <ArgoUI/MLNUIDataBindingCBridge.h>

@interface MLNHotReloadViewController ()
// NavigationBar
@property (nonatomic, assign) BOOL navigationBarTransparent;
@property (nonatomic, strong) UIImage *backgroundImageForBarMetrics;
@property (nonatomic, strong) UIImage *shadowImage;

@end

@implementation MLNHotReloadViewController

- (instancetype)initWithNavigationBarTransparent:(BOOL)transparent
{
    return [self initWithRegisterClasses:nil extraInfo:nil navigationBarTransparent:transparent];
}

- (instancetype)initWithRegisterClasses:(NSArray<Class<MLNExportProtocol>> *)regClasses extraInfo:(NSDictionary *)extraInfo
{
    return [self initWithRegisterClasses:regClasses extraInfo:extraInfo navigationBarTransparent:YES];
}

- (instancetype)initWithRegisterClasses:(nullable NSArray<Class<MLNExportProtocol>> *)regClasses extraInfo:(nullable NSDictionary *)extraInfo navigationBarTransparent:(BOOL)transparent
{
    return [self initWithEntryFilePath:@"" extraInfo:extraInfo regClasses:regClasses navigationBarTransparent:transparent];
}

- (instancetype)initWithEntryFilePath:(NSString *)entryFilePath extraInfo:(nullable NSDictionary *)extraInfo regClasses:(nullable NSArray<Class<MLNExportProtocol>> *)regClasses navigationBarTransparent:(BOOL)transparent
{
    NSMutableArray *regs = [NSMutableArray arrayWithArray:regClasses ? regClasses :@[]];
    [regs addObject: [MLNUIDataBinding class]];
    
    if (self = [super initWithEntryFilePath:entryFilePath extraInfo:extraInfo regClasses:regs]) {
        _navigationBarTransparent = transparent;
    }
    return self;
}

- (instancetype)init
{
    return [self initWithNavigationBarTransparent:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [MLNHotReload getInstance].useArgo = NO;
     __weak typeof(self) wself = self;
    [MLNHotReload getInstance].registerBridgeClassesCallback = ^(MLNKitInstance * _Nonnull instance) {
        __strong typeof(wself) sself = wself;
        if (sself.regClasses) {
            [instance registerClasses:sself.regClasses error:NULL];
        }
    };
    [MLNHotReload getInstance].extraInfoCallback = ^NSDictionary * _Nonnull(NSDictionary * _Nonnull params) {
        __strong typeof(wself) sself = wself;
         NSMutableDictionary *extraInfo = nil;
        if (params) {
            extraInfo = [NSMutableDictionary dictionaryWithDictionary:params];
        }
        if (sself.extraInfo) {
            if (extraInfo) {
                [extraInfo setDictionary:sself.extraInfo];
            } else {
                extraInfo = [NSMutableDictionary dictionaryWithDictionary:sself.extraInfo];
            }
        }
        return extraInfo;
    };
    [[MLNHotReload getInstance] setUpdateCallback:^(MLNKitInstance * _Nonnull instance) {
        __strong typeof(wself) sself = wself;
        @try {
            [sself setValue:instance forKey:@"_kitInstance"];
        } @catch (NSException *exception) {
            NSLog(@"%@", exception);
        };
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (![MLNHotReload getInstance].isUtilViewControllerShow) {
        [[MLNHotReload getInstance] startWithRootView:self.view viewController:self];
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
    [[MLNHotReload getInstance] doLuaViewDidDisappear];
    if (![MLNHotReload getInstance].isUtilViewControllerShow) {
        [[MLNHotReload getInstance] stop];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end



