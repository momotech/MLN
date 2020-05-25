//
//  NSMutableArray+MLNUICore.m
//  MLNUICore
//
//  Created by MoMo on 2019/7/23.
//

#import "NSMutableArray+MLNUICore.h"
#import "NSObject+MLNUICore.h"

@implementation NSMutableArray (MLNUICore)

- (MLNUINativeType)mln_nativeType
{
    // @note: 适配iOS10 之前的类簇问题
    if ([NSStringFromClass([self class]) hasPrefix:@"__NSArrayM"]) {
        return MLNUINativeTypeMArray;
    }
    return MLNUINativeTypeArray;
}

@end
