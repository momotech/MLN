//
//  MLNUILayoutContainerNode.m
//
//
//  Created by MoMo on 2018/10/29.
//

#import "MLNUILayoutContainerNode.h"
#import "UIView+MLNUILayout.h"

@interface MLNUILayoutContainerNode ()

@property (nonatomic, strong) NSMutableArray<MLNUILayoutNode *> *subNodes_m;

@end
@implementation MLNUILayoutContainerNode

#pragma mark - Override
- (BOOL)isContainer
{
    return YES;
}

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
    CGFloat usableZoneWidth = myMaxWidth - self.paddingLeft - self.paddingRight;
    CGFloat usableZoneHeight = myMaxHeight - self.paddingTop - self.paddingBottom;
    
    NSMutableArray<MLNUILayoutNode *> *measureMatchParentNodes = [NSMutableArray arrayWithCapacity:self.subnodes.count];
    NSArray<MLNUILayoutNode *> *subnodes_t = self.subnodes;
    for (NSUInteger i = 0; i < subnodes_t.count; i++) {
        MLNUILayoutNode *subnode = subnodes_t[i];
        if (subnode.isGone) {
            continue;
        }
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
                    myMeasuredWidth = MAX(myMeasuredWidth, subMeasuredSize.width +subnode.x+self.paddingLeft +self.paddingRight);
                    break;
                default: {
                    myMeasuredWidth = MAX(myMeasuredWidth, subMeasuredSize.width +subnode.marginLeft +subnode.marginRight +self.paddingLeft +self.paddingRight);
                    break;
                }
            }
        }
        // calculate height
        if (heightWrapContent) {
            switch (subnode.layoutStrategy) {
                case MLNUILayoutStrategyNativeFrame:
                     myMeasuredHeight = MAX(myMeasuredHeight, subMeasuredSize.height +subnode.y +self.paddingTop +self.paddingBottom);
                    break;
                default:
                     myMeasuredHeight = MAX(myMeasuredHeight, subMeasuredSize.height +subnode.marginTop +subnode.marginBottom +self.paddingTop +self.paddingBottom);
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
    
    // resize match parent nodes
    if (measureMatchParentNodes.count > 1) {
        for (MLNUILayoutNode *subnode in measureMatchParentNodes) {
            CGFloat usableZoneWidth = self.measuredWidth - self.paddingLeft - self.paddingRight;
            CGFloat usableZoneHeight = self.measuredHeight - self.paddingTop - self.paddingBottom;
            CGFloat subMaxWidth = usableZoneWidth - subnode.marginLeft - subnode.marginRight;
            CGFloat subMaxHeight = usableZoneHeight - subnode.marginTop - subnode.marginBottom;
            [subnode measureSizeLightMatchParentWithMaxWidth:subMaxWidth maxHeight:subMaxHeight];
        }
    }
    
    return CGSizeMake(self.measuredWidth, self.measuredHeight);
}

#pragma mark - Node Tree
- (void)addSubnode:(MLNUILayoutNode *)subNode
{
    if (subNode.supernode) {
        [subNode removeFromSupernode];
    }
    if (subNode && ![self.subNodes_m containsObject:subNode] && !subNode.supernode) {
        [subNode bindSuper:self];
        subNode.idx = self.subNodes_m.count;
        [self.subNodes_m addObject:subNode];
        [self needLayoutAndSpread];
        self.needSorting = YES;
    }
}

- (void)insertSubnode:(MLNUILayoutNode *)subNode atIndex:(NSUInteger)index
{
    if (subNode.supernode) {
        [subNode removeFromSupernode];
    }
    if (subNode && ![self.subNodes_m containsObject:subNode] && !subNode.supernode) {
        index = index >= self.subnodes.count ? self.subnodes.count : index;
        [self.subNodes_m insertObject:subNode atIndex:index];
        [subNode bindSuper:self];
        [self needLayoutAndSpread];
        self.needSorting = YES;
    }
}

- (void)removeSubnode:(MLNUILayoutNode *)subNode
{
    if (subNode && [self.subNodes_m containsObject:subNode]) {
        [self.subNodes_m removeObject:subNode];
        [subNode unbind];
        [self needLayoutAndSpread];
        self.needSorting = YES;
    }
}

- (void)removeAllSubnodes
{
    while (self.subNodes_m.count > 0) {
        [self removeSubnode:[self.subNodes_m lastObject]];
    }
}

#pragma mark - Layout
- (void)requestLayout
{
    if (self.isRoot) {
        if (self.isDirty) {
            [self onMeasure];
            [self onLayout];
        }
    } else {
        [super requestLayout];
    }
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

- (void)onLayout
{
    [self updateTargetViewFrameIfNeed];
    [self layoutSubnodes];
    [self layoutOverlayNode];
}

- (void)layoutSubnodes
{
    CGFloat layoutZoneWidth = self.measuredWidth - self.paddingLeft - self.paddingRight;
    CGFloat layoutZoneHeight = self.measuredHeight - self.paddingTop - self.paddingBottom;
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
                     subnode.measuredX = self.paddingLeft + (layoutZoneWidth - subnode.measuredWidth) *0.5 + subnode.marginLeft - subnode.marginRight;
                     break;
                 case MLNUIGravityRight:
                     subnode.measuredX = self.measuredWidth -self.paddingRight -subnode.measuredWidth -subnode.marginRight;
                     break;
                 case MLNUIGravityLeft:
                 default:
                     subnode.measuredX = self.paddingLeft + subnode.marginLeft;
                     break;
             }
             // vertical
             switch (subnode.gravity & MLNUIGravityVerticalMask) {
                 case MLNUIGravityCenterVertical:
                     subnode.measuredY = self.paddingTop +(layoutZoneHeight -subnode.measuredHeight) *0.5 +subnode.marginTop -subnode.marginBottom;
                     break;
                 case MLNUIGravityBottom:
                     subnode.measuredY = self.measuredHeight -self.paddingBottom -subnode.measuredHeight -subnode.marginBottom;
                     break;
                 case MLNUIGravityTop:
                 default:
                     subnode.measuredY = self.paddingTop + subnode.marginTop;
                     break;
             }
         }
}

#pragma mark - Getter
- (NSMutableArray<MLNUILayoutNode *> *)subNodes_m
{
    if (!_subNodes_m) {
        if (!_subNodes_m) {
            _subNodes_m = [NSMutableArray array];
        }
    }
    return _subNodes_m;
}

- (NSArray<MLNUILayoutNode *> *)subnodes
{
    return [self.subNodes_m copy];
}

@end
