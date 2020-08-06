/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "MLALayerExtras.h"

#include "TransformationMatrix.h"

using namespace MLAWebCore;

#define DECOMPOSE_TRANSFORM(L) \
  TransformationMatrix _m(L.transform); \
  TransformationMatrix::DecomposedType _d; \
  _m.decompose(_d);

#define RECOMPOSE_TRANSFORM(L) \
  _m.recompose(_d); \
  L.transform = _m.transform3d();

#define RECOMPOSE_ROT_TRANSFORM(L) \
  _m.recompose(_d, true); \
  L.transform = _m.transform3d();

#define DECOMPOSE_SUBLAYER_TRANSFORM(L) \
  TransformationMatrix _m(L.sublayerTransform); \
  TransformationMatrix::DecomposedType _d; \
  _m.decompose(_d);

#define RECOMPOSE_SUBLAYER_TRANSFORM(L) \
  _m.recompose(_d); \
  L.sublayerTransform = _m.transform3d();

#pragma mark - Log

#if DEBUG
__unused static void MLALogLayerTransform3D(TransformationMatrix _m, NSString *flag) {
    NSLog(@"\n \
    ---- %@ begin ----\n \
    m11:%0.2f m12:%0.2f m13:%0.2f m14:%0.2f \n \
    m21:%0.2f m22:%0.2f m23:%0.2f m24:%0.2f \n \
    m31:%0.2f m32:%0.2f m33:%0.2f m34:%0.2f \n \
    m41:%0.2f m42:%0.2f m43:%0.2f m44:%0.2f \n \
    ------ %@ end ------\n.", (flag ?: @""), \
    _m.m11(), _m.m12(), _m.m13(), _m.m14(),
    _m.m21(), _m.m22(), _m.m23(), _m.m24(),
    _m.m31(), _m.m32(), _m.m33(), _m.m34(),
    _m.m41(), _m.m42(), _m.m43(), _m.m44(),
    (flag ?: @""));
}
#endif

#pragma mark - Scale

NS_INLINE void ensureNonZeroValue(CGFloat &f)
{
  if (f == 0) {
    f = 1e-6;
  }
}

NS_INLINE void ensureNonZeroValue(CGPoint &p)
{
  if (p.x == 0 && p.y == 0) {
    p.x = 1e-6;
    p.y = 1e-6;
  }
}

CGFloat MLALayerGetScaleX(CALayer *l)
{
    TransformationMatrix _m(l.transform);
    TransformationMatrix::DecomposedType _d;
    _m.decompose(_d);
    return _d.scaleX;
}

void MLALayerSetScaleX(CALayer *l, CGFloat f)
{
  ensureNonZeroValue(f);
  DECOMPOSE_TRANSFORM(l);
  _d.scaleX = f;
  RECOMPOSE_TRANSFORM(l);
}

CGFloat MLALayerGetScaleY(CALayer *l)
{
  DECOMPOSE_TRANSFORM(l);
  return _d.scaleY;
}

void MLALayerSetScaleY(CALayer *l, CGFloat f)
{
  ensureNonZeroValue(f);
  DECOMPOSE_TRANSFORM(l);
  _d.scaleY = f;
  RECOMPOSE_TRANSFORM(l);
}

CGFloat MLALayerGetScaleZ(CALayer *l)
{
  DECOMPOSE_TRANSFORM(l);
  return _d.scaleZ;
}

void MLALayerSetScaleZ(CALayer *l, CGFloat f)
{
  ensureNonZeroValue(f);
  DECOMPOSE_TRANSFORM(l);
  _d.scaleZ = f;
  RECOMPOSE_TRANSFORM(l);
}

CGPoint MLALayerGetScaleXY(CALayer *l)
{
  DECOMPOSE_TRANSFORM(l);
  return CGPointMake(_d.scaleX, _d.scaleY);
}

void MLALayerSetScaleXY(CALayer *l, CGPoint p)
{
  ensureNonZeroValue(p);
  DECOMPOSE_TRANSFORM(l);
  _d.scaleX = p.x;
  _d.scaleY = p.y;
  RECOMPOSE_TRANSFORM(l);
}

#pragma mark - Translation

CGFloat MLALayerGetTranslationX(CALayer *l)
{
  DECOMPOSE_TRANSFORM(l);
  return _d.translateX;
}

void MLALayerSetTranslationX(CALayer *l, CGFloat f)
{
  DECOMPOSE_TRANSFORM(l);
  _d.translateX = f;
  RECOMPOSE_TRANSFORM(l);
}

CGFloat MLALayerGetTranslationY(CALayer *l)
{
  DECOMPOSE_TRANSFORM(l);
  return _d.translateY;
}

void MLALayerSetTranslationY(CALayer *l, CGFloat f)
{
  DECOMPOSE_TRANSFORM(l);
  _d.translateY = f;
  RECOMPOSE_TRANSFORM(l);
}

