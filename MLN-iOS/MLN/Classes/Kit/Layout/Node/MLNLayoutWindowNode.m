//
//  MLNLayoutWindowNode.m
//  MoMo
//
//  Created by MOMO on 2019/11/6.
//

#import "MLNLayoutWindowNode.h"

@implementation MLNLayoutWindowNode

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
    BOOL widthWrapContent = self.mergedWidthType == MLNLayoutMeasurementTypeWrapContent;
    BOOL heightWrapContent = self.mergedHeightType == MLNLayoutMeasurementTypeWrapContent;
    CGFloat myMaxWidth = [self myMaxWidthWithMaxWidth:maxWidth];
    CGFloat myMaxHeight = [self myMaxHeightWithMaxHeight:maxHeight];
    
    CGFloat myMeasuredWidth = 0.f;
    CGFloat myMeasuredHeight = 0.f;
    CGFloat usableZoneWidth = myMaxWidth - self.paddingLeft - self.paddingRight - self.safeAreaInset.left - self.safeAreaInset.right;
    CGFloat usableZoneHeight = myMaxHeight - self.paddingTop - self.paddingBottom - self.safeAreaInset.top - self.safeAreaInset.bottom;
    
    NSMutableArray<MLNLayoutNode *> *measureMatchParentNodes = [NSMutableArray arrayWithCapacity:self.subnodes.count];
    NSArray<MLNLayoutNode *> *subnodes_t = self.subnodes;
    for (NSUInteger i = 0; i < subnodes_t.count; i++) {
        MLNLayoutNode *subnode = subnodes_t[i];
        // need resize for match parent node
        if (subnode.widthType == MLNLayoutMeasurementTypeMatchParent ||
            subnode.heightType == MLNLayoutMeasurementTypeMatchParent) {
            [measureMatchParentNodes addObject:subnode];
        }
        CGFloat subMaxWidth = usableZoneWidth - subnode.marginLeft - subnode.marginRight;
        CGFloat subMaxHeight = usableZoneHeight - subnode.marginTop - subnode.marginBottom;
        CGSize subMeasuredSize = [subnode measureSizeWithMaxWidth:subMaxWidth maxHeight:subMaxHeight];
        // calculate width
        if (widthWrapContent) {
            switch (subnode.layoutStrategy) {
                case MLNLayoutStrategyNativeFrame:
                    myMeasuredWidth = MAX(myMeasuredWidth, subMeasuredSize.width +subnode.x+self.paddingLeft +self.paddingRight + self.safeAreaInset.left + self.safeAreaInset.right);
                    break;
                default: {
                    myMeasuredWidth = MAX(myMeasuredWidth, subMeasuredSize.width +subnode.marginLeft +subnode.marginRight +self.paddingLeft +self.paddingRight + self.safeAreaInset.left + self.safeAreaInset.right);
                    break;
                }
            }
        }
        // calculate height
        if (heightWrapContent) {
            switch (subnode.layoutStrategy) {
                case MLNLayoutStrategyNativeFrame:
                    myMeasuredHeight = MAX(myMeasuredHeight, subMeasuredSize.height +subnode.y +self.paddingTop +self.paddingBottom + self.safeAreaInset.top + self.safeAreaInset.bottom);
                    break;
                default:
                    myMeasuredHeight = MAX(myMeasuredHeight, subMeasuredSize.height +subnode.marginTop +subnode.marginBottom +self.paddingTop +self.paddingBottom + self.safeAreaInset.top + self.safeAreaInset.bottom);
                    break;
            }
            
        }
    }
    // width
    if (!self.isWidthExcatly) {
        switch (self.mergedWidthType) {
            case MLNLayoutMeasurementTypeWrapContent:
                myMeasuredWidth = MAX(self.minWidth, myMeasuredWidth);
                myMeasuredWidth = self.maxWidth > 0 ? MIN(myMeasuredWidth, self.maxWidth) : myMeasuredWidth;
                self.measuredWidth = myMeasuredWidth;
                break;
            case MLNLayoutMeasurementTypeMatchParent:
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
            case MLNLayoutMeasurementTypeWrapContent:
                myMeasuredHeight = MAX(self.minHeight, myMeasuredHeight);
                myMeasuredHeight = self.maxHeight > 0 ? MIN(myMeasuredHeight, self.maxHeight) : myMeasuredHeight;
                self.measuredHeight = myMeasuredHeight;
                break;
            case MLNLayoutMeasurementTypeMatchParent:
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
        for (MLNLayoutNode *subnode in measureMatchParentNodes) {
            CGFloat usableZoneWidth = self.measuredWidth - self.paddingLeft - self.paddingRight - self.safeAreaInset.left - self.safeAreaInset.right;
            CGFloat usableZoneHeight = self.measuredHeight - self.paddingTop - self.paddingBottom - self.safeAreaInset.top - self.safeAreaInset.bottom;
            CGFloat subMaxWidth = usableZoneWidth - subnode.marginLeft - subnode.marginRight;
            CGFloat subMaxHeight = usableZoneHeight - subnode.marginTop - subnode.marginBottom;
            [subnode measureSizeLightMatchParentWithMaxWidth:subMaxWidth maxHeight:subMaxHeight];
        }
    }
    return CGSizeMake(self.measuredWidth, self.measuredHeight);
}

