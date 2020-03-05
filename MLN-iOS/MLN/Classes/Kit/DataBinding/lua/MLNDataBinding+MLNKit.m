//
//  MLNDataBinding+MLNKit.m
//  AFNetworking
//
//  Created by Dai Dongpeng on 2020/3/3.
//

#import "MLNDataBinding+MLNKit.h"
#import "MLNStaticExporterMacro.h"
#import "MLNKitHeader.h"
#import "MLNKitViewController.h"
#import "MLNBlock.h"
#import "MLNBlockObserver.h"
#import "MLNKitViewController+DataBinding.h"

@implementation MLNDataBinding (MLNKit)

+ (void)lua_bindDataForKeyPath:(NSString *)keyPath handler:(MLNBlock *)handler {
    MLNKitViewController *kitViewController = (MLNKitViewController *)MLN_KIT_INSTANCE([self mln_currentLuaCore]).viewController;
    NSObject<MLNKVOObserverProtol> *observer = [MLNBlockObserver observerWithBlock:handler keyPath:keyPath];
    [kitViewController addDataObserver:observer forKeyPath:keyPath];
}

+ (id __nullable)lua_dataForKeyPath:(NSString *)keyPath
{
    MLNKitViewController *kitViewController = (MLNKitViewController *)MLN_KIT_INSTANCE([self mln_currentLuaCore]).viewController;
    return [kitViewController dataForKeyPath:keyPath];
}

+ (void)lua_updateDataForKeyPath:(NSString *)keyPath value:(id)value
{
    MLNKitViewController *kitViewController = (MLNKitViewController *)MLN_KIT_INSTANCE([self mln_currentLuaCore]).viewController;
    [kitViewController updateDataForKeyPath:keyPath value:value];
}

#pragma mark - ListView
+ (void)lua_bindListViewForKeyPath:(NSString *)keyPath listView:(UIView *)listView
{
//    MLNKitViewController *kitViewController = (MLNKitViewController *)MLN_KIT_INSTANCE([self mln_currentLuaCore]).viewController;
//    NSObject<MLNKVObserverProtocol> *observer = [[MLNListViewObserver alloc] initWithListView:listView];
//    [kitViewController addDataObserver:observer forKeyPath:keyPath];
}

+ (void)lua_bindDataListForKeyPath:(NSString *)keyPath handler:(MLNBlock *)handler
{
//    MLNKitViewController *kitViewController = (MLNKitViewController *)MLN_KIT_INSTANCE([self mln_currentLuaCore]).viewController;
//    NSObject<MLNKVObserverProtocol> *observer = [[MLNBlockObserver alloc] initWithBloclk:handler];
//    [kitViewController addDataObserver:observer forKeyPath:keyPath];
}

#pragma mark - Setup For Lua
LUA_EXPORT_STATIC_BEGIN(MLNDataBinding)
LUA_EXPORT_STATIC_METHOD(bind, "lua_bindDataForKeyPath:handler:", MLNDataBinding)
LUA_EXPORT_STATIC_METHOD(update, "lua_updateDataForKeyPath:value:", MLNDataBinding)
LUA_EXPORT_STATIC_METHOD(get, "lua_dataForKeyPath:", MLNDataBinding)
LUA_EXPORT_STATIC_END(MLNDataBinding, DataBinding, NO, NULL)

@end
