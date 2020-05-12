//
//  MLNVStackNode.m
//  MLN
//
//  Created by MOMO on 2020/3/25.
//

#import "MLNVStackNode.h"
#import "MLNSpacerNode.h"
#import "MLNHeader.h"
#import "UIView+MLNLayout.h"

@interface MLNLayoutNodeColumn : NSObject
@property (nonatomic, assign) CGFloat value;
@end

@implementation MLNLayoutNodeColumn
@end

#define MLN_MARK_DIRTY_AND_CACULATE_WEIGHT \
if (subNode.isGone) {\
    if (subNode.isDirty) needDirty = YES;\
    continue;\
}\
if (subNode.weight > 0 && subNode.heightType != MLNLayoutNodeStatusIdle) {\
    *totalWeight += subNode.weight;\
}\
if (subNode.isDirty) {\
    needDirty = YES;\
} else if (needDirty) {\
    [subNode needLayout];\
}

@interface MLNVStackNode ()

@property (nonatomic, assign) CGFloat subNodeTotalWidth;
@property (nonatomic, strong) NSMutableArray<NSArray<MLNLayoutNode *> *> *wrapLineNodes;

@end

@implementation MLNVStackNode

- (NSMutableArray<NSArray<MLNLayoutNode *> *> *)wrapLineNodes {
    if (!_wrapLineNodes) {
        _wrapLineNodes = [NSMutableArray array];
    }
    return _wrapLineNodes;
}

#pragma mark - Private

static const char MLNBelongColumnKey;
static MLN_FORCE_INLINE void SetBelongColumn(__unsafe_unretained MLNLayoutNode *node, __unsafe_unretained MLNLayoutNodeColumn *column) {
    objc_setAssociatedObject(node, &MLNBelongColumnKey, column, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static MLN_FORCE_INLINE MLNLayoutNodeColumn *GetBelongColumn(__unsafe_unretained MLNLayoutNode *node) {
    return objc_getAssociatedObject(node, &MLNBelongColumnKey);
}

static MLN_FORCE_INLINE void AdjustMeasuredWidthForSubNodes(__unsafe_unretained MLNLayoutNode *node) {
    NSArray<UIView *> *subViews = [node.targetView subviews];
    if (subViews.count == 0) return;
    [subViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.lua_node.measuredWidth = node.measuredWidth;
    }];
}

static MLN_FORCE_INLINE CGSize GetSubNodeSize(__unsafe_unretained MLNLayoutNode *subNode, CGFloat subNodeMaxWidth,  CGFloat subNodeMaxHeight) {
    CGSize subNodeSize = [subNode measureSizeWithMaxWidth:subNodeMaxWidth maxHeight:subNodeMaxHeight];
    if (subNode.layoutStrategy == MLNLayoutStrategySimapleAuto) {
        subNodeSize.width += (subNode.marginLeft + subNode.marginRight);
        subNodeSize.height += (subNode.marginTop + subNode.marginBottom);
    }
    return subNodeSize;
}

static MLN_FORCE_INLINE void MeasureSingleLineSize(__unsafe_unretained MLNVStackNode *self, __unsafe_unretained NSArray<MLNLayoutNode *> *subNodes, CGSize maxSize, CGFloat *totalWidth, CGFloat *totalHeight, NSInteger *totalWeight) {
    BOOL needDirty = NO;
    NSMutableArray<MLNLayoutNode *> *lineNodes = [NSMutableArray array];
    NSMutableArray<MLNLayoutNode *> *forceUseMatchParentNodes = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < subNodes.count; i++) {
        MLNLayoutNode *subNode = subNodes[i];
        MLN_MARK_DIRTY_AND_CACULATE_WEIGHT
        
        CGFloat subNodeMaxWidth = maxSize.width - subNode.marginLeft - subNode.marginRight;
        CGFloat subNodeMaxHeight = maxSize.height - subNode.marginTop - subNode.marginBottom - *totalHeight;
        CGSize subNodeSize = GetSubNodeSize(subNode, subNodeMaxWidth, subNodeMaxHeight); // 计算子节点
        if (MLN_NODE_WIDTH_SHOULD_FORCE_USE_MATCHPARENT(subNode)) {
            [forceUseMatchParentNodes addObject:subNode];
        }
        
        *totalWidth = MAX(*totalWidth, subNodeSize.width);
        *totalHeight = MAX(*totalHeight, *totalHeight + subNodeSize.height);
        [lineNodes addObject:subNode];
    };
    
    if (lineNodes.count > 0) {
        [self.wrapLineNodes addObject:lineNodes];
    }
    for (MLNLayoutNode *node in forceUseMatchParentNodes) {
        node.measuredWidth = *totalWidth;
        AdjustMeasuredWidthForSubNodes(node);
    }
}

