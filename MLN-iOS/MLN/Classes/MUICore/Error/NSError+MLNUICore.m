//
//  NSError+MLNUICore.m
//  MLNUICore
//
//  Created by MoMo on 2019/7/23.
//

#import "NSError+MLNUICore.h"

@implementation NSError (MLNUICore)

+ (instancetype)mlnui_errorLoad:(NSString *)msg {
    return [self mlnui_error:NSErrorCodeLoad msg:msg];
}

+ (instancetype)mlnui_errorCall:(NSString *)msg {
    return [self mlnui_error:NSErrorCodeCall msg:msg];
}

+ (instancetype)mlnui_errorState:(NSString *)msg {
    return [self mlnui_error:NSErrorCodeState msg:msg];
}

+ (instancetype)mlnui_errorOpenLib:(NSString *)msg {
    return [self mlnui_error:NSErrorCodeOpenLib msg:msg];
}

+ (instancetype)mlnui_errorConvert:(NSString *)msg {
    return [self mlnui_error:NSErrorCodeConvert msg:msg];
}

+ (instancetype)mlnui_error:(int)code msg:(NSString *)msg {
    NSParameterAssert(msg);
    return [self errorWithDomain:kMLNUI_ERROR_DOMAIN code:code userInfo:@{kMLNUI_ERROR_MSG : msg}];
}

- (NSString *)mlnui_errorMessage {
    return [self.userInfo objectForKey:kMLNUI_ERROR_MSG];
}

@end
