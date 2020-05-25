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
    if (!targetView.mln_tapClickBlock) return;
    [targetView.mln_tapClickBlock addFloatArgument:tapPoint.x];
    [targetView.mln_tapClickBlock addFloatArgument:tapPoint.y];
    [targetView.mln_tapClickBlock callIfCan];
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
- (BOOL)lua_canClick
{
    return NO;
}

- (BOOL)lua_canLongPress
{
    return NO;
}

- (BOOL)lua_layoutEnable
{
    return YES;
}

#pragma mark - Export For Lua
LUA_EXPORT_VIEW_BEGIN(MLNUIAnimationZoneView)
LUA_EXPORT_VIEW_END(MLNUIAnimationZoneView, AnimationZone, YES, "MLNUIView", NULL)

@end
