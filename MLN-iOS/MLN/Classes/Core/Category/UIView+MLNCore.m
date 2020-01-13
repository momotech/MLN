//
//  UIView+MLNCore.m
//  MLNCore
//
//  Created by MoMo on 2019/7/23.
//

#import "UIView+MLNCore.h"
#import <objc/runtime.h>

@implementation UIView (MLNCore)

- (instancetype)initWithLuaCore:(MLNLuaCore *)luaCore frame:(CGRect)frame
{
    if (self =  [self initWithFrame:frame]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [self performSelector:@selector(setMln_luaCore:) withObject:luaCore];
#pragma clang diagnostic pop
    }
    return self;
}

- (MLNNativeType)mln_nativeType
{
    return MLNNativeTypeView;
}

- (void)mln_user_data_dealloc
{
    [super mln_user_data_dealloc];
    // 如果是归属于lua的视图，在对应UserData被GC时候，应该从界面上移除
    if (self.mln_isLuaObject) {
        [self removeFromSuperview];
    }
}

@end
