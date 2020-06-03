//
//  MLNUIInnerTableView.m
//  MLNUI
//
//  Created by MoMo on 2019/9/2.
//

#import "MLNUIInnerTableView.h"
#import "NSObject+MLNUICore.h"

@implementation MLNUIInnerTableView

- (BOOL)mlnui_isConvertible
{
    return [self.containerView mlnui_isConvertible];
}

- (MLNUILuaCore *)mlnui_luaCore
{
    return self.containerView.mlnui_luaCore;
}

@end
