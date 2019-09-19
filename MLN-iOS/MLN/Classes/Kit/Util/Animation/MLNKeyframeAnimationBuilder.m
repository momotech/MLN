//
//  MLNKeyframeAnimationBuilder.m
//  MLN
//
//  Created by MoMo on 2019/9/8.
//

#import "MLNKeyframeAnimationBuilder.h"
#import "MLNKeyframeAnimation.h"
#import "MLNBounceInterpolator.h"
#import "MLNOvershotInterpolater.h"
#import "MLNValueCalculator.h"

@implementation MLNKeyframeAnimationBuilder

+ (CAKeyframeAnimation *)buildAnimationWithKeyPath:(NSString *)path interpolatorType:(MLNAnimationInterpolatorType)type
{
    id<MLNInterpolatorProtocol> interpolator = nil;
    switch (type) {
        case MLNAnimationInterpolatorTypeBounce: {
            interpolator = [[MLNBounceInterpolator alloc] init];
            id<MLNValueCalculatorProtocol> valueCalculator = [[MLNValueCalculator alloc] init];
            return [MLNKeyframeAnimation animationWithKeyPath:path interpolator:interpolator valueCalculator:valueCalculator];
        }
        case MLNAnimationInterpolatorTypeOvershoot: {
            interpolator = [[MLNOvershotInterpolater alloc] init];
            id<MLNValueCalculatorProtocol> valueCalculator = [[MLNValueCalculator alloc] init];
            return [MLNKeyframeAnimation animationWithKeyPath:path interpolator:interpolator valueCalculator:valueCalculator];
        }
        default:
            return nil;
    }
}


@end
