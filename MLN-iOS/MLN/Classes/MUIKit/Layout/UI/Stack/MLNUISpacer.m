//
//  MLNUISpacer.m
//  MLN
//
//  Created by xindong on 2020/6/4.
//

#import "MLNUISpacer.h"
#import "UIView+MLNUILayout.h"
#import "MLNUIViewExporterMacro.h"

@implementation MLNUISpacer

#pragma mark - Override

- (instancetype)init {
    if (self = [super init]) {
        self.mlnui_layoutNode.flexGrow = 1.0;
    }
    return self;
}

#pragma mark - Export Lua

LUAUI_EXPORT_VIEW_BEGIN(MLNUISpacer)
LUAUI_EXPORT_VIEW_END(MLNUISpacer, Spacer, YES, "MLNUIView", NULL)

@end
