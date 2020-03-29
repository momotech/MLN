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
#import "MLNKitViewController+DataBinding.h"
#import "MLNListViewObserver.h"
#import "NSObject+MLNKVO.h"
#import "NSArray+MLNKVO.h"
#import "NSDictionary+MLNKVO.h"
#import <KVOController/KVOController.h>
#import "NSArray+MLNSafety.h"
#import "MLNTableView.h"

@implementation MLNDataBinding (MLNKit)

+ (void)lua_bindDataForKeyPath:(NSString *)keyPath handler:(MLNBlock *)handler {
    MLNKitViewController *kitViewController = (MLNKitViewController *)MLN_KIT_INSTANCE([self mln_currentLuaCore]).viewController;
    NSObject<MLNKVOObserverProtol> *observer = [MLNBlockObserver observerWithBlock:handler keyPath:keyPath];
    [kitViewController addDataObserver:observer forKeyPath:keyPath];
}

+ (void)lua_updateDataForKeyPath:(NSString *)keyPath value:(id)value {
    MLNKitViewController *kitViewController = (MLNKitViewController *)MLN_KIT_INSTANCE([self mln_currentLuaCore]).viewController;
    [kitViewController updateDataForKeyPath:keyPath value:value];
}

+ (id __nullable)lua_dataForKeyPath:(NSString *)keyPath {
    MLNKitViewController *kitViewController = (MLNKitViewController *)MLN_KIT_INSTANCE([self mln_currentLuaCore]).viewController;
    return [kitViewController dataForKeyPath:keyPath];
}

+ (id __nullable)lua_mockForKey:(NSString *)key data:(NSDictionary *)dic {
    MLNKitViewController *kitViewController = (MLNKitViewController *)MLN_KIT_INSTANCE([self mln_currentLuaCore]).viewController;
//    if ([dic isKindOfClass:[NSArray class]]) {
//        return [self lua_mockArrayForKey:key data:(NSArray *)dic callbackDic:nil];
//    }
    if (![dic isKindOfClass:[NSDictionary class]]) {
        NSLog(@"error %s, should be NSDictionary",__func__);
        return nil;
    }
    NSMutableDictionary *map = dic.mln_mutalbeCopy;
    [kitViewController.dataBinding bindData:map forKey:key];
    return map;
}

+ (id __nullable)lua_mockArrayForKey:(NSString *)key data:(NSArray *)data callbackDic:(NSDictionary *)callbackDic {
    MLNKitViewController *kitViewController = (MLNKitViewController *)MLN_KIT_INSTANCE([self mln_currentLuaCore]).viewController;
    
    NSMutableArray *arr = [[kitViewController dataForKeyPath:key] mutableCopy];
    [kitViewController updateDataForKeyPath:key value:arr];
    
    MLNBlock *reuseIdBlock = [callbackDic objectForKey:@"reuseId"];
    MLNBlock *height = [callbackDic objectForKey:@"height"];
    MLNBlock *size = [callbackDic objectForKey:@"size"];
    arr.mln_resueIdBlock = ^NSString * _Nonnull(NSArray * _Nonnull items, NSUInteger section, NSUInteger row) {
        if (reuseIdBlock) {
            NSDictionary *item;
            @try {
                item = (items.mln_is2D) ? items[section][row] : items[row];
                [reuseIdBlock addMapArgument:item];
                [reuseIdBlock addUIntegerArgument:section + 1];
                [reuseIdBlock addUIntegerArgument:row + 1];
                NSString *cellId = [reuseIdBlock callIfCan];
                return cellId;
            } @catch (NSException *exception) {
                NSLog(@"error %s exception %@",__func__, exception);
            }
        }
        return nil;
    };
    arr.mln_heightBlock = ^NSUInteger(NSArray * _Nonnull items, NSUInteger section, NSUInteger row) {
        if (height) {
            NSDictionary *item;
            @try {
                item = (items.mln_is2D) ? items[section][row] : items[row];
                [height addMapArgument:item];
                [height addUIntegerArgument:section + 1];
                [height addUIntegerArgument:row + 1];
                NSUInteger h = [[height callIfCan] unsignedIntegerValue];
                return h;
            } @catch (NSException *exception) {
                NSLog(@"error %s exception %@",__func__, exception);
            }
        }
        return 0;
    };
    arr.mln_sizeBlock = ^CGSize(NSArray * _Nonnull items, NSUInteger section, NSUInteger row) {
        if (size) {
            NSDictionary *item;
            @try {
                item = (items.mln_is2D) ? items[section][row] : items[row];
                [size addMapArgument:item];
                [size addUIntegerArgument:section + 1];
                [size addUIntegerArgument:row + 1];
                CGSize s = [[size callIfCan] CGSizeValue];
                return s;
            } @catch (NSException *exception) {
                NSLog(@"error %s exception %@",__func__, exception);
            }
        }
        return CGSizeZero;
    };
    [arr mln_startKVOIfMutableble];
    return arr;
}

#pragma mark - ListView
//+ (void)lua_bindListViewForKey:(NSString *)key listView:(UIView *)listView {
//    MLNKitViewController *kitViewController = (MLNKitViewController *)MLN_KIT_INSTANCE([self mln_currentLuaCore]).viewController;
//    MLNListViewObserver *observer = [MLNListViewObserver observerWithListView:listView keyPath:key];
//    [kitViewController.dataBinding addArrayObserver:observer forKey:key];
//}

// userData.source
+ (void)lua_bindListViewForKey:(NSString *)key listView:(UIView *)listView {
    MLNKitViewController *kitViewController = (MLNKitViewController *)MLN_KIT_INSTANCE([self mln_currentLuaCore]).viewController;
    MLNListViewObserver *observer = [MLNListViewObserver observerWithListView:listView keyPath:key];
    
    [kitViewController.dataBinding addArrayObserver:observer forKey:key];
}

