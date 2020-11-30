//
//  MLNUIModelHandler.m
//  ArgoUI
//
//  Created by MOMO on 2020/8/17.
//

#import "MLNUIModelHandler.h"
#import "MLNUILuaCore.h"
#import "MLNUIKitBridgesManager.h"
#import "MLNUIModelKeyPathComparator.h"
#import "ArgoBindingConvertor.h"
#import "ArgoObservableMap.h"
#import "ArgoObservableArray.h"
#import "MLNUITable.h"

#define ARGOUI_ERROR(errmsg) do {\
if (error) { *error = [NSError errorWithDomain:@"com.argoui.error" code:-1 userInfo:@{NSLocalizedDescriptionKey:errmsg}]; }\
} while(0);

#if DEBUG
#define ARGOUI_ERROR_LOG(errmsg) printf("ArgoUI Error: %s\n.", errmsg.UTF8String ?: "(null)");
#else
#define ARGOUI_ERROR_LOG(errmsg)
#endif

typedef NS_ENUM(NSInteger, MLNUIAutoWireType) {
    MLNUIAutoWireTypeNone = 0,
    MLNUIAutoWireTypeUpdate = 1,
    MLNUIAutoWireTypeInsert = 2,
    MLNUIAutoWireTypeRemove = 3,
    MLNUIAutoWireTypeSort   = 4
};

typedef void(^MLNLUIModelHandleTask)(void);

@interface MLNUIModelHandler ()

@end

@implementation MLNUIModelHandler

#pragma mark - Public

+ (NSObject *)buildModelWithDataObject:(id)dataObject model:(nonnull NSObject <MLNUIModelHandlerProtocol>*)model extra:(id _Nullable)extra functionChunk:(nonnull const char *)functionChunk error:(NSError *__autoreleasing*)error {
    NSParameterAssert(dataObject && model && functionChunk);
    if (!dataObject || !model || !functionChunk) {
        return nil;
    }
    id object = [self handleModelWithDataObject:dataObject model:model extra:extra functionChunk:functionChunk error:error];
    return MLNUIConvertDataObjectToModel(object, model);
}

+ (void)buildModelWithDataObject:(id)dataObject model:(NSObject <MLNUIModelHandlerProtocol>*)model extra:(id)extra functionChunk:(const char *)functionChunk complete:(MLNUIModelHandleComplete)complete {
    NSParameterAssert(dataObject && model && functionChunk);
    if (!dataObject || !model || !functionChunk) {
        return;
    }
    MLNLUIModelHandleTask task = ^() {
        NSError *error = nil;
        id object = [self handleModelWithDataObject:dataObject model:model extra:extra functionChunk:functionChunk error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSObject *resultModel = MLNUIConvertDataObjectToModel(object, model);
            if (complete) complete(resultModel, error);
        });
    };
    [self performSelector:@selector(executeTask:) onThread:[self modelConvertThread] withObject:task waitUntilDone:NO];
}

+ (NSObject *)convertViewModel:(NSObject<MLNUIModelHandlerProtocol> *)model fromDictionary:(NSDictionary *)dic {
    NSParameterAssert(model && dic);
    if (!model || !dic) return model;
    return MLNUIConvertDataObjectToModel(dic, model);
}

#pragma mark - Private

