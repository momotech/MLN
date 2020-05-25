//
//  MLNUIKeyframeAnimationBuilder.h
//  MLNUI
//
//  Created by MoMo on 2019/9/8.
//

#import <Foundation/Foundation.h>
#import "MLNUIAnimationConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNUIKeyframeAnimationBuilder : NSObject

+ (CAKeyframeAnimation *)buildAnimationWithKeyPath:(NSString *)path interpolatorType:(MLNUIAnimationInterpolatorType)type;

@end

NS_ASSUME_NONNULL_END
