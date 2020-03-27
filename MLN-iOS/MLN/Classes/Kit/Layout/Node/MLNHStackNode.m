//
//  MLNHStackNode.m
//  MLN
//
//  Created by MOMO on 2020/3/25.
//

#import "MLNHStackNode.h"
#import "MLNHeader.h"

@implementation MLNHStackNode

#pragma mark - Override

- (CGSize)measureSubNodes:(NSArray<MLNLayoutNode *> *)subNods maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight {
    
    CGFloat myMaxWidth = [self myMaxWidthWithMaxWidth:maxWidth];
    CGFloat myMaxHeight = [self myMaxHeightWithMaxHeight:maxHeight];
    
    CGFloat usableZoneWidth = myMaxWidth - self.paddingLeft - self.paddingRight;
    CGFloat usableZoneHeight = myMaxHeight - self.paddingTop - self.paddingBottom;
    
    int totalWidth = 0;
    int needMaxHeight = 0;
    BOOL needDirty = NO;
    int totalWeight = 0;
    
    for (NSUInteger i  = 0; i < subNods.count; i++) {
        MLNLayoutNode *subnode = subNods[i];
        if (subnode.isGone) {
            if (subnode.isDirty) {
                needDirty = YES;
            }
            continue;
        }
        if (subnode.weight > 0 && subnode.widthType != MLNLayoutNodeStatusIdle) {
            totalWeight += subnode.weight;
        }
        if (subnode.isDirty) {
            needDirty = YES;
        } else if (needDirty) {
            [subnode needLayout];
        }
        CGFloat subMaxWidth = usableZoneWidth - totalWidth - subnode.marginLeft - subnode.marginRight;
        CGFloat subMaxHeight = usableZoneHeight - subnode.marginTop - subnode.marginBottom;
        CGSize subMeasuredSize = [subnode measureSizeWithMaxWidth:subMaxWidth maxHeight:subMaxHeight]; // 计算子节点
        switch (subnode.layoutStrategy) {
            case MLNLayoutStrategyNativeFrame:
                totalWidth = MAX(totalWidth, totalWidth + subMeasuredSize.width);
                needMaxHeight = MAX(needMaxHeight, subMeasuredSize.height);
                break;
            default: {
                totalWidth = MAX(totalWidth, totalWidth + subMeasuredSize.width + subnode.marginLeft + subnode.marginRight);
                needMaxHeight = MAX(needMaxHeight, subMeasuredSize.height + subnode.marginTop + subnode.marginBottom);
                break;
            }
        }
    }
    
    CGFloat measuredWidth = myMaxWidth;
    CGFloat measuredHeight = myMaxHeight;
    // width
    if (!self.isWidthExcatly) {
        switch (self.mergedWidthType) {
            case MLNLayoutMeasurementTypeWrapContent:
                // padding
                totalWidth += self.paddingLeft + self.paddingRight;
                // min
                totalWidth = self.minWidth > 0 ? MAX(totalWidth, self.minWidth) : totalWidth;
                // max
                totalWidth = MIN(myMaxWidth, totalWidth);
                measuredWidth = totalWidth;
                break;
            case MLNLayoutMeasurementTypeMatchParent:
                measuredWidth = MAX(self.minWidth, myMaxWidth);
                break;
            default:
                measuredWidth = myMaxWidth;
        }
    }
    // height
    if (!self.isHeightExcatly) {
        switch (self.mergedHeightType) {
            case MLNLayoutMeasurementTypeWrapContent:
                // padding
                needMaxHeight += self.paddingTop + self.paddingBottom;
                // min
                needMaxHeight = self.minHeight > 0 ? MAX(needMaxHeight, self.minHeight) : needMaxHeight; // 保证比最小值大
                // max
                needMaxHeight = MIN(myMaxHeight, needMaxHeight); // 保证比最大值小
                measuredHeight = needMaxHeight;
                break;
            case MLNLayoutMeasurementTypeMatchParent:
                measuredHeight = MAX(self.minHeight, myMaxHeight);
                break;
            default:
                measuredHeight = myMaxHeight;
        }
    }
    self.measuredWidth = measuredWidth;
    self.measuredHeight = measuredHeight;
    // measure weight
    if (totalWeight > 0) {
        MeasureHeightForWeightHorizontal(self, subNods, measuredWidth, myMaxHeight, totalWeight);
    }
    return CGSizeMake(self.measuredWidth, self.measuredHeight);
}

