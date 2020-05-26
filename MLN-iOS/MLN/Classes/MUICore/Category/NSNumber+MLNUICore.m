//
//  NSNumber+MLNUICore.m
//  MLNUICore
//
//  Created by MoMo on 2019/7/23.
//

#import "NSNumber+MLNUICore.h"
#import "NSObject+MLNUICore.h"

@implementation NSNumber (MLNUICore)

- (MLNUINativeType)mlnui_nativeType
{
    return MLNUINativeTypeNumber;
}

- (BOOL)mlnui_isMultiple
{
    return NO;
}

@end
