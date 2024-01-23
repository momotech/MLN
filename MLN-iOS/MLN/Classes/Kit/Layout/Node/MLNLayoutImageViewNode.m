//
//  MLNLayoutImageViewNode.m
//  MLN
//
//  Created by MoMo on 2019/10/29.
//

#import "MLNLayoutImageViewNode.h"
#import "MLNKitHeader.h"
#import "UIView+MLNLayout.h"
#import "MLNLayoutContainerNode.h"
#import "UIView+MLNKit.h"
#import "MLNLayoutImageViewNode.h"
#import "UIView+MLNLayout.h"
#import "MLNKitHeader.h"

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
    if (self.overlayNode) {
        CGFloat overlayMaxWidth = self.measuredWidth - self.overlayNode.marginLeft - self.overlayNode.marginRight;
        CGFloat overlayMaxHeight = self.measuredHeight - self.overlayNode.marginTop - self.overlayNode.marginBottom;
        [self.overlayNode measureSizeWithMaxWidth:overlayMaxWidth maxHeight:overlayMaxHeight];
    }
    return CGSizeMake(self.measuredWidth, self.measuredHeight);
}

MLN_FORCE_INLINE void measureImageViewAutoNodeSize (MLNLayoutNode __unsafe_unretained *node, CGFloat maxWidth, CGFloat maxHeight) {
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
            if (resizeWidth && heightSpecMode != MLNLayoutMeasurementTypeWrapContent) {
                CGFloat newWidth = desiredAspect * heightSize;
                if (!resizeHeight) {
                    widthSize = resolveAdjustedSize(newWidth, maxWidth, node.width>=0 ? node.width : 0 , widthSpecMode);
                }
                if (newWidth <= widthSize) {
                    widthSize = newWidth;
                    done = true;
                }
            }
            
            if (!done && resizeHeight && widthSpecMode != MLNLayoutMeasurementTypeWrapContent) {
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

MLN_FORCE_INLINE float resolveAdjustedSize(float desiredSize, float maxSize, float measureSize,MLNLayoutMeasurementType measureType)
{
    CGFloat result = desiredSize;
    switch (measureType) {
        case MLNLayoutMeasurementTypeWrapContent:
            result = MIN(desiredSize, maxSize);
            break;
        case MLNLayoutMeasurementTypeMatchParent:
            result = maxSize;
            break;
        case MLNLayoutMeasurementTypeIdle:
            result = measureSize;
            break;
    }
    return result;
}

MLN_FORCE_INLINE float resolveSizeAndState(float measureSize, float maxSize  , MLNLayoutMeasurementType measureType) {
    CGFloat result = measureSize;
    switch (measureType) {
        case MLNLayoutMeasurementTypeMatchParent:
            result = maxSize;
            break;
        case MLNLayoutMeasurementTypeWrapContent:
        case MLNLayoutMeasurementTypeIdle:
        default:
            result = measureSize;
    }
    return result;
}

@end
