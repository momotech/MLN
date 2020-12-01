/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "MLAAnimationRuntime.h"

#import <objc/objc.h>
#import <objc/runtime.h>

#import <QuartzCore/QuartzCore.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

#import "MLACGUtils.h"
#import "MLAGeometry.h"
//#import "Vector.h"

static Boolean pointerEqual(const void *ptr1, const void *ptr2) {
  return ptr1 == ptr2;
}

static CFHashCode pointerHash(const void *ptr) {
  return (CFHashCode)(ptr);
}

CFMutableDictionaryRef MLADictionaryCreateMutableWeakPointerToWeakPointer(NSUInteger capacity)
{
  CFDictionaryKeyCallBacks kcb = kCFTypeDictionaryKeyCallBacks;

  // weak, pointer keys
  kcb.retain = NULL;
  kcb.release = NULL;
  kcb.equal = pointerEqual;
  kcb.hash = pointerHash;

  CFDictionaryValueCallBacks vcb = kCFTypeDictionaryValueCallBacks;

  // weak, pointer values
  vcb.retain = NULL;
  vcb.release = NULL;
  vcb.equal = pointerEqual;

  return CFDictionaryCreateMutable(NULL, capacity, &kcb, &vcb);
}

CFMutableDictionaryRef MLADictionaryCreateMutableWeakPointerToStrongObject(NSUInteger capacity)
{
  CFDictionaryKeyCallBacks kcb = kCFTypeDictionaryKeyCallBacks;

  // weak, pointer keys
  kcb.retain = NULL;
  kcb.release = NULL;
  kcb.equal = pointerEqual;
  kcb.hash = pointerHash;

  // strong, object values
  CFDictionaryValueCallBacks vcb = kCFTypeDictionaryValueCallBacks;

  return CFDictionaryCreateMutable(NULL, capacity, &kcb, &vcb);
}

static bool FBCompareTypeEncoding(const char *objctype, MLAValueType type)
{
  switch (type)
  {
    case kMLAValueFloat:
      return (strcmp(objctype, @encode(float)) == 0
              || strcmp(objctype, @encode(double)) == 0
              );

    case kMLAValuePoint:
      return (strcmp(objctype, @encode(CGPoint)) == 0
#if !TARGET_OS_IPHONE
              || strcmp(objctype, @encode(NSPoint)) == 0
#endif
              );

    case kMLAValueSize:
      return (strcmp(objctype, @encode(CGSize)) == 0
#if !TARGET_OS_IPHONE
              || strcmp(objctype, @encode(NSSize)) == 0
#endif
              );

    case kMLAValueRect:
      return (strcmp(objctype, @encode(CGRect)) == 0
#if !TARGET_OS_IPHONE
              || strcmp(objctype, @encode(NSRect)) == 0
#endif
              );
    case kMLAValueEdgeInsets:
#if TARGET_OS_IPHONE
      return strcmp(objctype, @encode(UIEdgeInsets)) == 0;
#else
      return false;
#endif
      
    case kMLAValueAffineTransform:
      return strcmp(objctype, @encode(CGAffineTransform)) == 0;

    case kMLAValueTransform:
      return strcmp(objctype, @encode(CATransform3D)) == 0;

    case kMLAValueRange:
      return strcmp(objctype, @encode(CFRange)) == 0
      || strcmp(objctype, @encode (NSRange)) == 0;

    case kMLAValueInteger:
      return (strcmp(objctype, @encode(int)) == 0
              || strcmp(objctype, @encode(unsigned int)) == 0
              || strcmp(objctype, @encode(short)) == 0
              || strcmp(objctype, @encode(unsigned short)) == 0
              || strcmp(objctype, @encode(long)) == 0
              || strcmp(objctype, @encode(unsigned long)) == 0
              || strcmp(objctype, @encode(long long)) == 0
              || strcmp(objctype, @encode(unsigned long long)) == 0
              );
      
    default:
      return false;
  }
}

MLAValueType MLASelectValueType(const char *objctype, const MLAValueType *types, size_t length)
{
  if (NULL != objctype) {
    for (size_t idx = 0; idx < length; idx++) {
      if (FBCompareTypeEncoding(objctype, types[idx]))
        return types[idx];
    }
  }
  return kMLAValueUnknown;
}

MLAValueType MLASelectValueType(id obj, const MLAValueType *types, size_t length)
{
  if ([obj isKindOfClass:[NSValue class]]) {
    return MLASelectValueType([obj objCType], types, length);
  } else if (NULL != MLACGColorWithColor(obj)) {
    return kMLAValueColor;
  }
  return kMLAValueUnknown;
}

