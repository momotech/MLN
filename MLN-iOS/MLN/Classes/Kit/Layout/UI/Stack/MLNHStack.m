//
//  MLNHStack.m
//  MLN
//
//  Created by MOMO on 2020/3/23.
//

#import "MLNHStack.h"
#import "MLNViewConst.h"
#import "MLNHStackNode.h"
#import "UIView+MLNLayout.h"
#import "MLNViewExporterMacro.h"

@interface MLNHStack ()

@end

@implementation MLNHStack

- (MLNHStackNode *)node {
    return (MLNHStackNode *)self.lua_node;
}

#pragma mark - Override

- (instancetype)init {
    if (self = [super init]) {
        self.node.widthType = MLNLayoutMeasurementTypeMatchParent;  // 主轴
        self.node.heightType = MLNLayoutMeasurementTypeWrapContent; // 交叉轴
    }
    return self;
}

- (MLNLayoutNode *)createStackNodeWithTargetView:(UIView *)targetView {
    return [[MLNHStackNode alloc] initWithTargetView:targetView];
}

#pragma mark - Export Lua

LUA_EXPORT_VIEW_BEGIN(MLNHStack)
LUA_EXPORT_VIEW_END(MLNHStack, HStack, YES, "MLNPlaneStack", NULL)

@end
