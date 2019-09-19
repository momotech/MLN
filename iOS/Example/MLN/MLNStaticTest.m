//
//  MLNStaticTest.m
//  MLNCore_Example
//
//  Created by MoMo on 2019/8/1.
//  Copyright © 2019 MoMo. All rights reserved.
//

#import "MLNStaticTest.h"

@implementation MLNStaticTest

+ (NSString *)test:(NSString *)msg
{
    return [NSString stringWithFormat:@"Native_%@", msg];
}

LUA_EXPORT_STATIC_BEGIN(MLNStaticTest)
LUA_EXPORT_STATIC_METHOD(test, "test:", MLNStaticTest)
LUA_EXPORT_STATIC_END(MLNStaticTest, StaticTest, NO, NULL)

@end
