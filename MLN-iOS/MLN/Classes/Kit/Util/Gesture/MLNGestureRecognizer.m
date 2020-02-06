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
    BOOL _shouldCancelClick;
}

@end

@implementation MLNGestureRecognizer

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self.view];
    UIView *view = [self.view hitTest:point withEvent:event];
    if (view != self.view && view.mln_gesture) {
        self.state = UIGestureRecognizerStateBegan;
        return;
    }
    _shouldCancelClick = NO;
    self.state = UIGestureRecognizerStateBegan;
    if (_mln_delegate && [_mln_delegate respondsToSelector:@selector(mln_touchesBegan:withEvent:)]) {
        [_mln_delegate mln_touchesBegan:touches withEvent:event];
    }
    NSLog(@"custom---touchesBegan:%@ %ld", self, self.state);
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // When you leave the view, cancel the response to the click event
    CGPoint point = [[touches anyObject] locationInView:self.view];
    UIView *view = [self.view hitTest:point withEvent:event];
    if (view != self.view && view.mln_gesture) {
        self.state = UIGestureRecognizerStateChanged;
        return;
    }
    if (!CGRectContainsPoint(self.view.bounds, point)) {
        _shouldCancelClick = YES;
    }
    self.state = UIGestureRecognizerStateChanged;
    if (_mln_delegate && [_mln_delegate respondsToSelector:@selector(mln_touchesMoved:withEvent:)]) {
        [_mln_delegate mln_touchesMoved:touches withEvent:event];
    }
    NSLog(@"custom---touchesMoved:%@", self);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self.view];
    UIView *view = [self.view hitTest:point withEvent:event];
    if (view != self.view && view.mln_gesture) {
        self.state = UIGestureRecognizerStateEnded;
        return;
    }
    self.state = UIGestureRecognizerStateEnded;
    if (_mln_delegate && [_mln_delegate respondsToSelector:@selector(mln_touchesEnded:withEvent:)]) {
        [_mln_delegate mln_touchesEnded:touches withEvent:event];
    }
    if (!_shouldCancelClick && _mln_delegate && [_mln_delegate respondsToSelector:@selector(mln_tapAction:)]) {
        [_mln_delegate mln_tapAction:self];
    }
    NSLog(@"custom---touchesEnded:%@", self);
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self.view];
    UIView *view = [self.view hitTest:point withEvent:event];
    if (view != self.view && view.mln_gesture) {
        self.state = UIGestureRecognizerStateCancelled;
        return;
    }
    if (_mln_delegate && [_mln_delegate respondsToSelector:@selector(mln_touchesCancelled:withEvent:)]) {
        [_mln_delegate mln_touchesCancelled:touches withEvent:event];
    }
    NSLog(@"custom---touchesCancelled:%@", self);
}

//- (BOOL)shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    if (![otherGestureRecognizer isKindOfClass:[self class]]) {
//        return YES;
//    }
//    if ([self.view isDescendantOfView:otherGestureRecognizer.view]) {
//        return NO;
//    }
//    NSLog(@"otherGestureRecognizer:%@", otherGestureRecognizer);
//    return YES;
//}

@end