static MLN_FORCE_INLINE void MeasureMultiLineSize(__unsafe_unretained MLNVStackNode *self, __unsafe_unretained NSArray<MLNLayoutNode *> *subNodes, CGSize maxSize, CGFloat *totalWidth, CGFloat *totalHeight, NSInteger *totalWeight) {
    BOOL needDirty = NO;
    CGFloat currentLineWidth = 0.0;
    CGFloat currentLineHeight = 0.0;
    MLNLayoutNodeColumn *belongColumn = [MLNLayoutNodeColumn new];
    NSMutableArray<MLNLayoutNode *> *lineNodes = [NSMutableArray array];
    NSMutableArray<MLNLayoutNode *> *shouldUseMatchParentNodes = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < subNodes.count; i++) {
        MLNLayoutNode *subNode = subNodes[i];
        MLN_MARK_DIRTY_AND_CACULATE_WEIGHT
        
        BOOL shouldUseMatchParent = NO;
        if (subNode.widthType == MLNLayoutMeasurementTypeMatchParent) {
            subNode.widthType = MLNLayoutMeasurementTypeWrapContent;
            shouldUseMatchParent = YES; // 换行模式下，宽度为MatchParent节点要以WrapContent来测量
        }
        
        CGFloat subNodeMaxWidth = maxSize.width - subNode.marginLeft - subNode.marginRight;
        CGFloat subNodeMaxHeight = maxSize.height - subNode.marginTop - subNode.marginBottom;
        CGSize subNodeSize = GetSubNodeSize(subNode, subNodeMaxWidth, subNodeMaxHeight); // 计算子节点
        if (shouldUseMatchParent) {
            [shouldUseMatchParentNodes addObject:subNode];
            subNode.widthType = MLNLayoutMeasurementTypeMatchParent;
        }
        
        // 判断当前列剩余高度是否可容纳下一个子view && 如果是WrapContent则每个子view单独占一列
        if ((maxSize.height - currentLineHeight > subNodeSize.height) && self.mergedHeightType != MLNLayoutMeasurementTypeWrapContent) {
            [lineNodes addObject:subNode];
            
            currentLineWidth = MAX(currentLineWidth, subNodeSize.width);
            currentLineHeight += subNodeSize.height;
            
            belongColumn.value = currentLineWidth;
            SetBelongColumn(subNode, belongColumn); // 每一列的列宽取决于当前列最大宽度的subNode
        } else {
            [self.wrapLineNodes addObject:[lineNodes copy]];
            [lineNodes removeAllObjects];
            [lineNodes addObject:subNode];
            
            currentLineWidth = subNodeSize.width;
            currentLineHeight = subNodeSize.height;
            *totalWidth += currentLineWidth;
            
            belongColumn = [MLNLayoutNodeColumn new]; // 换行后重新分配列宽
            belongColumn.value = currentLineWidth;
            SetBelongColumn(subNode, belongColumn);
        }
        *totalWidth = MAX(*totalWidth, currentLineWidth);
        *totalHeight = MAX(*totalHeight, currentLineHeight);
    };
    
    if (lineNodes.count > 0) {
        [self.wrapLineNodes addObject:lineNodes];
    }
    for (MLNLayoutNode *node in shouldUseMatchParentNodes) {
        node.measuredWidth = GetBelongColumn(node).value; // 对于width为MatchParent的节点，宽度应为其所在列的列宽
        AdjustMeasuredWidthForSubNodes(node);
    }
}

