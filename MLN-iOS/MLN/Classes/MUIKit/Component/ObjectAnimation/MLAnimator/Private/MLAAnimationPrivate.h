//
// Created by momo783 on 2020/5/18.
// Copyright (c) 2020 Boztrail. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Animation.h"

@protocol MLAAnimationPrivate <NSObject>

- (void)makeAnimation:(NSString *)key forObject:(id)obj;

- (animator::Animation *)cplusplusAnimation;

- (void)updateAnimation:(animator::Animation *)animation;

- (void)startAnimation;

- (void)pauseAnimation:(BOOL)paused;

- (void)repeatAnimation:(MLAAnimation *)executingAnimation count:(NSUInteger)count;

- (void)finishAnimation:(BOOL)finish;

@end

@interface MLAAnimation ()

- (void)setInnerKey:(NSString *)innerKey;

@end
