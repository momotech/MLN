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

 @param FORMAT 字符拼接格式
 @param ... 可变参数
 */
#define MLNKitLuaError(FORMAT, ...)\
MLNLuaError(self.mln_luaCore, FORMAT, ##__VA_ARGS__)

/**
 静态类的相关Error
 
 @param FORMAT 字符拼接格式
 @param ... 可变参数
 */
#define MLNKitLuaStaticError(FORMAT, ...)\
MLNLuaAssert(self.mln_currentLuaCore, FORMAT, ##__VA_ARGS__)

/**
 可实例化对象的相关断言
 
 @param CONDITION 判断条件
 @param FORMAT 字符拼接格式
 @param ... 可变参数
 */
#define MLNKitLuaAssert(CONDITION, FORMAT, ...) \
MLNLuaAssert(((id<MLNEntityExportProtocol>)self).mln_luaCore, CONDITION, FORMAT, ##__VA_ARGS__)

/**
 静态类的相关断言
 
 @param CONDITION 判断条件
 @param FORMAT 字符拼接格式
 @param ... 可变参数
 */
#define MLNKitLuaStaticAssert(CONDITION, FORMAT, ...)\
MLNLuaAssert(self.mln_currentLuaCore, CONDITION, FORMAT, ##__VA_ARGS__)



#define MLNCheckTypeAndNilValue(OBJ, LUA_TYPE, NATIVE_TYPE)\
MLNLuaAssert(self.mln_luaCore, ([(OBJ) isKindOfClass:([NATIVE_TYPE class])]), @"The parameter type must be %@ and not a nil value!", LUA_TYPE);

#define MLNStaticCheckTypeAndNilValue(OBJ, LUA_TYPE, NATIVE_TYPE)\
MLNLuaAssert(self.mln_currentLuaCore, ([(OBJ) isKindOfClass:([NATIVE_TYPE class])]), @"The parameter type must be %@ and not a nil value!", LUA_TYPE);

#define MLNCheckStringTypeAndNilValue(OBJ)\
MLNCheckTypeAndNilValue(OBJ, @"string", NSString)

#define MLNStaticCheckStringTypeAndNilValue(OBJ)\
MLNStaticCheckTypeAndNilValue(OBJ, @"string", NSString)

#define MLNCheckWidth(VALUE) MLNKitLuaAssert((VALUE >= 0 || VALUE == MLNLayoutMeasurementTypeWrapContent || VALUE == MLNLayoutMeasurementTypeMatchParent), @"size must be set width positive number, error number: %@ .", @(VALUE));

#define MLNCheckHeight(VALUE) MLNKitLuaAssert((VALUE >= 0 || VALUE == MLNLayoutMeasurementTypeWrapContent || VALUE == MLNLayoutMeasurementTypeMatchParent), @"size must be set height positive number, error number: %@ .", @(VALUE));



#endif /* MLNKitHeader_h */
