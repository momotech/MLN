//
//  MLNUIAnimationDelegate.m
//
//
//  Created by MoMo on 2018/8/28.
//

#import "MLNUIAnimationDelegate.h"
#import "MLNUIAnimation.h"


@interface MLNUIAnimationDelegate ()

@property (nonatomic, weak, readonly) MLNUIAnimation *animation;

@end
@implementation MLNUIAnimationDelegate

- (instancetype)initWithAnimation:(MLNUIAnimation *)animation
{
    if (self = [super init]) {
        _animation = animation;
    }
    return self;
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStart:(CAAnimation *)anim
{
    [self.animation callAnimationDidStart];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    //动画结束并回调结束状态
    [self.animation callAnimationDidStopWith:flag];
}

@end
