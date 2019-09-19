//
//  MLNEditTextViewConst.m
//
//
//  Created by MoMo on 2018/8/17.
//

#import "MLNEditTextViewConst.h"
#import "MLNGlobalVarExporterMacro.h"

@implementation MLNEditTextViewConst

#pragma mark - Setup For Lua
LUA_EXPORT_GLOBAL_VAR_BEGIN()
LUA_EXPORT_GLOBAL_VAR(EditTextViewInputMode, (@{@"Normal":@(MLNEditTextViewInputModeNormal),
                                                @"Number":@(MLNEditTextViewInputModeNumber)}))
LUA_EXPORT_GLOBAL_VAR(ReturnType, (@{@"Default":@(MLNEditTextViewReturnTypeDefault),
                                     @"Go":@(MLNEditTextViewReturnTypeGo),
                                     @"Search":@(MLNEditTextViewReturnTypeSearch),
                                     @"Send":@(MLNEditTextViewReturnTypeSend),
                                     @"Next":@(MLNEditTextViewReturnTypeNext),
                                     @"Done":@(MLNEditTextViewReturnTypeDone)}))
LUA_EXPORT_GLOBAL_VAR_END()

@end
