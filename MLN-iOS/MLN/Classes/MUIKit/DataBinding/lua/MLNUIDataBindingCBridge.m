//
//  MLNUIDataBindingCBridge.m
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/7/7.
//

#import "MLNUIDataBindingCBridge.h"
#import "MLNUIKit.h"
#import "MLNUIBlockObserver.h"
#import "MLNUIListViewObserver.h"
#import "NSObject+MLNUIKVO.h"
#import "NSArray+MLNUIKVO.h"
#import "NSDictionary+MLNUIKVO.h"
//#import "NSArray+MLNUISafety.h"
#import "MLNUITableView.h"
#import "NSObject+MLNUIReflect.h"
#import "MLNUIExtScope.h"

@implementation MLNUIDataBindingCBridge

NS_INLINE id _mlnui_data_for_keypath(MLNUILuaCore *luaCore,NSString *keyPath) {
    if(!keyPath) return nil;
    UIViewController<MLNUIDataBindingProtocol> *kitViewController = (UIViewController<MLNUIDataBindingProtocol> *)MLNUI_KIT_INSTANCE(luaCore).viewController;
    NSObject *obj = [kitViewController.mlnui_dataBinding dataForKeyPath:keyPath];
    return obj;
}

NS_INLINE MLNUIDataBinding * _mlnui_get_dataBinding(MLNUILuaCore *luaCore) {
    UIViewController<MLNUIDataBindingProtocol> *kitViewController = (UIViewController<MLNUIDataBindingProtocol> *)MLNUI_KIT_INSTANCE(luaCore).viewController;
    return kitViewController.mlnui_dataBinding;
}

NS_INLINE void _mlnui_on_error_log(MLNUILuaCore *luaCore,NSString *log) {
#if DEBUG
    NSLog(@"%@",log);
    MLNUIError(luaCore, @"%@",log);
#endif
}

#pragma mark - Bridge

static int luaui_watch(lua_State *L) {
    mlnui_luaui_check_begin();
    mlnui_luaui_checkstring_rt(L, -2);
    mlnui_luaui_checkfunc_rt(L, -1);
    mlnui_luaui_check_end();
    PCallDB(__func__);
    TICK();
    
    MLNUILuaCore *luaCore = MLNUI_LUA_CORE(L);
    MLNUIDataBinding *dataBind = _mlnui_get_dataBinding(luaCore);
    NSString *nKey = [luaCore toString:-2 error:NULL];
    MLNUIBlock *handler = [luaCore toNativeObject:-1 error:NULL];
    
    NSObject<MLNUIKVOObserverProtol> *observer = [MLNUIBlockObserver observerWithBlock:handler keyPath:nKey];
    NSString *obID = [dataBind addMLNUIObserver:observer forKeyPath:nKey];
    
    lua_pushstring(L, obID.UTF8String);
    
    TOCK("luaui_watch key %s",nKey.UTF8String);
    return 1;
}

static int luaui_update (lua_State *L) {
    mlnui_luaui_check_begin();
    mlnui_luaui_checkstring_rt(L, -2);
//    mlnui_luaui_checkudata_rt(L, -1);
    mlnui_luaui_check_end();
    PCallDB(__func__);
    TICK();
    MLNUILuaCore *luaCore = MLNUI_LUA_CORE(L);
    MLNUIDataBinding *dataBind = _mlnui_get_dataBinding(luaCore);
    NSString *nKey = [luaCore toString:-2 error:NULL];
    id value = [luaCore toNativeObject:-1 error:NULL];
    value = [value mlnui_convertToNativeObject];
    
    [dataBind updateDataForKeyPath:nKey value:value];
    TOCK("luaui_update key %s",nKey.UTF8String);
    return 1;
}

static int luaui_get (lua_State *L) {
    mlnui_luaui_check_begin();
    mlnui_luaui_checkstring_rt(L, -1);
    mlnui_luaui_check_end();
    PCallDB(__func__);
    TICK();
    
    MLNUILuaCore *luaCore = MLNUI_LUA_CORE(L);
    NSString *nKey = [luaCore toString:-1 error:NULL];
    
    NSObject *obj = _mlnui_data_for_keypath(luaCore, nKey);
    NSObject *convertedObj = [obj mlnui_convertToLuaObject];
    int nret = [luaCore pushNativeObject:convertedObj error:NULL];
    TOCK("luaui_get key %s",nKey.UTF8String);
    return nret;
}

