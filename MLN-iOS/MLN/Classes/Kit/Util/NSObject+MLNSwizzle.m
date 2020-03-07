//
//  NSObject+MLNSwizzle.m
//  AFNetworking
//
//  Created by Dai Dongpeng on 2020/3/7.
//

#import "NSObject+MLNSwizzle.h"
@import ObjectiveC;

@implementation NSObject (MLNSwizzle)

+ (void)mln_swizzleInstanceSelector:(SEL)originSelector
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

+ (void)mln_swizzleInstanceSelector:(SEL)originSelector withNewSelector:(SEL)newSelector newImpBlock:(id)block forceAddOriginImpBlock:(id)originBlock {
    if (originBlock) {
        Method originMethod = class_getInstanceMethod(self, originSelector);
        IMP imp = imp_implementationWithBlock(originBlock);
        __unused BOOL res = class_addMethod(self, originSelector, imp, method_getTypeEncoding(originMethod));
        NSLog(@"add %s : %@", sel_getName(originSelector), res?@"OK":@"failed");
    }
    
    [self mln_swizzleInstanceSelector:originSelector withNewSelector:newSelector newImpBlock:block];
}

+ (void)mln_swizzleClassSelector:(SEL)originSelector
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
