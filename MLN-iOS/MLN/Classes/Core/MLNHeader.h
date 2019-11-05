//
//  MLNHeader.h
//  MLNCore
//
//  Created by MoMo on 2019/8/1.
//

#ifndef MLNHeader_h
#define MLNHeader_h

#include "mln_lua.h"
#include "mln_lauxlib.h"
#include "mln_lualib.h"
#include "lstate.h"
#include "lgc.h"
#include "lapi.h"

#import "MLNStaticExporterMacro.h"
#import "MLNEntityExporterMacro.h"
#import "MLNGlobalFuncExporterMacro.h"
#import "MLNGlobalVarExporterMacro.h"

#if defined(__LP64__) && __LP64__
#define CGFloatValueFromNumber(NUMBER) \
[(NUMBER) doubleValue]
#else
#define CGFloatValueFromNumber(NUMBER) \
[(NUMBER) floatValue]
#endif

/**
 判断是不是main queue
 */
#define isMainQueue (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(dispatch_get_main_queue()))

/**
 将一段代码块push到main queue执行
 
 @param ... 需要被执行的代码块
 */
#define doInMainQueue(...) \
if (isMainQueue) {\
__VA_ARGS__;\
} else { \
dispatch_async(dispatch_get_main_queue(), ^{\
__VA_ARGS__;\
});\
}

/**
 char * 是否为空
 
 @param c char *类型数据
 @return YES/NO
 */
#define charpNotEmpty(c) ((c)!=NULL) && ((c)[0]!='\0')

/**
 字符串是否为空
 
 @param str NSString 字符串
 @return YES/NO
 */
#define stringNotEmpty(str) (str && str.length >0)

/**
 lua状态机转换成lua core
 
 @param state lua状态机
 @return lua core
 */
#define MLN_LUA_CORE(state) ((__bridge MLNLuaCore *)(G(state)->ud))

/**
 强制函数内联
 */
#define MLN_FORCE_INLINE __inline__ __attribute__((always_inline))

/**
 强制类型检查
 */
#define mln_lua_checkType(L_T, idx, TYPE_T) mln_lua_assert(L_T, lua_type(L_T, idx) == TYPE_T, "%s expected, got %s", lua_typename(L_T, TYPE_T), luaL_typename(L_T, idx))
#define mln_lua_checkboolean(L, idx) mln_lua_checkType(L, idx, LUA_TBOOLEAN);
#define mln_lua_checkludata(L, idx) mln_lua_checkType(L, idx, LUA_TLIGHTUSERDATA);
#define mln_lua_checknumber(L, idx) mln_lua_checkType(L, idx, LUA_TNUMBER);
#define mln_lua_checkstring(L, idx) mln_lua_checkType(L, idx, LUA_TSTRING);
#define mln_lua_checktable(L, idx) mln_lua_checkType(L, idx, LUA_TTABLE);
#define mln_lua_checkfunc(L, idx) mln_lua_checkType(L, idx, LUA_TFUNCTION);
#define mln_lua_checkudata(L, idx) mln_lua_checkType(L, idx, LUA_TUSERDATA);
#define mln_lua_checkthread(L, idx) mln_lua_checkType(L, idx, LUA_TTHREAD);

#define MLNValueIsType(VALUE, TYPE) strcmp((VALUE).objCType, @encode(TYPE)) == 0
#define MLNValueIsCGRect(VALUE) MLNValueIsType(VALUE, CGRect)
#define MLNValueIsCGSize(VALUE) MLNValueIsType(VALUE, CGSize)
#define MLNValueIsCGPoint(VALUE) MLNValueIsType(VALUE, CGPoint)

//@note ⚠️在Native->Lua类型转换时，默认将char类型当做数字来处理，而BOOL类型在32位手机上编码为'c',
//      如果返回NO，则为'\0'，Lua接收到的值为0,而Lua语法规定0也为true，所以这里对于char做一个特殊处理
#if __LP64__ || (TARGET_OS_EMBEDDED && !TARGET_OS_IPHONE) || TARGET_OS_WIN32 || NS_BUILD_32_LIKE_64
#define MLNNumberIsBool(NUMBER) MLNValueIsType(NUMBER, BOOL)
#else
#define MLNNumberIsBool(NUMBER) (MLNValueIsType(NUMBER, BOOL) || ((MLNValueIsType(NUMBER, char)) && NUMBER.charValue =='\0'))
#endif
/**
 Lua 相关断言
 
 @param L Lua状态机
 @param condition 判断条件
 @param format 字符拼接格式
 @param ... 可变参数
 */
#define mln_lua_assert(L, condition, format, ...)\
if ([MLN_LUA_CORE((L)).errorHandler canHandleAssert:MLN_LUA_CORE((L))] && !(condition)) {\
    luaL_error(L, format, ##__VA_ARGS__);\
}

/**
 Lua 相关Error
 
 @param L Lua状态机
 @param format 字符拼接格式
 @param ... 可变参数
 */
#define mln_lua_error(L, format, ...)\
luaL_error(L, format, ##__VA_ARGS__);\

/**
 Lua相关断言
 
 @param LUA_CORE MLNLuaCore 虚拟机内核
 @param CONDITION 判断条件
 @param FORMAT 字符拼接格式
 @param ... 可变参数
 */
#define MLNLuaAssert(LUA_CORE, CONDITION, FORMAT, ...) \
if ([(LUA_CORE).errorHandler canHandleAssert:(LUA_CORE)] && !(CONDITION)) {\
    NSString *error_t = [NSString stringWithFormat:FORMAT, ##__VA_ARGS__];\
    if ((LUA_CORE).state) { \
        mln_lua_error((LUA_CORE).state, error_t.UTF8String) \
    }\
}

/**
 Lua Error
 
 @param LUA_CORE MLNLuaCore 虚拟机内核
 @param FORMAT 字符拼接格式
 @param ... 可变参数
 */
#define MLNLuaError(LUA_CORE, FORMAT, ...) \
NSString *error_t = [NSString stringWithFormat:FORMAT, ##__VA_ARGS__];\
if ((LUA_CORE).state) { \
    mln_lua_error((LUA_CORE).state, error_t.UTF8String) \
}

/**
 通知Handler处理Error
 
 @param LUA_CORE MLNLuaCore 虚拟机内核
 @param FORMAT 字符拼接格式
 @param ... 可变参数
 */
#define MLNCallErrorHandler(LUA_CORE, FORMAT, ...) \
NSString *error_t = [NSString stringWithFormat:FORMAT, ##__VA_ARGS__];\
[(LUA_CORE).errorHandler luaCore:(LUA_CORE) error:error_t]; \

/**
 原生相关断言
 
 @param LUA_CORE MLNLuaCore 虚拟机内核
 @param CONDITION 判断条件
 @param FORMAT 字符拼接格式
 @param ... 可变参数
 */
#define MLNAssert(LUA_CORE, CONDITION, FORMAT, ...) \
if ([(LUA_CORE).errorHandler canHandleAssert:(LUA_CORE)] && !(CONDITION)) {\
    MLNCallErrorHandler(LUA_CORE, FORMAT, ##__VA_ARGS__)\
}

/**
 原生Error
 
 @param LUA_CORE MLNLuaCore 虚拟机内核
 @param FORMAT 字符拼接格式
 @param ... 可变参数
 */
#define MLNError(LUA_CORE, FORMAT, ...) \
MLNCallErrorHandler(LUA_CORE, FORMAT, ##__VA_ARGS__)

#endif /* MLNHeader_h */
