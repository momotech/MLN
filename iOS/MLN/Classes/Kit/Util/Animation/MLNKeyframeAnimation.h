//
//  MLNKeyframeAnimation.h
//  MLN
//
//  Created by MoMo on 2019/9/6.
//

#import <QuartzCore/QuartzCore.h>
#import "MLNValueCalculatorProtocol.h"
#import "MLNInterpolatorProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNKeyframeAnimation : CAKeyframeAnimation

@property (nonatomic, strong) id fromValue;
@property (nonatomic, strong) id toValue;

+ (instancetype)animationWithKeyPath:(NSString *)path interpolator:(id<MLNInterpolatorProtocol>)interpolator valueCalculator:(id<MLNValueCalculatorProtocol>)valueCalculator;
- (instancetype)initWithInterpolator:(id<MLNInterpolatorProtocol>)interpolator valueCalculator:(id<MLNValueCalculatorProtocol>)valueCalculator;
- (id<MLNInterpolatorProtocol>)interpolator;
- (id<MLNValueCalculatorProtocol>)valueCalculator;

@end

NS_ASSUME_NONNULL_END
