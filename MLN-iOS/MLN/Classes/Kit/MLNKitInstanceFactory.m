//
//  MLNKitInstanceBuidler.m
//  MLN
//
//  Created by MoMo on 2019/11/22.
//

#import "MLNKitInstanceFactory.h"
#import "MLNKitLuaCorePool.h"
#import "MLNKitInstance.h"
#import "MLNLuaBundle.h"

@interface MLNKitInstanceFactory ()

@property (nonatomic, strong) MLNKitLuaCorePool *luaCorePool;

@end

@implementation MLNKitInstanceFactory

static MLNKitInstanceFactory *_defaultFactory = nil;
+ (instancetype)defaultFactory
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultFactory = [[MLNKitInstanceFactory alloc] init];
    });
    return _defaultFactory;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _luaCorePool = [[MLNKitLuaCorePool alloc] init];
    }
    return self;
}

- (void)preloadWithCapacity:(NSUInteger)capacity
{
    [self.luaCorePool preloadWithCapacity:capacity];
}

- (MLNKitInstance *)createKitInstanceWithViewController:(UIViewController<MLNViewControllerProtocol> *)viewController
{
    return [self createKitInstanceWithLuaBundle:[MLNLuaBundle mainBundle] viewController:viewController];
}

- (MLNKitInstance *)createKitInstanceWithLuaBundle:(MLNLuaBundle *)luaBundle viewController:(UIViewController<MLNViewControllerProtocol> *)viewController
{
    return [self createKitInstanceWithLuaBundle:luaBundle rootView:nil viewController:viewController];
}

- (MLNKitInstance *)createKitInstanceWithLuaBundle:(MLNLuaBundle *__nullable)luaBundle rootView:(UIView *__nullable)rootView viewController:(UIViewController<MLNViewControllerProtocol> *)viewController
{
    return [[MLNKitInstance alloc] initWithLuaBundle:luaBundle luaCoreBuilder:self.luaCorePool rootView:rootView viewController:viewController];
}

@end
