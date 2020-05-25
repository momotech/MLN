//
//  NSDictionary+MLNUICore.m
//  MLNUICore
//
//  Created by MoMo on 2019/7/23.
//

#import "NSDictionary+MLNUICore.h"
#import "NSObject+MLNUICore.h"

@implementation NSDictionary (MLNUICore)

- (MLNUINativeType)mln_nativeType
{
    return MLNUINativeTypeDictionary;
}

@end
