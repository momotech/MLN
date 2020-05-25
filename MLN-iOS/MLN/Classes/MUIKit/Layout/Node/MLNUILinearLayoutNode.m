//
//  MLNUILinearLayoutNode.m
//
//
//  Created by MoMo on 2018/10/26.
//

#import "MLNUILinearLayoutNode.h"
#import "MLNUIKitHeader.h"
#import "UIView+MLNUILayout.h"

@interface MLNUILinearLayoutNode ()

@property (nonatomic, strong) NSArray<MLNUILayoutNode *> *prioritySubnodes;

@end
@implementation MLNUILinearLayoutNode

- (instancetype)initWithTargetView:(UIView *)targetView
{
    if (self = [super initWithTargetView:targetView]) {
        _direction = MLNUILayoutDirectionHorizontal;
    }
    return self;
}

#pragma mark - Measure
- (CGSize)measureSizeWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight
{
    if (self.isGone) {
        return CGSizeZero;
    }
    // 权重
    maxWidth = [self calculateWidthBaseOnWeightWithMaxWidth:maxWidth];
    maxHeight = [self calculateHeightBaseOnWeightWithMaxHeight:maxHeight];
    if (!self.isDirty && (self.lastMeasuredMaxWidth==maxWidth && self.lastMeasuredMaxHeight==maxHeight) &&  !isLayoutNodeHeightNeedMerge(self) && !isLayoutNodeWidthNeedMerge(self)) {
        return CGSizeMake(self.measuredWidth, self.measuredHeight);
    }
    self.lastMeasuredMaxWidth = maxWidth;
    self.lastMeasuredMaxHeight = maxHeight;
    [self mergeMeasurementTypes];
    resortingSubnodesIfNeed(self);
    switch (self.direction) {
        case MLNUILayoutDirectionVertical:
            measureVertical(self, maxWidth, maxHeight);
            break;
        default:
            measureHorizontal(self, maxWidth, maxHeight);
            break;
    }
    return CGSizeMake(self.measuredWidth, self.measuredHeight);
}

