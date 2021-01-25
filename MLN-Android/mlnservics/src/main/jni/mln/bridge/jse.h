/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
//
// Created by XiongFangyu on 2020/8/28.
//

#ifndef MMLUA4ANDROID_JSE_H
#define MMLUA4ANDROID_JSE_H

#include "lua.h"
#include <jni.h>
/**
 * 注册JavaInstance和JavaClass
 * @see org.luaj.vm2.jse.JavaInstance
 * @see org.luaj.vm2.jse.JavaClass
 */
JNIEXPORT void JNICALL Java_org_luaj_vm2_jse_JSERegister__1registerJSE
        (JNIEnv *env, jclass cls, jlong l);
#endif //MMLUA4ANDROID_JSE_H
