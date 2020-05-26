//
//  MLNUIStackNode.m
//  MLNUI
//
//  Created by MOMO on 2020/3/23.
//

#import "MLNUIStackNode.h"
#import "MLNUIHeader.h"

@interface MLNUIStackNode ()

@property (nonatomic, strong) NSArray<MLNUILayoutNode *> *prioritySubnodes;

@end

@implementation MLNUIStackNode

- (CGSize)measureSubNodes:(NSArray<MLNUILayoutNode *> *)subNods maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight {
    return CGSizeZero;
}

#pragma mark - Override (Measure)

- (CGSize)measureSizeWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight {
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
    
    return [self measureSubNodes:self.prioritySubnodes maxWidth:maxWidth maxHeight:maxHeight];
}

#pragma mark - Sort

static MLNUI_FORCE_INLINE void resortingSubnodesIfNeed(MLNUIStackNode __unsafe_unretained *node) {
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

static MLNUI_FORCE_INLINE void quickSort(MLNUIStackNode __unsafe_unretained *node, NSMutableArray<MLNUILayoutNode *> __unsafe_unretained *nodes_m, NSUInteger head, NSUInteger tail) {
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


@implementation MLNUIPlaneStackNode

- (void)invalidateMainAxisMatchParentMeasureType {
    // do nothing
}

#pragma mark - Override (Init)

- (instancetype)initWithTargetView:(UIView *)targetView {
    if (self = [super initWithTargetView:targetView]) {
        _mainAxisAlignment = MLNUIStackMainAlignmentStart;
        _crossAxisAlignment = MLNUIStackCrossAlignmentStart;
    }
    return self;
}

@end
