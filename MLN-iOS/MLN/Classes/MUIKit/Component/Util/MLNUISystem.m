//
//  MLNUISystem.m
//  MLNUI
//
//  Created by MoMo on 2019/8/5.
//

#import "MLNUISystem.h"
#import "MLNUIKitHeader.h"
#import "MLNUIVersion.h"
#import "MLNUIBlock.h"
#import "MLNUIDevice.h"
#import "MLNUINetworkReachabilityManager.h"
#import <pthread/pthread.h>
@implementation MLNUISystem

+ (NSString *)luaui_osVersion
{
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSInteger)luaui_OSVersionInt
{
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    return [[systemVersion componentsSeparatedByString:@"."].firstObject integerValue];
}

+ (NSString *)luaui_sdkVersion
{
    return @MLNUI_SDK_VERSION;
}

+ (NSInteger)luaui_sdkVersionInt
{
    return MLNUI_SDK_VERSION_INT;
}

+ (BOOL)luaui_iOS
{
    return YES;
}

+ (BOOL)luaui_Android
{
    return NO;
}

+ (void)luaui_asyncDoInMain:(MLNUIBlock *)callback
{
    dispatch_block_t block = ^{
        if (!callback) return;
        [callback callIfCan];
    };
    if (pthread_main_np()) {
        block();
    }else{
        dispatch_async(dispatch_get_main_queue(),block);
    };
}


+ (CGFloat)luaui_scale
{
    return [UIScreen mainScreen].scale;
}

+ (CGSize)luaui_screenSize
{
    return [UIScreen mainScreen].bounds.size;
}

+ (CGFloat)luaui_navBarHeight
{
    return 44.f;
}

+ (CGFloat)luaui_stateBarHeight
{
    return CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
}

+ (CGFloat)luaui_homeIndicatorHeight
{
    static CGFloat height;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([self isIPhoneX]) {
            height = 34.f;
        } else {
            height = 0.f;
        }
    });
    return height;
}

+ (CGFloat)luaui_tabBarHeight
{
    return  49.f;
}

+ (BOOL)isIPhoneX
{
    static BOOL x = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        x = [MLNUIDevice isIPHX];
    });
    return x;
}

+ (NSString *)luaui_deviceInfo
{
    return [MLNUIDevice platform];
}

+ (void)luaui_layerMode:(BOOL)on
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:on] ;
}

+ (void)luaui_setTimeOut:(MLNUIBlock *)task delay:(NSTimeInterval)delay
{
    MLNUIStaticCheckTypeAndNilValue(task, @"callback", MLNUIBlock);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (task) {
            [task callIfCan];
        }
    });
}

+ (MLNUINetworkStatus)luaui_netWorkType
{
    return [[MLNUINetworkReachabilityManager sharedManager] networkStatus];
}

+ (void)luaui_setOnNetworkStateChange:(MLNUIBlock *)callback
{
    MLNUIStaticCheckTypeAndNilValue(callback, @"callback", MLNUIBlock);
    [[MLNUINetworkReachabilityManager sharedManager] addNetworkChangedCallback:^(MLNUINetworkStatus status) {
        if (callback) {
            [callback addIntArgument:(int)status];
            [callback callIfCan];
        }
    }];
}

+ (void)luaui_switchFullscreen:(BOOL)fullscreen {
    [[UIApplication sharedApplication] setStatusBarHidden:fullscreen];
}

+ (void)luaui_showStatusBar {
    [self _dealWithStatusBar:NO];
}

+ (void)luaui_hideStatusBar {
    [self _dealWithStatusBar:YES];
}

+ (void)luaui_changeBrightness:(NSInteger)brightness
{
    if ( brightness < 1) {
        brightness = 1;
    } else if ( brightness > 255) {
        brightness = 255;
    }
    [UIScreen mainScreen].brightness = [UIScreen mainScreen].brightness - 0.01;
    [UIScreen mainScreen].brightness = brightness / 255.0;
}

