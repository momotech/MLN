//
//  MLNSpacer.m
//  MLN
//
//  Created by MOMO on 2020/3/27.
//

#import "MLNSpacer.h"
#import "MLNKitHeader.h"
#import "MLNSpacerNode.h"
#import "UIView+MLNLayout.h"
#import "MLNViewExporterMacro.h"

@implementation MLNSpacer

#pragma mark - Override

- (BOOL)lua_isContainer {
    return NO;
}

- (BOOL)lua_layoutEnable {
    return YES;
}

#pragma mark - Export Lua

LUA_EXPORT_VIEW_BEGIN(MLNSpacer)
LUA_EXPORT_VIEW_END(MLNSpacer, Spacer, YES, "MLNView", "initWithLuaCore:frame:")

@end
