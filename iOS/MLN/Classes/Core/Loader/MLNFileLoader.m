//
//  MLNLoader.m
//  MLNCore
//
//  Created by MoMo on 2019/7/23.
//

#import "MLNFileLoader.h"
#import "MLNLuaCore.h"

@implementation MLNFileLoader

static int mln_file_loader(lua_State *L)
{
    NSString *fileName = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    if (fileName && fileName.length >0) {
        NSString *filePath = [fileName stringByReplacingOccurrencesOfString:@"." withString:@"/"];
        BOOL success = [MLN_LUA_CORE(L) loadFile:[NSString stringWithFormat:@"%@.lua",filePath] error:NULL];
        return success ? 1 : 0;
    }
    return 1;
}

#pragma mark - Export
LUA_EXPORT_GLOBAL_FUNC_BEGIN(MLNFileLoader)
LUA_EXPORT_GLOBAL_C_FUNC(2, mln_file_loader, MLNFileLoader)
LUA_EXPORT_GLOBAL_FUNC_WITH_NAME_END(MLNFileLoader, loaders, package)

@end
