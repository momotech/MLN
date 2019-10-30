//
//  MLNKitHeader.h
//  MLN
//
//  Created by MoMo on 2019/8/5.
//

#ifndef MLNKitHeader_h
#define MLNKitHeader_h

#import "MLNHeader.h"
#import "MLNKitInstance.h"

/**
 LUA_CORE转换为MLNKitInstance

 @param LUA_CORE MLNLuaCore
 @return MLNKitInstance
 */
#define MLN_KIT_INSTANCE(LUA_CORE) ((MLNKitInstance *)(LUA_CORE).weakAssociatedObject)

/**
 可实例化对象的相关Error
⚠️ 必须遵循MLNEntityExportProtocol协议，才能使用该宏定义
 
 @param FORMAT 字符拼接格式
 @param ... 可变参数
 */
#define MLNKitLuaError(FORMAT, ...)\
MLNLuaError(((id<MLNEntityExportProtocol>)self).mln_luaCore, FORMAT, ##__VA_ARGS__)

/**
 静态类的相关Error
 ⚠️ 必须遵循MLNStaticExportProtocol协议，才能使用该宏定义
 
 @param FORMAT 字符拼接格式
 @param ... 可变参数
 */
#define MLNKitLuaStaticError(FORMAT, ...)\
MLNLuaAssert([((id<MLNStaticExportProtocol>)self) mln_currentLuaCore], FORMAT, ##__VA_ARGS__)

/**
 可实例化对象的相关断言
 ⚠️ 必须遵循MLNEntityExportProtocol协议，才能使用该宏定义
 
 @param CONDITION 判断条件
 @param FORMAT 字符拼接格式
 @param ... 可变参数
 */
#define MLNKitLuaAssert(CONDITION, FORMAT, ...) \
MLNLuaAssert(((id<MLNEntityExportProtocol>)self).mln_luaCore, CONDITION, FORMAT, ##__VA_ARGS__)

/**
 静态类的相关断言
 ⚠️ 必须遵循MLNStaticExportProtocol协议，才能使用该宏定义
 
 @param CONDITION 判断条件
 @param FORMAT 字符拼接格式
 @param ... 可变参数
 */
#define MLNKitLuaStaticAssert(CONDITION, FORMAT, ...)\
MLNLuaAssert([((id<MLNStaticExportProtocol>)self) mln_currentLuaCore], CONDITION, FORMAT, ##__VA_ARGS__)

/**
 可实例化类的类型检查断言
 ⚠️ 必须遵循MLNEntityExportProtocol协议，才能使用该宏定义
 
 @param OBJ 要做类型校验的实例
 @param LUA_TYPE 对应的Lua类型
 @param NATIVE_TYPE 对应的原生类型
 */
#define MLNCheckTypeAndNilValue(OBJ, LUA_TYPE, NATIVE_TYPE)\
MLNLuaAssert(((id<MLNEntityExportProtocol>)self).mln_luaCore, ([(OBJ) isKindOfClass:([NATIVE_TYPE class])]), @"The parameter type must be %@ and not a nil value!", LUA_TYPE);

/**
 静态类的类型检查断言
 ⚠️ 必须遵循MLNStaticExportProtocol协议，才能使用该宏定义
 
 @param OBJ 要做类型校验的实例
 @param LUA_TYPE 对应的Lua类型
 @param NATIVE_TYPE 对应的原生类型
 */
#define MLNStaticCheckTypeAndNilValue(OBJ, LUA_TYPE, NATIVE_TYPE)\
MLNLuaAssert([((id<MLNStaticExportProtocol>)self) mln_currentLuaCore], ([(OBJ) isKindOfClass:([NATIVE_TYPE class])]), @"The parameter type must be %@ and not a nil value!", LUA_TYPE);

/**
 可实例化类的字符串检查断言
 ⚠️ 必须遵循MLNEntityExportProtocol协议，才能使用该宏定义
 
 @param OBJ 要做类型校验的字符串
 */
#define MLNCheckStringTypeAndNilValue(OBJ)\
MLNCheckTypeAndNilValue(OBJ, @"string", NSString)

/**
 静态类的字符串检查断言
 ⚠️ 必须遵循MLNStaticExportProtocol协议，才能使用该宏定义
 
 @param OBJ 要做类型校验的字符串
 */
#define MLNStaticCheckStringTypeAndNilValue(OBJ)\
MLNStaticCheckTypeAndNilValue(OBJ, @"string", NSString)

/**
 可实例化类的宽度检查断言
 ⚠️ 必须遵循MLNEntityExportProtocol协议，才能使用该宏定义
 
 @param VALUE 宽度
 */
#define MLNCheckWidth(VALUE) MLNKitLuaAssert((VALUE >= 0 || VALUE == MLNLayoutMeasurementTypeWrapContent || VALUE == MLNLayoutMeasurementTypeMatchParent), @"size must be set width positive number, error number: %@ .", @(VALUE));

/**
 可实例化类的高度检查断言
 ⚠️ 必须遵循MLNEntityExportProtocol协议，才能使用该宏定义
 
 @param VALUE 高度
 */
#define MLNCheckHeight(VALUE) MLNKitLuaAssert((VALUE >= 0 || VALUE == MLNLayoutMeasurementTypeWrapContent || VALUE == MLNLayoutMeasurementTypeMatchParent), @"size must be set height positive number, error number: %@ .", @(VALUE));

#endif /* MLNKitHeader_h */