#pragma mark - Override

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
    
    if (self.wrapType == MLNStackWrapTypeWrap) {
        MeasureMultiLineSize(self, subNods, CGSizeMake(usableZoneWidth, usableZoneHeight), &totalWidth, &totalHeight, &totalWeight);
    } else {
        MeasureSingleLineSize(self, subNods, CGSizeMake(usableZoneWidth, usableZoneHeight), &totalWidth, &totalHeight, &totalWeight);
    }
    self.subNodeTotalWidth = MIN(myMaxWidth, MAX(self.minWidth, totalWidth));
    
    CGFloat measuredWidth = myMaxWidth;
    CGFloat measuredHeight = myMaxHeight;
    // width
    if (!self.isWidthExcatly) {
        switch (self.mergedWidthType) {
            case MLNLayoutMeasurementTypeWrapContent:
                // padding
                totalWidth += self.paddingLeft + self.paddingRight;
                // max
                totalWidth = MIN(myMaxWidth, totalWidth);
                // min
                totalWidth = self.minWidth > 0 ? MAX(totalWidth, self.minWidth) : totalWidth;
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
    CGFloat previousColumnWidth = 0.0;
    
    for (NSArray<MLNLayoutNode *> *subNodes in self.wrapLineNodes) {
        CGFloat space = 0.0; // subNode之间的间隔
        CGFloat vernierY = 0.0; // 游标, 用于设置每个subNode的y坐标
        CGFloat spacerHeight = 0.0; // spacer的高度
        GetFirstSubNodeYAndSubNodeSpace(self, &vernierY, &space, &spacerHeight, subNodes);
    
        CGFloat childX, childY = 0.0;
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
            CGFloat maxWidth = layoutZoneWidth;
            CGFloat maxX = layoutZoneRight;
            if (self.wrapType == MLNStackWrapTypeWrap) {
                maxWidth = GetBelongColumn(subNode).value;
                maxX = maxWidth;
            }
            childX = GetSubNodeGravityX(self, subNode, maxWidth, maxX);
            childX = GetSubNodeCrossAxisAlignmentX(self, subNode, childX, layoutZoneWidth, layoutZoneRight);
            
            // set frame
            subNode.measuredX = childX + previousColumnWidth;
            subNode.measuredY = childY;
            [subNode updateTargetViewFrameIfNeed];
            
            if (subNode.isContainer) {
                [(MLNLayoutContainerNode *)subNode layoutSubnodes];
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

#pragma mark -

static MLN_FORCE_INLINE void GetFirstSubNodeYAndSubNodeSpace(MLNVStackNode __unsafe_unretained *self, CGFloat *firstSubNodeY, CGFloat *subNodeSpace, CGFloat *spacerHeight, NSArray<MLNLayoutNode *> __unsafe_unretained *subNodes) {
    if (self.mergedHeightType == MLNLayoutMeasurementTypeWrapContent) {
        *firstSubNodeY = self.paddingTop; // WrapContent模式下不会有多余间距
        return;
    }
    
    int validSpacerCount = 0; // 没有设置height的spacerNode
    CGFloat totalHeight = 0.0;
    for (MLNLayoutNode *node in subNodes) {
        if (MLN_IS_EXPANDED_SPACER_NODE_IN_VSTACK(node)) {
            validSpacerCount++;
            continue; // 具有扩展特性的Spacer不应参与宽度计算
        }
        totalHeight += node.marginTop + node.measuredHeight + node.marginBottom;
    }
    CGFloat maxHeight = self.measuredHeight - self.paddingTop - self.paddingBottom;
    CGFloat unusedHeigt = MAX(0, (maxHeight - totalHeight));
    
    MLNStackMainAlignment mainAlignment = self.mainAxisAlignment;
    if (validSpacerCount > 0) { // 如果有Spacer, 则主轴上AxisAlignment均无效
        mainAlignment = MLNStackMainAlignmentInvalid;
        *spacerHeight = unusedHeigt / validSpacerCount;
    }
    
    switch (mainAlignment) {
        case MLNStackMainAlignmentStart:
            *firstSubNodeY = self.paddingTop;
            break;
            
        case MLNStackMainAlignmentCenter:
            *firstSubNodeY = unusedHeigt / 2.0;
            break;
            
        case MLNStackMainAlignmentEnd:
            *firstSubNodeY = unusedHeigt;
            break;
            
        case MLNStackMainAlignmentSpaceBetween:
            *subNodeSpace = unusedHeigt / (MAX(1, (subNodes.count - 1)) * 1.0);
            *firstSubNodeY = self.paddingTop;
            break;
            
        case MLNStackMainAlignmentSpaceAround:
            *subNodeSpace = unusedHeigt / (MAX(1, subNodes.count) * 1.0);
            *firstSubNodeY = self.paddingTop + *subNodeSpace / 2.0;
            break;
            
        case MLNStackMainAlignmentSpaceEvenly:
            *subNodeSpace = unusedHeigt / (MAX(1, subNodes.count + 1) * 1.0);
            *firstSubNodeY = self.paddingTop + *subNodeSpace;
            break;
            
        default:
            *firstSubNodeY = self.paddingTop;
            break;
    }
}


static MLN_FORCE_INLINE CGFloat GetSubNodeGravityX(MLNVStackNode __unsafe_unretained *self, MLNLayoutNode __unsafe_unretained *subNode, CGFloat maxWidth, CGFloat maxX) {
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
            x = -1;
            break;
            
    }
    return x;
}

static MLN_FORCE_INLINE CGFloat GetSubNodeCrossAxisAlignmentX(MLNVStackNode __unsafe_unretained *self, MLNLayoutNode __unsafe_unretained *subNode, CGFloat x, CGFloat maxWidth, CGFloat maxX) {
    if (self.wrapType != MLNStackWrapTypeWrap) {
        if (x >= 0) return x; // 如果非换行模式，交叉轴方向布局优先以Gravity为准，若未设置Gravity，则以crossAxisAlignment为准.
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
        return x;
    }
    
    // 换行模式下Gravity只针对每一行生效，而crossAxisAlignment对所有行作为一个整体生效
    if (x < 0) {
        x = self.paddingLeft + subNode.marginLeft;
    }
    switch (self.crossAxisAlignment) {
        case MLNStackCrossAlignmentCenter:
            x += (maxWidth - self.subNodeTotalWidth) / 2.0f;
            break;
            
        case MLNStackCrossAlignmentEnd:
            x += (maxX - self.subNodeTotalWidth);
            break;
            
        case MLNStackCrossAlignmentStart:
        default:
            // do nothing
            break;
    }
    return x;
}

MLN_FORCE_INLINE void measureWidthForWeightVertical(MLNStackNode __unsafe_unretained *node, NSArray<MLNLayoutNode *> __unsafe_unretained *subNods, CGFloat measuredWidth, CGFloat measuredHeight, CGFloat myMaxWidth,  NSInteger totalWeight) {
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
        if (measuredWidth > node.measuredWidth) {
            node.measuredWidth = measuredWidth;
        }
    }
}

@end
