//
//  MLNUIKitInstanceBuidler.m
//  MLNUI
//
//  Created by MoMo on 2019/11/22.
//

#import "MLNUIKitInstanceFactory.h"
#import "MLNUIKitLuaCorePool.h"
#import "MLNUIKitInstance.h"
#import "MLNUILuaBundle.h"

@interface MLNUIKitInstanceFactory ()

@property (nonatomic, strong) MLNUIKitLuaCorePool *luaCorePool;

@end

@implementation MLNUIKitInstanceFactory

static MLNUIKitInstanceFactory *_defaultFactory = nil;
+ (instancetype)defaultFactory
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultFactory = [[MLNUIKitInstanceFactory alloc] init];
    });
    return _defaultFactory;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _luaCorePool = [[MLNUIKitLuaCorePool alloc] init];
    }
    return self;
}

- (void)preloadWithCapacity:(NSUInteger)capacity
{
    [self.luaCorePool preloadWithCapacity:capacity];
}

- (MLNUIKitInstance *)createKitInstanceWithViewController:(UIViewController<MLNUIViewControllerProtocol> *)viewController
{
    return [self createKitInstanceWithLuaBundle:[MLNUILuaBundle mainBundle] viewController:viewController];
}

- (MLNUIKitInstance *)createKitInstanceWithLuaBundle:(MLNUILuaBundle *)luaBundle viewController:(UIViewController<MLNUIViewControllerProtocol> *)viewController
{
    return [self createKitInstanceWithLuaBundle:luaBundle rootView:nil viewController:viewController];
}

- (MLNUIKitInstance *)createKitInstanceWithLuaBundle:(MLNUILuaBundle *__nullable)luaBundle rootView:(UIView *__nullable)rootView viewController:(UIViewController<MLNUIViewControllerProtocol> *)viewController
{
    return [[MLNUIKitInstance alloc] initWithLuaBundle:luaBundle luaCoreBuilder:self.luaCorePool rootView:rootView viewController:viewController];
}

@end
