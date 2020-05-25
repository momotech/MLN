//
//  MLNUILoader.m
//  MLNUICore
//
//  Created by MoMo on 2019/7/23.
//

#import "MLNUIFileLoader.h"
#import "MLNUILuaCore.h"

@implementation MLNUIFileLoader

static int mlnui_file_loader(lua_State *L)
{
    NSString *fileName = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    if (fileName && fileName.length >0) {
        NSString *filePath = [fileName stringByReplacingOccurrencesOfString:@"." withString:@"/"];
        BOOL success = [MLNUI_LUA_CORE(L) loadFile:[NSString stringWithFormat:@"%@.lua",filePath] error:NULL];
        return success ? 1 : 0;
    }
    return 1;
}

#pragma mark - Export
LUA_EXPORT_GLOBAL_FUNC_BEGIN(MLNUIFileLoader)
LUA_EXPORT_GLOBAL_C_FUNC(2, mlnui_file_loader, MLNUIFileLoader)
LUA_EXPORT_GLOBAL_FUNC_WITH_NAME_END(MLNUIFileLoader, loaders, package)

@end
