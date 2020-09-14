//
//  NSObject+MLNUICore.h
//  MLNUICore
//
//  Created by MoMo on 2019/7/23.
//

#import <Foundation/Foundation.h>
#import "MLNUIExportProtocol.h"

typedef enum : NSUInteger {
    MLNUINativeTypeObject,
    MLNUINativeTypeView,
    MLNUINativeTypeNumber,
    MLNUINativeTypeString,
    MLNUINativeTypeDictionary,
    MLNUINativeTypeMDictionary,
    MLNUINativeTypeArray,
    MLNUINativeTypeMArray,
    MLNUINativeTypeColor,
    MLNUINativeTypeValue,
    MLNUINativeTypeObervableMap,
    MLNUINativeTypeObervableArray,
} MLNUINativeType;

NS_ASSUME_NONNULL_BEGIN

@class MLNUILuaCore;
@interface NSObject (MLNUICore) <MLNUIExportProtocol>

/**
 标记当前对象是不是由Lua创建。
 
 @note 可转换前提下，才能标记为非Native视图，否则标记不生效
 */
@property (nonatomic, assign) BOOL mlnui_isLuaObject;

/**
 Lua创建的对象会默认调用该初始化方法

 @note 如果需要自定义初始化方法，第一个参数必须是luaCore。
 @param luaCore 对应的lua状态机
 @return Lua创建的实例对象
 */
- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore;

/**
 lua 释放该UserData时，会回调该方法，你可以实现该方法来做一些自定义释放操作。
 */
- (void)mlnui_user_data_dealloc NS_REQUIRES_SUPER;

/**
 是否可以转换成lua中的user data，默认为NO.

 @return 是否可转换，YES 为可以转换。
 */
- (BOOL)mlnui_isConvertible;

/**
 是否自定义转换压栈方式，默认为NO.
 
 @return YES 为自定义转换压栈。
 */
- (BOOL)mlnui_isCustomConversion;

/**
 自定义转换压栈方法

 @param error 错误信息
 @return 是否转换压栈成功
 */
- (BOOL)mlnui_convertToLuaStack:(NSError **)error;

/**
 当前对象是否需要展开为多个参数压栈，默认不需要。
 */
- (BOOL)mlnui_isMultiple;

/**
 展开后的多个参数组, 默认返回空。
 */
- (NSArray *)mlnui_multipleParams;

/**
 获取当前对象的原生类型，默认为MLNUINativeTypeObject.
 
 @return 当前对象的原生类型
 */
- (MLNUINativeType)mlnui_nativeType;

/**
 真实的原生实例，如果该对象不是包装特定实例的对象，则返回该对象本身，否则返回被包装的实例
 
 @return 真实的原生实例
 */
- (id)mlnui_rawNativeData;

@end

NS_ASSUME_NONNULL_END
