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

@implementation MLNUISystem

+ (NSString *)lua_osVersion
{
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSInteger)lua_OSVersionInt
{
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    return [[systemVersion componentsSeparatedByString:@"."].firstObject integerValue];
}

+ (NSString *)lua_sdkVersion
{
    return @MLNUI_SDK_VERSION;
}

+ (NSInteger)lua_sdkVersionInt
{
    return MLNUI_SDK_VERSION_INT;
}

+ (BOOL)lua_iOS
{
    return YES;
}

+ (BOOL)lua_Android
{
    return NO;
}

+ (void)lua_asyncDoInMain:(MLNUIBlock *)callback
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!callback) return ;
        [callback callIfCan];
    });
}


+ (CGFloat)lua_scale
{
    return [UIScreen mainScreen].scale;
}

+ (CGSize)lua_screenSize
{
    return [UIScreen mainScreen].bounds.size;
}

+ (CGFloat)lua_navBarHeight
{
    return 44.f;
}

+ (CGFloat)lua_stateBarHeight
{
    return CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
}

+ (CGFloat)lua_homeIndicatorHeight
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

+ (CGFloat)lua_tabBarHeight
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

+ (NSString *)lua_deviceInfo
{
    return [MLNUIDevice platform];
}

+ (void)lua_layerMode:(BOOL)on
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:on] ;
}

+ (void)lua_setTimeOut:(MLNUIBlock *)task delay:(NSTimeInterval)delay
{
    MLNUIStaticCheckTypeAndNilValue(task, @"callback", MLNUIBlock);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (task) {
            [task callIfCan];
        }
    });
}

+ (MLNUINetworkStatus)lua_netWorkType
{
    return [[MLNUINetworkReachabilityManager sharedManager] networkStatus];
}

+ (void)lua_setOnNetworkStateChange:(MLNUIBlock *)callback
{
    MLNUIStaticCheckTypeAndNilValue(callback, @"callback", MLNUIBlock);
    [[MLNUINetworkReachabilityManager sharedManager] addNetworkChangedCallback:^(MLNUINetworkStatus status) {
        if (callback) {
            [callback addIntArgument:(int)status];
            [callback callIfCan];
        }
    }];
}

+ (void)lua_switchFullscreen:(BOOL)fullscreen {
    [[UIApplication sharedApplication] setStatusBarHidden:fullscreen];
}

+ (void)lua_showStatusBar {
    [self _dealWithStatusBar:NO];
}

+ (void)lua_hideStatusBar {
    [self _dealWithStatusBar:YES];
}

+ (void)lua_changeBrightness:(NSInteger)brightness
{
    if ( brightness < 1) {
        brightness = 1;
    } else if ( brightness > 255) {
        brightness = 255;
    }
    [UIScreen mainScreen].brightness = [UIScreen mainScreen].brightness - 0.01;
    [UIScreen mainScreen].brightness = brightness / 255.0;
}

+ (NSInteger)lua_brightness
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
LUA_EXPORT_STATIC_BEGIN(MLNUISystem)
LUA_EXPORT_STATIC_METHOD(OSVersion, "lua_osVersion", MLNUISystem)
LUA_EXPORT_STATIC_METHOD(SDKVersion, "lua_sdkVersion", MLNUISystem)
LUA_EXPORT_STATIC_METHOD(SDKVersionInt, "lua_sdkVersionInt", MLNUISystem)
LUA_EXPORT_STATIC_METHOD(OSVersionInt, "lua_OSVersionInt", MLNUISystem)
LUA_EXPORT_STATIC_METHOD(iOS, "lua_iOS", MLNUISystem)
LUA_EXPORT_STATIC_METHOD(Android, "lua_Android", MLNUISystem)
LUA_EXPORT_STATIC_METHOD(asyncDoInMain, "lua_asyncDoInMain:", MLNUISystem)
LUA_EXPORT_STATIC_METHOD(scale, "lua_scale", MLNUISystem)
LUA_EXPORT_STATIC_METHOD(screenSize, "lua_screenSize", MLNUISystem)
LUA_EXPORT_STATIC_METHOD(navBarHeight, "lua_navBarHeight", MLNUISystem)
LUA_EXPORT_STATIC_METHOD(stateBarHeight, "lua_stateBarHeight", MLNUISystem)
LUA_EXPORT_STATIC_METHOD(homeIndicatorHeight, "lua_homeIndicatorHeight", MLNUISystem)
LUA_EXPORT_STATIC_METHOD(deviceInfo, "lua_deviceInfo", MLNUISystem)
LUA_EXPORT_STATIC_METHOD(tabBarHeight, "lua_tabBarHeight", MLNUISystem)
LUA_EXPORT_STATIC_METHOD(setTimeOut, "lua_setTimeOut:delay:", MLNUISystem)
LUA_EXPORT_STATIC_METHOD(networkState, "lua_netWorkType", MLNUISystem)
LUA_EXPORT_STATIC_METHOD(switchFullscreen, "lua_switchFullscreen:", MLNUISystem)
LUA_EXPORT_STATIC_METHOD(setOnNetworkStateChange, "lua_setOnNetworkStateChange:", MLNUISystem)
LUA_EXPORT_STATIC_METHOD(showStatusBar, "lua_showStatusBar", MLNUISystem)
LUA_EXPORT_STATIC_METHOD(hideStatusBar, "lua_hideStatusBar", MLNUISystem)
LUA_EXPORT_STATIC_METHOD(changeBright, "lua_changeBrightness:", MLNUISystem)
LUA_EXPORT_STATIC_METHOD(getBright, "lua_brightness", MLNUISystem) 
LUA_EXPORT_STATIC_END(MLNUISystem, System, NO, NULL)

@end