MLNUI_FORCE_INLINE void measureHorizontal(MLNUILinearLayoutNode __unsafe_unretained *node, CGFloat maxWidth, CGFloat maxHeight) {
    CGFloat myMaxWidth = [node myMaxWidthWithMaxWidth:maxWidth];
    CGFloat myMaxHeight = [node myMaxHeightWithMaxHeight:maxHeight];
    
    CGFloat usableZoneWidth = myMaxWidth - node.paddingLeft - node.paddingRight;
    CGFloat usableZoneHeight = myMaxHeight - node.paddingTop - node.paddingBottom;
    
    int totalWidth = 0;
    int needMaxHeight = 0;
    BOOL needDirty = NO;
    int totalWeight = 0;
    
    NSArray<MLNUILayoutNode *> *subnodes = node.prioritySubnodes;
    for (NSUInteger i  = 0; i < subnodes.count; i++) {
        MLNUILayoutNode *subnode = subnodes[i];
        if (subnode.isGone) {
            if (subnode.isDirty) {
                needDirty = YES;
            }
            continue;
        }
        if (subnode.weight > 0 && subnode.widthType != MLNUILayoutNodeStatusIdle) {
            totalWeight += subnode.weight;
        }
        if (subnode.isDirty) {
            needDirty = YES;
        } else if (needDirty) {
            [subnode needLayout];
        }
        CGFloat subMaxWidth = usableZoneWidth - totalWidth - subnode.marginLeft - subnode.marginRight;
        CGFloat subMaxHeight = usableZoneHeight - subnode.marginTop - subnode.marginBottom;
        CGSize subMeasuredSize = [subnode measureSizeWithMaxWidth:subMaxWidth maxHeight:subMaxHeight]; //计算子节点
        switch (subnode.layoutStrategy) {
            case MLNUILayoutStrategyNativeFrame:
                totalWidth = MAX(totalWidth, totalWidth +subMeasuredSize.width);
                needMaxHeight = MAX(needMaxHeight, subMeasuredSize.height);
                break;
            default: {
                totalWidth = MAX(totalWidth, totalWidth +subMeasuredSize.width +subnode.marginLeft +subnode.marginRight);
                needMaxHeight = MAX(needMaxHeight, subMeasuredSize.height +subnode.marginTop +subnode.marginBottom);
                break;
            }
        }
    }
    
    CGFloat measuredWidth = myMaxWidth;
    CGFloat measuredHeight = myMaxHeight;
    // width
    if (!node.isWidthExcatly) {
        switch (node.mergedWidthType) {
            case MLNUILayoutMeasurementTypeWrapContent:
                // padding
                totalWidth += node.paddingLeft +node.paddingRight;
                // min
                totalWidth = node.minWidth > 0 ? MAX(totalWidth, node.minWidth) : totalWidth;
                // max
                totalWidth = MIN(myMaxWidth, totalWidth);
                measuredWidth = totalWidth;
                break;
            case MLNUILayoutMeasurementTypeMatchParent:
                measuredWidth = MAX(node.minWidth, myMaxWidth);
                break;
            default:
                measuredWidth = myMaxWidth;
        }
    }
    // height
    if (!node.isHeightExcatly) {
        switch (node.mergedHeightType) {
            case MLNUILayoutMeasurementTypeWrapContent:
                // padding
                needMaxHeight += node.paddingTop +node.paddingBottom;
                // min
                needMaxHeight = node.minHeight > 0 ? MAX(needMaxHeight, node.minHeight) : needMaxHeight;
                // max
                needMaxHeight = MIN(myMaxHeight, needMaxHeight);
                measuredHeight = needMaxHeight;
                break;
            case MLNUILayoutMeasurementTypeMatchParent:
                measuredHeight = MAX(node.minHeight, myMaxHeight);
                break;
            default:
                measuredHeight = myMaxHeight;
        }
    }
    node.measuredWidth = measuredWidth;
    node.measuredHeight = measuredHeight;
    // measure weight
    if (totalWeight > 0) {
        measureHeightForWeightHorizontal(node, measuredWidth, myMaxHeight, totalWeight);
    }
}

