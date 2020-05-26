//
//  MLNUIEntityExport.h
//  MLNUICore
//
//  Created by MoMo on 2019/7/24.
//

#ifndef MLNUIEntityExport_h
#define MLNUIEntityExport_h

#import "MLNUIExportProtocol.h"

@class MLNUILuaCore;

/**
 可创建UserData 的实体导出类协议
 */
@protocol MLNUIEntityExportProtocol <MLNUIExportProtocol>

/**
 该对象对应的lua状态机
 */
@property(nonatomic, weak) MLNUILuaCore *mlnui_luaCore;

/**
 导出类时使用的描述信息

 @return 描述信息结构体对象
 */
+ (const mlnui_objc_class *)mlnui_clazzInfo;

/**
 获取该对象当前被lua引用的次数

 @return lua引用的次数
 */
- (int)mlnui_luaRetainCount;

/**
 该对象被lua引用，luaRetainCount + 1

 @param userData 引用该native对象的UserData
 */
- (void)mlnui_luaRetain:(MLNUIUserData *)userData;

/**
 该对象被lua引用释放， retainCount - 1
 */
- (void)mlnui_luaRelease;

@optional

/**
 真实的原生实例，如果该对象不是包装特定实例的对象，则返回该对象本身，否则返回被包装的实例
 
 @return 真实的原生实例
 */
- (id)mlnui_rawNativeData;

/**
 lua 释放该UserData时，会回调该方法，你可以实现该方法来做一些自定义释放操作，如释放Timer。
 */
- (void)mlnui_user_data_dealloc;

/**
 是否自定义类型转换压栈。
 */
- (BOOL)mlnui_isConvertible;

/**
 当前对象是否需要展开为多个参数压栈，默认不需要。
 */
- (BOOL)mlnui_isMultiple;

/**
 展开后的多个参数组, 默认返回空。
 */
- (NSArray *)mlnui_multipleParams;

@end

#endif /* MLNUIEntityExport_h */
