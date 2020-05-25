//
//  MLNUIValueCalculator.h
//  MLNUI
//
//  Created by MoMo on 2019/9/6.
//

#import <Foundation/Foundation.h>
#import "MLNUIValueCalculatorProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNUIValueCalculator : NSObject <MLNUIValueCalculatorProtocol>

- (id)calculate:(id)fromValue to:(id)toValue interpolation:(CGFloat)interpolation;

@end

NS_ASSUME_NONNULL_END
