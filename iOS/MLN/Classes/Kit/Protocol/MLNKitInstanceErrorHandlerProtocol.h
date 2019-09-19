//
//  MLNKitInstanceErrorHandlerProtocol.h
//  MLN
//
//  Created by MoMo on 2019/8/5.
//

#ifndef MLNKitInstanceErrorHandlerProtocol_h
#define MLNKitInstanceErrorHandlerProtocol_h

@class MLNKitInstance;

/**
 错误处理协议
 */
@protocol MLNKitInstanceErrorHandlerProtocol <NSObject>

/**
 是否处理Assert
 
 @param instance 异常的Lua运行实例
 @return YES / NO
 */
- (BOOL)canHandleAssert:(MLNKitInstance *)instance;

/**
 出现错误

 @param instance 异常的Lua运行实例
 @param error error 错误信息
 */
- (void)instance:(MLNKitInstance *)instance error:(NSString *)error;

/**
 出现错误
 
 @param instance 异常的Lua运行实例
 @param error 错误信息
 @param luaTraceback 当前Lua中的调用栈信息
 */
- (void)instance:(MLNKitInstance *)instance luaError:(NSString *)error luaTraceback:(NSString *)luaTraceback;

@end

#endif /* MLNKitInstanceErrorHandlerProtocol_h */
