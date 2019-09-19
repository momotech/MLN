//
//  NSBundle+HotReload.m
//  MLN
//
//  Created by MoMo on 2019/9/10.
//

#import "NSBundle+MLNDebugTool.h"

@implementation NSBundle (MLNDebugTool)

+ (instancetype)bundleWithClass:(Class)clazz name:(NSString *)name
{
    return [NSBundle bundleWithPath:[[NSBundle bundleForClass:clazz] pathForResource:name ofType:@"bundle"]];
}

- (NSString *)pngPathWithName:(NSString *)name
{
    return [self pathForResource:name ofType:@"png"];
}

- (NSString *)luaPathWithName:(NSString *)name
{
    return [self pathForResource:name ofType:@"lua"];
}

@end