static int luaui_removeObserver (lua_State *L) {
    mlnui_luaui_check_begin();
    mlnui_luaui_checkstring_rt(L, -1);
    mlnui_luaui_check_end();
    PCallDB(__func__);
    TICK();
    
    MLNUILuaCore *luaCore = MLNUI_LUA_CORE(L);
    MLNUIDataBinding *dataBind = _mlnui_get_dataBinding(luaCore);
    NSString *nKey = [luaCore toString:-1 error:NULL];
    
    [dataBind removeMLNUIObserverByID:nKey];
    TOCK("luaui_removeObserver key %s",nKey.UTF8String);
    return 1;
}

static int luaui_mock (lua_State *L) {
    mlnui_luaui_check_begin();
    mlnui_luaui_checkstring_rt(L, -2);
    mlnui_luaui_checktable(L, -1);
    mlnui_luaui_check_end();
    PCallDB(__func__);
    TICK();
    
    MLNUILuaCore *luaCore = MLNUI_LUA_CORE(L);
    MLNUIDataBinding *dataBind = _mlnui_get_dataBinding(luaCore);
    NSString *nKey = [luaCore toString:-2 error:NULL];
    NSDictionary *dic = [luaCore toNativeObject:-1 error:NULL];
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"PerformanceDemoMUI" ofType:@"bundle"];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    path = [path stringByAppendingPathComponent:nKey];
    
    [NSKeyedArchiver archiveRootObject:dic toFile:path];
    NSError *error;
    BOOL r = [NSKeyedArchiver archivedDataWithRootObject:dic requiringSecureCoding:YES error:&error];
    if (!r) {
        NSLog(@"%@",error);
    }
    if (![dic isKindOfClass:[NSDictionary class]]) {
        NSString *log = [NSString stringWithFormat:@"data %@ should be kindOf NSDictionary",dic.class];
        _mlnui_on_error_log(luaCore, log);
        return 1;
    }
    NSMutableDictionary *map = [dic mlnui_convertToNativeObject];
    [dataBind bindData:map forKey:nKey];
    TOCK("luaui_mock key %s",nKey.UTF8String);
    return 1;
}

static int luaui_mock_array (lua_State *L) {
    mlnui_luaui_check_begin();
    mlnui_luaui_checkstring_rt(L, -3);
    mlnui_luaui_checktable_rt(L, -2);
    mlnui_luaui_check_end();
    PCallDB(__func__);
    TICK();
    
    MLNUILuaCore *luaCore = MLNUI_LUA_CORE(L);
    MLNUIDataBinding *dataBind = _mlnui_get_dataBinding(luaCore);
    NSString *nKey = [luaCore toString:-3 error:NULL];
    
    NSMutableArray *existData = [dataBind dataForKeyPath:nKey];
    if ([existData isKindOfClass:[NSMutableArray class]]) {
        [existData mlnui_startKVOIfMutable];
        return 1;
    }
    
    NSArray *data = [luaCore toNativeObject:-2 error:NULL];
    if (![data isKindOfClass:[NSArray class]]) {
        NSString *log = [NSString stringWithFormat:@"data %@ should be kindOf NSArray",data.class];
        _mlnui_on_error_log(luaCore, log);
        return 1;
    }
    NSMutableArray *array = [data mlnui_convertToNativeObject];
    [array mlnui_startKVOIfMutable];
    [dataBind bindArray:array forKey:nKey];
    TOCK("luaui_mockArray key %s",nKey.UTF8String);
    return 1;
}

