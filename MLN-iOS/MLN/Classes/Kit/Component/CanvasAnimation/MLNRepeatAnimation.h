//
//  MLNRepeatAnimation.h
//  MLN
//
//  Created by MoMo on 2020/4/13.
//

#import <QuartzCore/QuartzCore.h>
#import "MLNAnimationConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNRepeatAnimation : CAKeyframeAnimation

@property (nonatomic, strong) id fromValue;

@property (nonatomic, strong) id toValue;

@property (nonatomic, assign) MLNAnimationRepeatType repeatType;

@property (nonatomic, assign) CGFloat delay;

@property (nonatomic, assign) BOOL autoBack;

- (void)resetMediaTimingValues;

@end

NS_ASSUME_NONNULL_END
