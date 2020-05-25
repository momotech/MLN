//
//  MLNUIInnerTableView.m
//  MLNUI
//
//  Created by MoMo on 2019/9/2.
//

#import "MLNUIInnerTableView.h"
#import "NSObject+MLNUICore.h"

@implementation MLNUIInnerTableView

- (BOOL)mln_isConvertible
{
    return [self.containerView mln_isConvertible];
}

- (MLNUILuaCore *)mln_luaCore
{
    return self.containerView.mln_luaCore;
}

@end
