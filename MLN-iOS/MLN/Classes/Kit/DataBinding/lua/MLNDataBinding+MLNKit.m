//
//  MLNDataBinding+MLNKit.m
// MLN
//
//  Created by Dai Dongpeng on 2020/3/3.
//

#import "MLNDataBinding+MLNKit.h"
#import "MLNStaticExporterMacro.h"
#import "MLNKitHeader.h"
#import "MLNKitViewController.h"
#import "MLNBlock.h"
#import "MLNBlockObserver.h"
#import "MLNListViewObserver.h"
#import "NSObject+MLNKVO.h"
#import "NSArray+MLNKVO.h"
#import "NSDictionary+MLNKVO.h"
#import "NSArray+MLNSafety.h"
#import "MLNTableView.h"
#import "NSObject+MLNReflect.h"

@implementation MLNDataBinding (MLNKit)

+ (void)lua_bindDataForKeyPath:(NSString *)keyPath handler:(MLNBlock *)handler {
    NSParameterAssert(keyPath && handler);
    if (!handler || !keyPath) return;

    UIViewController<MLNDataBindingProtocol> *kitViewController = (UIViewController<MLNDataBindingProtocol> *)MLN_KIT_INSTANCE([self mln_currentLuaCore]).viewController;
    NSObject<MLNKVOObserverProtol> *observer = [MLNBlockObserver observerWithBlock:handler keyPath:keyPath];
    [kitViewController.mln_dataBinding addMLNObserver:observer forKeyPath:keyPath];
}

+ (void)lua_updateDataForKeyPath:(NSString *)keyPath value:(id)value {
    NSParameterAssert(keyPath);
    if(!keyPath) return;
    
    UIViewController<MLNDataBindingProtocol> *kitViewController = (UIViewController<MLNDataBindingProtocol> *)MLN_KIT_INSTANCE([self mln_currentLuaCore]).viewController;
    NSObject *obj = [value mln_convertToNativeObject];
    [kitViewController.mln_dataBinding updateDataForKeyPath:keyPath value:obj];
}

+ (id)mln_dataForKeyPath:(NSString *)keyPath {
    NSParameterAssert(keyPath);
    if(!keyPath) return nil;
    
    UIViewController<MLNDataBindingProtocol> *kitViewController = (UIViewController<MLNDataBindingProtocol> *)MLN_KIT_INSTANCE([self mln_currentLuaCore]).viewController;
    NSObject *obj = [kitViewController.mln_dataBinding dataForKeyPath:keyPath];
    return obj;
}

+ (id __nullable)lua_dataForKeyPath:(NSString *)keyPath {
    NSObject *obj = [self mln_dataForKeyPath:keyPath];
    return [obj mln_convertToLuaObject];
}


+ (void)lua_mockForKey:(NSString *)key data:(NSDictionary *)dic {
    NSParameterAssert(key);
    if(!key) return;
    
    UIViewController<MLNDataBindingProtocol> *kitViewController = (UIViewController<MLNDataBindingProtocol> *)MLN_KIT_INSTANCE([self mln_currentLuaCore]).viewController;
//    if ([dic isKindOfClass:[NSArray class]]) {
//        return [self lua_mockArrayForKey:key data:(NSArray *)dic callbackDic:nil];
//    }
    if (![dic isKindOfClass:[NSDictionary class]]) {
        NSLog(@"error %s, should be NSDictionary",__func__);
        return;
    }
//    NSMutableDictionary *map = dic.mln_mutalbeCopy;
    NSMutableDictionary *map = [dic mln_convertToNativeObject];
    [kitViewController.mln_dataBinding bindData:map forKey:key];
}

+ (void)lua_mockArrayForKey:(NSString *)key data:(NSArray *)data callbackDic:(NSDictionary *)callbackDic {
    NSParameterAssert(key && data);
    if(!key || !data) return;
    
    UIViewController<MLNDataBindingProtocol> *kitViewController = (UIViewController<MLNDataBindingProtocol> *)MLN_KIT_INSTANCE([self mln_currentLuaCore]).viewController;
    
    NSMutableArray *existData = [kitViewController.mln_dataBinding dataForKeyPath:key];
    if ([existData isKindOfClass:[NSMutableArray class]]) {
        [existData mln_startKVOIfMutable];
        return;
    }
    
    if (![data isKindOfClass:[NSArray class]]) {
        NSLog(@"error %s, should be NSArray",__func__);
        return;
    }
    NSMutableArray *array = [data mln_convertToNativeObject];
    [array mln_startKVOIfMutable];
    [kitViewController.mln_dataBinding bindArray:array forKey:key];

//    NSMutableArray *arr = [[kitViewController.mln_dataBinding dataForKeyPath:key] mutableCopy];
//    if (![arr isKindOfClass:[NSMutableArray class]]) {
//        NSLog(@"data of keypath: %@ is %@ , it should be NSMutableArray!",key, data);
//        return nil;
//    }
//    [kitViewController.mln_dataBinding updateDataForKeyPath:key value:arr];
//    [arr mln_startKVOIfMutable];
//    return arr;
}

