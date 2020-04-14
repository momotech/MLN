//
//  MLNRepeatAnimation.m
//  MLN
//
//  Created by MoMo on 2020/4/13.
//

#import "MLNRepeatAnimation.h"
#import "MLNKitHeader.h"

@interface MLNRepeatAnimation ()

@property (nonatomic, assign) float mln_repeatCount;

@property (nonatomic, assign) CFTimeInterval mln_duration;

@end

@implementation MLNRepeatAnimation

- (void)resetMediaTimingValues
{
    if (!self.fromValue || !self.toValue) {
        return;
    }
    
    float rc = 0;
    NSArray *values = nil;
    CGFloat duration = 0;
    BOOL autoReverse = NO;
    
    if (self.mln_repeatCount >= 0 && self.repeatType == MLNAnimationRepeatTypeReverse) {
        rc = 1;
        duration = self.mln_duration * (self.mln_repeatCount + 1);
        NSMutableArray *mutableValues = @[].mutableCopy;
        for (int i = 0; i < self.mln_repeatCount + 2; i ++) {
            [mutableValues addObject:0 == (i % 2 == 0) ? self.fromValue : self.toValue];
        }
        values = mutableValues.copy;
    }else {
        autoReverse = self.repeatType == MLNAnimationRepeatTypeReverse;
        rc = self.mln_repeatCount < 0 ? INT_MAX : (self.mln_repeatCount + 1);
        duration = self.mln_duration;
        values = @[self.fromValue, self.toValue];
    }
    
    [super setAutoreverses:autoReverse];
    [super setRepeatCount:rc];
    [super setDuration:duration];
    [super setValues:values];
    if (!self.autoBack) {
        [super setRemovedOnCompletion:NO];
        [super setFillMode:kCAFillModeForwards];
    }
}

#pragma mark - Override

- (void)setDuration:(CFTimeInterval)duration
{
    [self setMln_duration:duration];
}

- (CFTimeInterval)duration
{
    return _mln_duration;
}

- (float)repeatCount
{
    return _mln_repeatCount;
}

- (void)setRepeatCount:(float)repeatCount
{
    [self setMln_repeatCount:repeatCount];
}

- (void)setAutoreverses:(BOOL)autoreverses
{
    self.repeatType = autoreverses ? MLNAnimationRepeatTypeReverse : MLNAnimationRepeatTypeBeginToEnd;
}

- (BOOL)autoreverses
{
    return self.repeatType == MLNAnimationRepeatTypeReverse;
}

- (void)setPath:(CGPathRef)path
{
    
}

- (CGPathRef)path
{
    return NULL;
}

- (void)setRotationMode:(NSString *)rotationMode
{
    return;
}

- (NSString *)rotationMode
{
    return nil;
}

@end
