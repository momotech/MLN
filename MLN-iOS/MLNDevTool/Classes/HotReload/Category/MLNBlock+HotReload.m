//
//  MLNBlock+LuaNative.m
//  MLNDebugger
//
//  Created by MoMo on 2019/8/7.
//

#import "MLNBlock+HotReload.h"
#import "MLNKit.h"

@implementation MLNBlock (HotReload)

- (void)errorLuaCall
{
    MLNLuaError(self.luaCore, @"error call, check argument type!");
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    if (self.luaCore) {
        return [self.class instanceMethodSignatureForSelector:@selector(errorLuaCall)];
    }
    return [super  methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    if (self.luaCore) {
        [self errorLuaCall];
    } else {
        [super  forwardInvocation:anInvocation];
    }
}

@end
