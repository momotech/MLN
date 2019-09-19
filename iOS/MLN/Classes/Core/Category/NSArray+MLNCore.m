//
//  NSArray+MLNCore.m
//  MLNCore
//
//  Created by MoMo on 2019/7/23.
//

#import "NSArray+MLNCore.h"
#import "NSObject+MLNCore.h"

@implementation NSArray (MLNCore)

- (MLNNativeType)mln_nativeType
{
    return MLNNativeTypeArray;
}

@end
