//
//  MLNUILayoutWindowNode.m
//  MoMo
//
//  Created by MOMO on 2019/11/6.
//

#import "MLNUILayoutWindowNode.h"

@implementation MLNUILayoutWindowNode

- (CGSize)measureSizeWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight
{
    if (self.isGone) {
        return CGSizeZero;
    }
    // 权重
    maxWidth = [self calculateWidthBaseOnWeightWithMaxWidth:maxWidth];
    maxHeight = [self calculateHeightBaseOnWeightWithMaxHeight:maxHeight];
    if (!self.isDirty && (self.lastMeasuredMaxWidth==maxWidth && self.lastMeasuredMaxHeight==maxHeight) && !isLayoutNodeHeightNeedMerge(self) && !isLayoutNodeWidthNeedMerge(self)) {
        return CGSizeMake(self.measuredWidth, self.measuredHeight);
    }
    self.lastMeasuredMaxWidth = maxWidth;
    self.lastMeasuredMaxHeight = maxHeight;
    [self mergeMeasurementTypes];
    BOOL widthWrapContent = self.mergedWidthType == MLNUILayoutMeasurementTypeWrapContent;
    BOOL heightWrapContent = self.mergedHeightType == MLNUILayoutMeasurementTypeWrapContent;
    CGFloat myMaxWidth = [self myMaxWidthWithMaxWidth:maxWidth];
    CGFloat myMaxHeight = [self myMaxHeightWithMaxHeight:maxHeight];
    
    CGFloat myMeasuredWidth = 0.f;
    CGFloat myMeasuredHeight = 0.f;
    CGFloat usableZoneWidth = myMaxWidth - self.paddingLeft - self.paddingRight - self.safeAreaInsets.left - self.safeAreaInsets.right;
    CGFloat usableZoneHeight = myMaxHeight - self.paddingTop - self.paddingBottom - self.safeAreaInsets.top - self.safeAreaInsets.bottom;
    
    NSMutableArray<MLNUILayoutNode *> *measureMatchParentNodes = [NSMutableArray arrayWithCapacity:self.subnodes.count];
    NSArray<MLNUILayoutNode *> *subnodes_t = self.subnodes;
    for (NSUInteger i = 0; i < subnodes_t.count; i++) {
        MLNUILayoutNode *subnode = subnodes_t[i];
        // need resize for match parent node
        if (subnode.widthType == MLNUILayoutMeasurementTypeMatchParent ||
            subnode.heightType == MLNUILayoutMeasurementTypeMatchParent) {
            [measureMatchParentNodes addObject:subnode];
        }
        CGFloat subMaxWidth = usableZoneWidth - subnode.marginLeft - subnode.marginRight;
        CGFloat subMaxHeight = usableZoneHeight - subnode.marginTop - subnode.marginBottom;
        CGSize subMeasuredSize = [subnode measureSizeWithMaxWidth:subMaxWidth maxHeight:subMaxHeight];
        // calculate width
        if (widthWrapContent) {
            switch (subnode.layoutStrategy) {
                case MLNUILayoutStrategyNativeFrame:
                    myMeasuredWidth = MAX(myMeasuredWidth, subMeasuredSize.width +subnode.x+self.paddingLeft +self.paddingRight + self.safeAreaInsets.left + self.safeAreaInsets.right);
                    break;
                default: {
                    myMeasuredWidth = MAX(myMeasuredWidth, subMeasuredSize.width +subnode.marginLeft +subnode.marginRight +self.paddingLeft +self.paddingRight + self.safeAreaInsets.left + self.safeAreaInsets.right);
                    break;
                }
            }
        }
        // calculate height
        if (heightWrapContent) {
            switch (subnode.layoutStrategy) {
                case MLNUILayoutStrategyNativeFrame:
                    myMeasuredHeight = MAX(myMeasuredHeight, subMeasuredSize.height +subnode.y +self.paddingTop +self.paddingBottom + self.safeAreaInsets.top + self.safeAreaInsets.bottom);
                    break;
                default:
                    myMeasuredHeight = MAX(myMeasuredHeight, subMeasuredSize.height +subnode.marginTop +subnode.marginBottom +self.paddingTop +self.paddingBottom + self.safeAreaInsets.top + self.safeAreaInsets.bottom);
                    break;
            }
            
        }
    }
    // width
    if (!self.isWidthExcatly) {
        switch (self.mergedWidthType) {
            case MLNUILayoutMeasurementTypeWrapContent:
                myMeasuredWidth = MAX(self.minWidth, myMeasuredWidth);
                myMeasuredWidth = self.maxWidth > 0 ? MIN(myMeasuredWidth, self.maxWidth) : myMeasuredWidth;
                self.measuredWidth = myMeasuredWidth;
                break;
            case MLNUILayoutMeasurementTypeMatchParent:
                self.measuredWidth = MAX(self.minWidth, myMaxWidth);
                break;
            default:
                self.measuredWidth = myMaxWidth;
        }
    } else {
        self.measuredWidth = maxWidth;
    }
    
    
    // height
    if (!self.isHeightExcatly) {
        switch (self.mergedHeightType) {
            case MLNUILayoutMeasurementTypeWrapContent:
                myMeasuredHeight = MAX(self.minHeight, myMeasuredHeight);
                myMeasuredHeight = self.maxHeight > 0 ? MIN(myMeasuredHeight, self.maxHeight) : myMeasuredHeight;
                self.measuredHeight = myMeasuredHeight;
                break;
            case MLNUILayoutMeasurementTypeMatchParent:
                self.measuredHeight = MAX(self.minHeight, myMaxHeight);
                break;
            default:
                self.measuredHeight = myMaxHeight;
        }
    } else {
        self.measuredHeight = maxHeight;
    }
    // resize match parent nodes if need
    if (measureMatchParentNodes.count > 1) {
        for (MLNUILayoutNode *subnode in measureMatchParentNodes) {
            CGFloat usableZoneWidth = self.measuredWidth - self.paddingLeft - self.paddingRight - self.safeAreaInsets.left - self.safeAreaInsets.right;
            CGFloat usableZoneHeight = self.measuredHeight - self.paddingTop - self.paddingBottom - self.safeAreaInsets.top - self.safeAreaInsets.bottom;
            CGFloat subMaxWidth = usableZoneWidth - subnode.marginLeft - subnode.marginRight;
            CGFloat subMaxHeight = usableZoneHeight - subnode.marginTop - subnode.marginBottom;
            [subnode measureSizeLightMatchParentWithMaxWidth:subMaxWidth maxHeight:subMaxHeight];
        }
    }
    
    return CGSizeMake(self.measuredWidth, self.measuredHeight);
}

