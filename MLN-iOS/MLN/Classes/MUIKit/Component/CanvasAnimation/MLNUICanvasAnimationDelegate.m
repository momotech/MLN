//
//  MLNUICanvasAnimationDelegate.m
//  MLNUI
//
//  Created by MoMo on 2019/5/13.
//

#import "MLNUICanvasAnimationDelegate.h"

@interface MLNUICanvasAnimationDelegate ()

@property (nonatomic, weak, readonly) id<CAAnimationDelegate> animation;

@end
@implementation MLNUICanvasAnimationDelegate

- (instancetype)initWithAnimation:(id<CAAnimationDelegate>)animation
{
    if (self = [super init]) {
        _animation = animation;
    }
    return self;
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStart:(CAAnimation *)anim
{
    if (!_ignoreAnimationCallback) {
        [self.animation animationDidStart:anim];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (!_ignoreAnimationCallback) {
        [self.animation animationDidStop:anim finished:flag];
    }
}


@end