const MLAValueType kMLAAnimatableAllTypes[12] = {kMLAValueInteger, kMLAValueFloat, kMLAValuePoint, kMLAValueSize, kMLAValueRect, kMLAValueEdgeInsets, kMLAValueAffineTransform, kMLAValueTransform, kMLAValueRange, kMLAValueColor};

const MLAValueType kMLAAnimatableSupportTypes[10] = {kMLAValueInteger, kMLAValueFloat, kMLAValuePoint, kMLAValueSize, kMLAValueRect, kMLAValueEdgeInsets, kMLAValueColor};

NSString *MLAValueTypeToString(MLAValueType t)
{
  switch (t) {
    case kMLAValueUnknown:
      return @"unknown";
    case kMLAValueInteger:
      return @"int";
    case kMLAValueFloat:
      return @"CGFloat";
    case kMLAValuePoint:
      return @"CGPoint";
    case kMLAValueSize:
      return @"CGSize";
    case kMLAValueRect:
      return @"CGRect";
    case kMLAValueEdgeInsets:
      return @"UIEdgeInsets";
    case kMLAValueAffineTransform:
      return @"CGAffineTransform";
    case kMLAValueTransform:
      return @"CATransform3D";
    case kMLAValueRange:
      return @"CFRange";
    case kMLAValueColor:
      return @"CGColorRef";
    default:
      return nil;
  }
}

id MLABox(VectorConstRef vec, MLAValueType type, bool force)
{
  if (NULL == vec)
    return nil;
  
  switch (type) {
    case kMLAValueInteger:
    case kMLAValueFloat:
      return @(vec->data()[0]);
      break;
    case kMLAValuePoint:
      return [NSValue valueWithCGPoint:vec->cg_point()];
      break;
    case kMLAValueSize:
      return [NSValue valueWithCGSize:vec->cg_size()];
      break;
    case kMLAValueRect:
      return [NSValue valueWithCGRect:vec->cg_rect()];
      break;
#if TARGET_OS_IPHONE
    case kMLAValueEdgeInsets:
      return [NSValue valueWithUIEdgeInsets:vec->ui_edge_insets()];
      break;
#endif
    case kMLAValueColor: {
      return vec->ui_color();
      break;
    }
    default:
      return force ? [NSValue valueWithCGPoint:vec->cg_point()] : nil;
      break;
  }
}

static VectorRef vectorize(id value, MLAValueType type)
{
  Vector *vec = NULL;

  switch (type) {
    case kMLAValueInteger:
    case kMLAValueFloat:
#if AMTFLOAT_IS_DOUBLE
      vec = Vector::new_cg_float([value doubleValue]);
#else
      vec = Vector::new_cg_float([value floatValue]);
#endif
      break;
    case kMLAValuePoint:
      vec = Vector::new_cg_point([value CGPointValue]);
      break;
    case kMLAValueSize:
      vec = Vector::new_cg_size([value CGSizeValue]);
      break;
    case kMLAValueRect:
      vec = Vector::new_cg_rect([value CGRectValue]);
      break;
#if TARGET_OS_IPHONE
    case kMLAValueEdgeInsets:
      vec = Vector::new_ui_edge_insets([value UIEdgeInsetsValue]);
      break;
#endif
    case kMLAValueAffineTransform:
      vec = Vector::new_cg_affine_transform([value CGAffineTransformValue]);
      break;
    case kMLAValueColor:
      vec = Vector::new_ui_color(value);
      break;
    default:
      break;
  }
  
  return VectorRef(vec);
}

VectorRef MLAUnbox(id value, MLAValueType &animationType, NSUInteger &count, bool validate)
{
  if (nil == value) {
    count = 0;
    return VectorRef(NULL);
  }

  // determine type of value
  MLAValueType valueType = MLASelectValueType(value, kMLAAnimatableSupportTypes, MLA_ARRAY_COUNT(kMLAAnimatableSupportTypes));

  // handle unknown types
  if (kMLAValueUnknown == valueType) {
    NSString *valueDesc = [[value class] description];
    [NSException raise:@"Unsuported value" format:@"Animating %@ values is not supported", valueDesc];
  }

  // vectorize
  VectorRef vec = vectorize(value, valueType);

  if (kMLAValueUnknown == animationType || 0 == count) {
    // update animation type based on value type
    animationType = valueType;
    if (NULL != vec) {
      count = vec->size();
    }
  } else if (validate) {
    // allow for mismatched types, so long as vector size matches
    if (count != vec->size()) {
      [NSException raise:@"Invalid value" format:@"%@ should be of type %@", value, MLAValueTypeToString(animationType)];
    }
  }
  
  return vec;
}
