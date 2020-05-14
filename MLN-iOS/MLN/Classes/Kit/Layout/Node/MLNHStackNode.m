//
//  MLNHStackNode.m
//  MLN
//
//  Created by MOMO on 2020/3/25.
//

#import "MLNHStackNode.h"
#import "MLNHeader.h"
#import "UIView+MLNLayout.h"

@interface MLNLayoutNodeLine : NSObject
@property (nonatomic, assign) CGFloat value;
@end

@implementation MLNLayoutNodeLine
@end

#define MLN_MARK_DIRTY_AND_CACULATE_WEIGHT \
if (subNode.isGone) {\
    if (subNode.isDirty) needDirty = YES;\
    continue;\
}\
if (subNode.weight > 0 && subNode.widthType != MLNLayoutNodeStatusIdle) {\
    *totalWeight += subNode.weight;\
}\
if (subNode.isDirty) {\
    needDirty = YES;\
} else if (needDirty) {\
    [subNode needLayout];\
}

@interface MLNHStackNode ()

@property (nonatomic, assign) CGFloat subNodeTotalHeight;
@property (nonatomic, strong) NSMutableArray<NSArray<MLNLayoutNode *> *> *wrapLineNodes;
@property (nonatomic, assign) BOOL changedWidthToMatchParent;

@end

@implementation MLNHStackNode

- (NSMutableArray<NSArray<MLNLayoutNode *> *> *)wrapLineNodes {
    if (!_wrapLineNodes) {
        _wrapLineNodes = [NSMutableArray array];
    }
    return _wrapLineNodes;
}

#pragma mark - Private

