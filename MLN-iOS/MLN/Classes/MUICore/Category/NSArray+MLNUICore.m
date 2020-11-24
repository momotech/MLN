//
//  NSArray+MLNUICore.m
//  MLNUICore
//
//  Created by MoMo on 2019/7/23.
//

#import "NSArray+MLNUICore.h"
#import "NSObject+MLNUICore.h"
#import <objc/runtime.h>

@implementation NSArray (MLNUICore)

- (MLNUINativeType)mlnui_nativeType
{
    return MLNUINativeTypeArray;
}

- (void)setMlnui_metaArray:(NSMutableArray *)array {
    objc_setAssociatedObject(self, @selector(mlnui_metaArray), array, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)mlnui_metaArray {
    return objc_getAssociatedObject(self, _cmd);
}

@end
