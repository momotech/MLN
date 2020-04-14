//
//  MLNRepeatAnimationGroup.h
//  MLN
//
//  Created by MoMo on 2020/4/14.
//

#import <QuartzCore/QuartzCore.h>
#import <MLNRepeatAnimation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 由于MLN接口约定的reverse行为与CoreAnimation不一致,
 * 所以自定义`MLNRepeatAnimationGroup`和`MLNRepeatAnimation`兼容.
 */
@interface MLNRepeatAnimationGroup : CAAnimationGroup

- (MLNRepeatAnimation *)animationForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
