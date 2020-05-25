//
//  MLNUIInvocation.h
//  MLNUICore
//
//  Created by MoMo on 2019/7/30.
//

#import <Foundation/Foundation.h>
#import "MLNUICore.h"
#import "MLNUIGlobalFuncExportProtocol.h"

/**
 lua虚拟机调用OC初始化方法的路由函数
 
 @param L 虚拟机
 @return OC初始化方法返回结果个数到lua虚拟机
 */
int mlnui_lua_constructor (lua_State *L);

/**
 lua虚拟机调用OC对象方法的路由函数
 
 @param L 虚拟机
 @return OC对象方法返回结果个数到lua虚拟机
 */
int mlnui_luaui_obj_method (lua_State *L);

/**
 lua虚拟机调用OC类方法的路由函数
 
 @param L  虚拟机
 @return  OC类方法返回结果个数到lua虚拟机
 */
int mlnui_luaui_class_method (lua_State *L);

/**
 lua虚拟机全局函数调用OC类方法的路由函数
 
 @param L  虚拟机
 @return  OC类方法返回结果个数到lua虚拟机
 */
int mlnui_luaui_global_func (lua_State *L);


