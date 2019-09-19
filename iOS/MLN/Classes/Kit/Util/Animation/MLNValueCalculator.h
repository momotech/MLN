//
//  MLNValueCalculator.h
//  MLN
//
//  Created by MoMo on 2019/9/6.
//

#import <Foundation/Foundation.h>
#import "MLNValueCalculatorProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNValueCalculator : NSObject <MLNValueCalculatorProtocol>

- (id)calculate:(id)fromValue to:(id)toValue interpolation:(CGFloat)interpolation;

@end

NS_ASSUME_NONNULL_END
