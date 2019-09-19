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

#include "m_utf.h"

uint32_t GetUtf16FromUtf8(const char** utf8_data_in) {
    const uint8_t one = *(*utf8_data_in)++;
    if ((one & 0x80) == 0) {
        // one-byte encoding
        return one;
    }
    const uint8_t two = *(*utf8_data_in)++;
    if ((one & 0x20) == 0) {
        // two-byte encoding
        return ((one & 0x1f) << 6) | (two & 0x3f);
    }
    const uint8_t three = *(*utf8_data_in)++;
    if ((one & 0x10) == 0) {
        return ((one & 0x0f) << 12) | ((two & 0x3f) << 6) | (three & 0x3f);
    }
    // Four byte encodings need special handling. We'll have
    // to convert them into a surrogate pair.
    const uint8_t four = *(*utf8_data_in)++;
    // Since this is a 4 byte UTF-8 sequence, it will lie between
    // U+10000 and U+1FFFFF.
    //
    // spec says they're invalid but nobody appears to check for them.
    const uint32_t code_point = ((one & 0x0f) << 18) | ((two & 0x3f) << 12)
                                | ((three & 0x3f) << 6) | (four & 0x3f);
    uint32_t surrogate_pair = 0;
    // Step two: Write out the high (leading) surrogate to the bottom 16 bits
    // of the of the 32 bit type.
    surrogate_pair |= ((code_point >> 10) + 0xd7c0) & 0xffff;
    // Step three : Write out the low (trailing) surrogate to the top 16 bits.
    surrogate_pair |= ((code_point & 0x03ff) + 0xdc00) << 16;
    return surrogate_pair;
}

size_t ConvertModifiedUtf8ToUtf16(uint16_t* utf16_data_out,
                                const char* utf8_data_in, size_t in_bytes) {
    const char *in_start = utf8_data_in;
    const char *in_end = utf8_data_in + in_bytes;
    uint16_t *out_p = utf16_data_out;
    size_t real_len = 0;

    // String contains non-ASCII characters.
    for (const char *p = in_start; p < in_end;) {
        const uint32_t ch = GetUtf16FromUtf8(&p);
        const uint16_t leading = (uint16_t) (ch & 0x0000FFFF);
        const uint16_t trailing = (uint16_t) (ch >> 16);
        *out_p++ = leading;
        real_len += leading ? 1 : 0;
        if (trailing != 0) {
            *out_p++ = trailing;
            real_len++;
        }
    }
    return real_len;
}