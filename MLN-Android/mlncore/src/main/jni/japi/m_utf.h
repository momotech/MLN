/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
// Created by XiongFangyu on 2019-07-29.
//

#ifndef MMLUA4ANDROID_M_UTF_H
#define MMLUA4ANDROID_M_UTF_H

#include <stdlib.h>
/**
 * @see jinfo.c
 * newJString
 */
size_t ConvertModifiedUtf8ToUtf16(uint16_t* utf16_data_out,
                                const char* utf8_data_in, size_t in_bytes);
#endif //MMLUA4ANDROID_M_UTF_H