//
//  NSObject+MLNUISwizzle.m
// MLNUI
//
//  Created by Dai Dongpeng on 2020/3/7.
//

#import "NSObject+MLNUISwizzle.h"
@import ObjectiveC;

@implementation NSObject (MLNUISwizzle)

+ (void)mlnui_swizzleInstanceSelector:(SEL)originSelector
                withNewSelector:(SEL)newSelector
                    newImpBlock:(id)block
{
    IMP newImp = imp_implementationWithBlock(block);
    Method originalMethod = class_getInstanceMethod(self, originSelector);
    if (originalMethod && class_addMethod(self, newSelector, newImp, method_getTypeEncoding(originalMethod))) {
        Method newMethod = class_getInstanceMethod(self, newSelector);
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

+ (void)mlnui_swizzleInstanceSelector:(SEL)originSelector withNewSelector:(SEL)newSelector newImpBlock:(id)block forceAddOriginImpBlock:(id)originBlock {
    if (originBlock) {
        Method originMethod = class_getInstanceMethod(self, originSelector);
        IMP imp = imp_implementationWithBlock(originBlock);
        __unused BOOL res = class_addMethod(self, originSelector, imp, method_getTypeEncoding(originMethod));
    }
    
    [self mlnui_swizzleInstanceSelector:originSelector withNewSelector:newSelector newImpBlock:block];
}

+ (void)mlnui_swizzleInstanceSelector:(SEL)originSelector
                      withNewSelector:(SEL)newSelector
                          newImpBlock:(id)block
            addOriginImpBlockIfNeeded:(id)originBlock {
    IMP newImp = imp_implementationWithBlock(block);
    Method originMethod = class_getInstanceMethod(self, originSelector);
    NSAssert(originMethod || (!originMethod && originBlock), @"The method swizzle will be failed, because the origin method doesn't exist and the originBlock parameter is nil.");
    if (originMethod) {
        id block = imp_getBlock(method_getImplementation(originMethod));
        if ([block isKindOfClass:NSClassFromString(@"NSBlock")]) {
            return; // 暂时忽略originImp是block的情况（因为有可能是已经执行了一次方法交换）
        }
        class_addMethod(self, newSelector, newImp, method_getTypeEncoding(originMethod));
        BOOL added = class_addMethod(self, originSelector, newImp, method_getTypeEncoding(originMethod));
        if (added) {
            class_replaceMethod(self, newSelector, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
        } else {
            Method newMethod = class_getInstanceMethod(self, newSelector);
            method_exchangeImplementations(originMethod, newMethod);
        }
    } else {
        if (originBlock) {
            [self mlnui_swizzleInstanceSelector:originSelector withNewSelector:newSelector newImpBlock:block forceAddOriginImpBlock:originBlock];
        } else {
            // swizzle failed
        }
    }
}

+ (void)mlnui_swizzleClassSelector:(SEL)originSelector
             withNewSelector:(SEL)newSelector
                 newImpBlock:(id)block
{
    IMP newImp = imp_implementationWithBlock(block);
    Method originalMethod = class_getClassMethod(self, originSelector);
    if (originalMethod && class_addMethod(object_getClass(self), newSelector, newImp, method_getTypeEncoding(originalMethod))) {
        Method newMethod = class_getClassMethod(self, newSelector);
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

@end
