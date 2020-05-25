//
//  NSNumber+MLNUICore.m
//  MLNUICore
//
//  Created by MoMo on 2019/7/23.
//

#import "NSNumber+MLNUICore.h"
#import "NSObject+MLNUICore.h"

@implementation NSNumber (MLNUICore)

- (MLNUINativeType)mln_nativeType
{
    return MLNUINativeTypeNumber;
}

- (BOOL)mln_isMultiple
{
    return NO;
}

@end