// 只可能变高度-宽度不变
MLNUI_FORCE_INLINE void measureHeightForWeightHorizontal(MLNUILinearLayoutNode __unsafe_unretained *node, CGFloat measuredWidth, CGFloat maxHeight,  int totalWeight) {
    CGFloat measuredHeight = 0.f;
    CGFloat usableZoneWidth = measuredWidth - node.paddingLeft - node.paddingRight;
    CGFloat usableZoneHeight = maxHeight - node.paddingTop - node.paddingBottom;
    
    NSArray<MLNUILayoutNode *> *subnodes = node.prioritySubnodes;
    NSMutableArray<MLNUILayoutNode *> *proportionNodes = [NSMutableArray arrayWithCapacity:subnodes.count];
    for (NSUInteger i  = 0; i < subnodes.count; i++) {
        MLNUILayoutNode *subnode = subnodes[i];
        if (subnode.isGone) {
            continue;
        }
        CGFloat subWidth = 0.f;
        if (totalWeight > 0 && subnode.weight > 0 && subnode.widthType != MLNUILayoutNodeStatusIdle) {
            subnode.widthProportion = subnode.weight * 1.f / totalWeight * 1.f;
            [subnode needLayout];
            [proportionNodes addObject:subnode];
            totalWeight -= subnode.weight;
        } else{
            subWidth = subnode.measuredWidth;
        }
        switch (subnode.layoutStrategy) {
            case MLNUILayoutStrategyNativeFrame:
                usableZoneWidth -= subWidth;
                break;
            default: {
                usableZoneWidth -= subWidth + subnode.marginLeft +subnode.marginRight;
                break;
            }
        }
    }
    
    CGFloat needMaxHeight = 0.f;
    
    for (MLNUILayoutNode *subnode in proportionNodes) {
        CGFloat subMaxWidth = usableZoneWidth;
        CGFloat subMaxHeight = usableZoneHeight - subnode.marginTop - subnode.marginBottom;
        //计算子节点
        CGSize subMeasuredSize = [subnode measureSizeWithMaxWidth:subMaxWidth maxHeight:subMaxHeight];
        // 清空权重
        subnode.widthProportion = 0;
        usableZoneWidth -= subMeasuredSize.width;
        switch (subnode.layoutStrategy) {
            case MLNUILayoutStrategyNativeFrame:
                needMaxHeight = MAX(needMaxHeight, subMeasuredSize.height);
                break;
            default: {
                needMaxHeight = MAX(needMaxHeight, subMeasuredSize.height +subnode.marginTop +subnode.marginBottom);
                break;
            }
        }
    }
    // height
    if (!node.isHeightExcatly) {
        switch (node.mergedHeightType) {
            case MLNUILayoutMeasurementTypeWrapContent:
                // padding
                needMaxHeight += node.paddingTop +node.paddingBottom;
                // min
                needMaxHeight = MAX(needMaxHeight, node.minHeight);
                // max
                needMaxHeight = node.maxHeight > 0 ? MIN(node.maxHeight, needMaxHeight) : needMaxHeight;
                measuredHeight = needMaxHeight;
                break;
            case MLNUILayoutMeasurementTypeMatchParent:
                measuredHeight = MAX(node.minHeight, maxHeight);
                break;
            default:
                measuredHeight = maxHeight;
        }
        if (measuredHeight > node.measuredHeight) {
            node.measuredHeight = measuredHeight;
        }
    }
}


MLNUI_FORCE_INLINE void measureVertical(MLNUILinearLayoutNode __unsafe_unretained *node, CGFloat maxWidth, CGFloat maxHeight) {
    CGFloat myMaxWidth = [node myMaxWidthWithMaxWidth:maxWidth];
    CGFloat myMaxHeight = [node myMaxHeightWithMaxHeight:maxHeight];
    
    CGFloat usableZoneWidth = myMaxWidth - node.paddingLeft - node.paddingRight;
    CGFloat usableZoneHeight = myMaxHeight - node.paddingTop - node.paddingBottom;
    
    int totalHeight = 0;
    int needMaxWidth = 0;
    BOOL needDirty = NO;
    int totalWeight = 0;
    
    NSArray<MLNUILayoutNode *> *subnodes = node.prioritySubnodes;
    for (NSUInteger i  = 0; i < subnodes.count; i++) {
        MLNUILayoutNode *subnode = subnodes[i];
        if (subnode.isGone) {
            if (subnode.isDirty) {
                needDirty = YES;
            }
            continue;
        }
        if (subnode.weight > 0 && subnode.heightType != MLNUILayoutNodeStatusIdle) {
            totalWeight += subnode.weight;
        }
        if (subnode.isDirty) {
            needDirty = YES;
        } else if (needDirty) {
            [subnode needLayout];
        }
        CGFloat subMaxWidth = usableZoneWidth - subnode.marginLeft - subnode.marginRight;
        CGFloat subMaxHeight = usableZoneHeight - totalHeight - subnode.marginTop - subnode.marginBottom;
        CGSize subMeasuredSize = [subnode measureSizeWithMaxWidth:subMaxWidth maxHeight:subMaxHeight]; //计算子节点
        switch (subnode.layoutStrategy) {
            case MLNUILayoutStrategyNativeFrame:
                needMaxWidth = MAX(needMaxWidth, subMeasuredSize.width);
                totalHeight = MAX(totalHeight, totalHeight + subMeasuredSize.height);
                break;
            default: {
                needMaxWidth = MAX(needMaxWidth, subMeasuredSize.width +subnode.marginLeft +subnode.marginRight);
                totalHeight = MAX(totalHeight, totalHeight + subMeasuredSize.height + subnode.marginTop + subnode.marginBottom);
                break;
            }
        }
    }
    
    CGFloat measuredWidth = myMaxWidth;
    CGFloat measuredHeight = myMaxHeight;
    // width
    if (!node.isWidthExcatly) {
        switch (node.mergedWidthType) {
            case MLNUILayoutMeasurementTypeWrapContent:
                // padding
                needMaxWidth += node.paddingLeft +node.paddingRight;
                // max
                needMaxWidth = MIN(myMaxWidth, needMaxWidth);
                // min
                needMaxWidth = node.minWidth > 0 ? MAX(needMaxWidth, node.minWidth) : needMaxWidth;
                measuredWidth = needMaxWidth;
                break;
            case MLNUILayoutMeasurementTypeMatchParent:
                measuredWidth = MAX(node.minWidth, myMaxWidth);
                break;
            default:
                measuredWidth = myMaxWidth;
        }
    }
    
    // height
    if (!node.isHeightExcatly) {
        switch (node.mergedHeightType) {
            case MLNUILayoutMeasurementTypeWrapContent:
                // padding
                totalHeight += node.paddingTop +node.paddingBottom;
                // max
                totalHeight = MIN(myMaxHeight, totalHeight);
                // min
                totalHeight = node.minHeight > 0 ? MAX(totalHeight, node.minHeight) : totalHeight;
                measuredHeight = totalHeight;
                break;
            case MLNUILayoutMeasurementTypeMatchParent:
                measuredHeight = MAX(node.minHeight, myMaxHeight);
                break;
            default:
                measuredHeight = myMaxHeight;
        }
    }
    node.measuredWidth = measuredWidth;
    node.measuredHeight = measuredHeight;
    
    // measure weight
    if (totalWeight > 0) {
        measureWidthForWeightVertical(node, measuredWidth, measuredHeight, myMaxWidth, totalWeight);
    }
}

