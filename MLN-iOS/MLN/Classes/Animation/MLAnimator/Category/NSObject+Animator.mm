//
// Created by momo783 on 2020/5/14.
// Copyright (c) 2020 boztrail. All rights reserved.
//

#import "NSObject+Animator.h"
#import <objc/runtime.h>
#import "MLAAnimator+Private.h"
#import "MLAAnimationPrivate.h"

static char kMLAAnimationDelegate;

@interface MLAWeakDelegate : NSObject
@property (nonatomic, weak) id<MLAAnimationDelegate> delegate;
@end

@implementation MLAWeakDelegate
@end

@implementation NSObject (Animator)

- (id<MLAAnimationDelegate>)mla_delegate {
    MLAWeakDelegate* weakObj = objc_getAssociatedObject(self, &kMLAAnimationDelegate);
    return weakObj.delegate;
}

- (void)setMla_delegate:(id<MLAAnimationDelegate>)delegate {
    if (delegate) {
        MLAWeakDelegate *weakObj = [MLAWeakDelegate new];
        weakObj.delegate = delegate;
        objc_setAssociatedObject(self, &kMLAAnimationDelegate, weakObj, OBJC_ASSOCIATION_ASSIGN);
    } else {
        objc_setAssociatedObject(self, &kMLAAnimationDelegate, NULL, OBJC_ASSOCIATION_ASSIGN);
    }
}

- (void)mla_addAnimation:(MLAAnimation *)animation forKey:(NSString *)key {
    if (animation && key) {
        [animation setInnerKey:key];
        [animation start];
    }
   
}

- (void)mla_removeAnimation:(NSString *)key {
    [[MLAAnimator shareAnimator] removeAnimation:self forKey:key];
}

- (void)mla_removeAllAnimations {
    [[MLAAnimator shareAnimator] removeAnimation:self];
}

@end