static const char MLNBelongLineKey;
static MLN_FORCE_INLINE void SetBelongLine(__unsafe_unretained MLNLayoutNode *node, __unsafe_unretained MLNLayoutNodeLine *line) {
    objc_setAssociatedObject(node, &MLNBelongLineKey, line, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static MLN_FORCE_INLINE MLNLayoutNodeLine *GetBelongLine(__unsafe_unretained MLNLayoutNode *node) {
    return objc_getAssociatedObject(node, &MLNBelongLineKey);
}

#pragma mark - Override

- (void)changeWidth:(CGFloat)width {
    [super changeWidth:width];
    if (self.widthType == MLNLayoutMeasurementTypeMatchParent) {
        _changedWidthToMatchParent = YES;
    }
}

- (void)invalidateMainAxisMatchParentMeasureType {
    if (self.widthType == MLNLayoutMeasurementTypeMatchParent && !_changedWidthToMatchParent) {
        self.widthType = MLNLayoutMeasurementTypeWrapContent;
    }
}

- (CGSize)measureSubNodes:(NSArray<MLNLayoutNode *> *)subNods maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight {
    if (self.wrapLineNodes.count > 0) {
        [self.wrapLineNodes removeAllObjects];
    }
    
    CGFloat myMaxWidth = [self myMaxWidthWithMaxWidth:maxWidth];
    CGFloat myMaxHeight = [self myMaxHeightWithMaxHeight:maxHeight];
    CGFloat usableZoneWidth = myMaxWidth - self.paddingLeft - self.paddingRight;
    CGFloat usableZoneHeight = myMaxHeight - self.paddingTop - self.paddingBottom;
    
    CGFloat totalWidth = 0;
    CGFloat totalHeight = 0;
    NSInteger totalWeight = 0;
    
    if (MLN_IS_WRAP_MODE) {
        MeasureMultiLineSize(self, subNods, CGSizeMake(usableZoneWidth, usableZoneHeight), &totalWidth, &totalHeight, &totalWeight);
    } else {
        MeasureSingleLineSize(self, subNods, CGSizeMake(usableZoneWidth, usableZoneHeight), &totalWidth, &totalHeight, &totalWeight);
    }
    self.subNodeTotalHeight = MIN(myMaxHeight, MAX(self.minHeight, totalHeight));
    
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
                totalHeight += self.paddingTop + self.paddingBottom;
                // min
                totalHeight = self.minHeight > 0 ? MAX(totalHeight, self.minHeight) : totalHeight; // 保证比最小值大
                // max
                totalHeight = MIN(myMaxHeight, totalHeight); // 保证比最大值小
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
    if (totalWeight > 0 && MLN_IS_WRAP_MODE == NO) {
        MeasureHeightForWeightHorizontal(self, subNods, measuredWidth, myMaxHeight, totalWeight);
    }
    return CGSizeMake(self.measuredWidth, self.measuredHeight);
}

- (void)layoutSubnodes {
    CGFloat layoutZoneHeight = self.measuredHeight - self.paddingTop - self.paddingBottom;
    CGFloat layoutZoneBottom = self.measuredHeight - self.paddingBottom;
    CGFloat previousLineHeight = 0.0;
    
    for (NSArray<MLNLayoutNode *> *subNodes in self.wrapLineNodes) {
        CGFloat space = 0.0; // subNode之间的间隔
        CGFloat vernierX = 0.0; // 游标, 用于设置每个subNode的x坐标
        GetFirstSubNodeXAndSubNodeSpace(self, &vernierX, &space, subNodes);
    
        CGFloat childX, childY = 0.0;
        for (MLNLayoutNode *subNode in subNodes) {
            if (subNode.isGone) continue;

            // 布局主轴(X-axis)
            vernierX += subNode.marginLeft;
            childX = vernierX;
            vernierX += subNode.measuredWidth + subNode.marginRight + space;
            
            // 布局交叉轴(Y-axis)
            if (MLN_IS_WRAP_MODE == NO) {
                childY = LayoutSingleColumnSubNodeY(self, subNode, layoutZoneHeight, layoutZoneBottom);
            } else {
                CGFloat lineHeight = GetBelongLine(subNode).value;
                childY = LayoutMultiLineSubNodeY(self, subNode, lineHeight, layoutZoneHeight, layoutZoneBottom);
            }
 
            // set frame
            subNode.measuredX = childX;
            subNode.measuredY = childY + previousLineHeight;
            [subNode updateTargetViewFrameIfNeed];
            
            if (subNode.isContainer) {
                [(MLNLayoutContainerNode *)subNode layoutSubnodes];
            }
            if (subNode.overlayNode) {
                [subNode layoutOverlayNode];
            }
        }
        
        if (subNodes.count > 0 && GetBelongLine(subNodes[0])) {
            previousLineHeight += GetBelongLine(subNodes[0]).value;
        }
    }
}

#pragma mark - Private (Measure)

static MLN_FORCE_INLINE void AdjustMeasuredHeightForSubNodes(__unsafe_unretained MLNLayoutNode *node) {
    NSArray<UIView *> *subViews = [node.targetView subviews];
    if (subViews.count == 0) return;
    [subViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.lua_node.measuredHeight = node.measuredHeight;
    }];
}

static MLN_FORCE_INLINE CGSize GetSubNodeSize(__unsafe_unretained MLNLayoutNode *subNode, CGFloat subNodeMaxWidth, CGFloat subNodeMaxHeight) {
    CGSize subNodeSize = [subNode measureSizeWithMaxWidth:subNodeMaxWidth maxHeight:subNodeMaxHeight];
    if (subNode.layoutStrategy == MLNLayoutStrategySimapleAuto) {
        subNodeSize.width += (subNode.marginLeft + subNode.marginRight);
        subNodeSize.height += (subNode.marginTop + subNode.marginBottom);
    }
    return subNodeSize;
}

static MLN_FORCE_INLINE void MeasureSingleLineSize(__unsafe_unretained MLNHStackNode *self, __unsafe_unretained NSArray<MLNLayoutNode *> *subNodes, CGSize maxSize, CGFloat *totalWidth, CGFloat *totalHeight, NSInteger *totalWeight) {
    BOOL needDirty = NO;
    NSMutableArray<MLNLayoutNode *> *lineNodes = [NSMutableArray array];
    NSMutableArray<MLNLayoutNode *> *forceUseMatchParentNodes = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < subNodes.count; i++) {
        MLNLayoutNode *subNode = subNodes[i];
        MLN_MARK_DIRTY_AND_CACULATE_WEIGHT
        
        CGFloat subNodeMaxWidth = maxSize.width - subNode.marginLeft - subNode.marginRight - *totalWidth;
        CGFloat subNodeMaxHeight = maxSize.height - subNode.marginTop - subNode.marginBottom;
        CGSize subNodeSize = GetSubNodeSize(subNode, subNodeMaxWidth, subNodeMaxHeight); // 计算子节点
        if (MLN_NODE_HEIGHT_SHOULD_FORCE_USE_MATCHPARENT(subNode)) {
            [forceUseMatchParentNodes addObject:subNode];
        }
        
        *totalWidth = MAX(*totalWidth, *totalWidth + subNodeSize.width);
        *totalHeight = MAX(*totalHeight, subNodeSize.height);
        [lineNodes addObject:subNode];
    };
    
    if (lineNodes.count > 0) {
        [self.wrapLineNodes addObject:lineNodes];
    }
    for (MLNLayoutNode *node in forceUseMatchParentNodes) {
        node.measuredHeight = *totalHeight;
        AdjustMeasuredHeightForSubNodes(node);
    }
}

