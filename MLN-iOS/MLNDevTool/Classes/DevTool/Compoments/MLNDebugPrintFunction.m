//
//  MLNGlobalFunction.m
//  MLN
//
//  Created by MoMo on 2018/8/27.
//

#import "MLNDebugPrintFunction.h"
#import <ArgoUI/MLNUIGlobalFuncExporterMacro.h>


@implementation MLNDebugPrintFunction

static NSHashTable<id<MLNDebugPrintObserver>> *observers = nil;

+ (void)addObserver:(id<MLNDebugPrintObserver>)observer
{
    doInMainQueue(
                  if (!observers) {
                      observers =  [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory|NSPointerFunctionsObjectPointerPersonality capacity:0];
                  }
                  [observers addObject:observer];)

}

+ (void)removeObserver:(id<MLNDebugPrintObserver>)observer
{
    doInMainQueue([observers removeObject:observer];)
}

+ (void)postMsg:(NSString *)msg
{
    for (id<MLNDebugPrintObserver> obs in observers) {
        [obs print:msg];
    }
}

static int mln_print(lua_State *L)
{
    int n = lua_gettop(L);  /* number of arguments */
    int i;
    NSMutableString* buf = [[NSMutableString alloc] init];
    lua_getglobal(L, "tostring");
    for (i=1; i<=n; i++) {
        const char *s = NULL;
        lua_pushvalue(L, -1);  /* function to be called */
        lua_pushvalue(L, i);   /* value to print */
        lua_call(L, 1, 1);
        s = lua_tostring(L, -1);  /* get result */
        if (s == NULL)
            return luaL_error(L, LUA_QL("tostring") " must return a string to " LUA_QL("print"));
        if ( i>1 ) {
            [buf appendString:@"\t"];
        }
        NSString* str  = [NSString stringWithUTF8String:s];
        [buf appendFormat:@"%@",str];
        lua_pop(L, 1);  /* pop result */
    }
    [buf appendString:@"\n"];
    [MLNDebugPrintFunction postMsg:buf.copy];
    return 0;
}

#pragma mark - Export
LUA_EXPORT_GLOBAL_FUNC_BEGIN(MLNDebugPrintFunction)
LUA_EXPORT_GLOBAL_C_FUNC(print, mln_print, MLNDebugPrintFunction)
LUA_EXPORT_GLOBAL_FUNC_END(MLNDebugPrintFunction)

LUAUI_EXPORT_GLOBAL_FUNC_BEGIN(MLNDebugPrintFunction)
LUAUI_EXPORT_GLOBAL_C_FUNC(print, mln_print, MLNDebugPrintFunction)
LUAUI_EXPORT_GLOBAL_FUNC_END(MLNDebugPrintFunction)
@end
