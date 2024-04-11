//
//  MLNCornerUtil.m
//  MLN
//
//  Created by MoMo on 2019/10/30.
//

#import "MLNCornerUtil.h"
#import "MLNKitHeader.h"
#import "MLNKitInstanceConsts.h"

@implementation MLNCornerUtil

+ (void)lua_openDefaultClip:(BOOL)clip
{
    [MLN_KIT_INSTANCE([self mln_currentLuaCore]) instanceConsts].defaultCornerClip = clip;
}

+ (BOOL)isOpenDefaultClip
{
    return [MLN_KIT_INSTANCE([self mln_currentLuaCore]) instanceConsts].defaultCornerClip;
}

#pragma mark - Setup For Lua
LUA_EXPORT_STATIC_BEGIN(MLNCornerUtil)
LUA_EXPORT_STATIC_METHOD(openDefaultClip, "lua_openDefaultClip:", MLNCornerUtil)
LUA_EXPORT_STATIC_END(MLNCornerUtil, CornerManager, NO, NULL)

@end
