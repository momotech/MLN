//
//  MLNUIDataBinding+MLNUIKit.m
// MLNUI
//
//  Created by Dai Dongpeng on 2020/3/3.
//

#import "MLNUIDataBinding+MLNKit.h"
#import "MLNUIStaticExporterMacro.h"
#import "MLNUIKitHeader.h"
#import "MLNUIKitViewController.h"
#import "MLNUIBlock.h"
#import "MLNUIBlockObserver.h"
#import "MLNUIListViewObserver.h"
#import "NSObject+MLNUIKVO.h"
#import "NSArray+MLNUIKVO.h"
#import "NSDictionary+MLNUIKVO.h"
#import "NSArray+MLNUISafety.h"
#import "MLNUITableView.h"
#import "NSObject+MLNUIReflect.h"

@implementation MLNUIDataBinding (MLNUIKit)

+ (NSString *)luaui_watchDataForKeys:(NSArray *)keys handler:(MLNUIBlock *)handler {
    NSParameterAssert(keys && handler);
    if(!keys || !handler)  return nil;
    UIViewController<MLNUIDataBindingProtocol> *kitViewController = (UIViewController<MLNUIDataBindingProtocol> *)MLNUI_KIT_INSTANCE([self mlnui_currentLuaCore]).viewController;
    
    if ([keys isKindOfClass:[NSArray class]]) {
        NSString *keyPath = [keys componentsJoinedByString:@"."];
        NSObject<MLNUIKVOObserverProtol> *observer = [MLNUIBlockObserver observerWithBlock:handler keyPath:keyPath];
        return [kitViewController.mlnui_dataBinding addMLNUIObserver:observer forKeys:keys];
    } else if([keys isKindOfClass:[NSString class]]){
        NSString *keyPath = (NSString *)keys;
        NSObject<MLNUIKVOObserverProtol> *observer = [MLNUIBlockObserver observerWithBlock:handler keyPath:keyPath];
        return [kitViewController.mlnui_dataBinding addMLNUIObserver:observer forKeyPath:keyPath];
    }
    return nil;
}

+ (void)luaui_updateDataForKeys:(NSArray *)keys value:(id)value {
    NSParameterAssert(keys);
    if(!keys) return;
    
    UIViewController<MLNUIDataBindingProtocol> *kitViewController = (UIViewController<MLNUIDataBindingProtocol> *)MLNUI_KIT_INSTANCE([self mlnui_currentLuaCore]).viewController;
    NSObject *obj = [value mlnui_convertToNativeObject];
    
    if ([keys isKindOfClass:[NSArray class]]) {
        [kitViewController.mlnui_dataBinding updateDataForKeys:keys value:obj];
    } else if([keys isKindOfClass:[NSString class]]) {
        [kitViewController.mlnui_dataBinding updateDataForKeyPath:(NSString *)keys value:obj];
    }
}

+ (id __nullable)luaui_dataForKeys:(NSArray *)keys {
    NSParameterAssert(keys);
    if(!keys) return nil;
    UIViewController<MLNUIDataBindingProtocol> *kitViewController = (UIViewController<MLNUIDataBindingProtocol> *)MLNUI_KIT_INSTANCE([self mlnui_currentLuaCore]).viewController;
    NSObject *obj;

    if ([keys isKindOfClass:[NSArray class]]) {
        obj = [kitViewController.mlnui_dataBinding dataForKeys:keys];
    } else if ([keys isKindOfClass:[NSString class]]) {
       obj = [self mlnui_dataForKeyPath:(NSString *)keys];
    }
    return [obj mlnui_convertToLuaObject];
}

+ (id)mlnui_dataForKeyPath:(NSString *)keyPath {
    NSParameterAssert(keyPath);
    if(!keyPath) return nil;
    
    UIViewController<MLNUIDataBindingProtocol> *kitViewController = (UIViewController<MLNUIDataBindingProtocol> *)MLNUI_KIT_INSTANCE([self mlnui_currentLuaCore]).viewController;
    NSObject *obj = [kitViewController.mlnui_dataBinding dataForKeyPath:keyPath];
    return obj;
}

