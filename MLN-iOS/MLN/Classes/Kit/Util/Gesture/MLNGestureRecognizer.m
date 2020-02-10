//
//  MLNGestureRecognizer.m
//  EventTrasmition
//
//  Created by MOMO on 2020/2/6.
//  Copyright © 2020年 xiaotei. All rights reserved.
//

#import "MLNGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "UIView+MLNKit.h"

@interface MLNGestureRecognizer()
{
    BOOL _ignoreEvent;
}

@property (nonatomic, strong) dispatch_source_t gcdTimer;

@end

@implementation MLNGestureRecognizer

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self.view];
    _ignoreEvent = [self mln_findCousumeView:self.view pointInside:point];
    if (_ignoreEvent) {
        return;
    }
    _shouldCancelClick = NO;
    if (_mln_delegate && [_mln_delegate respondsToSelector:@selector(mln_touchesBegan:withEvent:)]) {
        [_mln_delegate mln_touchesBegan:touches withEvent:event];
    }
    _gcdTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    //开始时间，0.5s后
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC);
    //间隔时间
    uint64_t interval = 0 * NSEC_PER_SEC;
    dispatch_source_set_timer(_gcdTimer, start, interval, 0);
    dispatch_source_set_event_handler(_gcdTimer, ^{
        dispatch_cancel(self.gcdTimer);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.mln_delegate && [self.mln_delegate respondsToSelector:@selector(mln_longPressAction:)]) {
              self.shouldCancelClick =  [self.mln_delegate mln_longPressAction:self];
            }
        });
    });
    dispatch_resume(_gcdTimer);
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // When you leave the view, cancel the response to the click event
    CGPoint point = [[touches anyObject] locationInView:self.view];
    if (_ignoreEvent) {
        return;
    }
    if (!CGRectContainsPoint(self.view.bounds, point)) {
        _shouldCancelClick = YES;
    }

    if (_mln_delegate && [_mln_delegate respondsToSelector:@selector(mln_touchesMoved:withEvent:)]) {
        [_mln_delegate mln_touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (_ignoreEvent) {
        return;
    }
    dispatch_cancel(_gcdTimer);
    if (_mln_delegate && [_mln_delegate respondsToSelector:@selector(mln_touchesEnded:withEvent:)]) {
        [_mln_delegate mln_touchesEnded:touches withEvent:event];
    }
    if (!_shouldCancelClick && _mln_delegate && [_mln_delegate respondsToSelector:@selector(mln_tapAction:)]) {
        [_mln_delegate mln_tapAction:self];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (_ignoreEvent) {
        return;
    }
    dispatch_cancel(_gcdTimer);
    if (_mln_delegate && [_mln_delegate respondsToSelector:@selector(mln_touchesCancelled:withEvent:)]) {
        [_mln_delegate mln_touchesCancelled:touches withEvent:event];
    }
}

//递归查找消费事件的子视图
- (BOOL)mln_findCousumeView:(UIView *)superView pointInside:(CGPoint)point
{
    for (UIView *subview in superView.subviews)
    {
        //当触摸点在子视图上时，才做处理
        if (subview.hidden == NO && subview.lua_enable && subview.alpha > 0.01 && CGRectContainsPoint(subview.frame, point)) {
            if ( [subview lua_consumeEvent]) {
                return YES;
            }
            //只有子视图消费事件时，才返回YES，否则需要判断其他的子视图
            BOOL result = [self mln_findCousumeView:subview pointInside:[superView convertPoint:point toView:subview]];
            if (result) {
                return YES;
            }
        }
    }
    return NO;
}

@end
