//
//  MLNUIInteractiveBehavior+Bridge.h
//  ArgoUI
//
//  Created by MOMO on 2020/6/22.
//

#import "MLNUIInteractiveBehavior.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNUIInteractiveBehavior (Bridge)

@property (nonatomic, strong, readonly) MLNUILuaCore *luaCore;

@end

NS_ASSUME_NONNULL_END
