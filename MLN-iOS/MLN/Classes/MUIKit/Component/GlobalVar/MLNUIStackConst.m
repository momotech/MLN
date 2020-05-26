//
//  MLNUIStackConst.m
//  MLNUI
//
//  Created by MOMO on 2020/3/24.
//

#import "MLNUIStackConst.h"
#import "MLNUIGlobalVarExporterMacro.h"

@implementation MLNUIStackConst

LUAUI_EXPORT_GLOBAL_VAR_BEGIN()
LUAUI_EXPORT_GLOBAL_VAR(MainAxisAlignment, (@{@"START" :@(MLNUIStackMainAlignmentStart),
                                            @"CENTER":@(MLNUIStackMainAlignmentCenter),
                                            @"END"   :@(MLNUIStackMainAlignmentEnd),
                                            @"SPACE_BETWEEN":@(MLNUIStackMainAlignmentSpaceBetween),
                                            @"SPACE_AROUND" :@(MLNUIStackMainAlignmentSpaceAround),
                                            @"SPACE_EVENLY" :@(MLNUIStackMainAlignmentSpaceEvenly)}))

LUAUI_EXPORT_GLOBAL_VAR(CrossAxisAlignment, (@{@"START" :@(MLNUIStackCrossAlignmentStart),
                                             @"CENTER":@(MLNUIStackCrossAlignmentCenter),
                                             @"END"   :@(MLNUIStackCrossAlignmentEnd)}))

LUAUI_EXPORT_GLOBAL_VAR(WrapType, (@{@"NOT_WRAP":@(MLNUIStackWrapTypeNone),
                                   @"WRAP"    :@(MLNUIStackWrapTypeWrap)}))

LUAUI_EXPORT_GLOBAL_VAR_END()

@end