- (void)layoutSubnodes {
    CGFloat layoutZoneHeight = self.measuredHeight - self.paddingTop - self.paddingBottom;
    CGFloat layoutZoneBottom = self.measuredHeight - self.paddingBottom;

    CGFloat space = 0.0; // subNode之间的间隔
    CGFloat vernierX = 0.0; // 游标, 用于设置每个subNode的x坐标
    GetFirstSubNodeXAndSubNodeSpace(self, &vernierX, &space);
    
    CGFloat childX, childY = 0.0;
    NSArray *subNodes = self.subnodes;
    
    for (NSUInteger i = 0; i < subNodes.count; i++) {
        MLNLayoutNode *subnode = subNodes[i];
        if (subnode.isGone) continue;

        // 布局主轴(X-axis)
        vernierX += subnode.marginLeft;
        childX = vernierX;
        vernierX += subnode.measuredWidth + subnode.marginRight + space;
        
        // 布局交叉轴(Y-axis)
        childY = GetSubNodeY(self, subnode, layoutZoneHeight, layoutZoneBottom);
        
        // set frame
        subnode.measuredX = childX;
        subnode.measuredY = childY;
        [subnode updateTargetViewFrameIfNeed];
        
        if (subnode.isContainer) {
            [(MLNLayoutContainerNode *)subnode layoutSubnodes];
        }
    }
}

#pragma mark -

static MLN_FORCE_INLINE void GetFirstSubNodeXAndSubNodeSpace(MLNHStackNode __unsafe_unretained *self, CGFloat *firstSubNodeX, CGFloat *subNodeSpace) {
    if (self.mergedWidthType == MLNLayoutMeasurementTypeWrapContent || self.mainAxisAlignment == MLNStackMainAlignmentStart) {
        *firstSubNodeX = self.paddingLeft;
        return;
    }
    
    CGFloat totalWidth = 0.0;
    NSArray *subNodes = self.subnodes;
    for (MLNLayoutNode *node in subNodes) {
        totalWidth += node.marginLeft + node.measuredWidth + node.marginRight;
    }
    CGFloat maxWidth = self.measuredWidth - self.paddingLeft - self.paddingRight;
    CGFloat unusedWidth = MAX(0, (maxWidth - totalWidth));
    
    switch (self.mainAxisAlignment) {
        case MLNStackMainAlignmentCenter:
            *firstSubNodeX = unusedWidth / 2.0;
            break;
            
        case MLNStackMainAlignmentEnd:
            *firstSubNodeX = unusedWidth;
            break;
            
        case MLNStackMainAlignmentSpaceBetween:
            *subNodeSpace = unusedWidth / (MAX(1, (subNodes.count - 1)) * 1.0);
            *firstSubNodeX = self.paddingLeft;
            break;
            
        case MLNStackMainAlignmentSpaceAround:
            *subNodeSpace = unusedWidth / (MAX(1, subNodes.count) * 1.0);
            *firstSubNodeX = self.paddingLeft + *subNodeSpace / 2.0;
            break;
            
        case MLNStackMainAlignmentSpaceEvenly:
            *subNodeSpace = unusedWidth / (MAX(1, subNodes.count + 1) * 1.0);
            *firstSubNodeX = self.paddingLeft + *subNodeSpace;
            break;
            
        default:
            break;
    }
}

