//
//  MLNHStackNode.m
//  MLN
//
//  Created by MOMO on 2020/3/25.
//

#import "MLNHStackNode.h"
#import "MLNSpacerNode.h"
#import "MLNHeader.h"

#define MLN_SHOULD_WRAP (self.wrapType == MLNStackWrapTypeWrap)

@interface MLNHStackNode ()

@property (nonatomic, assign) CGFloat subNodeTotalHeight;
@property (nonatomic, strong) NSMutableArray<NSArray<MLNLayoutNode *> *> *wrapLineNodes;

@end

@implementation MLNHStackNode

- (NSMutableArray<NSArray<MLNLayoutNode *> *> *)wrapLineNodes {
    if (!_wrapLineNodes) {
        _wrapLineNodes = [NSMutableArray array];
    }
    return _wrapLineNodes;
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
    BOOL needDirty = NO;
    int totalWeight = 0;
    
    CGFloat currentLineWidth = 0.0f;
    CGFloat currentLineHeight = 0.0f;
    MLNLayoutNode *belongLineNode = [MLNLayoutNode new];
    
    NSMutableArray<MLNLayoutNode *> *lineNodes = [NSMutableArray array];
   
    for (NSUInteger i = 0; i < subNods.count; i++) {
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
        
        CGFloat subMaxWidth = usableZoneWidth - subnode.marginLeft - subnode.marginRight;
        if (MLN_SHOULD_WRAP == NO) { // 非换行模式最大宽度限制要剔除已计算的子view宽度
            subMaxWidth -= totalWidth;
        }
        CGFloat subMaxHeight = usableZoneHeight - subnode.marginTop - subnode.marginBottom;
        CGSize subMeasuredSize = [subnode measureSizeWithMaxWidth:subMaxWidth maxHeight:subMaxHeight]; // 计算子节点
        
        CGFloat subNodeWidth = subMeasuredSize.width;
        CGFloat subNodeHeight = subMeasuredSize.height;
        if (subnode.layoutStrategy == MLNLayoutStrategySimapleAuto) {
            subNodeWidth += (subnode.marginLeft + subnode.marginRight);
            subNodeHeight += (subnode.marginTop + subnode.marginBottom);
        }
        
        if (MLN_SHOULD_WRAP) {
            if ((usableZoneWidth - currentLineWidth > subNodeWidth) && self.mergedWidthType != MLNLayoutMeasurementTypeWrapContent) { // 判断当前行剩余宽度是否可容纳下一个子view && 如果是WrapContent则每个子view单独占一行
                [lineNodes addObject:subnode];
                
                currentLineWidth += subNodeWidth;
                currentLineHeight = MAX(currentLineHeight, subNodeHeight);
                
                belongLineNode.belongLineHeight = currentLineHeight;
                subnode.belongLineNode = belongLineNode; // 每一行的行高取决于当前行最大高度的subNode，遍历过程中为了使每一行的所有subNode所属行高都能及时更新
            } else {
                [self.wrapLineNodes addObject:[lineNodes copy]];
                [lineNodes removeAllObjects];
                [lineNodes addObject:subnode];
                
                currentLineWidth = subNodeWidth;
                currentLineHeight = subNodeHeight;
                totalHeight += currentLineHeight;
                
                belongLineNode = [MLNLayoutNode new]; // 换行后重新分配行高
                belongLineNode.belongLineHeight = currentLineHeight;
                subnode.belongLineNode = belongLineNode;
            }
            totalWidth = MAX(totalWidth, currentLineWidth);
            totalHeight = MAX(totalHeight, currentLineHeight);
            
        } else {
            totalWidth = MAX(totalWidth, totalWidth + subNodeWidth);
            totalHeight = MAX(totalHeight, subNodeHeight);
            [lineNodes addObject:subnode];
        }
    };
    
    if (lineNodes.count > 0) {
        [self.wrapLineNodes addObject:lineNodes];
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
    if (totalWeight > 0) {
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
        CGFloat spacerWidth = 0.0; // spacer的宽度
        GetFirstSubNodeXAndSubNodeSpace(self, &vernierX, &space, &spacerWidth, subNodes);
    
        CGFloat childX, childY = 0.0;
        for (MLNLayoutNode *subNode in subNodes) {
            if (subNode.isGone) continue;
            if (MLN_IS_EXPANDED_SPACER_NODE_IN_HSTACK(subNode)) {
                subNode.measuredWidth = spacerWidth;
            }

            // 布局主轴(X-axis)
            vernierX += subNode.marginLeft;
            childX = vernierX;
            vernierX += subNode.measuredWidth + subNode.marginRight + space;
            
            // 布局交叉轴(Y-axis)
            CGFloat maxHeight = layoutZoneHeight;
            CGFloat maxY = layoutZoneBottom;
            if (self.wrapType == MLNStackWrapTypeWrap) {
                maxHeight = subNode.belongLineNode.belongLineHeight;
                maxY = maxHeight;
            }
            childY = GetSubNodeGravityY(self, subNode, maxHeight, maxY);
            childY = GetSubNodeCrossAxisAlignmentY(self, subNode, childY, layoutZoneHeight, layoutZoneBottom);
 
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
        
        if (subNodes[0].belongLineNode) {
            previousLineHeight += subNodes[0].belongLineNode.belongLineHeight;
        }
    }
}

#pragma mark -

static MLN_FORCE_INLINE void GetFirstSubNodeXAndSubNodeSpace(MLNHStackNode __unsafe_unretained *self, CGFloat *firstSubNodeX, CGFloat *subNodeSpace, CGFloat *spacerWidth, NSArray<MLNLayoutNode *> *subNodes) {
    if (self.mergedWidthType == MLNLayoutMeasurementTypeWrapContent) {
        *firstSubNodeX = self.paddingLeft;
        return;
    }
    
    int validSpacerCount = 0; // 没有设置width的spacerNode
    CGFloat totalWidth = 0.0;
    for (MLNLayoutNode *node in subNodes) {
        if (MLN_IS_EXPANDED_SPACER_NODE_IN_HSTACK(node)) {
            validSpacerCount++;
            continue; // 具有扩展特性的Spacer不应参与宽度计算
        }
        totalWidth += node.marginLeft + node.measuredWidth + node.marginRight;
    }
    CGFloat maxWidth = self.measuredWidth - self.paddingLeft - self.paddingRight;
    CGFloat unusedWidth = MAX(0, (maxWidth - totalWidth));
    
    MLNStackMainAlignment mainAlignment = self.mainAxisAlignment;
    if (validSpacerCount > 0) { // 如果有Spacer, 则主轴上AxisAlignment均无效
        mainAlignment = MLNStackMainAlignmentInvalid;
        *spacerWidth = unusedWidth / validSpacerCount;
    }
    
    switch (mainAlignment) {
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

static MLN_FORCE_INLINE CGFloat GetSubNodeGravityY(MLNHStackNode __unsafe_unretained *self, MLNLayoutNode __unsafe_unretained *subNode, CGFloat maxHeight, CGFloat maxY) {
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
            y = -1;
            break;
            
    }
    return y;
}

static MLN_FORCE_INLINE CGFloat GetSubNodeCrossAxisAlignmentY(MLNHStackNode __unsafe_unretained *self, MLNLayoutNode __unsafe_unretained *subNode, CGFloat y, CGFloat maxHeight, CGFloat maxY) {
    if (self.wrapType != MLNStackWrapTypeWrap) {
        if (y >= 0) return y; // 如果非换行模式，交叉轴方向布局优先以Gravity为准，若未设置Gravity，则以crossAxisAlignment为准.
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
        return y;
    }
    
    // 换行模式下Gravity只针对每一行生效，而crossAxisAlignment对所有行作为一个整体生效
    if (y < 0) {
        y = self.paddingTop + subNode.marginTop;
    }
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
        if (measuredHeight > 0) { // 如果为0，不应修改node测量高度，否则会导致父视图高度也变为0
            node.measuredHeight = measuredHeight;
        }
    }
}

@end