+ (void)luaui_removeMLNUIObserverByID:(NSString *)observerID {
    NSParameterAssert(observerID);
    if(!observerID) return;
    UIViewController<MLNUIDataBindingProtocol> *kitViewController = (UIViewController<MLNUIDataBindingProtocol> *)MLNUI_KIT_INSTANCE([self mlnui_currentLuaCore]).viewController;
    [kitViewController.mlnui_dataBinding removeMLNUIObserverByID:observerID];
}

+ (void)luaui_mockForKey:(NSString *)key data:(NSDictionary *)dic {
    NSParameterAssert(key);
    if(!key) return;
    
    UIViewController<MLNUIDataBindingProtocol> *kitViewController = (UIViewController<MLNUIDataBindingProtocol> *)MLNUI_KIT_INSTANCE([self mlnui_currentLuaCore]).viewController;
//    if ([dic isKindOfClass:[NSArray class]]) {
//        return [self luaui_mockArrayForKey:key data:(NSArray *)dic callbackDic:nil];
//    }
    if (![dic isKindOfClass:[NSDictionary class]]) {
        NSLog(@"error %s, should be NSDictionary",__func__);
        return;
    }
//    NSMutableDictionary *map = dic.mlnui_mutalbeCopy;
    NSMutableDictionary *map = [dic mlnui_convertToNativeObject];
    [kitViewController.mlnui_dataBinding bindData:map forKey:key];
}

+ (void)luaui_mockArrayForKey:(NSString *)key data:(NSArray *)data callbackDic:(NSDictionary *)callbackDic {
    NSParameterAssert(key && data);
    if(!key || !data) return;
    
    UIViewController<MLNUIDataBindingProtocol> *kitViewController = (UIViewController<MLNUIDataBindingProtocol> *)MLNUI_KIT_INSTANCE([self mlnui_currentLuaCore]).viewController;
    
    NSMutableArray *existData = [kitViewController.mlnui_dataBinding dataForKeyPath:key];
    if ([existData isKindOfClass:[NSMutableArray class]]) {
        [existData mlnui_startKVOIfMutable];
        return;
    }
    
    if (![data isKindOfClass:[NSArray class]]) {
        NSLog(@"error %s, should be NSArray",__func__);
        return;
    }
    NSMutableArray *array = [data mlnui_convertToNativeObject];
    [array mlnui_startKVOIfMutable];
    [kitViewController.mlnui_dataBinding bindArray:array forKey:key];

//    NSMutableArray *arr = [[kitViewController.mlnui_dataBinding dataForKeyPath:key] mutableCopy];
//    if (![arr isKindOfClass:[NSMutableArray class]]) {
//        NSLog(@"data of keypath: %@ is %@ , it should be NSMutableArray!",key, data);
//        return nil;
//    }
//    [kitViewController.mlnui_dataBinding updateDataForKeyPath:key value:arr];
//    [arr mlnui_startKVOIfMutable];
//    return arr;
}

#pragma mark - ListView
//+ (void)luaui_bindListViewForKey:(NSString *)key listView:(UIView *)listView {
//    MLNUIKitViewController *kitViewController = (MLNUIKitViewController *)MLNUI_KIT_INSTANCE([self mlnui_currentLuaCore]).viewController;
//    MLNUIListViewObserver *observer = [MLNUIListViewObserver observerWithListView:listView keyPath:key];
//    [kitViewController.dataBinding addArrayObserver:observer forKey:key];
//}

// userData.source
+ (void)luaui_bindListViewForKey:(NSString *)key listView:(UIView *)listView {
    NSParameterAssert(key && listView);
    if(!key || !listView) return;
    
    UIViewController<MLNUIDataBindingProtocol> *kitViewController = (UIViewController<MLNUIDataBindingProtocol> *)MLNUI_KIT_INSTANCE([self mlnui_currentLuaCore]).viewController;
    MLNUIListViewObserver *observer = [MLNUIListViewObserver observerWithListView:listView keyPath:key];
    
    [kitViewController.mlnui_dataBinding addMLNUIObserver:observer forKeyPath:key];
}

+ (NSUInteger)luaui_sectionCountForKey:(NSString *)key {
    NSParameterAssert(key);
    if(!key) return 0;
    
    NSArray *arr = [self mlnui_dataForKeyPath:key];
    if (arr.mlnui_is2D) {
        return arr.count;
    }
    return 1;
}

