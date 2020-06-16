//
//  MLNUIHStack.m
//  MLNUI
//
//  Created by MOMO on 2020/3/23.
//

#import "MLNUIHStack.h"
#import "MLNUIViewConst.h"
#import "UIView+MLNUILayout.h"
#import "MLNUIViewExporterMacro.h"

@interface MLNUIHStack ()

@end

@implementation MLNUIHStack

#pragma mark - Override

- (instancetype)init {
    if (self = [super init]) {
        self.mlnui_layoutNode.flexDirection = MLNUIFlexDirectionRow;
    }
    return self;
}

- (void)setLuaui_reverse:(BOOL)reverse {
    self.mlnui_layoutNode.flexDirection = reverse ? MLNUIFlexDirectionRowReverse : MLNUIFlexDirectionRow;
}

- (void)setCrossAxisSize:(CGSize)size {
    self.mlnui_layoutNode.height = MLNUIPointValue(size.height);
}

#pragma mark - Export Lua

LUAUI_EXPORT_VIEW_BEGIN(MLNUIHStack)
LUAUI_EXPORT_VIEW_END(MLNUIHStack, HStack, YES, "MLNUIPlaneStack", NULL)

@end
