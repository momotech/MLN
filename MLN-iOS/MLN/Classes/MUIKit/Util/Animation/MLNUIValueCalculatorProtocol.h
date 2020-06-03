//
//  MLNUIValueCalculatorProtocol.h
//  MLNUI
//
//  Created by MoMo on 2019/9/7.
//

#ifndef MLNUIValueCalculatorProtocol_h
#define MLNUIValueCalculatorProtocol_h

@protocol MLNUIValueCalculatorProtocol <NSObject>

- (id)calculate:(id)fromValue to:(id)toValue interpolation:(CGFloat)interpolation;

@end

#endif /* MLNUIValueCalculatorProtocol_h */
