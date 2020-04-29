//
//  MLNTestMe.m
//  MLNCore_Example
//
//  Created by MoMo on 2019/8/1.
//  Copyright © 2019 MoMo. All rights reserved.
//

#import "MLNTestMe.h"
#import "MLNBlock.h"
@import ObjectiveC;
@implementation MLNTestMe

- (NSNumber *)test:(NSString *)msg a:(NSNumber *)a
{
    return @(1000);
}

- (NSValue *)test:(CGRect)rect callback:(MLNBlock *)callback
{
    NSValue *value = @(rect);
    [callback addObjArgument:value];
    id ret = [callback callIfCan];
    NSLog(@"%@", ret);
    return @(CGSizeMake(90, 89));
}

- (void)dealloc {
    Class cls = object_getClass(self);
    NSLog(@"%s %@",__func__, cls);
}

LUA_EXPORT_BEGIN(MLNTestMe)
LUA_EXPORT_METHOD(test, "test:a:", MLNTestMe)
LUA_EXPORT_METHOD(testcall, "test:callback:", MLNTestMe)
LUA_EXPORT_END(MLNTestMe, TestMe, NO, NULL, NULL)

@end
