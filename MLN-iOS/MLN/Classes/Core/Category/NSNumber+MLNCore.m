//
//  NSNumber+MLNCore.m
//  MLNCore
//
//  Created by MoMo on 2019/7/23.
//

#import "NSNumber+MLNCore.h"
#import "NSObject+MLNCore.h"

@implementation NSNumber (MLNCore)

- (MLNNativeType)mln_nativeType
{
    return MLNNativeTypeNumber;
}

- (BOOL)mln_isMultiple
{
    return NO;
}

@end
