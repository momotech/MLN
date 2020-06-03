//
//  MLNUIEditTextViewConst.m
//
//
//  Created by MoMo on 2018/8/17.
//

#import "MLNUIEditTextViewConst.h"
#import "MLNUIGlobalVarExporterMacro.h"

@implementation MLNUIEditTextViewConst

#pragma mark - Setup For Lua
LUAUI_EXPORT_GLOBAL_VAR_BEGIN()
LUAUI_EXPORT_GLOBAL_VAR(EditTextViewInputMode, (@{@"Normal":@(MLNUIEditTextViewInputModeNormal),
                                                @"Number":@(MLNUIEditTextViewInputModeNumber)}))
LUAUI_EXPORT_GLOBAL_VAR(ReturnType, (@{@"Default":@(MLNUIEditTextViewReturnTypeDefault),
                                     @"Go":@(MLNUIEditTextViewReturnTypeGo),
                                     @"Search":@(MLNUIEditTextViewReturnTypeSearch),
                                     @"Send":@(MLNUIEditTextViewReturnTypeSend),
                                     @"Next":@(MLNUIEditTextViewReturnTypeNext),
                                     @"Done":@(MLNUIEditTextViewReturnTypeDone)}))
LUAUI_EXPORT_GLOBAL_VAR_END()

@end
