//
//  MLNKeyframeAnimation.m
//  MLN
//
//  Created by MoMo on 2019/9/6.
//

#import "MLNKeyframeAnimation.h"
#import "MLNKeyframeArray.h"

@interface MLNKeyframeAnimation () <MLNKeyframeArrayDelegate>

@property (nonatomic, strong) id<MLNInterpolatorProtocol> interpolator;
@property (nonatomic, strong) id<MLNValueCalculatorProtocol> valueCalculator;

@end
@implementation MLNKeyframeAnimation

+ (instancetype)animationWithKeyPath:(NSString *)path interpolator:(id<MLNInterpolatorProtocol>)interpolator valueCalculator:(id<MLNValueCalculatorProtocol>)valueCalculator
{
    MLNKeyframeAnimation *animation = [self animationWithKeyPath:path];
    animation.interpolator = interpolator;
    animation.valueCalculator = valueCalculator;
    return animation;
}

- (instancetype)initWithInterpolator:(id<MLNInterpolatorProtocol>)interpolator valueCalculator:(id<MLNValueCalculatorProtocol>)valueCalculator
{
    if (self = [super init]) {
        _interpolator = interpolator;
        _valueCalculator = valueCalculator;
    }
    return self;
}

- (NSArray *)values
{
    CGFloat count = self.duration * 60;
    return [[MLNKeyframeArray alloc] initWithCount:count delegate:self];
}

- (void)setPath:(CGPathRef)path {
    return;
}

- (CGPathRef)path {
    return NULL;
}

- (void)setRotationMode:(NSString *)rotationMode {
    return;
}

- (NSString *)rotationMode {
    return nil;
}

- (void)setValues:(NSArray *)values {
    return;
}

- (id)keyframeArray:(MLNKeyframeArray *)array objectAtIndex:(NSUInteger)index
{
    CGFloat interpolation = [[self interpolator] getInterpolation:(CGFloat)index/(CGFloat)array.count];
    return [[self valueCalculator] calculate:self.fromValue to:self.toValue interpolation:interpolation];
}

@end
