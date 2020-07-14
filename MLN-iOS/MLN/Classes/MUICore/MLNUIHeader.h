//
//  MLNUIHeader.h
//  MLNUICore
//
//  Created by MoMo on 2019/8/1.
//

#ifndef MLNUIHeader_h
#define MLNUIHeader_h

#include "mln_lua.h"
#include "mln_lauxlib.h"
#include "mln_lualib.h"
#include "lstate.h"
#include "lgc.h"
#include "lapi.h"

#import "MLNUIStaticExporterMacro.h"
#import "MLNUIEntityExporterMacro.h"
#import "MLNUIGlobalFuncExporterMacro.h"
#import "MLNUIGlobalVarExporterMacro.h"

/**
Lua强引用栈上指定位置的UserData

@param INDEX UserData在Lua虚拟机栈上的位置
@param USER_DATA UserData对应的原生对象
*/
#define MLNUI_Lua_UserData_Retain_With_Index(INDEX, USER_DATA) \
if ([((NSObject *)(USER_DATA)) mlnui_isConvertible]) {\
    [((id<MLNUIEntityExportProtocol>)(USER_DATA)).mlnui_luaCore setStrongObjectWithIndex:(INDEX) cKey:(__bridge void *)(USER_DATA)];\
}

/**
释放原生对象所关联UserData的强引用

@param USER_DATA UserData对应的原生对象
*/
#define MLNUI_Lua_UserData_Release(USER_DATA) \
if ([((NSObject *)(USER_DATA)) mlnui_isConvertible]) {\
    [((id<MLNUIEntityExportProtocol>)(USER_DATA)).mlnui_luaCore removeStrongObjectForCKey:(__bridge void *)(USER_DATA)];\
}

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
#define MLNUI_LUA_CORE(state) ((__bridge MLNUILuaCore *)(G(state)->ud))

/**
 强制函数内联
 */
#define MLNUI_FORCE_INLINE __inline__ __attribute__((always_inline))

/**
 强制类型检查
 */
#define mlnui_luaui_checkType(L_T, idx, TYPE_T) mlnui_luaui_assert(L_T, lua_type(L_T, idx) == TYPE_T, @"%s expected, got %s", lua_typename(L_T, TYPE_T), luaL_typename(L_T, idx))
#define mlnui_luaui_checkboolean(L, idx) mlnui_luaui_checkType(L, idx, LUA_TBOOLEAN);
#define mlnui_luaui_checkludata(L, idx) mlnui_luaui_checkType(L, idx, LUA_TLIGHTUSERDATA);
#define mlnui_luaui_checknumber(L, idx) mlnui_luaui_checkType(L, idx, LUA_TNUMBER);
#define mlnui_luaui_checkstring(L, idx) mlnui_luaui_checkType(L, idx, LUA_TSTRING);
#define mlnui_luaui_checktable(L, idx) mlnui_luaui_checkType(L, idx, LUA_TTABLE);
#define mlnui_luaui_checkfunc(L, idx) mlnui_luaui_checkType(L, idx, LUA_TFUNCTION);
#define mlnui_luaui_checkudata(L, idx) mlnui_luaui_checkType(L, idx, LUA_TUSERDATA);
#define mlnui_luaui_checkthread(L, idx) mlnui_luaui_checkType(L, idx, LUA_TTHREAD);

#define MLNUIValueIsType(VALUE, TYPE) strcmp((VALUE).objCType, @encode(TYPE)) == 0
#define MLNUIValueIsCGRect(VALUE) MLNUIValueIsType(VALUE, CGRect)
#define MLNUIValueIsCGSize(VALUE) MLNUIValueIsType(VALUE, CGSize)
#define MLNUIValueIsCGPoint(VALUE) MLNUIValueIsType(VALUE, CGPoint)


#define mlnui_luaui_checkType_rt(L_T, idx, rt, TYPE_T) mlnui_luaui_assert_rt(L_T, lua_type(L_T, idx) == TYPE_T, rt, @"%s expected, got %s", lua_typename(L_T, TYPE_T), luaL_typename(L_T, idx))

#define mlnui_luaui_check_begin()               BOOL check_rt = YES
#define mlnui_luaui_check_end()                 if(!check_rt) return 0

#define mlnui_luaui_checkboolean_rt(L, idx)     mlnui_luaui_checkType_rt(L, idx, check_rt, LUA_TBOOLEAN);
#define mlnui_luaui_checkludata_rt(L, idx)      mlnui_luaui_checkType_rt(L, idx, check_rt, LUA_TLIGHTUSERDATA);
#define mlnui_luaui_checknumber_rt(L, idx)      mlnui_luaui_checkType_rt(L, idx, check_rt, LUA_TNUMBER);
#define mlnui_luaui_checkstring_rt(L, idx)      mlnui_luaui_checkType_rt(L, idx, check_rt, LUA_TSTRING);
#define mlnui_luaui_checktable_rt(L, idx)       mlnui_luaui_checkType_rt(L, idx, check_rt, LUA_TTABLE);
#define mlnui_luaui_checkfunc_rt(L, idx)        mlnui_luaui_checkType_rt(L, idx, check_rt, LUA_TFUNCTION);
#define mlnui_luaui_checkudata_rt(L, idx)       mlnui_luaui_checkType_rt(L, idx, check_rt, LUA_TUSERDATA);
#define mlnui_luaui_checkthread_rt(L, idx)      mlnui_luaui_checkType_rt(L, idx, check_rt, LUA_TTHREAD);

