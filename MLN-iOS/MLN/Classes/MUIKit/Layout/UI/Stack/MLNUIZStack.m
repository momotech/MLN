//
//  MLNUIZStack.m
//  MLNUI
//
//  Created by MOMO on 2020/3/23.
//

#import "MLNUIZStack.h"
#import "MLNUIZStackNode.h"
#import "UIView+MLNUILayout.h"
#import "MLNUIViewExporterMacro.h"

@implementation MLNUIZStack

- (MLNUIZStackNode *)node {
    return (MLNUIZStackNode *)self.luaui_node;
}

#pragma mark - Override

- (instancetype)init {
    if (self = [super init]) {
        self.node.widthType = MLNUILayoutMeasurementTypeWrapContent;
        self.node.heightType = MLNUILayoutMeasurementTypeWrapContent;
    }
    return self;
}

- (MLNUILayoutNode *)createStackNodeWithTargetView:(UIView *)targetView {
    return [[MLNUIZStackNode alloc] initWithTargetView:targetView];
}

#pragma mark - Export Lua

- (void)luaui_setChildrenGravity:(MLNUIGravity)gravity {
    self.node.childGravity = gravity;
}

- (MLNUIGravity)luaui_childrenGravity {
    return self.node.childGravity;
}

LUA_EXPORT_VIEW_BEGIN(MLNUIZStack)
LUA_EXPORT_VIEW_PROPERTY(childGravity, "luaui_setChildrenGravity:", "luaui_childrenGravity", MLNUIZStack)
LUA_EXPORT_VIEW_END(MLNUIZStack, ZStack, YES, "MLNUIStack", NULL)

@end
