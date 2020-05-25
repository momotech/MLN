//
//  MLNUILink.m
//  MLNUI
//
//  Created by MOMO on 2020/4/30.
//

#import "MLNUILink.h"
#import "MLNUIKitHeader.h"
#import "MLNUIAnimationConst.h"
#import "MLNUILinkProtocol.h"

#define MLNUICURRENT_VIEW_CONTROLLLER  MLNUI_KIT_INSTANCE(self.mlnui_currentLuaCore).viewController
#define MLNUI_IS_VALID_CLASS(_class_) [_class_ respondsToSelector:@selector(mlnLinkCreateController:closeCallback:)]

@interface MLNUILink ()

@property (nonatomic, strong) NSMutableDictionary *nameClassMap;
@property (nonatomic, strong) NSMutableDictionary *linkLuaCallbackMap;

@end

@implementation MLNUILink

#pragma mark - Private

+ (MLNUILink *)sharedLink {
    static MLNUILink *link = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        link = [MLNUILink new];
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

+ (BOOL)gotoController:(UIViewController *)controller animation:(MLNUIAnimationAnimType)animation {
    NSParameterAssert([controller isKindOfClass:[UIViewController class]]);
    if ([controller isKindOfClass:[UIViewController class]] == NO) {
        return NO;
    }
    BOOL animate = (animation != MLNUIAnimationAnimTypeNone);
    UIViewController *currentController = MLNUICURRENT_VIEW_CONTROLLLER;
    switch (animation) {
        case MLNUIAnimationAnimTypeRightToLeft:
            NSParameterAssert(currentController.navigationController);
            [self pushToControllerIfNeeded:currentController controller:controller animate:animate];
            break;
            
        case MLNUIAnimationAnimTypeBottomToTop:
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
    MLNUIBlock *callback = [[self sharedLink].linkLuaCallbackMap objectForKey:key];
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
    NSParameterAssert(MLNUI_IS_VALID_CLASS(cls));
    if (!name || !cls) return;
    [[self sharedLink].nameClassMap setObject:cls forKey:name];
}

#pragma mark - Setup Lua

+ (void)luaui_link:(NSString *)luaClassName params:(NSDictionary *)params animation:(MLNUIAnimationAnimType)animation closeCallback:(MLNUIBlock *)callback {
    if (!luaClassName) {
        return;
    }
    Class cls = [[self sharedLink].nameClassMap objectForKey:luaClassName];
    if (!cls) return;
    if (MLNUI_IS_VALID_CLASS(cls)) {
        __block NSString *key = nil;
        MLNUILinkCloseCallback close = callback ? ^(NSDictionary *param) {
            [self callbackToLuaWhenClosePage:key params:param];
        } : nil;
        UIViewController *controller = [cls mlnLinkCreateController:params closeCallback:close];
        key = DISGUISE(controller);
        BOOL success = [self gotoController:controller animation:animation];
        if (success && callback) {
            [[self sharedLink].linkLuaCallbackMap setObject:callback forKey:key];
        }
    } else {
        MLNUIKitLuaStaticError(@"The %@ class (key is %@) does not implement MLNUILinkProtocol method.", cls, luaClassName);
    }
}

+ (void)luaui_closePage:(MLNUIAnimationAnimType)animation params:(NSDictionary *)params {
    UIViewController *currentController = MLNUICURRENT_VIEW_CONTROLLLER;
    if (!currentController) return;
    BOOL animate = (animation != MLNUIAnimationAnimTypeNone);
    if (currentController.navigationController) {
        [currentController.navigationController popViewControllerAnimated:animate];
    } else {
        [currentController dismissViewControllerAnimated:animate completion:nil];
    }
    [self callbackToLuaWhenClosePage:DISGUISE(currentController) params:params];
}

LUA_EXPORT_STATIC_BEGIN(MLNUILink)
LUA_EXPORT_STATIC_METHOD(link, "luaui_link:params:animation:closeCallback:", MLNUILink)
LUA_EXPORT_STATIC_METHOD(close, "luaui_closePage:params:", MLNUILink)
LUA_EXPORT_STATIC_END(MLNUILink, Link, NO, NULL)

@end
