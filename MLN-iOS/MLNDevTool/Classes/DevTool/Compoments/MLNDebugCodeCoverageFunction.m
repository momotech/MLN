//
//  MLNDebugCodeCoverageFunction.m
//  MLNDevTool
//
//  Created by MOMO on 2019/12/24.
//

#import "MLNDebugCodeCoverageFunction.h"
#import "MLNHotReload.h"
#import "MLNExporter.h"
#import "MLNServer.h"

@implementation MLNDebugCodeCoverageFunction

static int mln_reportCodeCoverageSummary(lua_State *L) {
    if (lua_gettop(L) == 2) {
        const char *summaryFilePath = lua_tostring(L, 1);
        const char *detailFilePath = lua_tostring(L, 2);
        if (summaryFilePath) {
            NSString *path = [NSString stringWithUTF8String:summaryFilePath];
            [[MLNServer getInstance] reportCodeCoverageSummary:path];
        }
        if (detailFilePath) {
            NSString *path = [NSString stringWithUTF8String:detailFilePath];
            [[MLNServer getInstance] reportCodeCoverageDetail:path];
        }
    }
    return 0;
}

static int mln_clearCodeCoverageResult(lua_State *L) {
    if (lua_type(L, -1) != LUA_TTABLE) {
        return 0;
    }
    
    lua_pushnil(L);
    while (lua_istable(L, -2) && lua_next(L, -2)) {
        const char *fileName = lua_tostring(L, -1);
        lua_pop(L, 1); // remove value and reserve key
        if (!fileName) continue;
        NSString *path = [[MLNHotReload getInstance].luaBundlePath stringByAppendingPathComponent:[NSString stringWithUTF8String:fileName]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
            NSCAssert(error == nil, error.localizedDescription);
        }
    }
    return 0;
}

static int mln_luaBundlePath(lua_State *L) {
    NSString *path = [MLNHotReload getInstance].luaBundlePath;
    lua_pushstring(L, path.UTF8String);
    return 1;
}

#pragma mark - Export

LUA_EXPORT_GLOBAL_FUNC_BEGIN(MLNDebugCodeCoverageFunction)
LUA_EXPORT_GLOBAL_C_FUNC(reportCoverageSummary, mln_reportCodeCoverageSummary, MLNDebugCodeCoverageFunction)
LUA_EXPORT_GLOBAL_C_FUNC(MLNCodeCovClearPreviousResult, mln_clearCodeCoverageResult, MLNDebugCodeCoverageFunction)
LUA_EXPORT_GLOBAL_C_FUNC(MLNBundlePath, mln_luaBundlePath, MLNDebugCodeCoverageFunction)
LUA_EXPORT_GLOBAL_FUNC_END(MLNDebugCodeCoverageFunction)

@end
