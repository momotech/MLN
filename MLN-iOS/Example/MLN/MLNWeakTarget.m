//
//  MLNWeakTarget.m
//  MLN_Example
//
//  Created by Feng on 2019/11/2.
//  Copyright © 2019 liu.xu_1586. All rights reserved.
//

#import "MLNWeakTarget.h"

@implementation MLNWeakTarget
{
    id _target;
}

- (instancetype)initWithObject:(NSObject *)object
{
    _target = object;
    
    return self;
}

+ (instancetype)weakTargetWithObject:(NSObject *)object
{
    id target = [[MLNWeakTarget alloc] initWithObject:object];
    return target;
}

- (id)forwardingTargetForSelector:(SEL)selector {
    return _target;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    return [_target methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    void *null = NULL;
    [invocation setReturnValue:null];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [_target respondsToSelector:aSelector];
}

- (BOOL)isEqual:(id)object {
    return [_target isEqual:object];
}

- (NSUInteger)hash {
    return [_target hash];
}

- (Class)superclass {
    return [_target superclass];
}

- (Class)class {
    return [_target class];
}

- (BOOL)isKindOfClass:(Class)aClass {
    return [_target isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass {
    return [_target isMemberOfClass:aClass];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return [_target conformsToProtocol:aProtocol];
}

- (BOOL)isProxy {
    return YES;
}

- (NSString *)description {
    return [_target description];
}

- (NSString *)debugDescription {
    return [_target debugDescription];
}

@end
