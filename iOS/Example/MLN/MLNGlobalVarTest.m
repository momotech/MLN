//
//  MLNGlobalVarTest.m
//  MLNCore_Example
//
//  Created by MoMo on 2019/8/1.
//  Copyright © 2019 MoMo. All rights reserved.
//

#import "MLNGlobalVarTest.h"

@implementation MLNGlobalVarTest

LUA_EXPORT_GLOBAL_VAR_BEGIN()
LUA_EXPORT_GLOBAL_VAR(idx, (@{@"tt":@(1),
                               @"aa":@(2)}))
LUA_EXPORT_GLOBAL_VAR_END()

@end
