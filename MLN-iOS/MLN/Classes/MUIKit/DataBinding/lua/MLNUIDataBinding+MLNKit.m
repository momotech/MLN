//
//  MLNUIDataBinding+MLNUIKit.m
// MLNUI
//
//  Created by Dai Dongpeng on 2020/3/3.
//

#import "MLNUIDataBinding+MLNKit.h"
#import "MLNUIStaticExporterMacro.h"
#import "MLNUIKitHeader.h"
#import <UIKit/UIKit.h>
#import "MLNUIBlock.h"
#import "MLNUIBlockObserver.h"
#import "MLNUIListViewObserver.h"
#import "NSObject+MLNUIKVO.h"
#import "NSArray+MLNUIKVO.h"
#import "NSDictionary+MLNUIKVO.h"
#import "NSArray+MLNUISafety.h"
#import "MLNUITableView.h"
#import "NSObject+MLNUIReflect.h"
#import "MLNUIMetamacros.h"
#import "MLNUIBlock+LazyCall.h"
#import "MLNUICollectionView.h"

@implementation MLNUIDataBinding (MLNUIKit)
#if !OCPERF_USE_C
#pragma mark - Watch/Get/Update
+ (NSString *)luaui_watchDataForKeys:(NSString *)keys handler:(MLNUIBlock *)handler {
    TICK();
    NSParameterAssert(keys && handler);
    if(!keys || !handler)  return nil;
    // PCallDB(__func__);

    UIViewController<MLNUIDataBindingProtocol> *kitViewController = (UIViewController<MLNUIDataBindingProtocol> *)MLNUI_KIT_INSTANCE([self mlnui_currentLuaCore]).viewController;
    
    NSObject<MLNUIKVOObserverProtol> *observer = [MLNUIBlockObserver observerWithBlock:handler keyPath:keys];
    NSString *obID = [kitViewController.mlnui_dataBinding addMLNUIObserver:observer forKeyPath:keys];
    TOCK("watch keys %s",keys.UTF8String);
    return obID;
}

+ (void)luaui_updateDataForKeys:(NSString *)keys value:(id)value {
    NSParameterAssert(keys);
    if(!keys) return;
    TICK();
    // PCallDB(__func__);

    UIViewController<MLNUIDataBindingProtocol> *kitViewController = (UIViewController<MLNUIDataBindingProtocol> *)MLNUI_KIT_INSTANCE([self mlnui_currentLuaCore]).viewController;
    NSObject *obj = [value mlnui_convertToNativeObject];
    
    [kitViewController.mlnui_dataBinding updateDataForKeyPath:(NSString *)keys value:obj];
    TOCK("update keys %s",keys.UTF8String);
}

+ (id __nullable)luaui_dataForKeys:(NSString *)keys {
    NSParameterAssert(keys);
    if(!keys) return nil;
    TICK();
    // PCallDB(__func__);

//    UIViewController<MLNUIDataBindingProtocol> *kitViewController = (UIViewController<MLNUIDataBindingProtocol> *)MLNUI_KIT_INSTANCE([self mlnui_currentLuaCore]).viewController;
    NSObject *obj = [self mlnui_dataForKeyPath:keys];
    NSObject *convertedObj = [obj mlnui_convertToLuaObject];
    TOCK("data for keys %s",keys.UTF8String);
    return convertedObj;
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
    TICK();
    // PCallDB(__func__);

    UIViewController<MLNUIDataBindingProtocol> *kitViewController = (UIViewController<MLNUIDataBindingProtocol> *)MLNUI_KIT_INSTANCE([self mlnui_currentLuaCore]).viewController;
    [kitViewController.mlnui_dataBinding removeMLNUIObserverByID:observerID];
    TOCK("remove observer by id %s",observerID.UTF8String);
}

#pragma mark - Mock

