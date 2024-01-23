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

LUA_EXPORT_VIEW_BEGIN(MLNHStack)
LUA_EXPORT_VIEW_PROPERTY(mainAxisAlignment, "lua_setMainAxisAlignment:", "lua_mainAxisAlignment", MLNHStack)
LUA_EXPORT_VIEW_PROPERTY(crossAxisAlignment, "lua_setCrossAxisAlignment:", "lua_crossAxisAlignment", MLNHStack)
LUA_EXPORT_VIEW_END(MLNHStack, HStack, YES, "MLNStack", NULL)

@end
