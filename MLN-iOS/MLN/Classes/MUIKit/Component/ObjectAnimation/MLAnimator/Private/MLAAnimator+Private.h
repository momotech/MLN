//
//  MLAAnimator+Private.h
//  MLAnimator
//
//  Created by Boztrail on 2020/5/17.
//  Copyright © 2020 Boztrail. All rights reserved.
//

#import "MLAAnimator.h"
#import "MLAAnimation.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLAAnimator ()

- (void)addAnimation:(MLAAnimation *)animation forObject:(id)obj andKey:(NSString*)key;

- (void)removeAnimation:(id)obj;

- (void)removeAnimation:(id)obj forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
