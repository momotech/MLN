//
//  MLNUICornerUtil.m
//  MLNUI
//
//  Created by MoMo on 2019/10/30.
//

#import "MLNUICornerUtil.h"
#import "MLNUIKitHeader.h"
#import "MLNUIKitInstanceConsts.h"

@implementation MLNUICornerUtil

+ (void)luaui_openDefaultClip:(BOOL)clip
{
    [MLNUI_KIT_INSTANCE([self mlnui_currentLuaCore]) instanceConsts].defaultCornerClip = clip;
}

+ (BOOL)isOpenDefaultClip
{
    return [MLNUI_KIT_INSTANCE([self mlnui_currentLuaCore]) instanceConsts].defaultCornerClip;
}

#pragma mark - Setup For Lua
LUAUI_EXPORT_STATIC_BEGIN(MLNUICornerUtil)
LUAUI_EXPORT_STATIC_METHOD(openDefaultClip, "luaui_openDefaultClip:", MLNUICornerUtil)
LUAUI_EXPORT_STATIC_END(MLNUICornerUtil, CornerManager, NO, NULL)

@end