#pragma mark - ListView
//+ (void)lua_bindListViewForKey:(NSString *)key listView:(UIView *)listView {
//    MLNKitViewController *kitViewController = (MLNKitViewController *)MLN_KIT_INSTANCE([self mln_currentLuaCore]).viewController;
//    MLNListViewObserver *observer = [MLNListViewObserver observerWithListView:listView keyPath:key];
//    [kitViewController.dataBinding addArrayObserver:observer forKey:key];
//}

// userData.source
+ (void)lua_bindListViewForKey:(NSString *)key listView:(UIView *)listView {
    NSParameterAssert(key && listView);
    if(!key || !listView) return;
    
    UIViewController<MLNDataBindingProtocol> *kitViewController = (UIViewController<MLNDataBindingProtocol> *)MLN_KIT_INSTANCE([self mln_currentLuaCore]).viewController;
    MLNListViewObserver *observer = [MLNListViewObserver observerWithListView:listView keyPath:key];
    
    [kitViewController.mln_dataBinding addMLNObserver:observer forKeyPath:key];
}

+ (NSUInteger)lua_sectionCountForKey:(NSString *)key {
    NSParameterAssert(key);
    if(!key) return 0;
    
    NSArray *arr = [self mln_dataForKeyPath:key];
    if (arr.mln_is2D) {
        return arr.count;
    }
    return 1;
}

+ (NSUInteger)lua_rowCountForKey:(NSString *)key section:(NSUInteger)section{
    NSParameterAssert(key);
    if(!key) return 0;
    
    NSArray *arr = [self mln_dataForKeyPath:key];
    if (section > arr.count || section == 0) {
        return 0;
    }
    
    if (arr.mln_is2D) {
        return [[arr mln_objectAtIndex:section - 1] count];
    }

    return arr.count;
}

+ (id)lua_modelForKey:(NSString *)key section:(NSUInteger)section row:(NSUInteger)row path:(NSString *)path {
    NSParameterAssert(key);
    if(!key) return nil;
    
    NSArray *array = [self mln_dataForKeyPath:key];
    id resust;
    @try {
        id tmp;
        if (array.mln_is2D) {
            tmp = [[[array mln_objectAtIndex:section - 1] mln_objectAtIndex:row - 1] mln_valueForKeyPath:path];
        } else {
            tmp = [[array mln_objectAtIndex:row - 1] mln_valueForKeyPath:path];
        }
        resust = [tmp mln_convertToLuaObject];
    } @catch (NSException *exception) {
        NSLog(@"%s exception: %@",__func__, exception);
    }
    return resust;
}

+ (void)lua_updateModelForKey:(NSString *)key section:(NSUInteger)section row:(NSUInteger)row path:(NSString *)path value:(id)value {
    NSParameterAssert(key);
    if(!key) return;
    
    NSArray *array = [self mln_dataForKeyPath:key];
    @try {
        NSObject *object;
        if (array.mln_is2D) {
            object = [[array mln_objectAtIndex:section - 1] mln_objectAtIndex:row - 1];
        } else {
            object = [array mln_objectAtIndex:row - 1];
        }
        
//        id oldValue = [object valueForKeyPath:path];
        NSObject *newValue = [value mln_convertToNativeObject];
        [object setValue:newValue forKeyPath:path];
        
    } @catch (NSException *exception) {
        NSLog(@"%s exception: %@",__func__, exception);
    }
}

