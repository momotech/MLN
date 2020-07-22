//
//  UIView+MLNUICore.m
//  MLNUICore
//
//  Created by MoMo on 2019/7/23.
//

#import "UIView+MLNUICore.h"
#import <objc/runtime.h>

@implementation UIView (MLNUICore)

- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore frame:(CGRect)frame
{
    if (self =  [self initWithFrame:frame]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [self performSelector:@selector(setMlnui_luaCore:) withObject:luaCore];
#pragma clang diagnostic pop
    }
    return self;
}

- (MLNUINativeType)mlnui_nativeType
{
    return MLNUINativeTypeView;
}

//- (void)mlnui_user_data_dealloc
//{
//    [super mlnui_user_data_dealloc];
//    // 如果是归属于lua的视图，在对应UserData被GC时候，应该从界面上移除
//    if (self.mlnui_isLuaObject) {
//        [self removeFromSuperview];
//    }
//}

@end