static int luaui_insert (lua_State *L) {
    mlnui_luaui_check_begin();
    mlnui_luaui_checkstring_rt(L, -3);
    mlnui_luaui_checknumber_rt(L, -2);
//    mlnui_luaui_checkudata_rt(L, -1);
    mlnui_luaui_check_end();
    PCallDB(__func__);
    TICK();
    
    MLNUILuaCore *luaCore = MLNUI_LUA_CORE(L);
    
    id value = [luaCore toNativeObject:-1 error:NULL];
    int index = lua_tonumber(L, -2);
    NSString *nKey = [luaCore toString:-3 error:NULL];

    NSMutableArray *arr = _mlnui_data_for_keypath(luaCore, nKey);
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
                _mlnui_on_error_log(luaCore, log);
            }
        }
        if (!newValue) newValue = [value mlnui_convertToNativeObject];
        if(!newValue) return 1;
        
        if (index == -1) {
            [arr addObject:newValue];
            return 1;
        }
        index--;
        if (index >= 0 &&  index <= arr.count) {
            [arr insertObject:newValue atIndex:index];
            return 1;
        } else {
            NSString *log = [NSString stringWithFormat:@"index %d illeage, should match range of array [1, %zd]",index+1,arr.count];
            _mlnui_on_error_log(luaCore, log);
        }
    } else {
        NSString *log = [NSString stringWithFormat:@"type of object is %@, is not NSMutableArray",arr.class];
        _mlnui_on_error_log(luaCore, log);
    }
    TOCK("luaui_insert key %s",nKey.UTF8String);
    return 1;
}

static int luaui_remove (lua_State *L) {
    mlnui_luaui_check_begin();
    mlnui_luaui_checknumber_rt(L, -1);
    mlnui_luaui_checkstring_rt(L, -2);
    mlnui_luaui_check_end();
    PCallDB(__func__);
    TICK();
    
    MLNUILuaCore *luaCore = MLNUI_LUA_CORE(L);
//    MLNUIDataBinding *dataBind = _mlnui_get_dataBinding(luaCore);
    NSString *nKey = [luaCore toString:-2 error:NULL];
    int index = lua_tonumber(L, -1);
    
    NSMutableArray *arr = _mlnui_data_for_keypath(luaCore, nKey);
    if ([arr isKindOfClass:[NSMutableArray class]]) {
        if (index == -1) {
            [arr removeLastObject];
            return 1;
        }
        index--;
        if (index >= 0 && index < arr.count) {
            [arr removeObjectAtIndex:index];
        } else {
            NSString *log = [NSString stringWithFormat:@"index %d illeage, should match range of array [1, %zd]",index+1,arr.count];
            _mlnui_on_error_log(luaCore, log);
        }
    } else {
        NSString *log = [NSString stringWithFormat:@"type of object is %@, is not NSMutableArray",arr.class];
        _mlnui_on_error_log(luaCore, log);
    }
    
    TOCK("luaui_remove key %s",nKey.UTF8String);
    return 1;
}

static int luaui_array_size (lua_State *L) {
    mlnui_luaui_check_begin();
    mlnui_luaui_checkstring_rt(L, -1);
    mlnui_luaui_check_end();
    PCallDB(__func__);
    TICK();
    
    MLNUILuaCore *luaCore = MLNUI_LUA_CORE(L);
    MLNUIDataBinding *dataBind = _mlnui_get_dataBinding(luaCore);
    NSString *nKey = [luaCore toString:-1 error:NULL];
    
    NSArray *keys = [nKey componentsSeparatedByString:@"."];
    NSObject *front;
    NSArray *arr = [dataBind dataForKeys:keys frontValue:&front];
    
    if (![arr isKindOfClass: [NSArray  class]]) {
        if ([front isKindOfClass:[NSArray class]]) {
            arr = (NSArray *)front;
        } else {
            NSString *log = [NSString stringWithFormat:@"%@ is not NSArray",nKey];
            _mlnui_on_error_log(luaCore, log);
            return 1;
        }
    }
    
    lua_pushinteger(L, arr.count);
    TOCK("luaui_arraySize key %s",nKey.UTF8String);
    return 1;
}

