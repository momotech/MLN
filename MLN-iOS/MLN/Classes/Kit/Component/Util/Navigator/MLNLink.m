//
//  MLNLink.m
//  MLN
//
//  Created by MOMO on 2020/4/30.
//

#import "MLNLink.h"
#import "MLNKitHeader.h"
#import "MLNAnimationConst.h"
#import "MLNLinkProtocol.h"

#define MLNCURRENT_VIEW_CONTROLLLER  MLN_KIT_INSTANCE(self.mln_currentLuaCore).viewController

@interface MLNLink ()

@property (nonatomic, strong) NSMutableDictionary *nameClassMap;
@property (nonatomic, strong) NSMutableDictionary *linkLuaCallbackMap;

@end

@implementation MLNLink

#pragma mark - Private

+ (MLNLink *)sharedLink {
    static MLNLink *link = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        link = [MLNLink new];
    });
    return link;
}

- (NSMutableDictionary *)nameClassMap {
    if (!_nameClassMap) {
        _nameClassMap = [NSMutableDictionary dictionary];
    }
    return _nameClassMap;
}

- (NSMutableDictionary *)linkLuaCallbackMap {
    if (!_linkLuaCallbackMap) {
        _linkLuaCallbackMap = [NSMutableDictionary dictionary];
    }
    return _linkLuaCallbackMap;
}

static inline NSString *DISGUISE(UIViewController *controller) {
    if (!controller) return nil;
    NSString *value = [NSString stringWithFormat:@"%p", controller];
    return value;
}

+ (BOOL)gotoController:(UIViewController *)controller animation:(MLNAnimationAnimType)animation {
    NSParameterAssert([controller isKindOfClass:[UIViewController class]]);
    if ([controller isKindOfClass:[UIViewController class]] == NO) {
        return NO;
    }
    BOOL animate = (animation != MLNAnimationAnimTypeNone);
    UIViewController *currentController = MLNCURRENT_VIEW_CONTROLLLER;
    switch (animation) {
        case MLNAnimationAnimTypeRightToLeft:
            NSParameterAssert(currentController.navigationController);
            [self pushToControllerIfNeeded:currentController controller:controller animate:animate];
            break;
            
        case MLNAnimationAnimTypeBottomToTop:
            [currentController presentViewController:controller animated:animate completion:nil];
            break;
            
        default:
            [self pushToControllerIfNeeded:currentController controller:controller animate:animate];
            break;
    }
    return YES;
}

+ (void)pushToControllerIfNeeded:(UIViewController *)pushingController controller:(UIViewController *)pushedController animate:(BOOL)animate {
    if (pushingController.navigationController) {
        [pushingController.navigationController pushViewController:pushedController animated:animate];
    } else {
        [pushingController presentViewController:pushedController animated:animate completion:nil];
    }
}

+ (void)callbackToLuaWhenClosePage:(NSString *)key params:(NSDictionary *)params{
    if (!key) return;
    MLNBlock *callback = [[self sharedLink].linkLuaCallbackMap objectForKey:key];
    if (callback) {
        [callback addBOOLArgument:YES];
        [callback addMapArgument:params];
        [callback callIfCan];
    }
    [[self sharedLink].linkLuaCallbackMap removeObjectForKey:key]; // does nothing if key does not exist.
}

#pragma mark - Public

+ (void)registerName:(NSString *)name linkClassName:(NSString *)clsName  {
   [self registerName:name linkClass:NSClassFromString(clsName)];
}

+ (void)registerName:(NSString *)name linkClass:(Class)cls {
    NSParameterAssert(name);
    NSParameterAssert(cls);
    if (!name || !cls) return;
    [[self sharedLink].nameClassMap setObject:cls forKey:name];
}

#pragma mark - Setup Lua

+ (void)lua_link:(NSString *)luaClassName params:(NSDictionary *)params animation:(MLNAnimationAnimType)animation closeCallback:(MLNBlock *)callback {
    if (!luaClassName) {
        return;
    }
    Class cls = [[self sharedLink].nameClassMap objectForKey:luaClassName];
    if (!cls) return;
    if ([cls respondsToSelector:@selector(mlnLinkCreateController:closeCallback:)]) {
        __block NSString *key = nil;
        MLNLinkCloseCallback close = callback ? ^(NSDictionary *param) {
            [self callbackToLuaWhenClosePage:key params:param];
        } : nil;
        UIViewController *controller = [cls mlnLinkCreateController:params closeCallback:close];
        key = DISGUISE(controller);
        BOOL success = [self gotoController:controller animation:animation];
        if (success && callback) {
            [[self sharedLink].linkLuaCallbackMap setObject:callback forKey:key];
        }
    } else {
        MLNKitLuaStaticError(@"The %@ class (key is %@) does not implement MLNLinkProtocol method.", cls, luaClassName);
    }
}

+ (void)lua_closePage:(MLNAnimationAnimType)animation params:(NSDictionary *)params {
    UIViewController *currentController = MLNCURRENT_VIEW_CONTROLLLER;
    if (!currentController) return;
    BOOL animate = (animation != MLNAnimationAnimTypeNone);
    if (currentController.navigationController) {
        [currentController.navigationController popViewControllerAnimated:animate];
    } else {
        [currentController dismissViewControllerAnimated:animate completion:nil];
    }
    [self callbackToLuaWhenClosePage:DISGUISE(currentController) params:params];
}

LUA_EXPORT_STATIC_BEGIN(MLNLink)
LUA_EXPORT_STATIC_METHOD(link, "lua_link:params:animation:closeCallback:", MLNLink)
LUA_EXPORT_STATIC_METHOD(close, "lua_closePage:params:", MLNLink)
LUA_EXPORT_STATIC_END(MLNLink, Link, NO, NULL)

@end
