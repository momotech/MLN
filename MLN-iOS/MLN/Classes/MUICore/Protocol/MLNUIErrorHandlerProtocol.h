//
//  MLNErrorHandlerProtocol.h
//  MLNCore
//
//  Created by MoMo on 2019/8/1.
//

#ifndef MLNErrorHandlerProtocol_h
#define MLNErrorHandlerProtocol_h

@class MLNLuaCore;

/**
 错误处理协议
 */
@protocol MLNErrorHandlerProtocol <NSObject>

/**
 是否处理Assert

 @param luaCore 当前Lua内核
 @return YES / NO
 */
- (BOOL)canHandleAssert:(MLNLuaCore *)luaCore;

/**
 出现错误

 @param luaCore 当前Lua内核
 @param error 错误信息
 */
- (void)luaCore:(MLNLuaCore *)luaCore error:(NSString *)error;

/**
 出现错误

 @param luaCore 当前Lua内核
 @param error 错误信息
 @param luaTraceback 当前Lua中的调用栈信息
 */
- (void)luaCore:(MLNLuaCore *)luaCore luaError:(NSString *)error luaTraceback:(NSString *)luaTraceback;

@end

#endif /* MLNErrorHandlerProtocolN_h */
