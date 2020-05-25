//
//  MLNUIKeyframeAnimationBuilder.m
//  MLNUI
//
//  Created by MoMo on 2019/9/8.
//

#import "MLNUIKeyframeAnimationBuilder.h"
#import "MLNUIKeyframeAnimation.h"
#import "MLNUIBounceInterpolator.h"
#import "MLNUIOvershotInterpolater.h"
#import "MLNUIValueCalculator.h"

@implementation MLNUIKeyframeAnimationBuilder

+ (CAKeyframeAnimation *)buildAnimationWithKeyPath:(NSString *)path interpolatorType:(MLNUIAnimationInterpolatorType)type
{
    id<MLNUIInterpolatorProtocol> interpolator = nil;
    switch (type) {
        case MLNUIAnimationInterpolatorTypeBounce: {
            interpolator = [[MLNUIBounceInterpolator alloc] init];
            id<MLNUIValueCalculatorProtocol> valueCalculator = [[MLNUIValueCalculator alloc] init];
            return [MLNUIKeyframeAnimation animationWithKeyPath:path interpolator:interpolator valueCalculator:valueCalculator];
        }
        case MLNUIAnimationInterpolatorTypeOvershoot: {
            interpolator = [[MLNUIOvershotInterpolater alloc] init];
            id<MLNUIValueCalculatorProtocol> valueCalculator = [[MLNUIValueCalculator alloc] init];
            return [MLNUIKeyframeAnimation animationWithKeyPath:path interpolator:interpolator valueCalculator:valueCalculator];
        }
        default:
            return nil;
    }
}


@end
