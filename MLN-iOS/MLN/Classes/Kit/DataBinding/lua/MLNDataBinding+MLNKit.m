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
#import "MLNListViewObserver.h"
#import "NSArray+MLNKVO.h"

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
+ (void)lua_bindListViewForKey:(NSString *)key listView:(UIView *)listView
{
    MLNKitViewController *kitViewController = (MLNKitViewController *)MLN_KIT_INSTANCE([self mln_currentLuaCore]).viewController;
//    NSObject<MLNKVObserverProtocol> *observer = [[MLNListViewObserver alloc] initWithListView:listView];
//    [kitViewController addDataObserver:observer forKeyPath:keyPath];
    MLNListViewObserver *observer = [MLNListViewObserver observerWithListView:listView keyPath:key];
    [kitViewController.dataBinding addArrayObserver:observer forKey:key];
}

+ (void)lua_bindDataListForKeyPath:(NSString *)keyPath handler:(MLNBlock *)handler
{
//    MLNKitViewController *kitViewController = (MLNKitViewController *)MLN_KIT_INSTANCE([self mln_currentLuaCore]).viewController;
//    NSObject<MLNKVObserverProtocol> *observer = [[MLNBlockObserver alloc] initWithBloclk:handler];
//    [kitViewController addDataObserver:observer forKeyPath:keyPath];
}

+ (NSUInteger)lua_sectionCountForKey:(NSString *)key {
    NSArray *arr = [self lua_dataForKeyPath:key];
    NSArray *first = arr.firstObject;
    if ([first isKindOfClass:[NSArray class]]) {
        return arr.count;
    }
    return 1;
}

+ (NSUInteger)lua_rowCountForKey:(NSString *)key section:(NSUInteger)section{
    NSArray *arr = [self lua_dataForKeyPath:key];
    if (section > arr.count || section == 0) {
        return 0;
    }
    
    NSArray *first = arr[section - 1];
    if ([first isKindOfClass:[NSArray class]]) {
        return first.count;
    }
    return arr.count;
}

+ (id)lua_modelForKey:(NSString *)key section:(NSUInteger)section row:(NSUInteger)row path:(NSString *)path {
    NSArray *array = [self lua_dataForKeyPath:key];
    id resust = [[array objectAtIndex:row - 1] valueForKeyPath:path];
    return resust;
}

+ (NSString *)lua_reuseIdForKey:(NSString *)key section:(NSUInteger)section row:(NSUInteger)row {
    NSArray *array = [self lua_dataForKeyPath:key];
    if (array.mln_resueIdBlock) {
        return array.mln_resueIdBlock(array, section, row);
    }
    return @"Cell";
}

+ (NSUInteger)lua_heightForKey:(NSString *)key section:(NSUInteger)section row:(NSUInteger)row {
    NSArray *array = [self lua_dataForKeyPath:key];
    if (array.mln_heightBlock) {
        return array.mln_heightBlock(array, section, row);
    }
    NSAssert(array.mln_heightBlock, @"mln_heightBlock of binded array should not be nil");
    return 0;
}

#pragma mark - Setup For Lua
LUA_EXPORT_STATIC_BEGIN(MLNDataBinding)
LUA_EXPORT_STATIC_METHOD(bind, "lua_bindDataForKeyPath:handler:", MLNDataBinding)
LUA_EXPORT_STATIC_METHOD(update, "lua_updateDataForKeyPath:value:", MLNDataBinding)
LUA_EXPORT_STATIC_METHOD(get, "lua_dataForKeyPath:", MLNDataBinding)

LUA_EXPORT_STATIC_METHOD(bindListView, "lua_bindListViewForKey:listView:", MLNDataBinding)
LUA_EXPORT_STATIC_METHOD(getSectionCount, "lua_sectionCountForKey:", MLNDataBinding)
LUA_EXPORT_STATIC_METHOD(getRowCount, "lua_rowCountForKey:section:", MLNDataBinding)
LUA_EXPORT_STATIC_METHOD(getModel, "lua_modelForKey:section:row:path:", MLNDataBinding)
LUA_EXPORT_STATIC_METHOD(getReuseId, "lua_reuseIdForKey:section:row:", MLNDataBinding)
LUA_EXPORT_STATIC_METHOD(getHeight, "lua_heightForKey:section:row:", MLNDataBinding)

LUA_EXPORT_STATIC_END(MLNDataBinding, DataBinding, NO, NULL)

@end
