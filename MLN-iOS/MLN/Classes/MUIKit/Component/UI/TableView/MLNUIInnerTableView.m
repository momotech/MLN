//
//  MLNInnerTableView.m
//  MLN
//
//  Created by MoMo on 2019/9/2.
//

#import "MLNInnerTableView.h"
#import "NSObject+MLNCore.h"

@implementation MLNInnerTableView

- (BOOL)mln_isConvertible
{
    return [self.containerView mln_isConvertible];
}

- (MLNLuaCore *)mln_luaCore
{
    return self.containerView.mln_luaCore;
}

@end