// 只可能变宽度-高度不变
MLNUI_FORCE_INLINE void measureWidthForWeightVertical(MLNUILinearLayoutNode __unsafe_unretained *node, CGFloat measuredWidth, CGFloat measuredHeight, CGFloat myMaxWidth,  int totalWeight) {
    CGFloat usableZoneWidth = myMaxWidth - node.paddingLeft - node.paddingRight;
    CGFloat usableZoneHeight = measuredHeight - node.paddingTop - node.paddingBottom;
    
    BOOL needDirty = NO;
    
    NSArray<MLNUILayoutNode *> *subnodes = node.prioritySubnodes;
    NSMutableArray<MLNUILayoutNode *> *proportionNodes = [NSMutableArray arrayWithCapacity:subnodes.count];
    for (NSUInteger i  = 0; i < subnodes.count; i++) {
        MLNUILayoutNode *subnode = subnodes[i];
        if (subnode.isGone) {
            continue;
        }
        CGFloat subHeight = 0.f;
        if (totalWeight > 0 && subnode.weight > 0 && subnode.heightType != MLNUILayoutNodeStatusIdle) {
            subnode.heightProportion = subnode.weight * 1.f / totalWeight * 1.f;
            needDirty = YES;
            [subnode needLayout];
            [proportionNodes addObject:subnode];
            totalWeight -= subnode.weight;
        } else{
            subHeight = subnode.measuredHeight;
        }
        switch (subnode.layoutStrategy) {
            case MLNUILayoutStrategyNativeFrame:
                usableZoneHeight -= subHeight;
                break;
            default: {
                usableZoneHeight -= subHeight + subnode.marginTop + subnode.marginBottom;
                break;
            }
        }
    }
    
    int needMaxWidth = 0.f;
    
    for (MLNUILayoutNode *subnode in proportionNodes) {
        CGFloat subMaxWidth = usableZoneWidth - subnode.marginLeft - subnode.marginRight;
        CGFloat subMaxHeight = usableZoneHeight;
        //计算子节点
        CGSize subMeasuredSize = [subnode measureSizeWithMaxWidth:subMaxWidth maxHeight:subMaxHeight];
        // 清空权重
        subnode.heightProportion = 0;
        usableZoneHeight -= subMeasuredSize.height;
        switch (subnode.layoutStrategy) {
            case MLNUILayoutStrategyNativeFrame:
                needMaxWidth = MAX(needMaxWidth, subMeasuredSize.width);
                break;
            default: {
                needMaxWidth = MAX(needMaxWidth, subMeasuredSize.width +subnode.marginLeft +subnode.marginRight);
                break;
            }
        }
    }
    
    // width
    if (!node.isWidthExcatly) {
        switch (node.mergedWidthType) {
            case MLNUILayoutMeasurementTypeWrapContent:
                // padding
                needMaxWidth += node.paddingLeft +node.paddingRight;
                // max
                needMaxWidth = MIN(measuredWidth, needMaxWidth);
                // min
                needMaxWidth = node.minWidth > 0 ? MAX(needMaxWidth, node.minWidth) : needMaxWidth;
                measuredWidth = needMaxWidth;
                break;
            case MLNUILayoutMeasurementTypeMatchParent:
                measuredWidth = MAX(node.minWidth, myMaxWidth);
                break;
            default:
                measuredWidth = myMaxWidth;
                break;
        }
        node.measuredWidth = measuredWidth;
    }
}