+ (id)handleModelWithDataObject:(id)dataObject model:(nonnull NSObject <MLNUIModelHandlerProtocol>*)model extra:(id _Nullable)extra functionChunk:(nonnull const char *)functionChunk error:(NSError *__autoreleasing*)error {
    NSParameterAssert(dataObject && model && functionChunk);
    if (!dataObject || !model || !functionChunk) {
        return nil;
    }
    
    MLNUILuaCore *luaCore = MLNUILuaCoreGet();
    lua_State *L = luaCore.state;
    int argCount = 0;
    if ([luaCore pushLuaTable:dataObject error:nil]) {
        argCount++;
    }
#if OCPERF_USE_NEW_DB
//    if ([luaCore.convertor pushArgoBindingNativeObject:model error:error]) {
//        argCount++;
//    }
    if (MLNUIConvertModelToLuaTable(model, luaCore)) {
        argCount++;
    }
#else
    if (MLNUIConvertModelToLuaTable(model, luaCore)) {
        argCount++;
    }
#endif
    if (extra) {
        argCount++;
        MLNUIPushObject(extra, luaCore);
    }
    #if DEBUG
            functionChunk = [MLNUIModelKeyPathComparator luaTableKeyTrackCodeAppendFunction:functionChunk model:model];
    #endif
    
#if !OCPERF_PRE_REQUIRE // 不开启预加载时，预先导入map()/array()函数
    const char *require =
    "function map() return setmetatable({}, {collectionType=1}) end\n"
    "function array() return setmetatable({}, {collectionType=2}) end\n";
    char *connectStr = malloc(strlen(require)+strlen(functionChunk)+1);
    strcpy(connectStr, require);
    strcat(connectStr, functionChunk);
    functionChunk = connectStr;
#endif
    
    int res = luaL_loadstring(L, functionChunk);
    
#if !OCPERF_PRE_REQUIRE
    free(connectStr);
#endif
    if (res != 0) { // error occur
        NSString *errmsg = [NSString stringWithFormat:@"The `functionChunk` parameter is invalid. (%s)", luaL_checkstring(L, -1)];
        ARGOUI_ERROR(errmsg);
        ARGOUI_ERROR_LOG(errmsg);
        return nil;
    }
    lua_pcall(L, 0, 1, 0); // return function
    if (lua_type(L, -1) != LUA_TFUNCTION) {
        NSString *errmsg = [NSString stringWithFormat:@"The element of top stack isn't function after loadstring. (%s)", lua_typename(L, lua_type(L, -1))];
        ARGOUI_ERROR(errmsg);
        ARGOUI_ERROR_LOG(errmsg);
        return nil;
    }
    
    [luaCore call:argCount retCount:1 error:error]; // return model
    if (error && *error) {
        NSString *errmsg = [NSString stringWithFormat:@"The functionChunk called error. (%s)", [*error localizedDescription].UTF8String];
        ARGOUI_ERROR_LOG(errmsg);
        return nil;
    }
    #if DEBUG
            [MLNUIModelKeyPathComparator keyPathCompare:luaCore model:model];
    #endif
#if OCPERF_USE_NEW_DB
    return [luaCore.convertor toArgoBindingNativeObject:-1 error:NULL];
#else
    return [luaCore toNativeObject:-1 error:error];
#endif
}

+ (NSThread *)modelConvertThread {
    static NSThread *thread = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        thread = [[NSThread alloc] initWithTarget:self selector:@selector(modelConvertThreadKeepAlive:) object:nil];
        [thread start];
    });
    return thread;
}

+ (void)modelConvertThreadKeepAlive:(id)object {
    @autoreleasepool {
        [[NSThread currentThread] setName:@"MLNUIModelConverter"];
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSRunLoopCommonModes];
        [runLoop run];
    }
}

+ (void)executeTask:(MLNLUIModelHandleTask)task {
    if (task) task();
}

static inline MLNUILuaCore *MLNUILuaCoreGet(void) {
    static MLNUILuaCore *luaCore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        luaCore = [[MLNUILuaCore alloc] initWithLuaBundle:nil convertor:[ArgoBindingConvertor class] exporter:nil];
        MLNUIKitBridgesManager *manager = [[MLNUIKitBridgesManager alloc] init];
        [manager registerKitForLuaCore:luaCore];
    });
    return luaCore;
}

// <NSObject> 协议中声明的属性要过滤掉
static inline NSDictionary *MLNUIModelPropertyBlackList(void) {
    static NSDictionary *dic = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dic = @{@"superclass":@(true),
                @"description":@(true),
                @"debugDescription":@(true),
                @"hash":@(true)};
    });
    return dic;
}

static inline void MLNUIPushObject(__unsafe_unretained id object, __unsafe_unretained MLNUILuaCore *luaCore) {
    switch ([object mlnui_nativeType]) {
        case MLNUINativeTypeDictionary:
        case MLNUINativeTypeMDictionary:
        case MLNUINativeTypeArray:
        case MLNUINativeTypeMArray:
            [luaCore pushLuaTable:object error:nil];
            break;
        case MLNUINativeTypeObject:
            MLNUIConvertModelToLuaTable(object, luaCore);
            break;
        default:
            [luaCore pushNativeObject:object error:nil];
            break;
    }
}

static inline BOOL MLNUIConvertModelToLuaTable(__unsafe_unretained NSObject *model, MLNUILuaCore *luaCore) {
    if (!model || !luaCore) {
        return false;
    }
    lua_State *L = luaCore.state;
    lua_newtable(L);
    
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([model class], &count);
    for (int i = 0; i < count; i++) {
        const char *name = property_getName(properties[i]);
        if (MLNUIModelPropertyBlackList()[@(name)]) {
            continue;
        }
        id value = nil;
        @try {
            value = [model valueForKey:@(name)];
        } @catch (NSException *exception) {
#if DEBUG
            NSLog(@"ArgoUI Model Exception: %@", exception);
#endif
        } @finally { }
        if (!value) continue;
        lua_pushstring(L, name);
        MLNUIPushObject(value, luaCore);
        lua_settable(L, -3);
    }
    free(properties);
    return YES;
}

