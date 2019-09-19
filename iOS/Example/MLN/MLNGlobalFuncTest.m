//
//  MLNGlobalFuncTest.m
//  MLNCore_Example
//
//  Created by MoMo on 2019/8/1.
//  Copyright © 2019 MoMo. All rights reserved.
//

#import "MLNGlobalFuncTest.h"

@implementation MLNGlobalFuncTest

static int mln_print(lua_State *L)
{
#if DEBUG
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
    NSLog(@"| LUA |> %@",buf);
    [buf appendString:@"\n"];
#endif
    return 0;
}

#pragma mark - Export
LUA_EXPORT_GLOBAL_FUNC_BEGIN(MLNGlobalFunction)
LUA_EXPORT_GLOBAL_C_FUNC(print, mln_print, MLNGlobalFunction)
LUA_EXPORT_GLOBAL_FUNC_END(MLNGlobalFunction)

@end
