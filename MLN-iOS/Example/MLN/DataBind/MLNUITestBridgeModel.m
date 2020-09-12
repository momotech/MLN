//
//  MLNUITestBridgeModel.m
//  LuaNative
//
//  Created by Dongpeng Dai on 2020/8/21.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import "MLNUITestBridgeModel.h"
#import "MLNUIKit.h"

@implementation MLNUITestBridgeModel

- (void)luaui_doTask {
    NSLog(@"call doTask");
}

//LUAUI_EXPORT_BEGIN(MLNUITestBridgeModel)
//LUAUI_EXPORT_METHOD(doTask, "luaui_doTask", MLNUITestBridgeModel)
//LUAUI_EXPORT_END(MLNUITestBridgeModel, TestModel, NO, NULL, "initWithLuaCore:fileName:")

// typedef struct mlnui_objc_method {
//     const char *l_mn;  /* Object-C method name in lua*/
//     const char *mn; /* Object-C method name */
//     const char *clz; /* Object-C class name */
//     BOOL isProperty; /* It's YES if property method*/
//     const char *setter_n; /* Object-C getter method name*/
//     const char *getter_n; /* Object-C setter method name */
//     lua_CFunction func; /* C function in lua */
// } mlnui_objc_method;

static const struct mlnui_objc_method mlnui_Method_MLNUITestBridgeModel [] = {
    {
        ("doTask"), ("luaui_doTask"), ("MLNUITestBridgeModel"), (__objc_no), (((void*)0)), (((void*)0)), (mlnui_luaui_obj_method)
    },
    {
        ((void*)0), ((void*)0), ((void*)0), __objc_no, ((void*)0), ((void*)0), ((void*)0)
    }
};

//typedef struct mlnui_objc_class {
//    const char *pkg; /* packge name */
//    const char *clz; /* Object-C class name */
//    const char *l_clz; /* Object-C class name in lua */
//    const char *l_name; /* Object-C class name in lua */
//    const char *l_type; /* its type of Object-C class in lua  */
//    BOOL isRoot; /* is root function,it should be YES if no base class. */
//    const char *supreClz; /* base Object-C class */
//    BOOL hasConstructor; /* it should be NO if static class. */
//    MLNUI_Method_List methods; /* Object-C method */
//    MLNUI_Method_List clz_methods; /* Object-C class method */
//    struct mlnui_objc_method constructor; /* Object-C constructor method */
//} mlnui_objc_class;

static const struct mlnui_objc_class mlnui_Clazz_Info_MLNUITestBridgeModel = {
    "mlnui",
    "MLNUITestBridgeModel",
    "TestModel",
    "mlnui" "." "TestModel",
    "MLNUI_UserDataNativeObject",
    !(__objc_no),
    ((void*)0),
    __objc_yes,
    (struct mlnui_objc_method *)mlnui_Method_MLNUITestBridgeModel,
    ((void*)0),
    {
        ("constructor"), ("initWithLuaCore:fileName:"), ("MLNUITestBridgeModel"), (__objc_no), (((void*)0)), (((void*)0)), (mlnui_lua_constructor)
    }
};

+ (const mlnui_objc_class *)mlnui_clazzInfo{
    return &mlnui_Clazz_Info_MLNUITestBridgeModel;
}

+ (MLNUIExportType)mlnui_exportType {
    return (MLNUIExportTypeEntity);
}

static const void *kLuaUICore_MLNUITestBridgeModel = &kLuaUICore_MLNUITestBridgeModel;

- (void)setMlnui_luaCore:(MLNUILuaCore *)mlnui_myLuaCore{
    MLNUIWeakAssociatedObject *wp = objc_getAssociatedObject(self, kLuaUICore_MLNUITestBridgeModel);
    if (!wp) {
        wp = [MLNUIWeakAssociatedObject weakAssociatedObject:mlnui_myLuaCore];
        objc_setAssociatedObject(self, kLuaUICore_MLNUITestBridgeModel, wp, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    } else if (wp.associatedObject != mlnui_myLuaCore) {
        [wp updateAssociatedObject:mlnui_myLuaCore];
    }
}

- (MLNUILuaCore *)mlnui_luaCore{
    MLNUIWeakAssociatedObject *wp = objc_getAssociatedObject(self, kLuaUICore_MLNUITestBridgeModel);
    return wp.associatedObject;}

static const void *kLuaUIRetainCountMLNUITestBridgeModel = &kLuaUIRetainCountMLNUITestBridgeModel;
- (int)mlnui_luaRetainCount{
    return [objc_getAssociatedObject(self, kLuaUIRetainCountMLNUITestBridgeModel) intValue];
}

- (void)mlnui_luaRetain:(MLNUIUserData *)userData{
    userData->object = CFBridgingRetain(self);
    int count = [self mlnui_luaRetainCount];
    objc_setAssociatedObject(self, kLuaUIRetainCountMLNUITestBridgeModel, @(count + 1), OBJC_ASSOCIATION_ASSIGN);
}

- (void)mlnui_luaRelease{
    CFBridgingRelease((__bridge CFTypeRef _Nullable)self);
    int count = [self mlnui_luaRetainCount];
    objc_setAssociatedObject(self, kLuaUIRetainCountMLNUITestBridgeModel, @(count - 1), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)mlnui_isConvertible{
    return __objc_yes;
}

@end
