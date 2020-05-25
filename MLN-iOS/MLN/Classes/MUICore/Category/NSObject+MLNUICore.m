//
//  NSObject+MLNUICore.m
//  MLNUICore
//
//  Created by MoMo on 2019/7/23.
//

#import "NSObject+MLNUICore.h"
#import <objc/runtime.h>

@implementation NSObject (MLNUICore)

- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore
{
    if (self =  [self init]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [self performSelector:@selector(setMlnui_luaCore:) withObject:luaCore];
#pragma clang diagnostic pop
    }
    return self;
}

- (void)mlnui_user_data_dealloc
{
    // do nothing
}

- (BOOL)mlnui_isMultiple
{
    return NO;
}

- (NSArray *)mlnui_multipleParams
{
    return nil;
}

static const void *kMLNUIIsLuaObject = &kMLNUIIsLuaObject;

- (BOOL)mlnui_isLuaObject
{
    if (self.mlnui_isConvertible) {
        return [objc_getAssociatedObject(self, kMLNUIIsLuaObject) boolValue];
    }
    return NO;
}

- (void)setMlnui_isLuaObject:(BOOL)mlnui_isLuaObject
{
    // 可转换前提下，才能标记为非Native视图
    if (self.mlnui_isConvertible) {
        objc_setAssociatedObject(self, kMLNUIIsLuaObject, @(mlnui_isLuaObject), OBJC_ASSOCIATION_ASSIGN);
    }
}

- (MLNUINativeType)mlnui_nativeType
{
    return MLNUINativeTypeObject;
}

- (BOOL)mlnui_isConvertible
{
    return NO;
}

- (BOOL)mlnui_isCustomConversion
{
    return NO;
}

- (BOOL)mlnui_convertToLuaStack:(NSError **)error
{
    return NO;
}

+ (MLNUIExportType)mlnui_exportType
{
    return MLNUIExportTypeNone;
}


- (id)mlnui_rawNativeData
{
    return self;
}

@end
