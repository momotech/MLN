//
//  MLNLuaTable.h
//  MLNCore
//
//  Created by MoMo on 2019/7/24.
//

#import <Foundation/Foundation.h>
#import "MLNEntityExportProtocol.h"

typedef enum : NSInteger {
    MLNLuaTableEnvGlobal = -10002, // default
    MLNLuaTableEnvRegister = -10000,
} MLNLuaTableEnvironment;

NS_ASSUME_NONNULL_BEGIN

@class MLNLuaCore;

/**
 关联Lua table的原生类
  @note ⚠️该类的实例化和方法调用都只能在主队列执行
 */
@interface MLNLuaTable : NSObject

@property (nonatomic, weak, readonly) MLNLuaCore *luaCore;
@property (nonatomic, assign, readonly) MLNLuaTableEnvironment env;

- (instancetype)initWithLuaCore:(MLNLuaCore *)luaCore env:(MLNLuaTableEnvironment)env NS_DESIGNATED_INITIALIZER;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE; 

- (void)setObject:(id<MLNEntityExportProtocol>)obj key:(NSString *)key;
- (void)removeObject:(NSString *)key;

- (NSInteger)pushToLuaStack;

@end

NS_ASSUME_NONNULL_END