- (void)layoutSubnodes
{
    CGFloat layoutZoneWidth = self.measuredWidth - self.paddingLeft - self.paddingRight - self.safeAreaInsets.left - self.safeAreaInsets.right;
    CGFloat layoutZoneHeight = self.measuredHeight - self.paddingTop - self.paddingBottom - self.safeAreaInsets.top - self.safeAreaInsets.bottom;
    for (MLNUILayoutNode *subnode in self.subnodes) {
        if (subnode.isGone) {
            continue;
        }
        switch (subnode.layoutStrategy) {
            case MLNUILayoutStrategyNativeFrame:
                subnode.measuredX = subnode.x;
                subnode.measuredY = subnode.y;
                break;
            case MLNUILayoutStrategySimapleAuto:
                [self layoutSimapleAutoSubnode:subnode layoutZoneWidth:layoutZoneWidth layoutZoneHeight:layoutZoneHeight];
                break;
            default:
                break;
        }
        [subnode updateTargetViewFrameIfNeed];
        if (subnode.isContainer) {
            [(MLNUILayoutContainerNode *)subnode layoutSubnodes];
        }
        if (subnode.overlayNode) {
            [subnode layoutOverlayNode];
        }
    }
}

- (void)layoutSimapleAutoSubnode:(MLNUILayoutNode *)subnode layoutZoneWidth:(CGFloat)layoutZoneWidth layoutZoneHeight:(CGFloat)layoutZoneHeight
{
    if ((subnode.isDirty ||
         subnode.hasNewLayout ||
         !(subnode.lastGravityZoneWidth == layoutZoneWidth &&
           subnode.lastGravityZoneHeight == layoutZoneHeight))) {
             subnode.lastGravityZoneWidth = layoutZoneWidth;
             subnode.lastGravityZoneHeight = layoutZoneHeight;
             // horizontal
             switch (subnode.gravity & MLNUIGravityHorizontalMask) {
                 case MLNUIGravityCenterHorizontal:
                     subnode.measuredX = self.paddingLeft + self.safeAreaInsets.left + (layoutZoneWidth - subnode.measuredWidth) *0.5 + subnode.marginLeft - subnode.marginRight;
                     break;
                 case MLNUIGravityRight:
                     subnode.measuredX = self.measuredWidth - self.paddingRight - self.safeAreaInsets.right - subnode.measuredWidth - subnode.marginRight;
                     break;
                 case MLNUIGravityLeft:
                 default:
                     subnode.measuredX = self.paddingLeft + self.safeAreaInsets.left + subnode.marginLeft;
                     break;
             }
             // vertical
             switch (subnode.gravity & MLNUIGravityVerticalMask) {
                 case MLNUIGravityCenterVertical:
                     subnode.measuredY = self.paddingTop + self.safeAreaInsets.top +(layoutZoneHeight -subnode.measuredHeight) *0.5 +subnode.marginTop -subnode.marginBottom;
                     break;
                 case MLNUIGravityBottom:
                     subnode.measuredY = self.measuredHeight - self.paddingBottom - self.safeAreaInsets.bottom - subnode.measuredHeight - subnode.marginBottom;
                     break;
                 case MLNUIGravityTop:
                 default:
                     subnode.measuredY = self.paddingTop + self.safeAreaInsets.top + subnode.marginTop;
                     break;
             }
         }
}

- (void)setSafeAreaInsets:(UIEdgeInsets)safeAreaInset
{
    if (!UIEdgeInsetsEqualToEdgeInsets(_safeAreaInsets, safeAreaInset)) {
        _safeAreaInsets = safeAreaInset;
        [self needLayoutAndSpread];
    }
}

@end
