//
// Created by momo783 on 2020/5/14.
// Copyright (c) 2020 boztrail. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLAAnimation.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MLAAnimationDelegate <NSObject>
@optional
- (void)didStartAnimation:(MLAAnimation *)animation;
- (void)didEndAnimation:(MLAAnimation *)animation;

@end

@interface NSObject (Animator)

@property (weak, nonatomic) id<MLAAnimationDelegate> mla_delegate;

- (void)mla_addAnimation:(MLAAnimation *)animation forKey:(NSString *)key;

- (void)mla_removeAnimation:(NSString *)key;

- (void)mla_removeAllAnimations;

@end

NS_ASSUME_NONNULL_END
