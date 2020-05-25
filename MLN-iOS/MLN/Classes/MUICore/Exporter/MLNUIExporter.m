//
//  MLNUIExporter.m
//  MLNUICore
//
//  Created by MoMo on 2019/7/23.
//

#import "MLNUIExporter.h"

@implementation MLNUIExporter

@synthesize luaCore = _luaCore;

- (instancetype)initWithLuaCore:(MLNUILuaCore *)luaCore
{
    NSParameterAssert(luaCore);
    if (self = [super init]) {
        _luaCore = luaCore;
    }
    return self;
}

- (BOOL)exportClass:(Class<MLNUIExportProtocol>)clazz error:(NSError **)error
{
    // 子类实现
    return NO;
}

@end