+ (NSInteger)luaui_brightness
{
    return (int)([UIScreen mainScreen].brightness * 255.0);
}

#pragma mark - Private method

+ (void)_dealWithStatusBar:(BOOL)isHidden
{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Info.plist" ofType:nil];
    NSDictionary *infoDict = [NSDictionary dictionaryWithContentsOfFile:bundlePath];
    NSNumber *controllerBaseStatusbarAppearanceNumber = [infoDict valueForKey:@"UIViewControllerBasedStatusBarAppearance"];
    if (!controllerBaseStatusbarAppearanceNumber) {
        return;
    }
    BOOL controllerBaseStatusbarAppearance = [controllerBaseStatusbarAppearanceNumber boolValue];
    if (controllerBaseStatusbarAppearanceNumber && !controllerBaseStatusbarAppearance) {
        [[UIApplication sharedApplication] setStatusBarHidden:isHidden];
    }
}

#pragma mark - Setup For Lua
LUAUI_EXPORT_STATIC_BEGIN(MLNUISystem)
LUAUI_EXPORT_STATIC_METHOD(OSVersion, "luaui_osVersion", MLNUISystem)
LUAUI_EXPORT_STATIC_METHOD(SDKVersion, "luaui_sdkVersion", MLNUISystem)
LUAUI_EXPORT_STATIC_METHOD(SDKVersionInt, "luaui_sdkVersionInt", MLNUISystem)
LUAUI_EXPORT_STATIC_METHOD(OSVersionInt, "luaui_OSVersionInt", MLNUISystem)
LUAUI_EXPORT_STATIC_METHOD(iOS, "luaui_iOS", MLNUISystem)
LUAUI_EXPORT_STATIC_METHOD(Android, "luaui_Android", MLNUISystem)
LUAUI_EXPORT_STATIC_METHOD(asyncDoInMain, "luaui_asyncDoInMain:", MLNUISystem)
LUAUI_EXPORT_STATIC_METHOD(scale, "luaui_scale", MLNUISystem)
LUAUI_EXPORT_STATIC_METHOD(screenSize, "luaui_screenSize", MLNUISystem)
LUAUI_EXPORT_STATIC_METHOD(navBarHeight, "luaui_navBarHeight", MLNUISystem)
LUAUI_EXPORT_STATIC_METHOD(stateBarHeight, "luaui_stateBarHeight", MLNUISystem)
LUAUI_EXPORT_STATIC_METHOD(homeIndicatorHeight, "luaui_homeIndicatorHeight", MLNUISystem)
LUAUI_EXPORT_STATIC_METHOD(deviceInfo, "luaui_deviceInfo", MLNUISystem)
LUAUI_EXPORT_STATIC_METHOD(tabBarHeight, "luaui_tabBarHeight", MLNUISystem)
LUAUI_EXPORT_STATIC_METHOD(setTimeOut, "luaui_setTimeOut:delay:", MLNUISystem)
LUAUI_EXPORT_STATIC_METHOD(networkState, "luaui_netWorkType", MLNUISystem)
LUAUI_EXPORT_STATIC_METHOD(switchFullscreen, "luaui_switchFullscreen:", MLNUISystem)
LUAUI_EXPORT_STATIC_METHOD(setOnNetworkStateChange, "luaui_setOnNetworkStateChange:", MLNUISystem)
LUAUI_EXPORT_STATIC_METHOD(showStatusBar, "luaui_showStatusBar", MLNUISystem)
LUAUI_EXPORT_STATIC_METHOD(hideStatusBar, "luaui_hideStatusBar", MLNUISystem)
LUAUI_EXPORT_STATIC_METHOD(changeBright, "luaui_changeBrightness:", MLNUISystem)
LUAUI_EXPORT_STATIC_METHOD(getBright, "luaui_brightness", MLNUISystem) 
LUAUI_EXPORT_STATIC_END(MLNUISystem, System, NO, NULL)

@end
