//
//  MLNUIErrorHandlerProtocol.h
//  MLNUICore
//
//  Created by MoMo on 2019/8/1.
//

#ifndef MLNUIErrorHandlerProtocol_h
#define MLNUIErrorHandlerProtocol_h

@class MLNUILuaCore;

/**
 错误处理协议
 */
@protocol MLNUIErrorHandlerProtocol <NSObject>

/**
 是否处理Assert

 @param luaCore 当前Lua内核
 @return YES / NO
 */
- (BOOL)canHandleAssert:(MLNUILuaCore *)luaCore;

/**
 出现错误

 @param luaCore 当前Lua内核
 @param error 错误信息
 */
- (void)luaCore:(MLNUILuaCore *)luaCore error:(NSString *)error;

/**
 出现错误

 @param luaCore 当前Lua内核
 @param error 错误信息
 @param luaTraceback 当前Lua中的调用栈信息
 */
- (void)luaCore:(MLNUILuaCore *)luaCore luaError:(NSString *)error luaTraceback:(NSString *)luaTraceback;

@end

#endif /* MLNUIErrorHandlerProtocolN_h */
