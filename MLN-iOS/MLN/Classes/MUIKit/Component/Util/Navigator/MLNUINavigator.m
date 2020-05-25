//
//  MLNNavigator.m
//  
//
//  Created by MoMo on 2018/8/21.
//

#import "MLNNavigator.h"
#import "MLNNavigatorHandlerProtocol.h"
#import "MLNKitHeader.h"
#import "MLNKitInstance.h"
#import "MLNKitInstanceHandlersManager.h"

#define MLNCURRENT_VIEW_CONTROLLLER  MLN_KIT_INSTANCE(self.mln_currentLuaCore).viewController

@implementation MLNNavigator

+ (void)lua_gotoPage:(NSString *)action params:(NSDictionary *)params animType:(MLNAnimationAnimType)animType
{
    MLNStaticCheckStringTypeAndNilValue(action)
    id<MLNNavigatorHandlerProtocol> delegate = [self navigatorHandler];
    MLNKitLuaStaticAssert([delegate respondsToSelector:@selector(viewController:gotoPage:params:animType:)], @"-[MLNNavigator viewController:gotoPage:params:animType:] was not found!");
    if ([delegate respondsToSelector:@selector(viewController:gotoPage:params:animType:)]) {
        [delegate viewController:MLNCURRENT_VIEW_CONTROLLLER gotoPage:action params:params animType:animType];
    }
}

+ (void)lua_gotoAndCloseSelf:(NSString *)action params:(NSDictionary *)params animType:(MLNAnimationAnimType)animType
{
    MLNStaticCheckStringTypeAndNilValue(action)
    id<MLNNavigatorHandlerProtocol> delegate = [self navigatorHandler];
    MLNKitLuaStaticAssert([delegate respondsToSelector:@selector(viewController:gotoAndCloseSelf:params:animType:)], @"-[MLNNavigator viewController:gotoAndCloseSelf:params:animType:] was not found!");
    if ([delegate respondsToSelector:@selector(viewController:gotoAndCloseSelf:params:animType:)]) {
        [delegate viewController:MLNCURRENT_VIEW_CONTROLLLER gotoAndCloseSelf:action params:params animType:animType];
    }
}

+ (void)lua_closeSelf:(MLNAnimationAnimType)animType
{
    id<MLNNavigatorHandlerProtocol> delegate = [self navigatorHandler];
     MLNKitLuaStaticAssert([delegate respondsToSelector:@selector(viewController:closeSelf:)], @"-[MLNNavigator viewController:closeSelf:] was not found!");
    if ([delegate respondsToSelector:@selector(viewController:closeSelf:)]) {
        [delegate viewController:MLNCURRENT_VIEW_CONTROLLLER closeSelf:animType];
    }
}

+ (BOOL)lua_closeToLuaPage:(NSString *)pageName
{
    MLNStaticCheckStringTypeAndNilValue(pageName)
    id<MLNNavigatorHandlerProtocol> delegate = [self navigatorHandler];
    MLNKitLuaStaticAssert([delegate respondsToSelector:@selector(viewController:closeToLuaPage:animateType:)], @"-[MLNNavigator viewController:closeToLuaPage:animateType:] was not found!");
    if ([delegate respondsToSelector:@selector(viewController:closeToLuaPage:animateType:)]) {
        BOOL finished =  [delegate viewController:MLNCURRENT_VIEW_CONTROLLLER closeToLuaPage:pageName animateType:MLNAnimationAnimTypeNone];
        return finished;
    }
    return NO;
}

+ (id<MLNNavigatorHandlerProtocol>)navigatorHandler
{
    return MLN_KIT_INSTANCE(self.mln_currentLuaCore).instanceHandlersManager.navigatorHandler;
}

#pragma mark - Setup For Lua
LUA_EXPORT_STATIC_BEGIN(MLNNavigator)
LUA_EXPORT_STATIC_METHOD(gotoPage, "lua_gotoPage:params:animType:", MLNNavigator)
LUA_EXPORT_STATIC_METHOD(gotoLuaCodePage, "gotoLuaCodePage:animType:", MLNNavigator)
LUA_EXPORT_STATIC_METHOD(gotoAndCloseSelf, "lua_gotoAndCloseSelf:params:animType:", MLNNavigator)
LUA_EXPORT_STATIC_METHOD(closeSelf, "lua_closeSelf:", MLNNavigator)
LUA_EXPORT_STATIC_METHOD(closeToLuaPageFinished, "lua_closeToLuaPage:", MLNNavigator)
LUA_EXPORT_STATIC_END(MLNNavigator, Navigator, NO, NULL)

@end
