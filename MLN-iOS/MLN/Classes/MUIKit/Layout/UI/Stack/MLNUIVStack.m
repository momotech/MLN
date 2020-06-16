//
//  MLNUIVStack.m
//  MLNUI
//
//  Created by MOMO on 2020/3/23.
//

#import "MLNUIVStack.h"
#import "UIView+MLNUILayout.h"
#import "MLNUIViewExporterMacro.h"

@implementation MLNUIVStack

#pragma mark - Override

- (instancetype)init {
    if (self = [super init]) {
        self.mlnui_layoutNode.flexDirection = MLNUIFlexDirectionColumn;
    }
    return self;
}

- (void)setLuaui_reverse:(BOOL)reverse {
    self.mlnui_layoutNode.flexDirection = reverse ? MLNUIFlexDirectionColumnReverse : MLNUIFlexDirectionColumn;
}

- (void)setCrossAxisSize:(CGSize)size {
    self.mlnui_layoutNode.width = MLNUIPointValue(size.width);
}

#pragma mark - Export Lua

LUAUI_EXPORT_VIEW_BEGIN(MLNUIVStack)
LUAUI_EXPORT_VIEW_END(MLNUIVStack, VStack, YES, "MLNUIPlaneStack", NULL)

@end