+ (void)lua_bindCellForKey:(NSString *)key section:(NSUInteger)section row:(NSUInteger)row paths:(NSArray *)paths {
    NSParameterAssert(key && paths);
    if (!key || !paths) return;
    
    UIViewController<MLNDataBindingProtocol> *kitViewController = (UIViewController<MLNDataBindingProtocol> *)MLN_KIT_INSTANCE([self mln_currentLuaCore]).viewController;

    NSArray *array = [self mln_dataForKeyPath:key];
    MLNListViewObserver *listObserver = (MLNListViewObserver *)[kitViewController.mln_dataBinding observersForKeyPath:key].lastObject;
    if (![listObserver isKindOfClass:[MLNListViewObserver class]]) {
        NSLog(@"error: not found observer for key %@",key);
        return;
    }
    
    NSObject *model;
    if (array.mln_is2D) {
        model = [[array mln_objectAtIndex:section - 1] mln_objectAtIndex:row - 1];
    } else {
        model = [array mln_objectAtIndex:row - 1];
    }
    
    for (NSString *k in paths) {
        [model mln_removeObervationsForOwner:kitViewController.mln_dataBinding keyPath:k];
    }

    [kitViewController.mln_dataBinding mln_observeObject:model properties:paths withBlock:^(id  _Nonnull observer, id  _Nonnull object, NSString * _Nonnull keyPath, id  _Nonnull oldValue, id  _Nonnull newValue, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
        UIView *listView = [listObserver listView];
        if ([listView isKindOfClass:[MLNTableView class]]) {
            MLNTableView *table = (MLNTableView *)listView;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row - 1 inSection:section - 1];
            [table.adapter tableView:table.adapter.targetTableView reloadRowsAtIndexPaths:@[indexPath]];
            [table.adapter.targetTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        } else {
            
        }
    }];
}

#pragma mark - BindArray

+ (void)lua_bindArrayForKeyPath:(NSString *)keyPath handler:(MLNBlock *)handler {
    NSParameterAssert(handler && keyPath);
    if (!handler || !keyPath) return;
    
    UIViewController<MLNDataBindingProtocol> *kitViewController = (UIViewController<MLNDataBindingProtocol> *)MLN_KIT_INSTANCE([self mln_currentLuaCore]).viewController;
//    __weak id<MLNDataBindingProtocol> weakController = kitViewController;
    __block __weak NSObject<MLNKVOObserverProtol>* weakOb;
    
    NSObject<MLNKVOObserverProtol> *observer = [[MLNKVOObserver alloc] initWithViewController:kitViewController callback:^(NSString * _Nonnull kp, NSArray *  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
        /*
        if (!handler.luaCore && weakOb) {
            [weakController.mln_dataBinding removeArrayObserver:weakOb forKeyPath:keyPath];
            weakOb = nil;
            return;
        }
         */
        NSKeyValueChange type = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue];
        if (type == NSKeyValueChangeSetting) {
            object = [change objectForKey:NSKeyValueChangeNewKey];
        }
        if (handler && [object isKindOfClass:[NSArray class]]) {
            NSArray *n = [object mln_convertToLuaObject];
            [handler addObjArgument:n];
            [handler callIfCan];
        } else {
            NSAssert(false, @"object: %@ should be array",object);
        }
        
    } keyPath:keyPath];
    
    weakOb = observer;
    [kitViewController.mln_dataBinding addMLNObserver:observer forKeyPath:keyPath];
}

+ (void)lua_bindArrayDataForKey:(NSString *)key index:(NSUInteger)index dataKeyPath:(NSString *)dataKeyPath handler:(MLNBlock *)handler {
    NSParameterAssert(key && handler && dataKeyPath);
    if(!key || !handler || !dataKeyPath) return;
    
    index -= 1;
    UIViewController<MLNDataBindingProtocol> *kitViewController = (UIViewController<MLNDataBindingProtocol> *)MLN_KIT_INSTANCE([self mln_currentLuaCore]).viewController;
    NSArray *array = [kitViewController.mln_dataBinding dataForKeyPath:key];
    if ([array isKindOfClass:[NSArray class]] && index < [array count]) {
        NSObject *obj = [array objectAtIndex:index];
        [kitViewController.mln_dataBinding mln_observeObject:obj property:dataKeyPath withBlock:^(id  _Nonnull observer, id  _Nonnull object, id  _Nonnull oldValue, id  _Nonnull newValue, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
            [handler addObjArgument:[newValue mln_convertToLuaObject]];
            [handler addObjArgument:[oldValue mln_convertToLuaObject]];
            [handler callIfCan];
        }];
    }
}

+ (void)lua_updateArrayDataForKey:(NSString *)key index:(NSUInteger)index dataKeyPath:(NSString *)dataKeyPath newValue:(id)newValue {
    NSParameterAssert(key && dataKeyPath);
    if(!key || !dataKeyPath) return;
    
    index -= 1;
    UIViewController<MLNDataBindingProtocol> *kitViewController = (UIViewController<MLNDataBindingProtocol> *)MLN_KIT_INSTANCE([self mln_currentLuaCore]).viewController;
    NSArray *array = [kitViewController.mln_dataBinding dataForKeyPath:key];
    if ([array isKindOfClass:[NSArray class]] && index < [array count]) {
        NSObject *obj = [array objectAtIndex:index];
        @try {
            [obj setValue:[newValue mln_convertToNativeObject] forKey:dataKeyPath];
        } @catch (NSException *exception) {
            NSLog(@"%s exception: %@",__func__,exception);
        }
    }
}

