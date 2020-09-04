//
//  MLNUILuaTable.h
//  MLNUICore
//
//  Created by MoMo on 2019/7/24.
//

#import <Foundation/Foundation.h>
#import "MLNUIEntityExportProtocol.h"

typedef enum : int {
    MLNUILuaTableEnvGlobal = -10002, // default
    MLNUILuaTableEnvRegister = -10000,
} MLNUILuaTableEnvironment;

NS_ASSUME_NONNULL_BEGIN

@class MLNUILuaCore;

/**
 关联Lua table的原生类
  @note ⚠️该类的实例化和方法调用都只能在主队列执行
 */
@interface MLNUILuaTable : NSObject

/**
 对应的Lua内核
 */
@property (nonatomic, weak, readonly) MLNUILuaCore *luaCore;

/**
 存储该Table的环境
 */
@property (nonatomic, assign, readonly) MLNUILuaTableEnvironment env;

/**
 创建LuaTable

 @param luaCore 对应的Lua内核
 @param env 存储环境
 @return LuaTable实例
 */
- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore env:(MLNUILuaTableEnvironment)env NS_DESIGNATED_INITIALIZER;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 设置Lua栈上指定位置的对象到该LuaTable

 @param objIndex 指定对象的下标
 @param key 对应的key
 */
- (void)setObjectWithIndex:(int)objIndex key:(NSString *)key;

/**
 设置Lua栈上指定位置的对象到该LuaTable

 @param objIndex 指定对象的下标
 @param cKey 对应的key
 */
- (void)setObjectWithIndex:(int)objIndex cKey:(void *)cKey;

/**
 设置key-value

 @param obj value对象
 @param key key值
 */
- (void)setObject:(id<MLNUIEntityExportProtocol>)obj key:(NSString *)key;
- (void)rawsetObject:(NSObject *)obj key:(NSString *)key;

- (void)setObject:(id<MLNUIEntityExportProtocol>)obj index:(int)index;
- (void)rawsetObject:(NSObject *)obj index:(int)index;
- (void)inseretObject:(NSObject *)obj index:(int)index;
/**
 设置key-value
 
 @param obj value对象
 @param cKey key值
 */
- (void)setObject:(id<MLNUIEntityExportProtocol>)obj cKey:(void *)cKey;

/**
 移除对象

 @param key 对应的key
 */
- (void)removeObject:(NSString *)key;

/**
 移除对象

 @param cKey 对应的key
 */
- (void)removeObjectForCKey:(void *)cKey;

/**
 将对应的Object压入栈顶

 @param key Object对应的key
 @return 返回NSNotFound则代表未找到或者压栈失败，否则代表成功
 */
- (NSInteger)pushObjectToLuaStack:(NSString *)key;

/**
 将对应的Object压入栈顶

 @param cKey Object对应的key
 @return 返回NSNotFound则代表未找到或者压栈失败，否则代表成功
 */
- (NSInteger)pushObjectToLuaStackForCKey:(void *)cKey;

/**
 将该table压入栈顶。

 @return 返回NSNotFound则代表未找到或者压栈失败，否则代表成功
 */
- (NSInteger)pushToLuaStack;

@end

NS_ASSUME_NONNULL_END
