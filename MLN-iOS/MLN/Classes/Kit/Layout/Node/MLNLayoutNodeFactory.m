//
//  MLNLayoutNodeFactory.m
//
//
//  Created by MoMo on 2018/12/13.
//

#import "MLNLayoutNodeFactory.h"
#import "UIView+MLNLayout.h"
#import "MLNLayoutNode.h"
#import "MLNLayoutContainerNode.h"
#import "MLNLinearLayoutNode.h"
#import "MLNLayoutScrollContainerNode.h"
#import "MLNLinearLayout.h"

@implementation MLNLayoutNodeFactory

+ (MLNLayoutNode *)createNodeWithTargetView:(UIView *)aView
{
    if (aView.lua_isContainer) {
        return [self internalCreateContainerNodeWithTargetView:aView];
    }
    return [[MLNLayoutNode alloc] initWithTargetView:aView];
}

+ (MLNLayoutNode *)internalCreateContainerNodeWithTargetView:(UIView *)aView
{
    if ([aView isKindOfClass:MLNLinearLayout.class]) {
        MLNLinearLayoutNode *node = [[MLNLinearLayoutNode alloc] initWithTargetView:aView];
        node.direction = [(MLNLinearLayout *)aView direction];
        return node;
    } else if ([aView isKindOfClass:UIScrollView.class] &&
        ![aView isKindOfClass:UICollectionView.class] &&
        ![aView isKindOfClass:UITableView.class]&&
        ![aView isKindOfClass:UITextView.class]) {
        return [[MLNLayoutScrollContainerNode alloc] initWithTargetView:aView];
    }
    return [[MLNLayoutContainerNode alloc] initWithTargetView:aView];
}

@end
