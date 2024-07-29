//
// Created by XiongFangyu on 2020/6/5.
//

#ifndef MMLUA4ANDROID_LUAIPC_H
#define MMLUA4ANDROID_LUAIPC_H

#include "lua.h"

#define IPC_OK 0
#define IPC_MEM_ERROR 1
#define IPC_UNSUPPORTED_TYPE 2
/**
 * 将src虚拟机栈中index位置数据拷贝到dest的栈顶
 * @return 0: 拷贝成功; 其他看error类型
 */
int ipc_copy(lua_State *src, int index, lua_State *dest);

#endif //MMLUA4ANDROID_LUAIPC_H
