//
//  MLNUIKitInstanceDelegate.h
//  MLNUI
//
//  Created by MoMo on 2019/9/4.
//

#ifndef MLNUIKitInstanceDelegate_h
#define MLNUIKitInstanceDelegate_h

@class MLNUIKitInstance;

/**
 KitInstance代理协议
 */
@protocol MLNUIKitInstanceDelegate <NSObject>

@optional

/**
 即将装载Lua引擎

 @param instance 承载Lua引擎的实例
 */
- (void)willSetupLuaCore:(MLNUIKitInstance *)instance;

/**
 完成装载Lua引擎
 
 @param instance 承载Lua引擎的实例
 */
- (void)didSetupLuaCore:(MLNUIKitInstance *)instance;

/**
 即将加载文件

 @param instance 承载Lua引擎的实例
 @param data 文件对应的数据
 @param fileName 文件路径
 */
- (void)instance:(MLNUIKitInstance *)instance willLoad:(NSData *)data fileName:(NSString *)fileName;

/**
 完成加载文件
 
 @param instance 承载Lua引擎的实例
 @param data 文件对应的数据
 @param fileName 文件路径
 */
- (void)instance:(MLNUIKitInstance *)instance didLoad:(NSData *)data fileName:(NSString *)fileName;

/**
 加载文件失败
 
 @param instance 承载Lua引擎的实例
 @param data 文件对应的数据
 @param fileName 文件路径
 @param error 错误信息
 */
- (void)instance:(MLNUIKitInstance *)instance didFailLoad:(NSData *)data fileName:(NSString *)fileName error:(NSError *)error;

/**
 模块执行完成

 @param instance 承载Lua引擎的实例
 @param entryFileName 被执行模块的入口文件
 */
- (void)instance:(MLNUIKitInstance *)instance didFinishRun:(NSString *)entryFileName;

/**
 模块执行失败

 @param instance 承载Lua引擎的实例
 @param entryFileName 被执行模块的入口文件
 @param error 失败的信息
 */
- (void)instance:(MLNUIKitInstance *)instance didFailRun:(NSString *)entryFileName error:(NSError *)error;

/**
 即将释放Lua引擎

 @param instance 承载Lua引擎的实例
 */
- (void)willReleaseLuaCore:(MLNUIKitInstance *)instance;

/**
 Lua引擎已释放
 
 @param instance 承载Lua引擎的实例
 */
- (void)didReleaseLuaCore:(MLNUIKitInstance *)instance;

@end

#endif /* MLNUIKitInstanceDelegate_h */
