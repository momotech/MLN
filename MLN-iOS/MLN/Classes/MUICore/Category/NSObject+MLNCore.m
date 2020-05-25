//
//  NSObject+MLNCore.m
//  MLNCore
//
//  Created by MoMo on 2019/7/23.
//

#import "NSObject+MLNCore.h"
#import <objc/runtime.h>

@implementation NSObject (MLNCore)

- (instancetype)initWithLuaCore:(MLNLuaCore *)luaCore
{
    if (self =  [self init]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [self performSelector:@selector(setMln_luaCore:) withObject:luaCore];
#pragma clang diagnostic pop
    }
    return self;
}

- (void)mln_user_data_dealloc
{
    // do nothing
}

- (BOOL)mln_isMultiple
{
    return NO;
}

- (NSArray *)mln_multipleParams
{
    return nil;
}

static const void *kMLNIsLuaObject = &kMLNIsLuaObject;

- (BOOL)mln_isLuaObject
{
    if (self.mln_isConvertible) {
        return [objc_getAssociatedObject(self, kMLNIsLuaObject) boolValue];
    }
    return NO;
}

- (void)setMln_isLuaObject:(BOOL)mln_isLuaObject
{
    // 可转换前提下，才能标记为非Native视图
    if (self.mln_isConvertible) {
        objc_setAssociatedObject(self, kMLNIsLuaObject, @(mln_isLuaObject), OBJC_ASSOCIATION_ASSIGN);
    }
}

- (MLNNativeType)mln_nativeType
{
    return MLNNativeTypeObject;
}

- (BOOL)mln_isConvertible
{
    return NO;
}

- (BOOL)mln_isCustomConversion
{
    return NO;
}

- (BOOL)mln_convertToLuaStack:(NSError **)error
{
    return NO;
}

+ (MLNExportType)mln_exportType
{
    return MLNExportTypeNone;
}


- (id)mln_rawNativeData
{
    return self;
}

@end