+ (id)lua_getArrayDataForKey:(NSString *)key index:(NSUInteger)index dataKeyPath:(NSString *)dataKeyPath {
    NSParameterAssert(key);
    if(!key) return nil;
    
    index -= 1;
    id ret;
    UIViewController<MLNDataBindingProtocol> *kitViewController = (UIViewController<MLNDataBindingProtocol> *)MLN_KIT_INSTANCE([self mln_currentLuaCore]).viewController;
    NSArray *array = [kitViewController.mln_dataBinding dataForKeyPath:key];
    if ([array isKindOfClass:[NSArray class]] && index < [array count]) {
        @try {
            NSObject *obj = [array objectAtIndex:index];
            id newObj = [obj mln_valueForKeyPath:dataKeyPath];
            ret = [newObj mln_convertToLuaObject];
        } @catch (NSException *exception) {
            NSLog(@"%s exception: %@",__func__,exception);
        }
    }
    return ret;
}

+ (void)lua_aliasArrayDataForKey:(NSString *)key index:(NSUInteger)index alias:(NSString *)alias {
    NSParameterAssert(key && alias);
    if(!key || !alias)  return;
    
    index -= 1;
    UIViewController<MLNDataBindingProtocol> *kitViewController = (UIViewController<MLNDataBindingProtocol> *)MLN_KIT_INSTANCE([self mln_currentLuaCore]).viewController;
    NSArray *array = [kitViewController.mln_dataBinding dataForKeyPath:key];
    if ([array isKindOfClass:[NSArray class]] && index < [array count]) {
        @try {
            NSObject *obj = [array objectAtIndex:index];
            if (obj) {
                [kitViewController.mln_dataBinding bindData:obj forKey:alias];
            }
        } @catch (NSException *exception) {
            NSLog(@"%s exception: %@",__func__,exception);
        }
    }
}

#pragma mark - Setup For Lua
LUA_EXPORT_STATIC_BEGIN(MLNDataBinding)
LUA_EXPORT_STATIC_METHOD(bind, "lua_bindDataForKeyPath:handler:", MLNDataBinding)
LUA_EXPORT_STATIC_METHOD(update, "lua_updateDataForKeyPath:value:", MLNDataBinding)
LUA_EXPORT_STATIC_METHOD(get, "lua_dataForKeyPath:", MLNDataBinding)
LUA_EXPORT_STATIC_METHOD(mock, "lua_mockForKey:data:", MLNDataBinding)
LUA_EXPORT_STATIC_METHOD(mockArray, "lua_mockArrayForKey:data:callbackDic:", MLNDataBinding)

LUA_EXPORT_STATIC_METHOD(bindListView, "lua_bindListViewForKey:listView:", MLNDataBinding)
LUA_EXPORT_STATIC_METHOD(getSectionCount, "lua_sectionCountForKey:", MLNDataBinding)
LUA_EXPORT_STATIC_METHOD(getRowCount, "lua_rowCountForKey:section:", MLNDataBinding)
LUA_EXPORT_STATIC_METHOD(getModel, "lua_modelForKey:section:row:path:", MLNDataBinding)
LUA_EXPORT_STATIC_METHOD(updateModel, "lua_updateModelForKey:section:row:path:value:", MLNDataBinding)
//LUA_EXPORT_STATIC_METHOD(getReuseId, "lua_reuseIdForKey:section:row:", MLNDataBinding)
//LUA_EXPORT_STATIC_METHOD(getHeight, "lua_heightForKey:section:row:", MLNDataBinding)
LUA_EXPORT_STATIC_METHOD(bindCell, "lua_bindCellForKey:section:row:paths:", MLNDataBinding)

//LUA_EXPORT_STATIC_METHOD(getSize, "lua_sizeForKey:section:row:", MLNDataBinding)
LUA_EXPORT_STATIC_METHOD(bindArray, "lua_bindArrayForKeyPath:handler:", MLNDataBinding)
LUA_EXPORT_STATIC_METHOD(bindArrayData, "lua_bindArrayDataForKey:index:dataKeyPath:handler:", MLNDataBinding)
LUA_EXPORT_STATIC_METHOD(updateArrayData, "lua_updateArrayDataForKey:index:dataKeyPath:newValue:", MLNDataBinding)
LUA_EXPORT_STATIC_METHOD(getArrayData, "lua_getArrayDataForKey:index:dataKeyPath:", MLNDataBinding)
LUA_EXPORT_STATIC_METHOD(aliasArrayData, "lua_aliasArrayDataForKey:index:alias:", MLNDataBinding)

LUA_EXPORT_STATIC_END(MLNDataBinding, DataBinding, NO, NULL)

@end
