//
//  MLNUILayoutMacro.h
//  MLN
//
//  Created by MOMO on 2020/5/29.
//

#pragma once
#import "YGValue.h"
#define MLNUIMax YGUndefined

/** ======= */
typedef YGValue MLNUIValue;
#define MLNUIPointValue(value)   MLNUIPointValue(value)
#define MLNUIPercentValue(value) MLNUIPercentValue(value)
#define MLNUIValueUndefined      YGValueUndefined
#define MLNUIValueAuto           YGValueAuto
#define MLNUIValueZero           YGValueZero

/** ======= */
typedef YGUnit  MLNUIUnit;
#define MLNUIUnitUndefined YGUnitUndefined
#define MLNUIUnitPoint     YGUnitPoint
#define MLNUIUnitPercent   YGUnitPercent
#define MLNUIUnitAuto      YGUnitAuto

/** ======= */
typedef YGAlign MLNUIAlign;
typedef MLNUIAlign MLNUICrossAlign;
#define MLNUIAlignAuto         YGAlignAuto
#define MLNUIAlignStart        YGAlignFlexStart
#define MLNUIAlignCenter       YGAlignCenter
#define MLNUIAlignEnd          YGAlignFlexEnd
#define MLNUIAlignStretch      YGAlignStretch
#define MLNUIAlignBaseline     YGAlignBaseline
#define MLNUIAlignSpaceBetween YGAlignSpaceBetween
#define MLNUIAlignSpaceAround  YGAlignSpaceAround

/** ======= */
typedef YGDimension MLNUIDimension;
#define MLNUIDimensionWidth  YGDimensionWidth
#define MLNUIDimensionHeight YGDimensionHeight

/** ======= */
typedef YGFlexDirection MLNUIFlexDirection;
#define MLNUIFlexDirectionColumn        YGFlexDirectionColumn
#define MLNUIFlexDirectionColumnReverse YGFlexDirectionColumnReverse
#define MLNUIFlexDirectionRow           YGFlexDirectionRow
#define MLNUIFlexDirectionRowReverse    YGFlexDirectionRowReverse

/** ======= */
typedef YGDirection MLNUIDirection;
#define MLNUIDirectionInherit YGDirectionInherit
#define MLNUIDirectionLTR     YGDirectionLTR
#define MLNUIDirectionRTL     YGDirectionRTL

/** ======= */
typedef YGJustify MLNUIJustify;
#define MLNUIJustifyFlexStart    YGJustifyFlexStart
#define MLNUIJustifyCenter       YGJustifyCenter
#define MLNUIJustifyFlexEnd      YGJustifyFlexEnd
#define MLNUIJustifySpaceBetween YGJustifySpaceBetween
#define MLNUIJustifySpaceAround  YGJustifySpaceAround
#define MLNUIJustifySpaceEvenly  YGJustifySpaceEvenly

/** ======= */
typedef YGPositionType MLNUIPositionType;
#define MLNUIPositionTypeRelative YGPositionTypeRelative
#define MLNUIPositionTypeAbsolute YGPositionTypeAbsolute

/** ======= */
typedef YGWrap MLNUIWrap;
#define MLNUIWrapNoWrap      YGWrapNoWrap
#define MLNUIWrapWrap        YGWrapWrap
#define MLNUIWrapWrapReverse YGWrapWrapReverse

/** ======= */
typedef YGDisplay MLNUIDisplay;
#define MLNUIDisplayFlex YGDisplayFlex
#define MLNUIDisplayNone YGDisplayNone
