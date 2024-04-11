//
//  MLNKeyframeAnimationBuilder.h
//  MLN
//
//  Created by MoMo on 2019/9/8.
//

#import <Foundation/Foundation.h>
#import "MLNAnimationConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNKeyframeAnimationBuilder : NSObject

+ (CAKeyframeAnimation *)buildAnimationWithKeyPath:(NSString *)path interpolatorType:(MLNAnimationInterpolatorType)type;

@end

NS_ASSUME_NONNULL_END
