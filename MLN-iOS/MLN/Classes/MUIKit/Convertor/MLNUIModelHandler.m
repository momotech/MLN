//
//  MLNUIModelHandler.m
//  ArgoUI
//
//  Created by MOMO on 2020/8/17.
//

#import "MLNUIModelHandler.h"
#import "NSObject+MLNUICore.h"
#import "MLNUILuaCore.h"

#define ARGOUI_BUILDMODEL_ERROR(desc, errmsg) printf("ArgoUI Error: %s (%s)\n.", desc ?: "", errmsg ?: "(null)");

@implementation MLNUIModelHandler

#pragma mark - Public

+ (NSObject *)buildModelWithDataObject:(id)dataObject model:(nonnull NSObject *)model extra:(id _Nullable)extra functionChunk:(nonnull const char *)functionChunk luaCore:(nonnull MLNUILuaCore *)luaCore {
    NSParameterAssert(dataObject && model && functionChunk && luaCore);
    if (!dataObject || !model || !luaCore || !functionChunk ) {
        return nil;
    }
    
    int argCount = 0;
    lua_State *L = luaCore.state;
    
    if ([luaCore pushLuaTable:dataObject error:nil]) {
        argCount++;
    }
    if (MLNUIConvertModelToLuaTable(model, luaCore)) {
        argCount++;
    }
    if (extra) {
        argCount++;
        switch ([extra mlnui_nativeType]) {
            case MLNUINativeTypeArray:
            case MLNUINativeTypeMArray:
            case MLNUINativeTypeDictionary:
            case MLNUINativeTypeMDictionary:
                [luaCore pushLuaTable:extra error:nil];
                break;
            case MLNUINativeTypeObject:
                MLNUIConvertModelToLuaTable(extra, luaCore);
                break;
            default:
                [luaCore pushNativeObject:extra error:nil];
                break;
        }
    }
    
    int res = luaL_loadstring(L, functionChunk);
    if (res != 0) { // error occur
        ARGOUI_BUILDMODEL_ERROR("load build model function error", luaL_checkstring(L, -1));
        return nil;
    }
    lua_pcall(L, 0, 1, 0); // return function
    
    NSError *error = nil;
    [luaCore call:argCount retCount:1 error:&error]; // return model
    if (error) {
        ARGOUI_BUILDMODEL_ERROR("call build model function error", error.localizedDescription.UTF8String);
        return nil;
    }
    id object = [luaCore toNativeObject:-1 error:nil];
    return MLNUIConvertDataObjectToModel(object, model);
}

#pragma mark - Private

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
        id value = [model valueForKey:@(name)];
        if (!value) continue;
        lua_pushstring(L, name);
        if ([value mlnui_nativeType] == MLNUINativeTypeObject) {
            MLNUIConvertModelToLuaTable(value, luaCore);
        } else {
            [luaCore pushNativeObject:value error:nil];
        }
        lua_settable(L, -3);
    }
    free(properties);
    return YES;
}

static inline NSObject *MLNUIConvertDataObjectToModel(__unsafe_unretained id dataObject, __unsafe_unretained NSObject *model) {
    if (!dataObject || !model) {
        return nil;
    }
    if ([dataObject isKindOfClass:[NSDictionary class]]) {
        [(NSDictionary *)dataObject enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
            @try {
                [model setValue:obj forKey:key];
            } @catch (NSException *exception) {
                ARGOUI_BUILDMODEL_ERROR("Convert NSDictionary to model", [exception description].UTF8String);
            } @finally { }
        }];
    }
    return model;
}

@end
