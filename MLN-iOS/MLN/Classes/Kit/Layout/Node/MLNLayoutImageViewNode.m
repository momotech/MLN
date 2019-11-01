//
//  MLNLayoutImageViewNode.m
//  MLN
//
//  Created by tamer on 2019/10/29.
//

#import "MLNLayoutImageViewNode.h"
#import "MLNKitHeader.h"
#import "UIView+MLNLayout.h"
#import "MLNLayoutContainerNode.h"
#import "UIView+MLNKit.h"

@implementation MLNLayoutImageViewNode

- (CGSize)measureSizeWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight
{
    if (self.isGone) {
        return CGSizeZero;
    }
    switch (self.layoutStrategy) {
        case MLNLayoutStrategySimapleAuto: {
            measureImageViewAutoNodeSize(self, maxWidth, maxHeight);
            break;
        }
        case MLNLayoutStrategyNativeFrame: {
            self.measuredWidth = self.width;
            self.measuredHeight = self.height;
            break;
        }
        default: {
            break;
        }
    }
    return CGSizeMake(self.measuredWidth, self.measuredHeight);
}

MLN_FORCE_INLINE void measureImageViewAutoNodeSize (MLNLayoutNode __unsafe_unretained *node, CGFloat maxWidth, CGFloat maxHeight) {
    maxWidth = [node calculateWidthBaseOnWeightWithMaxWidth:maxWidth];
    maxHeight = [node calculateHeightBaseOnWeightWithMaxHeight:maxHeight];
    if (!node.isDirty && (node.lastMeasuredMaxWidth==maxWidth && node.lastMeasuredMaxHeight==maxHeight)) {
        return;
    }
    node.lastMeasuredMaxWidth = maxWidth;
    node.lastMeasuredMaxHeight = maxHeight;
    [node mergeMeasurementTypes];
    CGFloat widthSize = node.width;
    CGFloat heightSize = node.height;
    CGSize imgSize = [node.targetView lua_measureSizeWithMaxWidth:maxWidth maxHeight:maxHeight];
    
    BOOL resizeWidth = NO;
    BOOL resizeHeight = NO;
    CGFloat desiredAspect = .0f;
    
    MLNLayoutMeasurementType widthSpecMode = node.mergedWidthType;
    MLNLayoutMeasurementType heightSpecMode= node.mergedHeightType;
    if (!CGSizeEqualToSize(imgSize, CGSizeZero)) {
        resizeWidth = widthSpecMode == MLNLayoutMeasurementTypeWrapContent;
        resizeHeight = heightSpecMode == MLNLayoutMeasurementTypeWrapContent;
        desiredAspect = imgSize.width / imgSize.height;
    }
    if (resizeWidth || resizeHeight) {
        if (!node.isWidthExcatly) {
            widthSize = resolveAdjustedSize(imgSize.width, node.maxWidth, node.width?:maxWidth, widthSpecMode);
        } else {
            widthSize = maxWidth;
        }
        
        if (!node.isHeightExcatly) {
            heightSize = resolveAdjustedSize(imgSize.height,node.maxHeight, node.height?:maxHeight, heightSpecMode);
        } else {
            heightSize = maxHeight;
        }
        
        // 按宽高比例重新计算
        CGFloat actualAspect = widthSize / heightSize;
        
        if (fabs(actualAspect - desiredAspect) >= 0.0000001) {
            BOOL done = NO;
            if (resizeWidth && heightSpecMode != MLNLayoutMeasurementTypeWrapContent) {
                CGFloat newWidth = desiredAspect * heightSize;
                if (!resizeHeight) {
                    widthSize = resolveAdjustedSize(newWidth, node.maxWidth?:MAXFLOAT, maxWidth, widthSpecMode);
                }
                if (newWidth <= widthSize) {
                    widthSize = newWidth;
                    done = true;
                }
            }
            
            if (!done && resizeHeight && widthSpecMode != MLNLayoutMeasurementTypeWrapContent) {
                CGFloat newHeight = widthSize / desiredAspect;
                if (!resizeWidth) {
                    heightSize = resolveAdjustedSize(newHeight, node.maxHeight?:MAXFLOAT, maxHeight, heightSpecMode);
                }
                if (newHeight <= heightSize) {
                    heightSize = newHeight;
                }
            }
        }
    } else {
        if (!node.isWidthExcatly) {
            CGFloat width = imgSize.width + node.paddingLeft + node.paddingRight;
            widthSize =  MAX(width, node.minWidth);
            widthSize = resolveSizeAndState(width, node.width?:maxWidth, widthSpecMode);
        } else {
            widthSize = maxWidth;
        }
        
        if (!node.isHeightExcatly) {
            CGFloat height = imgSize.height + node.paddingTop + node.paddingBottom;
            heightSize = MAX(height, node.minHeight);
            heightSize = resolveSizeAndState(height, node.height?:maxHeight, heightSpecMode);
        } else {
            heightSize = maxHeight;
        }
    }
    node.measuredWidth = widthSize;
    node.measuredHeight= heightSize;
}

MLN_FORCE_INLINE float resolveAdjustedSize(float desiredSize, float maxSize, float measureSize,MLNLayoutMeasurementType measureType)
{
    CGFloat result = desiredSize;
    switch (measureType) {
        case MLNLayoutMeasurementTypeWrapContent:
            result = MIN(desiredSize, measureSize);
            result = maxSize?MIN(result, maxSize):result;
            break;
        case MLNLayoutMeasurementTypeMatchParent:
        case MLNLayoutMeasurementTypeIdle:
            result = measureSize;
            break;
    }
    return result;
}

MLN_FORCE_INLINE float resolveSizeAndState(float desiredSize, float measureSize,MLNLayoutMeasurementType measureType) {
    CGFloat result = desiredSize;
    switch (measureType) {
        case MLNLayoutMeasurementTypeWrapContent:
            if (measureSize < desiredSize) {
                result = measureSize;
            } else {
                result = desiredSize;
            }
            break;
        case MLNLayoutMeasurementTypeMatchParent:
        case MLNLayoutMeasurementTypeIdle:
        default:
            result = measureSize;
    }
    return result;
}

@end