#pragma mark - Layout
- (void)layoutSubnodes
{
    if (self.isGone) {
        return;
    }
    switch (self.direction) {
        case MLNUILayoutDirectionVertical:
            layoutVertical(self);
            break;
        default:
            layoutHorizontal(self);
            break;
    }
}

MLNUI_FORCE_INLINE void layoutHorizontal(MLNUILinearLayoutNode __unsafe_unretained *node) {
    CGFloat maxX = node.paddingLeft;
    CGFloat layoutZoneHeight = node.measuredHeight - node.paddingTop - node.paddingBottom;
    CGFloat layoutZoneBottom = node.measuredHeight - node.paddingBottom;
    NSArray<MLNUILayoutNode *> *subnodes = node.subnodes;
    for (NSUInteger i  = 0; i < subnodes.count; i++) {
        MLNUILayoutNode *subnode = subnodes[i];
        if (subnode.isGone) {
            continue;
        }
        CGFloat childWidth = subnode.measuredWidth;
        CGFloat childHeight = subnode.measuredHeight;
        CGFloat childX = 0.f;
        // child's x
        maxX += subnode.marginLeft;
        childX = maxX;
        maxX += childWidth + subnode.marginRight;
        // child's y
        CGFloat childY = 0.f;
        switch (subnode.gravity & MLNUIGravityVerticalMask) {
            case MLNUIGravityCenterVertical:
                childY = node.paddingTop + (layoutZoneHeight - childHeight)*.5f + subnode.marginTop - subnode.marginBottom;
                break;
            case MLNUIGravityBottom:
                childY = layoutZoneBottom - childHeight - subnode.marginBottom;
                break;
            case MLNUIGravityTop:
            default:
                childY = node.paddingTop + subnode.marginTop;
                break;
        }
        // set frame
        subnode.measuredX = childX;
        subnode.measuredY = childY;
        [subnode updateTargetViewFrameIfNeed];
        if (subnode.isContainer) {
            [(MLNUILayoutContainerNode *)subnode layoutSubnodes];
        }
        if (subnode.overlayNode) {
            [subnode layoutOverlayNode];
        }
    }
}