static int luaui_bind_listview (lua_State *L) {
    mlnui_luaui_check_begin();
    mlnui_luaui_checkstring_rt(L, -2);
    mlnui_luaui_checkudata_rt(L, -1);
    mlnui_luaui_check_end();
    PCallDB(__func__);
    TICK();
    
    MLNUILuaCore *luaCore = MLNUI_LUA_CORE(L);
    MLNUIDataBinding *dataBind = _mlnui_get_dataBinding(luaCore);
    NSString *nKey = [luaCore toString:-2 error:NULL];
    UIView *listView = [luaCore toNativeObject:-1 error:NULL];
    
//    UIViewController<MLNUIDataBindingProtocol> *kitViewController = (UIViewController<MLNUIDataBindingProtocol> *)MLNUI_KIT_INSTANCE([self mlnui_currentLuaCore]).viewController;
//    MLNUIDataBinding *dataBinding = kitViewController.mlnui_dataBinding;
    
    __block NSString *obID;
//    __weak __typeof(MLNUIDataBinding*) weakBingding = dataBinding;
    MLNUIListViewObserver *observer = [MLNUIListViewObserver observerWithListView:listView keyPath:nKey callback:^(NSString * _Nonnull keyPath, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
//        __strong __typeof(MLNUIDataBinding*) strongBinding = weakBingding;
//        [strongBinding removeMLNUIObserverByID:obID];
//        [self luaui_bindListViewForKey:key listView:listView];
    }]; //这个是给array加一个默认监听，能够做自动刷新TableView
    
    [dataBind setListView:listView tag:nKey];
    obID = [dataBind addMLNUIObserver:observer forKeyPath:nKey];
    TOCK("luaui_bindListView key %s",nKey.UTF8String);
    return 1;
}

static int luaui_section_count (lua_State *L) {
    mlnui_luaui_check_begin();
    mlnui_luaui_checkstring_rt(L, -1);
    mlnui_luaui_check_end();
    PCallDB(__func__);
    TICK();
    
    MLNUILuaCore *luaCore = MLNUI_LUA_CORE(L);
    NSString *nKey = [luaCore toString:-1 error:NULL];
    
    NSArray *arr = _mlnui_data_for_keypath(luaCore, nKey);
    NSUInteger count = 1;
    if (arr.mlnui_is2D) {
        count = arr.count;
    }
    lua_pushinteger(L, count);
    TOCK("luaui_getSectionCount key %s",nKey.UTF8String);
    return 1;
}

static int luaui_row_count (lua_State *L) {
    mlnui_luaui_check_begin();
    mlnui_luaui_checkstring_rt(L, -2);
    mlnui_luaui_checknumber_rt(L, -1);
    mlnui_luaui_check_end();
    PCallDB(__func__);
    TICK();
    
    MLNUILuaCore *luaCore = MLNUI_LUA_CORE(L);
    NSString *nKey = [luaCore toString:-2 error:NULL];
    int section = lua_tonumber(L, -1);
    NSUInteger count = 0;
    
    NSArray *arr = _mlnui_data_for_keypath(luaCore, nKey);
    if (section > arr.count || section == 0) {
        count = 0;
    } else if(arr.mlnui_is2D){
        NSArray *subArr = [arr mlnui_objectAtIndex:section - 1];
        count = [subArr count];
    } else if (section == 1) {
        count = arr.count;
    }
    lua_pushinteger(L, count);
    TOCK("luaui_getRowCount key %s",nKey.UTF8String);
    return 1;
}