+ (NSUInteger)lua_sectionCountForKey:(NSString *)key {
    NSArray *arr = [self lua_dataForKeyPath:key];
    if (arr.mln_is2D) {
        return arr.count;
    }
    return 1;
}

+ (NSUInteger)lua_rowCountForKey:(NSString *)key section:(NSUInteger)section{
    NSArray *arr = [self lua_dataForKeyPath:key];
    if (section > arr.count || section == 0) {
        return 0;
    }
    
    if (arr.mln_is2D) {
        return [[arr mln_objectAtIndex:section - 1] count];
    }

    return arr.count;
}

+ (id)lua_modelForKey:(NSString *)key section:(NSUInteger)section row:(NSUInteger)row path:(NSString *)path {
    NSArray *array = [self lua_dataForKeyPath:key];
    id resust;
    @try {
        if (array.mln_is2D) {
            resust = [[[array mln_objectAtIndex:section - 1] mln_objectAtIndex:row - 1] valueForKeyPath:path];
        } else {
            resust = [[array mln_objectAtIndex:row - 1] valueForKeyPath:path];
        }
    } @catch (NSException *exception) {
        NSLog(@"%s exception: %@",__func__, exception);
    }
    return resust;
}

+ (void)lua_updateModelForKey:(NSString *)key section:(NSUInteger)section row:(NSUInteger)row path:(NSString *)path value:(id)value {
    NSArray *array = [self lua_dataForKeyPath:key];
    @try {
        NSObject *object;
        if (array.mln_is2D) {
            object = [[array mln_objectAtIndex:section - 1] mln_objectAtIndex:row - 1];
        } else {
            object = [array mln_objectAtIndex:row - 1];
        }
        
        id oldValue = [object valueForKeyPath:path];
        [object setValue:value forKeyPath:path];
        
        NSArray *blocks = array.mln_itemKVOBlocks.copy;
        for (MLNItemKVOBlock block in blocks) {
            block(object, path, oldValue, value);
        }
        
    } @catch (NSException *exception) {
        NSLog(@"%s exception: %@",__func__, exception);
    }
}

+ (NSString *)lua_reuseIdForKey:(NSString *)key section:(NSUInteger)section row:(NSUInteger)row {
    NSArray *array = [self lua_dataForKeyPath:key];
    if (array.mln_resueIdBlock) {
        return array.mln_resueIdBlock(array, section - 1, row - 1);
    }
    
    NSString *firstKey = [[key componentsSeparatedByString:@"."] firstObject];
    NSObject *obj = [self lua_dataForKeyPath:firstKey];
    if (obj.mln_resueIdBlock) {
        return obj.mln_resueIdBlock(array, section - 1, row - 1);
    }
    return @"Cell";
}

+ (NSUInteger)lua_heightForKey:(NSString *)key section:(NSUInteger)section row:(NSUInteger)row {
    NSArray *array = [self lua_dataForKeyPath:key];
    if (array.mln_heightBlock) {
        return array.mln_heightBlock(array, section - 1, row - 1);
    }
    
    NSString *firstKey = [[key componentsSeparatedByString:@"."] firstObject];
    NSObject *obj = [self lua_dataForKeyPath:firstKey];
    if (obj.mln_heightBlock) {
        return obj.mln_heightBlock(array, section - 1, row - 1);
    }
    NSAssert(array.mln_heightBlock || obj.mln_heightBlock, @"mln_heightBlock of binded array should not be nil");
    return 0;
}

+ (CGSize)lua_sizeForKey:(NSString *)key section:(NSUInteger)section row:(NSUInteger)row {
    NSArray *array = [self lua_dataForKeyPath:key];
    if (array.mln_sizeBlock) {
        return array.mln_sizeBlock(array, section - 1, row - 1);
    }
    
    NSString *firstKey = [[key componentsSeparatedByString:@"."] firstObject];
    NSObject *obj = [self lua_dataForKeyPath:firstKey];
    if (obj.mln_sizeBlock) {
        return obj.mln_sizeBlock(array, section - 1, row - 1);
    }
    NSAssert(array.mln_sizeBlock || obj.mln_sizeBlock, @"mln_sizeBlock of binded array should not be nil");
    return CGSizeZero;
}

+ (void)lua_bindCellForKey:(NSString *)key section:(NSUInteger)section row:(NSUInteger)row paths:(NSArray *)paths {
    MLNKitViewController *kitViewController = (MLNKitViewController *)MLN_KIT_INSTANCE([self mln_currentLuaCore]).viewController;

    NSArray *array = [self lua_dataForKeyPath:key];
    MLNListViewObserver *listObserver = (MLNListViewObserver *)[kitViewController.dataBinding observersForKeyPath:key].firstObject;
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
        [kitViewController.dataBinding.KVOController unobserve:model keyPath:k];
    }
    
    [kitViewController.dataBinding.KVOController observe:model keyPaths:paths options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
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
LUA_EXPORT_STATIC_METHOD(getReuseId, "lua_reuseIdForKey:section:row:", MLNDataBinding)
LUA_EXPORT_STATIC_METHOD(getHeight, "lua_heightForKey:section:row:", MLNDataBinding)
LUA_EXPORT_STATIC_METHOD(bindCell, "lua_bindCellForKey:section:row:paths:", MLNDataBinding)

LUA_EXPORT_STATIC_METHOD(getSize, "lua_sizeForKey:section:row:", MLNDataBinding)

LUA_EXPORT_STATIC_END(MLNDataBinding, DataBinding, NO, NULL)

@end
