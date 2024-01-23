//
//  MLNKitInstanceDelegate.h
//  MLN
//
//  Created by MoMo on 2019/9/4.
//

#ifndef MLNKitInstanceDelegate_h
#define MLNKitInstanceDelegate_h

@class MLNKitInstance;

/**
 KitInstance代理协议
 */
@protocol MLNKitInstanceDelegate <NSObject>

@optional

/**
 即将装载Lua引擎

 @param instance 承载Lua引擎的实例
 */
- (void)willSetupLuaCore:(MLNKitInstance *)instance;

/**
 完成装载Lua引擎
 
 @param instance 承载Lua引擎的实例
 */
- (void)didSetupLuaCore:(MLNKitInstance *)instance;

/**
 即将加载文件

 @param instance 承载Lua引擎的实例
 @param data 文件对应的数据
 @param fileName 文件路径
 */
- (void)instance:(MLNKitInstance *)instance willLoad:(NSData *)data fileName:(NSString *)fileName;

/**
 完成加载文件
 
 @param instance 承载Lua引擎的实例
 @param data 文件对应的数据
 @param fileName 文件路径
 */
- (void)instance:(MLNKitInstance *)instance didLoad:(NSData *)data fileName:(NSString *)fileName;

/**
 加载文件失败
 
 @param instance 承载Lua引擎的实例
 @param data 文件对应的数据
 @param fileName 文件路径
 @param error 错误信息
 */
- (void)instance:(MLNKitInstance *)instance didFailLoad:(NSData *)data fileName:(NSString *)fileName error:(NSError *)error;

/**
 模块执行完成

 @param instance 承载Lua引擎的实例
 @param entryFileName 被执行模块的入口文件
 */
- (void)instance:(MLNKitInstance *)instance didFinishRun:(NSString *)entryFileName;

/**
 模块执行失败

 @param instance 承载Lua引擎的实例
 @param entryFileName 被执行模块的入口文件
 @param error 失败的信息
 */
- (void)instance:(MLNKitInstance *)instance didFailRun:(NSString *)entryFileName error:(NSError *)error;

/**
 尝试加载其他路径文件
 
 @param instance 承载Lua引擎的实例
 @param currentPath 入口文件资源路径
 @param filePath 文件路径
 */
- (NSData *)instance:(MLNKitInstance *)instance tryLoad:(NSString *)currentPath filePath:(NSString *)filePath;

/// 加载bridge
/// @param instance 承载Lua引擎的实例
/// @param bridgeName bridgeName Lua侧桥接的名字
- (BOOL)instance:(MLNKitInstance *)instance loadBridge:(NSString *)bridgeName;

/**
 即将释放Lua引擎

 @param instance 承载Lua引擎的实例
 */
- (void)willReleaseLuaCore:(MLNKitInstance *)instance;

/**
 Lua引擎已释放
 
 @param instance 承载Lua引擎的实例
 */
- (void)didReleaseLuaCore:(MLNKitInstance *)instance;

@end

#endif /* MLNKitInstanceDelegate_h */
