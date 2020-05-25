//
//  MLNUIInnerCollectionView.m
//  MLNUI
//
//  Created by MoMo on 2019/9/2.
//

#import "MLNUIInnerCollectionView.h"
#import "NSObject+MLNUICore.h"

@implementation MLNUIInnerCollectionView

- (BOOL)mln_isConvertible
{
    return [self.containerView mln_isConvertible];
}

- (MLNUILuaCore *)mln_luaCore
{
    return self.containerView.mln_luaCore;
}

@end
