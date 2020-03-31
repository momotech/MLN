//
//  MLNStackNode.m
//  MLN
//
//  Created by MOMO on 2020/3/23.
//

#import "MLNStackNode.h"
#import "MLNHeader.h"

@interface MLNStackNode ()

@property (nonatomic, strong) NSArray<MLNLayoutNode *> *prioritySubnodes;

@end

@implementation MLNStackNode

- (CGSize)measureSubNodes:(NSArray<MLNLayoutNode *> *)subNods maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight {
    return CGSizeZero;
}

#pragma mark - Override (Init)

- (instancetype)initWithTargetView:(UIView *)targetView {
    if (self = [super initWithTargetView:targetView]) {
        _mainAxisAlignment = MLNStackMainAlignmentStart;
        _crossAxisAlignment = MLNStackCrossAlignmentStart;
    }
    return self;
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
    
    CGSize size = [self measureSubNodes:self.prioritySubnodes maxWidth:maxWidth maxHeight:maxHeight];
    if (self.overlayNode) {
        CGFloat overlayMaxWidth = size.width - self.overlayNode.marginLeft - self.overlayNode.marginRight;
        CGFloat overlayMaxHeight = size.height - self.overlayNode.marginTop - self.overlayNode.marginBottom;
        [self.overlayNode measureSizeWithMaxWidth:overlayMaxWidth maxHeight:overlayMaxHeight];
    }
    return size;
}

#pragma mark - Sort

static MLN_FORCE_INLINE void resortingSubnodesIfNeed(MLNStackNode __unsafe_unretained *node) {
    if (node.needSorting) {
        NSArray<MLNLayoutNode *> *subnodes = node.subnodes;
        NSUInteger count = subnodes.count;
        node.prioritySubnodes = subnodes;
        if (count > 1) {
            NSMutableArray<MLNLayoutNode *> *nodes_m = [NSMutableArray arrayWithArray:subnodes];
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

static MLN_FORCE_INLINE void quickSort(MLNStackNode __unsafe_unretained *node, NSMutableArray<MLNLayoutNode *> __unsafe_unretained *nodes_m, NSUInteger head, NSUInteger tail) {
    if (head >= tail || nodes_m.count <2) {
        return;
    }
    NSUInteger i = head, j = tail;
    NSUInteger base = head;
    MLNLayoutNode *baseNode = nodes_m[base]; // 基准
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
