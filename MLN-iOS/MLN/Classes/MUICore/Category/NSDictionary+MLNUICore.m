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

- (void)setMlnui_metaTable:(MLNUITable *)table {
    objc_setAssociatedObject(self, @selector(mlnui_metaTable), table, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUITable *)mlnui_metaTable {
    return objc_getAssociatedObject(self, _cmd);
}

@end
