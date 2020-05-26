//
//  MLNUIKeyframeAnimation.m
//  MLNUI
//
//  Created by MoMo on 2019/9/6.
//

#import "MLNUIKeyframeAnimation.h"
#import "MLNUIKeyframeArray.h"

@interface MLNUIKeyframeAnimation () <MLNUIKeyframeArrayDelegate>

@property (nonatomic, strong) id<MLNUIInterpolatorProtocol> interpolator;
@property (nonatomic, strong) id<MLNUIValueCalculatorProtocol> valueCalculator;

@end
@implementation MLNUIKeyframeAnimation

+ (instancetype)animationWithKeyPath:(NSString *)path interpolator:(id<MLNUIInterpolatorProtocol>)interpolator valueCalculator:(id<MLNUIValueCalculatorProtocol>)valueCalculator
{
    MLNUIKeyframeAnimation *animation = [self animationWithKeyPath:path];
    animation.interpolator = interpolator;
    animation.valueCalculator = valueCalculator;
    return animation;
}

- (instancetype)initWithInterpolator:(id<MLNUIInterpolatorProtocol>)interpolator valueCalculator:(id<MLNUIValueCalculatorProtocol>)valueCalculator
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
    return [[MLNUIKeyframeArray alloc] initWithCount:count delegate:self];
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

- (id)keyframeArray:(MLNUIKeyframeArray *)array objectAtIndex:(NSUInteger)index
{
    CGFloat interpolation = [[self interpolator] getInterpolation:(CGFloat)index/(CGFloat)array.count];
    return [[self valueCalculator] calculate:self.fromValue to:self.toValue interpolation:interpolation];
}

@end
