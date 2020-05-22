//
//  MLNVStack.m
//  MLN
//
//  Created by MOMO on 2020/3/23.
//

#import "MLNVStack.h"
#import "MLNVStackNode.h"
#import "UIView+MLNLayout.h"
#import "MLNViewExporterMacro.h"

@implementation MLNVStack

- (MLNVStackNode *)node {
    return (MLNVStackNode *)self.lua_node;
}

#pragma mark - Override

- (instancetype)init {
    if (self = [super init]) {
        self.node.heightType = MLNLayoutMeasurementTypeMatchParent; // 主轴
        self.node.widthType = MLNLayoutMeasurementTypeWrapContent;  // 交叉轴
    }
    return self;
}

- (MLNLayoutNode *)createStackNodeWithTargetView:(UIView *)targetView {
    return [[MLNVStackNode alloc] initWithTargetView:targetView];
}

#pragma mark - Override

- (void)lua_addSubview:(UIView *)view {
    [super lua_addSubview:view];
    if ([view isKindOfClass:[MLNVStack class]]) {
        [(MLNVStackNode *)view.lua_node invalidateMainAxisMatchParentMeasureType];
    }
}

#pragma mark - Export Lua

LUA_EXPORT_VIEW_BEGIN(MLNVStack)
LUA_EXPORT_VIEW_END(MLNVStack, VStack, YES, "MLNPlaneStack", NULL)

@end
