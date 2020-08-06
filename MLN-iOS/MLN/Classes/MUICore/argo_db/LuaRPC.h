//
// Created by XiongFangyu on 2020/6/5.
//

#ifndef MMLUA4ANDROID_LUARPC_H
#define MMLUA4ANDROID_LUARPC_H

#include "lua.h"

#define RPC_OK 0
#define RPC_MEM_ERROR 1
#define RPC_UNSUPPORTED_TYPE 2
/**
 * 将src虚拟机栈中index位置数据拷贝到dest的栈顶
 * @return 0: 拷贝成功; 其他看error类型
 */
int rpc_copy(lua_State *src, int index, lua_State *dest);

#endif //MMLUA4ANDROID_LUARPC_H
