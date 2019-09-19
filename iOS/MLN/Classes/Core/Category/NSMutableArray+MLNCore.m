//
//  NSMutableArray+MLNCore.m
//  MLNCore
//
//  Created by MoMo on 2019/7/23.
//

#import "NSMutableArray+MLNCore.h"
#import "NSObject+MLNCore.h"

@implementation NSMutableArray (MLNCore)

- (MLNNativeType)mln_nativeType
{
    // @note: 适配iOS10 之前的类簇问题
    if ([NSStringFromClass([self class]) hasPrefix:@"__NSArrayM"]) {
        return MLNNativeTypeMArray;
    }
    return MLNNativeTypeArray;
}

@end
