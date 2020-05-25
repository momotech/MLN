//
//  MLNAnimationDelegate.h
//
//
//  Created by MoMo on 2018/8/28.
//

#import <UIKit/UIKit.h>

@class MLNAnimation;
@interface MLNAnimationDelegate : NSObject <CAAnimationDelegate>

- (instancetype)initWithAnimation:(MLNAnimation *)animation;

@end
