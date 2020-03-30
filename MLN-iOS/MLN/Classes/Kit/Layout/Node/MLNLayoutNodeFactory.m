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
#import "MLNLayoutImageViewNode.h"
#import "MLNWindow.h"
#import "MLNLayoutWindowNode.h"
#import "MLNStack.h"
#import "MLNSpacer.h"
#import "MLNSpacerNode.h"

@implementation MLNLayoutNodeFactory

+ (MLNLayoutNode *)createNodeWithTargetView:(UIView *)aView
{
    if (aView.lua_isContainer) {
        return [self internalCreateContainerNodeWithTargetView:aView];
    } else if([aView isKindOfClass:[UIImageView class]]) {
        return [[MLNLayoutImageViewNode alloc] initWithTargetView:aView];
    } else if ([aView isKindOfClass:[MLNSpacer class]]) {
        return [[MLNSpacerNode alloc] initWithTargetView:aView];
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
    } else if ([aView isKindOfClass:[MLNWindow class]]) {
        return [[MLNLayoutWindowNode alloc] initWithTargetView:aView];
    } else if ([aView isKindOfClass:[MLNStack class]]) {
        return [(MLNStack *)aView createStackNodeWithTargetView:aView];
    }
    return [[MLNLayoutContainerNode alloc] initWithTargetView:aView];
}

@end
