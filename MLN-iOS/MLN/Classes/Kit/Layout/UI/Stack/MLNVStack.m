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

#pragma mark - Export Lua

- (void)lua_setMainAxisAlignment:(MLNStackMainAlignment)alignment {
    self.node.mainAxisAlignment = alignment;
}

- (MLNStackMainAlignment)lua_mainAxisAlignment {
    return self.node.mainAxisAlignment;
}

- (void)lua_setCrossAxisAlignment:(MLNStackCrossAlignment)alignment {
    self.node.crossAxisAlignment = alignment;
}

- (MLNStackCrossAlignment)lua_crossAxisAlignment {
    return self.node.crossAxisAlignment;
}

LUA_EXPORT_VIEW_BEGIN(MLNVStack)
LUA_EXPORT_VIEW_PROPERTY(mainAxisAlignment, "lua_setMainAxisAlignment:", "lua_mainAxisAlignment", MLNVStack)
LUA_EXPORT_VIEW_PROPERTY(crossAxisAlignment, "lua_setCrossAxisAlignment:", "lua_crossAxisAlignment", MLNVStack)
LUA_EXPORT_VIEW_END(MLNVStack, VStack, YES, "MLNStack", NULL)

@end