+ (NSUInteger)luaui_rowCountForKey:(NSString *)key section:(NSUInteger)section{
    NSParameterAssert(key);
    if(!key) return 0;
    
    NSArray *arr = [self mlnui_dataForKeyPath:key];
    if (section > arr.count || section == 0) {
        return 0;
    }
    
    if (arr.mlnui_is2D) {
        return [[arr mlnui_objectAtIndex:section - 1] count];
    }

    return arr.count;
}

+ (id)luaui_modelForKey:(NSString *)key section:(NSUInteger)section row:(NSUInteger)row path:(NSString *)path {
    NSParameterAssert(key);
    if(!key) return nil;
    
    NSArray *array = [self mlnui_dataForKeyPath:key];
    id resust;
    @try {
        id tmp;
        if (array.mlnui_is2D) {
            tmp = [[[array mlnui_objectAtIndex:section - 1] mlnui_objectAtIndex:row - 1] mlnui_valueForKeyPath:path];
        } else {
            tmp = [[array mlnui_objectAtIndex:row - 1] mlnui_valueForKeyPath:path];
        }
        resust = [tmp mlnui_convertToLuaObject];
    } @catch (NSException *exception) {
        NSLog(@"%s exception: %@",__func__, exception);
    }
    return resust;
}

+ (void)luaui_updateModelForKey:(NSString *)key section:(NSUInteger)section row:(NSUInteger)row path:(NSString *)path value:(id)value {
    NSParameterAssert(key);
    if(!key) return;
    
    NSArray *array = [self mlnui_dataForKeyPath:key];
    @try {
        NSObject *object;
        if (array.mlnui_is2D) {
            object = [[array mlnui_objectAtIndex:section - 1] mlnui_objectAtIndex:row - 1];
        } else {
            object = [array mlnui_objectAtIndex:row - 1];
        }
        
//        id oldValue = [object valueForKeyPath:path];
        NSObject *newValue = [value mlnui_convertToNativeObject];
        [object setValue:newValue forKeyPath:path];
        
    } @catch (NSException *exception) {
        NSLog(@"%s exception: %@",__func__, exception);
    }
}

+ (void)luaui_bindCellForKey:(NSString *)key section:(NSUInteger)section row:(NSUInteger)row paths:(NSArray *)paths {
    NSParameterAssert(key && paths);
    if (!key || !paths) return;
    
    UIViewController<MLNUIDataBindingProtocol> *kitViewController = (UIViewController<MLNUIDataBindingProtocol> *)MLNUI_KIT_INSTANCE([self mlnui_currentLuaCore]).viewController;

    NSArray *array = [self mlnui_dataForKeyPath:key];
    MLNUIListViewObserver *listObserver = (MLNUIListViewObserver *)[kitViewController.mlnui_dataBinding observersForKeyPath:key].lastObject;
    if (![listObserver isKindOfClass:[MLNUIListViewObserver class]]) {
        NSLog(@"error: not found observer for key %@",key);
        return;
    }
    
    NSObject *model;
    if (array.mlnui_is2D) {
        model = [[array mlnui_objectAtIndex:section - 1] mlnui_objectAtIndex:row - 1];
    } else {
        model = [array mlnui_objectAtIndex:row - 1];
    }
    
    for (NSString *k in paths) {
        [model mlnui_removeObervationsForOwner:kitViewController.mlnui_dataBinding keyPath:k];
    }

    //TODO: 如果paths中有属性对应可变数组？
    [kitViewController.mlnui_dataBinding mlnui_observeObject:model properties:paths withBlock:^(id  _Nonnull observer, id  _Nonnull object, NSString * _Nonnull keyPath, id  _Nonnull oldValue, id  _Nonnull newValue, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
        UIView *listView = [listObserver listView];
        if ([listView isKindOfClass:[MLNUITableView class]]) {
            MLNUITableView *table = (MLNUITableView *)listView;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row - 1 inSection:section - 1];
            [table.adapter tableView:table.adapter.targetTableView reloadRowsAtIndexPaths:@[indexPath]];
            [table.adapter.targetTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        } else {
            
        }
    }];
}

#pragma mark - BindArray