+ (void)luaui_mockForKey:(NSString *)key data:(NSDictionary *)dic {
    NSParameterAssert(key);
    if(!key) return;
    
    UIViewController<MLNUIDataBindingProtocol> *kitViewController = (UIViewController<MLNUIDataBindingProtocol> *)MLNUI_KIT_INSTANCE([self mlnui_currentLuaCore]).viewController;
//    if ([dic isKindOfClass:[NSArray class]]) {
//        return [self luaui_mockArrayForKey:key data:(NSArray *)dic callbackDic:nil];
//    }
    if (![dic isKindOfClass:[NSDictionary class]]) {
        NSString *log = [NSString stringWithFormat:@"data %@ should be kindOf NSDictionary",dic.class];
        [self onErrorLog:log];
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
        NSString *log = [NSString stringWithFormat:@"data %@ should be kindOf NSArray",data.class];
        [self onErrorLog:log];
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
//    UIViewController *kitViewController = (UIViewController *)MLNUI_KIT_INSTANCE([self mlnui_currentLuaCore]).viewController;
//    MLNUIListViewObserver *observer = [MLNUIListViewObserver observerWithListView:listView keyPath:key];
//    [kitViewController.dataBinding addArrayObserver:observer forKey:key];
//}

// userData.source
+ (void)luaui_bindListViewForKey:(NSString *)key listView:(UIView *)listView {
    NSParameterAssert(key && listView);
    if(!key || !listView) return;
    TICK();
    // PCallDB(__func__);

    UIViewController<MLNUIDataBindingProtocol> *kitViewController = (UIViewController<MLNUIDataBindingProtocol> *)MLNUI_KIT_INSTANCE([self mlnui_currentLuaCore]).viewController;
    MLNUIDataBinding *dataBinding = kitViewController.mlnui_dataBinding;
    
    __block NSString *obID;
//    __weak __typeof(MLNUIDataBinding*) weakBingding = dataBinding;
    MLNUIListViewObserver *observer = [MLNUIListViewObserver observerWithListView:listView keyPath:key callback:^(NSString * _Nonnull keyPath, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
//        __strong __typeof(MLNUIDataBinding*) strongBinding = weakBingding;
//        [strongBinding removeMLNUIObserverByID:obID];
//        [self luaui_bindListViewForKey:key listView:listView];
    }];
    
    [dataBinding setListView:listView tag:key];
    obID = [dataBinding addMLNUIObserver:observer forKeyPath:key];
    TOCK("bind list view for key %s",key.UTF8String);
}

+ (NSUInteger)luaui_sectionCountForKey:(NSString *)key {
    NSParameterAssert(key);
    if(!key) return 0;
    // PCallDB(__func__);

    NSArray *arr = [self mlnui_dataForKeyPath:key];
    if (arr.mlnui_is2D) {
        return arr.count;
    }
    return 1;
}

+ (NSUInteger)luaui_rowCountForKey:(NSString *)key section:(NSUInteger)section{
    NSParameterAssert(key);
    if(!key) return 0;
    // PCallDB(__func__);

    NSArray *arr = [self mlnui_dataForKeyPath:key];
    if (section > arr.count || section == 0) {
        return 0;
    }
    
    if (arr.mlnui_is2D) {
        return [[arr mlnui_objectAtIndex:section - 1] count];
    } else if(section != 1) {
        return 0;//1维，section错误.
    }
    return arr.count;
}

+ (void)luaui_bindCellForKey:(NSString *)key section:(NSUInteger)section row:(NSUInteger)row paths:(NSArray *)paths {
    NSParameterAssert(key && paths);
    if (!key || !paths) return;
    TICK();
    // PCallDB(__func__);

    UIViewController<MLNUIDataBindingProtocol> *kitViewController = (UIViewController<MLNUIDataBindingProtocol> *)MLNUI_KIT_INSTANCE([self mlnui_currentLuaCore]).viewController;

//    NSArray *array = [self mlnui_dataForKeyPath:key];
//    MLNUIListViewObserver *listObserver = (MLNUIListViewObserver *)[kitViewController.mlnui_dataBinding arrayObserversForKeyPath:key].lastObject;
//
//
//    if (![listObserver isKindOfClass:[MLNUIListViewObserver class]]) {
//        NSLog(@"error: not found observer for key %@",key);
//        return;
//    }
    
//    UIView *listView = [listObserver listView];
    UIView *listView = [kitViewController.mlnui_dataBinding listViewForTag:key];
    if (!listView)  return;
    
//    NSObject *model;
//    if (array.mlnui_is2D) {
//        model = [[array mlnui_objectAtIndex:section - 1] mlnui_objectAtIndex:row - 1];
//    } else {
//        model = [array mlnui_objectAtIndex:row - 1];
//    }
    
    NSMutableDictionary *infos = [listView mlnui_bindInfos];
    MLNUIDataBinding *dataBinding = kitViewController.mlnui_dataBinding;
    NSString *modelKey = [key stringByAppendingFormat:@".%zd.%zd",section,row];
    NSObject *cellModel = [dataBinding dataForKeyPath:modelKey];
    
    for (NSString *p in paths) {
        NSString *idKey = [key stringByAppendingFormat:@".%p.%@",cellModel,p];
        NSString *obID =  [infos objectForKey:idKey];
        if (obID) {
            [dataBinding removeMLNUIObserverByID:obID];
        }
        
        NSString *nk = [modelKey stringByAppendingFormat:@".%@",p];
        MLNUIKVOObserver *ob = [[MLNUIKVOObserver alloc] initWithViewController:kitViewController callback:^(NSString * _Nonnull keyPath, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
            if ([listView isKindOfClass:[MLNUITableView class]]) {
                MLNUITableView *table = (MLNUITableView *)listView;
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row - 1 inSection:section - 1];
                [table.adapter tableView:table.adapter.targetTableView reloadRowsAtIndexPaths:@[indexPath]];
                [table.adapter.targetTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            } else if([listView isKindOfClass:[MLNUICollectionView class]]){
                MLNUICollectionView *collection = (MLNUICollectionView *)listView;
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row - 1 inSection:section - 1];
                [collection.adapter collectionView:collection.adapter.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                [collection.adapter.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }
        } keyPath:nk];
        obID = [dataBinding addMLNUIObserver:ob forKeyPath:nk];
        if (obID) {
            [infos setObject:obID forKey:idKey];
        }
    }
    TOCK("bind cell for section %zd row %zd keys %s",section,row,paths.description.UTF8String);
    /*
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
    */
}

#pragma mark - Array

+ (void)luaui_insertForKey:(NSString *)key index:(int)index value:(id)value {
    NSParameterAssert(key && value);
    if(!key || !value) return;
    TICK();
    // PCallDB(__func__);

    NSMutableArray *arr = [self mlnui_dataForKeyPath:key];
    if ([arr isKindOfClass:[NSMutableArray class]]) {
        Class firstClass = [arr.firstObject class];
        NSObject *newValue;
        //TODO: value 如果是Dic，是否转成自定义Model?
        if (NO && [value isKindOfClass:[NSDictionary class]] && firstClass && ![firstClass isKindOfClass:[NSDictionary class]]) {
            @try {
                newValue = [firstClass new];
                for (NSString *k in [(NSDictionary *)value allKeys]) {
                    NSObject *nv = [value[k] mlnui_convertToNativeObject];
                    [newValue setValue:nv forKey:k];
                }
            } @catch (NSException *exception) {
                NSString *log = [NSString stringWithFormat:@"ex %@ %s",exception,__FUNCTION__];
                [self onErrorLog:log];
            }
        }
        if (!newValue) newValue = [value mlnui_convertToNativeObject];
        if(!newValue) return;
        
        if (index == -1) {
            [arr addObject:newValue];
            return;
        }
        index--;
        if (index >= 0 &&  index <= arr.count) {
            [arr insertObject:newValue atIndex:index];
            return;
        } else {
            NSString *log = [NSString stringWithFormat:@"index %d illeage, should match range of array [1, %zd]",index+1,arr.count];
            [self onErrorLog:log];
        }
    } else {
        NSString *log = [NSString stringWithFormat:@"type of object is %@, is not NSMutableArray",arr.class];
        [self onErrorLog:log];
    }
    TOCK("insert for key %s index %d",key.UTF8String,index);
}

+ (void)luaui_removeForKey:(NSString *)key index:(int)index {
    NSParameterAssert(key);
    if(!key) return;
    TICK();
    // PCallDB(__func__);

    NSMutableArray *arr = [self mlnui_dataForKeyPath:key];
    if ([arr isKindOfClass:[NSMutableArray class]]) {
        if (index == -1) {
            [arr removeLastObject];
            return;
        }
        index--;
        if (index >= 0 && index < arr.count) {
            [arr removeObjectAtIndex:index];
        } else {
            NSString *log = [NSString stringWithFormat:@"index %d illeage, should match range of array [1, %zd]",index+1,arr.count];
            [self onErrorLog:log];
        }
    } else {
        NSString *log = [NSString stringWithFormat:@"type of object is %@, is not NSMutableArray",arr.class];
        [self onErrorLog:log];
    }
    TOCK("remove for key %s index %d",key.UTF8String,index);
}

+ (NSUInteger)luaui_arraySizeForKey:(NSString *)key {
    NSParameterAssert(key);
    if(!key) return 0;
    // PCallDB(__func__);

    UIViewController<MLNUIDataBindingProtocol> *kitViewController = (UIViewController<MLNUIDataBindingProtocol> *)MLNUI_KIT_INSTANCE([self mlnui_currentLuaCore]).viewController;
    
    NSArray *keys = [key componentsSeparatedByString:@"."];
    NSObject *front;
    NSArray *arr = [kitViewController.mlnui_dataBinding dataForKeys:keys frontValue:&front];
    
    if (![arr isKindOfClass: [NSArray  class]]) {
        if ([front isKindOfClass:[NSArray class]]) {
            arr = (NSArray *)front;
        } else {
            NSString *log = [NSString stringWithFormat:@"%@ is not NSArray",key];
            [self onErrorLog:log];
            return 0;
        }
    }
    return arr.count;
}

#pragma mark - Utils

+ (void)onErrorLog:(NSString *)log {
#if DEBUG
    NSLog(@"%@",log);
    MLNUIError([self mlnui_currentLuaCore], @"%@",log);
#endif
}

#pragma mark - 废弃的方法

+ (id)luaui_modelForKey:(NSString *)key section:(NSUInteger)section row:(NSUInteger)row path:(NSString *)path {
    NSParameterAssert(key);
    if(!key) return nil;
    // PCallDB(__func__);

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
    // PCallDB(__func__);

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

+ (void)luaui_bindArrayForKeyPath:(NSString *)keyPath handler:(MLNUIBlock *)handler {
    NSParameterAssert(handler && keyPath);
    if (!handler || !keyPath) return;
    // PCallDB(__func__);

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
            [handler lazyCallIfCan:nil];
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
    // PCallDB(__func__);

    index -= 1;
    UIViewController<MLNUIDataBindingProtocol> *kitViewController = (UIViewController<MLNUIDataBindingProtocol> *)MLNUI_KIT_INSTANCE([self mlnui_currentLuaCore]).viewController;
    NSArray *array = [kitViewController.mlnui_dataBinding dataForKeyPath:key];
    if ([array isKindOfClass:[NSArray class]] && index < [array count]) {
        NSObject *obj = [array objectAtIndex:index];
        [kitViewController.mlnui_dataBinding mlnui_observeObject:obj property:dataKeyPath withBlock:^(id  _Nonnull observer, id  _Nonnull object, id  _Nonnull oldValue, id  _Nonnull newValue, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
            [handler addObjArgument:[newValue mlnui_convertToLuaObject]];
//            [handler addObjArgument:[oldValue mlnui_convertToLuaObject]];
            [handler lazyCallIfCan:nil];
        }];
    }
}

+ (void)luaui_updateArrayDataForKey:(NSString *)key index:(NSUInteger)index dataKeyPath:(NSString *)dataKeyPath newValue:(id)newValue {
    NSParameterAssert(key && dataKeyPath);
    if(!key || !dataKeyPath) return;
    // PCallDB(__func__);

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
    // PCallDB(__func__);

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
    // PCallDB(__func__);

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

+ (void)test_nop {
    return;
}

#pragma mark - Setup For Lua
LUAUI_EXPORT_STATIC_BEGIN(MLNUIDataBinding)
LUAUI_EXPORT_STATIC_METHOD(bind, "luaui_watchDataForKeys:handler:", MLNUIDataBinding)
LUAUI_EXPORT_STATIC_METHOD(watch, "luaui_watchDataForKeys:handler:", MLNUIDataBinding)
LUAUI_EXPORT_STATIC_METHOD(update, "luaui_updateDataForKeys:value:", MLNUIDataBinding)
LUAUI_EXPORT_STATIC_METHOD(get, "luaui_dataForKeys:", MLNUIDataBinding)
LUAUI_EXPORT_STATIC_METHOD(removeObserver, "luaui_removeMLNUIObserverByID:", MLNUIDataBinding)

LUAUI_EXPORT_STATIC_METHOD(mock, "luaui_mockForKey:data:", MLNUIDataBinding)
LUAUI_EXPORT_STATIC_METHOD(mockArray, "luaui_mockArrayForKey:data:callbackDic:", MLNUIDataBinding)

LUAUI_EXPORT_STATIC_METHOD(insert, "luaui_insertForKey:index:value:", MLNUIDataBinding)
LUAUI_EXPORT_STATIC_METHOD(remove, "luaui_removeForKey:index:", MLNUIDataBinding)
LUAUI_EXPORT_STATIC_METHOD(arraySize, "luaui_arraySizeForKey:", MLNUIDataBinding)

LUAUI_EXPORT_STATIC_METHOD(bindListView, "luaui_bindListViewForKey:listView:", MLNUIDataBinding)
LUAUI_EXPORT_STATIC_METHOD(getSectionCount, "luaui_sectionCountForKey:", MLNUIDataBinding)
LUAUI_EXPORT_STATIC_METHOD(getRowCount, "luaui_rowCountForKey:section:", MLNUIDataBinding)
LUAUI_EXPORT_STATIC_METHOD(bindCell, "luaui_bindCellForKey:section:row:paths:", MLNUIDataBinding)

//废弃的方法
LUAUI_EXPORT_STATIC_METHOD(getModel, "luaui_modelForKey:section:row:path:", MLNUIDataBinding)
LUAUI_EXPORT_STATIC_METHOD(updateModel, "luaui_updateModelForKey:section:row:path:value:", MLNUIDataBinding)
//LUAUI_EXPORT_STATIC_METHOD(getReuseId, "luaui_reuseIdForKey:section:row:", MLNUIDataBinding)
//LUAUI_EXPORT_STATIC_METHOD(getHeight, "luaui_heightForKey:section:row:", MLNUIDataBinding)
//LUAUI_EXPORT_STATIC_METHOD(getSize, "luaui_sizeForKey:section:row:", MLNUIDataBinding)
LUAUI_EXPORT_STATIC_METHOD(bindArray, "luaui_bindArrayForKeyPath:handler:", MLNUIDataBinding)
LUAUI_EXPORT_STATIC_METHOD(bindArrayData, "luaui_bindArrayDataForKey:index:dataKeyPath:handler:", MLNUIDataBinding)
LUAUI_EXPORT_STATIC_METHOD(updateArrayData, "luaui_updateArrayDataForKey:index:dataKeyPath:newValue:", MLNUIDataBinding)
LUAUI_EXPORT_STATIC_METHOD(getArrayData, "luaui_getArrayDataForKey:index:dataKeyPath:", MLNUIDataBinding)
LUAUI_EXPORT_STATIC_METHOD(aliasArrayData, "luaui_aliasArrayDataForKey:index:alias:", MLNUIDataBinding)

#ifdef DEBUG
LUAUI_EXPORT_STATIC_METHOD(test_nop, "test_nop", MLNUIDataBinding)
#endif

LUAUI_EXPORT_STATIC_END(MLNUIDataBinding, DataBinding, NO, NULL)
#endif
@end