//@note ⚠️在Native->Lua类型转换时，默认将char类型当做数字来处理，而BOOL类型在32位手机上编码为'c',
//      如果返回NO，则为'\0'，Lua接收到的值为0,而Lua语法规定0也为true，所以这里对于char做一个特殊处理
#if __LP64__ || (TARGET_OS_EMBEDDED && !TARGET_OS_IPHONE) || TARGET_OS_WIN32 || NS_BUILD_32_LIKE_64
#define MLNUINumberIsBool(NUMBER) MLNUIValueIsType(NUMBER, BOOL) || [number isKindOfClass:[@(YES) class]]
#else
#define MLNUINumberIsBool(NUMBER) (MLNUIValueIsType(NUMBER, BOOL) || [number isKindOfClass:[@(YES) class]] || ((MLNUIValueIsType(NUMBER, char)) && NUMBER.charValue =='\0'))
#endif

/**
 通知Handler处理Error
 
 @param LUA_CORE MLNUILuaCore 虚拟机内核
 @param FORMAT 字符拼接格式
 @param ... 可变参数
 */
#define MLNUICallErrorHandler(LUA_CORE, FORMAT, ...) \
NSString *error_tt = [NSString stringWithFormat:FORMAT, ##__VA_ARGS__];\
[(LUA_CORE).errorHandler luaCore:(LUA_CORE) error:error_tt]; \

/**
 通知Handler处理Error
 
 @param LUA_CORE MLNUILuaCore 虚拟机内核
 @param FORMAT 字符拼接格式
 @param ... 可变参数
 */
#define MLNUICallAssertHandler(LUA_CORE, FORMAT, ...) \
NSString *error_tt = [NSString stringWithFormat:FORMAT, ##__VA_ARGS__];\
error_tt = [error_tt stringByAppendingString:[LUA_CORE traceback]];\
[(LUA_CORE).errorHandler luaCore:(LUA_CORE) error:error_tt]; \

/**
 Lua 相关断言
 
 @param L Lua状态机
 @param condition 判断条件
 @param format 字符拼接格式
 @param ... 可变参数
 */
#define mlnui_luaui_assert(L, condition, format, ...)\
if (!(condition) && [MLNUI_LUA_CORE((L)).errorHandler canHandleAssert:MLNUI_LUA_CORE((L))]) {\
MLNUICallAssertHandler(MLNUI_LUA_CORE((L)), format, ##__VA_ARGS__)\
}

#define mlnui_luaui_assert_rt(L, condition, rt, format, ...)\
rt = rt && (condition);\
if (!(rt) && [MLNUI_LUA_CORE((L)).errorHandler canHandleAssert:MLNUI_LUA_CORE((L))]) {\
MLNUICallAssertHandler(MLNUI_LUA_CORE((L)), format, ##__VA_ARGS__)\
}

/**
 Lua 相关Error
 
 @param L Lua状态机
 @param format 字符拼接格式
 @param ... 可变参数
 */
#define mlnui_luaui_error(L, format, ...)\
MLNUICallErrorHandler(MLNUI_LUA_CORE((L)), format, ##__VA_ARGS__)\

/**
 Lua相关断言
 
 @param LUA_CORE MLNUILuaCore 虚拟机内核
 @param CONDITION 判断条件
 @param FORMAT 字符拼接格式
 @param ... 可变参数
 */
#define MLNUILuaAssert(LUA_CORE, CONDITION, FORMAT, ...) \
if ([(LUA_CORE).errorHandler canHandleAssert:(LUA_CORE)] && !(CONDITION)) {\
MLNUICallAssertHandler(LUA_CORE, FORMAT, ##__VA_ARGS__)\
}

/**
 Lua Error
 
 @param LUA_CORE MLNUILuaCore 虚拟机内核
 @param FORMAT 字符拼接格式
 @param ... 可变参数
 */
#define MLNUILuaError(LUA_CORE, FORMAT, ...) \
MLNUICallErrorHandler(LUA_CORE, FORMAT, ##__VA_ARGS__)\

/**
 原生相关断言
 
 @param LUA_CORE MLNUILuaCore 虚拟机内核
 @param CONDITION 判断条件
 @param FORMAT 字符拼接格式
 @param ... 可变参数
 */
#define MLNUIAssert(LUA_CORE, CONDITION, FORMAT, ...) \
if ([(LUA_CORE).errorHandler canHandleAssert:(LUA_CORE)] && !(CONDITION)) {\
MLNUICallAssertHandler(LUA_CORE, FORMAT, ##__VA_ARGS__)\
}

/**
 原生Error
 
 @param LUA_CORE MLNUILuaCore 虚拟机内核
 @param FORMAT 字符拼接格式
 @param ... 可变参数
 */
#define MLNUIError(LUA_CORE, FORMAT, ...) \
MLNUICallErrorHandler(LUA_CORE, FORMAT, ##__VA_ARGS__)

#endif /* MLNUIHeader_h */
