//
//  MLNEntityExporterMacro.h
//  MLNCore
//
//  Created by MoMo on 2019/8/1.
//

#ifndef MLNEntityExporterMacro_h
#define MLNEntityExporterMacro_h

#import "MLNExporterMacro.h"
#import "NSObject+MLNCore.h"
#import "MLNWeakAssociatedObject.h"
#import <objc/runtime.h>

/**
 标记开始实体UserData类导出
 
 @param CLZ 原生类名
 */
#define LUA_EXPORT_BEGIN(CLZ)  LUA_EXPORT_MAKE_METHOD_LIST(mln_Method_, CLZ)

/**
 导出实例方法映射
 
 @param LUA_FUNC Lua中调用的方法名
 @param SEL_NAME 原生中的对象方法
 @param CLZ 类名称
 */
#define LUA_EXPORT_METHOD(LUA_FUNC, SEL_NAME, CLZ) \
LUA_EXPORT_METHOD_LIST_ADD(#LUA_FUNC, SEL_NAME, #CLZ, NO, NULL, NULL, mln_lua_obj_method)

/**
 导出C函数映射
 
 @param LUA_FUNC Lua中调用的方法名
 @param CFUNC C函数
 @param CLZ 类名称
 */
#define LUA_EXPORT_METHOD_WITH_CFUNC(LUA_FUNC, CFUNC, CLZ) \
LUA_EXPORT_METHOD_LIST_ADD(#LUA_FUNC, "CFUNC", #CLZ, NO, NULL, NULL, CFUNC)

/**
 导出属性映射
 
 @param LUA_FUNC Lua中调用的方法名
 @param SETTER_NAME 原生中的setter方法
 @param GETTER_NAME 原生中的getter方法
 @param CLZ 类名称
 */
#define LUA_EXPORT_PROPERTY(LUA_FUNC, SETTER_NAME, GETTER_NAME, CLZ) \
LUA_EXPORT_METHOD_LIST_ADD(#LUA_FUNC, NULL, #CLZ, YES, SETTER_NAME, GETTER_NAME, mln_lua_obj_method)

/**
 导出属性与C函数的映射
 
 @param LUA_FUNC lua中的名称 （例： test）
 @param CFUNC c函数
 @param CLZ 类名称 (例：NSObject)
 */
#define LUA_EXPORT_PROPERTY_WITH_CFUNC(LUA_FUNC, CFUNC, CLZ) \
LUA_EXPORT_METHOD_LIST_ADD(#LUA_FUNC, NULL, #CLZ, YES, "CFUNC_SETTER", "CFUNC_GETTER", CFUNC)


/**
 处理Lua引用计数问题
 */
#define LUA_EXPORT_LUA_RETAIN_COUNT(CLZ) \
static const void *kLuaRetainCount ## CLZ = &kLuaRetainCount ## CLZ;\
- (int)mln_luaRetainCount\
{\
    return [objc_getAssociatedObject(self, kLuaRetainCount ## CLZ) intValue];\
}\
\
- (void)mln_luaRetain:(MLNUserData *)userData\
{\
    userData->object = CFBridgingRetain(self);\
    int count = [self mln_luaRetainCount];\
    objc_setAssociatedObject(self, kLuaRetainCount ## CLZ, @(count + 1), OBJC_ASSOCIATION_ASSIGN);\
}\
\
- (void)mln_luaRelease\
{\
    CFBridgingRelease((__bridge CFTypeRef _Nullable)self);\
    int count = [self mln_luaRetainCount];\
    NSAssert(count > 0, @"lua 过度释放UserData");\
    objc_setAssociatedObject(self, kLuaRetainCount ## CLZ, @(count - 1), OBJC_ASSOCIATION_ASSIGN);\
}\
\
- (BOOL)mln_isConvertible\
{\
    return YES;\
}

/**
 为被导出类添加对应LuaCore属性

 @param CLZ 被导出类
 */
#define LUA_EXPORT_LUA_CORE(CLZ) \
static const void *kLuaCore_ ## CLZ = &kLuaCore_ ## CLZ;\
- (void)setMln_luaCore:(MLNLuaCore *)mln_myLuaCore\
{\
    MLNWeakAssociatedObject *wp = objc_getAssociatedObject(self, kLuaCore_ ## CLZ);\
    if (!wp) {\
        wp = [MLNWeakAssociatedObject weakAssociatedObject:mln_myLuaCore];\
        objc_setAssociatedObject(self, kLuaCore_ ## CLZ, wp, OBJC_ASSOCIATION_RETAIN_NONATOMIC);\
    } else if (wp.associatedObject != mln_myLuaCore) {\
        [wp updateAssociatedObject:mln_myLuaCore];\
    }\
}\
\
- (MLNLuaCore *)mln_luaCore\
{\
    MLNWeakAssociatedObject *wp = objc_getAssociatedObject(self, kLuaCore_ ## CLZ);\
    return wp.associatedObject;\
}

/**
 标记完成实体UserData类导出
 @note ⚠️如果需要自定义初始化方法，第一个参数必须是MLNLuaCore。
 
 @param CLZ 原生类名称
 @param PACKAGE Lua中的包名
 @param LUA_CLZ Lua中的类名称
 @param HAS_SUPER 是否有父类 (YES/NO)，这是在Lua中的继承关系，并非原生的继承关系
 @param SUPERCLZ 父类的原生类名字，可以没有原生的继承关系。
 @param CONSTRUCTOR_NAME 构造器方法，默认为”initWithLuaCore:“.
 */
#define LUA_EXPORT_PACKAGE_END(CLZ, PACKAGE, LUA_CLZ, HAS_SUPER, SUPER_CLZ_NAME, CONSTRUCTOR_NAME) \
LUA_EXPORT_METHOD_LIST_COMPLETED \
LUA_EXPORT_MAKE_INFO(PACKAGE, #CLZ, #LUA_CLZ, "MLN_UserDataNativeObject", HAS_SUPER, SUPER_CLZ_NAME, YES,\
(struct mln_objc_method *)mln_Method_ ## CLZ, NULL,\
LUA_EXPORT_MAKE_METHOD("constructor", CONSTRUCTOR_NAME, #CLZ, NO, NULL, NULL, mln_lua_constructor),\
CLZ)\
LUA_EXPORT_TYPE(MLNExportTypeEntity)\
LUA_EXPORT_LUA_CORE(CLZ)\
LUA_EXPORT_LUA_RETAIN_COUNT(CLZ)


/**
 标记完成实体UserData类导出 (构造函数为C函数)
 @note ⚠️使用C函数创建对象，必要将mln_isLuaObject属性设置为YES
 
 @param CLZ 原生类名称
 @param PACKAGE Lua中的包名
 @param LUA_CLZ Lua中的类名称
 @param HAS_SUPER 是否有父类 (YES/NO)，这是在Lua中的继承关系，并非原生的继承关系
 @param SUPERCLZ 父类的原生类名字，可以没有原生的继承关系。
 @param CONSTRUCTOR_CFUNC C函数构造器
 */
#define LUA_EXPORT_PACKAGE_END_WITH_CFUNC(CLZ, PACKAGE, LUA_CLZ, HAS_SUPER, SUPER_CLZ_NAME, CONSTRUCTOR_CFUNC) \
LUA_EXPORT_METHOD_LIST_COMPLETED \
LUA_EXPORT_MAKE_INFO(PACKAGE, #CLZ, #LUA_CLZ, "MLN_UserDataNativeObject", HAS_SUPER, SUPER_CLZ_NAME, YES,\
(struct mln_objc_method *)mln_Method_ ## CLZ, NULL,\
LUA_EXPORT_MAKE_METHOD("constructor", NULL, #CLZ, NO, NULL, NULL, CONSTRUCTOR_CFUNC),\
CLZ)\
LUA_EXPORT_TYPE(MLNExportTypeEntity)\
LUA_EXPORT_LUA_CORE(CLZ)\
LUA_EXPORT_LUA_RETAIN_COUNT(CLZ)

/**
 标记完成实体UserData类导出
 @note ⚠️如果需要自定义初始化方法，第一个参数必须是MLNLuaCore。
 
 @param CLZ 原生类名称
 @param LUA_CLZ Lua中的类名称
 @param HAS_SUPER 是否有父类 (YES/NO)，这是在Lua中的继承关系，并非原生的继承关系
 @param SUPERCLZ 父类的原生类名字，可以没有原生的继承关系。
 @param CONSTRUCTOR_NAME 构造器方法，默认为”init“。
 */
#define LUA_EXPORT_END(CLZ, LUA_CLZ, HAS_SUPER, SUPER_CLZ_NAME, CONSTRUCTOR_NAME) \
LUA_EXPORT_PACKAGE_END(CLZ, "mln", LUA_CLZ, HAS_SUPER, SUPER_CLZ_NAME, CONSTRUCTOR_NAME)

/**
 导出Object结束 (C函数)
 @note ⚠️使用C函数创建对象，必要将mln_isLuaObject属性设置为YES
 
 @param CLZ 原生类名称
 @param LUA_CLZ Lua中的类名称
 @param HAS_SUPER 是否有父类 (YES/NO)，这是在Lua中的继承关系，并非原生的继承关系
 @param SUPERCLZ 父类的原生类名字，可以没有原生的继承关系。
 @param CONSTRUCTOR_CFUNC C函数构造器
 */
#define LUA_EXPORT_END_WITH_CFUNC(CLZ, LUA_CLZ, HAS_SUPER, SUPER_CLZ_NAME, CONSTRUCTOR_CFUNC) \
LUA_EXPORT_PACKAGE_END_WITH_CFUNC(CLZ, "mln", LUA_CLZ, HAS_SUPER, SUPER_CLZ_NAME, CONSTRUCTOR_CFUNC)

#endif /* MLNEntityExporterMacro_h */
