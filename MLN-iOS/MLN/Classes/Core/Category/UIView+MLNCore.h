//
//  UIView+MLNCore.h
//  MLNCore
//
//  Created by MoMo on 2019/7/23.
//

#import <UIKit/UIKit.h>
#import "NSObject+MLNCore.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIView (MLNCore)

/**
 Lua创建的对象会默认调用该初始化方法
 
 @note 如果需要自定义初始化方法，第一个参数必须是luaCore。
 @param luaCore 对应的lua状态机
 @return Lua创建的实例对象
 */
- (instancetype)initWithLuaCore:(MLNLuaCore *)luaCore frame:(CGRect)frame;

/**
 lua 释放该UserData时，会回调该方法，你可以实现该方法来做一些自定义释放操作。
 */
- (void)mln_user_data_dealloc;

@end

NS_ASSUME_NONNULL_END