+ (void)luaui_bindArrayForKeyPath:(NSString *)keyPath handler:(MLNUIBlock *)handler {
    NSParameterAssert(handler && keyPath);
    if (!handler || !keyPath) return;
    
    UIViewController<MLNUIDataBindingProtocol> *kitViewController = (UIViewController<MLNUIDataBindingProtocol> *)MLNUI_KIT_INSTANCE([self mlnui_currentLuaCore]).viewController;
//    __weak id<MLNUIDataBindingProtocol> weakController = kitViewController;
    __block __weak NSObject<MLNUIKVOObserverProtol>* weakOb;
    
    NSObject<MLNUIKVOObserverProtol> *observer = [[MLNUIKVOObserver alloc] initWithViewController:kitViewController callback:^(NSString * _Nonnull kp, NSArray *  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
        /*
        if (!handler.luaCore && weakOb) {
            [weakController.mlnui_dataBinding removeArrayObserver:weakOb forKeyPath:keyPath];
            weakOb = nil;
            return;
        }
         */
        NSKeyValueChange type = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue];
        if (type == NSKeyValueChangeSetting) {
            object = [change objectForKey:NSKeyValueChangeNewKey];
        }
        if (handler && [object isKindOfClass:[NSArray class]]) {
            NSArray *n = [object mlnui_convertToLuaObject];
            [handler addObjArgument:n];
            [handler callIfCan];
        } else {
            NSAssert(false, @"object: %@ should be array",object);
        }
        
    } keyPath:keyPath];
    
    weakOb = observer;
    [kitViewController.mlnui_dataBinding addMLNUIObserver:observer forKeyPath:keyPath];
}

+ (void)luaui_bindArrayDataForKey:(NSString *)key index:(NSUInteger)index dataKeyPath:(NSString *)dataKeyPath handler:(MLNUIBlock *)handler {
    NSParameterAssert(key && handler && dataKeyPath);
    if(!key || !handler || !dataKeyPath) return;
    
    index -= 1;
    UIViewController<MLNUIDataBindingProtocol> *kitViewController = (UIViewController<MLNUIDataBindingProtocol> *)MLNUI_KIT_INSTANCE([self mlnui_currentLuaCore]).viewController;
    NSArray *array = [kitViewController.mlnui_dataBinding dataForKeyPath:key];
    if ([array isKindOfClass:[NSArray class]] && index < [array count]) {
        NSObject *obj = [array objectAtIndex:index];
        [kitViewController.mlnui_dataBinding mlnui_observeObject:obj property:dataKeyPath withBlock:^(id  _Nonnull observer, id  _Nonnull object, id  _Nonnull oldValue, id  _Nonnull newValue, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
            [handler addObjArgument:[newValue mlnui_convertToLuaObject]];
            [handler addObjArgument:[oldValue mlnui_convertToLuaObject]];
            [handler callIfCan];
        }];
    }
}

+ (void)luaui_updateArrayDataForKey:(NSString *)key index:(NSUInteger)index dataKeyPath:(NSString *)dataKeyPath newValue:(id)newValue {
    NSParameterAssert(key && dataKeyPath);
    if(!key || !dataKeyPath) return;
    
    index -= 1;
    UIViewController<MLNUIDataBindingProtocol> *kitViewController = (UIViewController<MLNUIDataBindingProtocol> *)MLNUI_KIT_INSTANCE([self mlnui_currentLuaCore]).viewController;
    NSArray *array = [kitViewController.mlnui_dataBinding dataForKeyPath:key];
    if ([array isKindOfClass:[NSArray class]] && index < [array count]) {
        NSObject *obj = [array objectAtIndex:index];
        @try {
            [obj setValue:[newValue mlnui_convertToNativeObject] forKey:dataKeyPath];
        } @catch (NSException *exception) {
            NSLog(@"%s exception: %@",__func__,exception);
        }
    }
}

+ (id)luaui_getArrayDataForKey:(NSString *)key index:(NSUInteger)index dataKeyPath:(NSString *)dataKeyPath {
    NSParameterAssert(key);
    if(!key) return nil;
    
    index -= 1;
    id ret;
    UIViewController<MLNUIDataBindingProtocol> *kitViewController = (UIViewController<MLNUIDataBindingProtocol> *)MLNUI_KIT_INSTANCE([self mlnui_currentLuaCore]).viewController;
    NSArray *array = [kitViewController.mlnui_dataBinding dataForKeyPath:key];
    if ([array isKindOfClass:[NSArray class]] && index < [array count]) {
        @try {
            NSObject *obj = [array objectAtIndex:index];
            id newObj = [obj mlnui_valueForKeyPath:dataKeyPath];
            ret = [newObj mlnui_convertToLuaObject];
        } @catch (NSException *exception) {
            NSLog(@"%s exception: %@",__func__,exception);
        }
    }
    return ret;
}

