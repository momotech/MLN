//
//  NSMutableDictionary+MLNUICore.m
//  MLNUICore
//
//  Created by MoMo on 2019/7/23.
//

#import "NSMutableDictionary+MLNUICore.h"
#import "NSObject+MLNUICore.h"

@implementation NSMutableDictionary (MLNUICore)

- (MLNUINativeType)mln_nativeType
{
    // @note: 适配iOS10 之前的类簇问题
    if ([NSStringFromClass([self class]) hasPrefix:@"__NSDictionaryM"]) {
        return MLNUINativeTypeMDictionary;
    }
    return MLNUINativeTypeDictionary;
}

@end
