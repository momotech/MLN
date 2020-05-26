//
//  MLNUIAnimationZoneView.m
//
//
//  Created by MoMo on 2018/11/14.
//

#import "MLNUIAnimationZoneView.h"
#import "MLNUIViewExporterMacro.h"
#import "UIView+MLNUIKit.h"
#import "MLNUIBlock.h"

@implementation MLNUIAnimationZoneView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
        tap.cancelsTouchesInView = NO;
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)tapHandler:(UITapGestureRecognizer *)tap
{
    CGPoint tapPoint =  [tap locationInView:self];
    UIView *targetView = [self findTargetView:tapPoint];
    if (!targetView.mlnui_tapClickBlock) return;
    [targetView.mlnui_tapClickBlock addFloatArgument:tapPoint.x];
    [targetView.mlnui_tapClickBlock addFloatArgument:tapPoint.y];
    [targetView.mlnui_tapClickBlock callIfCan];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if ([self findTargetView:point]) {
        return self;
    }
    return nil;
}

- (UIView *)findTargetView:(CGPoint)point
{
    for (UIView *subview in [self subviews]) {
        if ([subview.layer.presentationLayer hitTest:point]) {
            return subview;
        }
    }
    return nil;
}


#pragma mark - Override
- (BOOL)luaui_canClick
{
    return NO;
}

- (BOOL)luaui_canLongPress
{
    return NO;
}

- (BOOL)luaui_layoutEnable
{
    return YES;
}

#pragma mark - Export For Lua
LUAUI_EXPORT_VIEW_BEGIN(MLNUIAnimationZoneView)
LUAUI_EXPORT_VIEW_END(MLNUIAnimationZoneView, AnimationZone, YES, "MLNUIView", NULL)

@end
