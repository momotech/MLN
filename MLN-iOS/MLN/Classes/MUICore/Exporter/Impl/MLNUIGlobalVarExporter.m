//
//  MLNGlobalVariablesExporter.m
//  MLNCore
//
//  Created by MoMo on 2019/7/23.
//

#import "MLNGlobalVarExporter.h"
#import "NSError+MLNCore.h"
#import "NSObject+MLNCore.h"
#import "MLNLuaCore.h"
#import "MLNGlobalVarExportProtocol.h"

@implementation MLNGlobalVarExporter

- (BOOL)exportClass:(Class<MLNExportProtocol>)clazz error:(NSError **)error
{
    NSParameterAssert(clazz);
    lua_State *L = self.luaCore.state;
    if (!L) {
        if (error) {
            *error = [NSError mln_errorState:@"Lua state is released"];
            MLNError(self.luaCore, @"Lua state is released");
        }
        return NO;
    }
    lua_settop(L, 0);
    Class<MLNGlobalVarExportProtocol> exportClazz = (Class<MLNGlobalVarExportProtocol>)clazz;
    NSArray<NSDictionary *> *vars = [exportClazz mln_globalVarMap];
    for (NSDictionary *info in vars) {
        BOOL ret = [self.luaCore registerGlobalVar:[info objectForKey:kGlobalVarMap] globalName:[info objectForKey:kGlobalVarLuaName] error:error];
        if (!ret) {
            return ret;
        }
    }
    return YES;
}

@end
