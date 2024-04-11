//
//  MLNCollectionViewConst.m
//  MLN
//
//  Created by xue.yunqiang on 2023/6/26.
//

#import "MLNCollectionViewConst.h"
#import "MLNGlobalVarExporterMacro.h"
@import UIKit;

@implementation MLNCollectionViewConst

#pragma mark - Setup For Lua
LUA_EXPORT_GLOBAL_VAR_BEGIN()
LUA_EXPORT_GLOBAL_VAR(ScrollToCellDirection, (@{@"TOP":@(UICollectionViewScrollPositionTop),
                                          @"CENTEREDVERTICALLY":@(UICollectionViewScrollPositionCenteredVertically),
                                                @"BOTTOM":@(UICollectionViewScrollPositionBottom),
                                                @"LEFT":@(UICollectionViewScrollPositionLeft),
                                                @"CENTERHORIZONTALLY":@(UICollectionViewScrollPositionCenteredHorizontally),
                                                @"RIGHT":@(UICollectionViewScrollPositionRight)
                                              }))
LUA_EXPORT_GLOBAL_VAR_END(MLNCollectionViewConst)
@end
