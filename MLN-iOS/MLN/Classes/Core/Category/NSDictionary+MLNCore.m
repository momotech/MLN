//
//  NSDictionary+MLNCore.m
//  MLNCore
//
//  Created by MoMo on 2019/7/23.
//

#import "NSDictionary+MLNCore.h"
#import "NSObject+MLNCore.h"

@implementation NSDictionary (MLNCore)

- (MLNNativeType)mln_nativeType
{
    return MLNNativeTypeDictionary;
}

@end
