//
//  MLNStackConst.m
//  MLN
//
//  Created by MOMO on 2020/3/24.
//

#import "MLNStackConst.h"
#import "MLNGlobalVarExporterMacro.h"

@implementation MLNStackConst

LUA_EXPORT_GLOBAL_VAR_BEGIN()
LUA_EXPORT_GLOBAL_VAR(MainAxisAlignment, (@{@"START" :@(MLNStackMainAlignmentStart),
                                            @"CENTER":@(MLNStackMainAlignmentCenter),
                                            @"END"   :@(MLNStackMainAlignmentEnd),
                                            @"SPACE_BETWEEN":@(MLNStackMainAlignmentSpaceBetween),
                                            @"SPACE_AROUND" :@(MLNStackMainAlignmentSpaceAround),
                                            @"SPACE_EVENLY" :@(MLNStackMainAlignmentSpaceEvenly)}))

LUA_EXPORT_GLOBAL_VAR(CrossAxisAlignment, (@{@"START" :@(MLNStackCrossAlignmentStart),
                                             @"CENTER":@(MLNStackCrossAlignmentCenter),
                                             @"END"   :@(MLNStackCrossAlignmentEnd)}))
LUA_EXPORT_GLOBAL_VAR_END()

@end
