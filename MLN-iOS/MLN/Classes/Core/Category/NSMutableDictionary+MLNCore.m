//
//  NSMutableDictionary+MLNCore.m
//  MLNCore
//
//  Created by MoMo on 2019/7/23.
//

#import "NSMutableDictionary+MLNCore.h"
#import "NSObject+MLNCore.h"

@implementation NSMutableDictionary (MLNCore)

- (MLNNativeType)mln_nativeType
{
    // @note: 适配iOS10 之前的类簇问题
    if ([NSStringFromClass([self class]) hasPrefix:@"__NSDictionaryM"]) {
        return MLNNativeTypeMDictionary;
    }
    return MLNNativeTypeDictionary;
}

@end