static MLN_FORCE_INLINE void MeasureMultiLineSize(__unsafe_unretained MLNHStackNode *self, __unsafe_unretained NSArray<MLNLayoutNode *> *subNodes, CGSize maxSize, CGFloat *totalWidth, CGFloat *totalHeight, NSInteger *totalWeight) {
    BOOL needDirty = NO;
    CGFloat currentLineWidth = 0.0;
    CGFloat currentLineHeight = 0.0;
    MLNLayoutNodeLine *belongLine = [MLNLayoutNodeLine new];
    NSMutableArray<MLNLayoutNode *> *lineNodes = [NSMutableArray array];
    NSMutableArray<MLNLayoutNode *> *shouldUseMatchParentNodes = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < subNodes.count; i++) {
        MLNLayoutNode *subNode = subNodes[i];
        MLN_MARK_DIRTY_AND_CACULATE_WEIGHT
        
        BOOL shouldUseMatchParent = NO;
        if (subNode.heightType == MLNLayoutMeasurementTypeMatchParent) {
            subNode.heightType = MLNLayoutMeasurementTypeWrapContent;
            shouldUseMatchParent = YES; // 换行模式下，高度为MatchParent节点要以WrapContent来测量
        }
        
        CGFloat subNodeMaxWidth = maxSize.width - subNode.marginLeft - subNode.marginRight;
        CGFloat subNodeMaxHeight = maxSize.height - subNode.marginTop - subNode.marginBottom;
        CGSize subNodeSize = GetSubNodeSize(subNode, subNodeMaxWidth, subNodeMaxHeight); // 计算子节点
        if (shouldUseMatchParent) {
            [shouldUseMatchParentNodes addObject:subNode];
            subNode.heightType = MLNLayoutMeasurementTypeMatchParent;
        }
        
        // 当前行剩余宽度是否可容纳下一个子view && 如果是WrapContent则每个子view单独占一行
        if ((maxSize.width - currentLineWidth > subNodeSize.width) && self.mergedWidthType != MLNLayoutMeasurementTypeWrapContent) {
            [lineNodes addObject:subNode];
            
            currentLineWidth += subNodeSize.width;
            currentLineHeight = MAX(currentLineHeight, subNodeSize.height);
            
            belongLine.value = currentLineHeight;
            SetBelongLine(subNode, belongLine); // 每一行的行高取决于当前行最大高度的subNode
        } else {
            [self.wrapLineNodes addObject:[lineNodes copy]];
            [lineNodes removeAllObjects];
            [lineNodes addObject:subNode];
            
            *totalHeight += currentLineHeight; // 换行后累加上一行的高度
            currentLineWidth = subNodeSize.width;
            currentLineHeight = subNodeSize.height;
            
            belongLine = [MLNLayoutNodeLine new]; // 换行后重新分配行高
            belongLine.value = currentLineHeight;
            SetBelongLine(subNode, belongLine);
        }
        *totalWidth = MAX(*totalWidth, currentLineWidth);
    };
     
    *totalHeight += currentLineHeight; // 累加最后一行高度
    if (lineNodes.count > 0) {
        [self.wrapLineNodes addObject:lineNodes];
    }
    for (MLNLayoutNode *node in shouldUseMatchParentNodes) {
        node.measuredHeight = GetBelongLine(node).value; // 对于height为MatchParent的节点，高度应为其所在行的行高
        AdjustMeasuredHeightForSubNodes(node);
    }
}

