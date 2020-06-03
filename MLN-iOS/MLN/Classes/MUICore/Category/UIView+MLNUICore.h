//
//  UIView+MLNUICore.h
//  MLNUICore
//
//  Created by MoMo on 2019/7/23.
//

#import <UIKit/UIKit.h>
#import "NSObject+MLNUICore.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIView (MLNUICore)

/**
 Lua创建的对象会默认调用该初始化方法
 
 @note 如果需要自定义初始化方法，第一个参数必须是luaCore。
 @param luaCore 对应的lua状态机
 @return Lua创建的实例对象
 */
- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore frame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
