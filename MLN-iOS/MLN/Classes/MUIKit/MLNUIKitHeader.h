//
//  MLNUIKitHeader.h
//  MLNUI
//
//  Created by MoMo on 2019/8/5.
//

#ifndef MLNUIKitHeader_h
#define MLNUIKitHeader_h



#import "MLNUIHeader.h"
#import "MLNUIKitInstance.h"

/**
 LUA_CORE转换为MLNUIKitInstance

 @param LUA_CORE MLNUILuaCore
 @return MLNUIKitInstance
 */
#define MLNUI_KIT_INSTANCE(LUA_CORE) ((MLNUIKitInstance *)(LUA_CORE).weakAssociatedObject)

/**
 可实例化对象的相关Error
⚠️ 必须遵循MLNUIEntityExportProtocol协议，才能使用该宏定义
 
 @param FORMAT 字符拼接格式
 @param ... 可变参数
 */
#define MLNUIKitLuaError(FORMAT, ...)\
MLNUILuaError(((id<MLNUIEntityExportProtocol>)self).mlnui_luaCore, FORMAT, ##__VA_ARGS__)

/**
 静态类的相关Error
 ⚠️ 必须遵循MLNUIStaticExportProtocol协议，才能使用该宏定义
 
 @param FORMAT 字符拼接格式
 @param ... 可变参数
 */
#define MLNUIKitLuaStaticError(FORMAT, ...)\
MLNUILuaError([((id<MLNUIStaticExportProtocol>)self) mlnui_currentLuaCore], FORMAT, ##__VA_ARGS__)

/**
 可实例化对象的相关断言
 ⚠️ 必须遵循MLNUIEntityExportProtocol协议，才能使用该宏定义
 
 @param CONDITION 判断条件
 @param FORMAT 字符拼接格式
 @param ... 可变参数
 */
#define MLNUIKitLuaAssert(CONDITION, FORMAT, ...) \
MLNUILuaAssert(((id<MLNUIEntityExportProtocol>)self).mlnui_luaCore, CONDITION, FORMAT, ##__VA_ARGS__)

/**
 静态类的相关断言
 ⚠️ 必须遵循MLNUIStaticExportProtocol协议，才能使用该宏定义
 
 @param CONDITION 判断条件
 @param FORMAT 字符拼接格式
 @param ... 可变参数
 */
#define MLNUIKitLuaStaticAssert(CONDITION, FORMAT, ...)\
MLNUILuaAssert([((id<MLNUIStaticExportProtocol>)self) mlnui_currentLuaCore], CONDITION, FORMAT, ##__VA_ARGS__)

/**
 可实例化类的类型检查断言
 ⚠️ 必须遵循MLNUIEntityExportProtocol协议，才能使用该宏定义
 
 @param OBJ 要做类型校验的实例
 @param LUA_TYPE 对应的Lua类型
 @param NATIVE_TYPE 对应的原生类型
 */
#define MLNUICheckTypeAndNilValue(OBJ, LUA_TYPE, NATIVE_TYPE)\
MLNUILuaAssert(((id<MLNUIEntityExportProtocol>)self).mlnui_luaCore, ([(OBJ) isKindOfClass:([NATIVE_TYPE class])]), @"The parameter type must be %@ and not a nil value!", LUA_TYPE);

/**
 静态类的类型检查断言
 ⚠️ 必须遵循MLNUIStaticExportProtocol协议，才能使用该宏定义
 
 @param OBJ 要做类型校验的实例
 @param LUA_TYPE 对应的Lua类型
 @param NATIVE_TYPE 对应的原生类型
 */
#define MLNUIStaticCheckTypeAndNilValue(OBJ, LUA_TYPE, NATIVE_TYPE)\
MLNUILuaAssert([((id<MLNUIStaticExportProtocol>)self) mlnui_currentLuaCore], ([(OBJ) isKindOfClass:([NATIVE_TYPE class])]), @"The parameter type must be %@ and not a nil value!", LUA_TYPE);

/**
 可实例化类的字符串检查断言
 ⚠️ 必须遵循MLNUIEntityExportProtocol协议，才能使用该宏定义
 
 @param OBJ 要做类型校验的字符串
 */
#define MLNUICheckStringTypeAndNilValue(OBJ)\
MLNUICheckTypeAndNilValue(OBJ, @"string", NSString)

/**
 静态类的字符串检查断言
 ⚠️ 必须遵循MLNUIStaticExportProtocol协议，才能使用该宏定义
 
 @param OBJ 要做类型校验的字符串
 */
#define MLNUIStaticCheckStringTypeAndNilValue(OBJ)\
MLNUIStaticCheckTypeAndNilValue(OBJ, @"string", NSString)

/**
 可实例化类的宽度检查断言
 ⚠️ 必须遵循MLNUIEntityExportProtocol协议，才能使用该宏定义
 
 @param VALUE 宽度
 */
#define MLNUICheckWidth(VALUE) MLNUIKitLuaAssert((VALUE >= 0 || VALUE == MLNUILayoutMeasurementTypeWrapContent || VALUE == MLNUILayoutMeasurementTypeMatchParent), @"size must be set width positive number, error number: %@ .", @(VALUE));

/**
 可实例化类的高度检查断言
 ⚠️ 必须遵循MLNUIEntityExportProtocol协议，才能使用该宏定义
 
 @param VALUE 高度
 */
#define MLNUICheckHeight(VALUE) MLNUIKitLuaAssert((VALUE >= 0 || VALUE == MLNUILayoutMeasurementTypeWrapContent || VALUE == MLNUILayoutMeasurementTypeMatchParent), @"size must be set height positive number, error number: %@ .", @(VALUE));



#endif /* MLNUIKitHeader_h */
