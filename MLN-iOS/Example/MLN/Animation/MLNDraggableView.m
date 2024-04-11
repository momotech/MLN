//
//  MLNDraggableView.m
//  LuaNative
//
//  Created by Dai Dongpeng on 2020/6/17.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import "MLNDraggableView.h"

@implementation MLNDraggableView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)touchType:(MLATouchType)type touch:(UITouch *)touch event:(UIEvent *)event {
    if (self.touchBlock) {
        self.touchBlock(type, self, touch, event);
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.delegate dragView:self touchesBegan:touches withEvent:event];
    [self touchType:MLATouchType_Begin touch:touches.anyObject event:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    [self.delegate dragView:self touchesMoved:touches withEvent:event];
    [self touchType:MLATouchType_Move touch:touches.anyObject event:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self.delegate dragView:self touchesEnded:touches withEvent:event];
    [self touchType:MLATouchType_End touch:touches.anyObject event:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [self.delegate dragView:self touchesCanceled:touches withEvent:event];
    [self touchType:MLATouchType_Cancel touch:touches.anyObject event:event];
}
@end
