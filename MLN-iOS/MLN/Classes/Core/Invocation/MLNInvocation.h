//
//  MLNInvocation.h
//  MLNCore
//
//  Created by MoMo on 2019/7/30.
//

#import <Foundation/Foundation.h>
#import "MLNCore.h"
#import "MLNGlobalFuncExportProtocol.h"

/**
 lua虚拟机调用OC初始化方法的路由函数
 
 @param L 虚拟机
 @return OC初始化方法返回结果个数到lua虚拟机
 */
int mln_lua_constructor (lua_State *L);

/**
 lua虚拟机调用OC对象方法的路由函数
 
 @param L 虚拟机
 @return OC对象方法返回结果个数到lua虚拟机
 */
int mln_lua_obj_method (lua_State *L);

/**
 lua虚拟机调用OC类方法的路由函数
 
 @param L  虚拟机
 @return  OC类方法返回结果个数到lua虚拟机
 */
int mln_lua_class_method (lua_State *L);

/**
 lua虚拟机全局函数调用OC类方法的路由函数
 
 @param L  虚拟机
 @return  OC类方法返回结果个数到lua虚拟机
 */
int mln_lua_global_func (lua_State *L);


