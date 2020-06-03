//
//  MLNUINavigator.m
//  
//
//  Created by MoMo on 2018/8/21.
//

#import "MLNUINavigator.h"
#import "MLNUINavigatorHandlerProtocol.h"
#import "MLNUIKitHeader.h"
#import "MLNUIKitInstance.h"
#import "MLNUIKitInstanceHandlersManager.h"

#define MLNUICURRENT_VIEW_CONTROLLLER  MLNUI_KIT_INSTANCE(self.mlnui_currentLuaCore).viewController

@implementation MLNUINavigator

+ (void)luaui_gotoPage:(NSString *)action params:(NSDictionary *)params animType:(MLNUIAnimationAnimType)animType
{
    MLNUIStaticCheckStringTypeAndNilValue(action)
    id<MLNUINavigatorHandlerProtocol> delegate = [self navigatorHandler];
    MLNUIKitLuaStaticAssert([delegate respondsToSelector:@selector(viewController:gotoPage:params:animType:)], @"-[MLNUINavigator viewController:gotoPage:params:animType:] was not found!");
    if ([delegate respondsToSelector:@selector(viewController:gotoPage:params:animType:)]) {
        [delegate viewController:MLNUICURRENT_VIEW_CONTROLLLER gotoPage:action params:params animType:animType];
    }
}

+ (void)luaui_gotoAndCloseSelf:(NSString *)action params:(NSDictionary *)params animType:(MLNUIAnimationAnimType)animType
{
    MLNUIStaticCheckStringTypeAndNilValue(action)
    id<MLNUINavigatorHandlerProtocol> delegate = [self navigatorHandler];
    MLNUIKitLuaStaticAssert([delegate respondsToSelector:@selector(viewController:gotoAndCloseSelf:params:animType:)], @"-[MLNUINavigator viewController:gotoAndCloseSelf:params:animType:] was not found!");
    if ([delegate respondsToSelector:@selector(viewController:gotoAndCloseSelf:params:animType:)]) {
        [delegate viewController:MLNUICURRENT_VIEW_CONTROLLLER gotoAndCloseSelf:action params:params animType:animType];
    }
}

+ (void)luaui_closeSelf:(MLNUIAnimationAnimType)animType
{
    id<MLNUINavigatorHandlerProtocol> delegate = [self navigatorHandler];
     MLNUIKitLuaStaticAssert([delegate respondsToSelector:@selector(viewController:closeSelf:)], @"-[MLNUINavigator viewController:closeSelf:] was not found!");
    if ([delegate respondsToSelector:@selector(viewController:closeSelf:)]) {
        [delegate viewController:MLNUICURRENT_VIEW_CONTROLLLER closeSelf:animType];
    }
}

+ (BOOL)luaui_closeToLuaPage:(NSString *)pageName
{
    MLNUIStaticCheckStringTypeAndNilValue(pageName)
    id<MLNUINavigatorHandlerProtocol> delegate = [self navigatorHandler];
    MLNUIKitLuaStaticAssert([delegate respondsToSelector:@selector(viewController:closeToLuaPage:animateType:)], @"-[MLNUINavigator viewController:closeToLuaPage:animateType:] was not found!");
    if ([delegate respondsToSelector:@selector(viewController:closeToLuaPage:animateType:)]) {
        BOOL finished =  [delegate viewController:MLNUICURRENT_VIEW_CONTROLLLER closeToLuaPage:pageName animateType:MLNUIAnimationAnimTypeNone];
        return finished;
    }
    return NO;
}

+ (id<MLNUINavigatorHandlerProtocol>)navigatorHandler
{
    return MLNUI_KIT_INSTANCE(self.mlnui_currentLuaCore).instanceHandlersManager.navigatorHandler;
}

#pragma mark - Setup For Lua
LUAUI_EXPORT_STATIC_BEGIN(MLNUINavigator)
LUAUI_EXPORT_STATIC_METHOD(gotoPage, "luaui_gotoPage:params:animType:", MLNUINavigator)
LUAUI_EXPORT_STATIC_METHOD(gotoLuaCodePage, "gotoLuaCodePage:animType:", MLNUINavigator)
LUAUI_EXPORT_STATIC_METHOD(gotoAndCloseSelf, "luaui_gotoAndCloseSelf:params:animType:", MLNUINavigator)
LUAUI_EXPORT_STATIC_METHOD(closeSelf, "luaui_closeSelf:", MLNUINavigator)
LUAUI_EXPORT_STATIC_METHOD(closeToLuaPageFinished, "luaui_closeToLuaPage:", MLNUINavigator)
LUAUI_EXPORT_STATIC_END(MLNUINavigator, Navigator, NO, NULL)

@end
