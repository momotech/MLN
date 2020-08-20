//
//  MLNUIGlobalVariablesExporter.m
//  MLNUICore
//
//  Created by MoMo on 2019/7/23.
//

#import "MLNUIGlobalVarExporter.h"
#import "NSError+MLNUICore.h"
#import "NSObject+MLNUICore.h"
#import "MLNUILuaCore.h"
#import "MLNUIGlobalVarExportProtocol.h"

@implementation MLNUIGlobalVarExporter

- (BOOL)exportClass:(Class<MLNUIExportProtocol>)clazz error:(NSError **)error
{
    NSParameterAssert(clazz);
    lua_State *L = self.luaCore.state;
    if (!L) {
        if (error) {
            *error = [NSError mlnui_errorState:@"Lua state is released"];
            MLNUIError(self.luaCore, @"Lua state is released");
        }
        return NO;
    }
//    lua_settop(L, 0);
    Class<MLNUIGlobalVarExportProtocol> exportClazz = (Class<MLNUIGlobalVarExportProtocol>)clazz;
    NSArray<NSDictionary *> *vars = [exportClazz mlnui_globalVarMap];
    for (NSDictionary *info in vars) {
        BOOL ret = [self.luaCore registerGlobalVar:[info objectForKey:kGlobalVarMap] globalName:[info objectForKey:kGlobalVarLuaName] error:error];
        if (!ret) {
            return ret;
        }
    }
    return YES;
}

@end
