//
//  MLNUILuaCoreDelegate.h
//  MLNUI
//
//  Created by MoMo on 2019/9/4.
//

#ifndef MLNUILuaCoreDelegate_h
#define MLNUILuaCoreDelegate_h

@class MLNUILuaCore;
@protocol MLNUILuaCoreDelegate <NSObject>

@optional
/**
 即将加载文件
 
 @param luaCore Lua引擎
 @param data 文件对应的数据
 @param filePath 文件路径
 */
- (void)luaCore:(MLNUILuaCore *)luaCore willLoad:(NSData *)data filePath:(NSString *)filePath;

/**
 完成加载文件
 
 @param luaCore Lua引擎
 @param data 文件对应的数据
 @param filePath 文件路径
 */
- (void)luaCore:(MLNUILuaCore *)luaCore didLoad:(NSData *)data filePath:(NSString *)filePath;

/**
 加载文件失败
 
 @param luaCore Lua引擎
 @param data 文件对应的数据
 @param filePath 文件路径
 @param error 错误信息
 */
- (void)luaCore:(MLNUILuaCore *)luaCore didFailLoad:(NSData *)data filePath:(NSString *)filePath error:(NSError *)error;

@end

#endif /* MLNUILuaCoreDelegate_h */
