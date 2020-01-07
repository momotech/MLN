//
//  MLNDebugContext.m
//  MLNDevTool
//
//  Created by MOMO on 2020/1/6.
//

#import "MLNDebugContext.h"
#import "NSBundle+MLNDebugTool.h"

@implementation MLNDebugContext

+ (MLNDebugContext *)sharedContext {
    static MLNDebugContext *context = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        context = [[MLNDebugContext alloc] init];
    });
    return context;
}

+ (NSBundle *)debugBundle {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundle = [NSBundle bundleWithClass:[self class] name:@"MLNDevTool_Util"];
    });
    return bundle;
}

+ (NSString *)mln_debugIp {
    return [MLNDebugContext sharedContext].ipAddress;
}

+ (NSInteger)mln_debugPort {
    return [MLNDebugContext sharedContext].port;
}

LUA_EXPORT_STATIC_BEGIN(MLNDebugContext)
LUA_EXPORT_STATIC_METHOD(debugIp, "mln_debugIp", MLNDebugContext)
LUA_EXPORT_STATIC_METHOD(debugPort, "mln_debugPort", MLNDebugContext)
LUA_EXPORT_STATIC_END(MLNDebugContext, DebugContext, NO, NULL)

@end
