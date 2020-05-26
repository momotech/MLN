//
//  MLNUIPreferenceUtils.m
//  MLNUI
//
//  Created by MoMo on 2018/8/29.
//

#import "MLNUIPreferenceUtils.h"
#import "MLNUIStaticExporterMacro.h"

@implementation MLNUIPreferenceUtils

+ (void)luaui_save:(NSString*)key value:(NSString*)value {
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString*)luaui_get:(NSString*)key defaultValue:(NSString*)defaultValue {
    NSString* value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    return value?:defaultValue;
}


#pragma mark - Setup For Lua

LUAUI_EXPORT_STATIC_BEGIN(MLNUIPreferenceUtils)
LUAUI_EXPORT_STATIC_METHOD(save, "luaui_save:value:", MLNUIPreferenceUtils)
LUAUI_EXPORT_STATIC_METHOD(get, "luaui_get:defaultValue:", MLNUIPreferenceUtils)
LUAUI_EXPORT_STATIC_END(MLNUIPreferenceUtils, PreferenceUtils, NO, NULL)

@end