static MLN_FORCE_INLINE CGFloat GetSubNodeY(MLNHStackNode __unsafe_unretained *self, MLNLayoutNode __unsafe_unretained *subNode, CGFloat maxHeight, CGFloat maxY) {
    CGFloat y = 0.0;
    switch (subNode.gravity & MLNGravityVerticalMask) { // 交叉轴方向布局优先以Gravity为准
        case MLNGravityTop:
            y = self.paddingTop + subNode.marginTop;
            break;
            
        case MLNGravityCenterVertical:
            y = self.paddingTop + (maxHeight - subNode.measuredHeight) / 2.0 + subNode.marginTop - subNode.marginBottom;
            break;
            
        case MLNGravityBottom:
            y = maxY - subNode.measuredHeight - subNode.marginBottom;
            break;
            
        default:
            switch (self.crossAxisAlignment) {
                case MLNStackCrossAlignmentStart:
                    y = self.paddingTop + subNode.marginTop;
                    break;
                case MLNStackCrossAlignmentCenter:
                    y = self.paddingTop + (maxHeight - subNode.measuredHeight) / 2.0f + subNode.marginTop - subNode.marginBottom;
                    break;
                case MLNStackCrossAlignmentEnd:
                    y = maxY - subNode.measuredHeight - subNode.marginBottom;
                    break;
                default:
                    y = self.paddingTop + subNode.marginTop;
                    break;
            }
            break;
    }
    return y;
}

// 只可能变高度-宽度不变
static MLN_FORCE_INLINE void MeasureHeightForWeightHorizontal(MLNStackNode __unsafe_unretained *node, NSArray<MLNLayoutNode *> __unsafe_unretained *subNods, CGFloat measuredWidth, CGFloat maxHeight,  int totalWeight) {
    
    CGFloat measuredHeight = 0.f;
    CGFloat usableZoneWidth = measuredWidth - node.paddingLeft - node.paddingRight;
    CGFloat usableZoneHeight = maxHeight - node.paddingTop - node.paddingBottom;
    
    NSMutableArray<MLNLayoutNode *> *proportionNodes = [NSMutableArray arrayWithCapacity:subNods.count];
    for (NSUInteger i  = 0; i < subNods.count; i++) {
        MLNLayoutNode *subnode = subNods[i];
        if (subnode.isGone) {
            continue;
        }
        CGFloat subWidth = 0.f;
        if (totalWeight > 0 && subnode.weight > 0 && subnode.widthType != MLNLayoutNodeStatusIdle) {
            subnode.widthProportion = subnode.weight * 1.f / totalWeight * 1.f;
            [subnode needLayout];
            [proportionNodes addObject:subnode];
        } else{
            subWidth = subnode.measuredWidth;
        }
        switch (subnode.layoutStrategy) {
            case MLNLayoutStrategyNativeFrame:
                usableZoneWidth -= subWidth;
                break;
            default: {
                usableZoneWidth -= subWidth + subnode.marginLeft +subnode.marginRight;
                break;
            }
        }
        totalWeight -= subnode.weight;
    }
    
    CGFloat needMaxHeight = 0.f;
    
    for (MLNLayoutNode *subnode in proportionNodes) {
        CGFloat subMaxWidth = usableZoneWidth;
        CGFloat subMaxHeight = usableZoneHeight - subnode.marginTop - subnode.marginBottom;
        //计算子节点
        CGSize subMeasuredSize = [subnode measureSizeWithMaxWidth:subMaxWidth maxHeight:subMaxHeight];
        // 清空权重
        subnode.widthProportion = 0;
        usableZoneWidth -= subMeasuredSize.width;
        switch (subnode.layoutStrategy) {
            case MLNLayoutStrategyNativeFrame:
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
            case MLNLayoutMeasurementTypeWrapContent:
                // padding
                needMaxHeight += node.paddingTop +node.paddingBottom;
                // min
                needMaxHeight = MAX(needMaxHeight, node.minHeight);
                // max
                needMaxHeight = node.maxHeight > 0 ? MIN(node.maxHeight, needMaxHeight) : needMaxHeight;
                measuredHeight = needMaxHeight;
                break;
            case MLNLayoutMeasurementTypeMatchParent:
                measuredHeight = MAX(node.minHeight, maxHeight);
                break;
            default:
                measuredHeight = maxHeight;
        }
        node.measuredHeight = measuredHeight;
    }
}

@end
