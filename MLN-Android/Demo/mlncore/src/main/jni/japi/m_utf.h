//
// Created by XiongFangyu on 2019-07-29.
//

#ifndef MMLUA4ANDROID_M_UTF_H
#define MMLUA4ANDROID_M_UTF_H

#include <stdlib.h>

size_t ConvertModifiedUtf8ToUtf16(uint16_t* utf16_data_out,
                                const char* utf8_data_in, size_t in_bytes);
#endif //MMLUA4ANDROID_M_UTF_H