+ (void)luaui_aliasArrayDataForKey:(NSString *)key index:(NSUInteger)index alias:(NSString *)alias {
    NSParameterAssert(key && alias);
    if(!key || !alias)  return;
    
    index -= 1;
    UIViewController<MLNUIDataBindingProtocol> *kitViewController = (UIViewController<MLNUIDataBindingProtocol> *)MLNUI_KIT_INSTANCE([self mlnui_currentLuaCore]).viewController;
    NSArray *array = [kitViewController.mlnui_dataBinding dataForKeyPath:key];
    if ([array isKindOfClass:[NSArray class]] && index < [array count]) {
        @try {
            NSObject *obj = [array objectAtIndex:index];
            if (obj) {
                [kitViewController.mlnui_dataBinding bindData:obj forKey:alias];
            }
        } @catch (NSException *exception) {
            NSLog(@"%s exception: %@",__func__,exception);
        }
    }
}

#pragma mark - Setup For Lua
LUA_EXPORT_STATIC_BEGIN(MLNUIDataBinding)
LUA_EXPORT_STATIC_METHOD(bind, "luaui_watchDataForKeys:handler:", MLNUIDataBinding)
LUA_EXPORT_STATIC_METHOD(update, "luaui_updateDataForKeys:value:", MLNUIDataBinding)
LUA_EXPORT_STATIC_METHOD(get, "luaui_dataForKeys:", MLNUIDataBinding)
LUA_EXPORT_STATIC_METHOD(remove, "luaui_removeMLNUIObserverByID:", MLNUIDataBinding)

LUA_EXPORT_STATIC_METHOD(mock, "luaui_mockForKey:data:", MLNUIDataBinding)
LUA_EXPORT_STATIC_METHOD(mockArray, "luaui_mockArrayForKey:data:callbackDic:", MLNUIDataBinding)

LUA_EXPORT_STATIC_METHOD(bindListView, "luaui_bindListViewForKey:listView:", MLNUIDataBinding)
LUA_EXPORT_STATIC_METHOD(getSectionCount, "luaui_sectionCountForKey:", MLNUIDataBinding)
LUA_EXPORT_STATIC_METHOD(getRowCount, "luaui_rowCountForKey:section:", MLNUIDataBinding)
LUA_EXPORT_STATIC_METHOD(getModel, "luaui_modelForKey:section:row:path:", MLNUIDataBinding)
LUA_EXPORT_STATIC_METHOD(updateModel, "luaui_updateModelForKey:section:row:path:value:", MLNUIDataBinding)
//LUA_EXPORT_STATIC_METHOD(getReuseId, "luaui_reuseIdForKey:section:row:", MLNUIDataBinding)
//LUA_EXPORT_STATIC_METHOD(getHeight, "luaui_heightForKey:section:row:", MLNUIDataBinding)
LUA_EXPORT_STATIC_METHOD(bindCell, "luaui_bindCellForKey:section:row:paths:", MLNUIDataBinding)

//LUA_EXPORT_STATIC_METHOD(getSize, "luaui_sizeForKey:section:row:", MLNUIDataBinding)
LUA_EXPORT_STATIC_METHOD(bindArray, "luaui_bindArrayForKeyPath:handler:", MLNUIDataBinding)
LUA_EXPORT_STATIC_METHOD(bindArrayData, "luaui_bindArrayDataForKey:index:dataKeyPath:handler:", MLNUIDataBinding)
LUA_EXPORT_STATIC_METHOD(updateArrayData, "luaui_updateArrayDataForKey:index:dataKeyPath:newValue:", MLNUIDataBinding)
LUA_EXPORT_STATIC_METHOD(getArrayData, "luaui_getArrayDataForKey:index:dataKeyPath:", MLNUIDataBinding)
LUA_EXPORT_STATIC_METHOD(aliasArrayData, "luaui_aliasArrayDataForKey:index:alias:", MLNUIDataBinding)

LUA_EXPORT_STATIC_END(MLNUIDataBinding, DataBinding, NO, NULL)

@end
