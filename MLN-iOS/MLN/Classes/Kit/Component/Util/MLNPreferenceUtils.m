//
//  MLNPreferenceUtils.m
//  MLN
//
//  Created by MoMo on 2018/8/29.
//

#import "MLNPreferenceUtils.h"
#import "MLNStaticExporterMacro.h"

@implementation MLNPreferenceUtils

+ (void)lua_save:(NSString*)key value:(NSString*)value {
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString*)lua_get:(NSString*)key defaultValue:(NSString*)defaultValue {
    NSString* value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    return value?:defaultValue;
}


#pragma mark - Setup For Lua

LUA_EXPORT_STATIC_BEGIN(MLNPreferenceUtils)
LUA_EXPORT_STATIC_METHOD(save, "lua_save:value:", MLNPreferenceUtils)
LUA_EXPORT_STATIC_METHOD(get, "lua_get:defaultValue:", MLNPreferenceUtils)
LUA_EXPORT_STATIC_END(MLNPreferenceUtils, PreferenceUtils, NO, NULL)

@end
