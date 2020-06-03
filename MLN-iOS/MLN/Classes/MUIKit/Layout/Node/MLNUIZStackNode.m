//
//  MLNUIZStackNode.m
//  MLNUI
//
//  Created by MOMO on 2020/3/25.
//

#import "MLNUIZStackNode.h"
#import "MLNUIHeader.h"

@implementation MLNUIZStackNode

#pragma mark - Override

- (CGSize)measureSubNodes:(NSArray<MLNUILayoutNode *> *)subNods maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight {
    CGFloat myMaxWidth = [self myMaxWidthWithMaxWidth:maxWidth];
    CGFloat myMaxHeight = [self myMaxHeightWithMaxHeight:maxHeight];
    
    CGFloat usableZoneWidth = myMaxWidth - self.paddingLeft - self.paddingRight;
    CGFloat usableZoneHeight = myMaxHeight - self.paddingTop - self.paddingBottom;
    
    CGFloat totalWidth = 0.0;
    CGFloat totalHeight = 0.0;
    BOOL needDirty = NO;
    
    for (NSUInteger i  = 0; i < subNods.count; i++) {
        MLNUILayoutNode *subnode = subNods[i];
        if (subnode.isGone) {
            if (subnode.isDirty) {
                needDirty = YES;
            }
            continue;
        }
        if (subnode.isDirty) {
            needDirty = YES;
        } else if (needDirty) {
            [subnode needLayout];
        }
        CGFloat subMaxWidth = usableZoneWidth - subnode.marginLeft - subnode.marginRight;
        CGFloat subMaxHeight = usableZoneHeight - subnode.marginTop - subnode.marginBottom;
        CGSize subMeasuredSize = [subnode measureSizeWithMaxWidth:subMaxWidth maxHeight:subMaxHeight]; // 计算子节点
        switch (subnode.layoutStrategy) {
            case MLNUILayoutStrategyNativeFrame:
                totalWidth = MAX(totalWidth, subMeasuredSize.width);
                totalHeight = MAX(totalHeight, subMeasuredSize.height);
                break;
            default: {
                totalWidth = MAX(totalWidth, subMeasuredSize.width + subnode.marginLeft +subnode.marginRight);
                totalHeight = MAX(totalHeight, subMeasuredSize.height + subnode.marginTop + subnode.marginBottom);
                break;
            }
        }
    }
    
    CGFloat measuredWidth = myMaxWidth;
    CGFloat measuredHeight = myMaxHeight;
    
    // width
    if (!self.isWidthExcatly) {
        switch (self.mergedWidthType) {
            case MLNUILayoutMeasurementTypeWrapContent:
                totalWidth += self.paddingLeft + self.paddingRight;
                totalWidth = MIN(myMaxWidth, totalWidth);
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
    }
    
    // height
    if (!self.isHeightExcatly) {
        switch (self.mergedHeightType) {
            case MLNUILayoutMeasurementTypeWrapContent:
                totalHeight += self.paddingTop + self.paddingBottom;
                totalHeight = MIN(myMaxHeight, totalHeight);
                totalHeight = self.minHeight > 0 ? MAX(totalHeight, self.minHeight) : totalHeight;
                measuredHeight = totalHeight;
                break;
            case MLNUILayoutMeasurementTypeMatchParent:
                measuredHeight = MAX(self.minHeight, myMaxHeight);
                break;
            default:
                measuredHeight = myMaxHeight;
                break;
        }
    }
    self.measuredWidth = measuredWidth;
    self.measuredHeight = measuredHeight;
    
    return CGSizeMake(self.measuredWidth, self.measuredHeight);
}

- (void)layoutSubnodes {
    CGFloat layoutZoneWidth = self.measuredWidth - self.paddingLeft - self.paddingRight;
    CGFloat layoutZoneHeight = self.measuredHeight - self.paddingTop - self.paddingBottom;
    CGFloat layoutZoneRight = self.measuredWidth - self.paddingRight;
    CGFloat layoutZoneBottom = self.measuredHeight - self.paddingBottom;
    
    NSArray<MLNUILayoutNode *> *subNodes = self.subnodes;
    for (NSUInteger i = 0; i < subNodes.count; i++) {
        MLNUILayoutNode *subNode = subNodes[i];
        if (subNode.isGone) continue;
        
        subNode.measuredX = GetSubNodeX(self, subNode, layoutZoneWidth, layoutZoneRight);
        subNode.measuredY = GetSubNodeY(self, subNode, layoutZoneHeight, layoutZoneBottom);
        [subNode updateTargetViewFrameIfNeed];
        
        if (subNode.isContainer) {
            [(MLNUILayoutContainerNode *)subNode layoutSubnodes];
        }
        if (subNode.overlayNode) {
            [subNode layoutOverlayNode];
        }
    }
}

#pragma mark -

// 布局X-axis
static MLNUI_FORCE_INLINE CGFloat GetSubNodeX(MLNUIZStackNode __unsafe_unretained *self, MLNUILayoutNode __unsafe_unretained *subNode, CGFloat maxWidth, CGFloat maxX) {
    CGFloat x = 0.0;
    switch (subNode.gravity & MLNUIGravityHorizontalMask) { // 优先以子节点的Gravity为准
        case MLNUIGravityLeft:
            x = self.paddingLeft + subNode.marginLeft;
            break;
            
        case MLNUIGravityCenterHorizontal:
            x = self.paddingLeft + (maxWidth - subNode.measuredWidth) / 2.0 + subNode.marginLeft - subNode.marginRight;
            break;
            
        case MLNUIGravityRight:
            x = maxX - subNode.measuredWidth - subNode.marginRight;;
            break;
            
        default:
            switch (self.childGravity & MLNUIGravityHorizontalMask) {
                case MLNUIGravityCenterHorizontal:
                    x = self.paddingLeft + (maxWidth - subNode.measuredWidth) / 2.0 + subNode.marginLeft - subNode.marginRight;
                    break;
                case MLNUIGravityRight:
                    x = maxX - subNode.measuredWidth - subNode.marginRight;;
                    break;
                case MLNUIGravityLeft:
                default:
                    x = self.paddingLeft + subNode.marginLeft;
                    break;
            }
            break;
    }
    return x;
}

// 布局Y-axis
static MLNUI_FORCE_INLINE CGFloat GetSubNodeY(MLNUIZStackNode __unsafe_unretained *self, MLNUILayoutNode __unsafe_unretained *subNode, CGFloat maxHeight, CGFloat maxY) {
    CGFloat y = 0.0;
    switch (subNode.gravity & MLNUIGravityVerticalMask) {
        case MLNUIGravityTop:
            y = self.paddingTop + subNode.marginTop;
            break;
            
        case MLNUIGravityCenterVertical:
            y = self.paddingTop + (maxHeight - subNode.measuredHeight) / 2.0 + subNode.marginTop - subNode.marginBottom;
            break;
            
        case MLNUIGravityBottom:
            y = maxY - subNode.measuredHeight - subNode.marginBottom;
            break;
            
        default:
            switch (self.childGravity & MLNUIGravityVerticalMask) {
                case MLNUIGravityCenterVertical:
                    y = self.paddingTop + (maxHeight - subNode.measuredHeight) / 2.0 + subNode.marginTop - subNode.marginBottom;
                    break;
                case MLNUIGravityBottom:
                    y = maxY - subNode.measuredHeight - subNode.marginBottom;
                    break;
                case MLNUIGravityTop:
                default:
                    y = self.paddingTop + subNode.marginTop;
                    break;
            }
            break;
    }
    return y;
}

@end
