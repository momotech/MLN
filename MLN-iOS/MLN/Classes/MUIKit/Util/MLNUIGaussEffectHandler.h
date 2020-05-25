//
//  MLNUIGaussEffectHandler.h
//  MLNUI
//
//  Created by MOMO on 2019/9/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNUIGaussEffectHandler : NSObject

+ (UIImage *)coreBlurImage:(UIImage *)image withBlurValue:(CGFloat)blurValue;

@end

NS_ASSUME_NONNULL_END
