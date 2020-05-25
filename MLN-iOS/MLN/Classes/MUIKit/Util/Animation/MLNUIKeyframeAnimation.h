//
//  MLNUIKeyframeAnimation.h
//  MLNUI
//
//  Created by MoMo on 2019/9/6.
//

#import <QuartzCore/QuartzCore.h>
#import "MLNUIValueCalculatorProtocol.h"
#import "MLNUIInterpolatorProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNUIKeyframeAnimation : CAKeyframeAnimation

@property (nonatomic, strong) id fromValue;
@property (nonatomic, strong) id toValue;

+ (instancetype)animationWithKeyPath:(NSString *)path interpolator:(id<MLNUIInterpolatorProtocol>)interpolator valueCalculator:(id<MLNUIValueCalculatorProtocol>)valueCalculator;
- (instancetype)initWithInterpolator:(id<MLNUIInterpolatorProtocol>)interpolator valueCalculator:(id<MLNUIValueCalculatorProtocol>)valueCalculator;
- (id<MLNUIInterpolatorProtocol>)interpolator;
- (id<MLNUIValueCalculatorProtocol>)valueCalculator;

@end

NS_ASSUME_NONNULL_END
