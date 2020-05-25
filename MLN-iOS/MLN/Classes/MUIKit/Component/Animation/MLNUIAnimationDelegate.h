//
//  MLNUIAnimationDelegate.h
//
//
//  Created by MoMo on 2018/8/28.
//

#import <UIKit/UIKit.h>

@class MLNUIAnimation;
@interface MLNUIAnimationDelegate : NSObject <CAAnimationDelegate>

- (instancetype)initWithAnimation:(MLNUIAnimation *)animation;

@end
