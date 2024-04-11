//
//  MLNAnimationDelegate.m
//
//
//  Created by MoMo on 2018/8/28.
//

#import "MLNAnimationDelegate.h"
#import "MLNAnimation.h"


@interface MLNAnimationDelegate ()

@property (nonatomic, weak, readonly) MLNAnimation *animation;

@end
@implementation MLNAnimationDelegate

- (instancetype)initWithAnimation:(MLNAnimation *)animation
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
