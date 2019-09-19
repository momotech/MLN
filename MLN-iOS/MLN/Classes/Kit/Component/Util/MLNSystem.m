//
//  MLNSystem.m
//  MLN
//
//  Created by MoMo on 2019/8/5.
//

#import "MLNSystem.h"
#import "MLNStaticExporterMacro.h"
#import "MLNVersion.h"
#import "MLNBlock.h"
#import "MLNDevice.h"
#import "MLNNetworkReachabilityManager.h"

@implementation MLNSystem

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
    return @MLN_SDK_VERSION;
}

+ (NSInteger)lua_sdkVersionInt
{
    return MLN_SDK_VERSION_INT;
}

+ (BOOL)lua_iOS
{
    return YES;
}

+ (BOOL)lua_Android
{
    return NO;
}

+ (void)lua_asyncDoInMain:(MLNBlock *)callback
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
        x = [MLNDevice isIPHX];
    });
    return x;
}

+ (NSString *)lua_deviceInfo
{
    return [MLNDevice platform];
}

+ (void)lua_layerMode:(BOOL)on
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:on] ;
}

+ (void)lua_setTimeOut:(MLNBlock *)task delay:(NSTimeInterval)delay
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (task) {
            [task callIfCan];
        }
    });
}

+ (MLNNetworkStatus)lua_netWorkType
{
    return [[MLNNetworkReachabilityManager sharedManager] networkStatus];
}

+ (void)lua_setOnNetworkStateChange:(MLNBlock *)callback
{
    [[MLNNetworkReachabilityManager sharedManager] addNetworkChangedCallback:^(MLNNetworkStatus status) {
        if (callback) {
            [callback addIntArgument:status];
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
    if (brightness < 0 || brightness > 255) return;
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
LUA_EXPORT_STATIC_BEGIN(MLNSystem)
LUA_EXPORT_STATIC_METHOD(OSVersion, "lua_osVersion", MLNSystem)
LUA_EXPORT_STATIC_METHOD(SDKVersion, "lua_sdkVersion", MLNSystem)
LUA_EXPORT_STATIC_METHOD(SDKVersionInt, "lua_sdkVersionInt", MLNSystem)
LUA_EXPORT_STATIC_METHOD(OSVersionInt, "lua_OSVersionInt", MLNSystem)
LUA_EXPORT_STATIC_METHOD(iOS, "lua_iOS", MLNSystem)
LUA_EXPORT_STATIC_METHOD(Android, "lua_Android", MLNSystem)
LUA_EXPORT_STATIC_METHOD(asyncDoInMain, "lua_asyncDoInMain:", MLNSystem)
LUA_EXPORT_STATIC_METHOD(scale, "lua_scale", MLNSystem)
LUA_EXPORT_STATIC_METHOD(screenSize, "lua_screenSize", MLNSystem)
LUA_EXPORT_STATIC_METHOD(navBarHeight, "lua_navBarHeight", MLNSystem)
LUA_EXPORT_STATIC_METHOD(stateBarHeight, "lua_stateBarHeight", MLNSystem)
LUA_EXPORT_STATIC_METHOD(homeIndicatorHeight, "lua_homeIndicatorHeight", MLNSystem)
LUA_EXPORT_STATIC_METHOD(deviceInfo, "lua_deviceInfo", MLNSystem)
LUA_EXPORT_STATIC_METHOD(tabBarHeight, "lua_tabBarHeight", MLNSystem)
LUA_EXPORT_STATIC_METHOD(setTimeOut, "lua_setTimeOut:delay:", MLNSystem)
LUA_EXPORT_STATIC_METHOD(networkState, "lua_netWorkType", MLNSystem)
LUA_EXPORT_STATIC_METHOD(switchFullscreen, "lua_switchFullscreen:", MLNSystem)
LUA_EXPORT_STATIC_METHOD(setOnNetworkStateChange, "lua_setOnNetworkStateChange:", MLNSystem)
LUA_EXPORT_STATIC_METHOD(showStatusBar, "lua_showStatusBar", MLNSystem)
LUA_EXPORT_STATIC_METHOD(hideStatusBar, "lua_hideStatusBar", MLNSystem)
LUA_EXPORT_STATIC_METHOD(changeBright, "lua_changeBrightness:", MLNSystem)
LUA_EXPORT_STATIC_METHOD(getBright, "lua_brightness", MLNSystem) 
LUA_EXPORT_STATIC_END(MLNSystem, System, NO, NULL)

@end
