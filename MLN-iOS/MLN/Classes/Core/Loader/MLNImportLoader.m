//
//  MLNImportLoader.m
//  MLN
//
//  Created by xue.yunqiang on 2022/4/1.
//

#import "MLNImportLoader.h"
#import "MLNLuaCore.h"

@implementation MLNImportLoader

static int mln_import_exporter_loader(lua_State *L)
{
    NSString *className4Lua = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    if (className4Lua && className4Lua.length >0) {
        className4Lua = [className4Lua stringByReplacingOccurrencesOfString:@".lua" withString:@""];
        BOOL success = [MLN_LUA_CORE(L) loadBridge:className4Lua];
        return success ? 1 : 0;
    }
    return 0;
}

#pragma mark - Export
LUA_EXPORT_GLOBAL_FUNC_BEGIN(MLNImportLoader)
LUA_EXPORT_GLOBAL_C_FUNC(1, mln_import_exporter_loader, MLNImportLoader)
LUA_EXPORT_GLOBAL_FUNC_WITH_NAME_END(MLNImportLoader, import, package)

@end
