/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

#import "Vector.h"
#import "MLAAnimatable.h"

enum MLAValueType
{
  kMLAValueUnknown = 0,
  kMLAValueInteger,
  kMLAValueFloat,
  kMLAValuePoint,
  kMLAValueSize,
  kMLAValueRect,
  kMLAValueEdgeInsets,
  kMLAValueAffineTransform,
  kMLAValueTransform,
  kMLAValueRange,
  kMLAValueColor
};

using namespace ANIMATOR_NAMESPACE;

/**
 Returns value type based on objc type description, given list of supported value types and length.
 */
extern MLAValueType MLASelectValueType(const char *objctype, const MLAValueType *types, size_t length);

/**
 Returns value type based on objc object, given a list of supported value types and length.
 */
extern MLAValueType MLASelectValueType(id obj, const MLAValueType *types, size_t length);

/**
 Array of all value types.
 */
extern const MLAValueType kMLAAnimatableAllTypes[12];

/**
 Array of all value types supported for animation.
 */
extern const MLAValueType kMLAAnimatableSupportTypes[10];

/**
 Returns a string description of a value type.
 */
extern NSString *MLAValueTypeToString(MLAValueType t);

/**
 Returns a mutable dictionary of weak pointer keys to weak pointer values.
 */
extern CFMutableDictionaryRef MLADictionaryCreateMutableWeakPointerToWeakPointer(NSUInteger capacity) CF_RETURNS_RETAINED;

/**
 Returns a mutable dictionary of weak pointer keys to weak pointer values.
 */
extern CFMutableDictionaryRef MLADictionaryCreateMutableWeakPointerToStrongObject(NSUInteger capacity) CF_RETURNS_RETAINED;

/**
 Box a vector.
 */
extern id MLABox(VectorConstRef vec, MLAValueType type, bool force = false);

/**
 Unbox a vector.
 */
extern VectorRef MLAUnbox(id value, MLAValueType &type, NSUInteger &count, bool validate);

/**
 Read object value and return a Vector4r.
 */
NS_INLINE Vector4r read_values(MLAValueReadBlock read, id obj, size_t count)
{
    Vector4r vec = Vector4r::Zero();
    if (0 == count) {
        return vec;
    }

    read(obj, vec.data());
    return vec;
}

NS_INLINE NSString *MLAStringFromBOOL(BOOL value)
{
  return value ? @"YES" : @"NO";
}
