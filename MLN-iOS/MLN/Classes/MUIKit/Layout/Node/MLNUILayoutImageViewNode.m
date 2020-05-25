//
//  MLNUILayoutImageViewNode.m
//  MLNUI
//
//  Created by MoMo on 2019/10/29.
//

#import "MLNUILayoutImageViewNode.h"
#import "MLNUIKitHeader.h"
#import "UIView+MLNUILayout.h"
#import "MLNUILayoutContainerNode.h"
#import "UIView+MLNUIKit.h"
#import "MLNUILayoutImageViewNode.h"
#import "UIView+MLNUILayout.h"
#import "MLNUIKitHeader.h"

@implementation MLNUILayoutImageViewNode

- (CGSize)measureSizeWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight
{
    if (self.isGone) {
        return CGSizeZero;
    }
    switch (self.layoutStrategy) {
        case MLNUILayoutStrategySimapleAuto: {
            measureImageViewAutoNodeSize(self, maxWidth, maxHeight);
            break;
        }
        case MLNUILayoutStrategyNativeFrame: {
            self.measuredWidth = self.width;
            self.measuredHeight = self.height;
            break;
        }
        default: {
            break;
        }
    }
    if (self.overlayNode) {
        CGFloat overlayMaxWidth = self.measuredWidth - self.overlayNode.marginLeft - self.overlayNode.marginRight;
        CGFloat overlayMaxHeight = self.measuredHeight - self.overlayNode.marginTop - self.overlayNode.marginBottom;
        if (self.overlayNode.width > self.measuredWidth) {
            [self.overlayNode changeWidth:self.measuredWidth];
        }
        if (self.overlayNode.height > self.measuredHeight) {
            [self.overlayNode changeHeight:self.measuredHeight];
        }
        [self.overlayNode measureSizeWithMaxWidth:overlayMaxWidth maxHeight:overlayMaxHeight];
    }
    return CGSizeMake(self.measuredWidth, self.measuredHeight);
}

MLNUI_FORCE_INLINE void measureImageViewAutoNodeSize (MLNUILayoutNode __unsafe_unretained *node, CGFloat maxWidth, CGFloat maxHeight) {
    maxWidth = [node calculateWidthBaseOnWeightWithMaxWidth:maxWidth];
    maxHeight = [node calculateHeightBaseOnWeightWithMaxHeight:maxHeight];
    if (!node.isDirty && (node.lastMeasuredMaxWidth==maxWidth && node.lastMeasuredMaxHeight==maxHeight) && !isLayoutNodeHeightNeedMerge(node) && !isLayoutNodeWidthNeedMerge(node)) {
        return;
    }
    node.lastMeasuredMaxWidth = maxWidth;
    node.lastMeasuredMaxHeight = maxHeight;
    [node mergeMeasurementTypes];
    CGFloat widthSize = node.width;
    CGFloat heightSize = node.height;
    CGSize imgSize = [node.targetView luaui_measureSizeWithMaxWidth:maxWidth maxHeight:maxHeight];
    
    BOOL resizeWidth = NO;
    BOOL resizeHeight = NO;
    CGFloat desiredAspect = .0f;
    
    MLNUILayoutMeasurementType widthSpecMode = node.mergedWidthType;
    MLNUILayoutMeasurementType heightSpecMode= node.mergedHeightType;
    if (!CGSizeEqualToSize(imgSize, CGSizeZero)) {
        resizeWidth = widthSpecMode == MLNUILayoutMeasurementTypeWrapContent;
        resizeHeight = heightSpecMode == MLNUILayoutMeasurementTypeWrapContent;
        desiredAspect = imgSize.width / imgSize.height;
    }
    //两边至少有一边是WRAP_CONTENT的，需要根据实际内容计算
    if (resizeWidth || resizeHeight) {
        if (!node.isWidthExcatly) {
            widthSize = resolveAdjustedSize(imgSize.width, maxWidth, node.width>=0 ? node.width : 0, widthSpecMode);
        } else {
            widthSize = maxWidth;
        }
        
        if (!node.isHeightExcatly) {
            heightSize = resolveAdjustedSize(imgSize.height, maxHeight, node.height>=0 ? node.height : 0, heightSpecMode);
        } else {
            heightSize = maxHeight;
        }
        
        // 按宽高比例重新计算
        CGFloat actualAspect = widthSize / heightSize;
        
        if (fabs(actualAspect - desiredAspect) >= 0.0000001) {
            BOOL done = NO;
            if (resizeWidth && heightSpecMode != MLNUILayoutMeasurementTypeWrapContent) {
                CGFloat newWidth = desiredAspect * heightSize;
                if (!resizeHeight) {
                    widthSize = resolveAdjustedSize(newWidth, maxWidth, node.width>=0 ? node.width : 0 , widthSpecMode);
                }
                if (newWidth <= widthSize) {
                    widthSize = newWidth;
                    done = true;
                }
            }
            
            if (!done && resizeHeight && widthSpecMode != MLNUILayoutMeasurementTypeWrapContent) {
                CGFloat newHeight = widthSize / desiredAspect;
                if (!resizeWidth) {
                    heightSize = resolveAdjustedSize(newHeight,  maxHeight, node.height>=0 ? node.height : 0, heightSpecMode);
                }
                if (newHeight <= heightSize) {
                    heightSize = newHeight;
                }
            }
        }
    } else {
        if (!node.isWidthExcatly) {
            widthSize = resolveSizeAndState(node.width >= 0 ? node.width : 0 , maxWidth, widthSpecMode);
        } else {
            widthSize = maxWidth;
        }
        
        if (!node.isHeightExcatly) {
            heightSize = resolveSizeAndState(node.height >= 0 ? node.height : 0, maxHeight, heightSpecMode);
        } else {
            heightSize = maxHeight;
        }
    }
    node.measuredWidth = widthSize;
    node.measuredHeight=  heightSize;
}

MLNUI_FORCE_INLINE float resolveAdjustedSize(float desiredSize, float maxSize, float measureSize,MLNUILayoutMeasurementType measureType)
{
    CGFloat result = desiredSize;
    switch (measureType) {
        case MLNUILayoutMeasurementTypeWrapContent:
            result = MIN(desiredSize, maxSize);
            break;
        case MLNUILayoutMeasurementTypeMatchParent:
            result = maxSize;
            break;
        case MLNUILayoutMeasurementTypeIdle:
            result = measureSize;
            break;
    }
    return result;
}

MLNUI_FORCE_INLINE float resolveSizeAndState(float measureSize, float maxSize  , MLNUILayoutMeasurementType measureType) {
    CGFloat result = measureSize;
    switch (measureType) {
        case MLNUILayoutMeasurementTypeMatchParent:
            result = maxSize;
            break;
        case MLNUILayoutMeasurementTypeWrapContent:
        case MLNUILayoutMeasurementTypeIdle:
        default:
            result = measureSize;
    }
    return result;
}

@end