static inline void MLNUIExchangeArrayObjectAtIndex(NSMutableArray *array, id object, NSUInteger index) {
    NSCParameterAssert(index < array.count);
    if (index < array.count) {
        if (object) {
            [array replaceObjectAtIndex:index withObject:object];
        } else {
            [array removeObjectAtIndex:index];
        }
    }
}

static inline void MLNUISetKeyValueForModel(NSObject *model, id key, id value) {
    @try {
#if OCPERF_USE_NEW_DB
        [model setValue:value forKey:key];
#else
        if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
            [model setValue:[value mutableCopy] forKey:key];
        } else {
            [model setValue:value forKey:key];
        }
#endif
    } @catch (NSException *exception) {
        ARGOUI_ERROR_LOG([exception description]);
    } @finally { }
}

static inline void MLNUIUpdateDictionaryForModel(NSDictionary *dic, NSObject *model) {
    if (!dic || !model) return;
    if ([model isKindOfClass:[NSDictionary class]]) {
        NSCParameterAssert([model isKindOfClass:[NSMutableDictionary class]]);
        if ([model isKindOfClass:[NSMutableDictionary class]] == NO) {
            return;
        }
    }
    MLNUITable *metaTable = [dic mlnui_metaTable];
    NSArray<NSDictionary *> *updateArray = [metaTable objectForKey:@"__update"];
    [updateArray enumerateObjectsUsingBlock:^(NSDictionary *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        MLNUIAutoWireType opType = [obj[@"op"] integerValue];
        id key = obj[@"key"];
        id value = obj[@"value"];
        if (opType == MLNUIAutoWireTypeUpdate) {
            MLNUISetKeyValueForModel(model, key, value);
        }
    }];
    
    [dic enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            MLNUIUpdateDictionaryForModel(obj, [model valueForKey:key]);
        } else if ([obj isKindOfClass:[NSArray class]]) {
            MLNUIUpdateArrayElementForModel(obj, [model valueForKey:key]);
        } else {
            // do nothing.
        }
    }];
}

static inline void MLNUIUpdateArrayElementForModel(NSArray *array, NSMutableArray *modelArray) {
    if (!array || !modelArray) return;
    NSCParameterAssert([modelArray isKindOfClass:[NSMutableArray class]]);
    if ([modelArray isKindOfClass:[NSMutableArray class]] == NO) {
        return;
    }
    MLNUITable *metaTable = array.mlnui_metaTable;
    NSArray<NSDictionary *> *updateArray = [metaTable objectForKey:@"__update"];
    for (NSDictionary *dic in updateArray) {
        MLNUIAutoWireType opType = [dic[@"op"] integerValue];
        if (opType == MLNUIAutoWireTypeSort) {
            [modelArray replaceObjectsInRange:NSMakeRange(0, modelArray.count) withObjectsFromArray:array];
            continue; // sort类型无需关心key-value
        }
        id key = dic[@"key"];
        id value = dic[@"value"];
        if (![key isKindOfClass:[NSNumber class]]) {
            NSCAssert(false, @"The key should be kind of NSNumber class.");
            continue;
        }
        NSUInteger index = [key unsignedIntegerValue] - 1; // lua索引从1开始
        switch (opType) {
            case MLNUIAutoWireTypeUpdate: {
                MLNUIExchangeArrayObjectAtIndex(modelArray, value, index);
                break;
            }
            case MLNUIAutoWireTypeInsert: {
                NSCAssert(index <= modelArray.count, @"The index of array is invalid when MLNUIAutoWireTypeInsert");
                if (index <= modelArray.count) {
                    if (value) {
                        [modelArray insertObject:value atIndex:index];
                    } else {
                        [modelArray removeObjectAtIndex:index];
                    }
                }
                break;
            }
            case MLNUIAutoWireTypeRemove: {
                NSCAssert(index < modelArray.count, @"The index of array is invalid when MLNUIAutoWireTypeRemove");
                if (index < modelArray.count) {
                    [modelArray removeObjectAtIndex:index];
                }
                break;
            }
            default:
                break;
        }
    }
    
    [array enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            MLNUIUpdateDictionaryForModel(obj, obj);
        } else if ([obj isKindOfClass:[NSArray class]]) {
            MLNUIUpdateArrayElementForModel(obj, obj);
        } else {
            // do nothing
        }
    }];
}

static inline NSObject *MLNUIConvertDataObjectToModel(__unsafe_unretained id dataObject, __unsafe_unretained NSObject *model) {
    if (!dataObject || !model) {
        return nil;
    }
    NSCAssert([NSThread isMainThread], @"This method will trigger data_binding and will update UI.");
    if ([dataObject isKindOfClass:[NSDictionary class]]) {
        MLNUIUpdateDictionaryForModel(dataObject, model);
    }
    return model;
}

@end
