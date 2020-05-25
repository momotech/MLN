//
//  MLNUIViewExporterMacro.h
//  MLNUICore
//
//  Created by MoMo on 2019/8/1.
//

#ifndef MLNUIViewExporterMacro_h
#define MLNUIViewExporterMacro_h

#import "MLNUIEntityExporterMacro.h"

/**
 导出View开始
 
 @param CLZ 类名 (例：NSObject)
 */
#define LUA_EXPORT_VIEW_BEGIN(CLZ)  LUA_EXPORT_BEGIN(CLZ)

/**
 导出方法映射
 
 @param LUA_FUNC Lua中的方法名称
 @param SEL_NAME 原生View的对象方法名称
 @param CLZ 原生类名称
 */
#define LUA_EXPORT_VIEW_METHOD(LUA_FUNC, SEL_NAME, CLZ) \
LUA_EXPORT_METHOD(LUA_FUNC, SEL_NAME, CLZ)

/**
 导出C函数映射
 
 @param LUA_FUNC Lua中的方法名称
 @param CFUNC C函数
 @param CLZ 原生类名称
 */
#define LUA_EXPORT_VIEW_METHOD_WITH_CFUNC(LUA_FUNC, CFUNC, CLZ) \
LUA_EXPORT_METHOD_WITH_CFUNC(LUA_FUNC, CFUNC, CLZ)

/**
 导出属性方法映射
 
 @param LUA_FUNC Lua中的方法名称
 @param SETTER_NAME 原生View属性的setter方法
 @param GETTER_NAME 原生View属性的getter方法
 @param CLZ 原生类名称
 */
#define LUA_EXPORT_VIEW_PROPERTY(LUA_FUNC, SETTER_NAME, GETTER_NAME, CLZ) \
LUA_EXPORT_PROPERTY(LUA_FUNC, SETTER_NAME, GETTER_NAME, CLZ)

/**
 导出属性与C函数映射
 
 @param LUA_FUNC Lua中的方法名称
 @param CFUNC C函数
 @param CLZ 原生类名称
 */
#define LUA_EXPORT_VIEW_PROPERTY_WITH_CFUNC(LUA_FUNC, CFUNC, CLZ) \
LUA_EXPORT_PROPERTY_WITH_CFUNC(LUA_FUNC, NULL, NULL, CFUNC, CLZ)

/**
 标记完成View UserData类导出 (构造函数为C函数)
 @note ⚠️使用C函数创建对象，必要将mlnui_isLuaObject属性设置为YES
 
 @param CLZ 原生类名称
 @param PACKAGE Lua中的包名
 @param LUA_CLZ Lua中的类名称
 @param HAS_SUPER 是否有父类 (YES/NO)，这是在Lua中的继承关系，并非原生的继承关系
 @param SUPERCLZ 父类的原生类名字，可以没有原生的继承关系。
 @param CONSTRUCTOR_CFUNC C函数构造器
 */
#define LUA_EXPORT_PACKAGE_VIEW_END_WITH_CFUNC(CLZ, PACKAGE, LUA_CLZ, HAS_SUPER, SUPER_CLZ_NAME, CFUNC_CONSTRUCTOR) \
LUA_EXPORT_PACKAGE_END_WITH_CFUNC(CLZ, PACKAGE, LUA_CLZ, HAS_SUPER, SUPER_CLZ_NAME, CFUNC_CONSTRUCTOR)

/**
 标记完成View UserData类导出 (构造函数为C函数)
 @note ⚠️使用C函数创建对象，必要将mlnui_isLuaObject属性设置为YES
 
 @param CLZ 原生类名称
 @param LUA_CLZ Lua中的类名称
 @param HAS_SUPER 是否有父类 (YES/NO)，这是在Lua中的继承关系，并非原生的继承关系
 @param SUPERCLZ 父类的原生类名字，可以没有原生的继承关系。
 @param CONSTRUCTOR_CFUNC C函数构造器
 */
#define LUA_EXPORT_VIEW_END_WITH_CFUNC(CLZ, LUA_CLZ, HAS_SUPER, SUPER_CLZ_NAME, CFUNC_CONSTRUCTOR) \
LUA_EXPORT_PACKAGE_VIEW_END_WITH_CFUNC(CLZ, "mln", LUA_CLZ, HAS_SUPER, SUPER_CLZ_NAME, CFUNC_CONSTRUCTOR)

/**
 标记完成View UserData类导出
 @note ⚠️如果需要自定义初始化方法，第一个参数必须是MLNUILuaCore。
 
 @param CLZ 原生类名称
 @param PACKAGE Lua中的包名
 @param LUA_CLZ Lua中的类名称
 @param HAS_SUPER 是否有父类 (YES/NO)，这是在Lua中的继承关系，并非原生的继承关系
 @param SUPERCLZ 父类的原生类名字，可以没有原生的继承关系。
 @param CONSTRUCTOR_NAME 构造器方法，默认为”initWithMLNUILuaCore:“。
 */
#define LUA_EXPORT_PACKAGE_VIEW_END(CLZ, PACKAGE, LUA_CLZ, HAS_SUPER, SUPER_CLZ_NAME, CONSTRUCTOR_NAME) \
LUA_EXPORT_PACKAGE_END(CLZ, PACKAGE, LUA_CLZ, HAS_SUPER, SUPER_CLZ_NAME, CONSTRUCTOR_NAME)

/**
 标记完成View UserData类导出
 @note ⚠️如果需要自定义初始化方法，第一个参数必须是MLNUILuaCore。
 
 @param CLZ 原生类名称
 @param LUA_CLZ Lua中的类名称
 @param HAS_SUPER 是否有父类 (YES/NO)，这是在Lua中的继承关系，并非原生的继承关系
 @param SUPERCLZ 父类的原生类名字，可以没有原生的继承关系。
 @param CONSTRUCTOR_NAME 构造器方法，默认为”initWithMLNUILuaCore:“。
 */
#define LUA_EXPORT_VIEW_END(CLZ, LUA_CLZ, HAS_SUPER, SUPER_CLZ_NAME, CONSTRUCTOR_NAME) \
LUA_EXPORT_PACKAGE_VIEW_END(CLZ, "mln", LUA_CLZ, HAS_SUPER, SUPER_CLZ_NAME, CONSTRUCTOR_NAME)

#endif /* MLNUIViewExporterMacro_h */