static MLN_FORCE_INLINE void MeasureHeightForWeightHorizontal(MLNStackNode __unsafe_unretained *node, NSArray<MLNLayoutNode *> __unsafe_unretained *subNods, CGFloat measuredWidth, CGFloat maxHeight, NSInteger totalWeight) {
    
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
    
    CGFloat totalHeight = 0.f;
    
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
                totalHeight = MAX(totalHeight, subMeasuredSize.height);
                break;
            default: {
                totalHeight = MAX(totalHeight, subMeasuredSize.height +subnode.marginTop +subnode.marginBottom);
                break;
            }
        }
    }
    // height
    if (!node.isHeightExcatly) {
        switch (node.mergedHeightType) {
            case MLNLayoutMeasurementTypeWrapContent:
                // padding
                totalHeight += node.paddingTop +node.paddingBottom;
                // min
                totalHeight = MAX(totalHeight, node.minHeight);
                // max
                totalHeight = node.maxHeight > 0 ? MIN(node.maxHeight, totalHeight) : totalHeight;
                measuredHeight = totalHeight;
                break;
            case MLNLayoutMeasurementTypeMatchParent:
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

#pragma mark - Private (Layout)

static MLN_FORCE_INLINE void GetFirstSubNodeXAndSubNodeSpace(MLNHStackNode __unsafe_unretained *self, CGFloat *firstSubNodeX, CGFloat *subNodeSpace, NSArray<MLNLayoutNode *> __unsafe_unretained *subNodes) {
    if (self.mergedWidthType == MLNLayoutMeasurementTypeWrapContent) {
        *firstSubNodeX = self.paddingLeft;
        return;
    }
    
    CGFloat totalWidth = 0.0;
    for (MLNLayoutNode *node in subNodes) {
        totalWidth += node.marginLeft + node.measuredWidth + node.marginRight;
    }
    CGFloat maxWidth = self.measuredWidth - self.paddingLeft - self.paddingRight;
    CGFloat unusedWidth = MAX(0, (maxWidth - totalWidth));
    
    switch (self.mainAxisAlignment) {
        case MLNStackMainAlignmentStart:
            *firstSubNodeX = self.paddingLeft;
            break;
            
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
            *firstSubNodeX = self.paddingLeft;
            break;
    }
}

static MLN_FORCE_INLINE CGFloat LayoutSingleColumnSubNodeY(MLNHStackNode __unsafe_unretained *self, MLNLayoutNode __unsafe_unretained *subNode, CGFloat maxHeight, CGFloat maxY) {
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
            
        default: // 若未设置Gravity，则以crossAxisAlignment为准.
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

static MLN_FORCE_INLINE CGFloat LayoutMultiLineSubNodeY(MLNHStackNode __unsafe_unretained *self, MLNLayoutNode __unsafe_unretained *subNode, CGFloat lineHeight, CGFloat maxHeight, CGFloat maxY) {
    CGFloat y = 0.0; // 多行模式下交叉轴方向Gravity只针对每一行生效
    switch (subNode.gravity & MLNGravityVerticalMask) {
        case MLNGravityTop:
            y = self.paddingTop + subNode.marginTop;
            break;
            
        case MLNGravityCenterVertical:
            y = self.paddingTop + (lineHeight - subNode.measuredHeight) / 2.0 + subNode.marginTop - subNode.marginBottom;
            break;
            
        case MLNGravityBottom:
            y = lineHeight - subNode.measuredHeight - subNode.marginBottom;
            break;
            
        default:
            y = self.paddingTop + subNode.marginTop;
            break;
               
       }

    // 多行模式下crossAxisAlignment对所有行作为一个整体生效
    switch (self.crossAxisAlignment) {
        case MLNStackCrossAlignmentCenter:
            y += (maxHeight - self.subNodeTotalHeight) / 2.0f;
            break;
            
        case MLNStackCrossAlignmentEnd:
            y += (maxY - self.subNodeTotalHeight);
            break;
            
        case MLNStackCrossAlignmentStart:
        default:
            // do nothing
            break;
    }
    return y;
}

@end