- (void)onMeasure
{
    CGFloat superWidth = self.supernode.width > 0 ? self.supernode.width : (self.targetView.superview.frame.size.width - self.supernode.offsetWidth);
    CGFloat superHeight = self.supernode.height > 0 ? self.supernode.height : (self.targetView.superview.frame.size.height - self.supernode.offsetWidth);
    CGFloat usableZoneWidth = superWidth - self.supernode.paddingLeft - self.supernode.paddingRight;
    CGFloat usableZoneHeight = superHeight - self.supernode.paddingTop - self.supernode.paddingBottom;
    [self onMeasureWithMaxWidth:usableZoneWidth maxHeight:usableZoneHeight];
}

- (void)onMeasureWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight
{
    if (self.enable) {
        maxWidth -= self.marginLeft + self.marginRight;
        maxHeight -= self.marginTop + self.marginBottom;
    }
    [self measureSizeWithMaxWidth:maxWidth maxHeight:maxHeight];
}

- (void)layoutSubnodes
{
    CGFloat layoutZoneWidth = self.measuredWidth - self.paddingLeft - self.paddingRight - self.safeAreaInset.left - self.safeAreaInset.right;
    CGFloat layoutZoneHeight = self.measuredHeight - self.paddingTop - self.paddingBottom - self.safeAreaInset.top - self.safeAreaInset.bottom;
    for (MLNLayoutNode *subnode in self.subnodes) {
        if (subnode.isGone) {
            continue;
        }
        switch (subnode.layoutStrategy) {
            case MLNLayoutStrategyNativeFrame:
                subnode.measuredX = subnode.x;
                subnode.measuredY = subnode.y;
                break;
            case MLNLayoutStrategySimapleAuto:
                [self layoutSimapleAutoSubnode:subnode layoutZoneWidth:layoutZoneWidth layoutZoneHeight:layoutZoneHeight];
                break;
            default:
                break;
        }
        [subnode updateTargetViewFrameIfNeed];
        if (subnode.isContainer) {
            [(MLNLayoutContainerNode *)subnode layoutSubnodes];
        }
    }
}

- (void)layoutSimapleAutoSubnode:(MLNLayoutNode *)subnode layoutZoneWidth:(CGFloat)layoutZoneWidth layoutZoneHeight:(CGFloat)layoutZoneHeight
{
    if ((subnode.isDirty ||
         subnode.hasNewLayout ||
         !(subnode.lastGravityZoneWidth == layoutZoneWidth &&
           subnode.lastGravityZoneHeight == layoutZoneHeight))) {
             subnode.lastGravityZoneWidth = layoutZoneWidth;
             subnode.lastGravityZoneHeight = layoutZoneHeight;
             // horizontal
             switch (subnode.gravity & MLNGravityHorizontalMask) {
                 case MLNGravityCenterHorizontal:
                     subnode.measuredX = self.paddingLeft + self.safeAreaInset.left + (layoutZoneWidth - subnode.measuredWidth) *0.5 + subnode.marginLeft - subnode.marginRight;
                     break;
                 case MLNGravityRight:
                     subnode.measuredX = self.measuredWidth - self.paddingRight - self.safeAreaInset.right - subnode.measuredWidth - subnode.marginRight;
                     break;
                 case MLNGravityLeft:
                 default:
                     subnode.measuredX = self.paddingLeft + self.safeAreaInset.left + subnode.marginLeft;
                     break;
             }
             // vertical
             switch (subnode.gravity & MLNGravityVerticalMask) {
                 case MLNGravityCenterVertical:
                     subnode.measuredY = self.paddingTop + self.safeAreaInset.top +(layoutZoneHeight -subnode.measuredHeight) *0.5 +subnode.marginTop -subnode.marginBottom;
                     break;
                 case MLNGravityBottom:
                     subnode.measuredY = self.measuredHeight - self.paddingBottom - self.safeAreaInset.bottom - subnode.measuredHeight - subnode.marginBottom;
                     break;
                 case MLNGravityTop:
                 default:
                     subnode.measuredY = self.paddingTop + self.safeAreaInset.top + subnode.marginTop;
                     break;
             }
         }
}

- (void)setSafeAreaInset:(UIEdgeInsets)safeAreaInset
{
    if (!UIEdgeInsetsEqualToEdgeInsets(_safeAreaInset, safeAreaInset)) {
        _safeAreaInset = safeAreaInset;
        [self needLayoutAndSpread];
    }
}

@end
