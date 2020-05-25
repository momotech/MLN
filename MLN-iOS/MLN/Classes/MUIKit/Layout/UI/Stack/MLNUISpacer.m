//
//  MLNUISpacer.m
//  MLNUI
//
//  Created by MOMO on 2020/3/27.
//

#import "MLNUISpacer.h"
#import "MLNUIKitHeader.h"
#import "UIView+MLNUILayout.h"
#import "MLNUIViewExporterMacro.h"

@implementation MLNUISpacer

#pragma mark - Override

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.lua_weight = 1;
    }
    return self;
}

- (BOOL)lua_isContainer {
    return NO;
}

- (BOOL)lua_layoutEnable {
    return YES;
}

#pragma mark - Export Lua

LUA_EXPORT_VIEW_BEGIN(MLNUISpacer)
LUA_EXPORT_VIEW_END(MLNUISpacer, Spacer, YES, "MLNUIView", "initWithLuaCore:frame:")

@end
