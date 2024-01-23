//
//  MLNLuaCoreDelegate.h
//  MLN
//
//  Created by MoMo on 2019/9/4.
//

#ifndef MLNLuaCoreDelegate_h
#define MLNLuaCoreDelegate_h

@class MLNLuaCore;
@protocol MLNLuaCoreDelegate <NSObject>

@optional
/**
 即将加载文件
 
 @param luaCore Lua引擎
 @param data 文件对应的数据
 @param filePath 文件路径
 */
- (void)luaCore:(MLNLuaCore *)luaCore willLoad:(NSData *)data filePath:(NSString *)filePath;

/**
 完成加载文件
 
 @param luaCore Lua引擎
 @param data 文件对应的数据
 @param filePath 文件路径
 */
- (void)luaCore:(MLNLuaCore *)luaCore didLoad:(NSData *)data filePath:(NSString *)filePath;

/**
 加载文件失败
 
 @param luaCore Lua引擎
 @param data 文件对应的数据
 @param filePath 文件路径
 @param error 错误信息
 */
- (void)luaCore:(MLNLuaCore *)luaCore didFailLoad:(NSData *)data filePath:(NSString *)filePath error:(NSError *)error;

/**
 尝试加载其他路径文件
 
 @param luaCore Lua引擎
 @param currentPath 入口文件资源路径
 @param filePath 文件路径
 */
- (NSData *)luaCore:(MLNLuaCore *)luaCore tryLoad:(NSString *)currentPath filePath:(NSString *)filePath;

/// 加载bridge
/// @param luaCore luaCore Lua引擎
/// @param bridgeName Lua侧桥接的名字
- (BOOL)luaCore:(MLNLuaCore *)luaCore loadBridge:(NSString *)bridgeName;

@end

#endif /* MLNLuaCoreDelegate_h */
