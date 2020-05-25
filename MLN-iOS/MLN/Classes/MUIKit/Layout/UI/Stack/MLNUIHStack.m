//
//  MLNUIHStack.m
//  MLNUI
//
//  Created by MOMO on 2020/3/23.
//

#import "MLNUIHStack.h"
#import "MLNUIViewConst.h"
#import "MLNUIHStackNode.h"
#import "UIView+MLNUILayout.h"
#import "MLNUIViewExporterMacro.h"

@interface MLNUIHStack ()

@end

@implementation MLNUIHStack

- (MLNUIHStackNode *)node {
    return (MLNUIHStackNode *)self.luaui_node;
}

#pragma mark - Override

- (instancetype)init {
    if (self = [super init]) {
        self.node.widthType = MLNUILayoutMeasurementTypeMatchParent;  // 主轴
        self.node.heightType = MLNUILayoutMeasurementTypeWrapContent; // 交叉轴
    }
    return self;
}

- (MLNUILayoutNode *)createStackNodeWithTargetView:(UIView *)targetView {
    return [[MLNUIHStackNode alloc] initWithTargetView:targetView];
}

#pragma mark - Override

- (void)luaui_addSubview:(UIView *)view {
    [super luaui_addSubview:view];
    if ([view isKindOfClass:[MLNUIHStack class]]) {
        [(MLNUIHStackNode *)view.luaui_node invalidateMainAxisMatchParentMeasureType];
    }
}

#pragma mark - Export Lua

LUA_EXPORT_VIEW_BEGIN(MLNUIHStack)
LUA_EXPORT_VIEW_END(MLNUIHStack, HStack, YES, "MLNUIPlaneStack", NULL)

@end
