/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import <QuartzCore/QuartzCore.h>
#import "MLADefines.h"

MLA_EXTERN_C_BEGIN

#pragma mark - Scale

/**
 @abstract Returns layer scale factor for the x axis.
 */
extern CGFloat MLALayerGetScaleX(CALayer *l);

/**
 @abstract Set layer scale factor for the x axis.
 */
extern void MLALayerSetScaleX(CALayer *l, CGFloat f);

/**
 @abstract Returns layer scale factor for the y axis.
 */
extern CGFloat MLALayerGetScaleY(CALayer *l);

/**
 @abstract Set layer scale factor for the y axis.
 */
extern void MLALayerSetScaleY(CALayer *l, CGFloat f);

/**
 @abstract Returns layer scale factor for the z axis.
 */
extern CGFloat MLALayerGetScaleZ(CALayer *l);

/**
 @abstract Set layer scale factor for the z axis.
 */
extern void MLALayerSetScaleZ(CALayer *l, CGFloat f);

/**
 @abstract Returns layer scale factors for x and y access as point.
 */
extern CGPoint MLALayerGetScaleXY(CALayer *l);

/**
 @abstract Sets layer x and y scale factors given point.
 */
extern void MLALayerSetScaleXY(CALayer *l, CGPoint p);

#pragma mark - Translation

/**
 @abstract Returns layer translation factor for the x axis.
 */
extern CGFloat MLALayerGetTranslationX(CALayer *l);

/**
 @abstract Set layer translation factor for the x axis.
 */
extern void MLALayerSetTranslationX(CALayer *l, CGFloat f);

/**
 @abstract Returns layer translation factor for the y axis.
 */
extern CGFloat MLALayerGetTranslationY(CALayer *l);

/**
 @abstract Set layer translation factor for the y axis.
 */
extern void MLALayerSetTranslationY(CALayer *l, CGFloat f);

/**
 @abstract Returns layer translation factor for the z axis.
 */
extern CGFloat MLALayerGetTranslationZ(CALayer *l);

/**
 @abstract Set layer translation factor for the z axis.
 */
extern void MLALayerSetTranslationZ(CALayer *l, CGFloat f);

/**
 @abstract Returns layer translation factors for x and y access as point.
 */
extern CGPoint MLALayerGetTranslationXY(CALayer *l);

/**
 @abstract Sets layer x and y translation factors given point.
 */
extern void MLALayerSetTranslationXY(CALayer *l, CGPoint p);

#pragma mark - Rotation

/**
 @abstract Returns layer rotation, in radians, in the X axis.
 */
extern CGFloat MLALayerGetRotationX(CALayer *l);

/**
 @abstract Sets layer rotation, in radians, in the X axis.
 */
extern void MLALayerSetRotationX(CALayer *l, CGFloat f);

/**
 @abstract Returns layer rotation, in radians, in the Y axis.
 */
extern CGFloat MLALayerGetRotationY(CALayer *l);

/**
 @abstract Sets layer rotation, in radians, in the Y axis.
 */
extern void MLALayerSetRotationY(CALayer *l, CGFloat f);

/**
 @abstract Returns layer rotation, in radians, in the Z axis.
 */
extern CGFloat MLALayerGetRotationZ(CALayer *l);

/**
 @abstract Sets layer rotation, in radians, in the Z axis.
 */
extern void MLALayerSetRotationZ(CALayer *l, CGFloat f);

/**
 @abstract Returns layer rotation, in radians, in the Z axis.
 */
extern CGFloat MLALayerGetRotation(CALayer *l);

/**
 @abstract Sets layer rotation, in radians, in the Z axis.
 */
extern void MLALayerSetRotation(CALayer *l, CGFloat f);

#pragma mark - Sublayer Scale

/**
 @abstract Returns sublayer scale factors for x and y access as point.
 */
extern CGPoint MLALayerGetSubScaleXY(CALayer *l);

/**
 @abstract Sets sublayer x and y scale factors given point.
 */
extern void MLALayerSetSubScaleXY(CALayer *l, CGPoint p);

#pragma mark - Sublayer Translation

/**
 @abstract Returns sublayer translation factor for the x axis.
 */
extern CGFloat MLALayerGetSubTranslationX(CALayer *l);

/**
 @abstract Set sublayer translation factor for the x axis.
 */
extern void MLALayerSetSubTranslationX(CALayer *l, CGFloat f);

/**
 @abstract Returns sublayer translation factor for the y axis.
 */
extern CGFloat MLALayerGetSubTranslationY(CALayer *l);

/**
 @abstract Set sublayer translation factor for the y axis.
 */
extern void MLALayerSetSubTranslationY(CALayer *l, CGFloat f);

/**
 @abstract Returns sublayer translation factor for the z axis.
 */
extern CGFloat MLALayerGetSubTranslationZ(CALayer *l);

/**
 @abstract Set sublayer translation factor for the z axis.
 */
extern void MLALayerSetSubTranslationZ(CALayer *l, CGFloat f);

/**
 @abstract Returns sublayer translation factors for x and y access as point.
 */
extern CGPoint MLALayerGetSubTranslationXY(CALayer *l);

/**
 @abstract Sets sublayer x and y translation factors given point.
 */
extern void MLALayerSetSubTranslationXY(CALayer *l, CGPoint p);

MLA_EXTERN_C_END
