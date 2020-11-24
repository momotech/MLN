//
//  NSDictionary+MLNUICore.m
//  MLNUICore
//
//  Created by MoMo on 2019/7/23.
//

#import "NSDictionary+MLNUICore.h"
#import "NSObject+MLNUICore.h"
#import <objc/runtime.h>

@implementation NSDictionary (MLNUICore)

- (MLNUINativeType)mlnui_nativeType
{
    return MLNUINativeTypeDictionary;
}

- (void)setMlnui_metaDictionary:(NSMutableDictionary *)dic {
    objc_setAssociatedObject(self, @selector(mlnui_metaDictionary), dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)mlnui_metaDictionary {
    return objc_getAssociatedObject(self, _cmd);
}

@end
