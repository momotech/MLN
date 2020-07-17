//
// Created by momo783 on 2020/5/14.
// Copyright (c) 2020 boztrail. All rights reserved.
//

#ifndef ANIMATION_COMMONTYPES_H
#define ANIMATION_COMMONTYPES_H

/**
 * Animator Engine 相关宏定义
 */

#if defined(__APPLE__)
#include <TargetConditionals.h>
# if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
#  define ANIMATOR_PLATFORM_IOS 1
# else
#  define ANIMATOR_PLATFORM_MAC 1
# endif
#elif defined(__ANDROID__)
# define ANIMATOR_PLATFORM_ANDROID 1
#endif

#ifdef __cplusplus
# define ANIMATOR_EXTERN_C_BEGIN extern "C" {
# define ANIMATOR_EXTERN_C_END   }
#else
# define ANIMATOR_EXTERN_C_BEGIN
# define ANIMATOR_EXTERN_C_END
#endif

#if defined (__cplusplus) && defined (__GNUC__)
# define ANIMATOR_INLINE __attribute__ ((always_inline))
# define ANIMATOR_NOTHROW __attribute__ ((nothrow))
#else
# define ANIMATOR_INLINE
# define ANIMATOR_NOTHROW
#endif

#define ANIMATOR_NAMESPACE animator

#ifndef ANIMATOR_NAMESPACE_BEGIN
# define ANIMATOR_NAMESPACE_BEGIN namespace ANIMATOR_NAMESPACE {
# define ANIMATOR_NAMESPACE_END  };
#endif

#ifndef ANIMATOR_ASSERT
#ifdef DEBUG
# define ANIMATOR_ASSERT(x) assert(x)
#else
# define ANIMATOR_ASSERT(x)
#endif
#endif

#define ANIMATOR_SAFE_DELETE(x) if (x != nullptr) { delete x; x = nullptr; }

#include <string>

typedef int AMTInt;
typedef bool AMTBool;

#if defined(__LP64__) && __LP64__
typedef double AMTFloat;
# define AMTFLOAT_IS_DOUBLE 1
#else
typedef float AMTFloat;
#endif
typedef double AMTDouble;

typedef double AMTTimeInterval;
typedef std::string AMTString;

#define ANIMATOR_ARRAY_COUNT(x) sizeof(x) / sizeof(x[0])

ANIMATOR_NAMESPACE_BEGIN

enum TimingFunction {
    Default,
    Linear,
    EaseIn,
    EaseOut,
    EaseInOut,
};


ANIMATOR_NAMESPACE_END

#endif //ANIMATION_COMMONTYPES_H