static int luaui_bind_cell (lua_State *L) {
    mlnui_luaui_check_begin();
    mlnui_luaui_checkstring_rt(L, -4);
    mlnui_luaui_checknumber_rt(L, -3);
    mlnui_luaui_checknumber_rt(L, -2);
    mlnui_luaui_checktable_rt(L, -1);
    mlnui_luaui_check_end();
    PCallDB(__func__);
    TICK();
    
    MLNUILuaCore *luaCore = MLNUI_LUA_CORE(L);
    MLNUIDataBinding *dataBind = _mlnui_get_dataBinding(luaCore);
    UIViewController<MLNUIDataBindingProtocol> *kitViewController = (UIViewController<MLNUIDataBindingProtocol> *)MLNUI_KIT_INSTANCE(luaCore).viewController;

    NSString *nKey = [luaCore toString:-4 error:NULL];
    NSUInteger section = lua_tonumber(L, -3);
    NSUInteger row = lua_tonumber(L, -2);
    NSArray *paths = [luaCore toNativeObject:-1 error:NULL];
    
    UIView *listView = [dataBind listViewForTag:nKey];
    if (!listView)  return 1;

    NSMutableDictionary *infos = [listView mlnui_bindInfos];
    NSString *modelKey = [nKey stringByAppendingFormat:@".%zd.%zd",section,row];
    NSObject *cellModel = [dataBind dataForKeyPath:modelKey];
    
    for (NSString *p in paths) {
        NSString *idKey = [nKey stringByAppendingFormat:@".%p.%@",cellModel,p];
        NSString *obID =  [infos objectForKey:idKey];
        if (obID) {
            [dataBind removeMLNUIObserverByID:obID];
        }
        
        NSString *nk = [modelKey stringByAppendingFormat:@".%@",p];
        MLNUIKVOObserver *ob = [[MLNUIKVOObserver alloc] initWithViewController:kitViewController callback:^(NSString * _Nonnull keyPath, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
            if ([listView isKindOfClass:[MLNUITableView class]]) {
                MLNUITableView *table = (MLNUITableView *)listView;
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row - 1 inSection:section - 1];
                [table.adapter tableView:table.adapter.targetTableView reloadRowsAtIndexPaths:@[indexPath]];
                [table.adapter.targetTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            } else {
                
            }
        } keyPath:nk];
        obID = [dataBind addMLNUIObserver:ob forKeyPath:nk];
        if (obID) {
            [infos setObject:obID forKey:idKey];
        }
    }
    
    TOCK("luaui_bindCell key %s section %zd row %zd",nKey.UTF8String, section, row);
    return 1;
}

static int test_nop(lua_State *L) {
    return 1;
}

LUAUI_NEW_EXPORT_GLOBAL_FUNC_BEGIN(MLNUIDataBindingCBridge)

LUAUI_NEW_EXPORT_GLOBAL_C_FUNC(watch, luaui_watch, MLNUIDataBindingCBridge)
LUAUI_NEW_EXPORT_GLOBAL_C_FUNC(update, luaui_update, MLNUIDataBindingCBridge)
LUAUI_NEW_EXPORT_GLOBAL_C_FUNC(get, luaui_get, MLNUIDataBindingCBridge)
LUAUI_NEW_EXPORT_GLOBAL_C_FUNC(removeObserver, luaui_removeObserver, MLNUIDataBindingCBridge)

LUAUI_NEW_EXPORT_GLOBAL_C_FUNC(mock, luaui_mock, MLNUIDataBindingCBridge)
LUAUI_NEW_EXPORT_GLOBAL_C_FUNC(mockArray, luaui_mock_array, MLNUIDataBindingCBridge)
LUAUI_NEW_EXPORT_GLOBAL_C_FUNC(insert, luaui_insert, MLNUIDataBindingCBridge)
LUAUI_NEW_EXPORT_GLOBAL_C_FUNC(remove, luaui_remove, MLNUIDataBindingCBridge)
LUAUI_NEW_EXPORT_GLOBAL_C_FUNC(arraySize, luaui_array_size, MLNUIDataBindingCBridge)

LUAUI_NEW_EXPORT_GLOBAL_C_FUNC(bindListView, luaui_bind_listview, MLNUIDataBindingCBridge)
LUAUI_NEW_EXPORT_GLOBAL_C_FUNC(getSectionCount, luaui_section_count, MLNUIDataBindingCBridge)
LUAUI_NEW_EXPORT_GLOBAL_C_FUNC(getRowCount, luaui_row_count, MLNUIDataBindingCBridge)
LUAUI_NEW_EXPORT_GLOBAL_C_FUNC(bindCell, luaui_bind_cell, MLNUIDataBindingCBridge)

#ifdef DEBUG
LUAUI_NEW_EXPORT_GLOBAL_C_FUNC(test_nop, test_nop, MLNUIDataBindingCBridge)
#endif

LUAUI_NEW_EXPORT_GLOBAL_FUNC_WITH_NAME_END(MLNUIDataBindingCBridge, DataBinding, NULL)

@end

