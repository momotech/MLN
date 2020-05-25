//
//  MLNZStack.m
//  MLN
//
//  Created by MOMO on 2020/3/23.
//

#import "MLNZStack.h"
#import "MLNZStackNode.h"
#import "UIView+MLNLayout.h"
#import "MLNViewExporterMacro.h"

@implementation MLNZStack

- (MLNZStackNode *)node {
    return (MLNZStackNode *)self.lua_node;
}

#pragma mark - Override

- (instancetype)init {
    if (self = [super init]) {
        self.node.widthType = MLNLayoutMeasurementTypeWrapContent;
        self.node.heightType = MLNLayoutMeasurementTypeWrapContent;
    }
    return self;
}

- (MLNLayoutNode *)createStackNodeWithTargetView:(UIView *)targetView {
    return [[MLNZStackNode alloc] initWithTargetView:targetView];
}

#pragma mark - Export Lua

- (void)lua_setChildrenGravity:(MLNGravity)gravity {
    self.node.childGravity = gravity;
}

- (MLNGravity)lua_childrenGravity {
    return self.node.childGravity;
}

LUA_EXPORT_VIEW_BEGIN(MLNZStack)
LUA_EXPORT_VIEW_PROPERTY(childGravity, "lua_setChildrenGravity:", "lua_childrenGravity", MLNZStack)
LUA_EXPORT_VIEW_END(MLNZStack, ZStack, YES, "MLNStack", NULL)

@end
