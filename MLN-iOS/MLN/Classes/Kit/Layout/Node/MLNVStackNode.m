//
//  MLNVStackNode.m
//  MLN
//
//  Created by MOMO on 2020/3/25.
//

#import "MLNVStackNode.h"
#import "MLNSpacerNode.h"
#import "MLNHeader.h"

@implementation MLNVStackNode

#pragma mark - Override

- (CGSize)measureSubNodes:(NSArray<MLNLayoutNode *> *)subNods maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight {
    CGFloat myMaxWidth = [self myMaxWidthWithMaxWidth:maxWidth];
    CGFloat myMaxHeight = [self myMaxHeightWithMaxHeight:maxHeight];
    
    CGFloat usableZoneWidth = myMaxWidth - self.paddingLeft - self.paddingRight;
    CGFloat usableZoneHeight = myMaxHeight - self.paddingTop - self.paddingBottom;
    
    int totalHeight = 0;
    int needMaxWidth = 0;
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
        if (subnode.weight > 0 && subnode.heightType != MLNLayoutNodeStatusIdle) {
            totalWeight += subnode.weight;
        }
        if (subnode.isDirty) {
            needDirty = YES;
        } else if (needDirty) {
            [subnode needLayout];
        }
        CGFloat subMaxWidth = usableZoneWidth - subnode.marginLeft - subnode.marginRight;
        CGFloat subMaxHeight = usableZoneHeight - totalHeight - subnode.marginTop - subnode.marginBottom;
        CGSize subMeasuredSize = [subnode measureSizeWithMaxWidth:subMaxWidth maxHeight:subMaxHeight]; // 计算子节点
        switch (subnode.layoutStrategy) {
            case MLNLayoutStrategyNativeFrame:
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
    if (!self.isWidthExcatly) {
        switch (self.mergedWidthType) {
            case MLNLayoutMeasurementTypeWrapContent:
                // padding
                needMaxWidth += self.paddingLeft + self.paddingRight;
                // max
                needMaxWidth = MIN(myMaxWidth, needMaxWidth);
                // min
                needMaxWidth = self.minWidth > 0 ? MAX(needMaxWidth, self.minWidth) : needMaxWidth;
                measuredWidth = needMaxWidth;
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
                totalHeight += self.paddingTop + self.paddingBottom;
                // max
                totalHeight = MIN(myMaxHeight, totalHeight);
                // min
                totalHeight = self.minHeight > 0 ? MAX(totalHeight, self.minHeight) : totalHeight;
                measuredHeight = totalHeight;
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
        measureWidthForWeightVertical(self, subNods, measuredWidth, measuredHeight, myMaxWidth, totalWeight);
    }
    return CGSizeMake(self.measuredWidth, self.measuredHeight);
}

- (void)layoutSubnodes {
    CGFloat layoutZoneWidth = self.measuredWidth - self.paddingLeft - self.paddingRight;
    CGFloat layoutZoneRight = self.measuredWidth - self.paddingRight;
    
    CGFloat space = 0.0; // subNode之间的间隔
    CGFloat vernierY = 0.0; // 游标, 用于设置每个subNode的y坐标
    CGFloat spacerHeight = 0.0; // spacer的高度
    GetFirstSubNodeYAndSubNodeSpace(self, &vernierY, &space, &spacerHeight);
    
    CGFloat childX, childY = 0.0f;
    NSArray<MLNLayoutNode *> *subNodes = self.subnodes;
    
    for (MLNLayoutNode *subNode in subNodes) {
        if (subNode.isGone) continue;
        if (MLN_IS_EXPANDED_SPACER_NODE_IN_VSTACK(subNode)) {
            subNode.measuredHeight = spacerHeight;
        }
        
        // 布局主轴(Y-axis)
        vernierY += subNode.marginTop;
        childY = vernierY;
        vernierY += subNode.measuredHeight + subNode.marginBottom + space;
        
        // 布局交叉轴(X-axis)
        childX = GetSubNodeX(self, subNode, layoutZoneWidth, layoutZoneRight);
        
        // set frame
        subNode.measuredX = childX;
        subNode.measuredY = childY;
        [subNode updateTargetViewFrameIfNeed];
        
        if (subNode.isContainer) {
            [(MLNLayoutContainerNode *)subNode layoutSubnodes];
        }
        if (subNode.overlayNode) {
            [subNode layoutOverlayNode];
        }
    }
}

#pragma mark -

static MLN_FORCE_INLINE void GetFirstSubNodeYAndSubNodeSpace(MLNVStackNode __unsafe_unretained *self, CGFloat *firstSubNodeY, CGFloat *subNodeSpace, CGFloat *spacerHeight) {
    if (self.mergedHeightType == MLNLayoutMeasurementTypeWrapContent) {
        *firstSubNodeY = self.paddingTop;
        return;
    }

    int validSpacerCount = 0; // 没有设置height的spacerNode
    CGFloat totalHeight = 0.0;
    NSArray *subNodes = self.subnodes;
    for (MLNLayoutNode *node in subNodes) {
        totalHeight += node.marginTop + node.measuredHeight + node.marginBottom;
        if (MLN_IS_EXPANDED_SPACER_NODE_IN_VSTACK(node)) {
            validSpacerCount++;
        }
    }
    CGFloat maxHeight = self.measuredHeight - self.paddingTop - self.paddingBottom;
    CGFloat unusedHeight = MAX(0, (maxHeight - totalHeight));
    
    MLNStackMainAlignment mainAlignment = self.mainAxisAlignment;
    if (validSpacerCount > 0) { // 如果有Spacer, 则主轴上AxisAlignment均无效
        mainAlignment = MLNStackMainAlignmentInvalid;
        *spacerHeight = unusedHeight / validSpacerCount;
    }
    
    switch (mainAlignment) {
        case MLNStackMainAlignmentStart:
            *firstSubNodeY = self.paddingLeft;
            break;
            
        case MLNStackMainAlignmentCenter:
            *firstSubNodeY = unusedHeight / 2.0;
            break;
            
        case MLNStackMainAlignmentEnd:
            *firstSubNodeY = unusedHeight;
            break;
            
        case MLNStackMainAlignmentSpaceBetween:
            *subNodeSpace = unusedHeight / (MAX(1, (subNodes.count - 1)) * 1.0);
            *firstSubNodeY = self.paddingTop;
            break;
            
        case MLNStackMainAlignmentSpaceAround:
            *subNodeSpace = unusedHeight / (MAX(1, subNodes.count) * 1.0);
            *firstSubNodeY = self.paddingTop + *subNodeSpace / 2.0;
            break;
            
        case MLNStackMainAlignmentSpaceEvenly:
            *subNodeSpace = unusedHeight / (MAX(1, subNodes.count + 1) * 1.0);
            *firstSubNodeY = self.paddingTop + *subNodeSpace;
            break;
            
        default:
            break;
    }
}

static MLN_FORCE_INLINE CGFloat GetSubNodeX(MLNVStackNode __unsafe_unretained *self, MLNLayoutNode __unsafe_unretained *subNode, CGFloat maxWidth, CGFloat maxX) {
    CGFloat x = 0.0;
    switch (subNode.gravity & MLNGravityHorizontalMask) { // 交叉轴方向布局优先以Gravity为准
        case MLNGravityLeft:
            x = self.paddingLeft + subNode.marginLeft;
            break;
            
        case MLNGravityCenterHorizontal:
            x = self.paddingLeft + (maxWidth - subNode.measuredWidth) / 2.0 + subNode.marginLeft - subNode.marginRight;
            break;
            
        case MLNGravityRight:
            x = maxX - subNode.measuredWidth - subNode.marginRight;
            break;
            
        default:
            switch (self.crossAxisAlignment) {
                case MLNStackCrossAlignmentStart:
                    x = self.paddingLeft + subNode.marginLeft;
                    break;
                case MLNStackCrossAlignmentCenter:
                    x = self.paddingLeft + (maxWidth - subNode.measuredWidth) / 2.0f + subNode.marginLeft - subNode.marginRight;
                    break;
                case MLNStackCrossAlignmentEnd:
                    x = maxX - subNode.measuredWidth - subNode.marginRight;
                    break;
                default:
                    x = self.paddingLeft + subNode.marginLeft;
                    break;
            }
            break;
    }
    return x;
}

// 只可能变宽度-高度不变
MLN_FORCE_INLINE void measureWidthForWeightVertical(MLNStackNode __unsafe_unretained *node, NSArray<MLNLayoutNode *> __unsafe_unretained *subNods, CGFloat measuredWidth, CGFloat measuredHeight, CGFloat myMaxWidth,  int totalWeight) {
    CGFloat usableZoneWidth = myMaxWidth - node.paddingLeft - node.paddingRight;
    CGFloat usableZoneHeight = measuredHeight - node.paddingTop - node.paddingBottom;
    
    BOOL needDirty = NO;

    NSMutableArray<MLNLayoutNode *> *proportionNodes = [NSMutableArray arrayWithCapacity:subNods.count];
    for (NSUInteger i  = 0; i < subNods.count; i++) {
        MLNLayoutNode *subnode = subNods[i];
        if (subnode.isGone) {
            continue;
        }
        CGFloat subHeight = 0.f;
        if (totalWeight > 0 && subnode.weight > 0 && subnode.heightType != MLNLayoutNodeStatusIdle) {
            subnode.heightProportion = subnode.weight * 1.f / totalWeight * 1.f;
            needDirty = YES;
            [subnode needLayout];
            [proportionNodes addObject:subnode];
        } else{
            subHeight = subnode.measuredHeight;
        }
        switch (subnode.layoutStrategy) {
            case MLNLayoutStrategyNativeFrame:
                usableZoneHeight -= subHeight;
                break;
            default: {
                usableZoneHeight -= subHeight + subnode.marginTop + subnode.marginBottom;
                break;
            }
        }
        totalWeight -= subnode.weight;
    }
    
    int needMaxWidth = 0.f;
    
    for (MLNLayoutNode *subnode in proportionNodes) {
        CGFloat subMaxWidth = usableZoneWidth - subnode.marginLeft - subnode.marginRight;
        CGFloat subMaxHeight = usableZoneHeight;
        //计算子节点
        CGSize subMeasuredSize = [subnode measureSizeWithMaxWidth:subMaxWidth maxHeight:subMaxHeight];
        // 清空权重
        subnode.heightProportion = 0;
        usableZoneHeight -= subMeasuredSize.height;
        switch (subnode.layoutStrategy) {
            case MLNLayoutStrategyNativeFrame:
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
            case MLNLayoutMeasurementTypeWrapContent:
                // padding
                needMaxWidth += node.paddingLeft +node.paddingRight;
                // max
                needMaxWidth = MIN(measuredWidth, needMaxWidth);
                // min
                needMaxWidth = node.minWidth > 0 ? MAX(needMaxWidth, node.minWidth) : needMaxWidth;
                measuredWidth = needMaxWidth;
                break;
            case MLNLayoutMeasurementTypeMatchParent:
                measuredWidth = MAX(node.minWidth, myMaxWidth);
                break;
            default:
                measuredWidth = myMaxWidth;
                break;
        }
        node.measuredWidth = measuredWidth;
    }
}

@end