MLNUI_FORCE_INLINE void layoutVertical(MLNUILinearLayoutNode __unsafe_unretained *node) {
    CGFloat maxY = node.paddingTop;
    CGFloat layoutZoneWidth = node.measuredWidth - node.paddingLeft - node.paddingRight;
    CGFloat layoutZoneRight = node.measuredWidth - node.paddingRight;
    NSArray<MLNUILayoutNode *> *subnodes = node.subnodes;
    for (NSUInteger i  = 0; i < subnodes.count; i++) {
        MLNUILayoutNode *subnode = subnodes[i];
        if (subnode.isGone) {
            continue;
        }
        // x
        CGFloat childX = 0.f;
        CGFloat childWidth = subnode.measuredWidth;
        CGFloat childHeight = subnode.measuredHeight;
        switch (subnode.gravity & MLNUIGravityHorizontalMask) {
            case MLNUIGravityCenterHorizontal:
                childX = node.paddingLeft + (layoutZoneWidth - childWidth)*.5f + subnode.marginLeft - subnode.marginRight;
                break;
            case MLNUIGravityRight:
                childX = layoutZoneRight - childWidth - subnode.marginRight;;
                break;
            case MLNUIGravityLeft:
            default:
                childX = node.paddingLeft + subnode.marginLeft;
                break;
        }
        CGFloat childY = 0.f;
        // y
        maxY += subnode.marginTop;
        childY = maxY;
        maxY += childHeight + subnode.marginBottom;
        // set frame
        subnode.measuredX = childX;
        subnode.measuredY = childY;
        [subnode updateTargetViewFrameIfNeed];
        if (subnode.isContainer) {
            [(MLNUILayoutContainerNode *)subnode layoutSubnodes];
        }
        if (subnode.overlayNode) {
            [subnode layoutOverlayNode];
        }
    }
}

#pragma mark - Sort
static MLNUI_FORCE_INLINE void resortingSubnodesIfNeed(MLNUILinearLayoutNode __unsafe_unretained *node) {
    if (node.needSorting) {
        NSArray<MLNUILayoutNode *> *subnodes = node.subnodes;
        NSUInteger count = subnodes.count;
        node.prioritySubnodes = subnodes;
        if (count > 1) {
            NSMutableArray<MLNUILayoutNode *> *nodes_m = [NSMutableArray arrayWithArray:subnodes];
            if (count == 2) {
                if ([nodes_m firstObject].measurePriority < [nodes_m lastObject].measurePriority) {
                    [nodes_m exchangeObjectAtIndex:0 withObjectAtIndex:1];
                }
            } else {
                quickSort(node, nodes_m, 0, nodes_m.count-1);
            }
            node.prioritySubnodes = [nodes_m copy];
        }
        node.needSorting = NO;
    } else if (!node.prioritySubnodes) {
        node.prioritySubnodes = node.subnodes;
    }
}

static MLNUI_FORCE_INLINE void quickSort(MLNUILinearLayoutNode __unsafe_unretained *node, NSMutableArray<MLNUILayoutNode *> __unsafe_unretained *nodes_m, NSUInteger head, NSUInteger tail) {
    if (head >= tail || nodes_m.count <2) {
        return;
    }
    NSUInteger i = head, j = tail;
    NSUInteger base = head;
    MLNUILayoutNode *baseNode = nodes_m[base]; // 基准
    while (i < j) {
        // right
        while (baseNode.measurePriority >= nodes_m[j].measurePriority && i < j)
            j--;
        // left
        while (baseNode.measurePriority <= nodes_m[i].measurePriority && i < j)
            i++;
        if (i < j) {
            // swap
            [nodes_m exchangeObjectAtIndex:i withObjectAtIndex:j];
        }
    }
    if (i == j) {
        [nodes_m exchangeObjectAtIndex:i withObjectAtIndex:base];
    }
    if (i > 0 && i-1 > head) {
        quickSort(node, nodes_m, head, i-1);
    }
    if (j < nodes_m.count -1 && j+1 < tail) {
        quickSort(node, nodes_m, j+1, tail);
    }
}

@end
