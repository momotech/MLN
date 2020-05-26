//
//  MLNUILayoutNodeFactory.m
//
//
//  Created by MoMo on 2018/12/13.
//

#import "MLNUILayoutNodeFactory.h"
#import "UIView+MLNUILayout.h"
#import "MLNUILayoutNode.h"
#import "MLNUILayoutContainerNode.h"
#import "MLNUILinearLayoutNode.h"
#import "MLNUILayoutScrollContainerNode.h"
#import "MLNUILinearLayout.h"
#import "MLNUILayoutImageViewNode.h"
#import "MLNUIWindow.h"
#import "MLNUILayoutWindowNode.h"
#import "MLNUIStack.h"
#import "MLNUISpacer.h"

@implementation MLNUILayoutNodeFactory

+ (MLNUILayoutNode *)createNodeWithTargetView:(UIView *)aView
{
    if (aView.luaui_isContainer) {
        return [self internalCreateContainerNodeWithTargetView:aView];
    } else if([aView isKindOfClass:[UIImageView class]]) {
        return [[MLNUILayoutImageViewNode alloc] initWithTargetView:aView];
    }
    return [[MLNUILayoutNode alloc] initWithTargetView:aView];
}

+ (MLNUILayoutNode *)internalCreateContainerNodeWithTargetView:(UIView *)aView
{
    if ([aView isKindOfClass:MLNUILinearLayout.class]) {
        MLNUILinearLayoutNode *node = [[MLNUILinearLayoutNode alloc] initWithTargetView:aView];
        node.direction = [(MLNUILinearLayout *)aView direction];
        return node;
    } else if ([aView isKindOfClass:UIScrollView.class] &&
        ![aView isKindOfClass:UICollectionView.class] &&
        ![aView isKindOfClass:UITableView.class]&&
        ![aView isKindOfClass:UITextView.class]) {
        return [[MLNUILayoutScrollContainerNode alloc] initWithTargetView:aView];
    } else if ([aView isKindOfClass:[MLNUIWindow class]]) {
        return [[MLNUILayoutWindowNode alloc] initWithTargetView:aView];
    } else if ([aView isKindOfClass:[MLNUIStack class]]) {
        return [(MLNUIStack *)aView createStackNodeWithTargetView:aView];
    }
    return [[MLNUILayoutContainerNode alloc] initWithTargetView:aView];
}

@end
