//
//  MLNGlobalTimeTest.m
//  LuaNative
//
//  Created by sun-zt on 2020/7/15.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import "MLNGlobalTimeTest.h"

@implementation MLNGlobalTimeTest

static int mln_millisecond(lua_State *L)
{
#if DEBUG
    lua_pushnumber(L, CFAbsoluteTimeGetCurrent() * 1000);
    return 1;
#endif
    return 0;
}

LUAUI_EXPORT_GLOBAL_FUNC_BEGIN(MLNGlobalTimeTest)
LUAUI_EXPORT_GLOBAL_C_FUNC(millisecond, mln_millisecond, MLNGlobalTimeTest)
LUAUI_EXPORT_GLOBAL_FUNC_END(MLNGlobalTimeTest)

@end
