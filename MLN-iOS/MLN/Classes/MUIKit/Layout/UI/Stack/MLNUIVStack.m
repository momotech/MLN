//
//  MLNUIVStack.m
//  MLNUI
//
//  Created by MOMO on 2020/3/23.
//

#import "MLNUIVStack.h"
#import "MLNUIVStackNode.h"
#import "UIView+MLNUILayout.h"
#import "MLNUIViewExporterMacro.h"

@implementation MLNUIVStack

- (MLNUIVStackNode *)node {
    return (MLNUIVStackNode *)self.luaui_node;
}

#pragma mark - Override

- (instancetype)init {
    if (self = [super init]) {
        self.node.heightType = MLNUILayoutMeasurementTypeMatchParent; // 主轴
        self.node.widthType = MLNUILayoutMeasurementTypeWrapContent;  // 交叉轴
    }
    return self;
}

- (MLNUILayoutNode *)createStackNodeWithTargetView:(UIView *)targetView {
    return [[MLNUIVStackNode alloc] initWithTargetView:targetView];
}

#pragma mark - Override

- (void)luaui_addSubview:(UIView *)view {
    [super luaui_addSubview:view];
    if ([view isKindOfClass:[MLNUIVStack class]]) {
        [(MLNUIVStackNode *)view.luaui_node invalidateMainAxisMatchParentMeasureType];
    }
}

#pragma mark - Export Lua

LUA_EXPORT_VIEW_BEGIN(MLNUIVStack)
LUA_EXPORT_VIEW_END(MLNUIVStack, VStack, YES, "MLNUIPlaneStack", NULL)

@end
