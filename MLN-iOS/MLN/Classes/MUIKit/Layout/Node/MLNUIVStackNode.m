//
//  MLNUIVStackNode.m
//  MLNUI
//
//  Created by MOMO on 2020/3/25.
//

#import "MLNUIVStackNode.h"
#import "MLNUIHeader.h"
#import "UIView+MLNUILayout.h"

@interface MLNUILayoutNodeColumn : NSObject
@property (nonatomic, assign) CGFloat value;
@end

@implementation MLNUILayoutNodeColumn
@end

#define MLNUI_MARK_DIRTY_AND_CACULATE_WEIGHT \
if (subNode.isGone) {\
    if (subNode.isDirty) needDirty = YES;\
    continue;\
}\
if (subNode.weight > 0 && subNode.heightType != MLNUILayoutNodeStatusIdle) {\
    *totalWeight += subNode.weight;\
}\
if (subNode.isDirty) {\
    needDirty = YES;\
} else if (needDirty) {\
    [subNode needLayout];\
}

@interface MLNUIVStackNode ()

@property (nonatomic, assign) CGFloat subNodeTotalWidth;
@property (nonatomic, strong) NSMutableArray<NSArray<MLNUILayoutNode *> *> *wrapLineNodes;
@property (nonatomic, assign) BOOL changedHeightToMatchParent;

@end

@implementation MLNUIVStackNode

- (NSMutableArray<NSArray<MLNUILayoutNode *> *> *)wrapLineNodes {
    if (!_wrapLineNodes) {
        _wrapLineNodes = [NSMutableArray array];
    }
    return _wrapLineNodes;
}

