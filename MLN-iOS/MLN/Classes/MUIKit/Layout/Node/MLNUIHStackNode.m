//
//  MLNUIHStackNode.m
//  MLNUI
//
//  Created by MOMO on 2020/3/25.
//

#import "MLNUIHStackNode.h"
#import "MLNUIHeader.h"
#import "UIView+MLNUILayout.h"

@interface MLNUILayoutNodeLine : NSObject
@property (nonatomic, assign) CGFloat value;
@end

@implementation MLNUILayoutNodeLine
@end

#define MLNUI_MARK_DIRTY_AND_CACULATE_WEIGHT \
if (subNode.isGone) {\
    if (subNode.isDirty) needDirty = YES;\
    continue;\
}\
if (subNode.weight > 0 && subNode.widthType != MLNUILayoutNodeStatusIdle) {\
    *totalWeight += subNode.weight;\
}\
if (subNode.isDirty) {\
    needDirty = YES;\
} else if (needDirty) {\
    [subNode needLayout];\
}

@interface MLNUIHStackNode ()

@property (nonatomic, assign) CGFloat subNodeTotalHeight;
@property (nonatomic, strong) NSMutableArray<NSArray<MLNUILayoutNode *> *> *wrapLineNodes;
@property (nonatomic, assign) BOOL changedWidthToMatchParent;

@end

@implementation MLNUIHStackNode

- (NSMutableArray<NSArray<MLNUILayoutNode *> *> *)wrapLineNodes {
    if (!_wrapLineNodes) {
        _wrapLineNodes = [NSMutableArray array];
    }
    return _wrapLineNodes;
}

#pragma mark - Private

