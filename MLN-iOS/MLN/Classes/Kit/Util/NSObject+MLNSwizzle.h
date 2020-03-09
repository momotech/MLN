//
//  NSObject+MLNSwizzle.h
// MLN
//
//  Created by Dai Dongpeng on 2020/3/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (MLNSwizzle)

+ (void)mln_swizzleInstanceSelector:(SEL)originSelector
                withNewSelector:(SEL)newSelector
                    newImpBlock:(id)block;

+ (void)mln_swizzleInstanceSelector:(SEL)originSelector
                    withNewSelector:(SEL)newSelector
                        newImpBlock:(id)block
             forceAddOriginImpBlock:(nullable id)originBlock;

+ (void)mln_swizzleClassSelector:(SEL)originSelector
             withNewSelector:(SEL)newSelector
                 newImpBlock:(id)block;

@end

NS_ASSUME_NONNULL_END