static const char MLNUIBelongColumnKey;
static MLNUI_FORCE_INLINE void SetBelongColumn(__unsafe_unretained MLNUILayoutNode *node, __unsafe_unretained MLNUILayoutNodeColumn *column) {
    objc_setAssociatedObject(node, &MLNUIBelongColumnKey, column, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static MLNUI_FORCE_INLINE MLNUILayoutNodeColumn *GetBelongColumn(__unsafe_unretained MLNUILayoutNode *node) {
    return objc_getAssociatedObject(node, &MLNUIBelongColumnKey);
}

#pragma mark - Override

- (void)changeHeight:(CGFloat)height {
    [super changeHeight:height];
    if (self.heightType == MLNUILayoutMeasurementTypeMatchParent) {
        _changedHeightToMatchParent = YES;
    }
}

- (void)invalidateMainAxisMatchParentMeasureType {
    if (self.heightType == MLNUILayoutMeasurementTypeMatchParent && !_changedHeightToMatchParent) {
        self.heightType = MLNUILayoutMeasurementTypeWrapContent;
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
        MeasureMultiColumnSize(self, subNods, CGSizeMake(usableZoneWidth, usableZoneHeight), &totalWidth, &totalHeight, &totalWeight);
    } else {
        MeasureSingleColumnSize(self, subNods, CGSizeMake(usableZoneWidth, usableZoneHeight), &totalWidth, &totalHeight, &totalWeight);
    }
    self.subNodeTotalWidth = MIN(myMaxWidth, MAX(self.minWidth, totalWidth));
    
    CGFloat measuredWidth = myMaxWidth;
    CGFloat measuredHeight = myMaxHeight;
    // width
    if (!self.isWidthExcatly) {
        switch (self.mergedWidthType) {
            case MLNUILayoutMeasurementTypeWrapContent:
                // padding
                totalWidth += self.paddingLeft + self.paddingRight;
                // max
                totalWidth = MIN(myMaxWidth, totalWidth);
                // min
                totalWidth = self.minWidth > 0 ? MAX(totalWidth, self.minWidth) : totalWidth;
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
                // max
                totalHeight = MIN(myMaxHeight, totalHeight);
                // min
                totalHeight = self.minHeight > 0 ? MAX(totalHeight, self.minHeight) : totalHeight;
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
        measureWidthForWeightVertical(self, subNods, measuredWidth, measuredHeight, myMaxWidth, totalWeight);
    }
    return CGSizeMake(self.measuredWidth, self.measuredHeight);
}

- (void)layoutSubnodes {
    CGFloat layoutZoneWidth = self.measuredWidth - self.paddingLeft - self.paddingRight;
    CGFloat layoutZoneRight = self.measuredWidth - self.paddingRight;
    CGFloat previousColumnWidth = 0.0;
    
    for (NSArray<MLNUILayoutNode *> *subNodes in self.wrapLineNodes) {
        CGFloat space = 0.0; // subNode之间的间隔
        CGFloat vernierY = 0.0; // 游标, 用于设置每个subNode的y坐标
        GetFirstSubNodeYAndSubNodeSpace(self, &vernierY, &space, subNodes);
    
        CGFloat childX, childY = 0.0;
        for (MLNUILayoutNode *subNode in subNodes) {
            if (subNode.isGone) continue;
            
            // 布局主轴(Y-axis)
            vernierY += subNode.marginTop;
            childY = vernierY;
            vernierY += subNode.measuredHeight + subNode.marginBottom + space;
            
            // 布局交叉轴(X-axis)
            if (MLNUI_IS_WRAP_MODE == NO) {
                childX = LayoutSingleColumnSubNodeX(self, subNode, layoutZoneWidth, layoutZoneRight);
            } else {
                CGFloat columnWidth = GetBelongColumn(subNode).value;
                childX = LayoutMultiColumnSubNodeX(self, subNode, columnWidth, layoutZoneWidth, layoutZoneRight);
            }
            
            // set frame
            subNode.measuredX = childX + previousColumnWidth;
            subNode.measuredY = childY;
            [subNode updateTargetViewFrameIfNeed];
            
            if (subNode.isContainer) {
                [(MLNUILayoutContainerNode *)subNode layoutSubnodes];
            }
            if (subNode.overlayNode) {
                [subNode layoutOverlayNode];
            }
        }
        
        if (subNodes.count > 0 && GetBelongColumn(subNodes[0])) {
            previousColumnWidth += GetBelongColumn(subNodes[0]).value;
        }
    }
}

#pragma mark - Private (Measure)

static MLNUI_FORCE_INLINE CGSize GetSubNodeSize(__unsafe_unretained MLNUILayoutNode *subNode, CGFloat subNodeMaxWidth,  CGFloat subNodeMaxHeight) {
    CGSize subNodeSize = [subNode measureSizeWithMaxWidth:subNodeMaxWidth maxHeight:subNodeMaxHeight];
    if (subNode.layoutStrategy == MLNUILayoutStrategySimapleAuto) {
        subNodeSize.width += (subNode.marginLeft + subNode.marginRight);
        subNodeSize.height += (subNode.marginTop + subNode.marginBottom);
    }
    return subNodeSize;
}

static MLNUI_FORCE_INLINE void MeasureSingleColumnSize(__unsafe_unretained MLNUIVStackNode *self, __unsafe_unretained NSArray<MLNUILayoutNode *> *subNodes, CGSize maxSize, CGFloat *totalWidth, CGFloat *totalHeight, NSInteger *totalWeight) {
    BOOL needDirty = NO;
    NSMutableArray<MLNUILayoutNode *> *lineNodes = [NSMutableArray array];
    NSMutableArray<MLNUILayoutNode *> *forceUseMatchParentNodes = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < subNodes.count; i++) {
        MLNUILayoutNode *subNode = subNodes[i];
        MLNUI_MARK_DIRTY_AND_CACULATE_WEIGHT
        
        CGFloat subNodeMaxWidth = maxSize.width - subNode.marginLeft - subNode.marginRight;
        CGFloat subNodeMaxHeight = maxSize.height - subNode.marginTop - subNode.marginBottom - *totalHeight;
        CGSize subNodeSize = GetSubNodeSize(subNode, subNodeMaxWidth, subNodeMaxHeight); // 计算子节点
        if (MLNUI_NODE_WIDTH_SHOULD_FORCE_USE_MATCHPARENT(subNode)) {
            [forceUseMatchParentNodes addObject:subNode];
        }
        
        *totalWidth = MAX(*totalWidth, subNodeSize.width);
        *totalHeight = MAX(*totalHeight, *totalHeight + subNodeSize.height);
        [lineNodes addObject:subNode];
    };
    
    if (lineNodes.count > 0) {
        [self.wrapLineNodes addObject:lineNodes];
    }
    for (MLNUILayoutNode *node in forceUseMatchParentNodes) {
        [node forceUseMatchParentForWidthMeasureType];
        [node measureSizeWithMaxWidth:(*totalWidth - node.marginLeft - node.marginRight) maxHeight:node.measuredHeight];
    }
}

static MLNUI_FORCE_INLINE void MeasureMultiColumnSize(__unsafe_unretained MLNUIVStackNode *self, __unsafe_unretained NSArray<MLNUILayoutNode *> *subNodes, CGSize maxSize, CGFloat *totalWidth, CGFloat *totalHeight, NSInteger *totalWeight) {
    BOOL needDirty = NO;
    CGFloat currentColumnWidth = 0.0;
    CGFloat currentColumnHeight = 0.0;
    MLNUILayoutNodeColumn *belongColumn = [MLNUILayoutNodeColumn new];
    NSMutableArray<MLNUILayoutNode *> *lineNodes = [NSMutableArray array];
    NSMutableArray<MLNUILayoutNode *> *shouldUseMatchParentNodes = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < subNodes.count; i++) {
        MLNUILayoutNode *subNode = subNodes[i];
        MLNUI_MARK_DIRTY_AND_CACULATE_WEIGHT
        
        BOOL shouldUseMatchParent = NO;
        if (subNode.widthType == MLNUILayoutMeasurementTypeMatchParent) {
            subNode.widthType = MLNUILayoutMeasurementTypeWrapContent;
            shouldUseMatchParent = YES; // 换行模式下，宽度为MatchParent节点要以WrapContent来测量
        }
        
        CGFloat subNodeMaxWidth = maxSize.width - subNode.marginLeft - subNode.marginRight;
        CGFloat subNodeMaxHeight = maxSize.height - subNode.marginTop - subNode.marginBottom;
        CGSize subNodeSize = GetSubNodeSize(subNode, subNodeMaxWidth, subNodeMaxHeight); // 计算子节点
        if (shouldUseMatchParent) {
            [shouldUseMatchParentNodes addObject:subNode];
            subNode.widthType = MLNUILayoutMeasurementTypeMatchParent;
        }
        
        // 判断当前列剩余高度是否可容纳下一个子view && 如果是WrapContent则每个子view单独占一列
        if ((maxSize.height - currentColumnHeight > subNodeSize.height) && self.mergedHeightType != MLNUILayoutMeasurementTypeWrapContent) {
            [lineNodes addObject:subNode];
            
            currentColumnWidth = MAX(currentColumnWidth, subNodeSize.width);
            currentColumnHeight += subNodeSize.height;
            
            belongColumn.value = currentColumnWidth;
            SetBelongColumn(subNode, belongColumn); // 每一列的列宽取决于当前列最大宽度的subNode
        } else {
            [self.wrapLineNodes addObject:[lineNodes copy]];
            [lineNodes removeAllObjects];
            [lineNodes addObject:subNode];
            
            *totalWidth += currentColumnWidth; // 换列后累加上一列宽度
            currentColumnWidth = subNodeSize.width;
            currentColumnHeight = subNodeSize.height;
            
            belongColumn = [MLNUILayoutNodeColumn new]; // 换行后重新分配列宽
            belongColumn.value = currentColumnWidth;
            SetBelongColumn(subNode, belongColumn);
        }
        *totalHeight = MAX(*totalHeight, currentColumnHeight);
    };
    
    *totalWidth += currentColumnWidth; // 累加最后一列宽度
    if (lineNodes.count > 0) {
        [self.wrapLineNodes addObject:lineNodes];
    }
    for (MLNUILayoutNode *node in shouldUseMatchParentNodes) {
        [node forceUseMatchParentForWidthMeasureType];
        CGFloat maxWidth = GetBelongColumn(node).value - node.marginLeft - node.marginRight; // 对于width为MatchParent的节点，宽度应为其所在列的列宽
        [node measureSizeWithMaxWidth:maxWidth maxHeight:node.measuredHeight];
    }
}

MLNUI_FORCE_INLINE void measureWidthForWeightVertical(MLNUIStackNode __unsafe_unretained *self, NSArray<MLNUILayoutNode *> __unsafe_unretained *subNods, CGFloat measuredWidth, CGFloat measuredHeight, CGFloat myMaxWidth,  NSInteger totalWeight) {
    CGFloat usableZoneWidth = myMaxWidth - self.paddingLeft - self.paddingRight;
    CGFloat usableZoneHeight = measuredHeight - self.paddingTop - self.paddingBottom;
    
    BOOL needDirty = NO;

    NSMutableArray<MLNUILayoutNode *> *proportionNodes = [NSMutableArray arrayWithCapacity:subNods.count];
    for (NSUInteger i  = 0; i < subNods.count; i++) {
        MLNUILayoutNode *subnode = subNods[i];
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
    
    CGFloat totalWidth = 0.f;
    NSMutableArray<MLNUILayoutNode *> *forceUseMatchParentNodes = [NSMutableArray array];
    
    for (MLNUILayoutNode *subnode in proportionNodes) {
        CGFloat subMaxWidth = usableZoneWidth - subnode.marginLeft - subnode.marginRight;
        CGFloat subMaxHeight = usableZoneHeight;
        CGSize subMeasuredSize = [subnode measureSizeWithMaxWidth:subMaxWidth maxHeight:subMaxHeight]; // 计算子节点
        if (MLNUI_NODE_WIDTH_SHOULD_FORCE_USE_MATCHPARENT(subnode)) {
            [forceUseMatchParentNodes addObject:subnode];
        }
        subnode.heightProportion = 0; // 清空权重
        usableZoneHeight -= subMeasuredSize.height;
        switch (subnode.layoutStrategy) {
            case MLNUILayoutStrategyNativeFrame:
                totalWidth = MAX(totalWidth, subMeasuredSize.width);
                break;
            default: {
                totalWidth = MAX(totalWidth, subMeasuredSize.width + subnode.marginLeft + subnode.marginRight);
                break;
            }
        }
    }
    
    for (MLNUILayoutNode *node in forceUseMatchParentNodes) {
        [node forceUseMatchParentForWidthMeasureType];
        CGFloat maxWidth = MAX(totalWidth, self.measuredWidth - self.paddingLeft - self.paddingRight) - node.marginLeft - node.marginRight;
        CGFloat originHeight = node.measuredHeight;
        [node measureSizeWithMaxWidth:maxWidth maxHeight:originHeight];
        node.measuredHeight = originHeight; // 高度应保持不变，否则权重将失效
    }
    
    // width
    if (!self.isWidthExcatly) {
        switch (self.mergedWidthType) {
            case MLNUILayoutMeasurementTypeWrapContent:
                // padding
                totalWidth += self.paddingLeft + self.paddingRight;
                // max
                totalWidth = MIN(measuredWidth, totalWidth);
                // min
                totalWidth = self.minWidth > 0 ? MAX(totalWidth, self.minWidth) : totalWidth;
                measuredWidth = totalWidth;
                break;
            case MLNUILayoutMeasurementTypeMatchParent:
                measuredWidth = MAX(self.minWidth, myMaxWidth);
                break;
            default:
                measuredWidth = myMaxWidth;
                break;
        }
        if (measuredWidth > self.measuredWidth) {
            self.measuredWidth = measuredWidth;
        }
    }
}

#pragma mark - Private (Layout)

static MLNUI_FORCE_INLINE void GetFirstSubNodeYAndSubNodeSpace(MLNUIVStackNode __unsafe_unretained *self, CGFloat *firstSubNodeY, CGFloat *subNodeSpace, NSArray<MLNUILayoutNode *> __unsafe_unretained *subNodes) {
    if (self.mergedHeightType == MLNUILayoutMeasurementTypeWrapContent) {
        *firstSubNodeY = self.paddingTop; // WrapContent模式下不会有多余间距
        return;
    }
    
    CGFloat totalHeight = 0.0;
    for (MLNUILayoutNode *node in subNodes) {
        totalHeight += node.marginTop + node.measuredHeight + node.marginBottom;
    }
    CGFloat maxHeight = self.measuredHeight - self.paddingTop - self.paddingBottom;
    CGFloat unusedHeigt = MAX(0, (maxHeight - totalHeight));
    
    switch (self.mainAxisAlignment) {
        case MLNUIStackMainAlignmentStart:
            *firstSubNodeY = self.paddingTop;
            break;
            
        case MLNUIStackMainAlignmentCenter:
            *firstSubNodeY = unusedHeigt / 2.0;
            break;
            
        case MLNUIStackMainAlignmentEnd:
            *firstSubNodeY = self.paddingTop + unusedHeigt;
            break;
            
        case MLNUIStackMainAlignmentSpaceBetween:
            *subNodeSpace = unusedHeigt / (MAX(1, (subNodes.count - 1)) * 1.0);
            *firstSubNodeY = self.paddingTop;
            break;
            
        case MLNUIStackMainAlignmentSpaceAround:
            *subNodeSpace = unusedHeigt / (MAX(1, subNodes.count) * 1.0);
            *firstSubNodeY = self.paddingTop + *subNodeSpace / 2.0;
            break;
            
        case MLNUIStackMainAlignmentSpaceEvenly:
            *subNodeSpace = unusedHeigt / (MAX(1, subNodes.count + 1) * 1.0);
            *firstSubNodeY = self.paddingTop + *subNodeSpace;
            break;
            
        default:
            *firstSubNodeY = self.paddingTop;
            break;
    }
}

static MLNUI_FORCE_INLINE CGFloat LayoutSingleColumnSubNodeX(MLNUIVStackNode __unsafe_unretained *self, MLNUILayoutNode __unsafe_unretained *subNode, CGFloat maxWidth, CGFloat maxX) {
    CGFloat x = 0.0;
    switch (subNode.gravity & MLNUIGravityHorizontalMask) { // 交叉轴方向布局优先以Gravity为准
        case MLNUIGravityLeft:
            x = self.paddingLeft + subNode.marginLeft;
            break;
            
        case MLNUIGravityCenterHorizontal:
            x = self.paddingLeft + (maxWidth - subNode.measuredWidth) / 2.0 + subNode.marginLeft - subNode.marginRight;
            break;
            
        case MLNUIGravityRight:
            x = maxX - subNode.measuredWidth - subNode.marginRight;
            break;
            
        default: // 若未设置Gravity，则以crossAxisAlignment为准.
            switch (self.crossAxisAlignment) {
                case MLNUIStackCrossAlignmentStart:
                    x = self.paddingLeft + subNode.marginLeft;
                    break;
                case MLNUIStackCrossAlignmentCenter:
                    x = self.paddingLeft + (maxWidth - subNode.measuredWidth) / 2.0f + subNode.marginLeft - subNode.marginRight;
                    break;
                case MLNUIStackCrossAlignmentEnd:
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

static MLNUI_FORCE_INLINE CGFloat LayoutMultiColumnSubNodeX(MLNUIVStackNode __unsafe_unretained *self, MLNUILayoutNode __unsafe_unretained *subNode, CGFloat columnWidth, CGFloat maxWidth, CGFloat maxX) {
    CGFloat x = 0.0; // 多列模式下交叉轴方向Gravity只针对每一列生效
    switch (subNode.gravity & MLNUIGravityHorizontalMask) {
        case MLNUIGravityLeft:
            x = self.paddingLeft + subNode.marginLeft;
            break;
            
        case MLNUIGravityCenterHorizontal:
            x = self.paddingLeft + (columnWidth - subNode.measuredWidth) / 2.0 + subNode.marginLeft - subNode.marginRight;
            break;
            
        case MLNUIGravityRight:
            x = columnWidth - subNode.measuredWidth - subNode.marginRight;
            break;
            
        default:
            x = self.paddingLeft + subNode.marginLeft;
            break;
            
    }

    // 多列模式下crossAxisAlignment对所有列作为一个整体生效
    switch (self.crossAxisAlignment) {
        case MLNUIStackCrossAlignmentCenter:
            x += (maxWidth - self.subNodeTotalWidth) / 2.0f;
            break;
            
        case MLNUIStackCrossAlignmentEnd:
            x += (maxX - self.subNodeTotalWidth);
            break;
            
        case MLNUIStackCrossAlignmentStart:
        default:
            // do nothing
            break;
    }
    return x;
}

@end
