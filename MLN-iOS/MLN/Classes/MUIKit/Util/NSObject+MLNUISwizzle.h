//
//  NSObject+MLNUISwizzle.h
// MLNUI
//
//  Created by Dai Dongpeng on 2020/3/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (MLNUISwizzle)

+ (void)mlnui_swizzleInstanceSelector:(SEL)originSelector
                withNewSelector:(SEL)newSelector
                    newImpBlock:(id)block;

+ (void)mlnui_swizzleInstanceSelector:(SEL)originSelector
                    withNewSelector:(SEL)newSelector
                        newImpBlock:(id)block
             forceAddOriginImpBlock:(nullable id)originBlock;

+ (void)mlnui_swizzleInstanceSelector:(SEL)originSelector
                      withNewSelector:(SEL)newSelector
                          newImpBlock:(id)block
            addOriginImpBlockIfNeeded:(nullable id)originBlock;

+ (void)mlnui_swizzleClassSelector:(SEL)originSelector
             withNewSelector:(SEL)newSelector
                 newImpBlock:(id)block;

@end

NS_ASSUME_NONNULL_END