static const char MLNUIBelongLineKey;
static MLNUI_FORCE_INLINE void SetBelongLine(__unsafe_unretained MLNUILayoutNode *node, __unsafe_unretained MLNUILayoutNodeLine *line) {
    objc_setAssociatedObject(node, &MLNUIBelongLineKey, line, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static MLNUI_FORCE_INLINE MLNUILayoutNodeLine *GetBelongLine(__unsafe_unretained MLNUILayoutNode *node) {
    return objc_getAssociatedObject(node, &MLNUIBelongLineKey);
}

#pragma mark - Override

- (void)changeWidth:(CGFloat)width {
    [super changeWidth:width];
    if (self.widthType == MLNUILayoutMeasurementTypeMatchParent) {
        _changedWidthToMatchParent = YES;
    }
}

- (void)invalidateMainAxisMatchParentMeasureType {
    if (self.widthType == MLNUILayoutMeasurementTypeMatchParent && !_changedWidthToMatchParent) {
        self.widthType = MLNUILayoutMeasurementTypeWrapContent;
    }
}

- (CGSize)measureSubNodes:(NSArray<MLNUILayoutNode *> *)subNods maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight {
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
    
    if (MLNUI_IS_WRAP_MODE) {
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
            case MLNUILayoutMeasurementTypeWrapContent:
                // padding
                totalWidth += self.paddingLeft + self.paddingRight;
                // min
                totalWidth = self.minWidth > 0 ? MAX(totalWidth, self.minWidth) : totalWidth;
                // max
                totalWidth = MIN(myMaxWidth, totalWidth);
                measuredWidth = totalWidth;
                break;
            case MLNUILayoutMeasurementTypeMatchParent:
                measuredWidth = MAX(self.minWidth, myMaxWidth);
                break;
            default:
                measuredWidth = myMaxWidth;
        }
    }
    // height
    if (!self.isHeightExcatly) {
        switch (self.mergedHeightType) {
            case MLNUILayoutMeasurementTypeWrapContent:
                // padding
                totalHeight += self.paddingTop + self.paddingBottom;
                // min
                totalHeight = self.minHeight > 0 ? MAX(totalHeight, self.minHeight) : totalHeight; // 保证比最小值大
                // max
                totalHeight = MIN(myMaxHeight, totalHeight); // 保证比最大值小
                measuredHeight = totalHeight;
                break;
            case MLNUILayoutMeasurementTypeMatchParent:
                measuredHeight = MAX(self.minHeight, myMaxHeight);
                break;
            default:
                measuredHeight = myMaxHeight;
        }
    }
    self.measuredWidth = measuredWidth;
    self.measuredHeight = measuredHeight;
    // measure weight
    if (totalWeight > 0 && MLNUI_IS_WRAP_MODE == NO) {
        MeasureHeightForWeightHorizontal(self, subNods, measuredWidth, myMaxHeight, totalWeight);
    }
    return CGSizeMake(self.measuredWidth, self.measuredHeight);
}

- (void)layoutSubnodes {
    CGFloat layoutZoneHeight = self.measuredHeight - self.paddingTop - self.paddingBottom;
    CGFloat layoutZoneBottom = self.measuredHeight - self.paddingBottom;
    CGFloat previousLineHeight = 0.0;
    
    for (NSArray<MLNUILayoutNode *> *subNodes in self.wrapLineNodes) {
        CGFloat space = 0.0; // subNode之间的间隔
        CGFloat vernierX = 0.0; // 游标, 用于设置每个subNode的x坐标
        GetFirstSubNodeXAndSubNodeSpace(self, &vernierX, &space, subNodes);
    
        CGFloat childX, childY = 0.0;
        for (MLNUILayoutNode *subNode in subNodes) {
            if (subNode.isGone) continue;

            // 布局主轴(X-axis)
            vernierX += subNode.marginLeft;
            childX = vernierX;
            vernierX += subNode.measuredWidth + subNode.marginRight + space;
            
            // 布局交叉轴(Y-axis)
            if (MLNUI_IS_WRAP_MODE == NO) {
                childY = LayoutSingleLineSubNodeY(self, subNode, layoutZoneHeight, layoutZoneBottom);
            } else {
                CGFloat lineHeight = GetBelongLine(subNode).value;
                childY = LayoutMultiLineSubNodeY(self, subNode, lineHeight, layoutZoneHeight, layoutZoneBottom);
            }
 
            // set frame
            subNode.measuredX = childX;
            subNode.measuredY = childY + previousLineHeight;
            [subNode updateTargetViewFrameIfNeed];
            
            if (subNode.isContainer) {
                [(MLNUILayoutContainerNode *)subNode layoutSubnodes];
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

static MLNUI_FORCE_INLINE CGSize GetSubNodeSize(__unsafe_unretained MLNUILayoutNode *subNode, CGFloat subNodeMaxWidth, CGFloat subNodeMaxHeight) {
    CGSize subNodeSize = [subNode measureSizeWithMaxWidth:subNodeMaxWidth maxHeight:subNodeMaxHeight];
    if (subNode.layoutStrategy == MLNUILayoutStrategySimapleAuto) {
        subNodeSize.width += (subNode.marginLeft + subNode.marginRight);
        subNodeSize.height += (subNode.marginTop + subNode.marginBottom);
    }
    return subNodeSize;
}

static MLNUI_FORCE_INLINE void MeasureSingleLineSize(__unsafe_unretained MLNUIHStackNode *self, __unsafe_unretained NSArray<MLNUILayoutNode *> *subNodes, CGSize maxSize, CGFloat *totalWidth, CGFloat *totalHeight, NSInteger *totalWeight) {
    BOOL needDirty = NO;
    NSMutableArray<MLNUILayoutNode *> *lineNodes = [NSMutableArray array];
    NSMutableArray<MLNUILayoutNode *> *forceUseMatchParentNodes = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < subNodes.count; i++) {
        MLNUILayoutNode *subNode = subNodes[i];
        MLNUI_MARK_DIRTY_AND_CACULATE_WEIGHT
        
        CGFloat subNodeMaxWidth = maxSize.width - subNode.marginLeft - subNode.marginRight - *totalWidth;
        CGFloat subNodeMaxHeight = maxSize.height - subNode.marginTop - subNode.marginBottom;
        CGSize subNodeSize = GetSubNodeSize(subNode, subNodeMaxWidth, subNodeMaxHeight); // 计算子节点
        if (MLNUI_NODE_HEIGHT_SHOULD_FORCE_USE_MATCHPARENT(subNode)) {
            [forceUseMatchParentNodes addObject:subNode];
        }
        
        *totalWidth = MAX(*totalWidth, *totalWidth + subNodeSize.width);
        *totalHeight = MAX(*totalHeight, subNodeSize.height);
        [lineNodes addObject:subNode];
    };
    
    if (lineNodes.count > 0) {
        [self.wrapLineNodes addObject:lineNodes];
    }
    for (MLNUILayoutNode *node in forceUseMatchParentNodes) {
        [node forceUseMatchParentForHeightMeasureType];
        [node measureSizeWithMaxWidth:node.measuredWidth maxHeight:(*totalHeight - node.marginTop - node.marginBottom)];
    }
}

static MLNUI_FORCE_INLINE void MeasureMultiLineSize(__unsafe_unretained MLNUIHStackNode *self, __unsafe_unretained NSArray<MLNUILayoutNode *> *subNodes, CGSize maxSize, CGFloat *totalWidth, CGFloat *totalHeight, NSInteger *totalWeight) {
    BOOL needDirty = NO;
    CGFloat currentLineWidth = 0.0;
    CGFloat currentLineHeight = 0.0;
    MLNUILayoutNodeLine *belongLine = [MLNUILayoutNodeLine new];
    NSMutableArray<MLNUILayoutNode *> *lineNodes = [NSMutableArray array];
    NSMutableArray<MLNUILayoutNode *> *shouldUseMatchParentNodes = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < subNodes.count; i++) {
        MLNUILayoutNode *subNode = subNodes[i];
        MLNUI_MARK_DIRTY_AND_CACULATE_WEIGHT
        
        BOOL shouldUseMatchParent = NO;
        if (subNode.heightType == MLNUILayoutMeasurementTypeMatchParent) {
            subNode.heightType = MLNUILayoutMeasurementTypeWrapContent;
            shouldUseMatchParent = YES; // 换行模式下，高度为MatchParent节点要以WrapContent来测量
        }
        
        CGFloat subNodeMaxWidth = maxSize.width - subNode.marginLeft - subNode.marginRight;
        CGFloat subNodeMaxHeight = maxSize.height - subNode.marginTop - subNode.marginBottom;
        CGSize subNodeSize = GetSubNodeSize(subNode, subNodeMaxWidth, subNodeMaxHeight); // 计算子节点
        if (shouldUseMatchParent) {
            [shouldUseMatchParentNodes addObject:subNode];
            subNode.heightType = MLNUILayoutMeasurementTypeMatchParent;
        }
        
        // 当前行剩余宽度是否可容纳下一个子view && 如果是WrapContent则每个子view单独占一行
        if ((maxSize.width - currentLineWidth > subNodeSize.width) && self.mergedWidthType != MLNUILayoutMeasurementTypeWrapContent) {
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
            
            belongLine = [MLNUILayoutNodeLine new]; // 换行后重新分配行高
            belongLine.value = currentLineHeight;
            SetBelongLine(subNode, belongLine);
        }
        *totalWidth = MAX(*totalWidth, currentLineWidth);
    };
     
    *totalHeight += currentLineHeight; // 累加最后一行高度
    if (lineNodes.count > 0) {
        [self.wrapLineNodes addObject:lineNodes];
    }
    for (MLNUILayoutNode *node in shouldUseMatchParentNodes) {
        [node forceUseMatchParentForHeightMeasureType];
        CGFloat maxHeight = GetBelongLine(node).value - node.marginTop - node.marginBottom; // 对于height为MatchParent的节点，高度应为其所在行的行高
        [node measureSizeWithMaxWidth:node.measuredWidth maxHeight:maxHeight];
    }
}

static MLNUI_FORCE_INLINE void MeasureHeightForWeightHorizontal(MLNUIStackNode __unsafe_unretained *self, NSArray<MLNUILayoutNode *> __unsafe_unretained *subNods, CGFloat measuredWidth, CGFloat maxHeight, NSInteger totalWeight) {
    
    CGFloat measuredHeight = 0.f;
    CGFloat usableZoneWidth = measuredWidth - self.paddingLeft - self.paddingRight;
    CGFloat usableZoneHeight = maxHeight - self.paddingTop - self.paddingBottom;
    
    NSMutableArray<MLNUILayoutNode *> *proportionNodes = [NSMutableArray arrayWithCapacity:subNods.count];
    for (NSUInteger i  = 0; i < subNods.count; i++) {
        MLNUILayoutNode *subnode = subNods[i];
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
    
    CGFloat totalHeight = 0.f;
    NSMutableArray<MLNUILayoutNode *> *forceUseMatchParentNodes = [NSMutableArray array];
    
    for (MLNUILayoutNode *subnode in proportionNodes) {
        CGFloat subMaxWidth = usableZoneWidth;
        CGFloat subMaxHeight = usableZoneHeight - subnode.marginTop - subnode.marginBottom;
        CGSize subMeasuredSize = [subnode measureSizeWithMaxWidth:subMaxWidth maxHeight:subMaxHeight]; // 计算子节点
        if (MLNUI_NODE_HEIGHT_SHOULD_FORCE_USE_MATCHPARENT(subnode)) {
            [forceUseMatchParentNodes addObject:subnode];
        }
        subnode.widthProportion = 0; // 清空权重
        usableZoneWidth -= subMeasuredSize.width;
        switch (subnode.layoutStrategy) {
            case MLNUILayoutStrategyNativeFrame:
                totalHeight = MAX(totalHeight, subMeasuredSize.height);
                break;
            default: {
                totalHeight = MAX(totalHeight, subMeasuredSize.height + subnode.marginTop + subnode.marginBottom);
                break;
            }
        }
    }
    
    for (MLNUILayoutNode *node in forceUseMatchParentNodes) {
        [node forceUseMatchParentForHeightMeasureType];
        CGFloat maxHeight = MAX(self.measuredHeight - self.paddingTop - self.paddingBottom, totalHeight) - node.marginTop - node.marginBottom;
        CGFloat originWidth = node.measuredWidth;
        [node measureSizeWithMaxWidth:originWidth maxHeight:maxHeight];
        node.measuredWidth = originWidth; // 宽度应保持不变，否则权重将失效
    }
    
    // height
    if (!self.isHeightExcatly) {
        switch (self.mergedHeightType) {
            case MLNUILayoutMeasurementTypeWrapContent:
                // padding
                totalHeight += self.paddingTop + self.paddingBottom;
                // min
                totalHeight = MAX(totalHeight, self.minHeight);
                // max
                totalHeight = self.maxHeight > 0 ? MIN(self.maxHeight, totalHeight) : totalHeight;
                measuredHeight = totalHeight;
                break;
            case MLNUILayoutMeasurementTypeMatchParent:
                measuredHeight = MAX(self.minHeight, maxHeight);
                break;
            default:
                measuredHeight = maxHeight;
        }
        if (measuredHeight > self.measuredHeight) {
            self.measuredHeight = measuredHeight;
        }
    }
}

#pragma mark - Private (Layout)

static MLNUI_FORCE_INLINE void GetFirstSubNodeXAndSubNodeSpace(MLNUIHStackNode __unsafe_unretained *self, CGFloat *firstSubNodeX, CGFloat *subNodeSpace, NSArray<MLNUILayoutNode *> __unsafe_unretained *subNodes) {
    if (self.mergedWidthType == MLNUILayoutMeasurementTypeWrapContent) {
        *firstSubNodeX = self.paddingLeft;
        return;
    }
    
    CGFloat totalWidth = 0.0;
    for (MLNUILayoutNode *node in subNodes) {
        totalWidth += node.marginLeft + node.measuredWidth + node.marginRight;
    }
    CGFloat maxWidth = self.measuredWidth - self.paddingLeft - self.paddingRight;
    CGFloat unusedWidth = MAX(0, (maxWidth - totalWidth));
    
    switch (self.mainAxisAlignment) {
        case MLNUIStackMainAlignmentStart:
            *firstSubNodeX = self.paddingLeft;
            break;
            
        case MLNUIStackMainAlignmentCenter:
            *firstSubNodeX = unusedWidth / 2.0;
            break;
            
        case MLNUIStackMainAlignmentEnd:
            *firstSubNodeX = self.paddingLeft + unusedWidth;
            break;
            
        case MLNUIStackMainAlignmentSpaceBetween:
            *subNodeSpace = unusedWidth / (MAX(1, (subNodes.count - 1)) * 1.0);
            *firstSubNodeX = self.paddingLeft;
            break;
            
        case MLNUIStackMainAlignmentSpaceAround:
            *subNodeSpace = unusedWidth / (MAX(1, subNodes.count) * 1.0);
            *firstSubNodeX = self.paddingLeft + *subNodeSpace / 2.0;
            break;
            
        case MLNUIStackMainAlignmentSpaceEvenly:
            *subNodeSpace = unusedWidth / (MAX(1, subNodes.count + 1) * 1.0);
            *firstSubNodeX = self.paddingLeft + *subNodeSpace;
            break;
            
        default:
            *firstSubNodeX = self.paddingLeft;
            break;
    }
}

static MLNUI_FORCE_INLINE CGFloat LayoutSingleLineSubNodeY(MLNUIHStackNode __unsafe_unretained *self, MLNUILayoutNode __unsafe_unretained *subNode, CGFloat maxHeight, CGFloat maxY) {
    CGFloat y = 0.0;
    switch (subNode.gravity & MLNUIGravityVerticalMask) { // 交叉轴方向布局优先以Gravity为准
        case MLNUIGravityTop:
            y = self.paddingTop + subNode.marginTop;
            break;
            
        case MLNUIGravityCenterVertical:
            y = self.paddingTop + (maxHeight - subNode.measuredHeight) / 2.0 + subNode.marginTop - subNode.marginBottom;
            break;
            
        case MLNUIGravityBottom:
            y = maxY - subNode.measuredHeight - subNode.marginBottom;
            break;
            
        default: // 若未设置Gravity，则以crossAxisAlignment为准.
            switch (self.crossAxisAlignment) {
                case MLNUIStackCrossAlignmentStart:
                    y = self.paddingTop + subNode.marginTop;
                    break;
                    
                case MLNUIStackCrossAlignmentCenter:
                    y = self.paddingTop + (maxHeight - subNode.measuredHeight) / 2.0f + subNode.marginTop - subNode.marginBottom;
                    break;
                    
                case MLNUIStackCrossAlignmentEnd:
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

static MLNUI_FORCE_INLINE CGFloat LayoutMultiLineSubNodeY(MLNUIHStackNode __unsafe_unretained *self, MLNUILayoutNode __unsafe_unretained *subNode, CGFloat lineHeight, CGFloat maxHeight, CGFloat maxY) {
    CGFloat y = 0.0; // 多行模式下交叉轴方向Gravity只针对每一行生效
    switch (subNode.gravity & MLNUIGravityVerticalMask) {
        case MLNUIGravityTop:
            y = self.paddingTop + subNode.marginTop;
            break;
            
        case MLNUIGravityCenterVertical:
            y = self.paddingTop + (lineHeight - subNode.measuredHeight) / 2.0 + subNode.marginTop - subNode.marginBottom;
            break;
            
        case MLNUIGravityBottom:
            y = lineHeight - subNode.measuredHeight - subNode.marginBottom;
            break;
            
        default:
            y = self.paddingTop + subNode.marginTop;
            break;
               
       }

    // 多行模式下crossAxisAlignment对所有行作为一个整体生效
    switch (self.crossAxisAlignment) {
        case MLNUIStackCrossAlignmentCenter:
            y += (maxHeight - self.subNodeTotalHeight) / 2.0f;
            break;
            
        case MLNUIStackCrossAlignmentEnd:
            y += (maxY - self.subNodeTotalHeight);
            break;
            
        case MLNUIStackCrossAlignmentStart:
        default:
            // do nothing
            break;
    }
    return y;
}

@end
