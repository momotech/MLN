//
//  MLNRepeatAnimationGroup.h
//  MLN
//
//  Created by asnail on 2020/4/14.
//

#import <QuartzCore/QuartzCore.h>
#import <MLNRepeatAnimation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNRepeatAnimationGroup : CAAnimationGroup

- (MLNRepeatAnimation *)animationForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
