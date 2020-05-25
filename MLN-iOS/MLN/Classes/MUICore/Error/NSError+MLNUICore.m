//
//  NSError+MLNUICore.m
//  MLNUICore
//
//  Created by MoMo on 2019/7/23.
//

#import "NSError+MLNUICore.h"

@implementation NSError (MLNUICore)

+ (instancetype)mln_errorLoad:(NSString *)msg {
    return [self mln_error:NSErrorCodeLoad msg:msg];
}

+ (instancetype)mln_errorCall:(NSString *)msg {
    return [self mln_error:NSErrorCodeCall msg:msg];
}

+ (instancetype)mln_errorState:(NSString *)msg {
    return [self mln_error:NSErrorCodeState msg:msg];
}

+ (instancetype)mln_errorOpenLib:(NSString *)msg {
    return [self mln_error:NSErrorCodeOpenLib msg:msg];
}

+ (instancetype)mln_errorConvert:(NSString *)msg {
    return [self mln_error:NSErrorCodeConvert msg:msg];
}

+ (instancetype)mln_error:(int)code msg:(NSString *)msg {
    NSParameterAssert(msg);
    return [self errorWithDomain:kMLNUI_ERROR_DOMAIN code:code userInfo:@{kMLNUI_ERROR_MSG : msg}];
}

- (NSString *)mln_errorMessage {
    return [self.userInfo objectForKey:kMLNUI_ERROR_MSG];
}

@end
