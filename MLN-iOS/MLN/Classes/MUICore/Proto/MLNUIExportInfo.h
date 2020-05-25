//
//  MLNUIExportInfo.h
//  MLNUICore
//
//  Created by MoMo on 2019/7/23.
//

#ifndef MLNUIExportInfo_h
#define MLNUIExportInfo_h

#include "mln_lua.h"

struct mln_objc_method ;
typedef struct mln_objc_method *MLNUI_Method_List;
struct mln_objc_class;
typedef struct mln_objc_class *MLNUI_Class;

/**
 方法信息结构体
 */
typedef struct mln_objc_method {
    const char *l_mn;  /* Object-C method name in lua*/
    const char *mn; /* Object-C method name */
    const char *clz; /* Object-C class name */
    BOOL isProperty; /* It's YES if property method*/
    const char *setter_n; /* Object-C getter method name*/
    const char *getter_n; /* Object-C setter method name */
    lua_CFunction func; /* C function in lua */
} mln_objc_method;

/**
 类描述信息结构体
 */
typedef struct mln_objc_class {
    const char *pkg; /* packge name */
    const char *clz; /* Object-C class name */
    const char *l_clz; /* Object-C class name in lua */
    const char *l_name; /* Object-C class name in lua */
    const char *l_type; /* its type of Object-C class in lua  */
    BOOL isRoot; /* is root function,it should be YES if no base class. */
    const char *supreClz; /* base Object-C class */
    BOOL hasConstructor; /* it should be NO if static class. */
    MLNUI_Method_List methods; /* Object-C method */
    MLNUI_Method_List clz_methods; /* Object-C class method */
    struct mln_objc_method constructor; /* Object-C constructor method */
} mln_objc_class;

#define MLNUIHasSuperClass(clz) (!(clz)->isRoot)

/**
 自定义lua USer
 */
typedef struct _MLNUIUserData {
    /* 对应的native类型 */
    const char *type;
    /* 对应的native对象 */
    const void *object;
} MLNUIUserData;

#endif /* MLNUIExportInfo_h */
