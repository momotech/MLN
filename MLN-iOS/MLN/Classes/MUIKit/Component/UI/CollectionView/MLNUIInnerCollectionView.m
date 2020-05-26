//
//  MLNUIInnerCollectionView.m
//  MLNUI
//
//  Created by MoMo on 2019/9/2.
//

#import "MLNUIInnerCollectionView.h"
#import "NSObject+MLNUICore.h"

@implementation MLNUIInnerCollectionView

- (BOOL)mlnui_isConvertible
{
    return [self.containerView mlnui_isConvertible];
}

- (MLNUILuaCore *)mlnui_luaCore
{
    return self.containerView.mlnui_luaCore;
}

@end
