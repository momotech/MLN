//
//  MLNExporter.m
//  MLNCore
//
//  Created by MoMo on 2019/7/23.
//

#import "MLNExporter.h"

@implementation MLNExporter

@synthesize luaCore = _luaCore;

- (instancetype)initWithLuaCore:(MLNLuaCore *)luaCore
{
    NSParameterAssert(luaCore);
    if (self = [super init]) {
        _luaCore = luaCore;
    }
    return self;
}

- (BOOL)exportClass:(Class<MLNExportProtocol>)clazz error:(NSError **)error
{
    // 子类实现
    return NO;
}

@end
