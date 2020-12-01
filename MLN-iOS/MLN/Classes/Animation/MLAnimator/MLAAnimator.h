//
// Created by momo783 on 2020/5/14.
// Copyright (c) 2020 boztrail. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MLAAnimtorDelegate;

@interface MLAAnimator : NSObject

@property (weak, nonatomic) id<MLAAnimtorDelegate> delegate;

+ (instancetype)shareAnimator;

@end

@protocol MLAAnimtorDelegate <NSObject>
@optional
- (void)animatorLoopStart:(MLAAnimator *)animator;
- (void)animatorLoopFinish:(MLAAnimator *)animator;

@end

NS_ASSUME_NONNULL_END
