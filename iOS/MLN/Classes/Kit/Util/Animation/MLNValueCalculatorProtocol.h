//
//  MLNValueCalculatorProtocol.h
//  MLN
//
//  Created by MoMo on 2019/9/7.
//

#ifndef MLNValueCalculatorProtocol_h
#define MLNValueCalculatorProtocol_h

@protocol MLNValueCalculatorProtocol <NSObject>

- (id)calculate:(id)fromValue to:(id)toValue interpolation:(CGFloat)interpolation;

@end

#endif /* MLNValueCalculatorProtocol_h */