CGFloat MLALayerGetTranslationZ(CALayer *l)
{
  DECOMPOSE_TRANSFORM(l);
  return _d.translateZ;
}

void MLALayerSetTranslationZ(CALayer *l, CGFloat f)
{
  DECOMPOSE_TRANSFORM(l);
  _d.translateZ = f;
  RECOMPOSE_TRANSFORM(l);
}

CGPoint MLALayerGetTranslationXY(CALayer *l)
{
  DECOMPOSE_TRANSFORM(l);
  return CGPointMake(_d.translateX, _d.translateY);
}

void MLALayerSetTranslationXY(CALayer *l, CGPoint p)
{
  DECOMPOSE_TRANSFORM(l);
  _d.translateX = p.x;
  _d.translateY = p.y;
  RECOMPOSE_TRANSFORM(l);
}

#pragma mark - Rotation

CGFloat MLALayerGetRotationX(CALayer *l)
{
  DECOMPOSE_TRANSFORM(l);
  return _d.rotateX;
}

void MLALayerSetRotationX(CALayer *l, CGFloat f)
{
  DECOMPOSE_TRANSFORM(l);
  _d.rotateX = f;
  RECOMPOSE_ROT_TRANSFORM(l);
}

CGFloat MLALayerGetRotationY(CALayer *l)
{
  DECOMPOSE_TRANSFORM(l);
  return _d.rotateY;
}

void MLALayerSetRotationY(CALayer *l, CGFloat f)
{
  DECOMPOSE_TRANSFORM(l);
  _d.rotateY = f;
  RECOMPOSE_ROT_TRANSFORM(l);
}

CGFloat MLALayerGetRotationZ(CALayer *l)
{
  DECOMPOSE_TRANSFORM(l);
  return _d.rotateZ;
}

void MLALayerSetRotationZ(CALayer *l, CGFloat f)
{
  DECOMPOSE_TRANSFORM(l);
  _d.rotateZ = f;
  RECOMPOSE_ROT_TRANSFORM(l);
}

CGFloat MLALayerGetRotation(CALayer *l)
{
  return MLALayerGetRotationZ(l);
}

void MLALayerSetRotation(CALayer *l, CGFloat f)
{
  MLALayerSetRotationZ(l, f);
}

#pragma mark - Sublayer Scale

CGPoint MLALayerGetSubScaleXY(CALayer *l)
{
  DECOMPOSE_SUBLAYER_TRANSFORM(l);
  return CGPointMake(_d.scaleX, _d.scaleY);
}

void MLALayerSetSubScaleXY(CALayer *l, CGPoint p)
{
  ensureNonZeroValue(p);
  DECOMPOSE_SUBLAYER_TRANSFORM(l);
  _d.scaleX = p.x;
  _d.scaleY = p.y;
  RECOMPOSE_SUBLAYER_TRANSFORM(l);
}

#pragma mark - Sublayer Translation

extern CGFloat MLALayerGetSubTranslationX(CALayer *l)
{
  DECOMPOSE_SUBLAYER_TRANSFORM(l);
  return _d.translateX;
}

extern void MLALayerSetSubTranslationX(CALayer *l, CGFloat f)
{
  DECOMPOSE_SUBLAYER_TRANSFORM(l);
  _d.translateX = f;
  RECOMPOSE_SUBLAYER_TRANSFORM(l);
}

extern CGFloat MLALayerGetSubTranslationY(CALayer *l)
{
  DECOMPOSE_SUBLAYER_TRANSFORM(l);
  return _d.translateY;
}

extern void MLALayerSetSubTranslationY(CALayer *l, CGFloat f)
{
  DECOMPOSE_SUBLAYER_TRANSFORM(l);
  _d.translateY = f;
  RECOMPOSE_SUBLAYER_TRANSFORM(l);
}

extern CGFloat MLALayerGetSubTranslationZ(CALayer *l)
{
  DECOMPOSE_SUBLAYER_TRANSFORM(l);
  return _d.translateZ;
}

extern void MLALayerSetSubTranslationZ(CALayer *l, CGFloat f)
{
  DECOMPOSE_SUBLAYER_TRANSFORM(l);
  _d.translateZ = f;
  RECOMPOSE_SUBLAYER_TRANSFORM(l);
}

extern CGPoint MLALayerGetSubTranslationXY(CALayer *l)
{
  DECOMPOSE_SUBLAYER_TRANSFORM(l);
  return CGPointMake(_d.translateX, _d.translateY);
}

extern void MLALayerSetSubTranslationXY(CALayer *l, CGPoint p)
{
  DECOMPOSE_SUBLAYER_TRANSFORM(l);
  _d.translateX = p.x;
  _d.translateY = p.y;
  RECOMPOSE_SUBLAYER_TRANSFORM(l);
}
